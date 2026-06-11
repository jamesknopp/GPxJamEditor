unit JamHW;

interface

uses
  // System
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  // Windows/VCL
  Winapi.Windows, Vcl.Graphics, Vcl.dialogs,
  // Project
  GeneralHelpers, JamGeneral, JamPalette, jampalettedetector;

type

  THWJamTempDimensions = record
    x: integer;
    y: integer;
    height: integer;
    width: integer;
  end;

  THWJamHeaderArray = array of THWJamEntryInfo;

  THWJamEntry = class
  public
    FInfo: THWJamEntryInfo;
    // FRawInfo: THWRawJamEntryInfo;
    FTexture: TBitmap;
    FOriginalTex: TBitmap;
    boolImportedBMP: boolean;
    tempDimensions: THWJamTempDimensions;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    function Clone: THWJamEntry;

    constructor Create(const Info: THWJamEntryInfo); overload;
    destructor Destroy; override;
    // in the class declaration:
    property Info: THWJamEntryInfo read FInfo write FInfo;
  end;

  THWJamFile = class
  private

  public
    FHeader: THWJamHeader;
    FEntries: TList<THWJamEntry>;

    canvasHeight, canvasWidth: integer;
    CanvasBitmap: TBitmap;
    JamFileName: string;
    JamFullPath: string;

    constructor Create;
    destructor Destroy; override;

    function Clone: THWJamFile;

    function AddTexture(bmp: TBitmap; newinfo: TJamEntryInfo): integer overload;
    procedure AddTexture(textureFilename: string)overload;

    function LoadFromFile(const FileName: string): boolean;
    procedure SaveToFile(const FileName: string);

    procedure CreateNewHWJam(FileName: string; height: integer);

    procedure DeleteTexture(JamId: integer);

    function GetNextJamID(JamEntries: TList<THWJamEntry>): Word;

    procedure ImportCanvas(FileName: string);

    procedure ImportTexture(JamId: integer; textureFilename: string);
    procedure ExportTexture(JamId: integer; textureFilename: string);

    procedure PackHWJAMHeader(const Hdr: THWJamEntryInfo; Dest: PWord);
    procedure ParseHWJAMHeader(const Src: PWord; out Hdr: THWJamEntryInfo);

    procedure WriteRLE(const Data: TArray<Word>; Stream: TStream);

    function DrawCanvas(uiUpdate: boolean): TBitmap;
    function DrawSingleTexture(JamId: integer): TBitmap;

    procedure BuildRect_HW(Jam: THWJamFile; var Rects: TArray<TJamRect>);

    procedure ApplyRects_HW(Jam: THWJamFile; const Rects: TArray<TJamRect>);

    procedure ChangeJamCanvasHeight(height: integer);

    property Entries: TList<THWJamEntry> read FEntries write FEntries;

  end;

implementation

constructor THWJamEntry.Create(const Info: THWJamEntryInfo);
begin
  FInfo := Info;
  FTexture := TBitmap.Create;
  FOriginalTex := TBitmap.Create;
end;

destructor THWJamEntry.Destroy;
begin

  if assigned(FOriginalTex) then
    FreeAndNil(FOriginalTex);

  if assigned(FTexture) then
    FreeAndNil(FTexture);

  inherited;
end;

function THWJamEntry.Clone: THWJamEntry;
begin
  Result := THWJamEntry.Create(Self.FInfo);

  // Copy simple values
  Result.boolImportedBMP := Self.boolImportedBMP;
  Result.tempDimensions := Self.tempDimensions;

  // Clone FTexture
  if assigned(Self.FTexture) then
  begin
    Result.FTexture := TBitmap.Create;
    Result.FTexture.Assign(Self.FTexture);
  end;

  // Clone FOriginalTex
  if assigned(Self.FOriginalTex) then
  begin
    Result.FOriginalTex := TBitmap.Create;
    Result.FOriginalTex.Assign(Self.FOriginalTex);
  end;
end;

constructor THWJamFile.Create;
begin
  FEntries := TList<THWJamEntry>.Create;
end;

destructor THWJamFile.Destroy;
var
  i: integer;
