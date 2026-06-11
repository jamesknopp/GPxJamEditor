unit JamRCRRender;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes,
  System.IOUtils,
  Vcl.Graphics, Vcl.Imaging.pngimage,
  JamGeneral, JamSW, JamPalette;

type
  TRCRMode = (rcrGP2, rcrGP3Single, rcrGP3Multi);

  TRCRTextures = record
    Livery:  TBitmap;   // GP2 + GP3-multi
    Chassis: TBitmap;   // GP3-multi only
    Tyre:    TBitmap;   // GP3-single + GP3-multi
    Helmet:  TBitmap;   // GP3-multi only — drives mask value 7
  end;

  TRCRRenderOptions = record
    Mode:        TRCRMode;
    Textures:    TRCRTextures;
    Background:  TColor;
    SwapUV:      Boolean;   // Diagnostic: when True, treat odd byte as U and
                            // even byte as V (the inverse of the normal
                            // even=U, odd=V convention). Useful for
                            // troubleshooting JAMs with unknown encoding.
    UOffset:     Byte;      // GP3-single only: horizontal U-coord offset
                            // added before sampling Textures.Tyre. Used by
                            // the harness wheel-spin preview. Ignored by
                            // GP2 and GP3-multi.
  end;

const
  GP3_LIVERY_SECTION1_Y = 128;
  GP3_LIVERY_SECTION2_Y = 256;

// Returns the per-mode default background colour.
function DefaultBackgroundFor(Mode: TRCRMode): TColor;

// Loads a BMP, PNG, or JAM from disk and returns a freshly-created
// pf24bit TBitmap. For JAM inputs, Mode selects the palette used to
// resolve pixel indices: rcrGP2 uses the GP2 master palette,
// rcrGP3Single/Multi use the GP3 master palette. BMP and PNG inputs
// carry their own embedded palette so Mode is ignored for those.
// Caller must Free the result.
function LoadTextureBitmap(const Filename: string;
  Mode: TRCRMode = rcrGP3Single): TBitmap;

// Renders a single entry from one of the helmet JAMs as a 24-bit TBitmap.
// The entry is chosen by JamID; the function searches both supplied JAM
// files and returns the first match (HelmetsDPath wins ties). Returns nil
// if not found. Caller must Free the result.
function LoadHelmetByJamID(const HelmetsDPath, HelmetsEPath: string;
  JamID: Word): TBitmap;

// Loads a JAM in isolation from the application's global JAM state.
// TJamFile.LoadFromFile and the load chain it invokes mutate ~18 module
// globals (boolRcrJam, boolJipMode, boolGP2Jam, boolGP3Jam, boolHWJAM,
// boolJamLoaded, boolJamIssues, boolUndo, boolJamModified, boolGP2Livery,
// boolRCRDrawMode, boolTexSelected, generatePal, intJamMaxWidth/Height,
// intPaletteID, intSelectedTexture, plus GPXPal[]) — that's fine for the
// editor's own load path, but when the RCR render dialog loads JAMs
// purely for rendering it would clobber the editor's state. This helper
// snapshots all of them, performs the load, and restores them before
// returning. Caller owns the returned TJamFile (or nil on failure).
function LoadIsolatedJam(const Path: string): TJamFile;

// Layer 1 - pure pixel pipeline. EvenBmp/OddBmp must be 8-bit indexed.
// MaskBmp is required for rcrGP3Multi, must be nil for other modes.
// Caller owns input bitmaps; result is owned by caller.
function RenderRCRFromBitmaps(
  const EvenBmp, OddBmp: TBitmap;
  const MaskBmp: TBitmap;
  const Options: TRCRRenderOptions
): TBitmap;

// Layer 2 - JAM-aware facade.
function RenderRCRFromJam(
  Jam: TJamFile;
  const Options: TRCRRenderOptions;
  const PartnerMaskJam: TJamFile = nil
): TBitmap;

