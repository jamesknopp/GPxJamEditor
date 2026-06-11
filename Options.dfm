object optionsForm: ToptionsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 516
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 529
    Height = 161
    Caption = 'Locations'
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 35
      Width = 73
      Height = 15
      Caption = 'GP2 Location:'
    end
    object Label2: TLabel
      Left = 10
      Top = 82
      Width = 73
      Height = 15
      Caption = 'GP3 Location:'
    end
    object Label4: TLabel
      Left = 10
      Top = 129
      Width = 85
      Height = 15
      Caption = 'GP32k Location:'
    end
    object edtGP2Loc: TEdit
      Left = 101
      Top = 31
      Width = 302
      Height = 23
      TabOrder = 0
    end
    object edtGp3Loc: TEdit
      Left = 101
      Top = 79
      Width = 302
      Height = 23
      TabOrder = 1
    end
    object btnGP2Browse: TButton
      Left = 426
      Top = 30
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 2
      OnClick = btnGP2BrowseClick
    end
    object btnGP3Browse: TButton
      Left = 426
      Top = 78
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 3
      OnClick = btnGP3BrowseClick
    end
    object btnGP32kBrowse: TButton
      Left = 426
      Top = 127
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 4
      OnClick = btnGP32kBrowseClick
    end
    object edtGp32KLoc: TEdit
      Left = 101
      Top = 126
      Width = 302
      Height = 23
      TabOrder = 5
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 311
    Width = 526
    Height = 162
    Caption = 'Jam Format Detection'
    TabOrder = 1
    object Label3: TLabel
      Left = 10
      Top = 27
      Width = 466
      Height = 75
      Caption = 
        'Jam Editor attempts to work out what each JAM file is - HW JAMs ' +
        'have a specific format whereas there'#39's not an easy way to work o' +
        'ut GP2 or GP3 SW JAMs.'#13#10#13#10'Jam Editor makes an assumption based o' +
        'n JAM'#39's location, or will keep a record of JAMs located in arbit' +
        'ary/non GP2/GP3 locations. You can clear this here:'
      WordWrap = True
    end
    object Button1: TButton
      Left = 144
      Top = 120
      Width = 217
      Height = 25
      Caption = 'Clear JAM Format Records'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Button3: TButton
    Left = 240
    Top = 479
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    OnClick = Button3Click
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 175
    Width = 526
    Height = 130
    Caption = 'General Options'
    TabOrder = 3
    object chkAutoArrange: TCheckBox
      Left = 10
      Top = 32
      Width = 319
      Height = 17
      Caption = 'Auto Arrange Textures on Add && Delete'
      TabOrder = 0
      OnClick = chkAutoArrangeClick
    end
    object rgGP3Version: TRadioGroup
      Left = 10
      Top = 56
      Width = 200
      Height = 66
      Caption = 'GP3 Version (RCR render)'
      ItemIndex = 0
      Items.Strings = (
        'GP3'
        'GP3 2000')
      TabOrder = 1
      OnClick = rgGP3VersionClick
    end
  end
end