begin
  if Assigned(FEntries) then
  begin
    for i := 0 to FEntries.Count - 1 do
      FreeAndNil(FEntries[i]);
    FreeAndNil(FEntries);
  end;

  FreeAndNil(CanvasBitmap);

  inherited;
end;

procedure THWJamEntry.SaveToStream(Stream: TStream);
begin
  // Save FInfo
  Stream.WriteBuffer(FInfo, SizeOf(FInfo));

  // Save FTexture
  FTexture.SaveToStream(Stream);

  // Save FOriginalTex
  FOriginalTex.SaveToStream(Stream);

  // Save TempDimensions
  Stream.WriteBuffer(tempDimensions, SizeOf(tempDimensions));

  // Save boolImportedBMP
  Stream.WriteBuffer(boolImportedBMP, SizeOf(boolImportedBMP));
end;

procedure THWJamEntry.LoadFromStream(Stream: TStream);

begin
  // Read FInfo
  Stream.ReadBuffer(FInfo, SizeOf(FInfo));

  // Read FTexture
  FreeAndNil(FTexture);
  FTexture := TBitmap.Create;
  FTexture.LoadFromStream(Stream);

  // Read FOriginalTex
  FreeAndNil(FOriginalTex);
  FOriginalTex := TBitmap.Create;
  FOriginalTex.LoadFromStream(Stream);

  // Read TempDimensions
  Stream.ReadBuffer(tempDimensions, SizeOf(tempDimensions));

  // Read boolImportedBMP
  Stream.ReadBuffer(boolImportedBMP, SizeOf(boolImportedBMP));
end;

procedure THWJamFile.DeleteTexture(JamId: integer);
begin
  FEntries.Delete(JamId);
  Dec(FHeader.NumItems);
end;

function THWJamFile.Clone: THWJamFile;
var
  i: integer;
  Entry: THWJamEntry;
begin
  Result := THWJamFile.Create;

  // Copy basic fields
  Result.FHeader := Self.FHeader;
  Result.canvasWidth := Self.canvasWidth;
  Result.canvasHeight := Self.canvasHeight;
  Result.JamFileName := Self.JamFileName;
  Result.JamFullPath := Self.JamFullPath;

  // Clone canvas bitmap
  if assigned(Self.CanvasBitmap) then
  begin
    Result.CanvasBitmap := TBitmap.Create;
    Result.CanvasBitmap.Assign(Self.CanvasBitmap);
  end;

  // Deep copy entries
  for i := 0 to FEntries.Count - 1 do
  begin
    Entry := FEntries[i].Clone; // requires THWJamEntry.Clone
    Result.FEntries.Add(Entry);
  end;
end;

procedure THWJamFile.ParseHWJAMHeader(const Src: PWord;
  out Hdr: THWJamEntryInfo);
type
  PWordArray = ^TWordArray;
  TWordArray = array [0 .. MaxInt div SizeOf(Word) - 1] of Word;
var
  A: PWordArray;
  i: integer;
begin
  A := PWordArray(Src);
  // reconstruct PosRaw
  Hdr.PosRaw := integer(A^[0]) or (integer(A^[1]) shl 16);
  // decode X,Y
  Hdr.x := (Hdr.PosRaw and $1FF) div 2;
  Hdr.y := Hdr.PosRaw div 512;
  // direct fields
  Hdr.width := A^[2];
  Hdr.height := A^[3];
  Hdr.JamId := A^[9];
  Hdr.word6 := A^[6];
  // derived
  Hdr.NumFrames := 1 shl Hdr.word6;
  Hdr.jamFlags := A^[10];
  // unpack flags
  for i := 0 to 15 do
    Hdr.FrameFlags[i] := (Hdr.jamFlags and (1 shl i)) <> 0;
end;

function THWJamFile.GetNextJamID(JamEntries: TList<THWJamEntry>): Word;
var
  i: integer;
  MaxID: Word;
begin
  MaxID := 0;
  for i := 0 to JamEntries.Count - 1 do
  begin
    if JamEntries[i].FInfo.JamId > MaxID then
      MaxID := JamEntries[i].FInfo.JamId;
  end;

  if MaxID < High(Word) then
    Result := MaxID + 1
  else
    raise Exception.Create('Maximum JamID value (65535) exceeded');
