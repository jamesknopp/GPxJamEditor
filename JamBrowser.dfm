object JamBrowserFrm: TJamBrowserFrm
  Left = 0
  Top = 0
  Caption = 'Jam Browser'
  ClientHeight = 766
  ClientWidth = 1198
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  ShowInTaskBar = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object SplitterLeft: TSplitter
    Left = 310
    Top = 40
    Width = 4
    Height = 684
    ExplicitLeft = 256
    ExplicitHeight = 532
  end
  object Splitter1: TSplitter
    Left = 894
    Top = 40
    Width = 4
    Height = 684
    Align = alRight
    ExplicitLeft = 620
    ExplicitTop = -95
    ExplicitHeight = 536
  end
  object SplitterFilmstrip: TSplitter
    Left = 0
    Top = 724
    Width = 1198
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = -372
    ExplicitTop = 437
    ExplicitWidth = 996
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 728
    Width = 1198
    Height = 38
    Panels = <
      item
        Width = 300
      end>
    ExplicitTop = 711
    ExplicitWidth = 1192
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1198
    Height = 40
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 1192
    object jamLoading: TLabel
      Left = 894
      Top = 12
      Width = 63
      Height = 15
      Caption = 'jamLoading'
      Visible = False
    end
    object SliderThumbSize: TTrackBar
      Left = 1
      Top = 1
      Width = 280
      Height = 38
      Align = alLeft
      Max = 256
      Min = 64
      Position = 128
      TabOrder = 0
      OnChange = SliderThumbSizeChange
    end
    object ProgressBar: TProgressBar
      Left = 314
      Top = 8
      Width = 574
      Height = 26
      Smooth = True
      Step = 1
      TabOrder = 1
      Visible = False
      StyleName = 'Windows'
    end
    object btnCancel: TButton
      Left = 1112
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 2
      Visible = False
      OnClick = btnCancelClick
    end
  end
  object PanelFolders: TPanel
    Left = 0
    Top = 40
    Width = 310
    Height = 684
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 667
    object directoryTree: TVirtualDrawTree
      Left = 1
      Top = 1
      Width = 308
      Height = 682
      Align = alClient
      DefaultNodeHeight = 19
      Header.AutoSizeIndex = 0
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
      Images = SystemImages
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes, toAutoChangeScale]
      TreeOptions.MiscOptions = [toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toFullVertGridLines, toUseExplorerTheme]
      TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toCenterScrollIntoView, toSelectNextNodeOnRemoval]
      OnCompareNodes = directoryTreeCompareNodes
      OnDrawNode = directoryTreeDrawNode
      OnFocusChanged = directoryTreeFocusChanged
      OnFreeNode = directoryTreeFreeNode
      OnGetImageIndex = directoryTreeGetImageIndex
      OnGetNodeWidth = directoryTreeGetNodeWidth
      OnInitChildren = directoryTreeInitChildren
      OnInitNode = directoryTreeInitNode
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <
        item
          Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coSmartResize, coAllowFocus, coEditable, coStyleColor]
          Position = 0
          Width = 308
        end>
    end
  end
  object PanelPreview: TPanel
    Left = 898
    Top = 40
    Width = 300
    Height = 684
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 892
    ExplicitHeight = 667
    object ImagePreview: TImage
      Left = 1
      Top = 1
      Width = 298
      Height = 312
      Align = alTop
      Center = True
      Proportional = True
      Stretch = True
    end
    object lblFilename: TLabel
      Left = 6
      Top = 334
      Width = 59
      Height = 15
      Caption = 'File Name: '
      Visible = False
    end
    object lblJamType: TLabel
      Left = 6
      Top = 355
      Width = 54
      Height = 15
      Caption = 'JAM Type:'
      Visible = False
    end
    object lblDimensions: TLabel
      Left = 6
      Top = 376
      Width = 68
      Height = 15
      Caption = 'Dimensions: '
      Visible = False
    end
    object lblTexs: TLabel
      Left = 6
      Top = 398
      Width = 107
      Height = 15
      Caption = 'Number of Textures:'
      Visible = False
    end
    object lblDateCreate: TLabel
      Left = 6
      Top = 419
      Width = 71
      Height = 15
      Caption = 'Date Created:'
      Visible = False
    end
    object lblDateModify: TLabel
      Left = 6
      Top = 440
      Width = 78
      Height = 15
      Caption = 'Date Modified:'
      Visible = False
    end
    object lblSize: TLabel
      Left = 6
      Top = 461
      Width = 23
      Height = 15
      Caption = 'Size:'
      Visible = False
    end
  end
  object jamListView: TEasyListview
    Left = 314
    Top = 40
    Width = 580
    Height = 684
    Align = alClient
    CellSizes.ReportThumb.Height = 135
    CellSizes.ReportThumb.Width = 112
    CellSizes.Thumbnail.Height = 128
    CellSizes.Thumbnail.Width = 128
    EditManager.Font.Charset = DEFAULT_CHARSET
    EditManager.Font.Color = clWindowText
    EditManager.Font.Height = -12
    EditManager.Font.Name = 'Segoe UI'
    EditManager.Font.Style = []
    DragManager.EnableDragImage = False
    Header.Columns.Tag = 2
    Header.Columns.Items = {
      0600000004000000110000005445617379436F6C756D6E53746F726564FFFECE
      0006000000800C00010101010000000001000181000000FFFFFF1F0001000000
      01000000040000004E0061006D00650000000000000000000000000011000000
      5445617379436F6C756D6E53746F726564FFFECE000600000080080001010101
      0100000000000181000000FFFFFF1F0001000000010000000400000044006100
      74006500000000000000000000000000110000005445617379436F6C756D6E53
      746F726564FFFECE000600000080080001010101020000000000015B000000FF
      FFFF1F00010000000100000004000000530069007A0065000000000000000000
      00000000110000005445617379436F6C756D6E53746F726564FFFECE00060000
      00810C00010101010300000000000181000000FFFFFF1F000100000001000000
      120000004E0075006D0062006500720020006F00660020005400650078007400
      7500720065007300000000000000000000000000}
    Header.Height = 23
    Header.Visible = True
    PaintInfoGroup.MarginBottom.CaptionIndent = 4
    PaintInfoItem.CheckFlat = True
    PaintInfoItem.GridLines = True
    PaintInfoItem.HorzGridLine = True
    PaintInfoItem.VertGridLine = True
    PaintInfoItem.ImageIndent = 10
    PaintInfoItem.ShowBorder = False
    PaintInfoItem.VAlignment = cvaBottom
    PopupMenu = PopupMenu1
    ShowThemedBorder = False
    Sort.Algorithm = esaQuickSort
    Sort.AutoSort = True
    TabOrder = 3
    View = elsThumbnail
    OnItemCompare = jamListViewItemCompare
    OnItemDblClick = jamListViewItemDblClick
    OnItemFreeing = jamListViewItemFreeing
    OnItemImageDraw = jamListViewItemImageDraw
    OnItemImageDrawIsCustom = jamListViewItemImageDrawIsCustom
    OnItemSelectionChanged = jamListViewItemSelectionChanged
  end
  object SystemImages: TImageList
    Left = 164
    Top = 316
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 592
    Top = 392
    object View1: TMenuItem
      Caption = 'View'
      object thumbnails1: TMenuItem
        Caption = 'Thumbnails'
        OnClick = thumbnails1Click
      end
      object Details1: TMenuItem
        Caption = 'Details'
        OnClick = Details1Click
      end
    end
    object SortBy1: TMenuItem
      Caption = 'Sort By'
      object Name1: TMenuItem
        Caption = 'Name'
        Checked = True
        OnClick = Name1Click
      end
      object Date1: TMenuItem
        Caption = 'Date'
        OnClick = Date1Click
      end
      object Size1: TMenuItem
        Caption = 'Size'
        OnClick = Size1Click
      end
      object NumberofTextures1: TMenuItem
        Caption = 'Number of Textures'
        OnClick = NumberofTextures1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Ascending1: TMenuItem
        Caption = 'Ascending'
        OnClick = Ascending1Click
      end
      object Descending1: TMenuItem
        Caption = 'Descending'
        OnClick = Descending1Click
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object AddtoBatch1: TMenuItem
      Caption = 'Add to Batch Convert'
    end
  end
end
