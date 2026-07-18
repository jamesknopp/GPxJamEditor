unit JamFileAssoc;

// Per-user (.jam/.jip) file-association registration for Jam Editor.
// Everything is written under HKCU\Software\Classes — no admin rights needed.
// The Explorer UserChoice key is only ever READ; setting a default when
// another app owns it goes through Windows' own "Open with" dialog
// (SHOpenWithDialog), which is the sanctioned route.

interface

const
  JamProgID = 'JKVFX.JamEditor.jam';
  JipProgID = 'JKVFX.JamEditor.jip';

// Core, parameterised for testability (see harness\TestFileAssoc.dpr)
procedure RegisterExtension(const Ext, ProgID, Description, ExePath: string);
procedure UnregisterExtension(const Ext, ProgID: string);
function ExtensionRegistered(const Ext, ProgID, ExePath: string): Boolean;
function ForeignDefaultForExt(const Ext: string;
  const OurProgIDs: array of string): Boolean;

// App-facing API (binds .jam/.jip + the running executable)
procedure RegisterJamAssociations;
procedure UnregisterJamAssociations;
function JamAssociationsRegistered: Boolean;
function ForeignDefaultPresent(out ExtWithForeignDefault: string): Boolean;
procedure ShowOpenWithPicker(const Ext: string);

implementation

uses
  Winapi.Windows, Winapi.ShlObj, System.Win.Registry, System.SysUtils,
  System.IOUtils;

const
  ClassesRoot = '\Software\Classes\';
  FileExtsRoot = '\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\';

function ReadClassesString(const SubKey: string): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(ClassesRoot + SubKey) then
      Result := Reg.ReadString('');
  finally
    Reg.Free;
  end;
end;

procedure WriteClassesDefault(const SubKey, Data: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(ClassesRoot + SubKey, True) then
    begin
      Reg.WriteString('', Data);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure RegisterExtension(const Ext, ProgID, Description, ExePath: string);
begin
  WriteClassesDefault(ProgID, Description);
  WriteClassesDefault(ProgID + '\DefaultIcon', '"' + ExePath + '",0');
  WriteClassesDefault(ProgID + '\shell\open\command',
    '"' + ExePath + '" "%1"');
  WriteClassesDefault(Ext, ProgID);
end;

procedure UnregisterExtension(const Ext, ProgID: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    // Only remove the extension key if it still points at us — a foreign
    // default written after ours must be left alone.
    if ReadClassesString(Ext) = ProgID then
      Reg.DeleteKey(ClassesRoot + Ext);
    Reg.DeleteKey(ClassesRoot + ProgID);
  finally
    Reg.Free;
  end;
end;

function ExtensionRegistered(const Ext, ProgID, ExePath: string): Boolean;
begin
  // Registered = ext points at our ProgID AND the ProgID's open command
  // references this exact executable (if the exe moved, report false so
  // the user can re-register with the new path).
  Result := (ReadClassesString(Ext) = ProgID) and
    SameText(ReadClassesString(ProgID + '\shell\open\command'),
    '"' + ExePath + '" "%1"');
end;

function ForeignDefaultForExt(const Ext: string;
  const OurProgIDs: array of string): Boolean;
var
  Reg: TRegistry;
  choice: string;
  i: Integer;
begin
  Result := False;
  choice := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(FileExtsRoot + Ext + '\UserChoice') then
      if Reg.ValueExists('ProgId') then
        choice := Reg.ReadString('ProgId');
  finally
    Reg.Free;
  end;
  if choice = '' then
    Exit;
  for i := 0 to High(OurProgIDs) do
    if SameText(choice, OurProgIDs[i]) then
      Exit;
  Result := True;
end;

const
  // Declared locally in case the ShlObj unit in use doesn't surface it
  SHCNF_FLUSHNOWAIT = $3000;

procedure NotifyShellAssocChanged;
begin
  // FLUSHNOWAIT nudges Explorer to refresh cached file-type icons without
  // blocking the UI while it does so.
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST or SHCNF_FLUSHNOWAIT,
    nil, nil);
end;

procedure RegisterJamAssociations;
begin
  RegisterExtension('.jam', JamProgID, 'Jam Editor JAM File', ParamStr(0));
  RegisterExtension('.jip', JipProgID, 'Jam Editor JIP File', ParamStr(0));
  NotifyShellAssocChanged;
end;

procedure UnregisterJamAssociations;
begin
  UnregisterExtension('.jam', JamProgID);
  UnregisterExtension('.jip', JipProgID);
  NotifyShellAssocChanged;
end;

function JamAssociationsRegistered: Boolean;
begin
  Result := ExtensionRegistered('.jam', JamProgID, ParamStr(0)) and
    ExtensionRegistered('.jip', JipProgID, ParamStr(0));
end;

function ForeignDefaultPresent(out ExtWithForeignDefault: string): Boolean;
begin
  Result := True;
  if ForeignDefaultForExt('.jam', [JamProgID, JipProgID]) then
    ExtWithForeignDefault := '.jam'
  else if ForeignDefaultForExt('.jip', [JamProgID, JipProgID]) then
    ExtWithForeignDefault := '.jip'
  else
  begin
    ExtWithForeignDefault := '';
    Result := False;
  end;
end;

type
  TOpenAsInfo = record
    pcszFile: PWideChar;
    pcszClass: PWideChar;
    oaifInFlags: DWORD;
  end;

const
  OAIF_ALLOW_REGISTRATION = $00000001; // show "Always use this app" choice
  OAIF_REGISTER_EXT = $00000002;       // write the association on OK

function SHOpenWithDialog(hwndParent: HWND; const poainfo: TOpenAsInfo)
  : HRESULT; stdcall; external 'shell32.dll' name 'SHOpenWithDialog';

procedure ShowOpenWithPicker(const Ext: string);
var
  info: TOpenAsInfo;
  tempFile: string;
begin
  // SHOpenWithDialog wants a file; give it a scratch one with the right
  // extension.  Deliberately NO OAIF_EXEC — executing would relaunch the
  // app with this dummy file and the single-instance forwarder would then
  // prompt to open it.
  tempFile := TPath.Combine(TPath.GetTempPath, 'JamEditorDefault' + Ext);
  TFile.WriteAllText(tempFile, '');
  try
    info.pcszFile := PWideChar(tempFile);
    info.pcszClass := PWideChar(Ext);
    info.oaifInFlags := OAIF_ALLOW_REGISTRATION or OAIF_REGISTER_EXT;
    SHOpenWithDialog(0, info);
    NotifyShellAssocChanged;
  finally
    TFile.Delete(tempFile);
  end;
end;

end.