function RenderRCREntryFromJam(
  Jam: TJamFile;
  EntryIndex: Integer;
  const Options: TRCRRenderOptions;
  const PartnerMaskJam: TJamFile = nil
): TBitmap;

// Filename-based mode hint. Returns rcrGP2 for unrecognised filenames so the
// caller can show *something*; PartnerName is set when the filename suggests
// a known mask partner (e.g. "rcr1a" -> "rcr1b").
function DetectRCRMode(const JamFilename: string;
                      out PartnerName: string): TRCRMode;

implementation

type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..MaxInt div SizeOf(TRGBTriple) - 1] of TRGBTriple;

// Reads a pixel from a pf24bit bitmap, clamping to bounds.
// Caller must ensure Tex.PixelFormat = pf24bit before calling.
function SamplePixel(Tex: TBitmap; X, Y: Integer): TRGBTriple; inline;
var
  row: PRGBTripleArray;
begin
  if X < 0 then X := 0
  else if X >= Tex.Width then X := Tex.Width - 1;
  if Y < 0 then Y := 0
  else if Y >= Tex.Height then Y := Tex.Height - 1;
  row := Tex.ScanLine[Y];
  Result := row[X];
end;

function DefaultBackgroundFor(Mode: TRCRMode): TColor;
begin
  case Mode of
    rcrGP2:                    Result := TCol_TransGP2;
    rcrGP3Single, rcrGP3Multi: Result := TCol_TransGP3;
  else
    Result := clBlack;
  end;
end;

// Renders a non-RCR SW JAM's canvas to a fresh 24-bit TBitmap by
// compositing each entry's raw texture bytes through its local palette
// mapping into the chosen master palette (GP2 for rcrGP2, GP3 for
// the GP3 modes). We do all the index -> RGB translation explicitly
// so we don't depend on:
//   - the per-bitmap palette set by DrawSingleTexture (which can be
//     mishandled by GDI when copying onto a 24-bit canvas)
//   - the global gpxPal variable (only initialised by SetGpxPal,
//     which LoadFromFile does not call)
//   - DrawFullJam's wider chain of global state
// Index 0 from each local palette renders as the master palette's
// transparent colour.
function RenderJamCanvas24Bit(jam: TJamFile; Mode: TRCRMode): TBitmap;
const
  CANVAS_W = 256;
var
  canvasH, i, X, Y, entryW, entryH, X0, Y0, palCount, k: Integer;
  entry: TJamEntry;
  rawTex: TBytes;
  localToMaster: array[0..255] of Byte;
  outRow: PRGBTriple;
  masterIdx: Byte;
  master: TRGBArray;
  bgR, bgG, bgB: Byte;
