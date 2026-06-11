unit newJamDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, JamGeneral;

type
  TnewJamDialog = class(TForm)
    strName: TEdit;
    intHeight: TSpinEdit;
    radioJamType: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    btnCreate: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ResetForm;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  newJamDialog: TnewJamDialog;

implementation

uses
  System.IOUtils, mainform, jampalette;

{$R *.dfm}

procedure TnewJamDialog.btnCreateClick(Sender: TObject);
var
  FileName: string;
  InvalidChars: TArray<Char>;
  c: Char;
  i: integer;
begin
  // 1) Get & trim
  FileName := Trim(strName.Text);
  if FileName.IsEmpty then
  begin
    inc(intUntitledCount);
    FileName := format('untitled%d', [intUntitledCount]);

  end;

  // 2) Check for any invalid file‐name characters
  InvalidChars := TPath.GetInvalidFileNameChars;
  // ['<', '>', ':', '"', '/', '\', '|', '?', '*', …]
  for c in InvalidChars do
    if FileName.Contains(c) then
    begin
      ShowMessage
        (format('The character "%s" is not allowed in file names.', [c]));
      Exit;
    end;

  // 3) Prevent entering an extension
  if FileName.Contains('.') then
  begin
    ShowMessage
      ('Please do not include an extension; it will be added automatically.');
    Exit;
  end;

  // 4) Dispatch based on Jamtype.ItemIndex
  case radioJamType.ItemIndex of
    0:
      begin
        for i := 0 to 255 do
          GPXPal[i] := Gp2Pal[i];

        boolGP2JAM := true;
        boolGP3JAM := false;
        boolHWJAM := false;
        boolJipMode := false;
        jamtype := jamGP2;

        formmain.NewJam(FileName, intHeight.value);
      end;
    1:
      begin
        for i := 0 to 255 do
          GPXPal[i] := Gp3Pal[i];

        boolGP3JAM := true;
        jamtype := jamGP3SW;
        boolGP2JAM := false;
        boolHWJAM := false;
        boolJipMode := false;

        formmain.NewJam(FileName, intHeight.value);
      end;

    2:
      begin
        jamtype := jamGP3HW;

        boolHWJAM := true;

        boolGP3JAM := false;

        boolGP2JAM := false;

        boolJipMode := false;
        formmain.NewJam(FileName, intHeight.value);

      end;
    3:
      begin
        for i := 0 to 255 do
          GPXPal[i] := Gp3Pal[i];

        jamtype := jamJIP;

        boolJipMode := true;
        boolGP3JAM := false;

        boolGP2JAM := false;
        boolHWJAM := false;

        formmain.NewJam(FileName, intHeight.value);

      end;

  else
    ShowMessage('Please select a JAM type.');
  end;
  boolrcrJAM := false;
  newJamDialog.close;

end;

procedure TnewJamDialog.Button2Click(Sender: TObject);
begin
  newJamDialog.close;
end;

procedure TnewJamDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (ActiveControl = strName) then
  begin
    Key := 0; // consume it
    btnCreate.Click;
  end;
end;

procedure TnewJamDialog.ResetForm;
begin
  strName.Text := '';
  intHeight.value := 256;
  radioJamType.ItemIndex := 0; // e.g. GP2JAM
end;

procedure TnewJamDialog.FormShow(Sender: TObject);
begin
  ResetForm;
end;

end.
