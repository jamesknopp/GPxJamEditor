unit JamRCRSettings;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
  System.Win.Registry,
  JamGeneral, JamRCRRender;

type
  TGP3Version = (gp3v1998, gp3v2000);

  TJamRCRSettings = record
    GP2Folder:         string;
    GP3MainFolder:     string;
    GP3LiveriesFolder: string;
    GP3Version:        TGP3Version;
  end;

const
  // Registry value name under HKCU\Software\JKVFX\JamEditor\.
  // Only GP3Version is stored standalone; the three folder paths are
  // derived at read time from the existing strGP2Location /
  // strGP3Location / strGP32kLocation globals (which the editor already
  // persists from the Options form).
  REG_RCR_GP3_VERSION         = 'RCRGP3Version';   // 0 = GP3, 1 = GP3 2000

  // Subfolders, relative to the chosen GP2/GP3 game root.
  GP2_RCR_SUBFOLDER           = 'GameJams';
  GP3_RCR_SUBFOLDER           = 'Gp3Jams\Main';
  GP3_LIVERIES_SUBFOLDER      = 'Gp3Jams\Liveries';

  // Last-resort fallbacks used only when the corresponding game-root
  // global is empty AND the derived path doesn't exist on disk.
  DEFAULT_GP2_FOLDER          = 'D:\gp2\GAMEJAMS';
  DEFAULT_GP3_MAIN_FOLDER     = 'D:\gp3\Gp3jams\Main';
  DEFAULT_GP3_LIVERIES_FOLDER = 'D:\gp3\Gp3jams\Liveries';

// Loads all four settings, falling back to defaults for missing/stale entries.
function LoadRCRSettings: TJamRCRSettings;

// Persists all four settings.
procedure SaveRCRSettings(const S: TJamRCRSettings);

// Returns the 13 GP2 team livery names (no extension).
function GP2LiveryNames: TArray<string>;

// Returns the GP3 team livery names (no extension) for the given version.
// GP3 1998 has 11 teams, GP3 2000 has 12 (1mclar/2mclar variants etc.).
function GP3LiveryNames(V: TGP3Version): TArray<string>;

// Returns the tyre filenames (with .jam extension) for the given GP3 version.
function GP3TyreNames(V: TGP3Version): TArray<string>;

// File-existence-filtered variants. Each returns only entries whose file
// exists under the relevant folder. Folder is required.
function ExistingGP2Liveries(const GP2Folder: string): TArray<string>;
function ExistingGP3Liveries(const GP3LiveriesFolder: string;
  V: TGP3Version): TArray<string>;
function ExistingGP3Tyres(const GP3MainFolder: string;
  V: TGP3Version): TArray<string>;

// Returns all RCR car JAMs in the GP2 folder matching RCR*.JAM
// (case-insensitive).
function ExistingGP2RCRs(const GP2Folder: string): TArray<string>;

// Returns all GP3 multi-surface RCR JAMs (rcr*a.jam) in the GP3 main folder.
function ExistingGP3MultiRCRs(const GP3MainFolder: string): TArray<string>;

implementation

const
  baseKeyPath = '\Software\JKVFX\JamEditor\';

  GP2_LIVERIES: array[0..12] of string = (
    'Benetton', 'Ferrari',  'Footwork', 'Jordan',  'Larrous',
    'Ligier',   'Lotus',    'Mclaren',  'Minardi', 'Pacific',
    'Simtek',   'Tyrrel',   'Williams'
  );

  GP3_LIVERIES_1998: array[0..10] of string = (
    'Arrows98', 'Benett98', 'Ferrar98', 'Jordan98', 'Mclare98',
    'Minard98', 'Prost98',  'Sauber98', 'Stewar98', 'Tyrrel98',
    'Willia98'
  );

  GP3_LIVERIES_2000: array[0..11] of string = (
    '1mclar00', '2mclar00', 'Arrows00', 'Bar00',
    'Benett00', 'Ferrar00', 'Jaguar00', 'Jordan00',
    'Minardi00', 'Prost00', 'Sauber00', 'Willia00'
  );

  GP3_TYRES_FULL: array[0..3] of string = (
    'Whblur0.jam', 'Whblur1.jam', 'Whbridg0.jam', 'Whbridg1.jam'
  );

  GP3_TYRES_2000: array[0..1] of string = (
    'Whbridg0.jam', 'Whbridg1.jam'
  );

function GP2LiveryNames: TArray<string>;
var
  i: Integer;
begin
  SetLength(Result, Length(GP2_LIVERIES));
  for i := Low(GP2_LIVERIES) to High(GP2_LIVERIES) do
    Result[i] := GP2_LIVERIES[i];
end;

function GP3LiveryNames(V: TGP3Version): TArray<string>;
var
  i: Integer;
begin
  case V of
    gp3v2000:
      begin
        SetLength(Result, Length(GP3_LIVERIES_2000));
        for i := Low(GP3_LIVERIES_2000) to High(GP3_LIVERIES_2000) do
          Result[i] := GP3_LIVERIES_2000[i];
      end;
  else
    SetLength(Result, Length(GP3_LIVERIES_1998));
    for i := Low(GP3_LIVERIES_1998) to High(GP3_LIVERIES_1998) do
      Result[i] := GP3_LIVERIES_1998[i];
  end;