begin
  canvasH := jam.FHeader.JamTotalHeight;
  if canvasH < 1 then
    raise Exception.Create('JAM has no canvas data');

  // GP2Pal / GP3Pal are declared as anonymous-typed const arrays in
  // JamPalette, so a typed assignment fails Delphi's type check; copy
  // the 768 bytes once via Move and the rest of the function reads
  // from the named-type local.
  if Mode = rcrGP2 then
    Move(GP2Pal[0], master[0], SizeOf(master))
  else
    Move(GP3Pal[0], master[0], SizeOf(master));

  bgR := master[0].R;
  bgG := master[0].G;
  bgB := master[0].b;

  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf24bit;
    Result.SetSize(CANVAS_W, canvasH);

    // Fill with master palette index 0 (per-mode transparent colour).
    for Y := 0 to canvasH - 1 do
    begin
      outRow := Result.ScanLine[Y];
      for X := 0 to CANVAS_W - 1 do
      begin
        outRow^.rgbtRed   := bgR;
        outRow^.rgbtGreen := bgG;
        outRow^.rgbtBlue  := bgB;
        Inc(outRow);
      end;
    end;

    for i := 0 to jam.FEntries.Count - 1 do
    begin
      entry := jam.FEntries[i];
      entryW := entry.FInfo.Width;
      entryH := entry.FInfo.Height;
      X0 := entry.FInfo.X;
      Y0 := entry.FInfo.Y;
      if (entryW = 0) or (entryH = 0) then Continue;
      rawTex := entry.FRawTexture;
      if Length(rawTex) < entryW * entryH then Continue;

      // Build local-to-master index mapping: identity by default,
      // overridden by the entry's first local palette.
      for k := 0 to 255 do
        localToMaster[k] := k;
      palCount := entry.FInfo.PaletteSizeDiv4;
      if palCount > 256 then palCount := 256;
      if (Length(entry.FPalettes[0]) >= palCount) and (palCount > 0) then
        for k := 0 to palCount - 1 do
          localToMaster[k] := entry.FPalettes[0][k];

      for Y := 0 to entryH - 1 do
      begin
        if Y0 + Y >= canvasH then Break;
        outRow := Result.ScanLine[Y0 + Y];
        Inc(outRow, X0);
        for X := 0 to entryW - 1 do
        begin
          if X0 + X >= CANVAS_W then Break;
          masterIdx := localToMaster[rawTex[Y * entryW + X]];
          outRow^.rgbtRed   := master[masterIdx].R;
          outRow^.rgbtGreen := master[masterIdx].G;
          outRow^.rgbtBlue  := master[masterIdx].b;
          Inc(outRow);
        end;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function LoadTextureBitmap(const Filename: string;
  Mode: TRCRMode): TBitmap;
var
  ext: string;
  png: TPngImage;
  jam: TJamFile;
begin
  ext := LowerCase(ExtractFileExt(Filename));
  if ext = '.jam' then
  begin
    jam := LoadIsolatedJam(Filename);
    if jam = nil then
      raise Exception.CreateFmt('Failed to load JAM as texture: %s',
        [Filename]);
    try
      Result := RenderJamCanvas24Bit(jam, Mode);
    finally
      jam.Free;
    end;
    Exit;
  end;

  Result := TBitmap.Create;
  try
    if ext = '.png' then
    begin
      png := TPngImage.Create;
      try
        png.LoadFromFile(Filename);
        Result.Assign(png);
      finally
        png.Free;
      end;
    end
    else
      Result.LoadFromFile(Filename);
    Result.PixelFormat := pf24bit;
  except
    Result.Free;
    raise;
  end;
end;

// Renders a single helmet entry's raw texture bytes through its first
// local palette into a pf24bit TBitmap. Helmets are GP3-only, so the GP3
// master palette is hardcoded. Mirrors RenderJamCanvas24Bit's per-entry
// inner loop but produces an entry-sized bitmap rather than compositing
// onto a 256-wide canvas.
function RenderHelmetEntry(jam: TJamFile; entry: TJamEntry): TBitmap;
var
  W, H, X, Y, palCount, k: Integer;
  rawTex: TBytes;
  localToMaster: array[0..255] of Byte;
  outRow: PRGBTriple;
  master: TRGBArray;
  masterIdx: Byte;
begin
  W := entry.FInfo.Width;
  H := entry.FInfo.Height;
  if (W = 0) or (H = 0) then
  begin
    Result := nil;
    Exit;
  end;
  rawTex := entry.FRawTexture;
  if Length(rawTex) < W * H then
  begin
    Result := nil;
    Exit;
  end;

  Move(GP3Pal[0], master[0], SizeOf(master));

  for k := 0 to 255 do
    localToMaster[k] := k;
  palCount := entry.FInfo.PaletteSizeDiv4;
  if palCount > 256 then palCount := 256;
  if (Length(entry.FPalettes[0]) >= palCount) and (palCount > 0) then
    for k := 0 to palCount - 1 do
      localToMaster[k] := entry.FPalettes[0][k];

  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf24bit;
    Result.SetSize(W, H);
    for Y := 0 to H - 1 do
    begin
      outRow := Result.ScanLine[Y];
      for X := 0 to W - 1 do
      begin
        masterIdx := localToMaster[rawTex[Y * W + X]];
        outRow^.rgbtRed   := master[masterIdx].R;
        outRow^.rgbtGreen := master[masterIdx].G;
        outRow^.rgbtBlue  := master[masterIdx].b;
        Inc(outRow);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function LoadIsolatedJam(const Path: string): TJamFile;
