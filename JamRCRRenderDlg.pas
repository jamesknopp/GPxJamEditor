unit JamRCRRenderDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.FileCtrl,
  Vcl.Imaging.pngimage,
  JamRCRRender, JamRCRSettings, JamSW, JamGeneral, Options;

type
  TJamRCRRenderDlgForm = class(TForm)
    rgMode:             TRadioGroup;
    rgGP3Version:       TRadioGroup;
    btnOptions:         TButton;
    lblFolders:         TLabel;
    lblRCR:             TLabel;
    cbRCR:              TComboBox;
    lblPair:            TLabel;
    lblLivery:          TLabel;
    cbLivery:           TComboBox;
    lblChassis:         TLabel;
    cbChassis:          TComboBox;
    lblTyre:            TLabel;
    cbTyre:             TComboBox;
    lblHelmet:          TLabel;
    cbHelmet:           TComboBox;
    btnRender:          TButton;
    btnExportSheet:     TButton;
    btnExportPerEntry:  TButton;
    btnZoomOut:         TButton;
    btnZoomReset:       TButton;
    btnZoomIn:          TButton;
    btnClose:           TButton;
    sbPreview:          TScrollBox;
    imgPreview:         TImage;
    lblStatus:          TLabel;
    dlgSave:            TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rgModeClick(Sender: TObject);
    procedure rgGP3VersionClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure cbRCRChange(Sender: TObject);
    procedure cbLiveryChange(Sender: TObject);
    procedure cbChassisChange(Sender: TObject);
    procedure cbTyreChange(Sender: TObject);
    procedure cbHelmetChange(Sender: TObject);
    procedure btnRenderClick(Sender: TObject);
    procedure btnExportSheetClick(Sender: TObject);
    procedure btnExportPerEntryClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnZoomResetClick(Sender: TObject);
  private
    FSettings:       TJamRCRSettings;
    FInitialJamPath: string;
    FRendered:       TBitmap;
    FJam, FMaskJam:  TJamFile;            // owned; freed in FormDestroy
    FLivery, FChassis, FTyre, FHelmet: TBitmap;
    FHelmetIDs:     TArray<Word>;
    FHelmetSources: TArray<string>;
    FZoom:          Double;
    FUpdating:      Boolean;        // suppresses auto-render during bulk
                                    // combo repopulation in RefreshAll
    procedure ApplyZoom;
    function CurrentMode: TRCRMode;
    function VersionLabel: string;
    procedure RefreshAll;
    procedure PopulateHelmetCombo;
    procedure UpdatePairLabel;
    procedure FreeAllCached;
    procedure PreselectFromInitialJam;
    function BuildOptions: TRCRRenderOptions;
    procedure DoRender;
  public
    // Opens the dialog modally. `JamPath` is the filename of the JAM the
    // main app currently has open; the dialog uses it to preselect a
    // combo entry but otherwise runs in complete isolation from the
    // editor — it loads its own TJamFile instances via LoadIsolatedJam
    // so the editor's currently-loaded JAM and its UI flags are never
    // touched. Pass '' to open with the default selections.
    class procedure Execute(Owner: TForm; const JamPath: string = '');
  end;

implementation

{$R *.dfm}

class procedure TJamRCRRenderDlgForm.Execute(Owner: TForm;
  const JamPath: string);
var
  dlg: TJamRCRRenderDlgForm;
begin
  dlg := TJamRCRRenderDlgForm.Create(Owner);
  try
    dlg.FInitialJamPath := JamPath;
    dlg.PreselectFromInitialJam;
    dlg.ShowModal;
  finally
    dlg.Free;
  end;
end;

function TJamRCRRenderDlgForm.CurrentMode: TRCRMode;
begin
  case rgMode.ItemIndex of
    0: Result := rcrGP2;
    1: Result := rcrGP3Single;
  else
    Result := rcrGP3Multi;
  end;
end;

function TJamRCRRenderDlgForm.VersionLabel: string;
begin
  if FSettings.GP3Version = gp3v2000 then
    Result := 'GP3 2000'
  else
    Result := 'GP3';