end;

procedure THWJamFile.PackHWJAMHeader(const Hdr: THWJamEntryInfo; Dest: PWord);
var
  RawPos: integer;
  A: array [0 .. 15] of Word;
  j: integer;
begin
  // Reconstruct PosRaw from X and Y
  // X = (PosRaw and $1FF) div 2  => PosRaw low 9 bits = X*2
  // Y = PosRaw div 512
  RawPos := (Hdr.y * 512) + (Hdr.x * 2);

  A[0] := Word(RawPos and $FFFF); // low word
  A[1] := Word((RawPos shr 16) and $FFFF); // high word
  A[2] := Hdr.width;
  A[3] := Hdr.height;
  A[4] := (Word(Hdr.scaleY) shl 8) or Hdr.scaleX;
  A[5] := (Word(Hdr.scaleFactor) shl 8) or Hdr.scaleFlags;
  A[6] := Hdr.word6;
  A[7] := 0;
  A[8] := 0;
  A[9] := Hdr.JamId;
  A[10] := Hdr.jamFlags;
  for j := 11 to 15 do
    A[j] := 0;
  Move(A, Dest^, SizeOf(A));
end;

function THWJamFile.LoadFromFile(const FileName: string): boolean;
type
  PWordArray = ^TWordArray;
  TWordArray = array [0 .. MaxInt div SizeOf(Word) - 1] of Word;
var
  A: PWordArray;
  fs: TFileStream;
  magic: Cardinal;
  i, j, totalWords, dst, row, col: integer;
  ctrl: Byte;
  w: Word;
  raw: TArray<Word>;
  Info: THWJamEntryInfo;
  sFilename: string;
  ScanPtr: PRGBTriple;
  c: Word;
