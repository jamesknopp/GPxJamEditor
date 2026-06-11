unit JamBatch;

interface

uses
  System.IOUtils, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Generics.Collections,
  System.Classes, Vcl.Dialogs, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.NumberBox, Vcl.Samples.Spin,
  System.Threading, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  jamGeneral, jamPaletteDetector, jamSW, jamHW, System.types, strutils,
  Vcl.Menus, generalhelpers, System.Win.Registry, Winapi.ShellAPI;

type

  TTextureSimpOptions = (quad, seed, mean, neighbour);

  // Batch-run lifecycle state for each item. Drives the row colour
  // and status text in the ListView.
  TJamBatchStatus = (bsIdle, bsPending, bsProcessing, bsDone, bsFailed);

  TJamOptions = record
    Simplify: TTextureSimpOptions;
    Blur: integer;
    simplifyThresh: integer;
    doPals: boolean;
    doSimplePal: boolean;
    doSoftenMatte: boolean;
  end;

  TJamBatchItem = class
    filepath: string;
    filename: string;
    outputpath: string;
    inputType: TJamType;
    outputType: TJamType;
    TextureOptions: TJamOptions;
    status: TJamBatchStatus;
    constructor Create(const aFile: string);
  end;

type
  TJamBatchForm = class(TForm)
    panel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LabelOutputFormat: TLabel;
    lblProgress: TLabel;
    cbSimplify: TComboBox;
    cbOutputFormat: TComboBox;
    chkSimpPalette: TCheckBox;
    chkDoMatte: TCheckBox;
    chkDoPalette: TCheckBox;
    chkScanAllFolders: TCheckBox;
    seBlur: TNumberBox;
    seThreshold: TNumberBox;
    strJamFile: TEdit;
    edtOutputPath: TEdit;
    edtFilename: TEdit;
    GroupBox1: TGroupBox;
    GroupBoxTools: TGroupBox;
    btnBrowseOutput: TButton;
    btnRun: TButton;
    btnCancel: TButton;
    btnAddFile: TButton;
    btnDel: TButton;
    btnScanFolder: TButton;
    btnConvertTrack: TButton;
    lvBatch: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBarPanel: TPanel;
    Splitter1: TSplitter;
    pbBatch: TProgressBar;
    jamBatchPopup: TPopupMenu;
    AddFiles01: TMenuItem;
    AddScanFolder1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    DeleteItems1: TMenuItem;
    mnuOpenFolder: TMenuItem;
    mnuRetryFailed: TMenuItem;
    openTrack: TOpenDialog;
    procedure btnAddFileClick(Sender: TObject);
    procedure btnScanFolderClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvBatchSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure cbSimplifyChange(Sender: TObject);
    procedure cbOutputFormatChange(Sender: TObject);
    procedure seThresholdChange(Sender: TObject);
    procedure seBlurChange(Sender: TObject);
    procedure edtOutputPathChange(Sender: TObject);
    procedure chkSimpPaletteClick(Sender: TObject);
    procedure chkDoMatteClick(Sender: TObject);
    procedure chkDoPaletteClick(Sender: TObject);
    function GetJamType(jamType: TJamType): string;
    function GetSimplifyOptions(opts: TTextureSimpOptions): string;
    procedure lvBatchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvBatchDblClick(Sender: TObject);
    procedure jamBatchPopupPopup(Sender: TObject);
    procedure lvBatchClick(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtFilenameChange(Sender: TObject);
    procedure DeleteItems1Click(Sender: TObject);
    procedure btnConvertTrackClick(Sender: TObject);
    procedure mnuOpenFolderClick(Sender: TObject);
    procedure mnuRetryFailedClick(Sender: TObject);
    procedure lvBatchCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvBatchCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);

  private
    // O(1) duplicate detection — paired with BatchList. Normalised lower-case
    // filepath → item. Kept in sync in AddBatchItem / btnDelClick / OnClear.
    FPathIndex: TDictionary<string, TJamBatchItem>;
    // Batch progress counters (UI-thread only)
    FBatchTotal: integer;
    FBatchDone: integer;
    FBatchFailed: integer;
    // Set by btnCancelClick (UI thread); read by the TTask worker loop
    // between items. Plain Boolean reads/writes are atomic on x86/x64
    // so no interlock is needed for this one-shot signalling use — the
    // worst case is a one-iteration delay before the worker notices.
    FCancelRequested: Boolean;
    FBatchRunning: Boolean;
    FLastRunSummary: string;

    procedure RefreshListView;
    procedure ConvertJam;
    procedure ConvertSingleItem(Item: TJamBatchItem; DoPalette: Boolean);
    procedure UpdateListViewItem(li: TListItem);
    procedure UpdateItemRow(Item: TJamBatchItem);
    procedure RefreshSelectedItems;
    procedure PopulateDetails(const Items: TArray<TJamBatchItem>);
    procedure ApplyDetailsToItems(const Items: TArray<TJamBatchItem>);
    procedure OnItemProcessed(Item: TJamBatchItem);
    function GetSelectedBatchItems: TArray<TJamBatchItem>;
    function ItemExists(const APath: string): Boolean;
    function AddBatchItem(const FilePath: string): TJamBatchItem;
    function DefaultOutputType(InputType: TJamType): TJamType;
    function DefaultOutputPath(const SourcePath: string;
      OutputType: TJamType): string;
    function NormalisePath(const APath: string): string;
    procedure EnsurePathIndex;
    procedure SetItemStatus(Item: TJamBatchItem; NewStatus: TJamBatchStatus);
    procedure UpdateBatchProgress;
    function StatusText(S: TJamBatchStatus): string;
    procedure ClearCompletedItems;
    procedure UpdateUIState;
    // Queue-from-worker helpers. Pass Item + NewStatus as parameters so
    // each call's values are captured per-invocation — the closure would
    // otherwise alias the loop variable in the caller and misreport.
    procedure QueueStatusChange(Item: TJamBatchItem;
      NewStatus: TJamBatchStatus);
    procedure QueueItemComplete(Item: TJamBatchItem; Success: Boolean);
    // Remember last folder per dialog type (add-files, scan-folder, output)
    // in the existing HKCU\Software\JKVFX\JamEditor key. Values are written
    // immediately when the user picks a folder, so they persist even if the
    // app is killed.
    function LoadBatchFolder(const ValueName: string): string;
    procedure SaveBatchFolder(const ValueName, Folder: string);
    function OutputTypeFromComboIndex(Idx: Integer): TJamType;
    function ComboIndexForOutputType(JT: TJamType): Integer;
    procedure OpenFolderForItem(Item: TJamBatchItem);
    function AnyFailed: Boolean;
    function StatusColor(S: TJamBatchStatus): TColor;
  public
    destructor Destroy; override;
  end;