end;

procedure TJamRCRRenderDlgForm.FreeAllCached;
begin
  FreeAndNil(FJam);
  FreeAndNil(FMaskJam);
  FreeAndNil(FLivery);
  FreeAndNil(FChassis);
  FreeAndNil(FTyre);
  FreeAndNil(FHelmet);
end;

// Re-select `preferred` in combo if it exists (case-insensitive),
// otherwise fall back to the first item. Used by RefreshAll to keep the
// user's picks alive across version / mode flips when the file is still
// available under the new settings.
procedure RestoreOrFirst(combo: TComboBox; const preferred: string);
var
  i: Integer;
begin
  if preferred <> '' then
    for i := 0 to combo.Items.Count - 1 do
      if SameText(combo.Items[i], preferred) then
      begin
        combo.ItemIndex := i;
        Exit;
      end;
  if combo.Items.Count > 0 then combo.ItemIndex := 0;
end;

procedure TJamRCRRenderDlgForm.RefreshAll;
var
  mode: TRCRMode;
  prevRCR, prevLivery, prevChassis, prevTyre, prevHelmet: string;

  function CurrentText(c: TComboBox): string;
  begin
    if c.ItemIndex >= 0 then Result := c.Items[c.ItemIndex]
    else                    Result := '';
  end;

begin
  FUpdating := True;

  // Snapshot the current selections so version/mode flips can preserve
  // them when the same file still exists in the new picker set.
  prevRCR     := CurrentText(cbRCR);
  prevLivery  := CurrentText(cbLivery);
  prevChassis := CurrentText(cbChassis);
  prevTyre    := CurrentText(cbTyre);
  prevHelmet  := CurrentText(cbHelmet);

  FSettings := LoadRCRSettings;
  if FSettings.GP3Version = gp3v2000 then
    rgGP3Version.ItemIndex := 1
  else
    rgGP3Version.ItemIndex := 0;
  lblFolders.Caption :=
    'GP2: '          + FSettings.GP2Folder         + sLineBreak +
    'GP3 main: '     + FSettings.GP3MainFolder     + sLineBreak +
    'GP3 liveries: ' + FSettings.GP3LiveriesFolder + sLineBreak +
    'Version: '      + VersionLabel;

  mode := CurrentMode;

  cbRCR.Items.BeginUpdate;
  try
    cbRCR.Clear;
    case mode of
      rcrGP2:
        cbRCR.Items.AddStrings(ExistingGP2RCRs(FSettings.GP2Folder));
      rcrGP3Single:
        if FileExists(IncludeTrailingPathDelimiter(FSettings.GP3MainFolder)
                      + 'Chwheel1.jam') then
          cbRCR.Items.Add('Chwheel1.jam');
      rcrGP3Multi:
        cbRCR.Items.AddStrings(ExistingGP3MultiRCRs(FSettings.GP3MainFolder));
    end;
    RestoreOrFirst(cbRCR, prevRCR);
  finally
    cbRCR.Items.EndUpdate;
  end;

  cbLivery.Items.BeginUpdate;
  try
    cbLivery.Clear;
    case mode of
      rcrGP2:
        cbLivery.Items.AddStrings(ExistingGP2Liveries(FSettings.GP2Folder));
      rcrGP3Multi:
        cbLivery.Items.AddStrings(
          ExistingGP3Liveries(FSettings.GP3LiveriesFolder, FSettings.GP3Version));
    end;
    cbLivery.Enabled := mode in [rcrGP2, rcrGP3Multi];
    RestoreOrFirst(cbLivery, prevLivery);
  finally
    cbLivery.Items.EndUpdate;
  end;

  cbChassis.Items.BeginUpdate;
  try
    cbChassis.Clear;
    if (mode = rcrGP3Multi) and FileExists(
         IncludeTrailingPathDelimiter(FSettings.GP3MainFolder) + 'Chassis3.jam') then
      cbChassis.Items.Add('Chassis3.jam');
    cbChassis.Enabled := mode = rcrGP3Multi;
    RestoreOrFirst(cbChassis, prevChassis);
  finally
    cbChassis.Items.EndUpdate;
  end;

  cbTyre.Items.BeginUpdate;
  try
    cbTyre.Clear;
    if mode in [rcrGP3Single, rcrGP3Multi] then
      cbTyre.Items.AddStrings(
        ExistingGP3Tyres(FSettings.GP3MainFolder, FSettings.GP3Version));
    cbTyre.Enabled := mode in [rcrGP3Single, rcrGP3Multi];
    RestoreOrFirst(cbTyre, prevTyre);
  finally
    cbTyre.Items.EndUpdate;
  end;

  PopulateHelmetCombo;
  RestoreOrFirst(cbHelmet, prevHelmet);
  cbHelmet.Enabled := mode = rcrGP3Multi;

  FreeAllCached;
  UpdatePairLabel;
  FUpdating := False;
  // Render with the new selections so the user sees output immediately.
  if cbRCR.ItemIndex >= 0 then DoRender;