begin
  sFilename := lowercase(ChangeFileExt(ExtractFileName(FileName), ''));

  JamFileName := sFilename;

  Result := false;

  for i := 0 to FEntries.Count - 1 do
    FEntries[i].free;
  FEntries.Clear;

  // Initial state

  intjamMaxWidth := 0;
  intJamMaxHeight := 0;

  // Read & decrypt all file bytes
  if not FileExists(FileName) then
    Exit;
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

  try
    fs.ReadBuffer(magic, SizeOf(magic));
    if magic <> JAM_HW_MAGIC then
      Exit;

    fs.ReadBuffer(FHeader.NumItems, SizeOf(Word));
    fs.ReadBuffer(FHeader.JamTotalHeight, SizeOf(Word));

    totalWords := (FHeader.NumItems shl 4) + (FHeader.JamTotalHeight shl 8);
    SetLength(raw, totalWords);
    dst := 0;
    while dst < totalWords do
    begin
      fs.ReadBuffer(ctrl, 1);
      if (ctrl and $80) <> 0 then
      begin
        ctrl := ctrl and $7F;
        fs.ReadBuffer(raw[dst], ctrl * SizeOf(Word));
        Inc(dst, ctrl);
      end
      else if ctrl > 0 then
      begin
        fs.ReadBuffer(w, SizeOf(w));
        for i := 1 to ctrl do
        begin
          raw[dst] := w;
          Inc(dst);
        end;
      end;
    end;

    // there is always one texture - lets ensure that

    if FHeader.NumItems = 0 then
      FHeader.NumItems := 1;

    // Read entries and add them to the list
    for i := 0 to FHeader.NumItems - 1 do
    begin
      FEntries.Add(THWJamEntry.Create(Info));

      with FEntries[i] do
      begin

        A := PWordArray(@raw[i * 16]);

        FInfo.PosRaw := integer(A^[0]) or (integer(A^[1]) shl 16);
        FInfo.x := (FInfo.PosRaw and $1FF) div 2;
        FInfo.y := FInfo.PosRaw div 512;
        FInfo.width := A^[2];
        FInfo.height := A^[3];
        FInfo.JamId := A^[9];
        FInfo.scaleX := A^[4] and $00FF;
        FInfo.scaleY := (A^[4] shr 8) and $00FF;
        FInfo.scaleFactor := (A^[5] shr 8) and $00FF;
        FInfo.scaleFlags := A^[5] and $00FF;

        FInfo.word6 := A^[6];
        FInfo.word6a := A^[6] and $00FF;
        FInfo.word6b := (A^[6] shr 8) and $00FF;

        FInfo.word7 := A^[7];
        FInfo.word7a := A^[7] and $00FF;
        FInfo.word7b := (A^[7] shr 8) and $00FF;

        FInfo.word8 := A^[8];
        FInfo.word8a := A^[8] and $00FF;
        FInfo.word8b := (A^[8] shr 8) and $00FF;

        FInfo.NumFrames := 1 shl FInfo.word7;

        FInfo.jamFlags := A^[10];

        for j := 0 to 15 do
          FInfo.FrameFlags[j] := (FInfo.jamFlags and (1 shl j)) <> 0;

        FInfo.word11 := A^[11];
        FInfo.word11a := A^[11] and $00FF;
        FInfo.word11b := (A^[11] shr 8) and $00FF;

        FInfo.word12 := A^[12];
        FInfo.word12a := A^[12] and $00FF;
        FInfo.word12b := (A^[12] shr 8) and $00FF;

        FInfo.word13 := A^[13];
        FInfo.word13a := A^[13] and $00FF;
        FInfo.word13b := (A^[13] shr 8) and $00FF;

        FInfo.word14 := A^[14];
        FInfo.word14a := A^[14] and $00FF;
        FInfo.word14b := (A^[14] shr 8) and $00FF;

        FInfo.word15 := A^[15];
        FInfo.word15a := A^[15] and $00FF;
        FInfo.word15b := (A^[15] shr 8) and $00FF;

        FInfo.word16 := A^[16];
        FInfo.word16a := A^[16] and $00FF;
        FInfo.word16b := (A^[16] shr 8) and $00FF;
      end;
    end;

    intJamMaxHeight := FHeader.JamTotalHeight;

    // Write Canvas for the first time

    CanvasBitmap := TBitmap.Create;

    with CanvasBitmap do
    begin
      PixelFormat := pf24bit;
      width := 256;
      height := FHeader.JamTotalHeight;
    end;

    for row := 0 to CanvasBitmap.height - 1 do
    begin
      ScanPtr := CanvasBitmap.ScanLine[row];
      for col := 0 to CanvasBitmap.width - 1 do
      begin
        c := raw[FHeader.NumItems * 16 + row * 256 + col];

        // unpack 5/6/5 → 8/8/8
        ScanPtr^.rgbtRed := Byte((c and $F800) shr 11) * 255 div $1F;
        ScanPtr^.rgbtGreen := Byte((c and $07E0) shr 5) * 255 div $3F;
        ScanPtr^.rgbtBlue := Byte(c and $001F) * 255 div $1F;

        Inc(ScanPtr);
      end;
    end;
    for i := 0 to FHeader.NumItems - 1 do
      with FEntries[i] do
      begin

        FTexture := DrawSingleTexture(i);
        FOriginalTex.Assign(FTexture);
      end
  finally
    fs.free;
  end;

  canvasWidth := 256;
  canvasHeight := FHeader.JamTotalHeight;
  JamFullPath := FileName;
  Result := True;
end;

procedure THWJamFile.CreateNewHWJam(FileName: string; height: integer);
var
  sFilename: string;

begin

  intjamMaxWidth := 256;

  sFilename := lowercase(ChangeFileExt(ExtractFileName(FileName), ''));
  JamFullPath := FileName;

  FHeader.NumItems := 0;

  FHeader.JamTotalHeight := height;

  intJamMaxHeight := FHeader.JamTotalHeight;

  // Write Canvas for the first time

  CanvasBitmap := TBitmap.Create;
  with CanvasBitmap do
  begin
    PixelFormat := pf24bit;
    width := 256;
    height := FHeader.JamTotalHeight;
    Canvas.Brush.Color := TCol_TransGP3HW;
    Canvas.FillRect(Rect(0, 0, CanvasBitmap.width, CanvasBitmap.height));
  end;

  JamFileName := FileName;
  boolJamLoaded := True;

end;

