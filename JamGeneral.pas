unit JamGeneral;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.IOUtils, System.Math,
  Winapi.Windows, Vcl.Graphics, System.Generics.Collections, Vcl.dialogs,
  Generics.Defaults;

const
  JAM_HW_MAGIC = $0098967F; // Magic number to identify it's a HW JAM

  CLIPBOARD_JAM = 'JamTexClipboard';
  CLIPBOARD_HWJAM = 'JamHWTexClipboard';

  TCol_TransGP2 = $007FAB97; // RGB(151,171,127)
  TCol_TransGP3 = $0067673F; // RGB(63,103,103)
  TCol_TransGP3HW = $00FFFF00; // RGB(0,255,255)

  TransparentColors: array [0 .. 2] of TColor = (TCol_TransGP2, TCol_TransGP3,
    TCol_TransGP3HW);

  baseKeyPath = '\Software\JKVFX\JamEditor\';
  MRUKeyPath = baseKeyPath + 'RecentFiles';

  // Single-instance support (see jamviewer.dpr and TFormMain.WMCopyData)
  JamEditorMutexName = 'JKVFX.JamEditor.SingleInstance';
  JamCopyDataOpenFile = $4A414D31; // WM_COPYDATA dwData tag ('JAM1')

  dx: array [0 .. 3] of Integer = (1, -1, 0, 0);
  dy: array [0 .. 3] of Integer = (0, 0, 1, -1);

type
  TRow = record
    Y: Integer;
    Height: Integer;
    UsedWidth: Integer;
  end;

  TGap = record
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  end;

type
  THWJamHeader = packed record
    NumItems: Word;
    JamTotalHeight: Word;
  end;

  THWJamEntryInfo = record
    PosRaw: Integer; // raw dword from words[0]+[1]<<16
    X, Y: Integer; // decoded Left/Top
    Width, Height: Word; // words[2], words[3]
    scaleX, scaleY, scaleFactor, scaleFlags: byte; // words 4  & 5
    word6: Word; // words[6]
    word7, word8: Word;
    JamID: Word; // words[9]
    jamflags: Word; // words[10]
    word11, word12, word13, word14, word15, word16: Word;

    FrameFlags: array [0 .. 15] of Boolean; // unpacked bits

    word6a, word6b, word7a, word7b, word8a, word8b, word11a, word11b, word12a,
      word12b, word13a, word13b, word14a, word14b, word15a, word15b, word16a,
      word16b: byte;
    NumFrames: Integer; // = 1 shl FrameCountExp
  end;

  TJamHeader = packed record
    NumItems: Word;
    JamTotalHeight: Word;
  end;

  TJamEntryInfo = packed record
    X: byte;
    Y: Word;
    Unk: byte; // totally unk?
    Width: Word;
    Height: Word;
    scaleX: byte;
    scaleY: byte;
    scaleFlag: byte;
    scaleFactor: byte;
    // Idx08: Word; // scale origin x & y?
    // Idx0A: Word; // scaling flags & factor?
    ImagePtr: Word;
    Idx0E: Word; // totally unk
    PaletteSizeDiv4: Word;
    JamID: Word;
    jamflags: Word; // flags
    Idx16: byte; // untex color 1; entry in palette
    Idx17: byte; // untext color 2; entry in palette
    Idx18: array [0 .. 7] of byte;
    // 3,4 and 6 seem to be used in car liveries (gp3)... maybe load up all JAM files and create CSVs with all the data to review??
  end;

  TJamRect = record
    X, Y: Integer;
    Width, Height: Integer;
    index: Integer;
    JamID: Integer;
    size: Integer;
  end;

  TJamRectIntersects = record
    JamID, intersectID: Integer;
  end;

type
  TJamType = (jamGP2, jamGP3SW, jamGP3HW, jamJIP);