var
  JamBatchForm: TJamBatchForm;
  BatchList: TObjectList<TJamBatchItem>;

procedure InitBatchList;
procedure FreeBatchList;

implementation

uses
  mainform; // only for LoadJam on double-click — kept in implementation
            // uses to avoid a circular unit reference

{$R *.dfm}

constructor TJamBatchItem.Create(const aFile: string);
begin
  inherited Create;
  filepath := aFile;
  outputpath := ChangeFileExt(aFile, ''); // or wherever you like
  inputType := jamGP3SW;
  outputType := jamGP3HW;

  with TextureOptions do
  begin
    Simplify := neighbour;
    Blur := intBlurThreshold;
    simplifyThresh := intSimplifyThreshold;
    doSimplePal := False;
    doSoftenMatte := False;
  end;
  status := bsIdle;
end;

procedure InitBatchList;
begin
  BatchList := TObjectList<TJamBatchItem>.Create(True);
end;

procedure FreeBatchList;
begin
  BatchList.Free;
end;

destructor TJamBatchForm.Destroy;
begin
  FreeAndNil(FPathIndex);
  inherited;
end;

function TJamBatchForm.NormalisePath(const APath: string): string;
begin
  Result := ExpandFileName(APath).ToLower;
end;

procedure TJamBatchForm.EnsurePathIndex;
var
  itm: TJamBatchItem;
begin
  if FPathIndex <> nil then Exit;
  FPathIndex := TDictionary<string, TJamBatchItem>.Create;
  // Populate from any items already in BatchList (defensive)
  for itm in BatchList do
    FPathIndex.AddOrSetValue(NormalisePath(itm.filepath), itm);
end;

function TJamBatchForm.ItemExists(const APath: string): Boolean;
begin
  EnsurePathIndex;
  Result := FPathIndex.ContainsKey(NormalisePath(APath));
end;

function TJamBatchForm.DefaultOutputType(InputType: TJamType): TJamType;
begin
  // "Convert to the opposite" default: SW → HW, HW → SW, GP2 → GP3SW
  case InputType of
    jamGP3SW: Result := jamGP3HW;
    jamGP3HW: Result := jamGP3SW;
    jamGP2:   Result := jamGP3SW;
  else
    Result := InputType;
  end;
end;

function TJamBatchForm.DefaultOutputPath(const SourcePath: string;
  OutputType: TJamType): string;
var
  dir: string;
begin
  dir := ExtractFilePath(SourcePath);
  // GP3 SW and HW share the same pair of Gp3Jams / Gp3JamsH folders;
  // flip between them so output lands in the "other" folder by default.
  if OutputType in [jamGP3SW, jamGP3HW] then
    Result := ToggleGP3JamsFolder(dir)
  else
    Result := dir;
end;

function TJamBatchForm.AddBatchItem(const FilePath: string): TJamBatchItem;
begin
  EnsurePathIndex;
  if FPathIndex.ContainsKey(NormalisePath(FilePath)) then
    Exit(nil);

  Result := TJamBatchItem.Create(FilePath);
  Result.inputType := TJamPaletteDetector.Instance.Detect(FilePath, True);
  Result.outputType := DefaultOutputType(Result.inputType);
  Result.filename := ExtractFileName(FilePath);
  Result.outputpath := DefaultOutputPath(FilePath, Result.outputType);

  BatchList.Add(Result);
  FPathIndex.Add(NormalisePath(FilePath), Result);
end;

procedure TJamBatchForm.jamBatchPopupPopup(Sender: TObject);
begin
  DeleteItems1.Enabled  := lvBatch.SelCount > 0;
  mnuOpenFolder.Enabled := lvBatch.SelCount > 0;
  mnuRetryFailed.Enabled := AnyFailed and not FBatchRunning;
end;

function TJamBatchForm.GetSelectedBatchItems: TArray<TJamBatchItem>;
var
  i: integer;
  tmp: TList<TJamBatchItem>;