procedure THWJamFile.WriteRLE(const Data: TArray<Word>; Stream: TStream);
var
  i, runLen: integer;
  current: Word;
  header: Byte;
begin
  i := 0;
  while i < Length(Data) do
  begin
    current := Data[i];
    // count how many times it repeats (max 127)
    runLen := 1;
    while (i + runLen < Length(Data)) and (Data[i + runLen] = current) and
      (runLen < 127) do
      Inc(runLen);
    if runLen > 1 then
    begin
      // write a repeat block (high bit clear)
      header := Byte(runLen);
      Stream.WriteBuffer(header, 1);
      Stream.WriteBuffer(current, SizeOf(current));
      Inc(i, runLen);
    end
    else
    begin
      // write a literal block (high bit set)
      runLen := 1;
      while (i + runLen < Length(Data)) and (runLen < 127) and
        ((i + runLen + 1 >= Length(Data)) or
        (Data[i + runLen] <> Data[i + runLen + 1])) do
        Inc(runLen);
      header := Byte(runLen or $80);
      Stream.WriteBuffer(header, 1);
      Stream.WriteBuffer(Data[i], runLen * SizeOf(Word));
      Inc(i, runLen);
    end;
  end;
end;

procedure THWJamFile.SaveToFile(const FileName: string);
var
  fs: TFileStream;
  hdrCount, heightVal: Word;
  raw: TArray<Word>;
  totalWords: integer;
  i, row, col, offset: integer;
  v: Cardinal;
  w: Word;
  tmpTex: TBitmap;
  ScanPtr: PRGBTriple;
begin

  hdrCount := FHeader.NumItems;
  heightVal := FHeader.JamTotalHeight;
  totalWords := (hdrCount shl 4) + (256 * heightVal);
  SetLength(raw, totalWords);

  // 1) pack each header into the first hdrCount*16 words
  for i := 0 to hdrCount - 1 do
    PackHWJAMHeader(FEntries[i].FInfo, @raw[i * 16]);

  // 2 - draw brand new canvas
  CanvasBitmap.Canvas.lock;

  for i := 0 to hdrCount - 1 do
  begin
    tmpTex := stretchF(FEntries[i].FOriginalTex, FEntries[i].FInfo.width,
      FEntries[i].FInfo.height);
    try
      CanvasBitmap.Canvas.Draw(FEntries[i].FInfo.x,
        FEntries[i].FInfo.y, tmpTex);
    finally
      tmpTex.free;
    end;

  end;

  // 3) pack pixel data into raw[hdrCount*16..] using ScanLine
  CanvasBitmap.PixelFormat := pf24bit;
  offset := hdrCount * 16;
  {$R-}
  for row := 0 to heightVal - 1 do
  begin
    ScanPtr := CanvasBitmap.ScanLine[row];
    for col := 0 to 256 - 1 do
    begin
      raw[offset] := PackRGB565(RGB(ScanPtr^.rgbtRed, ScanPtr^.rgbtGreen,
        ScanPtr^.rgbtBlue));
      Inc(ScanPtr);
      Inc(offset);
    end;
  end;
  {$R+}

  CanvasBitmap.Canvas.Unlock;
  // 3) write to disk: magic, counts, then RLE data
  fs := TFileStream.Create(FileName, fmCreate or fmShareExclusive);
  try
    v := JAM_HW_MAGIC;
    fs.WriteBuffer(v, SizeOf(v));

    w := hdrCount;
    fs.WriteBuffer(w, SizeOf(w));

    w := heightVal;
    fs.WriteBuffer(w, SizeOf(w));

    WriteRLE(raw, fs);

  finally
    fs.free;
  end;
end;

procedure THWJamFile.ImportCanvas(FileName: string);
var
  i: integer;
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.LoadFromFile(FileName);

    if (bmp.Height = canvasHeight) and (bmp.Width = canvasWidth) then
    begin
      FreeAndNil(CanvasBitmap);
      CanvasBitmap := TBitmap.Create;
      CanvasBitmap.Assign(bmp);

      for i := 0 to FHeader.NumItems - 1 do
        DrawSingleTexture(i);
    end
    else
    begin
      MessageDlg(
        Format('Bitmap file size incorrect - it should match the size of the JAM file. Bitmap is %d x %d and JAM is %d x %d',
        [bmp.Width, bmp.Height, canvasWidth, canvasHeight]),
        mtError, [mbOK], 0);
    end;
  finally
    bmp.Free;
  end;
