unit GeneralHelpers;

interface

uses
  Winapi.Windows, System.SysUtils,
  System.Classes, Vcl.Graphics, ShlWapi,
  System.IOUtils, Math;

function ClampInt(const Value, MinValue, MaxValue: Integer): Integer;

function ColorDist2(const A, B: TRGBTriple): Double;

function StretchF(const BMP: TBitmap; OutWidth, OutHeight: Integer): TBitmap;

function ResizeBilinear(const Src: TBitmap; NewW, NewH: Integer): TBitmap;

function BoolToInt(B: Boolean): Integer;

function IntToBol(i: Integer): Boolean;

function IsPowerOfTwo(Value: Integer): Boolean;

function WinShortPath(const APath: string; MaxLen: UINT): string;

procedure CheckPath(const AFileName: string);

function FormatFileSize(Bytes: Int64): string;

implementation

function IsPowerOfTwo(Value: Integer): Boolean;
begin
  Result := (Value > 0) and ((Value and (Value - 1)) = 0);
end;

function ClampInt(const Value, MinValue, MaxValue: Integer): Integer;
begin
  if Value < MinValue then
    Result := MinValue
  else if Value > MaxValue then
    Result := MaxValue
  else
    Result := Value;
end;

function ColorDist2(const A, B: TRGBTriple): Double;
begin
  Result := Sqr(A.rgbtRed - B.rgbtRed) + Sqr(A.rgbtGreen - B.rgbtGreen) +
    Sqr(A.rgbtBlue - B.rgbtBlue);
end;


type
  TRGBTripleArray = array[0..0] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;


{$R-}

function ResizeBilinear(const Src: TBitmap; NewW, NewH: Integer): TBitmap;
var
  x, y: Integer;
  gx, gy: Single;
  gxi, gyi: Integer;
  tx, ty: Single;

  c00, c10, c01, c11: TRGBTriple;
  r, g, b: Single;

  SrcLine0, SrcLine1: PRGBTripleArray;
  DstLine: PRGBTripleArray;

  xRatio, yRatio: Single;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.Width := NewW;
  Result.Height := NewH;

  // Ensure source format
  Src.PixelFormat := pf24bit;

  xRatio := (Src.Width - 1) / NewW;
  yRatio := (Src.Height - 1) / NewH;

  for y := 0 to NewH - 1 do
  begin
    gy := y * yRatio;
    gyi := Trunc(gy);
    ty := gy - gyi;

    SrcLine0 := Src.ScanLine[gyi];
    SrcLine1 := Src.ScanLine[Min(gyi + 1, Src.Height - 1)];
    DstLine := Result.ScanLine[y];

    for x := 0 to NewW - 1 do
    begin
      gx := x * xRatio;
      gxi := Trunc(gx);
      tx := gx - gxi;

      // Fetch 4 surrounding pixels
      c00 := SrcLine0[gxi];
      c10 := SrcLine0[Min(gxi + 1, Src.Width - 1)];
      c01 := SrcLine1[gxi];
      c11 := SrcLine1[Min(gxi + 1, Src.Width - 1)];

      // Bilinear interpolation
      b :=
        c00.rgbtBlue * (1 - tx) * (1 - ty) +
        c10.rgbtBlue * tx * (1 - ty) +
        c01.rgbtBlue * (1 - tx) * ty +
        c11.rgbtBlue * tx * ty;

      g :=
        c00.rgbtGreen * (1 - tx) * (1 - ty) +
        c10.rgbtGreen * tx * (1 - ty) +
        c01.rgbtGreen * (1 - tx) * ty +
        c11.rgbtGreen * tx * ty;

      r :=
        c00.rgbtRed * (1 - tx) * (1 - ty) +
        c10.rgbtRed * tx * (1 - ty) +
        c01.rgbtRed * (1 - tx) * ty +
        c11.rgbtRed * tx * ty;

      DstLine[x].rgbtBlue := Round(b);
      DstLine[x].rgbtGreen := Round(g);
      DstLine[x].rgbtRed := Round(r);
    end;
  end;
end;
{$R+}
function StretchF(const BMP: TBitmap; OutWidth, OutHeight: Integer): TBitmap;
var
  DestRect: TRect;
begin
  Result := TBitmap.Create;
  try
    // If source and destination sizes are identical, just copy
    if (BMP.Width = OutWidth) and (BMP.Height = OutHeight) then
    begin
      Result.Assign(BMP);
      Exit;
    end;

    // always produce 24-bit output
    Result.PixelFormat := pf24bit;
    Result.SetSize(OutWidth, OutHeight);

    DestRect := Rect(0, 0, OutWidth, OutHeight);

    if (BMP.Width < 16) or (BMP.Height < 16) then
    begin
      // simple Delphi StretchDraw for small source bitmaps
      Result.Canvas.StretchDraw(DestRect, BMP);
    end
    else
    begin
      // higher-quality halftone stretch for larger bitmaps
      SetStretchBltMode(Result.Canvas.Handle, HALFTONE);
      SetBrushOrgEx(Result.Canvas.Handle, 0, 0, nil);
      StretchBlt(Result.Canvas.Handle, DestRect.Left, DestRect.Top,
        DestRect.Width, DestRect.Height, BMP.Canvas.Handle, 0, 0, BMP.Width,
        BMP.Height, SRCCOPY);
    end;

  except
    FreeAndNil(Result);
    raise;
  end;
end;

function BoolToInt(B: Boolean): Integer;
begin
  if B then
    Result := 1
  else
    Result := 0;
end;

function IntToBol(i: Integer): Boolean;
begin
  if i = 1 then
    Result := true
  else
    Result := false;
end;

function WinShortPath(const APath: string; MaxLen: UINT): string;
var
  buf: array [0 .. MAX_PATH] of Char;
begin
  if PathCompactPathEx(buf, PChar(APath), MaxLen, 0) then
    Result := buf
  else
    Result := APath;
end;

procedure CheckPath(const AFileName: string);
var
  Dir: string;
begin
  // Get just the directory portion of the full filename
  Dir := TPath.GetDirectoryName(AFileName);
  if (Dir <> '') and not TDirectory.Exists(Dir) then
    TDirectory.CreateDirectory(Dir);
end;

function FormatFileSize(Bytes: Int64): string;
begin
  if Bytes < 1024 then
    Result := Format('%d B', [Bytes])
  else if Bytes < 1024 * 1024 then
    Result := Format('%.1f KB', [Bytes / 1024])
  else
    Result := Format('%.2f MB', [Bytes / (1024 * 1024)]);
end;

end.
