program JamViewer;

{$R *.dres}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
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
  JamRCRRenderDlg in 'JamRCRRenderDlg.pas' {JamRCRRenderDlgForm};

{$R *.res}

begin
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
  Application.Run;

end.
