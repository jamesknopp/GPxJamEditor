object newJamDialog: TnewJamDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'New JAM'
  ClientHeight = 312
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  Position = poScreenCenter
  StyleName = 'Windows'
  ShowInTaskBar = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 19
    Width = 79
    Height = 15
    Caption = 'JAM File Name'
    StyleName = 'Windows'
  end
  object Label2: TLabel
    Left = 8
    Top = 83
    Width = 103
    Height = 15
    Caption = 'JAM Canvas Height'
    StyleName = 'Windows'
  end
  object strName: TEdit
    Left = 8
    Top = 40
    Width = 273
    Height = 23
    TabOrder = 0
    StyleName = 'Windows'
  end
  object intHeight: TSpinEdit
    Left = 8
    Top = 104
    Width = 121
    Height = 24
    MaxValue = 2048
    MinValue = 64
    StyleName = 'Windows'
    TabOrder = 1
    Value = 256
  end
  object radioJamType: TRadioGroup
    Left = 8
    Top = 144
    Width = 273
    Height = 114
    Caption = 'JAM Type'
    ItemIndex = 0
    Items.Strings = (
      'GP2 JAM'
      'GP3 Software JAM'
      'GP3 Hardware JAM'
      'GP3/4 JIP')
    TabOrder = 2
    StyleName = 'Windows'
  end
  object btnCreate: TButton
    Left = 8
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Create'
    Default = True
    TabOrder = 3
    StyleName = 'Windows'
    OnClick = btnCreateClick
  end
  object Button2: TButton
    Left = 206
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    StyleName = 'Windows'
    OnClick = Button2Click
  end
end