var
  ClipboardJAM: uint;
  ClipboardhwJAM: uint;

  IntersectList: TList<TJamRectIntersects>;

  // JAM IDs of entries whose bounding box currently strays outside the
  // canvas (X < 0, Y < 0, X+Width > canvasWidth, or Y+Height > canvasHeight).
  // Populated alongside IntersectList by the sanity check.
  OffCanvasList: TList<Integer>;

  SelectedTextureList: TList<Integer>;
  rcrJAMList: array [0 .. 18] of string = (
    'rcr1a',

    'rcr2a',
    'rcr2b',

    'rcr3a',

    'rcr4a',

    'rcr5a',

    'chwheel1',
    'rcr1',
    'rcr2',
    'rcr3',
    'rcr4',
    'rcr5',
    'mhill',
    'SHILL',
    'car_srf',
    'hlm_srf',
    'ccp_srf',
    'ccp_srf2',
    'wh_srf'
  );

  intJamMaxWidth: Integer;
  intJamMaxHeight: Integer;

  boolAutoLayout: Boolean;

  boolRcrJam: Boolean;
  booljipMode: Boolean;

  boolGP2Livery: Boolean;

  boolGP2Jam: Boolean;
  boolGP3Jam: Boolean;
  boolHWJAM: Boolean;

  boolBrowsePal: Boolean;

  booljamLoaded: Boolean;

  boolJamIssues: Boolean;

  boolUndo: Boolean;

  generatePal: Boolean;

  boolJamModified: Boolean;

  intJamZoom: double;

  // DPI-aware scaling.  dblDPIFactor is set once at startup from the monitor's
  // logical DPI (Screen.PixelsPerInch / 96).  EffectiveJamZoom() combines it
  // with the user-controlled intJamZoom whenever boolDPIScaling is enabled.
  boolDPIScaling: Boolean;
  dblDPIFactor: Double;

  boolDrawOutlines: Boolean;
  boolMoveToolActive: Boolean;
  boolSnapEnabled: Boolean;
  boolShowCheckerboard: Boolean;
  boolShowAdvancedFlags: Boolean;
  // If >= 0, DrawFullJam / DrawOutlines skips this entry index. Used by
  // the move tool to capture a "pristine" background without the moving
  // texture so its new position can be composited cleanly.
  intDragSkipEntry: Integer = -1;

  intSelectedTexture: Integer;
  boolTexSelected: Boolean;

  intSimplifyThreshold: Integer;
  intSimplifyDist: Integer;
  intBlurThreshold: Integer;

  intUntitledCount: Integer;

  boolSimpifyAllPals: Boolean;
  boolProtectTrans: Boolean;

  intSimplifyMethod: Integer;

  intPaletteID: Integer;

  boolRCRDrawMode: Boolean;

  strImportPath: string;
  strExportPath: string;
  strOpenPath: string;
  strSavePath: string;

  strGP2Location: string;
  strGP3Location: string;
  strGP32kLocation: string;

  strBrowserPath: string;

  intMaxMRU: Integer;

  intMaxUndo: Integer;

  jamType: TJamType;

function CheckIfRCR(const S: string): Integer;
function CreateTransparencyMatte(const Bmp: TBitmap): TBitmap;
function DetectTransCol(Bmp: TBitmap): Boolean;
function ReplaceTransparentColour(const Bmp: TBitmap;
  const ReplacementColor: TColor): TBitmap;

function DrawTextureOutlines(jamCanvas: TBitmap; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; i: Integer; JamID: Integer;
  isOffCanvas: Boolean = False): TBitmap;

// Returns intJamZoom multiplied by the monitor DPI factor when DPI scaling
// is active, otherwise returns intJamZoom unchanged.
function EffectiveJamZoom: Double;

function UnPackRGB565(raw: Word): TColor;
function PackRGB565(Color: TColor): Word;

function isHWJAM(const Filename: string): Boolean;

function UnPackFlag(data: Word; flagNum: Integer): Boolean overload;

function PackFlag(data: Word; flagNum: Integer): Word;

function ToggleGP3JamsFolder(const APath: string): string;

function DeinterlaceRCR(const Source: TBitmap; ReadOdd: Boolean;
  JamHeight: Integer): TBitmap;