end;

procedure TJamRCRRenderDlgForm.PopulateHelmetCombo;

  procedure AddFromFile(const Path, SourceTag: string);
  var
    jam: TJamFile;
    i, n: Integer;
  begin
    jam := LoadIsolatedJam(Path);
    if jam = nil then Exit;
    try
      for i := 0 to jam.FEntries.Count - 1 do
      begin
        n := Length(FHelmetIDs);
        SetLength(FHelmetIDs,     n + 1);
        SetLength(FHelmetSources, n + 1);
        FHelmetIDs[n]     := jam.FEntries[i].FInfo.JamID;
        FHelmetSources[n] := SourceTag;
        cbHelmet.Items.Add(Format('%d - Helmets%s.jam',
          [jam.FEntries[i].FInfo.JamID, SourceTag]));
      end;
    finally
      jam.Free;
    end;
  end;

var
  liveriesDir: string;
begin
  cbHelmet.Items.BeginUpdate;
  try
    cbHelmet.Clear;
    SetLength(FHelmetIDs, 0);
    SetLength(FHelmetSources, 0);
    liveriesDir := IncludeTrailingPathDelimiter(FSettings.GP3LiveriesFolder);
    AddFromFile(liveriesDir + 'Helmetsd.jam', 'd');
    AddFromFile(liveriesDir + 'Helmetse.jam', 'e');
    if cbHelmet.Items.Count > 0 then cbHelmet.ItemIndex := 0;
  finally
    cbHelmet.Items.EndUpdate;
  end;
end;

procedure TJamRCRRenderDlgForm.UpdatePairLabel;
var
  base: string;
begin
  lblPair.Caption := '';
  if (CurrentMode = rcrGP3Multi) and (cbRCR.ItemIndex >= 0) then
  begin
    base := LowerCase(ChangeFileExt(cbRCR.Items[cbRCR.ItemIndex], ''));
    if EndsText('a', base) then
      lblPair.Caption := '-> paired with ' +
        Copy(base, 1, Length(base) - 1) + 'b.jam';
  end;
end;

// If FInitialJamPath matches an entry in cbRCR (after mode auto-detection),
// pick it as the initial combo selection.
procedure TJamRCRRenderDlgForm.PreselectFromInitialJam;
var
  initialName: string;
  i: Integer;
  partner: string;
  detected: TRCRMode;
begin
  if FInitialJamPath = '' then Exit;
  initialName := ExtractFileName(FInitialJamPath);
  if initialName = '' then Exit;

  detected := DetectRCRMode(initialName, partner);
  rgMode.ItemIndex := Ord(detected);
  RefreshAll;

  for i := 0 to cbRCR.Items.Count - 1 do
    if SameText(cbRCR.Items[i], initialName) then
    begin
      cbRCR.ItemIndex := i;
      UpdatePairLabel;
      Break;
    end;
end;

// Form lifecycle.

procedure TJamRCRRenderDlgForm.FormCreate(Sender: TObject);
begin
  FZoom := 1.0;
  imgPreview.AutoSize := False;
  imgPreview.Stretch  := True;
  RefreshAll;
  lblStatus.Caption := 'Ready';