begin
  tmp := TList<TJamBatchItem>.Create;
  try
    for i := 0 to lvBatch.Items.Count - 1 do
      if lvBatch.Items[i].Selected then
        tmp.Add(TJamBatchItem(lvBatch.Items[i].Data));
    Result := tmp.ToArray;
  finally
    tmp.Free;
  end;
end;

procedure TJamBatchForm.btnAddFileClick(Sender: TObject);
var
  dlg: TOpenDialog;
  fn: string;
begin
  dlg := TOpenDialog.Create(nil);
  try
    dlg.Filter := 'JAM files|*.jam;*.jip';
    dlg.Options := dlg.Options + [ofAllowMultiSelect];
    dlg.InitialDir := LoadBatchFolder('BatchAddFilesPath');
    if dlg.Execute then
    begin
      ClearCompletedItems;
      for fn in dlg.Files do
        AddBatchItem(fn);
      if dlg.Files.Count > 0 then
        SaveBatchFolder('BatchAddFilesPath', ExtractFilePath(dlg.Files[0]));
    end;
    RefreshListView;
  finally
    dlg.Free;
  end;
end;

procedure TJamBatchForm.btnBrowseOutputClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select output folder';
    dlg.DefaultFolder := LoadBatchFolder('BatchOutputPath');
    if dlg.Execute then
    begin
      edtOutputPath.Text := dlg.filename;
      edtOutputPath.SetFocus;
      ApplyDetailsToItems(GetSelectedBatchItems);
      SaveBatchFolder('BatchOutputPath', dlg.filename);
    end;
  finally
    dlg.Free;
  end;
end;

procedure TJamBatchForm.btnDelClick(Sender: TObject);
var
  i: integer;
  idxs: TList<integer>;
  itm: TJamBatchItem;
begin
  if lvBatch.SelCount = 0 then Exit;
  if MessageDlg('Remove the selected item(s)?', mtConfirmation, [mbYes, mbNo],
    0) <> mrYes then
    Exit;

  EnsurePathIndex;
  idxs := TList<integer>.Create;
  try
    for i := 0 to lvBatch.Items.Count - 1 do
      if lvBatch.Items[i].Selected then
        idxs.Add(i);
    idxs.Sort;
    // remove highest to lowest so preceding indexes stay valid
    for i := idxs.Count - 1 downto 0 do
    begin
      itm := BatchList[idxs[i]];
      FPathIndex.Remove(NormalisePath(itm.filepath));
      BatchList.Delete(idxs[i]); // TObjectList owns → frees item
    end;
    RefreshListView;
  finally
    idxs.Free;
  end;
end;

function TJamBatchForm.LoadBatchFolder(const ValueName: string): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(baseKeyPath) then
    try
      if Reg.ValueExists(ValueName) then
        Result := Reg.ReadString(ValueName);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  // Guard against stale paths pointing at folders that no longer exist.
  if (Result <> '') and not DirectoryExists(Result) then
    Result := '';
end;

procedure TJamBatchForm.SaveBatchFolder(const ValueName, Folder: string);
var
  Reg: TRegistry;
begin
  if Folder = '' then Exit;
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(baseKeyPath, True) then
    try
      Reg.WriteString(ValueName, Folder);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SetChildrenEnabled(Parent: TWinControl; Enabled: Boolean);
// VCL's Enabled-cascade works for input routing but doesn't force a visual
// repaint through nested TPanels — their children can end up looking active
// even when the outer GroupBox is disabled. Walk the tree and set Enabled
// directly on every leaf TControl so each repaints in its disabled style.
var
  i: integer;
  child: TControl;
begin
  for i := 0 to Parent.ControlCount - 1 do
  begin
    child := Parent.Controls[i];
    child.Enabled := Enabled;
    if child is TWinControl then
      SetChildrenEnabled(TWinControl(child), Enabled);
  end;
end;

procedure TJamBatchForm.UpdateUIState;
// Centralises enable/disable rules so selection / list / status changes all
// route through one place. Called by: selection, add, delete, clear,
// radio-click, and SetItemStatus (so Run disables when all items finish).
var
  selCount, readyCount, swSelCount: integer;
  i: integer;
  itm: TJamBatchItem;
  allSelectedAreSW: Boolean;
begin
  selCount := 0;
  swSelCount := 0;
  readyCount := 0;
  for i := 0 to BatchList.Count - 1 do
  begin
    itm := BatchList[i];
    // "Ready to convert" = anything that hasn't already succeeded. We keep
    // bsFailed items eligible so the user can retry after fixing the cause.
    if itm.status <> bsDone then
      Inc(readyCount);
  end;

  // Selection-driven counts (walk the ListView, not BatchList — order may
  // differ after sort).
  for i := 0 to lvBatch.Items.Count - 1 do
    if lvBatch.Items[i].Selected and (lvBatch.Items[i].Data <> nil) then
    begin
      Inc(selCount);
      itm := TJamBatchItem(lvBatch.Items[i].Data);
      if itm.outputType in [jamGP2, jamGP3SW] then
        Inc(swSelCount);
    end;
  allSelectedAreSW := (selCount > 0) and (swSelCount = selCount);

  // During a batch run we lock down edits entirely — the user can only
  // watch progress or hit Cancel.
  btnDel.Enabled           := (selCount > 0) and not FBatchRunning;
  DeleteItems1.Enabled     := (selCount > 0) and not FBatchRunning;
  btnAddFile.Enabled       := not FBatchRunning;
  btnScanFolder.Enabled    := not FBatchRunning;
  btnConvertTrack.Enabled  := not FBatchRunning;
  edtOutputPath.Enabled    := (selCount > 0) and not FBatchRunning;
  btnBrowseOutput.Enabled  := (selCount > 0) and not FBatchRunning;
  edtFilename.Enabled      := (selCount = 1) and not FBatchRunning;
  // Input JAM field is read-only but grey it out when selection is
  // non-singular so it doesn't look like an editable field with no value.
  strJamFile.Enabled       := selCount = 1;
  cbOutputFormat.Enabled   := (selCount > 0) and not FBatchRunning;
  // Palette controls only meaningful when converting to a software JAM.
  // Cascade Enabled through the nested panel so every child greys out
  // visually, not just logically.
  GroupBox1.Enabled := allSelectedAreSW and not FBatchRunning;
  SetChildrenEnabled(GroupBox1, allSelectedAreSW and not FBatchRunning);
  btnRun.Enabled := (readyCount > 0) and not FBatchRunning;