function RectsOverlap(const A, B: TJamRect): Boolean;

function DetectRectsOverlap(const Rects: TArray<TJamRect>): Boolean;

function PackRects(var Rects: TArray<TJamRect>; CanvasWidth: Integer;
  CanvasHeight: Integer): Integer;

implementation

//uses MainForm;

function EffectiveJamZoom: Double;
begin
  if boolDPIScaling and (dblDPIFactor > 0) then
    Result := intJamZoom * dblDPIFactor
  else
    Result := intJamZoom;
end;

function DrawTextureOutlines(jamCanvas: TBitmap; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; i: Integer; JamID: Integer;
  isOffCanvas: Boolean = False): TBitmap;
const
  HANDLE = 3; // half-size: 7x7 constant-pixel handle squares
  PS_BLUE = TColor($D77800); // BGR = RGB(0,120,215) — Windows accent blue
var
  textW, textH: Integer;
  idText: string;
  rectX, rectY: Integer;
  textRect: TRect;
  w, h, j, k: Integer;
  drawColour: TColor;
  selectColour: TColor;
  isSelected: Boolean;

  procedure DrawHandle(hx, hy: Integer);
  begin
    jamCanvas.Canvas.Brush.Color := clWhite;
    jamCanvas.Canvas.Brush.Style := bsSolid;
    jamCanvas.Canvas.Pen.Color := PS_BLUE;
    jamCanvas.Canvas.Pen.Style := psSolid;
    jamCanvas.Canvas.Pen.Width := 1;
    jamCanvas.Canvas.Rectangle(hx - HANDLE, hy - HANDLE,
      hx + HANDLE + 1, hy + HANDLE + 1);
  end;

begin
  if not boolDrawOutlines then
    exit(jamCanvas);

  if boolRcrJam then
  begin
    X := X div 2;
    Width := Width div 2;
  end;

  // Is this entry the currently selected one?
  isSelected := False;
  for j in SelectedTextureList do
    if j = i then
    begin
      isSelected := True;
      Break;
    end;

  jamCanvas.Canvas.lock;
  try
    w := round(Width * EffectiveJamZoom);
    h := round(Height * EffectiveJamZoom);
    Y := round(Y * EffectiveJamZoom);
    X := round(X * EffectiveJamZoom);

    // Move tool active + selected texture -> Photoshop-style handles
    if boolMoveToolActive and isSelected then
    begin
      jamCanvas.Canvas.Brush.Style := bsClear;
      // Dashed when the texture has wandered into the off-canvas margin —
      // makes "this is outside the JAM bounds" instantly readable.
      if isOffCanvas then
        jamCanvas.Canvas.Pen.Style := psDash
      else
        jamCanvas.Canvas.Pen.Style := psSolid;
      jamCanvas.Canvas.Pen.Width := 1;
      jamCanvas.Canvas.Pen.Color := PS_BLUE;
      jamCanvas.Canvas.Rectangle(X, Y, X + w, Y + h);

      // 8 handles: 4 corners + 4 edge midpoints
      DrawHandle(X,         Y);              // top-left
      DrawHandle(X + w div 2, Y);            // top-mid
      DrawHandle(X + w,     Y);              // top-right
      DrawHandle(X + w,     Y + h div 2);    // right-mid
      DrawHandle(X + w,     Y + h);          // bottom-right
      DrawHandle(X + w div 2, Y + h);        // bottom-mid
      DrawHandle(X,         Y + h);          // bottom-left
      DrawHandle(X,         Y + h div 2);    // left-mid

      // No JamID label in move mode
      Exit(jamCanvas);
    end;

    // Standard outline path (unchanged behaviour)
    drawColour := clInactiveBorder;
    selectColour := clHighlight;

    if boolJamIssues then
    begin
      for k := 0 to IntersectList.Count - 1 do
        if IntersectList[k].JamID = JamID then
        begin
          drawColour := clRed;
          selectColour := clYellow;
        end;
    end;

    if isOffCanvas then
      jamCanvas.Canvas.Pen.Style := psDash
    else
      jamCanvas.Canvas.Pen.Style := psSolid;
    jamCanvas.Canvas.Pen.Width := 1;
    jamCanvas.Canvas.Brush.Style := bsClear;

    if isSelected then
      jamCanvas.Canvas.Pen.Color := selectColour
    else
      jamCanvas.Canvas.Pen.Color := drawColour;

    jamCanvas.Canvas.Rectangle(X, Y, X + w, Y + h);

    // Force solid for the JamID label rect — looks wrong with a dashed
    // border around the small text box.
    jamCanvas.Canvas.Pen.Style := psSolid;

    jamCanvas.Canvas.font.IsScreenFont := True;
    jamCanvas.Canvas.font.size := min(12, Max(5, round(5 * EffectiveJamZoom)));
    jamCanvas.Canvas.font.Quality := fqClearTypeNatural;
    jamCanvas.Canvas.font.name := 'Segoe UI';

    // Draw texture ID at top-left
    idText := 'Jam ID: ' + JamID.ToString;

    textW := jamCanvas.Canvas.TextWidth(idText) + 10;
    textH := jamCanvas.Canvas.TextHeight(idText) + 2;

    rectX := X;
    rectY := Y;
    textRect := Rect(rectX, rectY, rectX + textW, rectY + textH);

    jamCanvas.Canvas.Brush.Style := bsSolid;
    if isSelected then
      jamCanvas.Canvas.Brush.Color := selectColour
    else
      jamCanvas.Canvas.Brush.Color := drawColour;

    jamCanvas.Canvas.Pen.Color := clBlack;
    jamCanvas.Canvas.Rectangle(textRect);

    jamCanvas.Canvas.font.Color := clBlack;
    jamCanvas.Canvas.Brush.Style := bsClear;
    jamCanvas.Canvas.TextOut(rectX + 6, rectY + 1, idText);
  finally
    jamCanvas.Canvas.Unlock;
  end;

  Result := jamCanvas;
