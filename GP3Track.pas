unit GP3Track;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes, System.Generics.Collections,
  vcl.Dialogs;

type
  TGP3Track = class
  private
    FRaw: TBytes; // full file as loaded
    FJamList: TList<string>; // editable list (ANSI paths)
    FSigOffset: Integer; // offset of signature
    FUnkByte: Byte; // byte right after signature
    FJamStartOffset: Integer; // first byte after unknown byte
    FTailStart: Integer; // start of preserved tail (<= Length(FRaw))
    FHasSignature: Boolean;

    function FindLastPatternBeforeLimit(const Pattern: TBytes;
      Limit: Integer): Integer;
    function IndexOfTailMarker(const Marker: AnsiString): Integer;
    procedure DetectTailStart; // sets FTailStart (kept exactly on save)
    procedure ParseJamList(StartOfs, EndOfs: Integer);
    class function AnsiBytesToString(const Bytes: TBytes): string; static;
    class function StringToAnsiBytes(const S: string): TBytes; static;

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    // list access
    function JamCount: Integer;
    function JamItem(Index: Integer): string;
    procedure SetJamItem(Index: Integer; const Value: string);
    procedure AddJam(const Value: string);
    procedure InsertJam(Index: Integer; const Value: string);
    procedure DeleteJam(Index: Integer);
    procedure ClearJam;

    function GetJamList: TArray<string>;
    procedure SetJamList(const Items: TArray<string>);
  end;

implementation

const
  // Signature immediately before the jam list
  JamSig: array [0 .. 17] of Byte = ($FF, $FF, $00, $01, $02, $03, $09, $05,
    $06, $07, $08, $09, $0A, $02, $0C, $0D, $0E, $0F);

  { TGP3Track }

constructor TGP3Track.Create;
begin
  inherited;
  FJamList := TList<string>.Create;
  FSigOffset := -1;
  FJamStartOffset := -1;
  FTailStart := -1;
  FHasSignature := False;
end;

destructor TGP3Track.Destroy;
begin
  FJamList.Free;
  inherited;
end;

function TGP3Track.IndexOfTailMarker(const Marker: AnsiString): Integer;
var
  markerBytes: TBytes;
  i, j: Integer;
begin
  Result := -1;
  markerBytes := TEncoding.ANSI.GetBytes(string(Marker));
  if Length(markerBytes) = 0 then
    Exit;

  for i := Length(FRaw) - Length(markerBytes) downto 0 do
  begin
    for j := 0 to High(markerBytes) do
      if FRaw[i + j] <> markerBytes[j] then
        Break;
    if j > High(markerBytes) then
      Exit(i);
  end;
end;

procedure TGP3Track.DetectTailStart;
var
  idxGp3, idxGp2: Integer;
begin
  idxGp3 := IndexOfTailMarker(AnsiString('#GP3INFO|'));
  idxGp2 := IndexOfTailMarker(AnsiString('#GP2INFO'));

  if (idxGp3 >= 0) and ((idxGp2 < 0) or (idxGp3 <= idxGp2)) then
  begin
    FTailStart := idxGp3;
  end
  else if (idxGp2 >= 0) then
    FTailStart := idxGp2
  else
  begin
    if Length(FRaw) >= 4 then
      FTailStart := Length(FRaw) - 4
    else
      FTailStart := Length(FRaw);
  end;

  if FTailStart < 0 then
    FTailStart := 0;
  if FTailStart > Length(FRaw) then
    FTailStart := Length(FRaw);
end;

function TGP3Track.FindLastPatternBeforeLimit(const Pattern: TBytes;
  Limit: Integer): Integer;
var
  i, j, maxStart: Integer;
begin
  Result := -1;
  if (Length(Pattern) = 0) or (Limit < Length(Pattern)) then
    Exit;

  maxStart := Limit - Length(Pattern);
  for i := maxStart downto 0 do
  begin
    for j := 0 to High(Pattern) do
      if FRaw[i + j] <> Pattern[j] then
        Break;
    if j > High(Pattern) then
      Exit(i);
  end;
end;

class function TGP3Track.AnsiBytesToString(const Bytes: TBytes): string;
begin
  Result := TEncoding.ANSI.GetString(Bytes);
end;

class function TGP3Track.StringToAnsiBytes(const S: string): TBytes;
begin
  Result := TEncoding.ANSI.GetBytes(S);
end;

procedure TGP3Track.ParseJamList(StartOfs, EndOfs: Integer);
var
  i: Integer;
  entry: TList<Byte>;
