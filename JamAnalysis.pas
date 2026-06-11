unit JamAnalysis;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils,
  System.StrUtils, System.Classes, System.IOUtils, System.Math,
  System.Win.Registry, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Clipbrd,
  MPCommonObjects, EasyListview,
  JamSW, JamHW, JamPalette, JamGeneral, jamPaletteDetector;

type

  TJamItem = class
    Path: string;
    JamInfo: TJamEntryInfo;
    Thumb: TBitmap;
    JamType: string;
    destructor Destroy; override;
  end;

  PJamItem = ^TJamItem;

  TfrmJamAnalysis = class(TForm)
    // Layout panels
    Splitter1: TSplitter;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBarPanel: TPanel;

    // ListView
    jamlistview: TEasyListview;

    // Preview panel
    GroupBox1: TGroupBox;
    texPreview: TImage;

    // Scan controls
    scanGroup: TGroupBox;
    Label1: TLabel;
    strFolder: TEdit;
    btnBrowseFolder: TButton;
    optionsGroup: TGroupBox;
    chkSubfolders: TCheckBox;
    chkSoftware: TCheckBox;
    chkHardware: TCheckBox;
    chkClearList: TCheckBox;
    btnScanGP2: TButton;
    btnScanGP3: TButton;
    scanGP32K: TButton;
    btnScanFolder: TButton;

    // Status strip
    btnCancel: TButton;
    ProgressBar: TProgressBar;
    jamLoading: TLabel;

    // Popup
    jamAnalysisPopup: TPopupMenu;
    mnuOpenFolder: TMenuItem;
    mnuCopyPath: TMenuItem;
    N1: TMenuItem;
    mnuClearList: TMenuItem;

    // Form / scan handlers
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnScanFolderClick(Sender: TObject);
    procedure btnScanGP2Click(Sender: TObject);
    procedure btnScanGP3Click(Sender: TObject);
    procedure scanGP32KClick(Sender: TObject);
    procedure Button1Click(Sender: TObject); // Cancel
    procedure Button2Click(Sender: TObject); // Browse
    procedure strFolderChange(Sender: TObject);

    // ListView handlers
    procedure jamlistviewItemImageDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
      const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    function jamlistviewItemCompare(Sender: TCustomEasyListview;
      Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem;
      var DoDefault: Boolean): Integer;
    procedure jamlistviewItemFreeing(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure jamlistviewItemSelectionChanged(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure jamlistviewItemImageDrawIsCustom(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; var IsCustom: Boolean);
    procedure jamlistviewDblClick(Sender: TObject);

    // Popup handlers
    procedure jamAnalysisPopupPopup(Sender: TObject);
    procedure mnuOpenFolderClick(Sender: TObject);
    procedure mnuCopyPathClick(Sender: TObject);
    procedure mnuClearListClick(Sender: TObject);

  private
    // Set by Cancel button; read in the scan loop between files. Same
    // atomic-Boolean pattern as JamBatch: a single flag, one writer, one
    // reader, sees-ish isn't a problem because the worst case is a one-
    // iteration delay before the loop notices.
    FCancelRequested: Boolean;
    // True while a scan is in progress; UpdateUIState uses it to gate
    // every control that shouldn't be touched mid-scan.
    FScanRunning: Boolean;
    // Running totals for the summary line shown after a scan finishes.
    FFilesScanned: Integer;
    FTexturesFound: Integer;
    FFailedFiles: Integer;
    FLastSummary: string;
    // Cached last-selected item, updated by OnItemSelectionChanged. We
    // keep this because the EasyListview selection API varies by version,
    // and the event already hands us the item we need.
    FSelectedItem: TEasyItem;

    procedure UpdateUIState;
    procedure RunScan(const Folder: string; Subfolders: Boolean);
    procedure AddFileToListview(const FilePath: string);
    function ShouldSkipFile(const FilePath: string): Boolean;
    function MakeThumbnail(Source: TBitmap): TBitmap;
    function LoadAnalysisFolder: string;
    procedure SaveAnalysisFolder(const Folder: string);
    function SelectedJamItem: TJamItem;

  public
    // Kept public for any external caller that referenced it. Not used
    // internally any more.
    FileList: TStringList;
  end;

var
  frmJamAnalysis: TfrmJamAnalysis;

implementation

uses
  mainform; // for FormMain.LoadJam on double-click — implementation-uses
            // avoids a circular reference (mainform uses JamAnalysis too)

{$R *.dfm}

const
  AnalysisRegValue = 'AnalysisCustomPath';
  // Cap the per-item thumbnail resolution. Each TBitmap eats a GDI handle,
  // and Windows limits us to ~10,000 per process. A 500-file scan with
  // ~20 textures/file puts us right at that limit if we stored full-res.
  // 256px is a good balance: big enough for the preview pane (which is
  // 264x248) with minimal upscale blur, small enough to keep thousands of
  // thumbs comfortably in memory at pf24bit.
  THUMB_MAX_SIZE = 256;

// ============================================================================
// TJamItem
// ============================================================================

destructor TJamItem.Destroy;
begin
  FreeAndNil(Thumb);
  inherited;
end;

// ============================================================================
// Form lifecycle
// ============================================================================

procedure TfrmJamAnalysis.FormCreate(Sender: TObject);
begin
  FileList := TStringList.Create;
  FCancelRequested := False;
  FScanRunning := False;
  FFilesScanned := 0;
  FTexturesFound := 0;
  FLastSummary := '';
  FSelectedItem := nil;
end;

procedure TfrmJamAnalysis.FormDestroy(Sender: TObject);
begin
  // If a scan is in flight, cue it to cancel and drain the message pump
  // so the scan loop exits before we tear the form down — otherwise the
  // in-progress AddFileToListview would touch a destroyed listview.
  FCancelRequested := True;
  while FScanRunning do
    Application.ProcessMessages;
  jamlistview.Items.Clear;
  FileList.Free;
end;

procedure TfrmJamAnalysis.FormShow(Sender: TObject);
var
  lastFolder: string;
begin
  lastFolder := LoadAnalysisFolder;
  if lastFolder <> '' then
    strFolder.Text := lastFolder;
  jamLoading.Caption := 'Ready';
  UpdateUIState;
end;

// ============================================================================
// UI state
// ============================================================================

procedure TfrmJamAnalysis.UpdateUIState;
var
  hasFolder, atLeastOneType: Boolean;
begin
  hasFolder := Trim(strFolder.Text) <> '';
  atLeastOneType := chkSoftware.Checked or chkHardware.Checked;

  // While scanning, everything except Cancel is locked down so the user
  // can't kick off a second scan, change options, or edit the folder path
  // mid-run.
  btnCancel.Enabled       := FScanRunning;
  btnScanGP2.Enabled      := (not FScanRunning) and atLeastOneType;
  btnScanGP3.Enabled      := (not FScanRunning) and atLeastOneType;
  scanGP32K.Enabled       := (not FScanRunning) and atLeastOneType;
  btnScanFolder.Enabled   := (not FScanRunning) and atLeastOneType and hasFolder;
  btnBrowseFolder.Enabled := not FScanRunning;
  strFolder.Enabled       := not FScanRunning;
  chkSubfolders.Enabled   := not FScanRunning;
  chkSoftware.Enabled     := not FScanRunning;
  chkHardware.Enabled     := not FScanRunning;
  chkClearList.Enabled    := not FScanRunning;
end;

procedure TfrmJamAnalysis.strFolderChange(Sender: TObject);
begin
  UpdateUIState;
end;

// ============================================================================
// Registry persistence for the last-used custom folder
// ============================================================================

function TfrmJamAnalysis.LoadAnalysisFolder: string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(baseKeyPath) then
    try
      if Reg.ValueExists(AnalysisRegValue) then
        Result := Reg.ReadString(AnalysisRegValue);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  // If the saved folder no longer exists, fall back to empty so the dialog
  // opens at the system default rather than refusing to show.
  if (Result <> '') and not DirectoryExists(Result) then
    Result := '';
end;

procedure TfrmJamAnalysis.SaveAnalysisFolder(const Folder: string);
var
  Reg: TRegistry;
begin
  if Folder = '' then Exit;
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(baseKeyPath, True) then
    try
      Reg.WriteString(AnalysisRegValue, Folder);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

// ============================================================================
// Scan entry points
// ============================================================================

procedure TfrmJamAnalysis.btnScanFolderClick(Sender: TObject);
var
  folder: string;
begin
  folder := Trim(strFolder.Text);
  if folder = '' then
  begin
    ShowMessage('Please select a folder to scan.');
    Exit;
  end;
  if not DirectoryExists(folder) then
  begin
    ShowMessage('Directory does not exist: ' + folder);
    Exit;
  end;
  if not (chkSoftware.Checked or chkHardware.Checked) then
  begin
    ShowMessage('Select whether to scan for software and/or hardware JAMs.');
    Exit;
  end;
  SaveAnalysisFolder(folder);
  RunScan(folder, chkSubfolders.Checked);
end;

procedure TfrmJamAnalysis.btnScanGP2Click(Sender: TObject);
begin
  if not (chkSoftware.Checked or chkHardware.Checked) then
  begin
    ShowMessage('Select whether to scan for software and/or hardware JAMs.');
    Exit;
  end;
  if strGP2Location.Length = 0 then
  begin
    ShowMessage('GP2 location not defined - go to Options to set it.');
    Exit;
  end;
  RunScan(strGP2Location, chkSubfolders.Checked);
end;

procedure TfrmJamAnalysis.btnScanGP3Click(Sender: TObject);
begin
  if not (chkSoftware.Checked or chkHardware.Checked) then
  begin
    ShowMessage('Select whether to scan for software and/or hardware JAMs.');
    Exit;
  end;
  if strGP3Location.Length = 0 then
  begin
    ShowMessage('GP3 location not defined - go to Options to set it.');
    Exit;
  end;
  RunScan(strGP3Location, chkSubfolders.Checked);
end;

procedure TfrmJamAnalysis.scanGP32KClick(Sender: TObject);
begin
  if not (chkSoftware.Checked or chkHardware.Checked) then
  begin
    ShowMessage('Select whether to scan for software and/or hardware JAMs.');
    Exit;
  end;
  if strGP32kLocation.Length = 0 then
  begin
    ShowMessage('GP3 2000 location not defined - go to Options to set it.');
    Exit;
  end;
  RunScan(strGP32kLocation, chkSubfolders.Checked);
end;

procedure TfrmJamAnalysis.Button1Click(Sender: TObject);
// Cancel. The scan loop sees FCancelRequested between files and breaks.
begin
  FCancelRequested := True;
  btnCancel.Enabled := False;
  jamLoading.Caption := jamLoading.Caption + ' - cancelling...';
end;

procedure TfrmJamAnalysis.Button2Click(Sender: TObject);
// Browse for a custom scan folder. Seeds from last-used via the registry.
var
  dlg: TFileOpenDialog;
  pickedDir: string;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select folder to scan for JAMs';
    dlg.DefaultFolder := LoadAnalysisFolder;
    if not dlg.Execute then Exit;
    pickedDir := dlg.FileName;
    strFolder.Text := pickedDir;
    SaveAnalysisFolder(pickedDir);
    UpdateUIState;
  finally
    dlg.Free;
  end;
end;

// ============================================================================
// Scan loop
// ============================================================================

function TfrmJamAnalysis.ShouldSkipFile(const FilePath: string): Boolean;
// A few specific JAMs are known to crash the loader. Historically these
// were hard-coded to be skipped; preserving the same list so scans keep
// behaving as they did.
var
  fn: string;
begin
  fn := LowerCase(TPath.GetFileName(FilePath));
  Result :=
       (fn = 'barm.jam')
    or (fn = 'bars.jam')
    or (fn = 'hun_s1.jam')
    or (fn = 'mhill.jam')
    or (fn = 'shill.jam');
end;

procedure TfrmJamAnalysis.RunScan(const Folder: string; Subfolders: Boolean);
// Synchronous main-thread scan loop. Using Application.ProcessMessages
// rather than TTask.Run because:
//   - TBitmap.Canvas.Draw (used per thumbnail) calls GDI, which is
//     thread-affine;
//   - the conversion code path still touches shared palette globals
//     (GPXPal), so moving files off the UI thread risks corruption from
//     any editor window touching the same globals concurrently.
// True parallelism is a separate refactor — same call we made in JamBatch.
var
  files: TArray<string>;
  opt: TSearchOption;
  i: Integer;
  palBackup: array [0..255] of TRGB;
  savedAutoSort: Boolean;
  lastUIUpdateTick, nowTick: Cardinal;
begin
  if FScanRunning then Exit; // Re-entry safety.

  if Subfolders then
    opt := TSearchOption.soAllDirectories
  else
    opt := TSearchOption.soTopDirectoryOnly;

  try
    files := TDirectory.GetFiles(Folder, '*.jam', opt);
  except
    on E: Exception do
    begin
      ShowMessage('Failed to enumerate folder: ' + E.Message);
      Exit;
    end;
  end;

  if chkClearList.Checked then
    jamlistview.Items.Clear;

  if Length(files) = 0 then
  begin
    jamLoading.Caption := 'No JAM files found in that folder.';
    FLastSummary := jamLoading.Caption;
    Exit;
  end;

  // Keep a reference for any external caller that still looks at FileList
  // (not used internally any more).
  FileList.Clear;
  FileList.AddStrings(files);

  // Back up the global palette so any crash or early-exit below can
  // restore it cleanly in the finally block.
  for i := 0 to 255 do
    palBackup[i] := GPXPal[i];

  FScanRunning := True;
  FCancelRequested := False;
  FFilesScanned := 0;
  FTexturesFound := 0;
  FFailedFiles := 0;
  ProgressBar.Max := Length(files);
  ProgressBar.Position := 0;
  ProgressBar.Visible := True;
  jamLoading.Visible := True;
  jamLoading.Caption := Format('Scanning 0 / %d', [Length(files)]);
  UpdateUIState;

  // *** Performance: disable AutoSort during the scan ***
  //
  // The DFM has Sort.AutoSort = True, so every Items.Add triggers a full
  // re-sort of all existing items. That's O(N log N) per insertion, turning
  // N insertions into O(N^2 log N) — a 10k-item scan spends billions of
  // comparisons before even showing a row. We toggle AutoSort off, let the
  // scan run linearly, then do a single SortAll at the end.
  savedAutoSort := jamlistview.Sort.AutoSort;
  jamlistview.Sort.AutoSort := False;

  // Freeze the listview while batch-inserting — otherwise every Add queues
  // repaint/layout messages that the ProcessMessages pump would service.
  jamlistview.BeginUpdate;

  // Throttle progress UI updates to a few per second rather than per-file.
  // Each Caption/Position assignment invalidates + repaints the control,
  // which competes with the scan work. GetTickCount is fine here — we
  // only care about wall-clock elapsed milliseconds.
  lastUIUpdateTick := 0;

  try
    try
      for i := 0 to High(files) do
      begin
        if FCancelRequested then Break;

        if not ShouldSkipFile(files[i]) then
          AddFileToListview(files[i]);

        Inc(FFilesScanned);

        // Update the progress bar + label + pump messages at most every
        // ~80 ms. This gives a smooth bar, keeps Cancel responsive, but
        // doesn't flood the message queue when files parse quickly.
        nowTick := GetTickCount;
        if (nowTick - lastUIUpdateTick > 80) or
           (i = High(files)) then
        begin
          ProgressBar.Position := FFilesScanned;
          jamLoading.Caption := Format('Scanning %d / %d (%d textures)',
            [FFilesScanned, Length(files), FTexturesFound]);
          Application.ProcessMessages;
          lastUIUpdateTick := nowTick;
        end;
      end;
    except
      on E: Exception do
        OutputDebugString(PChar(Format('JamAnalysis: scan error: %s',
          [E.Message])));
    end;
  finally
    // EndUpdate first so SortAll's redraw is already suppressed.
    jamlistview.EndUpdate;

    // Restore the palette globals no matter how we got here.
    for i := 0 to 255 do
      GPXPal[i] := palBackup[i];

    // One sort at the end, then re-enable AutoSort for user-driven
    // column clicks.
    jamlistview.Sort.SortAll;
    jamlistview.Sort.AutoSort := savedAutoSort;

    if FCancelRequested then
      FLastSummary := Format(
        'Cancelled: %d files scanned, %d textures found (%d failed)',
        [FFilesScanned, FTexturesFound, FFailedFiles])
    else if FFailedFiles > 0 then
      FLastSummary := Format(
        'Done: %d files scanned, %d textures found (%d failed)',
        [FFilesScanned, FTexturesFound, FFailedFiles])
    else
      FLastSummary := Format('Done: %d files scanned, %d textures found',
        [FFilesScanned, FTexturesFound]);

    ProgressBar.Visible := False;
    jamLoading.Caption := FLastSummary;
    jamLoading.Visible := True;
    FScanRunning := False;
    UpdateUIState;
  end;
end;

// ============================================================================
// Per-file handler - all on UI thread because TBitmap.Canvas.Draw is GDI
// ============================================================================

function TfrmJamAnalysis.MakeThumbnail(Source: TBitmap): TBitmap;
// Produce a fixed-max-size thumbnail copy of Source, preserving aspect
// ratio. Uses pf24bit so each thumb is 3 bytes/pixel rather than 4 (the
// default pfDevice is pf32bit on modern Windows, which wastes 33% of the
// memory on a non-existent alpha channel we don't use).
//
// Scaling once here is much cheaper overall than letting the listview
// rescale a multi-megabyte source to its 112x135 thumb cell on every
// repaint. It also lets us cap total memory + GDI-handle usage so big
// scans don't exhaust Windows' per-process GDI limit.
var
  scale: Double;
  w, h: Integer;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf24bit;
    if (Source = nil) or (Source.Width <= 0) or (Source.Height <= 0) then
    begin
      Result.SetSize(1, 1);
      Exit;
    end;

    // Never upscale — if the source is already small, keep it as-is.
    scale := THUMB_MAX_SIZE / Max(Source.Width, Source.Height);
    if scale >= 1 then
    begin
      Result.SetSize(Source.Width, Source.Height);
      Result.Canvas.Draw(0, 0, Source);
    end
    else
    begin
      w := Max(1, Round(Source.Width * scale));
      h := Max(1, Round(Source.Height * scale));
      Result.SetSize(w, h);
      Result.Canvas.StretchDraw(Rect(0, 0, w, h), Source);
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmJamAnalysis.AddFileToListview(const FilePath: string);
var
  JamFile: TJamFile;
  HWJamFile: THWJamFile;
  Node: TJamItem;
  JamType: string;
  Item: TEasyItem;
  i, j, k: Integer;
  info: TJamQuickInfo;
begin
  // Single-pass probe: one file open for the magic + palette-type guess,
  // instead of the old isHWJAM -> Detect pair which opened the file
  // multiple times per scanned JAM.
  info := QuickInspectJam(FilePath);
  if not info.Exists then Exit;

  try
    if info.IsHW then
    begin
      if not chkHardware.Checked then Exit;
      HWJamFile := THWJamFile.Create;
      try
        HWJamFile.LoadFromFile(FilePath);
        JamType := 'Hardware JAM File';
        for j := 0 to HWJamFile.FHeader.NumItems - 1 do
        begin
          // Per-entry try/except: if thumbnail creation or Items.Add
          // throws on a single bad entry, don't leak Node and don't
          // abort the rest of the file.
          Node := TJamItem.Create;
          try
            Node.Path := FilePath;
            Node.JamType := JamType;
            Node.JamInfo.X := HWJamFile.FEntries[j].FInfo.X;
            Node.JamInfo.Y := HWJamFile.FEntries[j].FInfo.Y;
            Node.JamInfo.Height := HWJamFile.FEntries[j].FInfo.Height;
            Node.JamInfo.JamId := HWJamFile.FEntries[j].FInfo.JamId;
            Node.JamInfo.JamFlags := HWJamFile.FEntries[j].FInfo.JamFlags;

            Node.Thumb := MakeThumbnail(HWJamFile.FEntries[j].FTexture);

            Item := jamlistview.Items.Add(Node);
          except
            Node.Free;
            OutputDebugString(PChar(Format(
              'JamAnalysis: bad entry %d in %s', [j, FilePath])));
            Continue;
          end;

          Item.Captions[1]  := Node.Path;
          Item.Captions[2]  := IntToStr(Node.JamInfo.JamId);
          Item.Captions[3]  := IntToStr(Node.JamInfo.ImagePtr);
          Item.Captions[4]  := IntToStr(Node.JamInfo.PaletteSizeDiv4);
          for k := 0 to 15 do
            Item.Captions[5 + k] :=
              IntToStr(Ord(UnPackFlag(Node.JamInfo.JamFlags, k)));
          Item.Captions[21] := IntToStr(Node.JamInfo.scaleX);
          Item.Captions[22] := IntToStr(Node.JamInfo.scaley);
          Item.Captions[23] := IntToStr(Node.JamInfo.scaleFactor);
          for k := 0 to 7 do
            Item.Captions[24 + k] :=
              IntToStr(Ord(UnPackFlag(Node.JamInfo.scaleFlag, k)));

          Inc(FTexturesFound);
        end;
      finally
        HWJamFile.Free;
      end;
    end
    else
    begin
      if not chkSoftware.Checked then Exit;
      JamFile := TJamFile.Create;
      try
        // Palette type came from QuickInspectJam up top — no extra disk
        // read needed here.
        case info.PaletteType of
          jamGP2:
            for i := 0 to 255 do GPXPal[i] := Gp2Pal[i];
          jamGP3SW:
            for i := 0 to 255 do GPXPal[i] := Gp3Pal[i];
        end;

        JamFile.LoadFromFile(FilePath, True);
        JamType := IfThen(TPath.GetExtension(FilePath) = '.jip',
          'Software JIP File', 'Software JAM File');

        for j := 0 to JamFile.FHeader.NumItems - 1 do
        begin
          Node := TJamItem.Create;
          try
            Node.Path := FilePath;
            Node.JamType := JamType;
            Node.JamInfo := JamFile.FEntries[j].FInfo;
            Node.Thumb := MakeThumbnail(JamFile.FEntries[j].FTexture);
            Item := jamlistview.Items.Add(Node);
          except
            Node.Free;
            OutputDebugString(PChar(Format(
              'JamAnalysis: bad entry %d in %s', [j, FilePath])));
            Continue;
          end;

          Item.Captions[1]  := Node.Path;
          Item.Captions[2]  := IntToStr(Node.JamInfo.JamId);
          Item.Captions[3]  := IntToStr(JamFile.FHeader.jamtotalheight);
          Item.Captions[4]  := IntToStr(Node.JamInfo.PaletteSizeDiv4);
          for k := 0 to 15 do
            Item.Captions[5 + k] :=
              IntToStr(Ord(UnPackFlag(Node.JamInfo.JamFlags, k)));
          Item.Captions[21] := IntToStr(Node.JamInfo.scaleX);
          Item.Captions[22] := IntToStr(Node.JamInfo.scaley);
          Item.Captions[23] := IntToStr(Node.JamInfo.scaleFactor);
          for k := 0 to 7 do
            Item.Captions[24 + k] :=
              IntToStr(Ord(UnPackFlag(Node.JamInfo.scaleFlag, k)));
          Item.Captions[32] := IntToStr(Node.JamInfo.Unk);
          Item.Captions[33] := IntToStr(Node.JamInfo.Idx0E);
          for k := 0 to 7 do
            Item.Captions[k + 34] := IntToStr(Node.JamInfo.Idx18[k]);

          Inc(FTexturesFound);
        end;
      finally
        JamFile.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      Inc(FFailedFiles);
      OutputDebugString(PChar(Format('JamAnalysis: skipping %s (%s)',
        [FilePath, E.Message])));
    end;
  end;
end;

// ============================================================================
// ListView event handlers
// ============================================================================

function TfrmJamAnalysis.jamlistviewItemCompare(Sender: TCustomEasyListview;
  Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem;
  var DoDefault: Boolean): Integer;
var
  val1, val2: Integer;
begin
  Result := 0;
  if Column.Index > 0 then
  begin
    val1 := StrToIntDef(Item1.Captions[Column.Index], 0);
    val2 := StrToIntDef(Item2.Captions[Column.Index], 0);
    Result := CompareValue(val1, val2);
    if Column.SortDirection = esdDescending then
      Result := -Result;
    DoDefault := False;
  end
  else
    DoDefault := True;
end;

procedure TfrmJamAnalysis.jamlistviewItemFreeing(Sender: TCustomEasyListview;
  Item: TEasyItem);
begin
  if Item = FSelectedItem then
    FSelectedItem := nil;
  if Assigned(Item.Data) then
  begin
    TJamItem(Item.Data).Free;
    Item.Data := nil;
  end;
end;

procedure TfrmJamAnalysis.jamlistviewItemImageDraw(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
  const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  img: TBitmap;
begin
  if not Assigned(Item.Data) then Exit;
  img := TJamItem(Item.Data).Thumb;
  if img <> nil then
    AlphaBlender.Blend(Sender, Item, ACanvas, RectArray.IconRect, img);
end;

procedure TfrmJamAnalysis.jamlistviewItemImageDrawIsCustom
  (Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := True;
end;

procedure TfrmJamAnalysis.jamlistviewItemSelectionChanged
  (Sender: TCustomEasyListview; Item: TEasyItem);
begin
  FSelectedItem := Item;
  if Assigned(Item) and Assigned(Item.Data) then
    texPreview.Picture.Bitmap := TJamItem(Item.Data).Thumb;
end;

procedure TfrmJamAnalysis.jamlistviewDblClick(Sender: TObject);
// Load the double-clicked JAM into the main editor. FormMain.LoadJam
// handles both HW and SW formats internally.
var
  itm: TJamItem;
begin
  if FScanRunning then Exit; // don't thrash the loader during a scan
  itm := SelectedJamItem;
  if (itm = nil) or not FileExists(itm.Path) then Exit;
  FormMain.LoadJam(itm.Path);
  FormMain.BringToFront;
end;

// ============================================================================
// Popup menu
// ============================================================================

function TfrmJamAnalysis.SelectedJamItem: TJamItem;
begin
  Result := nil;
  if (FSelectedItem <> nil) and Assigned(FSelectedItem.Data) then
    Result := TJamItem(FSelectedItem.Data);
end;

procedure TfrmJamAnalysis.jamAnalysisPopupPopup(Sender: TObject);
var
  hasSel, hasItems: Boolean;
begin
  hasSel := SelectedJamItem <> nil;
  hasItems := jamlistview.Items.Count > 0;
  mnuOpenFolder.Enabled := hasSel and not FScanRunning;
  mnuCopyPath.Enabled   := hasSel;
  mnuClearList.Enabled  := hasItems and not FScanRunning;
end;

procedure TfrmJamAnalysis.mnuOpenFolderClick(Sender: TObject);
var
  itm: TJamItem;
  folder: string;
begin
  itm := SelectedJamItem;
  if itm = nil then Exit;
  folder := ExtractFilePath(itm.Path);
  if (folder <> '') and DirectoryExists(folder) then
    ShellExecute(Handle, 'open', PChar(folder), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmJamAnalysis.mnuCopyPathClick(Sender: TObject);
var
  itm: TJamItem;
begin
  itm := SelectedJamItem;
  if itm <> nil then
    Clipboard.AsText := itm.Path;
end;

procedure TfrmJamAnalysis.mnuClearListClick(Sender: TObject);
begin
  if FScanRunning then Exit;
  jamlistview.Items.Clear;
  FLastSummary := '';
  jamLoading.Caption := 'Ready';
  ProgressBar.Visible := False;
  FFilesScanned := 0;
  FTexturesFound := 0;
end;

end.