end;

procedure THWJamFile.ImportTexture(JamId: integer; textureFilename: string);
var
  srcPic: TPicture;
  textureWidth, textureHeight: integer;
  tmpCanvas, stretched: TBitmap;
begin
  srcPic := TPicture.Create;
  tmpCanvas := TBitmap.Create;
  try
    textureWidth := FEntries[JamId].Info.width;
    textureHeight := FEntries[JamId].Info.height;

    srcPic.LoadFromFile(textureFilename);

    tmpCanvas.PixelFormat := srcPic.bitmap.PixelFormat;
    tmpCanvas.SetSize(textureWidth, textureHeight);

    stretched := stretchF(srcPic.bitmap, textureWidth, textureHeight);
    try
      tmpCanvas.Canvas.Lock;
      tmpCanvas.Canvas.StretchDraw(Rect(0, 0, textureWidth, textureHeight),
        stretched);
      tmpCanvas.Canvas.Unlock;
    finally
      stretched.Free;
    end;

    FEntries[JamId].FOriginalTex.Assign(tmpCanvas);
    FEntries[JamId].FTexture.Assign(tmpCanvas);
  finally
    tmpCanvas.Free;
    srcPic.Free;
  end;
end;

procedure THWJamFile.ExportTexture(JamId: integer; textureFilename: string);
var
  tmpCanvas: TBitmap;
begin

  tmpCanvas := FEntries[JamId].FTexture;
  tmpCanvas.SaveToFile(textureFilename);

end;

function THWJamFile.DrawCanvas(uiUpdate: boolean): TBitmap;
var
  bmpAll, entryBmp, stretchedBmp: TBitmap;
  i: integer;
begin
  // Create the master canvas
  bmpAll := TBitmap.Create;
  try
    bmpAll.Canvas.lock;
    bmpAll.PixelFormat := pf32bit;
    bmpAll.width := 256;
    bmpAll.height := FHeader.JamTotalHeight;
    bmpAll.Canvas.Brush.Color := TCol_TransGP3HW;
    bmpAll.Canvas.FillRect(Rect(0, 0, bmpAll.width, bmpAll.height));

    // Draw each entry
    for i := 0 to FEntries.Count - 1 do
    begin
      if uiUpdate then
      begin
        // Use the cached original texture, scale it, draw, then free
        entryBmp := FEntries[i].FOriginalTex;
        stretchedBmp := stretchF(entryBmp, FEntries[i].Info.width,
          FEntries[i].Info.height);
        try
          bmpAll.Canvas.Draw(FEntries[i].Info.x, FEntries[i].Info.y,
            stretchedBmp);
        finally
          stretchedBmp.free;
        end;
      end
      else
      begin
        // Generate a one‐off snapshot, draw it, then free
        entryBmp := DrawSingleTexture(i);
        try
          bmpAll.Canvas.Draw(FEntries[i].Info.x, FEntries[i].Info.y, entryBmp);
        finally
          entryBmp.free;
        end;
      end;
    end;

    bmpAll.Canvas.Unlock;
    // Success—transfer ownership of bmpAll to the caller
    Result := bmpAll;
  except
    // On any exception, free bmpAll and re‐raise
    bmpAll.free;
    raise;
  end;
end;

function THWJamFile.DrawSingleTexture(JamId: integer): TBitmap;
// Copy a rectangular region out of CanvasBitmap into a fresh TBitmap.
//
// We used to call BitBlt here, but BitBlt goes through GDI and its device
// contexts are thread-affine — calling from a worker thread returned FALSE
// with ERROR_INVALID_HANDLE. Moving to ScanLine + Move makes the copy a
// pure-memory operation: no GDI, no DCs, no cross-thread handle issues,
// and no Canvas.Lock needed. It's also a touch faster for small rects
// because there's no per-call GDI overhead.
//
// Preconditions (relied on by the caller and enforced here):
//   - CanvasBitmap is fully loaded and its DIB is allocated (first
//     ScanLine[] call materialises it). If this is called from multiple
//     threads for the first time on the same instance, see the note in
//     ConvertGPxJam about priming.
//   - Each thread creates its own dst bitmap — we never share a dst.
//   - Source and dst share a PixelFormat, so rows are byte-compatible.
var
  w, H, x, y: integer;
  dst: TBitmap;
  bytesPerPixel: integer;
  rowBytes: integer;
  srcRow, dstRow: PByte;
  row: integer;
