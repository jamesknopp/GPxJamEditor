program JamViewer;

{$R *.dres}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  Vcl.Forms,
  mainform in 'mainform.pas' {FormMain},
  JamGeneral in 'JamGeneral.pas',
  JamPalette in 'JamPalette.pas',
  GeneralHelpers in 'GeneralHelpers.pas',
  JamBrowser in 'JamBrowser.pas' {JamBrowserFrm},
  JamHW in 'JamHW.pas',
  JamSW in 'JamSW.pas',
  newJamDlg in 'newJamDlg.pas' {newJamDialog},
  JamPaletteDetector in 'JamPaletteDetector.pas',
  JamBatch in 'JamBatch.pas' {JamBatchForm},
  Options in 'Options.pas' {optionsForm},
  JamScalingFlags in 'JamScalingFlags.pas' {frmScalingFlags},
  JamAnalysis in 'JamAnalysis.pas' {frmJamAnalysis},
  GP3Track in 'GP3Track.pas',
  Vcl.Themes,
  Vcl.Styles,
  about in 'about.pas' {aboutForm},
  JamRCRRender in 'JamRCRRender.pas',
  JamRCRSettings in 'JamRCRSettings.pas',
  JamRCRRenderDlg in 'JamRCRRenderDlg.pas' {JamRCRRenderDlgForm},
  JamFileAssoc in 'JamFileAssoc.pas';

{$R *.res}
{$R 'jamicon.res'}

// Second-instance path: hand our command-line file (if any) to the running
// instance over WM_COPYDATA, bring it to the front, then exit.
procedure ForwardToRunningInstance(otherWnd: HWND);
var
  filePath: string;
  cds: TCopyDataStruct;
begin
  if IsIconic(otherWnd) then
    ShowWindow(otherWnd, SW_RESTORE);
  SetForegroundWindow(otherWnd);

  if ParamCount >= 1 then
  begin
    filePath := ExpandFileName(ParamStr(1));
    cds.dwData := JamCopyDataOpenFile;
    cds.cbData := (Length(filePath) + 1) * SizeOf(Char);
    cds.lpData := PChar(filePath);
    SendMessage(otherWnd, WM_COPYDATA, 0, LPARAM(@cds));
  end;
end;

var
  mutexHandle: THandle;
  otherWnd: HWND;

begin
  // Named mutex enforces a single instance.  The handle is intentionally
  // never closed — Windows releases it when the process exits.
  mutexHandle := CreateMutex(nil, False, JamEditorMutexName);
  if (mutexHandle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    otherWnd := FindWindow('TFormMain', nil);
    if otherWnd <> 0 then
      ForwardToRunningInstance(otherWnd);
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Jam Editor';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TJamBrowserFrm, JamBrowserFrm);
  Application.CreateForm(TnewJamDialog, newJamDialog);
  Application.CreateForm(TJamBatchForm, JamBatchForm);
  Application.CreateForm(ToptionsForm, optionsForm);
  Application.CreateForm(TfrmScalingFlags, frmScalingFlags);
  Application.CreateForm(TfrmJamAnalysis, frmJamAnalysis);
  Application.CreateForm(TaboutForm, aboutForm);
  FormMain.OpenCommandLineFile;
  Application.Run;

end.