end;

function CreateTransparencyMatte(const Bmp: TBitmap): TBitmap;
var
  X, Y: Integer;
  srcLine: PRGBTriple;
  dstLine: PRGBTriple;
  Matte: TBitmap;
  c: TColor;
begin
  Matte := TBitmap.Create;
  Matte.PixelFormat := pf24bit;
  Matte.SetSize(Bmp.Width, Bmp.Height);

  Bmp.PixelFormat := pf24bit;

  for Y := 0 to Bmp.Height - 1 do
  begin
    srcLine := Bmp.ScanLine[Y];
    dstLine := Matte.ScanLine[Y];
    for X := 0 to Bmp.Width - 1 do
    begin
      c := RGB(srcLine^.rgbtRed, srcLine^.rgbtGreen, srcLine^.rgbtBlue);
      if (c = TransparentColors[0]) or (c = TransparentColors[1]) or
        (c = TransparentColors[2]) then
      begin
        dstLine^.rgbtRed := 255;
        dstLine^.rgbtGreen := 255;
        dstLine^.rgbtBlue := 255;
      end
      else
      begin
        dstLine^.rgbtRed := 0;
        dstLine^.rgbtGreen := 0;
        dstLine^.rgbtBlue := 0;
      end;
      Inc(srcLine);
      Inc(dstLine);
    end;
  end;

  Result := Matte;
end;

function DetectTransCol(Bmp: TBitmap): Boolean;
var
  X, Y, i: Integer;
  px: PRGBTriple;
  MatchCounts: array [0 .. 2] of Integer;
  c: TColor;
begin
  Result := False;

  FillChar(MatchCounts, SizeOf(MatchCounts), 0);

  Bmp.PixelFormat := pf24bit;

  for Y := 0 to Bmp.Height - 1 do
  begin
    px := Bmp.ScanLine[Y];
    for X := 0 to Bmp.Width - 1 do
    begin
      c := RGB(px^.rgbtRed, px^.rgbtGreen, px^.rgbtBlue);

      for i := 0 to High(TransparentColors) do
      begin
        if c = TransparentColors[i] then
        begin
          Inc(MatchCounts[i]);
          if MatchCounts[i] = 4 then
          begin
            Result := True;
            exit;
          end;
          Break;
        end;
      end;
      Inc(px);
    end;
  end;
