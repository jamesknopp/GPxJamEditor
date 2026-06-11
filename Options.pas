unit Options;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.IOUtils, // for TDirectory, TPath
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, // for TFileOpenDialog, MessageDlg
  Vcl.StdCtrls, Vcl.ExtCtrls,
  jamgeneral, jampalettedetector, JamRCRSettings;

type
  ToptionsForm = class(TForm)
    GroupBox1: TGroupBox;
    edtGP2Loc: TEdit;
    edtGp3Loc: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnGP2Browse: TButton;
    btnGP3Browse: TButton;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Button1: TButton;
    Label4: TLabel;
    edtGp32KLoc: TEdit;
    btnGP32kBrowse: TButton;
    Button3: TButton;
    GroupBox3: TGroupBox;
    chkAutoArrange: TCheckBox;
    rgGP3Version: TRadioGroup;
    procedure btnGP2BrowseClick(Sender: TObject);
    procedure btnGP3BrowseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnGP32kBrowseClick(Sender: TObject);
    procedure chkAutoArrangeClick(Sender: TObject);
    procedure rgGP3VersionClick(Sender: TObject);

  private
    { Private declarations }
  public
    function ValidateFolder(const APath, ExeName: string;
      const Subfolders: TArray<string>;
      out MissingItems: TArray<string>): Boolean;
  end;

var
  optionsForm: ToptionsForm;

implementation

{$R *.dfm}

procedure ToptionsForm.btnGP2BrowseClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
  pickedDir: string;
  missing: TArray<string>;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select the application folder';
    if not dlg.Execute then
      Exit;

    pickedDir := dlg.FileName; // the folder the user chose

    if ValidateFolder(pickedDir, 'GP2.exe', ['GameJams', 'Circuits'], missing)
    then
    begin
      strGP2Location := pickedDir;
      edtGP2Loc.text := pickedDir;
    end
    else
    begin
      ShowMessage('Invalid folder; missing:' + sLineBreak +
        string.Join(sLineBreak, missing));
    end;

  finally
    dlg.Free;
  end;
end;

procedure ToptionsForm.btnGP32kBrowseClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
  pickedDir: string;
  missing: TArray<string>;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select the application folder';
    if not dlg.Execute then
      Exit;

    pickedDir := dlg.FileName; // the folder the user chose

    if ValidateFolder(pickedDir, 'GP3_2000.exe', ['Gp3Jams', 'Gp3JamsH'],
      missing) then
    begin
      strGP32kLocation := pickedDir;
      edtGp32KLoc.text := pickedDir;
    end
    else
    begin
      ShowMessage('Invalid folder; missing:' + sLineBreak +
        string.Join(sLineBreak, missing));
    end;

  finally
    dlg.Free;
  end;
end;

procedure ToptionsForm.btnGP3BrowseClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
  pickedDir: string;
  missing: TArray<string>;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select the application folder';
    if not dlg.Execute then
      Exit;

    pickedDir := dlg.FileName; // the folder the user chose

    if ValidateFolder(pickedDir, 'GP3.exe', ['Gp3Jams', 'Gp3JamsH'], missing)
    then
    begin
      strGP3Location := pickedDir;
      edtGp3Loc.text := pickedDir;
    end
    else
    begin
      ShowMessage('Invalid folder; missing:' + sLineBreak +
        string.Join(sLineBreak, missing));
    end;

  finally
    dlg.Free;
  end;
end;

procedure ToptionsForm.Button1Click(Sender: TObject);
begin
  jampalettedetector.TJamPaletteDetector.Instance.ClearEntries;
end;

procedure ToptionsForm.Button3Click(Sender: TObject);
begin
  optionsForm.close;
end;

procedure ToptionsForm.chkAutoArrangeClick(Sender: TObject);
begin
  boolAutoLayout := chkAutoArrange.checked;
end;

procedure ToptionsForm.FormShow(Sender: TObject);
var
  rcr: TJamRCRSettings;
begin
  edtGP2Loc.text := strGP2Location;
  edtGp3Loc.text := strGP3Location;
  edtGp32KLoc.text := strGP32kLocation;

  chkAutoArrange.checked := boolAutoLayout;

  rcr := LoadRCRSettings;
  if rcr.GP3Version = gp3v2000 then
    rgGP3Version.ItemIndex := 1
  else
    rgGP3Version.ItemIndex := 0;
end;

procedure ToptionsForm.rgGP3VersionClick(Sender: TObject);
var
  rcr: TJamRCRSettings;
begin
  rcr := LoadRCRSettings;
  if rgGP3Version.ItemIndex = 1 then
    rcr.GP3Version := gp3v2000
  else
    rcr.GP3Version := gp3v1998;
  SaveRCRSettings(rcr);
end;

function ToptionsForm.ValidateFolder(const APath, ExeName: string;
  const Subfolders: TArray<string>; out MissingItems: TArray<string>): Boolean;
var
  fullExePath: string;
  i: integer;
  req: string;
begin
  MissingItems := [];
  // 1) Check .exe

  fullExePath := TPath.Combine(APath, ExeName);
  if not TFile.Exists(fullExePath) then
    MissingItems := MissingItems + [ExeName];

  // 2) Check each required subfolder
  for i := 0 to High(Subfolders) do
  begin
    req := Subfolders[i];
    if not TDirectory.Exists(TPath.Combine(APath, req)) then
      MissingItems := MissingItems + [req + PathDelim];
  end;

  Result := Length(MissingItems) = 0;
end;

end.
