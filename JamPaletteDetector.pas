unit JamPaletteDetector;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  System.JSON, Vcl.Dialogs, Vcl.Forms, System.UITypes, JamGeneral;

type

  TJamPaletteDetector = class
  private
    FMap: TDictionary<string, TJamType>;
    class var FInstance: TJamPaletteDetector;
    constructor Create;
    procedure LoadMap;
    procedure SaveMap;
  public
    class function Instance: TJamPaletteDetector;
    class procedure Release;
    function Detect(const APath: string; silent: boolean): TJamType;
    // Faster variant when the caller already knows whether the file is HW.
    // Skips the internal isHWJAM probe, saving one file-open per call.
    function DetectKnown(const APath: string; IsHW: Boolean;
      silent: Boolean): TJamType;
    procedure Remember(const APath: string; AType: TJamType);
    procedure ClearEntries;
  end;

  // Single-pass file-type probe. Replaces the common callsite pattern
  //   if isHWJAM(path) then ... else begin t := Detect(path, True); ... end
  // which opens the file *at least* twice (and internally more for nested
  // paths). This opens the file once, reads the 4-byte magic, then does
  // pure-string directory heuristics for the palette type.
  TJamQuickInfo = record
    Exists: Boolean;       // False if file missing or unreadable
    IsHW: Boolean;         // True = HW JAM (GP3 Hardware)
    PaletteType: TJamType; // jamGP2 / jamGP3SW / jamGP3HW
  end;

function QuickInspectJam(const APath: string): TJamQuickInfo;

implementation

const
  MAPPING_FILE = 'jam_palettes.json';

  { TJamPaletteDetector }

constructor TJamPaletteDetector.Create;
begin
  FMap := TDictionary<string, TJamType>.Create;
  LoadMap;
end;

procedure TJamPaletteDetector.LoadMap;
var
  JSONText: string;
  JSONArray: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
  Pth: string;
  Ty: Integer;
begin
  if not TFile.Exists(MAPPING_FILE) then
    Exit;
  JSONText := TFile.ReadAllText(MAPPING_FILE);
  JSONArray := TJSONObject.ParseJSONValue(JSONText) as TJSONArray;
  try
    for I := 0 to JSONArray.Count - 1 do
    begin
      Obj := JSONArray.Items[I] as TJSONObject;
      Pth := Obj.GetValue<string>('path');
      Ty := Obj.GetValue<Integer>('type');
      FMap.AddOrSetValue(Pth, TJamType(Ty));
    end;
  finally
    JSONArray.Free;
  end;
end;

procedure TJamPaletteDetector.SaveMap;
var
  JSONArray: TJSONArray;
  Pair: TPair<string, TJamType>;
  Obj: TJSONObject;
begin
  JSONArray := TJSONArray.Create;
  try
    for Pair in FMap do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('path', TJSONString.Create(Pair.Key));
      Obj.AddPair('type', TJSONNumber.Create(Ord(Pair.Value)));
      JSONArray.AddElement(Obj);
    end;
    TFile.WriteAllText(MAPPING_FILE, JSONArray.ToString);
  finally
    JSONArray.Free;
  end;
end;

function TJamPaletteDetector.Detect(const APath: string; silent: boolean)
  : TJamType;
// Previously this function had two bugs: it called isHWJAM(APath) inside
// a `while Dir` loop unconditionally (one disk open per ancestor folder
// on unmatched paths — tens of thousands of opens during a big scan),
// and it left Result uninitialised if the loop finished unmatched.
//
// Now delegated to DetectKnown: we do at most one isHWJAM probe up front
// and let the directory-only heuristics do the rest.
var
  cached: TJamType;
begin
  if FMap.TryGetValue(APath, cached) then
    Exit(cached);
  if SameText(ExtractFileExt(APath), '.JIP') then
    Exit(jamGP3SW);
  Result := DetectKnown(APath, isHWJAM(APath), silent);
end;

function TJamPaletteDetector.DetectKnown(const APath: string; IsHW: Boolean;
  silent: Boolean): TJamType;
// Like Detect, but the caller hands us the IsHW result — so we never need
// to open the file. Purely string/dictionary work.
var
  Dir: string;
begin
  if FMap.TryGetValue(APath, Result) then
    Exit;

  if SameText(ExtractFileExt(APath), '.JIP') then
  begin
    Result := jamGP3SW;
    Exit;
  end;

  Dir := ExtractFileDir(APath);
  while Dir <> '' do
  begin
    if SameText(ExtractFileName(Dir), 'GAMEJAMS') then
    begin
      Result := jamGP2;
      Exit;
    end;
    if SameText(ExtractFileName(Dir), 'GP3JAMS')
       or SameText(ExtractFileName(Dir), 'GP3JAMSH') then
    begin
      if IsHW then Result := jamGP3HW else Result := jamGP3SW;
      Exit;
    end;
    if IsHW then
    begin
      Result := jamGP3HW;
      Exit;
    end;
    Dir := TDirectory.GetParent(Dir);
  end;

  // Unknown path + SW JAM — default to GP3SW and optionally ask the user.
  // Scan contexts pass silent=True and get the default without a prompt.
  Result := jamGP3SW;
  if not silent then
  begin
    case MessageDlg(Format('Is "%s" a GP2 or GP3 palette JAM?',
      [ExtractFileName(APath)]), mtCustom, [mbYes, mbNo], 0, mbOK,
      ['GP2', 'GP3']) of
      mrYes: Result := jamGP2;
      mrNo:  Result := jamGP3SW;
    end;
    if Result in [jamGP2, jamGP3SW] then
      Remember(APath, Result);
  end;
end;

function QuickInspectJam(const APath: string): TJamQuickInfo;
// Opens the file exactly once, reads the 4-byte magic, then derives the
// palette type from the file path (no further disk I/O).
//
// Use this anywhere you'd otherwise write:
//     if isHWJAM(path) then ... else begin t := Detect(path, True); ... end
// It replaces 2+ file-opens with 1.
var
  fs: TFileStream;
  magic: Cardinal;
begin
  Result.Exists := False;
  Result.IsHW := False;
  Result.PaletteType := jamGP3SW;

  if not TFile.Exists(APath) then Exit;

  try
    fs := TFileStream.Create(APath, fmOpenRead or fmShareDenyWrite);
    try
      if fs.Size >= SizeOf(magic) then
      begin
        fs.ReadBuffer(magic, SizeOf(magic));
        Result.IsHW := (magic = JAM_HW_MAGIC);
        Result.Exists := True;
      end;
    finally
      fs.Free;
    end;
  except
    // Leave Exists=False; caller decides what to do.
    Exit;
  end;

  Result.PaletteType :=
    TJamPaletteDetector.Instance.DetectKnown(APath, Result.IsHW, True);
end;

procedure TJamPaletteDetector.Remember(const APath: string; AType: TJamType);
begin
  FMap.AddOrSetValue(APath, AType);
  SaveMap;
end;

procedure TJamPaletteDetector.ClearEntries;
begin

  FMap.Clear;

  if TFile.Exists(MAPPING_FILE) then
    TFile.Delete(MAPPING_FILE);
end;

class function TJamPaletteDetector.Instance: TJamPaletteDetector;
begin
  if FInstance = nil then
    FInstance := TJamPaletteDetector.Create;
  Result := FInstance;
end;

class procedure TJamPaletteDetector.Release;
begin
  FreeAndNil(FInstance);
end;

end.