end;

function ReplaceTransparentColour(const Bmp: TBitmap;
  const ReplacementColor: TColor): TBitmap;
var
  X, Y, i: Integer;
  pxSrc, pxDst: PRGBTriple;
  c: TColor;
  R, G, B: byte;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(Bmp.Width, Bmp.Height);

  Bmp.PixelFormat := pf24bit;

  R := GetRValue(ReplacementColor);
  G := GetGValue(ReplacementColor);
  B := GetBValue(ReplacementColor);

  for Y := 0 to Bmp.Height - 1 do
  begin
    pxSrc := Bmp.ScanLine[Y];
    pxDst := Result.ScanLine[Y];

    for X := 0 to Bmp.Width - 1 do
    begin
      c := RGB(pxSrc^.rgbtRed, pxSrc^.rgbtGreen, pxSrc^.rgbtBlue);

      for i := 0 to High(TransparentColors) do
      begin
        if c = TransparentColors[i] then
        begin

          // Skip replacement if color is the same as ReplacementColor
          if TransparentColors[i] = ReplacementColor then
            pxDst^ := pxSrc^ // leave pixel unchanged
          else
          begin
            pxDst^.rgbtRed := R;
            pxDst^.rgbtGreen := G;
            pxDst^.rgbtBlue := B;
          end;

          Break; // exit inner loop
        end;

        // No match after last color, copy original pixel
        if i = High(TransparentColors) then
          pxDst^ := pxSrc^;
      end;
      Inc(pxSrc);
      Inc(pxDst);
    end;
  end;
end;

function CheckIfRCR(const S: string): Integer;
var
  i: Integer;
  Filename: string;
begin
  Filename := lowercase(ChangeFileExt(ExtractFileName(S), ''));
  Result := 0;
  boolRcrJam := False;
  for i := Low(rcrJAMList) to High(rcrJAMList) do
  begin
    if Filename = lowercase(rcrJAMList[i]) then
    begin
      Result := 1;
      boolRcrJam := True;
      exit;
    end;
  end;
end;

function PackRGB565(Color: TColor): Word;
begin
  Result := (GetBValue(Color) shr 3) or ((GetGValue(Color) shr 2) shl 5) or
    ((GetRValue(Color) shr 3) shl 11);
end;

function UnPackRGB565(raw: Word): TColor;
begin

  Result := RGB(byte((raw shr 11) shl 3), byte(((raw and $7E0) shr 5) shl 2),
    byte((raw and $1F) shl 3));

end;

function isHWJAM(const Filename: string): Boolean;
var
  fs: TFileStream;
  magic: Cardinal;
begin
  Result := False; // default assumption

  if not TFile.Exists(Filename) then
    exit;

  try
    fs := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
    try
      if fs.size >= SizeOf(magic) then
      begin
        fs.ReadBuffer(magic, SizeOf(magic));
        Result := (magic = JAM_HW_MAGIC);
      end;
    finally
      fs.Free;
    end;
  except
    // Optional: swallow exceptions, or log
    Result := False;
  end;
end;

function UnPackFlag(data: Word; flagNum: Integer): Boolean;
begin
  Result := (data and (1 shl flagNum)) <> 0;
end;

function PackFlag(data: Word; flagNum: Integer): Word;
begin
  Result := data or (1 shl flagNum);
end;

function ToggleGP3JamsFolder(const APath: string): string;
const
  Old1 = 'GP3JAMSH';
  Old2 = 'GP3JAMS';
begin
  // first look for the longer “H” variant
  if ContainsText(APath, Old1) then
    Result := StringReplace(APath, Old1, Old2, [rfReplaceAll, rfIgnoreCase])
    // else, if it has the non‑H variant, add the H
  else if ContainsText(APath, Old2) then
    Result := StringReplace(APath, Old2, Old1, [rfReplaceAll, rfIgnoreCase])
  else
    Result := APath;