var
  SavedPal: array [0..255] of TRGB;
  SavedRcr, SavedJip, SavedGP2, SavedGP3, SavedHW, SavedLoaded,
  SavedIssues, SavedUndo, SavedGenPal, SavedModified,
  SavedGP2Livery, SavedRCRDraw, SavedTexSelected: Boolean;
  SavedMaxW, SavedMaxH, SavedPalID, SavedSelTex: Integer;
  i: Integer;
begin
  Result := nil;
  if (Path = '') or not FileExists(Path) then Exit;

  // Snapshot every global TJamFile.LoadFromFile (or its callees) might
  // touch. Mirrors the list in JamBrowser's batch-thumbnail path.
  for i := 0 to 255 do
    SavedPal[i] := GPXPal[i];
  SavedRcr         := boolRcrJam;
  SavedJip         := boolJipMode;
  SavedMaxW        := intJamMaxWidth;
  SavedMaxH        := intJamMaxHeight;
  SavedPalID       := intPaletteID;
  SavedGP2         := boolGP2Jam;
  SavedGP3         := boolGP3Jam;
  SavedHW          := boolHWJAM;
  SavedLoaded      := boolJamLoaded;
  SavedIssues      := boolJamIssues;
  SavedUndo        := boolUndo;
  SavedGenPal      := generatePal;
  SavedModified    := boolJamModified;
  SavedGP2Livery   := boolGP2Livery;
  SavedRCRDraw     := boolRCRDrawMode;
  SavedTexSelected := boolTexSelected;
  SavedSelTex      := intSelectedTexture;

  try
    Result := TJamFile.Create;
    try
      if not Result.LoadFromFile(Path, False) then
        FreeAndNil(Result);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    for i := 0 to 255 do
      GPXPal[i] := SavedPal[i];
    boolRcrJam         := SavedRcr;
    boolJipMode        := SavedJip;
    intJamMaxWidth     := SavedMaxW;
    intJamMaxHeight    := SavedMaxH;
    intPaletteID       := SavedPalID;
    boolGP2Jam         := SavedGP2;
    boolGP3Jam         := SavedGP3;
    boolHWJAM          := SavedHW;
    boolJamLoaded      := SavedLoaded;
    boolJamIssues      := SavedIssues;
    boolUndo           := SavedUndo;
    generatePal        := SavedGenPal;
    boolJamModified    := SavedModified;
    boolGP2Livery      := SavedGP2Livery;
    boolRCRDrawMode    := SavedRCRDraw;
    boolTexSelected    := SavedTexSelected;
    intSelectedTexture := SavedSelTex;
  end;
end;

function LoadHelmetByJamID(const HelmetsDPath, HelmetsEPath: string;
  JamID: Word): TBitmap;

  function FindAndRender(const Path: string): TBitmap;
  var
    jam: TJamFile;
    i: Integer;
  begin
    Result := nil;
    jam := LoadIsolatedJam(Path);
    if jam = nil then Exit;
    try
      for i := 0 to jam.FEntries.Count - 1 do
        if jam.FEntries[i].FInfo.JamID = JamID then
        begin
          Result := RenderHelmetEntry(jam, jam.FEntries[i]);
          Exit;
        end;
    finally
      jam.Free;
    end;
  end;

begin
  Result := FindAndRender(HelmetsDPath);
  if Result = nil then
    Result := FindAndRender(HelmetsEPath);
end;

function RenderRCRFromBitmaps(const EvenBmp, OddBmp: TBitmap;
  const MaskBmp: TBitmap; const Options: TRCRRenderOptions): TBitmap;