end;

function GP3TyreNames(V: TGP3Version): TArray<string>;
var
  i: Integer;
begin
  case V of
    gp3v2000:
      begin
        SetLength(Result, Length(GP3_TYRES_2000));
        for i := Low(GP3_TYRES_2000) to High(GP3_TYRES_2000) do
          Result[i] := GP3_TYRES_2000[i];
      end;
  else
    SetLength(Result, Length(GP3_TYRES_FULL));
    for i := Low(GP3_TYRES_FULL) to High(GP3_TYRES_FULL) do
      Result[i] := GP3_TYRES_FULL[i];
  end;
end;

// Best effort: prefer Root + Sub if the resulting folder exists; otherwise
// fall back to Default_. Avoids returning a derived path that doesn't
// exist (e.g. when the user has only GP3 2000 configured but the dialog
// is set to GP3 mode).
function DeriveFolder(const Root, Sub, Default_: string): string;
begin
  if (Root <> '') and
     DirectoryExists(IncludeTrailingPathDelimiter(Root) + Sub) then
    Result := IncludeTrailingPathDelimiter(Root) + Sub
  else if DirectoryExists(Default_) then
    Result := Default_
  else
    Result := IncludeTrailingPathDelimiter(Root) + Sub;  // surface "doesn't exist" to caller
end;

function LoadRCRSettings: TJamRCRSettings;
var
  Reg: TRegistry;
  v: Integer;
  gp3root: string;
begin
  Result.GP3Version := gp3v1998;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(baseKeyPath) then
    try
      if Reg.ValueExists(REG_RCR_GP3_VERSION) then
      begin
        v := Reg.ReadInteger(REG_RCR_GP3_VERSION);
        if v = 1 then Result.GP3Version := gp3v2000
        else          Result.GP3Version := gp3v1998;
      end;
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  // Derive folders from the editor's existing game-root globals.
  Result.GP2Folder := DeriveFolder(strGP2Location, GP2_RCR_SUBFOLDER,
    DEFAULT_GP2_FOLDER);

  if Result.GP3Version = gp3v2000 then gp3root := strGP32kLocation
  else                                  gp3root := strGP3Location;

  Result.GP3MainFolder := DeriveFolder(gp3root, GP3_RCR_SUBFOLDER,
    DEFAULT_GP3_MAIN_FOLDER);
  Result.GP3LiveriesFolder := DeriveFolder(gp3root, GP3_LIVERIES_SUBFOLDER,
    DEFAULT_GP3_LIVERIES_FOLDER);
end;

procedure SaveRCRSettings(const S: TJamRCRSettings);
var
  Reg: TRegistry;
begin
  // Only GP3Version is owned by JamRCRSettings; the game-root globals
  // are persisted by the editor's existing Options form save path.
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(baseKeyPath, True) then
    try
      Reg.WriteInteger(REG_RCR_GP3_VERSION, Ord(S.GP3Version));
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function FilterExisting(const Folder: string;
  const Names: TArray<string>; const Ext: string): TArray<string>;
var
  i, n: Integer;
  Path: string;
begin
  SetLength(Result, Length(Names));
  n := 0;
  for i := 0 to High(Names) do
  begin
    Path := IncludeTrailingPathDelimiter(Folder) + Names[i] + Ext;
    if FileExists(Path) then
    begin
      Result[n] := Names[i] + Ext;
      Inc(n);
    end;
  end;
  SetLength(Result, n);
end;

function ExistingGP2Liveries(const GP2Folder: string): TArray<string>;
begin
  Result := FilterExisting(GP2Folder, GP2LiveryNames, '.JAM');
end;

function ExistingGP3Liveries(const GP3LiveriesFolder: string;
  V: TGP3Version): TArray<string>;
begin
  Result := FilterExisting(GP3LiveriesFolder, GP3LiveryNames(V), '.jam');
end;

function ExistingGP3Tyres(const GP3MainFolder: string;
  V: TGP3Version): TArray<string>;
var
  Names: TArray<string>;
  i, n: Integer;
  Path: string;
begin
  Names := GP3TyreNames(V);
  SetLength(Result, Length(Names));
  n := 0;
  for i := 0 to High(Names) do
  begin
    Path := IncludeTrailingPathDelimiter(GP3MainFolder) + Names[i];
    if FileExists(Path) then
    begin
      Result[n] := Names[i];
      Inc(n);
    end;
  end;
  SetLength(Result, n);
end;

function GlobJam(const Folder, Pattern: string): TArray<string>;
var
  i: Integer;
  All: TArray<string>;
begin
  if not DirectoryExists(Folder) then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  All := TDirectory.GetFiles(Folder, Pattern);
  SetLength(Result, Length(All));
  for i := 0 to High(All) do
    Result[i] := ExtractFileName(All[i]);
end;

function ExistingGP2RCRs(const GP2Folder: string): TArray<string>;
begin
  Result := GlobJam(GP2Folder, 'RCR*.JAM');
end;

function ExistingGP3MultiRCRs(const GP3MainFolder: string): TArray<string>;
begin
  Result := GlobJam(GP3MainFolder, 'rcr*a.jam');
end;

end.
