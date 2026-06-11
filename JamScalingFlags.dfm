object frmScalingFlags: TfrmScalingFlags
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  BorderWidth = 10
  Caption = 'Scaling Flags'
  ClientHeight = 202
  ClientWidth = 245
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object scaleFlags: TCheckListBox
    Left = 0
    Top = 8
    Width = 240
    Height = 137
    Columns = 2
    CheckBoxPadding = 1
    Enabled = False
    Items.Strings = (
      'Flag 1'
      'Flag 2'
      'Flag 3'
      'Flag 4'
      'Flag 5'
      'Flag 6'
      'Flag 7'
      'Flag 8')
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 84
    Top = 167
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 165
    Top = 167
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
  end
end