var
  W, H, X, Y: Integer;
  evenRow, oddRow, maskRow: PByteArray;
  outRow: PRGBTripleArray;
  U, V, T: Byte;
begin
  Assert(Assigned(EvenBmp) and Assigned(OddBmp), 'EvenBmp/OddBmp required');
  Assert(EvenBmp.Width = OddBmp.Width, 'Even/Odd width mismatch');
  Assert(EvenBmp.Height = OddBmp.Height, 'Even/Odd height mismatch');
  if EvenBmp.PixelFormat <> pf8bit then EvenBmp.PixelFormat := pf8bit;
  if OddBmp.PixelFormat  <> pf8bit then OddBmp.PixelFormat  := pf8bit;

  W := EvenBmp.Width;
  H := EvenBmp.Height;

  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf24bit;
    Result.SetSize(W, H);
    Result.Canvas.Brush.Color := Options.Background;
    Result.Canvas.FillRect(Rect(0, 0, W, H));

    case Options.Mode of
      rcrGP2:
        begin
          Assert(Assigned(Options.Textures.Livery),
            'Livery texture required for GP2');
          if Options.Textures.Livery.PixelFormat <> pf24bit then
            Options.Textures.Livery.PixelFormat := pf24bit;
          // Same shape as GP3 single: the even byte is U + livery mask,
          // the odd byte is V or a baked-in palette index (tyres + bg).
          // For non-zero U we sample the livery at (U, V); for U=0 we
          // resolve the odd byte directly through the GP2 master palette.
          for Y := 0 to H - 1 do
          begin
            evenRow := EvenBmp.ScanLine[Y];
            oddRow  := OddBmp.ScanLine[Y];
            outRow  := Result.ScanLine[Y];
            for X := 0 to W - 1 do
            begin
              U := evenRow[X];
              V := oddRow[X];
              if Options.SwapUV then begin T := U; U := V; V := T; end;
              if U <> 0 then
                outRow[X] := SamplePixel(Options.Textures.Livery, U, V)
              else
              begin
                outRow[X].rgbtRed   := GP2Pal[V].R;
                outRow[X].rgbtGreen := GP2Pal[V].G;
                outRow[X].rgbtBlue  := GP2Pal[V].b;
              end;
            end;
          end;
        end;

      rcrGP3Single:
        begin
          Assert(Assigned(Options.Textures.Tyre),
            'Tyre texture required for GP3 single');
          if Options.Textures.Tyre.PixelFormat <> pf24bit then
            Options.Textures.Tyre.PixelFormat := pf24bit;
          for Y := 0 to H - 1 do
          begin
            evenRow := EvenBmp.ScanLine[Y];   // U coordinate values
            oddRow  := OddBmp.ScanLine[Y];    // V coordinate values
            outRow  := Result.ScanLine[Y];
            for X := 0 to W - 1 do
            begin
              U := evenRow[X];
              V := oddRow[X];
              if Options.SwapUV then begin T := U; U := V; V := T; end;
              if (U <> 0) or (V <> 0) then
                outRow[X] := SamplePixel(Options.Textures.Tyre,
                                         (U + Options.UOffset) and $FF, V);
              // else leave background already filled
            end;
          end;
        end;

      rcrGP3Multi:
        begin
          Assert(Assigned(MaskBmp), 'MaskBmp required for GP3 multi');
          Assert(MaskBmp.Width = W, 'Mask width mismatch');
          Assert(MaskBmp.Height = H, 'Mask height mismatch');
          Assert(Assigned(Options.Textures.Livery)  and
                 Assigned(Options.Textures.Chassis) and
                 Assigned(Options.Textures.Tyre)    and
                 Assigned(Options.Textures.Helmet),
            'Livery/Chassis/Tyre/Helmet all required for GP3 multi');
          if MaskBmp.PixelFormat <> pf8bit then MaskBmp.PixelFormat := pf8bit;
          if Options.Textures.Livery.PixelFormat  <> pf24bit then Options.Textures.Livery.PixelFormat  := pf24bit;
          if Options.Textures.Chassis.PixelFormat <> pf24bit then Options.Textures.Chassis.PixelFormat := pf24bit;
          if Options.Textures.Tyre.PixelFormat    <> pf24bit then Options.Textures.Tyre.PixelFormat    := pf24bit;
          if Options.Textures.Helmet.PixelFormat  <> pf24bit then Options.Textures.Helmet.PixelFormat  := pf24bit;

          for Y := 0 to H - 1 do
          begin
            evenRow := EvenBmp.ScanLine[Y];   // U
            oddRow  := OddBmp.ScanLine[Y];    // V
            maskRow := MaskBmp.ScanLine[Y];
            outRow  := Result.ScanLine[Y];
            for X := 0 to W - 1 do
            begin
              U := evenRow[X];
              V := oddRow[X];
              if Options.SwapUV then begin T := U; U := V; V := T; end;
              case maskRow[X] of
                2, 6:    outRow[X] := SamplePixel(Options.Textures.Chassis, U, V);
                3:       outRow[X] := SamplePixel(Options.Textures.Livery, 255 - U, GP3_LIVERY_SECTION1_Y + V);
                4:       outRow[X] := SamplePixel(Options.Textures.Livery,       U, GP3_LIVERY_SECTION1_Y + V);
                5:       outRow[X] := SamplePixel(Options.Textures.Livery,       U, GP3_LIVERY_SECTION2_Y + V);
                7:       outRow[X] := SamplePixel(Options.Textures.Helmet,       U, V);
                8..11:   outRow[X] := SamplePixel(Options.Textures.Tyre,         U, V);
                // 0 (background) and 1 (shadow): leave background already filled.
              end;
            end;
          end;
        end;
    else
      raise ENotImplemented.Create('Mode not yet implemented');
    end;
  except
    Result.Free;
    raise;
  end;