end;

procedure TJamRCRRenderDlgForm.FormDestroy(Sender: TObject);
begin
  FRendered.Free;
  FreeAllCached;
end;

procedure TJamRCRRenderDlgForm.rgModeClick(Sender: TObject);
begin
  RefreshAll;
end;

procedure TJamRCRRenderDlgForm.rgGP3VersionClick(Sender: TObject);
var
  rcr: TJamRCRSettings;
begin
  if FUpdating then Exit;
  // Persist via JamRCRSettings so the Options form picks up the same
  // value on its next FormShow, then refresh local pickers (livery list
  // and tyre list both change with version).
  rcr := LoadRCRSettings;
  if rgGP3Version.ItemIndex = 1 then
    rcr.GP3Version := gp3v2000
  else
    rcr.GP3Version := gp3v1998;
  SaveRCRSettings(rcr);
  RefreshAll;
end;

procedure TJamRCRRenderDlgForm.btnOptionsClick(Sender: TObject);
begin
  // The existing Options form is application-wide; surface it from here
  // so the user can edit GP2/GP3 root paths or toggle GP3 version
  // without leaving the render dialog. RefreshAll picks up changes when
  // it closes.
  optionsForm.ShowModal;
  RefreshAll;
end;

procedure TJamRCRRenderDlgForm.cbRCRChange(Sender: TObject);
begin
  FreeAndNil(FJam);
  FreeAndNil(FMaskJam);
  UpdatePairLabel;
  if not FUpdating then DoRender;
end;

procedure TJamRCRRenderDlgForm.cbLiveryChange(Sender: TObject);
begin
  FreeAndNil(FLivery);
  if not FUpdating then DoRender;
end;

procedure TJamRCRRenderDlgForm.cbChassisChange(Sender: TObject);
begin
  FreeAndNil(FChassis);
  if not FUpdating then DoRender;
end;

procedure TJamRCRRenderDlgForm.cbTyreChange(Sender: TObject);
begin
  FreeAndNil(FTyre);
  if not FUpdating then DoRender;
end;

procedure TJamRCRRenderDlgForm.cbHelmetChange(Sender: TObject);
begin
  FreeAndNil(FHelmet);
  if not FUpdating then DoRender;
end;

// Render path.

function TJamRCRRenderDlgForm.BuildOptions: TRCRRenderOptions;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Mode := CurrentMode;
  Result.Textures.Livery  := FLivery;
  Result.Textures.Chassis := FChassis;
  Result.Textures.Tyre    := FTyre;
  Result.Textures.Helmet  := FHelmet;
  Result.Background := DefaultBackgroundFor(Result.Mode);
end;

procedure TJamRCRRenderDlgForm.DoRender;

  function RCRFolder: string;
  begin
    if CurrentMode = rcrGP2 then Result := FSettings.GP2Folder
    else                         Result := FSettings.GP3MainFolder;
  end;

  function LiveryFolder: string;
  begin
    if CurrentMode = rcrGP2 then Result := FSettings.GP2Folder
    else                         Result := FSettings.GP3LiveriesFolder;
  end;

var
  Opts: TRCRRenderOptions;
  startTick: Cardinal;
  rcrPath, pairPath, liveryPath, chassisPath, tyrePath: string;
  base: string;
  helmetIdx: Integer;
