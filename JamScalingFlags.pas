unit JamScalingFlags;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, jamgeneral,
  jamsw;

type
  TfrmScalingFlags = class(TForm)
    scaleFlags: TCheckListBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmScalingFlags: TfrmScalingFlags;

implementation

uses
  mainform;

{$R *.dfm}

procedure TfrmScalingFlags.btnOKClick(Sender: TObject);
begin
end;

end.