end;

function RenderRCRFromJam(Jam: TJamFile; const Options: TRCRRenderOptions;
  const PartnerMaskJam: TJamFile): TBitmap;
const
  PARTNER_W = 256;
var
  evenBmp, oddBmp, maskBmp: TBitmap;
  partnerH, Y: Integer;
begin
  Assert(Assigned(Jam), 'Jam required');
  evenBmp := nil; oddBmp := nil; maskBmp := nil;
  try
    // The source RCR JAM is interleaved on a 512-wide canvas.
    // DrawFullRCR(odd=False) takes the even columns; (odd=True) the odd
    // columns. halfHeight=True returns a deinterlaced half-height canvas
    // matching the 256-wide sprite resolution.
    evenBmp := Jam.DrawFullRCR(Jam.FRawData, False, True);
    oddBmp  := Jam.DrawFullRCR(Jam.FRawData, True,  True);

    if Options.Mode = rcrGP3Multi then
    begin
      Assert(Assigned(PartnerMaskJam),
        'PartnerMaskJam required for GP3 multi');
      // The partner mask JAM (e.g. rcr1b) is a regular non-RCR JAM with a
      // flat 256-wide canvas - NOT interleaved. Wrap its raw data as an
      // 8-bit indexed bitmap directly; the index values themselves are the
      // mask values the engine routes on.
      partnerH := Length(PartnerMaskJam.FRawData) div PARTNER_W;
      if partnerH < 1 then
        raise Exception.Create('Partner mask JAM has no canvas data');
      maskBmp := TBitmap.Create;
      maskBmp.PixelFormat := pf8bit;
      maskBmp.SetSize(PARTNER_W, partnerH);
      for Y := 0 to partnerH - 1 do
        Move(PartnerMaskJam.FRawData[Y * PARTNER_W],
             maskBmp.ScanLine[Y]^, PARTNER_W);
    end;

    Result := RenderRCRFromBitmaps(evenBmp, oddBmp, maskBmp, Options);
  finally
    evenBmp.Free;
    oddBmp.Free;
    maskBmp.Free;
  end;