begin
  // 1) Pull out rectangle info
  w := FEntries[JamId].FInfo.width;
  H := FEntries[JamId].FInfo.height;
  x := FEntries[JamId].FInfo.x;
  y := FEntries[JamId].FInfo.y;

  // 2) Sanity-check inputs
  if (w <= 0) or (H <= 0) then
    raise Exception.CreateFmt('Invalid texture size %dx%d for entry %d',
      [w, H, JamId]);

  if CanvasBitmap = nil then
    raise Exception.Create('DrawSingleTexture: CanvasBitmap is nil');

  // 3) Determine bytes-per-pixel from the source format. We only handle
  //    the formats the loader actually produces — anything else is a bug.
  case CanvasBitmap.PixelFormat of
    pf8bit:  bytesPerPixel := 1;
    pf15bit, pf16bit: bytesPerPixel := 2;
    pf24bit: bytesPerPixel := 3;
    pf32bit: bytesPerPixel := 4;
  else
    raise Exception.CreateFmt(
      'DrawSingleTexture: unsupported PixelFormat %d',
      [Ord(CanvasBitmap.PixelFormat)]);
  end;

  // 4) Bounds-check the rectangle against the source bitmap so we don't
  //    stray past the end of a ScanLine row.
  if (x < 0) or (y < 0)
     or (x + w > CanvasBitmap.Width)
     or (y + H > CanvasBitmap.Height) then
    raise Exception.CreateFmt(
      'DrawSingleTexture: rect (%d,%d,%dx%d) out of bounds for canvas %dx%d',
      [x, y, w, H, CanvasBitmap.Width, CanvasBitmap.Height]);

  rowBytes := w * bytesPerPixel;

  // 5) Allocate dst and copy, freeing on any error.
  dst := TBitmap.Create;
  try
    dst.PixelFormat := CanvasBitmap.PixelFormat;
    dst.SetSize(w, H);

    // Palette-indexed formats must share the colour table, otherwise the
    // pixel indices in the copied rows point into the wrong RGB entries.
    if CanvasBitmap.PixelFormat = pf8bit then
      dst.Palette := CopyPalette(CanvasBitmap.Palette);

    // Copy row-by-row. Each ScanLine call returns a pointer to that row's
    // start (bitmap stride may be padded, but the ScanLine step already
    // accounts for that, so we never need to compute padding ourselves).
    for row := 0 to H - 1 do
    begin
      srcRow := PByte(CanvasBitmap.ScanLine[y + row]);
      Inc(srcRow, x * bytesPerPixel); // seek into the source row
      dstRow := PByte(dst.ScanLine[row]);
      Move(srcRow^, dstRow^, rowBytes);
    end;

    Result := dst;
    dst := nil; // prevent the finally block from freeing the handed-off bitmap
  finally
    dst.Free;
  end;
end;

procedure THWJamFile.AddTexture(textureFilename: string);
var
  srcPic: TPicture;
  Info: THWJamEntryInfo;
  newTex: THWJamEntry;
  x: integer;

  transbool: boolean;