end;

procedure TJamBatchForm.ClearCompletedItems;
var
  i: integer;
  itm: TJamBatchItem;
  removed: Boolean;
begin
  // Remove any items that finished successfully on the previous run so the
  // list doesn't accumulate stale results. Failed items are preserved so the
  // user can see what went wrong and retry.
  if BatchList.Count = 0 then Exit;
  EnsurePathIndex;
  removed := False;
  for i := BatchList.Count - 1 downto 0 do
  begin
    itm := BatchList[i];
    if itm.status = bsDone then
    begin
      FPathIndex.Remove(NormalisePath(itm.filepath));
      BatchList.Delete(i); // TObjectList owns → frees item
      removed := True;
    end;
  end;
  if removed then
  begin
    FBatchTotal := 0;
    FBatchDone := 0;
    FLastRunSummary := '';  // New run starts fresh — clear any prior summary
    UpdateBatchProgress;
    RefreshListView;
  end;
end;

procedure TJamBatchForm.btnScanFolderClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
  Dir: string;
  Files: TArray<string>;
  f: string;
  opt: TSearchOption;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist];
    dlg.Title := 'Select folder to scan for JAMs';
    dlg.DefaultFolder := LoadBatchFolder('BatchScanFolderPath');
    if not dlg.Execute then Exit;

    Dir := dlg.filename;
    SaveBatchFolder('BatchScanFolderPath', Dir);
    if chkScanAllFolders.Checked then
      opt := TSearchOption.soAllDirectories
    else
      opt := TSearchOption.soTopDirectoryOnly;

    Files := TDirectory.GetFiles(Dir, '*.jam', opt);
    ClearCompletedItems;
    for f in Files do
      AddBatchItem(f);

    RefreshListView;
  finally
    dlg.Free;
  end;
end;

procedure TJamBatchForm.btnConvertTrackClick(Sender: TObject);
begin
end;