end;

function RenderRCREntryFromJam(Jam: TJamFile; EntryIndex: Integer;
  const Options: TRCRRenderOptions; const PartnerMaskJam: TJamFile): TBitmap;
var
  entry, partnerEntry: TJamEntry;
  partnerMaskBmp: TBitmap;
  i, W, H, Y: Integer;
begin
  Assert(Assigned(Jam), 'Jam required');
  Assert((EntryIndex >= 0) and (EntryIndex < Jam.FEntries.Count),
    'EntryIndex out of range');
  entry := Jam.FEntries[EntryIndex];
  Assert(Assigned(entry.rcrA) and Assigned(entry.rcrB),
    'Entry rcrA/rcrB not populated; load the JAM through the RCR draw path first');

  partnerMaskBmp := nil;
  try
    if Options.Mode = rcrGP3Multi then
    begin
      Assert(Assigned(PartnerMaskJam),
        'PartnerMaskJam required for GP3 multi');

      // Partner mask JAM (e.g. rcr1b) is a non-RCR JAM whose entries pair
      // with the source RCR JAM (rcr1a) by entry-index, NOT by JamID. Real
      // GP3 data uses disjoint JamID ranges for the two files (e.g.
      // 1280..1311 in rcr1a vs 1426..1457 in rcr1b) - matching by JamID
      // never finds the partner. The dimensions line up entry-for-entry, so
      // we use EntryIndex directly and assert the W/H sanity-match.
      if EntryIndex >= PartnerMaskJam.FEntries.Count then
        raise Exception.CreateFmt(
          'Partner mask JAM has %d entries; source needs index %d',
          [PartnerMaskJam.FEntries.Count, EntryIndex]);
      partnerEntry := PartnerMaskJam.FEntries[EntryIndex];

      W := partnerEntry.FInfo.Width;
      H := partnerEntry.FInfo.Height;
      if (W <> entry.FInfo.Width) or (H <> entry.FInfo.Height) then
        raise Exception.CreateFmt(
          'Partner entry %d dimensions %dx%d do not match source %dx%d',
          [EntryIndex, W, H, entry.FInfo.Width, entry.FInfo.Height]);
      if Length(partnerEntry.FRawTexture) < W * H then
        raise Exception.CreateFmt(
          'Partner entry %d has insufficient raw texture data',
          [EntryIndex]);

      partnerMaskBmp := TBitmap.Create;
      partnerMaskBmp.PixelFormat := pf8bit;
      partnerMaskBmp.SetSize(W, H);
      for Y := 0 to H - 1 do
        Move(partnerEntry.FRawTexture[Y * W],
             partnerMaskBmp.ScanLine[Y]^, W);
    end;

    Result := RenderRCRFromBitmaps(entry.rcrA, entry.rcrB, partnerMaskBmp, Options);
  finally
    partnerMaskBmp.Free;
  end;
end;

function DetectRCRMode(const JamFilename: string;
  out PartnerName: string): TRCRMode;
var
  base: string;
  i: Integer;
begin
  base := LowerCase(ChangeFileExt(ExtractFileName(JamFilename), ''));
  PartnerName := '';

  // GP3 multi-surface: rcr1a..rcr5a, rcr2b etc. are masks (won't be opened directly).
  if (Length(base) = 5) and StartsText('rcr', base) and EndsText('a', base) then
  begin
    PartnerName := Copy(base, 1, 4) + 'b';
    Exit(rcrGP3Multi);
  end;

  // GP3 single-surface wheel.
  if base = 'chwheel1' then
    Exit(rcrGP3Single);

  // GP2 known RCR variants.
  for i := Low(rcrJAMList) to High(rcrJAMList) do
    if base = LowerCase(rcrJAMList[i]) then
      Exit(rcrGP2);

  // Unknown - best guess GP2; the user can override in the dialog.
  Result := rcrGP2;
end;

end.