begin
  srcPic := TPicture.Create;

  try
    srcPic.LoadFromFile(textureFilename);
    Info.x := 0;
    Info.y := 0;
    Info.width := srcPic.width;
    Info.height := srcPic.height;
    if FEntries.Count > 0 then
      Info.JamId := FEntries[FEntries.Count - 1].Info.JamId + 1
    else
      Info.JamId := 0;

    newTex := THWJamEntry.Create(Info);
    newTex.FOriginalTex := TBitmap.Create;
    newTex.FTexture := TBitmap.Create;

    newTex.FOriginalTex.SetSize(Info.width, Info.height);
    newTex.FTexture.SetSize(Info.width, Info.height);

    transbool := DetectTransCol(srcPic.bitmap);

    srcPic.bitmap := ReplaceTransparentColour(srcPic.bitmap, TCol_TransGP3HW);

    newTex.FOriginalTex.Assign(srcPic.bitmap);
    newTex.FTexture.Assign(srcPic.bitmap);

    FEntries.Add(newTex);
    Inc(FHeader.NumItems);

    x := FEntries.Count - 1;
    intSelectedTexture := x;

    FEntries[x].FInfo.jamFlags := 0;

    if not isPowerOfTwo(FEntries[x].FTexture.width) then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 9);

    if not isPowerOfTwo(FEntries[x].FTexture.height) then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 8);

    if transbool then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 3);

  finally
    srcPic.free;

  end;
end;

function THWJamFile.AddTexture(bmp: TBitmap; newinfo: TJamEntryInfo): integer;
var
  Info: THWJamEntryInfo;
  newTex: THWJamEntry;
  x: integer;
  tmpCanvas, replaced: TBitmap;
  transbool: boolean;
begin
  tmpCanvas := TBitmap.Create;
  tmpCanvas.Assign(bmp);
  try

    Info.x := newinfo.x;
    Info.y := newinfo.y;
    Info.width := newinfo.width;
    Info.height := newinfo.height;
    Info.JamId := newinfo.JamId;
    Info.jamFlags := newinfo.jamFlags;

    newTex := THWJamEntry.Create(Info);
    newTex.FOriginalTex := TBitmap.Create;
    newTex.FTexture := TBitmap.Create;

    replaced := ReplaceTransparentColour(tmpCanvas, TCol_TransGP3HW);
    tmpCanvas.Free;
    tmpCanvas := replaced;

    tmpCanvas.PixelFormat := pf24bit;

    newTex.FOriginalTex.SetSize(Info.width, Info.height);
    newTex.FTexture.SetSize(Info.width, Info.height);

    newTex.FOriginalTex.Assign(tmpCanvas);
    newTex.FTexture.Assign(tmpCanvas);

    FEntries.Add(newTex);
    Inc(FHeader.NumItems);

    x := FEntries.Count - 1;
    intSelectedTexture := x;

    transbool := DetectTransCol(newTex.FTexture);

    if not isPowerOfTwo(FEntries[x].FTexture.width) then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 9);

    if not isPowerOfTwo(FEntries[x].FTexture.height) then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 8);

    if transbool then
      FEntries[x].FInfo.jamFlags := PackFlag(FEntries[x].FInfo.jamFlags, 3);

    Result := x;

  finally
    tmpCanvas.Free;
  end;
end;

procedure THWJamFile.BuildRect_HW(Jam: THWJamFile; var Rects: TArray<TJamRect>);
var
  i: integer;
begin
  SetLength(Rects, Jam.FHeader.NumItems);

  for i := 0 to Jam.FHeader.NumItems - 1 do
  begin
    Rects[i].x := Jam.FEntries[i].FInfo.x;
    Rects[i].y := Jam.FEntries[i].FInfo.y;
    Rects[i].width := Jam.FEntries[i].FInfo.width;
    Rects[i].height := Jam.FEntries[i].FInfo.height;
    Rects[i].JamId := Jam.FEntries[i].FInfo.JamId;
    Rects[i].size := Rects[i].x * Rects[i].y;
    Rects[i].index := i;
  end;
end;

procedure THWJamFile.ApplyRects_HW(Jam: THWJamFile;
  const Rects: TArray<TJamRect>);
var
  i: integer;
begin
  for i := 0 to High(Rects) do
  begin
    Jam.FEntries[Rects[i].index].FInfo.x := Rects[i].x;
    Jam.FEntries[Rects[i].index].FInfo.y := Rects[i].y;
  end;
end;

procedure THWJamFile.ChangeJamCanvasHeight(height: integer);
begin
  // Update header + metadata
  FHeader.JamTotalHeight := height;
  canvasHeight := height;

  CanvasBitmap.Canvas.Brush.Color := TCol_TransGP3HW;
  CanvasBitmap.height := height;

  intJamMaxHeight := height;

end;

end.