begin
  if cbRCR.ItemIndex < 0 then
  begin
    lblStatus.Caption := 'No RCR JAM selected';
    Exit;
  end;

  rcrPath := IncludeTrailingPathDelimiter(RCRFolder)
             + cbRCR.Items[cbRCR.ItemIndex];
  if FJam = nil then
  begin
    FJam := LoadIsolatedJam(rcrPath);
    if FJam = nil then
    begin
      lblStatus.Caption := 'Failed to load RCR JAM: ' + rcrPath;
      Exit;
    end;
  end;

  if (CurrentMode = rcrGP3Multi) and (FMaskJam = nil) then
  begin
    base := LowerCase(ChangeFileExt(cbRCR.Items[cbRCR.ItemIndex], ''));
    pairPath := IncludeTrailingPathDelimiter(FSettings.GP3MainFolder)
                + Copy(base, 1, Length(base) - 1) + 'b.jam';
    FMaskJam := LoadIsolatedJam(pairPath);
    if FMaskJam = nil then
    begin
      lblStatus.Caption := 'Failed to load partner mask: ' + pairPath;
      Exit;
    end;
  end;

  if cbLivery.Enabled and (FLivery = nil) and (cbLivery.ItemIndex >= 0) then
  begin
    liveryPath := IncludeTrailingPathDelimiter(LiveryFolder)
                  + cbLivery.Items[cbLivery.ItemIndex];
    try
      FLivery := LoadTextureBitmap(liveryPath, CurrentMode);
    except
      on E: Exception do
      begin
        FreeAndNil(FLivery);
        lblStatus.Caption := 'Livery load failed: ' + E.Message;
        Exit;
      end;
    end;
  end;

  if cbChassis.Enabled and (FChassis = nil) and (cbChassis.ItemIndex >= 0) then
  begin
    chassisPath := IncludeTrailingPathDelimiter(FSettings.GP3MainFolder)
                   + cbChassis.Items[cbChassis.ItemIndex];
    try
      FChassis := LoadTextureBitmap(chassisPath, CurrentMode);
    except
      on E: Exception do
      begin
        FreeAndNil(FChassis);
        lblStatus.Caption := 'Chassis load failed: ' + E.Message;
        Exit;
      end;
    end;
  end;

  if cbTyre.Enabled and (FTyre = nil) and (cbTyre.ItemIndex >= 0) then
  begin
    tyrePath := IncludeTrailingPathDelimiter(FSettings.GP3MainFolder)
                + cbTyre.Items[cbTyre.ItemIndex];
    try
      FTyre := LoadTextureBitmap(tyrePath, CurrentMode);
    except
      on E: Exception do
      begin
        FreeAndNil(FTyre);
        lblStatus.Caption := 'Tyre load failed: ' + E.Message;
        Exit;
      end;
    end;
  end;

  if cbHelmet.Enabled and (FHelmet = nil) and (cbHelmet.ItemIndex >= 0) then
  begin
    helmetIdx := cbHelmet.ItemIndex;
    if (helmetIdx >= 0) and (helmetIdx <= High(FHelmetIDs)) then
    begin
      try
        FHelmet := LoadHelmetByJamID(
          IncludeTrailingPathDelimiter(FSettings.GP3LiveriesFolder)
            + 'Helmetsd.jam',
          IncludeTrailingPathDelimiter(FSettings.GP3LiveriesFolder)
            + 'Helmetse.jam',
          FHelmetIDs[helmetIdx]);
      except
        on E: Exception do
        begin
          FreeAndNil(FHelmet);
          lblStatus.Caption := 'Helmet load failed: ' + E.Message;
          Exit;
        end;
      end;
      if FHelmet = nil then
      begin
        lblStatus.Caption := Format(
          'Helmet JamID %d not found in either file',
          [FHelmetIDs[helmetIdx]]);
        Exit;
      end;
    end;
  end;

  Opts := BuildOptions;

  startTick := GetTickCount;
  try
    FreeAndNil(FRendered);
    FRendered := RenderRCRFromJam(FJam, Opts, FMaskJam);
    ApplyZoom;
    lblStatus.Caption := Format('Rendered in %dms - %dx%d - %d entries',
      [GetTickCount - startTick, FRendered.Width, FRendered.Height,
       FJam.FEntries.Count]);
  except
    on E: Exception do
      lblStatus.Caption := 'Render failed: ' + E.Message;
  end;
end;

procedure TJamRCRRenderDlgForm.btnRenderClick(Sender: TObject);
begin
  DoRender;
end;

