unit JamBrowser;

interface

uses
  Winapi.Windows, System.SysUtils,
  System.Classes, System.IOUtils, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.StrUtils,
  VirtualTrees, VirtualTrees.DrawTree, VirtualTrees.Types,
  VirtualTrees.BaseTree, EasyListview, GeneralHelpers,
  MPCommonUtilities,
  Vcl.Imaging.pngimage,

  JamGeneral, JamHW, JamPalette, JamSW, System.ImageList, Vcl.ImgList,
  MPCommonObjects,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.AncestorVCL, jamPaletteDetector,
  Vcl.Menus, Vcl.Dialogs;

type
  // This data record contains all necessary information about a particular file system object.
  // This can either be a folder (virtual or real) or an image file.
  PShellObjectData = ^TShellObjectData;

  TShellObjectData = record
    FullPath, Display: UnicodeString;
    Attributes: Cardinal;
    OpenIndex, CloseIndex: Integer; // image indices into the system image list
    Image: TBitmap;
    Properties: UnicodeString; // some image properties, preformatted
  end;

type

  TJamBrowseNode = class
    FileName: string;
    Thumb: TBitmap;
    Orig: TBitmap;
    Height, Width, numTexs: Integer;
    jamType: string;
    size: Integer;
    dateCreated, dateModified: TDateTime;
    destructor Destroy; override;
  end;

  PJamBrowseNode = ^TJamBrowseNode;

