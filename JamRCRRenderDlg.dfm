object JamRCRRenderDlgForm: TJamRCRRenderDlgForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Render RCR'
  ClientHeight = 760
  ClientWidth = 920
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object lblFolders: TLabel
    Left = 496
    Top = 8
    Width = 312
    Height = 50
    AutoSize = False
    Caption = 'Folders...'
    WordWrap = True
  end
  object lblRCR: TLabel
    Left = 8
    Top = 72
    Width = 60
    Height = 13
    Caption = 'RCR JAM:'
  end
  object lblPair: TLabel
    Left = 320
    Top = 72
    Width = 500
    Height = 13
    Caption = ''
  end
  object lblLivery: TLabel
    Left = 8
    Top = 102
    Width = 33
    Height = 13
    Caption = 'Livery:'
  end
  object lblChassis: TLabel
    Left = 8
    Top = 132
    Width = 40
    Height = 13
    Caption = 'Chassis:'
  end
  object lblTyre: TLabel
    Left = 8
    Top = 162
    Width = 26
    Height = 13
    Caption = 'Tyre:'
  end
  object lblHelmet: TLabel
    Left = 8
    Top = 192
    Width = 38
    Height = 13
    Caption = 'Helmet:'
  end
  object lblStatus: TLabel
    Left = 8
    Top = 735
    Width = 31
    Height = 13
    Caption = 'Ready'
  end
  object rgMode: TRadioGroup
    Left = 8
    Top = 8
    Width = 304
    Height = 49
    Caption = 'Mode'
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'GP2'
      'GP3 single'
      'GP3 multi')
    TabOrder = 0
    OnClick = rgModeClick
  end
  object rgGP3Version: TRadioGroup
    Left = 320
    Top = 8
    Width = 168
    Height = 49
    Caption = 'GP3 Version'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'GP3'
      'GP3 2000')
    TabOrder = 14
    OnClick = rgGP3VersionClick
  end
  object btnOptions: TButton
    Left = 816
    Top = 28
    Width = 96
    Height = 25
    Caption = 'Options...'
    TabOrder = 1
    OnClick = btnOptionsClick
  end
  object cbRCR: TComboBox
    Left = 96
    Top = 69
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    OnChange = cbRCRChange
  end
  object cbLivery: TComboBox
    Left = 96
    Top = 99
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    OnChange = cbLiveryChange
  end
  object cbChassis: TComboBox
    Left = 96
    Top = 129
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = cbChassisChange
  end
  object cbTyre: TComboBox
    Left = 96
    Top = 159
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    OnChange = cbTyreChange
  end
  object cbHelmet: TComboBox
    Left = 96
    Top = 189
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    OnChange = cbHelmetChange
  end
  object btnRender: TButton
    Left = 8
    Top = 224
    Width = 120
    Height = 30
    Caption = 'Render'
    TabOrder = 7
    OnClick = btnRenderClick
  end
  object btnExportSheet: TButton
    Left = 136
    Top = 224
    Width = 160
    Height = 30
    Caption = 'Export full sheet...'
    TabOrder = 8
    OnClick = btnExportSheetClick
  end
  object btnExportPerEntry: TButton
    Left = 304
    Top = 224
    Width = 160
    Height = 30
    Caption = 'Export per-entry...'
    TabOrder = 9
    OnClick = btnExportPerEntryClick
  end
  object btnZoomOut: TButton
    Left = 480
    Top = 224
    Width = 60
    Height = 30
    Caption = 'Zoom -'
    TabOrder = 10
    OnClick = btnZoomOutClick
  end
  object btnZoomReset: TButton
    Left = 544
    Top = 224
    Width = 64
    Height = 30
    Caption = '100%'
    TabOrder = 11
    OnClick = btnZoomResetClick
  end
  object btnZoomIn: TButton
    Left = 612
    Top = 224
    Width = 60
    Height = 30
    Caption = 'Zoom +'
    TabOrder = 12
    OnClick = btnZoomInClick
  end
  object btnClose: TButton
    Left = 792
    Top = 224
    Width = 120
    Height = 30
    Caption = 'Close'
    ModalResult = 8
    TabOrder = 13
  end
  object sbPreview: TScrollBox
    Left = 8
    Top = 266
    Width = 904
    Height = 460
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Color = clGray
    ParentColor = False
    TabOrder = 11
    object imgPreview: TImage
      Left = 0
      Top = 0
      Width = 100
      Height = 100
      AutoSize = True
    end
  end
  object dlgSave: TSaveDialog
    Left = 752
    Top = 64
  end
end