end;

function DeinterlaceRCR(const Source: TBitmap; ReadOdd: Boolean;
  JamHeight: Integer): TBitmap;
var
  StartX, Y, SrcX, DstX: Integer;
  srcLine, dstLine: PByteArray;
begin
  if not Assigned(Source) then
    raise Exception.Create('DeinterlaceRCR: Source bitmap is nil');

  // Ensure source is 8‑bit
  if Source.PixelFormat <> pf8bit then
    Source.PixelFormat := pf8bit;

  // Decide start column (0 for even, 1 for odd)
  if ReadOdd then
    StartX := 1
  else
    StartX := 0;

  // Create result bitmap. The result holds half the source's columns
  // (every other pixel was dropped), so allocate at half-width to match
  // the actual content. Existing callers that drew onto a 256-wide canvas
  // were already clipping the uninitialised right half implicitly; sizing
  // correctly here removes the garbage region.
  Result := TBitmap.Create;
  Result.PixelFormat := pf8bit;
  Result.Width := Source.Width div 2;
  Result.Height := JamHeight;

  // Copy palette so the byte values map the same colours
  Result.Palette := CopyPalette(Source.Palette);

  // Copy each scanline, picking every 2nd byte
  for Y := 0 to Source.Height - 1 do
  begin
    srcLine := Source.ScanLine[Y];
    dstLine := Result.ScanLine[Y];
    DstX := 0;
    SrcX := StartX;
    while SrcX < Source.Width do
    begin
      dstLine[DstX] := srcLine[SrcX];
      Inc(DstX);
      Inc(SrcX, 2);
    end;
  end;
end;

function RectsOverlap(const A, B: TJamRect): Boolean;
begin
  Result := not((A.X + A.Width <= B.X) or (A.X >= B.X + B.Width) or
    (A.Y + A.Height <= B.Y) or (A.Y >= B.Y + B.Height));
end;

function DetectRectsOverlap(const Rects: TArray<TJamRect>): Boolean;
var
  i, j: Integer;

  intersectItem: TJamRectIntersects;

begin

  Result := False;

  if Assigned(IntersectList) then
    IntersectList.Clear
  else
    IntersectList := TList<TJamRectIntersects>.Create;

  for i := 0 to High(Rects) do
    for j := i + 1 to High(Rects) do
      if RectsOverlap(Rects[i], Rects[j]) then
      begin
        Result := True;
        intersectItem.JamID := Rects[i].JamID;
        intersectItem.intersectID := Rects[j].JamID;
        IntersectList.add(intersectItem);
      end;

end;

function PackRects(var Rects: TArray<TJamRect>; CanvasWidth: Integer;
  CanvasHeight: Integer): Integer;
var
  Rows: TList<TRow>;
  Gaps: TList<TGap>;
  i, j: Integer;
  Row: TRow;
  Gap, NewGap: TGap;
  BestRow, BestGap: Integer;
  Score, BestScore: Integer;
  Placed: Boolean;
  RemainingWidth: Integer;