begin
  FJamList.Clear;
  if (StartOfs < 0) or (EndOfs <= StartOfs) then
    Exit;

  i := StartOfs;
  entry := TList<Byte>.Create;
  try
    while i < EndOfs do
    begin
      // if FRaw[i] <> $00 then
      // begin
      // showmessage('break');
      // Break; // unexpected byte: stop parsing
      // end;

      // Inc(i); // skip leading 00

      entry.Clear;
      while (i < EndOfs) and (FRaw[i] <> $00) do
      begin
        entry.Add(FRaw[i]);
        Inc(i);
      end;

      if entry.Count > 0 then
        FJamList.Add(AnsiBytesToString(entry.ToArray));

      if (i < EndOfs) and (FRaw[i] = $00) then
        Inc(i); // skip trailing 00 and continue
    end;
  finally
    entry.Free;
  end;
end;

procedure TGP3Track.LoadFromFile(const FileName: string);
var
  sigLen, afterSig: Integer;
  sigBytes: TBytes;
begin
  FRaw := TFile.ReadAllBytes(FileName);

  DetectTailStart; // establish FTailStart to preserve it later

  sigLen := Length(JamSig);
  SetLength(sigBytes, Length(JamSig));
  Move(JamSig[0], sigBytes[0], Length(JamSig));
  FSigOffset := FindLastPatternBeforeLimit(sigBytes, FTailStart);
  FHasSignature := (FSigOffset >= 0);

  if FHasSignature then
  begin
    afterSig := FSigOffset + sigLen;
    if afterSig >= Length(FRaw) then
      Exit;

    FUnkByte := FRaw[afterSig];
    FJamStartOffset := afterSig + 1;
    ParseJamList(FJamStartOffset, FTailStart);
  end
  else
  begin
    FJamList.Clear;
    FUnkByte := 0;
    FJamStartOffset := -1;
  end;
end;

procedure TGP3Track.SaveToFile(const FileName: string);
var
  outBuf: TBytes;
  outLen, i: Integer;
  S: string;
  ANSI: TBytes;
  sigLen: Integer;
begin
  if not FHasSignature then
    raise Exception.Create('No jam signature found: cannot save jam list.');

  sigLen := Length(JamSig);

  SetLength(outBuf, FSigOffset);
  Move(FRaw[0], outBuf[0], FSigOffset);
  outLen := Length(outBuf);

  SetLength(outBuf, outLen + sigLen);
  Move(JamSig[0], outBuf[outLen], sigLen);
  Inc(outLen, sigLen);

  SetLength(outBuf, outLen + 1);
  outBuf[outLen] := FUnkByte;
  Inc(outLen);

  for S in FJamList do
  begin
    SetLength(outBuf, outLen + 1);
    outBuf[outLen] := $00;
    Inc(outLen);

    ANSI := StringToAnsiBytes(S);
    if Length(ANSI) > 0 then
    begin
      SetLength(outBuf, outLen + Length(ANSI));
      Move(ANSI[0], outBuf[outLen], Length(ANSI));
      Inc(outLen, Length(ANSI));
    end;

    SetLength(outBuf, outLen + 1);
    outBuf[outLen] := $00;
    Inc(outLen);
  end;

  if (FTailStart >= 0) and (FTailStart <= Length(FRaw)) then
  begin
    i := Length(FRaw) - FTailStart; // tail length
    if i > 0 then
    begin
      SetLength(outBuf, outLen + i);
      Move(FRaw[FTailStart], outBuf[outLen], i);
      Inc(outLen, i);
    end;
  end;

  // need to add checksum calculations!!

  TFile.WriteAllBytes(FileName, outBuf);
end;

function TGP3Track.JamCount: Integer;
begin
  Result := FJamList.Count;
end;

function TGP3Track.JamItem(Index: Integer): string;
begin
  Result := FJamList[Index];
end;

procedure TGP3Track.SetJamItem(Index: Integer; const Value: string);
begin
  FJamList[Index] := Value;
end;

procedure TGP3Track.AddJam(const Value: string);
begin
  FJamList.Add(Value);
end;

procedure TGP3Track.InsertJam(Index: Integer; const Value: string);
begin
  FJamList.Insert(Index, Value);
end;

procedure TGP3Track.DeleteJam(Index: Integer);
begin
  FJamList.Delete(Index);
end;

procedure TGP3Track.ClearJam;
begin
  FJamList.Clear;
end;

function TGP3Track.GetJamList: TArray<string>;
begin
  Result := FJamList.ToArray;
end;

procedure TGP3Track.SetJamList(const Items: TArray<string>);
begin
  FJamList.Clear;
  FJamList.AddRange(Items);
end;

end.