type
  TJamBrowserFrm = class(TForm)
    PanelTop: TPanel;
    SliderThumbSize: TTrackBar;
    PanelFolders: TPanel;
    SplitterLeft: TSplitter;
    Splitter1: TSplitter;
    PanelPreview: TPanel;
    ImagePreview: TImage;
    SplitterFilmstrip: TSplitter;
    directoryTree: TVirtualDrawTree;
    SystemImages: TImageList;
    jamListView: TEasyListview;
    StatusBar1: TStatusBar;
    ProgressBar: TProgressBar;
    lblFilename: TLabel;
    lblJamType: TLabel;
    lblDimensions: TLabel;
    lblTexs: TLabel;
    jamLoading: TLabel;
    lblDateCreate: TLabel;
    lblDateModify: TLabel;
    lblSize: TLabel;
    PopupMenu1: TPopupMenu;
    View1: TMenuItem;
    thumbnails1: TMenuItem;
    Details1: TMenuItem;
    N1: TMenuItem;
    SortBy1: TMenuItem;
    Name1: TMenuItem;
    Date1: TMenuItem;
    Size1: TMenuItem;
    NumberofTextures1: TMenuItem;
    N2: TMenuItem;
    Ascending1: TMenuItem;
    Descending1: TMenuItem;
    AddtoBatch1: TMenuItem;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SliderThumbSizeChange(Sender: TObject);

    procedure directoryTreeCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure directoryTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure directoryTreeGetNodeWidth(Sender: TBaseVirtualTree;
      HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      var NodeWidth: TDimension);
    procedure directoryTreeInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure directoryTreeInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure directoryTreeFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure directoryTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: TImageIndex);
    procedure FormDestroy(Sender: TObject);
    procedure directoryTreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure jamListViewItemFreeing(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure jamListViewItemImageDrawIsCustom(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; var IsCustom: Boolean);
    procedure jamListViewItemImageDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
      const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure jamListViewItemSelectionChanged(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure jamListViewItemDblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem);

    function FindChildNodeByPath(Tree: TVirtualDrawTree; Parent: PVirtualNode;
      const TargetPath: UnicodeString): PVirtualNode;
    function NavigateToPath(Tree: TVirtualDrawTree;
      const Path: UnicodeString): Boolean;

    function GetNodeParent(Node: PVirtualNode): PVirtualNode;

    procedure directoryTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Name1Click(Sender: TObject);
    procedure thumbnails1Click(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure Ascending1Click(Sender: TObject);
    procedure Date1Click(Sender: TObject);
    procedure Size1Click(Sender: TObject);
    procedure NumberofTextures1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Descending1Click(Sender: TObject);
    function jamListViewItemCompare(Sender: TCustomEasyListview;
      Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem;
      var DoDefault: Boolean): Integer;
    procedure btnCancelClick(Sender: TObject);

  public
    FileList: TStringList;
    ThumbSize: Integer;
    FThumbSize: Integer;
    FExtensionsInitialized: Boolean;
    FExtensionList: TStringList;
    FDriveStrings: string;

    FPendingThumbnails: Integer;
    FLoadedThumbnails: Integer;
    FLoadGeneration: Integer;
    FCurrentLoadPath: string;

    procedure LoadImagesFromFolderAsync(const Folder: string);
    procedure LoadImagesWorker(const Folder: string; Generation: Integer);
    procedure RedrawThumbnails;
    procedure ClearPreview;
    function CanDisplay(const Name: String): Boolean;
    function GetDriveString(Index: Integer): string;
    function ReadAttributes(const Name: UnicodeString): Cardinal;
    function GenerateThumbnail(srcBmp: TBitmap; maxSize: Integer;
      bgColor: TColor): TBitmap;
    procedure SortJams(i: Integer; order: Boolean);

    procedure RefreshDirectoryTree;

  public
    gotSelection: Boolean;
  end;

const
  SupportedExtensions: array [0 .. 1] of string = ('.jam', '.jip');

var
  JamBrowserFrm: TJamBrowserFrm;
  cancelJob: Boolean;

implementation

{$R *.dfm}

uses
  System.Math, ShellAPI, Mask, ShlObj, ActiveX, VirtualTrees.Utils, MainForm;

{ TJamBrowseNode }

destructor TJamBrowseNode.Destroy;
begin
  FreeAndNil(Thumb);
  FreeAndNil(Orig);
  inherited;
end;

{ TJamBrowser }

procedure DrawBitmapInRectCentered(const Canvas: TCanvas;
  const SourceBmp: TBitmap; const TargetRect: TRect);
var
  SrcW, SrcH: Integer;
  RectW, RectH: Integer;
  Scale, ScaleW, ScaleH: Double;
  DrawW, DrawH: Integer;
  OffsetX, OffsetY: Integer;
begin
  SrcW := SourceBmp.Width;
  SrcH := SourceBmp.Height;
  RectW := TargetRect.Right - TargetRect.Left;
  RectH := TargetRect.Bottom - TargetRect.Top;

  Canvas.Lock;
  if (SrcW <= 0) or (SrcH <= 0) or (RectW <= 0) or (RectH <= 0) then
    Exit;

  // Compute scaling factor to fit inside rect
  ScaleW := RectW / SrcW;
  ScaleH := RectH / SrcH;
  Scale := Min(ScaleW, ScaleH);

  // Compute scaled size
  DrawW := Round(SrcW * Scale);
  DrawH := Round(SrcH * Scale);

  // Compute offsets to center the image
  OffsetX := TargetRect.Left + (RectW - DrawW) div 2;
  OffsetY := TargetRect.Top + (RectH - DrawH) div 2;

  // Draw stretched and centered
  Canvas.StretchDraw(Rect(OffsetX, OffsetY, OffsetX + DrawW, OffsetY + DrawH),
    SourceBmp);
  Canvas.unlock;
end;

// ----------------------------------------------------------------------------------------------------------------------

function HasChildren(const Folder: string): Boolean;

// Determines whether folder contains other file objects.

var
  SR: TSearchRec;

begin
  Result := FindFirst(IncludeTrailingPathDelimiter(Folder) + '*.*',
    faReadOnly or faHidden or faSysFile or faArchive, SR) = 0;
  if Result then
    FindClose(SR);
end;

// ----------------------------------------------------------------------------------------------------------------------

function GetIconIndex(Name: string; Flags: Cardinal): Integer;

// Returns the index of the system icon for the given file object.

var
  SFI: TSHFileInfo;

begin
  if SHGetFileInfo(PChar(Name), 0, SFI, SizeOf(TSHFileInfo), Flags) = 0 then
    Result := -1
  else
    Result := SFI.iIcon;
end;

// ----------------------------------------------------------------------------------------------------------------------

procedure GetOpenAndClosedIcons(Name: string; var Open, Closed: Integer);

begin
  Closed := GetIconIndex(Name, SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  Open := GetIconIndex(Name, SHGFI_SYSICONINDEX or SHGFI_SMALLICON or
    SHGFI_OPENICON);
end;




// ----------------------------------------------------------------------------------------------------------------------

procedure TJamBrowserFrm.Ascending1Click(Sender: TObject);
begin

  jamListView.Selection.FocusedColumn.SortDirection := esdAscending

end;

procedure TJamBrowserFrm.btnCancelClick(Sender: TObject);
begin
  cancelJob := True;
  FCurrentLoadPath := '';
end;

function TJamBrowserFrm.CanDisplay(const Name: string): Boolean;

// Determines whether the given file is one we can display in the image tree.

var
  Ext: string;
  i: Integer;

begin
  if not FExtensionsInitialized then
  begin
    FExtensionsInitialized := true;
    FExtensionList := TStringList.Create;
{$IFDEF GraphicEx}
    FileFormatList.GetExtensionList(FExtensionList);
    for i := 0 to FExtensionList.Count - 1 do
      FExtensionList[i] := '.' + FExtensionList[i];
{$ELSE}
    // GraphicEx is not used so add some default extensions
    with FExtensionList do
    begin
      // Add('.bmp');
      // Add('.ico');
      // Add('.jpg');
      // Add('.jpeg');
      // Add('.wmf');
      // Add('.emf');
    end;
{$ENDIF}
    FExtensionList.Sort;
  end;

  Ext := ExtractFileExt(Name);
  Result := FExtensionList.Find(Ext, i);
end;

// ----------------------------------------------------------------------------------------------------------------------

function TJamBrowserFrm.GetDriveString(Index: Integer): string;

// Helper method to extract a sub string (given by Index) from FDriveStrings.

var
  Head, Tail: PChar;

begin
  Head := PChar(FDriveStrings);
  Result := '';
  repeat
    Tail := Head;
    while Tail^ <> #0 do
      Inc(Tail);
    if Index = 0 then
    begin
      SetString(Result, Head, Tail - Head);
      Break;
    end;
    Dec(Index);
    Head := Tail + 1;
  until Head^ = #0;
end;

function TJamBrowserFrm.jamListViewItemCompare(Sender: TCustomEasyListview;
  Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem;
  var DoDefault: Boolean): Integer;
var
  val1, val2: Integer;
begin
  Result := 0;
  if Column.Index = 3 then
  begin
    val1 := StrToIntDef(Item1.Captions[3], 0);
    val2 := StrToIntDef(Item2.Captions[3], 0);

    Result := CompareValue(val1, val2);

    // Flip the result for descending sort
    if Column.SortDirection = esdDescending then
      Result := -Result;

    DoDefault := False; // prevent default sorting
  end
  else
    DoDefault := true; // fall back to default sort for other columns
end;

procedure TJamBrowserFrm.jamListViewItemDblClick(Sender: TCustomEasyListview;
  Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem);
begin

  FormMain.LoadJam(TJamBrowseNode(HitInfo.Item.data).FileName);

end;

procedure TJamBrowserFrm.jamListViewItemFreeing(Sender: TCustomEasyListview;
  Item: TEasyItem);
begin
  if Assigned(Item.data) then
  begin
    TJamBrowseNode(Item.data).Free;
    Item.data := nil;
  end;
  ClearPreview;
end;

procedure TJamBrowserFrm.jamListViewItemImageDraw(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
  const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  img: TBitmap;
begin
  img := TJamBrowseNode(Item.data).Thumb;
  AlphaBlender.Blend(Sender, Item, ACanvas, RectArray.IconRect, img);
end;

procedure TJamBrowserFrm.jamListViewItemImageDrawIsCustom
  (Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := true;
end;

procedure TJamBrowserFrm.jamListViewItemSelectionChanged
  (Sender: TCustomEasyListview; Item: TEasyItem);
begin

  if jamListView.Selection.Count = 0 then
  begin
    ImagePreview.visible := False;
    lblJamType.visible := False;
    lblFilename.visible := False;
    lblDimensions.visible := False;
    lblTexs.visible := False;
    lblDateCreate.visible := False;
    lblDateModify.visible := False;
    lblSize.visible := False;

  end
  else
  begin

    ImagePreview.visible := true;
    ImagePreview.Picture.Bitmap := TJamBrowseNode(Item.data).Orig;
    lblJamType.visible := true;
    lblFilename.visible := true;
    lblDimensions.visible := true;
    lblTexs.visible := true;
    lblDateCreate.visible := true;
    lblDateModify.visible := true;
    lblSize.visible := true;

    lblJamType.Caption := 'Jam Type: ' + TJamBrowseNode(Item.data).jamType;
    lblFilename.Caption := 'File Name: ' +
      ExtractFileName(TJamBrowseNode(Item.data).FileName);
    lblDimensions.Caption := 'Dimensions: ' +
      inttostr(TJamBrowseNode(Item.data).Width) + ' x ' +
      inttostr(TJamBrowseNode(Item.data).Height);
    lblTexs.Caption := 'Number of Textures: ' +
      inttostr(TJamBrowseNode(Item.data).numTexs);

    lblDateCreate.Caption := 'Date Created: ' +
      DateToStr(TJamBrowseNode(Item.data).dateCreated);

    lblDateModify.Caption := 'Date Modified: ' +
      DateToStr(TJamBrowseNode(Item.data).dateModified);

    lblSize.Caption := 'Size: ' + FormatFileSize
      (TJamBrowseNode(Item.data).size);
  end;

end;

// ----------------------------------------------------------------------------------------------------------------------

function TJamBrowserFrm.ReadAttributes(const Name: UnicodeString): Cardinal;

// Determines the attributes of the given shell object (file, folder).

const
  SFGAO_CONTENTSMASK = $F0000000; // This value is wrongly defined in ShlObj.

var
  Desktop: IShellFolder;
  Eaten: Cardinal;
  PIDL: PItemIDList;
  Malloc: IMalloc;

begin
  // Get the root folder of the shell name space.
  SHGetDesktopFolder(Desktop);
  // While parsing the name also the shell object's attributes are determined.
  // These is what we are really interested in.
  Result := SFGAO_DISPLAYATTRMASK or SFGAO_CONTENTSMASK or SFGAO_COMPRESSED;
  Desktop.ParseDisplayName(0, nil, PWideChar(Name), Eaten, PIDL, Result);
  // Don't forget to free the returned PIDL. The shell folder is released automatically.
  SHGetMalloc(Malloc);
  Malloc.Free(PIDL);
end;

function TJamBrowserFrm.GenerateThumbnail(srcBmp: TBitmap;
  maxSize: Integer; bgColor: TColor): TBitmap;
var
  TempBmp, ThumbBmp: TBitmap;
  RS: TResourceStream;
  PNG: TPngImage;
  Ratio: Double;
  ThumbW, ThumbH, OffsetX, OffsetY: Integer;
const
  PaddingFactor = 0.95;
begin
  Result := nil;
  TempBmp := TBitmap.Create;
  try
    // Choose source: preview icon if too small
    if (srcBmp.Width < 16) or (srcBmp.Height < 16) then
    begin
      RS := TResourceStream.Create(HInstance, 'noJamPreview', RT_RCDATA);
      PNG := TPngImage.Create;
      try
        PNG.LoadFromStream(RS);
        TempBmp.Assign(PNG);
      finally
        PNG.Free;
        RS.Free;
      end;
    end
    else
      TempBmp.Assign(srcBmp);

    // Calculate size
    Ratio := Min((maxSize * PaddingFactor) / TempBmp.Width,
      (maxSize * PaddingFactor) / TempBmp.Height);
    ThumbW := Round(TempBmp.Width * Ratio);
    ThumbH := Round(TempBmp.Height * Ratio);

    // Create thumbnail
    ThumbBmp := StretchF(TempBmp, ThumbW, ThumbH);
    if not Assigned(ThumbBmp) then
      Exit;

    // Build final image
    Result := TBitmap.Create;
    Result.PixelFormat := pf24bit;
    Result.SetSize(maxSize, maxSize);
    Result.Canvas.Brush.Color := bgColor;
    Result.Canvas.FillRect(Rect(0, 0, maxSize, maxSize));

    OffsetX := (maxSize - ThumbW) div 2;
    OffsetY := (maxSize - ThumbH) div 2;
    Result.Canvas.Draw(OffsetX, OffsetY, ThumbBmp);
  finally
    TempBmp.Free;
    ThumbBmp.Free;
  end;
end;


procedure TJamBrowserFrm.FormCreate(Sender: TObject);
var
  SFI: TSHFileInfo;
  i, DriveCount: Integer;
  Len: Integer;
  DriveMap, Mask: Cardinal;

begin

  cancelJob := False;

  FileList := TStringList.Create;
  ThumbSize := 128;
  SliderThumbSize.Min := 128;
  SliderThumbSize.Max := 512;
  SliderThumbSize.Position := ThumbSize;

  jamListView.CellSizes.Thumbnail.Width := ThumbSize + 40;
  jamListView.CellSizes.Thumbnail.Height := ThumbSize + 40;

  // Initial layout
  RedrawThumbnails;
  directoryTree.NodeDataSize := SizeOf(TShellObjectData);

  // Fill root level of image tree. Determine which drives are mapped.
  DriveCount := 0;
  DriveMap := GetLogicalDrives;
  Mask := 1;
  for i := 0 to 25 do
  begin
    if (DriveMap and Mask) <> 0 then
      Inc(DriveCount);
    Mask := Mask shl 1;
  end;
  // Determine drive strings which are used in the initialization process.
  Len := GetLogicalDriveStrings(0, nil);
  SetLength(FDriveStrings, Len);
  GetLogicalDriveStrings(Len, PChar(FDriveStrings));

  directoryTree.RootNodeCount := DriveCount;

  SystemImages.Handle := SHGetFileInfo('', 0, SFI, SizeOf(SFI),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  SystemImages.ShareImages := true;
  FThumbSize := 200;

  // NavigateToPath(directoryTree,strBrowserPath);
end;

procedure TJamBrowserFrm.FormDestroy(Sender: TObject);
begin
  jamListView.Items.Clear;
  FileList.Free;
  FreeAndNil(FExtensionList);
end;

procedure TJamBrowserFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  tmpStrPath: string;

begin
  tmpStrPath := strBrowserPath;
  if Key = VK_F5 then
  begin

    RefreshDirectoryTree;
    NavigateToPath(directoryTree, tmpStrPath);
    LoadImagesFromFolderAsync(tmpStrPath);
    Key := 0;
  end;
end;

procedure TJamBrowserFrm.FormShow(Sender: TObject);
begin
  NavigateToPath(directoryTree, strBrowserPath);
end;

procedure TJamBrowserFrm.Size1Click(Sender: TObject);
begin
  SortJams(2, true);
  Name1.Checked := False;
  Date1.Checked := False;
  Size1.Checked := true;
  NumberofTextures1.Checked := False;
end;

procedure TJamBrowserFrm.SliderThumbSizeChange(Sender: TObject);
begin
  ThumbSize := SliderThumbSize.Position;
  jamListView.CellSizes.Thumbnail.SetSize(ThumbSize, ThumbSize + 40);
  RedrawThumbnails;

end;

procedure TJamBrowserFrm.LoadImagesFromFolderAsync(const Folder: string);
begin
  // Don't re-trigger if we're already loading this folder
  if SameText(Folder, FCurrentLoadPath) then
    Exit;

  // Cancel any running load by bumping the generation counter
  Inc(FLoadGeneration);
  FCurrentLoadPath := Folder;

  LoadImagesWorker(Folder, FLoadGeneration);
end;

procedure TJamBrowserFrm.LoadImagesWorker(const Folder: string; Generation: Integer);
var
  SR: TSearchRec;
  LocalFileList: TStringList;
  FileExt: string;
  i: Integer;
  FilePath: string;

  // Per-file working variables
  JamFile: TJamFile;
  HWJamFile: THWJamFile;
  Thumb: TBitmap;
  Node: TJamBrowseNode;
  Item: TEasyItem;
  jamTypeStr: string;
  numTexs: Integer;
  jamPal: TJamType;
  fileData: WIN32_FILE_ATTRIBUTE_DATA;
  SystemTime: TSystemTime;
  LocalFileTime: TFileTime;

  // Saved global state
  SavedPal: array [0 .. 255] of TRGB;
  SavedRcr, SavedJip, SavedGP2, SavedGP3, SavedHW: Boolean;
  SavedLoaded, SavedIssues, SavedUndo, SavedGenPal, SavedModified: Boolean;
  SavedGP2Livery, SavedRCRDraw, SavedTexSelected: Boolean;
  SavedMaxW, SavedMaxH, SavedPalID, SavedSelTex: Integer;
begin
  LocalFileList := TStringList.Create;
  try
    // 1. Scan folder
    if FindFirst(Folder + '\*.*', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory = 0) then
          begin
            FileExt := LowerCase(ExtractFileExt(SR.Name));
            if (FileExt = '.jam') or (FileExt = '.jip') then
              if not SameText(SR.Name, 'shill.jam') then
                LocalFileList.Add(Folder + '\' + SR.Name);
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;

    if LocalFileList.Count = 0 then
      Exit;

    // 2. Save ALL global state before we start mutating it
    for i := 0 to 255 do
      SavedPal[i] := GPXPal[i];
    SavedRcr := boolRcrJam;
    SavedJip := boolJipMode;
    SavedMaxW := intJamMaxWidth;
    SavedMaxH := intJamMaxHeight;
    SavedPalID := intPaletteID;
    SavedGP2 := boolGP2Jam;
    SavedGP3 := boolGP3Jam;
    SavedHW := boolHWJAM;
    SavedLoaded := boolJamLoaded;
    SavedIssues := boolJamIssues;
    SavedUndo := boolUndo;
    SavedGenPal := generatePal;
    SavedModified := boolJamModified;
    SavedGP2Livery := boolGP2Livery;
    SavedRCRDraw := boolRCRDrawMode;
    SavedTexSelected := boolTexSelected;
    SavedSelTex := intSelectedTexture;

    // 3. Init UI
    jamListView.BeginUpdate;
    try
      jamListView.Items.Clear;
      FileList.Assign(LocalFileList);
    finally
      jamListView.EndUpdate;
    end;
    ProgressBar.Max := LocalFileList.Count;
    ProgressBar.Position := 0;
    ProgressBar.Visible := True;
    btnCancel.Visible := True;
    jamLoading.Visible := True;
    FPendingThumbnails := LocalFileList.Count;
    FLoadedThumbnails := 0;

    try
      // 4. Process each file on the main thread with ProcessMessages
      //    for UI responsiveness between files
      for i := 0 to LocalFileList.Count - 1 do
      begin
        // Let UI breathe — handle cancel clicks, repaints, scrolls
        Application.ProcessMessages;

        if cancelJob or (FLoadGeneration <> Generation) then
          Break;

        FilePath := LocalFileList[i];

        // Reset all JAM globals to clean state before each file.
        // Prevents state leaking from one file to the next (e.g. RCR
        // flags persisting from rcr1a into the non-RCR rcr1b).
        boolRcrJam := False;
        boolJipMode := False;
        intJamMaxWidth := 0;
        intJamMaxHeight := 0;

        // Detect palette type
        jamPal := TJamPaletteDetector.Instance.Detect(FilePath, True);

        // Set palette for this file — default to GP2 if unrecognised
        case jamPal of
          jamGP2:
            for numTexs := 0 to 255 do
              GPXPal[numTexs] := Gp2Pal[numTexs];
          jamGP3SW, jamGP3HW:
            for numTexs := 0 to 255 do
              GPXPal[numTexs] := Gp3Pal[numTexs];
        else
          for numTexs := 0 to 255 do
            GPXPal[numTexs] := Gp2Pal[numTexs];
        end;

        // Load JAM and render thumbnail — wrapped in try/except so one
        // bad file doesn't stop the entire browser from loading
        Thumb := nil;
        Node := nil;
        try try
          if isHWJAM(FilePath) then
          begin
            HWJamFile := THWJamFile.Create;
            try
              HWJamFile.LoadFromFile(FilePath);
              Thumb := HWJamFile.DrawCanvas(False);
              jamTypeStr := 'Hardware JAM File';
              numTexs := HWJamFile.FEntries.Count;
            finally
              HWJamFile.Free;
            end;
          end
          else
          begin
            JamFile := TJamFile.Create;
            try
              JamFile.LoadFromFile(FilePath, True);
              Thumb := JamFile.DrawFullJam(False);
              jamTypeStr := IfThen(TPath.GetExtension(FilePath) = '.jip',
                'Software JIP File', 'Software JAM File');
              numTexs := JamFile.FEntries.Count;
            finally
              JamFile.Free;
            end;
          end;

          if not Assigned(Thumb) then
            Continue;

          // Build node
          Node := TJamBrowseNode.Create;
          Node.FileName := FilePath;
          Node.Orig := Thumb;
          Thumb := nil; // ownership transferred to Node
          Node.Thumb := GenerateThumbnail(Node.Orig, ThumbSize, jamListView.Color);
          Node.Height := Node.Orig.Height;
          Node.Width := Node.Orig.Width;
          Node.numTexs := numTexs;
          Node.jamType := jamTypeStr;

          // Read file metadata
          if GetFileAttributesEx(PChar(FilePath), GetFileExInfoStandard,
            @fileData) then
          begin
            Node.size := (Int64(fileData.nFileSizeHigh) shl 32) or
              fileData.nFileSizeLow;

            FileTimeToLocalFileTime(fileData.ftCreationTime, LocalFileTime);
            FileTimeToSystemTime(LocalFileTime, SystemTime);
            Node.dateCreated := SystemTimeToDateTime(SystemTime);

            FileTimeToLocalFileTime(fileData.ftLastWriteTime, LocalFileTime);
            FileTimeToSystemTime(LocalFileTime, SystemTime);
            Node.dateModified := SystemTimeToDateTime(SystemTime);
          end;

          // Add to listview
          Item := jamListView.Items.Add(Node);
          Item.Caption := ExtractFileName(Node.FileName);
          Item.Captions[1] := DateToStr(Node.dateModified);
          Item.Captions[2] := FormatFileSize(Node.size);
          Item.Captions[3] := IntToStr(Node.numTexs);

          Inc(FLoadedThumbnails);
          ProgressBar.Position := FLoadedThumbnails;
          jamLoading.Caption := Format('Loading JAM %d of %d',
            [FLoadedThumbnails, FPendingThumbnails]);

          Node := nil; // ownership transferred to listview

        except
          // Skip files that fail to load — don't crash the browser
          on E: Exception do
          begin
            Inc(FLoadedThumbnails);
            ProgressBar.Position := FLoadedThumbnails;
            jamLoading.Caption := Format('Loading JAM %d of %d',
              [FLoadedThumbnails, FPendingThumbnails]);
          end;
        end;
        finally
          Thumb.Free;
          Node.Free;
        end;
      end;

    finally
      // 5. Restore ALL global state
      for i := 0 to 255 do
        GPXPal[i] := SavedPal[i];
      boolRcrJam := SavedRcr;
      boolJipMode := SavedJip;
      intJamMaxWidth := SavedMaxW;
      intJamMaxHeight := SavedMaxH;
      intPaletteID := SavedPalID;
      boolGP2Jam := SavedGP2;
      boolGP3Jam := SavedGP3;
      boolHWJAM := SavedHW;
      boolJamLoaded := SavedLoaded;
      boolJamIssues := SavedIssues;
      boolUndo := SavedUndo;
      generatePal := SavedGenPal;
      boolJamModified := SavedModified;
      boolGP2Livery := SavedGP2Livery;
      boolRCRDrawMode := SavedRCRDraw;
      boolTexSelected := SavedTexSelected;
      intSelectedTexture := SavedSelTex;

      // 6. Cleanup UI
      ProgressBar.Visible := False;
      jamLoading.Visible := False;
      btnCancel.Visible := False;
      cancelJob := False;
      FCurrentLoadPath := '';
      jamListView.Sort.SortAll;
    end;

  finally
    LocalFileList.Free;
  end;
end;

procedure TJamBrowserFrm.RedrawThumbnails;
var
  i: Integer;
  Node: TJamBrowseNode;
  NewThumb: TBitmap;
  Ratio: Double;
  ThumbW, ThumbH, OffsetX, OffsetY: Integer;
  bgColor: TColor;
const
  PaddingFactor = 0.95;
begin
  bgColor := jamListView.Color;

  jamListView.BeginUpdate;
  try
    for i := 0 to jamListView.Items.Count - 1 do
    begin
      Node := TJamBrowseNode(jamListView.Items[i].data);
      if not Assigned(Node) or not Assigned(Node.Orig) then
        Continue;

      // Fast inline resize — no StretchF, no TempBmp copy, just StretchDraw
      Ratio := Min((ThumbSize * PaddingFactor) / Node.Orig.Width,
        (ThumbSize * PaddingFactor) / Node.Orig.Height);
      ThumbW := Round(Node.Orig.Width * Ratio);
      ThumbH := Round(Node.Orig.Height * Ratio);

      NewThumb := TBitmap.Create;
      NewThumb.PixelFormat := pf24bit;
      NewThumb.SetSize(ThumbSize, ThumbSize);
      NewThumb.Canvas.Brush.Color := bgColor;
      NewThumb.Canvas.FillRect(Rect(0, 0, ThumbSize, ThumbSize));

      OffsetX := (ThumbSize - ThumbW) div 2;
      OffsetY := (ThumbSize - ThumbH) div 2;
      NewThumb.Canvas.StretchDraw(
        Rect(OffsetX, OffsetY, OffsetX + ThumbW, OffsetY + ThumbH),
        Node.Orig);

      FreeAndNil(Node.Thumb);
      Node.Thumb := NewThumb;
    end;
  finally
    jamListView.EndUpdate;
  end;

  jamListView.Invalidate;
end;

procedure TJamBrowserFrm.directoryTreeChange(Sender: TBaseVirtualTree;
Node: PVirtualNode);
begin
  // Selection loading is handled by directoryTreeFocusChanged.
  // This event fires alongside FocusChanged on every click — wiring both
  // caused duplicate background loads that raced each other.
end;

procedure TJamBrowserFrm.RefreshDirectoryTree;
var
  i, DriveCount, Len: Integer;
  DriveMap, Mask: DWORD;
  PreviousPath: string;
begin
  Screen.Cursor := crHourGlass;
  try
    // Store previous selection path before clearing
    PreviousPath := strBrowserPath;

    directoryTree.BeginUpdate;
    try
      // Prevent reentry during update
      directoryTree.Clear;

      // Recalculate drives
      DriveCount := 0;
      DriveMap := GetLogicalDrives;
      Mask := 1;
      for i := 0 to 25 do
      begin
        if (DriveMap and Mask) <> 0 then
          Inc(DriveCount);
        Mask := Mask shl 1;
      end;

      // Refresh drive strings
      Len := GetLogicalDriveStrings(0, nil);
      SetLength(FDriveStrings, Len);
      GetLogicalDriveStrings(Len, PChar(FDriveStrings));

      // Set root nodes (this will cause InitNode to be called)
      directoryTree.RootNodeCount := DriveCount;

    finally
      directoryTree.EndUpdate;
    end;

    // // Navigate after EndUpdate to avoid recursion
    // if DirectoryExists(PreviousPath) then
    // NavigateToPath(directoryTree, PreviousPath);

  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TJamBrowserFrm.directoryTreeCompareNodes(Sender: TBaseVirtualTree;
Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
// The node comparison routine is the heart of the tree sort. Here we have to tell the caller which node we consider
// being "larger" or "smaller".

var
  Data1, Data2: PShellObjectData;

begin
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);

  // Folder are always before files. Check if *both* are folders or *both* are non-folders, but not different.
  if ((Data1.Attributes xor Data2.Attributes) and SFGAO_FOLDER) <> 0 then
  begin
    // One of both is a folder the other is a file.
    if (Data1.Attributes and SFGAO_FOLDER) <> 0 then
      Result := -1
    else
      Result := 1;
  end
  else
    // Both are of same type (folder or file). Just compare captions.
    // Note that we use ANSI comparison, while the strings are Unicode. Since this will implicitely convert the captions
    // to ANSI for comparation it might happen that the sort order is wrong for names which contain text in a language
    // other than the current OS language. A full blown Unicode comparison is beyond the scope of this demo.
    Result := CompareText(Data1.FullPath, Data2.FullPath);
end;

procedure TJamBrowserFrm.directoryTreeDrawNode(Sender: TBaseVirtualTree;
const PaintInfo: TVTPaintInfo);
// This is the main paint routine for a node in a draw tree. There is nothing special here. Demonstrating the
// specific features of a draw tree (compared to the string tree) is a bit difficult, since the only difference is
// that the draw tree does not handle node content (captions in the case of the string tree).

var
  data: PShellObjectData;
  x: Integer;
  S: UnicodeString;
  R: TRect;

begin
  with Sender as TVirtualDrawTree, PaintInfo do
  begin
    data := Sender.GetNodeData(Node);
    Canvas.Lock;
    if (Column = FocusedColumn) and (Selected[Node]) then
      Canvas.Font.Color := clHighlightText
    else if (data.Attributes and SFGAO_COMPRESSED) <> 0 then
      Canvas.Font.Color := clBlue
    else
      Canvas.Font.Color := clWindowText;

    SetBKMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);
    Dec(R.Right);
    Dec(R.Bottom);
    S := '';
    case Column of
      0, 2:
        begin
          if Column = 2 then
          begin
            if Assigned(data.Image) then
              S := data.Properties;
          end
          else
            S := data.Display;
          if Length(S) > 0 then
          begin
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R,
              DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
          end;
        end;
      1:
        begin
          if Assigned(data.Image) then
          begin
            x := ContentRect.Left + (directoryTree.Header.Columns[1].Width -
              data.Image.Width - Margin) div 2;
            BitBlt(Canvas.Handle, x, ContentRect.Top + 2, data.Image.Width,
              data.Image.Height, data.Image.Canvas.Handle, 0, 0, SRCCOPY);
          end;
        end;
    end;
  end;
  Canvas.unlock;
end;

procedure TJamBrowserFrm.directoryTreeFocusChanged(Sender: TBaseVirtualTree;
Node: PVirtualNode; Column: TColumnIndex);
var
  data: PShellObjectData;
begin
  ImagePreview.Picture := nil;

  if not Assigned(Node) then
    Exit;
  data := Sender.GetNodeData(Node);
  if not Assigned(data) then
    Exit;

  if DirectoryExists(data.FullPath) then
  begin
    LoadImagesFromFolderAsync(data.FullPath);
    strBrowserPath := data.FullPath;
  end
  else
    OutputDebugString(PChar('Invalid directory: ' + data.FullPath));
end;

procedure TJamBrowserFrm.directoryTreeFreeNode(Sender: TBaseVirtualTree;
Node: PVirtualNode);
var
  data: PShellObjectData;

begin
  data := Sender.GetNodeData(Node);
  data.Image.Free;
  Finalize(data^); // Clear string data.
end;

procedure TJamBrowserFrm.directoryTreeGetImageIndex(Sender: TBaseVirtualTree;
Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
var Ghosted: Boolean; var Index: TImageIndex);
var
  data: PShellObjectData;

begin
  if Column = 0 then
  begin
    data := Sender.GetNodeData(Node);
    case Kind of
      ikNormal, ikSelected:
        begin
          if Sender.Expanded[Node] then
            Index := data.OpenIndex
          else
            Index := data.CloseIndex;
        end;
      ikOverlay:
        if (data.Attributes and SFGAO_SHARE) <> 0 then
          Index := 0
        else if (data.Attributes and SFGAO_LINK) <> 0 then
          Index := 1;
    end;
  end;
end;

procedure TJamBrowserFrm.directoryTreeGetNodeWidth(Sender: TBaseVirtualTree;
HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
var NodeWidth: TDimension);

// Since the draw tree does not know what is in a cell, we have to return the width of the content (not the entire
// cell width, this could be determined by the column width).

var
  data: PShellObjectData;
  AMargin: Integer;

begin
  with Sender as TVirtualDrawTree do
    AMargin := TextMargin;
  Canvas.Lock;

  begin
    data := Sender.GetNodeData(Node);
    case Column of
      0:
        begin
          if Sender.NodeParent[Node] = nil then
            NodeWidth := Canvas.TextWidth(data.FullPath) + 2 * AMargin
          else
            NodeWidth := Canvas.TextWidth(ExtractFileName(data.FullPath)) + 2
              * AMargin;
        end;
      1:
        begin
          if Assigned(data.Image) then
            NodeWidth := data.Image.Width;
        end;
      2:
        NodeWidth := Canvas.TextWidth(data.Properties) + 2 * AMargin;
    end;
  end;
  Canvas.unlock;
end;

procedure TJamBrowserFrm.directoryTreeInitChildren(Sender: TBaseVirtualTree;
Node: PVirtualNode; var ChildCount: Cardinal);
// Called just before a node with children (only folder nodes can have children) is expanded.

var
  data, ChildData: PShellObjectData;
  SR: TSearchRec;
  ChildNode: PVirtualNode;
  NewName: String;

begin
  data := Sender.GetNodeData(Node);
  if FindFirst(IncludeTrailingPathDelimiter(data.FullPath) + '*.*', faAnyFile, SR) = 0
  then
  begin
    Screen.Cursor := crHourGlass;
    Sender.BeginUpdate;
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          NewName := IncludeTrailingPathDelimiter(data.FullPath) + SR.Name;
          if (SR.Attr and faDirectory <> 0) or CanDisplay(NewName) then
          begin
            ChildNode := Sender.AddChild(Node);
            ChildData := Sender.GetNodeData(ChildNode);
            ChildData.FullPath := NewName;
            ChildData.Attributes := ReadAttributes(NewName);
            if (ChildData.Attributes and SFGAO_FOLDER) = 0 then
              ChildData.Properties := Format('%n KB, ', [SR.size / 1024]);
            GetOpenAndClosedIcons(ChildData.FullPath, ChildData.OpenIndex,
              ChildData.CloseIndex);

            // Sender.ValidateNode(Node, false);
            Inc(ChildCount);
          end;
        end;
      until FindNext(SR) <> 0;

      // finally sort node
      Sender.Sort(Node, 0, TVirtualStringTree(Sender)
        .Header.SortDirection, False);
    finally
      Sender.EndUpdate;
      FindClose(SR);
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TJamBrowserFrm.directoryTreeInitNode(Sender: TBaseVirtualTree;
ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  data: PShellObjectData;
  Picture: TPicture;

begin
  data := Sender.GetNodeData(Node);
  if ParentNode = nil then
  begin
    // top level node, initialize first enumeration
    data.FullPath := GetDriveString(Node.Index);
    data.Display := data.FullPath;
    GetOpenAndClosedIcons(data.FullPath, data.OpenIndex, data.CloseIndex);
  end
  else
  begin
    data.Display := ExtractFileName(ExcludeTrailingPathDelimiter(data.FullPath));
    if (data.Attributes and SFGAO_FOLDER) = 0 then
    begin
      Picture := TPicture.Create;
      try
        try
          data.Image := TBitmap.Create;
          Picture.LoadFromFile(data.FullPath);
          if not(Picture.Graphic is TBitmap) then
          begin
            // Some extra steps needed to keep non TBitmap descendants alive when
            // scaling. This is needed because when accessing Picture.Bitmap all
            // non-TBitmap content will simply be erased (definitely the wrong
            // action, but we can't do anything to prevent this). Hence we
            // must explicitly draw the graphic to a bitmap.
            with data.Image do
            begin
              Canvas.Lock;
              Width := Picture.Width;
              Height := Picture.Height;
              Canvas.Draw(0, 0, Picture.Graphic);
              Canvas.unlock;
            end;
            Picture.Bitmap.Assign(data.Image);
          end;
          // RescaleImage(Picture.Bitmap, Data.Image);

          // Collect some additional image properties.
          data.Properties := data.Properties + Format('%d x %d pixels',
            [Picture.Width, Picture.Height]);
          case Picture.Bitmap.PixelFormat of
            pf1bit:
              data.Properties := data.Properties + ', 2 colors';
            pf4bit:
              data.Properties := data.Properties + ', 16 colors';
            pf8bit:
              data.Properties := data.Properties + ', 256 colors';
            pf15bit:
              data.Properties := data.Properties + ', 32K colors';
            pf16bit:
              data.Properties := data.Properties + ', 64K colors';
            pf24bit:
              data.Properties := data.Properties + ', 16M colors';
            pf32bit:
              data.Properties := data.Properties + ', 16M+ colors';
          end;
          if data.Image.Height + 4 > TVirtualDrawTree(Sender).DefaultNodeHeight
          then
            Sender.NodeHeight[Node] := data.Image.Height + 4;
        except
          data.Image.Free;
          data.Image := nil;
        end;
      finally
        Picture.Free;
      end; // try..finally
    end; // if
  end; // else
  data.Attributes := ReadAttributes(data.FullPath);
  if ((data.Attributes and SFGAO_HASSUBFOLDER) <> 0) or
    (((data.Attributes and SFGAO_FOLDER) <> 0) and HasChildren(data.FullPath))
  then
    Include(InitialStates, ivsHasChildren);

end;

/// finds among Parent’s immediate children a node whose Data.FullPath
/// (minus any trailing slash) matches TargetPath (minus any trailing slash)
function TJamBrowserFrm.FindChildNodeByPath(Tree: TVirtualDrawTree;
Parent: PVirtualNode; const TargetPath: UnicodeString): PVirtualNode;
var
  Child: PVirtualNode;
  data: PShellObjectData;
  normTarget: string;
begin
  Result := nil;
  normTarget := ExcludeTrailingPathDelimiter(TargetPath);
  Child := Tree.GetFirstChild(Parent);
  while Assigned(Child) do
  begin
    data := Tree.GetNodeData(Child);
    if SameText(ExcludeTrailingPathDelimiter(data.FullPath), normTarget) then
    begin
      Result := Child;
      Exit;
    end;
    Child := Tree.GetNextSibling(Child);
  end;
end;

procedure TJamBrowserFrm.SortJams(i: Integer; order: Boolean);
var
  PreviousFocusedColumn: TEasyColumn;
  PreviousOrder: TEasySortDirection;
begin
  jamListView.BeginUpdate;
  PreviousFocusedColumn := jamListView.Selection.FocusedColumn;
  PreviousOrder := jamListView.Selection.FocusedColumn.SortDirection;

  jamListView.Selection.FocusedColumn := jamListView.Header.Columns.Columns[i];

  jamListView.Selection.FocusedColumn.SortDirection := PreviousOrder;

  PreviousFocusedColumn.SortDirection := esdNone;

  jamListView.Sort.ReGroup(jamListView.Selection.FocusedColumn);

  jamListView.Sort.SortAll();
  jamListView.EndUpdate();
end;

procedure TJamBrowserFrm.Name1Click(Sender: TObject);
begin
  SortJams(0, true);
  Name1.Checked := true;

  Date1.Checked := False;
  Size1.Checked := False;
  NumberofTextures1.Checked := False;
end;

function TJamBrowserFrm.NavigateToPath(Tree: TVirtualDrawTree;
const Path: UnicodeString): Boolean;
var
  parts: TStringList;
  i: Integer;
  cumulative: string;
  currNode: PVirtualNode;
  nodeData: PShellObjectData;
begin
  Result := False;
  if not DirectoryExists(Path) then
    Exit;

  parts := TStringList.Create;
  try
    ExtractStrings([PathDelim], [], PChar(Path), parts);
    if parts.Count = 0 then
      Exit;

    Tree.BeginUpdate;
    try
      cumulative := '';
      currNode := nil;

      for i := 0 to parts.Count - 1 do
      begin
        // Rebuild the path incrementally
        if i = 0 then
          cumulative := parts[i] + PathDelim
        else
          cumulative := IncludeTrailingPathDelimiter(cumulative) + parts[i];

        if i = 0 then
          currNode := FindChildNodeByPath(Tree, nil, cumulative)
        else
        begin
          if not Assigned(currNode) then
            Exit;

          // Only validate if not already initialized
          if not(vsInitialized in currNode.States) then
            Tree.ValidateNode(currNode, true);

          // Only expand if not already expanded
          if not Tree.Expanded[currNode] then
            Tree.Expanded[currNode] := true;

          currNode := FindChildNodeByPath(Tree, currNode, cumulative);
        end;

        if not Assigned(currNode) then
          Exit;
      end;

      // Select final node
      Tree.ClearSelection;
      Tree.FocusedNode := currNode;
      Tree.Selected[currNode] := true;
      Tree.ScrollIntoView(currNode, true);
      Tree.Invalidate;

      // Update current path
      nodeData := Tree.GetNodeData(currNode);
      if Assigned(nodeData) then
        strBrowserPath := nodeData.FullPath;

      Result := true;
    finally
      Tree.EndUpdate;
    end;
  finally
    parts.Free;
  end;
end;

procedure TJamBrowserFrm.NumberofTextures1Click(Sender: TObject);
begin
  SortJams(3, true);
  Name1.Checked := False;
  Date1.Checked := False;
  Size1.Checked := False;
  NumberofTextures1.Checked := true;
end;

procedure TJamBrowserFrm.PopupMenu1Popup(Sender: TObject);
begin
  if jamListView.Selection.FocusedColumn.SortDirection = esdAscending then
    Ascending1.Checked := true
  else
    Ascending1.Checked := False;

  if jamListView.Selection.FocusedColumn.SortDirection = esdDescending then
    Descending1.Checked := true
  else
    Descending1.Checked := False;

end;

function TJamBrowserFrm.GetNodeParent(Node: PVirtualNode): PVirtualNode;
begin
  if Assigned(Node) and (Node.Parent <> directoryTree.RootNode) then
    Result := Node.Parent
  else
    Result := nil;
end;

procedure TJamBrowserFrm.thumbnails1Click(Sender: TObject);
begin
  jamListView.View := elsThumbnail;
  thumbnails1.Checked := true;
  Details1.Checked := False;
end;

procedure TJamBrowserFrm.ClearPreview();
begin

  ImagePreview.Picture := nil;

  lblJamType.visible := False;
  lblFilename.visible := False;
  lblDimensions.visible := False;
  lblTexs.visible := False;

end;

procedure TJamBrowserFrm.Date1Click(Sender: TObject);
begin
  SortJams(1, true);
  Name1.Checked := False;
  Date1.Checked := true;
  Size1.Checked := False;
  NumberofTextures1.Checked := False;
end;

procedure TJamBrowserFrm.Descending1Click(Sender: TObject);
begin
  jamListView.Selection.FocusedColumn.SortDirection := esdDescending
end;

procedure TJamBrowserFrm.Details1Click(Sender: TObject);
begin
  jamListView.View := elsReport;

  thumbnails1.Checked := False;
  Details1.Checked := true;
end;

end.
