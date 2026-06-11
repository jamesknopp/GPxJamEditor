object JamBatchForm: TJamBatchForm
  Left = 0
  Top = 0
  Caption = 'Jam Batch Converter'
  ClientHeight = 720
  ClientWidth = 1200
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 960
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 0
    Top = 420
    Width = 1200
    Height = 4
    Cursor = crVSplit
    Align = alTop
    ResizeStyle = rsUpdate
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 420
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object lvBatch: TListView
      Left = 5
      Top = 5
      Width = 1190
      Height = 410
      Align = alClient
      Columns = <
        item
          Caption = 'File'
          Width = 180
        end
        item
          Caption = 'Input JAM'
          Width = 120
        end
        item
          Caption = 'Output JAM'
          Width = 130
        end
        item
          AutoSize = True
          Caption = 'Output Location'
        end
        item
          Caption = 'Status'
          Width = 110
        end
        item
          Caption = 'Pal Simp'
          Width = 110
        end
        item
          Caption = 'Blur'
          Width = 50
        end
        item
          Caption = 'Simp Thresh'
          Width = 90
        end
        item
          Caption = 'Simp All Pals'
          Width = 90
        end
        item
          Caption = 'Soften Matte'
          Width = 90
        end
        item
          Caption = 'No Pal Gen'
          Width = 80
        end>
      DoubleBuffered = True
      FullDrag = True
      MultiSelect = True
      ReadOnly = True
      ParentDoubleBuffered = False
      PopupMenu = jamBatchPopup
      RowSelect = True
      SortType = stBoth
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lvBatchClick
      OnCustomDrawSubItem = lvBatchCustomDrawSubItem
      OnCustomDrawItem = lvBatchCustomDrawItem
      OnKeyDown = lvBatchKeyDown
      OnSelectItem = lvBatchSelectItem
      OnDblClick = lvBatchDblClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 424
    Width = 1200
    Height = 256
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 1
    object Label4: TLabel
      Left = 12
      Top = 8
      Width = 57
      Height = 15
      Caption = 'Input JAM:'
    end
    object LabelOutputFormat: TLabel
      Left = 12
      Top = 62
      Width = 81
      Height = 15
      Caption = 'Output Format:'
    end
    object Label5: TLabel
      Left = 824
      Top = 8
      Width = 90
      Height = 15
      Caption = 'Output Location:'
    end
    object Label6: TLabel
      Left = 824
      Top = 112
      Width = 92
      Height = 15
      Caption = 'Output Filename:'
    end
    object strJamFile: TEdit
      Left = 12
      Top = 27
      Width = 328
      Height = 23
      ReadOnly = True
      TabOrder = 0
    end
    object cbOutputFormat: TComboBox
      Left = 12
      Top = 81
      Width = 328
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbOutputFormatChange
      Items.Strings = (
        'GP2 JAM'
        'GP3 SW JAM'
        'GP3 HW JAM')
    end
    object btnAddFile: TButton
      Left = 12
      Top = 120
      Width = 100
      Height = 27
      Caption = 'Add File(s)'
      TabOrder = 2
      OnClick = btnAddFileClick
    end
    object btnScanFolder: TButton
      Left = 118
      Top = 120
      Width = 140
      Height = 27
      Caption = 'Add && Scan Folder'
      TabOrder = 3
      OnClick = btnScanFolderClick
    end
    object chkScanAllFolders: TCheckBox
      Left = 120
      Top = 153
      Width = 160
      Height = 18
      Caption = 'Include sub-folders'
      TabOrder = 4
    end
    object btnDel: TButton
      Left = 12
      Top = 184
      Width = 246
      Height = 27
      Caption = 'Remove Selected'
      Enabled = False
      TabOrder = 5
      OnClick = btnDelClick
    end
    object GroupBoxTools: TGroupBox
      Left = 12
      Top = 218
      Width = 328
      Height = 27
      Caption = ''
      TabOrder = 6
      object btnConvertTrack: TButton
        Left = 8
        Top = 0
        Width = 156
        Height = 25
        Caption = 'Convert Track JAMs'
        Hint = 'Scan a GP3 track .dat file and batch-convert every JAM it references'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnConvertTrackClick
      end
    end
    object GroupBox1: TGroupBox
      Left = 356
      Top = 8
      Width = 452
      Height = 240
      Caption = 'Palette Controls (Only for GP2 && GP3 SW JAMs)'
      TabOrder = 7
      object panel: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 19
        Width = 446
        Height = 218
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 10
        TabOrder = 0
        ExplicitTop = 20
        ExplicitWidth = 416
        ExplicitHeight = 180
        object Label2: TLabel
          Left = 10
          Top = 10
          Width = 188
          Height = 15
          Caption = 'Input Image Simplification Method:'
        end
        object Label1: TLabel
          Left = 10
          Top = 71
          Width = 71
          Height = 15
          Caption = 'Blur Amount:'
        end
        object Label3: TLabel
          Left = 130
          Top = 71
          Width = 102
          Height = 15
          Caption = 'Simplify Threshold:'
        end
        object cbSimplify: TComboBox
          Left = 10
          Top = 29
          Width = 260
          Height = 23
          Style = csDropDownList
          ItemIndex = 3
          TabOrder = 0
          Text = 'Neighbour Threshold (Usually best)'
          OnChange = cbSimplifyChange
          Items.Strings = (
            'Quad Tree Method (Blocky)'
            'Seed Threshold'
            'Mean Region '
            'Neighbour Threshold (Usually best)')
        end
        object chkSimpPalette: TCheckBox
          Left = 280
          Top = 29
          Width = 150
          Height = 18
          Caption = 'Simplify All Palettes'
          TabOrder = 1
          OnClick = chkSimpPaletteClick
        end
        object chkDoMatte: TCheckBox
          Left = 280
          Top = 53
          Width = 150
          Height = 18
          Caption = 'Don'#39't Soften Matte'
          TabOrder = 2
          OnClick = chkDoMatteClick
        end
        object seBlur: TNumberBox
          Left = 10
          Top = 92
          Width = 110
          Height = 23
          MinValue = 1.000000000000000000
          MaxValue = 10.000000000000000000
          TabOrder = 3
          Value = 1.000000000000000000
          SpinButtonOptions.Placement = nbspCompact
          UseMouseWheel = True
          OnChange = seBlurChange
        end
        object seThreshold: TNumberBox
          Left = 130
          Top = 92
          Width = 140
          Height = 23
          MaxValue = 100.000000000000000000
          TabOrder = 4
          Value = 20.000000000000000000
          SpinButtonOptions.Placement = nbspCompact
          UseMouseWheel = True
          OnChange = seThresholdChange
        end
        object chkDoPalette: TCheckBox
          Left = 280
          Top = 77
          Width = 161
          Height = 18
          Caption = 'Do Not Generate Palettes'
          TabOrder = 5
          OnClick = chkDoPaletteClick
        end
      end
    end
    object edtOutputPath: TEdit
      Left = 824
      Top = 27
      Width = 357
      Height = 23
      TabOrder = 8
      OnChange = edtOutputPathChange
    end
    object btnBrowseOutput: TButton
      Left = 824
      Top = 58
      Width = 357
      Height = 27
      Caption = 'Browse...'
      TabOrder = 9
      OnClick = btnBrowseOutputClick
    end
    object edtFilename: TEdit
      Left = 824
      Top = 131
      Width = 357
      Height = 23
      TabOrder = 10
      OnChange = edtFilenameChange
    end
  end
  object StatusBarPanel: TPanel
    Left = 0
    Top = 680
    Width = 1200
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 2
    object btnRun: TButton
      Left = 6
      Top = 6
      Width = 110
      Height = 27
      Caption = 'Run Batch'
      Default = True
      TabOrder = 0
      OnClick = btnRunClick
    end
    object btnCancel: TButton
      Left = 122
      Top = 6
      Width = 90
      Height = 27
      Caption = 'Cancel'
      Enabled = False
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object lblProgress: TLabel
      Left = 224
      Top = 12
      Width = 48
      Height = 15
      Caption = '0 / 0'
    end
    object pbBatch: TProgressBar
      Left = 288
      Top = 8
      Width = 900
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
  end
  object jamBatchPopup: TPopupMenu
    OnPopup = jamBatchPopupPopup
    Left = 344
    Top = 660
    object AddFiles01: TMenuItem
      Caption = 'Add File(s)'
      OnClick = btnAddFileClick
    end
    object AddScanFolder1: TMenuItem
      Caption = 'Add && Scan Folder'
      OnClick = btnScanFolderClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuOpenFolder: TMenuItem
      Caption = 'Open Containing Folder'
      Enabled = False
      OnClick = mnuOpenFolderClick
    end
    object mnuRetryFailed: TMenuItem
      Caption = 'Retry Failed Item(s)'
      Enabled = False
      OnClick = mnuRetryFailedClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DeleteItems1: TMenuItem
      Caption = 'Delete Item(s)'
      Enabled = False
      OnClick = DeleteItems1Click
    end
  end
  object openTrack: TOpenDialog
    Filter = 'GP3 Track (*.dat)|*.dat|All files (*.*)|*.*'
    Left = 512
    Top = 660
  end
end