// Zoom is a simple scaling step (1.5x in/out, no animation). The bitmap
// stays at native resolution in FRendered; imgPreview just stretches it.
procedure TJamRCRRenderDlgForm.ApplyZoom;
begin
  if FRendered = nil then Exit;
  if FZoom < 0.05 then FZoom := 0.05;
  if FZoom > 16   then FZoom := 16;
  imgPreview.Width  := Max(1, Round(FRendered.Width  * FZoom));
  imgPreview.Height := Max(1, Round(FRendered.Height * FZoom));
  imgPreview.Picture.Assign(FRendered);
end;

procedure TJamRCRRenderDlgForm.btnZoomInClick(Sender: TObject);
begin
  FZoom := FZoom * 1.5;
  ApplyZoom;
end;

procedure TJamRCRRenderDlgForm.btnZoomOutClick(Sender: TObject);
begin
  FZoom := FZoom / 1.5;
  ApplyZoom;
end;

procedure TJamRCRRenderDlgForm.btnZoomResetClick(Sender: TObject);
begin
  FZoom := 1.0;
  ApplyZoom;
end;

procedure TJamRCRRenderDlgForm.btnExportSheetClick(Sender: TObject);
var
  png: TPngImage;
  defaultName: string;
begin
  if FRendered = nil then DoRender;
  if FRendered = nil then
  begin
    lblStatus.Caption := 'Nothing rendered yet';
    Exit;
  end;
  defaultName :=
    ChangeFileExt(cbRCR.Items[cbRCR.ItemIndex], '') + '_' +
    IfThen(cbLivery.Enabled and (cbLivery.ItemIndex >= 0),
      ChangeFileExt(cbLivery.Items[cbLivery.ItemIndex], ''),
      'plain') + '.png';
  dlgSave.Filter := 'PNG (*.png)|*.png|Bitmap (*.bmp)|*.bmp';
  dlgSave.DefaultExt := 'png';
  dlgSave.FileName := defaultName;
  if not dlgSave.Execute then Exit;
  if SameText(ExtractFileExt(dlgSave.FileName), '.bmp') then
    FRendered.SaveToFile(dlgSave.FileName)
  else
  begin
    png := TPngImage.Create;
    try
      png.Assign(FRendered);
      png.SaveToFile(dlgSave.FileName);
    finally
      png.Free;
    end;
  end;
  lblStatus.Caption := 'Saved: ' + dlgSave.FileName;
end;

procedure TJamRCRRenderDlgForm.btnExportPerEntryClick(Sender: TObject);
var
  dir, baseName, outPath: string;
  Opts: TRCRRenderOptions;
  i, exported, skipped: Integer;
  entry: TJamEntry;
  bmp: TBitmap;
  png: TPngImage;
begin
  if not Assigned(FJam) then
  begin
    DoRender;
    if not Assigned(FJam) then Exit;
  end;
  dir := '';
  if not SelectDirectory('Pick output folder for per-entry export',
    '', dir, [sdNewUI, sdShowEdit]) then
    Exit;

  Opts := BuildOptions;
  baseName := ChangeFileExt(cbRCR.Items[cbRCR.ItemIndex], '');
  exported := 0;
  skipped := 0;
  for i := 0 to FJam.FEntries.Count - 1 do
  begin
    entry := FJam.FEntries[i];
    if (entry.FInfo.Width = 0) or (entry.FInfo.Height = 0) then
    begin
      Inc(skipped);
      Continue;
    end;
    bmp := nil;
    try
      bmp := RenderRCREntryFromJam(FJam, i, Opts, FMaskJam);
      outPath := IncludeTrailingPathDelimiter(dir) +
        Format('%s_%d.png', [baseName, entry.FInfo.JamID]);
      png := TPngImage.Create;
      try
        png.Assign(bmp);
        png.SaveToFile(outPath);
      finally
        png.Free;
      end;
      Inc(exported);
    finally
      bmp.Free;
    end;
    lblStatus.Caption := Format('Exporting %d/%d...',
      [i + 1, FJam.FEntries.Count]);
    Application.ProcessMessages;
  end;
  lblStatus.Caption := Format('Per-entry export done: %d exported, %d skipped',
    [exported, skipped]);
end;

end.