procedure TJamBatchForm.cbSimplifyChange(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.chkDoMatteClick(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.chkDoPaletteClick(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.chkSimpPaletteClick(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.edtOutputPathChange(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.lvBatchClick(Sender: TObject);
begin
  UpdateUIState;
end;

procedure TJamBatchForm.FormShow(Sender: TObject);
begin
  UpdateUIState;
end;

procedure TJamBatchForm.lvBatchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Ctrl+A → select all
  if (Key = Ord('A')) and (Shift = [ssCtrl]) then
  begin
    lvBatch.Items.BeginUpdate;
    try
      for var i := 0 to lvBatch.Items.Count - 1 do
        lvBatch.Items[i].Selected := True;
    finally
      lvBatch.Items.EndUpdate;
    end;
    Key := 0; // swallow
  end
  // Delete → confirm & remove
  else if (Key = VK_DELETE) and (lvBatch.SelCount > 0) then
  begin
    btnDelClick(Sender);
    Key := 0;
  end;
end;

procedure TJamBatchForm.lvBatchSelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
var
  sel: TList<TJamBatchItem>;
  i: integer;
begin
  sel := TList<TJamBatchItem>.Create;
  try
    for i := 0 to lvBatch.Items.Count - 1 do
      if lvBatch.Items[i].Selected then
        sel.Add(TJamBatchItem(lvBatch.Items[i].Data));
    PopulateDetails(sel.ToArray);
  finally
    sel.Free;
  end;

  UpdateUIState;
end;

procedure TJamBatchForm.ConvertSingleItem(Item: TJamBatchItem;
  DoPalette: Boolean);
// Handles one input/output type pair with the correct load/convert/save
// pattern. Always frees its bitmap objects, even on exception.
// Item.outputpath is the directory; Item.filename is the file name —
// SaveToFile needs the full path, so we combine them here.
var
  JamFile, OldJamFile: TJamFile;
  HWJamFile: THWJamFile;
  outFile: string;
  i: Integer;

  procedure ZeroPalettesIfRequested;
  var
    x: Integer;
  begin
    if not DoPalette then Exit;
    for x := 0 to JamFile.FEntries.Count - 1 do
      JamFile.ZeroPalette(x);
  end;

begin
  // Ensure the destination directory exists
  checkPath(Item.outputpath);

  // Build the full output file path
  outFile := TPath.Combine(Item.outputpath, Item.filename);

  // HW → SW/GP2: load HW, convert, save SW
  if Item.inputType = jamGP3HW then
  begin
    if not (Item.outputType in [jamGP3SW, jamGP2]) then Exit;
    JamFile := TJamFile.Create;
    HWJamFile := THWJamFile.Create;
    try
      HWJamFile.LoadFromFile(Item.filepath);
      JamFile.ConvertHWJam(HWJamFile, Item.outputType = jamGP2);
      JamFile.SaveToFile(outFile, False);
    finally
      JamFile.Free;
      HWJamFile.Free;
    end;
    Exit;
  end;

  // GP2 / GP3SW source — two sub-paths: → SW (with palette option) or → HW
  if Item.inputType in [jamGP2, jamGP3SW] then
  begin
    if Item.outputType = jamGP3HW then
    begin
      OldJamFile := TJamFile.Create;
      HWJamFile := THWJamFile.Create;
      try
        case TJamPaletteDetector.Instance.Detect(Item.filepath, false) of
          jamGP2:   OldJamFile.SetGpxPal(True);
          jamGP3SW: OldJamFile.SetGpxPal(False);
        end;
        OldJamFile.LoadFromFile(Item.filepath, False);
        HWJamFile.canvasWidth := 256;
        HWJamFile.FHeader.JamTotalHeight := OldJamFile.FHeader.JamTotalHeight;
        HWJamFile.CanvasBitmap := TBitmap.Create;
        HWJamFile.CanvasBitmap.Canvas.Lock;
        with HWJamFile.CanvasBitmap do
        begin
          PixelFormat := pf24bit;
          Width := 256;
          Height := HWJamFile.FHeader.JamTotalHeight;
          Canvas.Brush.Color := TCol_TransGP3HW;
          Canvas.FillRect(Rect(0, 0, Width, Height));
        end;
        HWJamFile.CanvasBitmap.Canvas.Unlock;
        for i := 0 to OldJamFile.FHeader.NumItems - 1 do
          HWJamFile.AddTexture(OldJamFile.FEntries[i].FTexture,
            OldJamFile.FEntries[i].FInfo);
        HWJamFile.FHeader.NumItems := OldJamFile.FHeader.NumItems;
        HWJamFile.SaveToFile(outFile);
      finally
        OldJamFile.Free;
        HWJamFile.Free;
      end;
      Exit;
    end;

    if Item.outputType in [jamGP2, jamGP3SW] then
    begin
      JamFile := TJamFile.Create;
      OldJamFile := TJamFile.Create;
      try
        OldJamFile.LoadFromFile(Item.filepath, False);
        JamFile.ConvertGpxJam(OldJamFile, Item.outputType = jamGP2);
        ZeroPalettesIfRequested;
        JamFile.SaveToFile(outFile, False);
      finally
        JamFile.Free;
        OldJamFile.Free;
      end;
    end;
  end;
end;

procedure TJamBatchForm.QueueStatusChange(Item: TJamBatchItem;
  NewStatus: TJamBatchStatus);
begin
  TThread.Queue(nil,
    procedure
    begin
      SetItemStatus(Item, NewStatus);
    end);
end;

procedure TJamBatchForm.QueueItemComplete(Item: TJamBatchItem; Success: Boolean);
begin
  TThread.Queue(nil,
    procedure
    begin
      if Success then
        SetItemStatus(Item, bsDone)
      else
      begin
        SetItemStatus(Item, bsFailed);
        Inc(FBatchFailed);
      end;
      Inc(FBatchDone);
      UpdateBatchProgress;
    end);
end;

procedure TJamBatchForm.ConvertJam;
// See the big comment inside the TTask.Run block for the threading
// rationale.
var
  pendingList: TList<TJamBatchItem>;
  items: TArray<TJamBatchItem>;
  doPalette: Boolean;
  it: TJamBatchItem;
begin
  if BatchList.Count = 0 then Exit;

  // Build the ready-to-convert subset. Items that already succeeded stay
  // bsDone; failed items get another shot.
  pendingList := TList<TJamBatchItem>.Create;
  try
    for it in BatchList do
      if it.status <> bsDone then
        pendingList.Add(it);
    items := pendingList.ToArray;
  finally
    pendingList.Free;
  end;
  if Length(items) = 0 then Exit;

  doPalette := chkDoPalette.Checked;

  for it in items do
    it.status := bsPending;
  FBatchTotal := Length(items);
  FBatchDone := 0;
  FBatchFailed := 0;
  FCancelRequested := False;
  FBatchRunning := True;
  FLastRunSummary := '';
  UpdateBatchProgress;
  RefreshListView;
  btnCancel.Enabled := True;
  btnRun.Enabled := False;

  // Run the conversion loop on a single worker thread via TTask.Run.
  //
  // Why not TParallel.For / multiple workers: the conversion code still
  // touches shared globals (gpxPal, intPaletteID, boolRcrJam, the palette
  // detector singleton). One worker at a time keeps those globals from
  // being contested. True parallelism is a separate, larger refactor.
  //
  // Why run on a worker at all, if the conversion is still serial: keeping
  // the long-running loop off the UI thread lets the VCL paint/click
  // pipeline run uninterrupted — the list repaints smoothly, Cancel clicks
  // are instant, and we don't have to sprinkle ProcessMessages through the
  // loop (which was noticeably slower).
  //
  // GDI safety: THWJamFile.DrawSingleTexture no longer uses BitBlt — it
  // copies pixels with ScanLine+Move, so worker-thread use is safe.
  //
  // User must not touch the main editor window while a batch is running,
  // because the globals above are shared process-wide. UpdateUIState
  // locks down the batch dialog itself during a run, but can't disable
  // the main form — keep that in mind if the user reports weird palette
  // glitches during a batch.
  TTask.Run(
    procedure
    var
      i: integer;
      current: TJamBatchItem;
      ok: Boolean;
    begin
      try
        for i := 0 to High(items) do
        begin
          if FCancelRequested then
          begin
            // Roll any still-queued items back to Idle on the UI thread so
            // they don't sit forever showing "Pending".
            TThread.Queue(nil,
              procedure
              var
                k: integer;
              begin
                for k := i to High(items) do
                  if items[k].status = bsPending then
                    SetItemStatus(items[k], bsIdle);
              end);
            Break;
          end;

          current := items[i];
          QueueStatusChange(current, bsProcessing);

          ok := False;
          try
            ConvertSingleItem(current, doPalette);
            ok := True;
          except
            on E: Exception do
              OutputDebugString(PChar(Format(
                'Batch: conversion failed for %s: %s',
                [current.filepath, E.Message])));
          end;

          QueueItemComplete(current, ok);
        end;
      finally
        // Finalise on the UI thread — touch VCL state from here only.
        TThread.Queue(nil,
          procedure
          var
            succeeded: integer;
          begin
            FBatchRunning := False;
            btnCancel.Enabled := False;
            succeeded := FBatchDone - FBatchFailed;
            if FCancelRequested then
              FLastRunSummary := Format('Cancelled: %d / %d done',
                [FBatchDone, FBatchTotal])
            else if FBatchFailed > 0 then
              FLastRunSummary := Format('Finished: %d ok, %d failed',
                [succeeded, FBatchFailed])
            else
              FLastRunSummary := Format('Finished: %d / %d ok',
                [succeeded, FBatchTotal]);
            pbBatch.Visible := False;
            lblProgress.Visible := True;
            lblProgress.Caption := FLastRunSummary;
            UpdateUIState;
          end);
      end;
    end);
end;

procedure TJamBatchForm.DeleteItems1Click(Sender: TObject);
begin
  btnDelClick(Sender);
end;

procedure TJamBatchForm.edtFilenameChange(Sender: TObject);
begin

  if lvBatch.SelCount > 1 then
    Exit;

  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.btnRunClick(Sender: TObject);
begin
  ConvertJam;
end;

procedure TJamBatchForm.btnCancelClick(Sender: TObject);
begin
  // Signal the worker loop to stop between items. Current item finishes.
  FCancelRequested := True;
  btnCancel.Enabled := False;
  lblProgress.Caption := lblProgress.Caption + ' — cancelling...';
end;

procedure TJamBatchForm.OpenFolderForItem(Item: TJamBatchItem);
var
  folder: string;
begin
  if Item = nil then Exit;
  folder := ExtractFilePath(Item.filepath);
  if (folder = '') or not DirectoryExists(folder) then Exit;
  ShellExecute(Handle, 'open', PChar(folder), nil, nil, SW_SHOWNORMAL);
end;

procedure TJamBatchForm.mnuOpenFolderClick(Sender: TObject);
var
  sel: TArray<TJamBatchItem>;
begin
  sel := GetSelectedBatchItems;
  if Length(sel) = 0 then Exit;
  // For multi-select, just open the first distinct folder. Users rarely
  // want many Explorer windows to fire at once.
  OpenFolderForItem(sel[0]);
end;

procedure TJamBatchForm.mnuRetryFailedClick(Sender: TObject);
// Flip every bsFailed item back to bsIdle so the next Run Batch picks
// them up. ConvertJam already ignores bsDone items so this is all we need.
var
  itm: TJamBatchItem;
  any: Boolean;
begin
  any := False;
  for itm in BatchList do
    if itm.status = bsFailed then
    begin
      itm.status := bsIdle;
      any := True;
    end;
  if any then
  begin
    RefreshListView;
    lvBatch.Invalidate;
  end;
end;

function TJamBatchForm.AnyFailed: Boolean;
var
  itm: TJamBatchItem;
begin
  for itm in BatchList do
    if itm.status = bsFailed then Exit(True);
  Result := False;
end;

procedure TJamBatchForm.lvBatchDblClick(Sender: TObject);
// Double-click loads the clicked JAM into the main editor window so the
// user can inspect/edit it before (or instead of) converting. The main
// form's LoadJam handles both HW and SW formats internally.
var
  sel: TArray<TJamBatchItem>;
  path: string;
begin
  sel := GetSelectedBatchItems;
  if Length(sel) = 0 then Exit;
  path := sel[0].filepath;
  if not FileExists(path) then Exit;
  FormMain.LoadJam(path);
  // Bring the main window forward so the user sees the loaded JAM. The
  // batch dialog stays open behind it — user can keep scrolling.
  FormMain.BringToFront;
end;

procedure TJamBatchForm.cbOutputFormatChange(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
  UpdateUIState;
end;

function TJamBatchForm.OutputTypeFromComboIndex(Idx: Integer): TJamType;
begin
  case Idx of
    0: Result := jamGP2;
    1: Result := jamGP3SW;
    2: Result := jamGP3HW;
  else
    Result := jamGP3SW;
  end;
end;

function TJamBatchForm.ComboIndexForOutputType(JT: TJamType): Integer;
begin
  case JT of
    jamGP2:   Result := 0;
    jamGP3SW: Result := 1;
    jamGP3HW: Result := 2;
  else
    Result := -1;
  end;
end;

procedure TJamBatchForm.OnItemProcessed(Item: TJamBatchItem);
begin
  // Just update the one row rather than clearing + rebuilding the entire
  // ListView (which loses sort order, selection, and scroll position).
  UpdateItemRow(Item);
end;

procedure TJamBatchForm.UpdateItemRow(Item: TJamBatchItem);
var
  i: integer;
  li: TListItem;
begin
  for i := 0 to lvBatch.Items.Count - 1 do
  begin
    li := lvBatch.Items[i];
    if TJamBatchItem(li.Data) = Item then
    begin
      UpdateListViewItem(li);
      Exit;
    end;
  end;
end;

function TJamBatchForm.StatusText(S: TJamBatchStatus): string;
// A leading glyph gives the status a visual anchor inside the cell, on top
// of the full-row background colour. Unicode bullets render fine in Segoe
// UI on every supported Windows version.
begin
  case S of
    bsIdle:       Result := #$25CB + '  Ready';         // white circle
    bsPending:    Result := #$25CF + '  Pending';       // black circle
    bsProcessing: Result := #$25D0 + '  Processing...'; // half circle
    bsDone:       Result := #$2714 + '  Done';          // check mark
    bsFailed:     Result := #$2716 + '  Failed';        // cross
  else
    Result := '';
  end;
end;

procedure TJamBatchForm.SetItemStatus(Item: TJamBatchItem;
  NewStatus: TJamBatchStatus);
// Called on the main thread. Updates the item's status, the
// corresponding ListView row, and the progress indicators.
begin
  if Item = nil then Exit;
  Item.status := NewStatus;
  UpdateItemRow(Item);
  lvBatch.Invalidate; // force a redraw so the background colour updates
  UpdateUIState;      // Run button state depends on how many remain ready
end;

procedure TJamBatchForm.UpdateBatchProgress;
// Main thread only. Refreshes the progress bar + count label.
begin
  if FBatchTotal <= 0 then
  begin
    pbBatch.Position := 0;
    pbBatch.Visible := False;
    // Keep last-run summary visible between runs (ConvertJam sets it in
    // FLastRunSummary). Only hide entirely if we have neither.
    if FLastRunSummary <> '' then
    begin
      lblProgress.Visible := True;
      lblProgress.Caption := FLastRunSummary;
    end
    else
      lblProgress.Visible := False;
    Exit;
  end;
  pbBatch.Max := FBatchTotal;
  pbBatch.Position := FBatchDone;
  pbBatch.Visible := True;
  lblProgress.Visible := True;
  lblProgress.Caption := Format('%d / %d', [FBatchDone, FBatchTotal]);
end;

function TJamBatchForm.StatusColor(S: TJamBatchStatus): TColor;
// Row background colours — slightly more saturated than the original pastels
// so status reads at a glance down a long list.
begin
  case S of
    bsPending:    Result := $00BDEDFF; // amber (peach)
    bsProcessing: Result := $00F0D088; // soft blue
    bsDone:       Result := $00A8F0A8; // green
    bsFailed:     Result := $00A8A8F0; // pink/red
  else
    Result := clWindow;                // bsIdle: default row background
  end;
end;

procedure TJamBatchForm.lvBatchCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
// Per-row background colour based on the item's batch status.
var
  itm: TJamBatchItem;
begin
  DefaultDraw := True;
  if Item.Data = nil then Exit;
  itm := TJamBatchItem(Item.Data);
  Sender.Canvas.Brush.Color := StatusColor(itm.status);
end;

procedure TJamBatchForm.lvBatchCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
// Row colour is the primary status signal; the bullet prefix in StatusText
// reinforces it for accessibility. Nothing extra to draw per subitem — we
// keep the handler registered in case we add per-column styling later.
begin
  DefaultDraw := True;
end;

function TJamBatchForm.GetJamType(jamType: TJamType): string;
begin
  case jamType of
    jamGP2:   Result := 'GP2 JAM';
    jamGP3SW: Result := 'GP3 Software JAM';
    jamGP3HW: Result := 'GP3 Hardware JAM';
  else
    Result := '';
  end;
end;

function TJamBatchForm.GetSimplifyOptions(opts: TTextureSimpOptions): string;
begin
  case opts of
    quad:      Result := 'Quad Tree Method (Blocky)';
    seed:      Result := 'Seed Threshold';
    mean:      Result := 'Mean Region';
    neighbour: Result := 'Neighbour Threshold (Usually best)';
  else
    Result := '';
  end;
end;

procedure TJamBatchForm.RefreshListView;
var

  itm: TJamBatchItem;
  li: TListItem;
begin
  lvBatch.Items.BeginUpdate;
  try
    lvBatch.Items.Clear;
    for itm in BatchList do
    begin
      li := lvBatch.Items.Add;
      li.Caption := ExtractFileName(itm.filepath);
      li.SubItems.Add(GetJamType(itm.inputType));
      li.SubItems.Add(GetJamType(itm.outputType));
      li.SubItems.Add(TPath.Combine(itm.outputpath, itm.filename));
      li.SubItems.Add(StatusText(itm.status));
      li.SubItems.Add(GetSimplifyOptions(itm.TextureOptions.Simplify));
      li.SubItems.Add(inttostr(itm.TextureOptions.Blur));
      li.SubItems.Add(inttostr(itm.TextureOptions.simplifyThresh));
      li.SubItems.Add(IfThen(itm.TextureOptions.doSimplePal, 'Yes', 'No'));
      li.SubItems.Add(IfThen(itm.TextureOptions.doSoftenMatte, 'Yes', 'No'));
      li.SubItems.Add(IfThen(itm.TextureOptions.doPals, 'Yes', 'No'));
      li.Data := itm;
    end;
  finally
    lvBatch.Items.EndUpdate;
  end;
  UpdateUIState;
end;

procedure TJamBatchForm.UpdateListViewItem(li: TListItem);
var
  itm: TJamBatchItem;
begin
  itm := TJamBatchItem(li.Data);

  // li.Caption is column 0
  li.Caption := ExtractFileName(itm.filepath);

  // SubItems[0] is column 1, SubItems[1] is column 2, etc.
  li.SubItems[0] := GetJamType(itm.inputType);
  li.SubItems[1] := GetJamType(itm.outputType);
  li.SubItems[2] := TPath.Combine(itm.outputpath, itm.filename);
  li.SubItems[3] := StatusText(itm.status);
  li.SubItems[4] := GetSimplifyOptions(itm.TextureOptions.Simplify);
  li.SubItems[5] := inttostr(itm.TextureOptions.Blur);
  li.SubItems[6] := inttostr(itm.TextureOptions.simplifyThresh);
  li.SubItems[7] := IfThen(itm.TextureOptions.doSimplePal, 'Yes', 'No');
  li.SubItems[8] := IfThen(itm.TextureOptions.doSoftenMatte, 'Yes', 'No');
  li.SubItems[9] := IfThen(itm.TextureOptions.doPals, 'Yes', 'No');
end;

procedure TJamBatchForm.RefreshSelectedItems;
var
  i: integer;
begin
  lvBatch.Items.BeginUpdate;
  try
    for i := 0 to lvBatch.Items.Count - 1 do
      if lvBatch.Items[i].Selected then
        UpdateListViewItem(lvBatch.Items[i]);
  finally
    lvBatch.Items.EndUpdate;
  end;
end;

procedure TJamBatchForm.seBlurChange(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

procedure TJamBatchForm.seThresholdChange(Sender: TObject);
begin
  ApplyDetailsToItems(GetSelectedBatchItems);
end;

// show values (or “mixed” state) for 1 vs. many
procedure TJamBatchForm.PopulateDetails(const Items: TArray<TJamBatchItem>);
var
  single: boolean;
  jamItem: TJamBatchItem;
begin
  single := Length(Items) = 1;
  if single then
    jamItem := Items[0];

  // OutputPath
  if single then
  begin
    edtOutputPath.Text := jamItem.outputpath;
    strJamFile.Text := jamItem.filepath;
    edtFilename.Text := jamItem.filename;
  end
  else
    edtOutputPath.Text := '';

  // OutputType
  if single then
    cbOutputFormat.ItemIndex := ComboIndexForOutputType(jamItem.outputType)
  else
    cbOutputFormat.ItemIndex := -1;

  // texture options...
  if single then
  begin
    cbSimplify.ItemIndex := Ord(jamItem.TextureOptions.Simplify);
    seBlur.Value := jamItem.TextureOptions.Blur;
    seThreshold.Value := Round(jamItem.TextureOptions.simplifyThresh);
    chkDoPalette.Checked := jamItem.TextureOptions.doPals;
    chkDoMatte.Checked := jamItem.TextureOptions.doSoftenMatte;
    chkSimpPalette.Checked := jamItem.TextureOptions.doSimplePal;

  end
  else
  begin
    cbSimplify.ItemIndex := -1;
    seBlur.Value := 0;
    seThreshold.Value := 0;
    chkDoPalette.Checked := False;
    chkDoMatte.Checked := False;
    chkSimpPalette.Checked := False;
    edtFilename.Text := '';
    edtOutputPath.Text := '';
    strJamFile.Text := '';
  end;
end;

// Write any changed detail back to all selected items. We use "which
// control has focus" as a proxy for "which property the user is editing",
// so only the edited field gets applied across selection.
procedure TJamBatchForm.ApplyDetailsToItems(const Items: TArray<TJamBatchItem>);
var
  jamItem: TJamBatchItem;
begin
  for jamItem in Items do
  begin
    if edtOutputPath.Focused then
      jamItem.outputpath := edtOutputPath.Text;

    if edtFilename.Focused then
      jamItem.filename := edtFilename.Text;

    if cbOutputFormat.Focused and (cbOutputFormat.ItemIndex >= 0) then
      jamItem.outputType := OutputTypeFromComboIndex(cbOutputFormat.ItemIndex);

    if cbSimplify.Focused then
      jamItem.TextureOptions.Simplify :=
        TTextureSimpOptions(cbSimplify.ItemIndex);
    if seBlur.Focused then
      jamItem.TextureOptions.Blur := Round(seBlur.Value);
    if seThreshold.Focused then
      jamItem.TextureOptions.simplifyThresh := Round(seThreshold.Value);
    if chkDoPalette.Focused then
      jamItem.TextureOptions.doPals := chkDoPalette.Checked;
    if chkDoMatte.Focused then
      jamItem.TextureOptions.doSoftenMatte := chkDoMatte.Checked;
    if chkSimpPalette.Focused then
      jamItem.TextureOptions.doSimplePal := chkSimpPalette.Checked;
  end;
  RefreshSelectedItems;
end;

initialization

InitBatchList;

finalization

FreeBatchList;

end.