begin
  // Sort by height DESC, width DESC
  TArray.Sort<TJamRect>(Rects, TComparer<TJamRect>.Construct(
    function(const A, B: TJamRect): Integer
    begin
      if B.Height <> A.Height then
        exit(B.Height - A.Height);
      Result := B.Width - A.Width;
    end));

  Rows := TList<TRow>.Create;
  Gaps := TList<TGap>.Create;
  try
    for i := 0 to High(Rects) do
    begin
      Placed := False;

      // =====================================================
      // 1. GAP FIT (best fit)
      // =====================================================
      BestGap := -1;
      BestScore := MaxInt;

      for j := 0 to Gaps.Count - 1 do
      begin
        Gap := Gaps[j];

        if (Rects[i].Width <= Gap.Width) and (Rects[i].Height <= Gap.Height)
        then
        begin
          Score := min(Gap.Width - Rects[i].Width,
            Gap.Height - Rects[i].Height);

          if Score < BestScore then
          begin
            BestScore := Score;
            BestGap := j;
          end;
        end;
      end;

      if BestGap <> -1 then
      begin
        Gap := Gaps[BestGap];

        Rects[i].X := Gap.X;
        Rects[i].Y := Gap.Y;

        // Split gap (right)
        if Gap.Width > Rects[i].Width then
        begin
          NewGap.X := Gap.X + Rects[i].Width;
          NewGap.Y := Gap.Y;
          NewGap.Width := Gap.Width - Rects[i].Width;
          NewGap.Height := Rects[i].Height;
          Gaps.add(NewGap);
        end;

        // Split gap (bottom)
        if Gap.Height > Rects[i].Height then
        begin
          NewGap.X := Gap.X;
          NewGap.Y := Gap.Y + Rects[i].Height;
          NewGap.Width := Gap.Width;
          NewGap.Height := Gap.Height - Rects[i].Height;
          Gaps.add(NewGap);
        end;

        Gaps.Delete(BestGap);
        Continue;
      end;

      // =====================================================
      // 2. BEST ROW FIT
      // =====================================================
      BestRow := -1;
      BestScore := MaxInt;

      for j := 0 to Rows.Count - 1 do
      begin
        Row := Rows[j];

        if (Rects[i].Height <= Row.Height) and
          (Row.UsedWidth + Rects[i].Width <= CanvasWidth) then
        begin
          Score := Row.Height - Rects[i].Height;

          if Score < BestScore then
          begin
            BestScore := Score;
            BestRow := j;
          end;
        end;
      end;

      if BestRow <> -1 then
      begin
        Row := Rows[BestRow];

        Rects[i].X := Row.UsedWidth;
        Rects[i].Y := Row.Y;

        // Create vertical gap
        if Rects[i].Height < Row.Height then
        begin
          NewGap.X := Row.UsedWidth;
          NewGap.Y := Row.Y + Rects[i].Height;
          NewGap.Width := Rects[i].Width;
          NewGap.Height := Row.Height - Rects[i].Height;
          Gaps.add(NewGap);
        end;

        Row.UsedWidth := Row.UsedWidth + Rects[i].Width;
        Rows[BestRow] := Row;

        Continue;
      end;

      // =====================================================
      // 3. ANY ROW WIDTH
      // =====================================================
      for j := 0 to Rows.Count - 1 do
      begin
        Row := Rows[j];
        RemainingWidth := CanvasWidth - Row.UsedWidth;

        if (Rects[i].Width <= RemainingWidth) and (Rects[i].Height <= Row.Height)
        then
        begin
          Rects[i].X := Row.UsedWidth;
          Rects[i].Y := Row.Y;

          if Rects[i].Height < Row.Height then
          begin
            NewGap.X := Row.UsedWidth;
            NewGap.Y := Row.Y + Rects[i].Height;
            NewGap.Width := Rects[i].Width;
            NewGap.Height := Row.Height - Rects[i].Height;
            Gaps.add(NewGap);
          end;

          Row.UsedWidth := Row.UsedWidth + Rects[i].Width;
          Rows[j] := Row;

          Placed := True;
          Break;
        end;
      end;

      if Placed then
        Continue;

      // =====================================================
      // 4. NEW ROW
      // =====================================================
      Row.Y := 0;
      if Rows.Count > 0 then
        Row.Y := Rows.Last.Y + Rows.Last.Height;

      Row.Height := Rects[i].Height;
      Row.UsedWidth := Rects[i].Width;

      Rects[i].X := 0;
      Rects[i].Y := Row.Y;

      Rows.add(Row);
    end;

    // =====================================================
    // Final height
    // =====================================================
    Result := 0;
    for i := 0 to Rows.Count - 1 do
      Result := Max(Result, Rows[i].Y + Rows[i].Height);

  finally
    Rows.Free;
    Gaps.Free;
  end;
end;

end.
