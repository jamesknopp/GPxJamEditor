unit MainForm;

interface

uses
        Winapi.Windows, Winapi.Messages,
        System.SysUtils, System.Classes, System.Math, Registry, IOUtils,
        clipbrd,

        Vcl.Graphics, Vcl.Controls, Vcl.Forms,
        Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
        Vcl.StdCtrls, Vcl.NumberBox, Vcl.ExtDlgs,
        Vcl.Menus, Vcl.ImgList, Vcl.ImageCollection,
        Vcl.VirtualImageList, System.Generics.Collections,

        JamGeneral, JamSW, JamHW, JamPalette, JamAnalysis, GeneralHelpers,
        newJamDlg,
        Vcl.Samples.Spin, Vcl.CheckLst, Vcl.ToolWin, Vcl.BaseImageCollection,
        System.ImageList, jampalettedetector, jambatch, options, about,
        JamRCRRenderDlg;

type

        TJamTreeNodeID = (jamDimensions, jamPosX, jamposY, jamFlags, jamColour,
          jamUnk, jamID, canvasDimensions, rootNode, jamwidth, jamheight,
          jamData, jamPalInfo);

        TJamTreeNode = class
                data: integer;
                jamID: integer;
                editNode: boolean;
                nodeType: TJamTreeNodeID;
        end;

type
        TResizeMode = (rmNone, rmMove, rmTopLeft, rmTop, rmTopRight, rmRight,
          rmBottomRight, rmBottom, rmBottomLeft, rmLeft);

        TDragState = record
                Active: Boolean;
                Mode: TResizeMode;
                StartX, StartY, StartW, StartH: Integer;
                StartMouseX, StartMouseY: Integer;
                AspectRatio: Double;
        end;

        PJamTreeNode = ^TJamTreeNode;

        TFormMain = class(TForm)
                JamTree: TTreeView;
                dlgOpenJam: TOpenDialog;
                ScrollBox1: TScrollBox;
                ImageCanvas: TImage;
                dlgSaveJam: TSaveDialog;
                canvasPopupMenu: TPopupMenu;
                popupImportTexture: TMenuItem;
                popupExportTexture: TMenuItem;
                popupExportAllTextures: TMenuItem;
                importDialog: TOpenPictureDialog;
                exportDialog: TSaveDialog;
                MainMenu1: TMainMenu;
                File1: TMenuItem;
                Edit1: TMenuItem;
                Image1: TMenuItem;
                New1: TMenuItem;
                Open1: TMenuItem;
                mainMenuClose: TMenuItem;
                N1: TMenuItem;
                mainMenuSave: TMenuItem;
                mainMenuSaveAs: TMenuItem;
                N2: TMenuItem;
                N3: TMenuItem;
                Exit1: TMenuItem;
                N4: TMenuItem;
                Browser1: TMenuItem;
                mainMenuAddTexture: TMenuItem;
                N5: TMenuItem;
                mainMenuCut: TMenuItem;
                mainMenuCopy: TMenuItem;
                mainMenuPaste: TMenuItem;
                N6: TMenuItem;
                mainMenuModifyPalette: TMenuItem;
                N7: TMenuItem;
                mainMenuTextureProperties: TMenuItem;
                mainMenuImportTexture: TMenuItem;
                mainMenuImportCanvas: TMenuItem;
                N8: TMenuItem;
                mainMenuExportTexture: TMenuItem;
                mainMenuExportCanvas: TMenuItem;
                mainMenuExportAllTextures: TMenuItem;
                Help1: TMenuItem;
                About1: TMenuItem;
                ToolBar1: TToolBar;
                toolbar_NEW: TToolButton;
                toolbar_OPEN: TToolButton;
                toolBar_Save: TToolButton;
                ToolButton4: TToolButton;
                toolBar_AddTexture: TToolButton;
                toolBar_DeleteTexture: TToolButton;
                ToolButton7: TToolButton;
                toolBar_ImportTexture: TToolButton;
                toolBar_ExportTexture: TToolButton;
                ToolButton10: TToolButton;
                toolBar_GP2PAL: TToolButton;
                Splitter1: TSplitter;
                StatusBar1: TStatusBar;
                toolBar_GP3PAL: TToolButton;
                ToolButton11: TToolButton;
                toolBar_PalPrev: TToolButton;
                toolBar_Pal1: TToolButton;
                toolBar_Pal2: TToolButton;
                toolBar_Pal3: TToolButton;
                toolBar_Pal4: TToolButton;
                toolBar_PalNext: TToolButton;
                toolBarImageList: TVirtualImageList;
                ImageCollection1: TImageCollection;
                leftPanel: TPanel;
                timer_JamRedrawPals: TTimer;
                timer_redrawTree: TTimer;
                N9: TMenuItem;
                popUpAddTexture: TMenuItem;
                N10: TMenuItem;
                popUpDeleteTexture: TMenuItem;
                N11: TMenuItem;
                mainMenuDeleteTexture: TMenuItem;
                mnuRecentFiles: TMenuItem;
                ools1: TMenuItem;
                BatchConvert1: TMenuItem;
                View1: TMenuItem;
                View2: TMenuItem;
                N12: TMenuItem;
                ResetZoom1: TMenuItem;
                N13: TMenuItem;
                menuDrawOutlines: TMenuItem;
                menuSnap: TMenuItem;
                menuCheckerboard: TMenuItem;
                menuDPIScale: TMenuItem;
                treeimagecollection: TImageCollection;
                treeimagelist: TVirtualImageList;
                toolbar_drawOutlines: TToolButton;
                toolbarSnap: TToolButton;
                toolbarCheckerboard: TToolButton;
                ToolButton12: TToolButton;
                toolbarBatch: TToolButton;
                toolbarAutoPack: TToolButton;
                toolbarJamAnalysis: TToolButton;
                toolbarRenderRCR: TToolButton;
                ToolButton5: TToolButton;
                toolbarZoomIN: TToolButton;
                ToolButton6: TToolButton;
                toolbarZoomOUT: TToolButton;
                toolbarZoomReset: TToolButton;
    toolbarMove: TToolButton;
                ToolButton8: TToolButton;
                N14: TMenuItem;
                Undo1: TMenuItem;
                Redo1: TMenuItem;
                N15: TMenuItem;
                PreviewMask1: TMenuItem;
                N16: TMenuItem;
                ConverttoGP2JAM: TMenuItem;
                ConverttoGP3SWJAM: TMenuItem;
                ConverttoGP3HWJAM: TMenuItem;
                panel_TexProperties_Generic: TPanel;
                Label5: TLabel;
                Label6: TLabel;
                Label7: TLabel;
                Label8: TLabel;
                Label9: TLabel;
                tex_height: TSpinEdit;
                tex_ID: TSpinEdit;
                tex_width: TSpinEdit;
                tex_X: TSpinEdit;
                tex_Y: TSpinEdit;
                panel_flags: TPanel;
                tex_flags: TCheckListBox;
                chkShowAdvancedFlags: TCheckBox;
                panel_TexPreview: TPanel;
                ImageEntry: TImage;
                panel_PalPreview: TPanel;
                PaintBoxPalette: TPaintBox;
                panel_PaletteEdit: TPanel;
                Label2: TLabel;
                Label1: TLabel;
                Label3: TLabel;
                comboSimpMethod: TComboBox;
                chkBoxSimpPal: TCheckBox;
                chkBoxTrans: TCheckBox;
                numBox_BlurAmount: TNumberBox;
                numBox_SimpThresh: TNumberBox;
                btnRemovePal: TButton;
                btnPal0: TButton;
                btnPal1: TButton;
                btnPal2: TButton;
                btnPal3: TButton;
                btnRemoveAllPals: TButton;
                btnGenPal: TButton;
                btnRegenAllPals: TButton;
                panel_RCR: TPanel;
                Label11: TLabel;
                rcrOdd: TButton;
                rcrEven: TButton;
                rcrReset: TButton;
                panel_TexScaling: TPanel;
                Label13: TLabel;
                Label14: TLabel;
                Label15: TLabel;
                scaleFlags: TCheckListBox;
                texScaleX: TSpinEdit;
                texScaleY: TSpinEdit;
                texScale: TSpinEdit;
                canvasHeight: TSpinEdit;
                Button5: TButton;
                panelCanvasBar: TPanel;
                lblCanvasPrefix: TLabel;
                lblCanvasSize: TLabel;
                lblCanvasHeightLbl: TLabel;
                lblCanvasZoom: TLabel;
                CategoryPanelGroup1: TCategoryPanelGroup;
                panel_TexturePreview: TCategoryPanel;
                Panel_TexProperties: TCategoryPanel;
                panel_TexFlags: TCategoryPanel;
                panel_ScaleParameters: TCategoryPanel;
                panel_PalEdit: TCategoryPanel;
                panel_RCRControls: TCategoryPanel;
                N17: TMenuItem;
                JamAnalysis1: TMenuItem;
                N19: TMenuItem;
                RenderRCR1: TMenuItem;
                SaveDecryptedJAM: TMenuItem;
                N18: TMenuItem;
                autoPackTexs: TMenuItem;
                undoTimer: TTimer;
                timerZoom: TTimer;
                Button1: TButton;
                Button2: TButton;
                procedure JamTreeChange(Sender: TObject; Node: TTreeNode);
                procedure PaintBoxPalettePaint(Sender: TObject);
                procedure btnLoadJamClick(Sender: TObject);
                procedure btnGP2palClick(Sender: TObject);
                procedure btnGP3palClick(Sender: TObject);
                procedure btnPal0Click(Sender: TObject);
                procedure btnPal1Click(Sender: TObject);
                procedure btnPal2Click(Sender: TObject);
                procedure btnPal3Click(Sender: TObject);
                procedure FormCreate(Sender: TObject);
                procedure btnDrawDataClick(Sender: TObject);
                procedure ImageCanvasMouseDown(Sender: TObject;
                  Button: TMouseButton; Shift: TShiftState; X, Y: integer);

                procedure btnSaveJamClick(Sender: TObject);
                procedure ImportTexture(Sender: TObject);
                procedure btnExportTextureClick(Sender: TObject);
                procedure toolBar_PalPrevClick(Sender: TObject);
                procedure toolBar_PalNextClick(Sender: TObject);
                procedure numBox_SimpThreshChange(Sender: TObject);
                procedure numBox_BlurAmountChange(Sender: TObject);
                procedure btnGenPalClick(Sender: TObject);
                procedure btnRemovePalClick(Sender: TObject);
                procedure Browser1Click(Sender: TObject);
                procedure Splitter2Paint(Sender: TObject);
                procedure tex_flagsClickCheck(Sender: TObject);
                procedure chkShowAdvancedFlagsClick(Sender: TObject);
                procedure RebuildFlagsList;
                procedure tex_IDChange(Sender: TObject);
                procedure tex_XChange(Sender: TObject);
                procedure tex_YChange(Sender: TObject);
                procedure tex_widthChange(Sender: TObject);
                procedure tex_heightChange(Sender: TObject);
                procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
                  WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
                procedure ScrollBox1Click(Sender: TObject);
                procedure ScrollBox1Resize(Sender: TObject);
                procedure rcrOddClick(Sender: TObject);
                procedure rcrEvenClick(Sender: TObject);
                procedure rcrResetClick(Sender: TObject);
                procedure AddNewTexture(Sender: TObject);
                procedure JamTreeDeletion(Sender: TObject; Node: TTreeNode);
                procedure JamTreeAdvancedCustomDrawItem(Sender: TCustomTreeView;
                  Node: TTreeNode; State: TCustomDrawState;
                  Stage: TCustomDrawStage;
                  var PaintImages, DefaultDraw: boolean);
                procedure mainMenuAddTextureClick(Sender: TObject);
                procedure mainMenuImportTextureClick(Sender: TObject);
                procedure timer_JamRedrawPalsTimer(Sender: TObject);
                procedure timer_redrawTreeTimer(Sender: TObject);
                procedure toolbar_NEWClick(Sender: TObject);
                procedure popUpDeleteTextureClick(Sender: TObject);

                procedure mainMenuExportCanvasClick(Sender: TObject);
                procedure mainMenuExportAllTexturesClick(Sender: TObject);
                procedure canvasPopupMenuPopup(Sender: TObject);
                procedure FormDestroy(Sender: TObject);
                procedure BatchConvert1Click(Sender: TObject);
                procedure View2Click(Sender: TObject);
                procedure ResetZoom1Click(Sender: TObject);
                procedure btnRemoveAllPalsClick(Sender: TObject);
                procedure FormCloseQuery(Sender: TObject;
                  var CanClose: boolean);
                procedure btnRegenAllPalsClick(Sender: TObject);
                procedure Exit1Click(Sender: TObject);
                function GetActiveJamFileName: string;
                function GetEntryJamID(EntryIndex: Integer): Word;
                function GetActiveEntryCount: Integer;
                procedure toolbar_drawOutlinesClick(Sender: TObject);
                procedure toolbarMoveClick(Sender: TObject);
                procedure toolbarSnapClick(Sender: TObject);
                procedure menuSnapClick(Sender: TObject);
                procedure toolbarCheckerboardClick(Sender: TObject);
                procedure menuCheckerboardClick(Sender: TObject);
                procedure menuDPIScaleClick(Sender: TObject);
                procedure ImageCanvasMouseMove(Sender: TObject;
                  Shift: TShiftState; X, Y: integer);
                procedure ImageCanvasDblClick(Sender: TObject);
                procedure timerZoomTimer(Sender: TObject);
                procedure toolBar_GP3PALMouseUp(Sender: TObject;
                  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
                procedure toolBar_GP2PALMouseUp(Sender: TObject;
                  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
                procedure toolbarZoomINClick(Sender: TObject);
                procedure toolbarZoomResetClick(Sender: TObject);
                procedure toolbarZoomOUTClick(Sender: TObject);
                procedure menuDrawOutlinesClick(Sender: TObject);
                procedure ShowHintInStatusBar(Sender: TObject);
                procedure ImageCanvasMouseUp(Sender: TObject;
                  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
                procedure mainMenuSaveAsClick(Sender: TObject);
                procedure Button4Click(Sender: TObject);
                procedure FormKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure FormKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_XKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_XKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure mainMenuCopyClick(Sender: TObject);
                procedure mainMenuPasteClick(Sender: TObject);
                procedure MainMenu1Change(Sender: TObject; Source: TMenuItem;
                  Rebuild: boolean);
                procedure JamTreeMouseDown(Sender: TObject;
                  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
                procedure tex_IDKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_YKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_widthKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_heightKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_IDKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_YKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_widthKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure tex_heightKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure mainMenuCutClick(Sender: TObject);
                procedure Button5Click(Sender: TObject);
                procedure Button6Click(Sender: TObject);
                procedure mainMenuDeleteTextureClick(Sender: TObject);
                procedure Undo1Click(Sender: TObject);
                procedure Redo1Click(Sender: TObject);
                procedure PreviewMask1Click(Sender: TObject);
                procedure ConverttoGP2JAMClick(Sender: TObject);
                procedure ConverttoGP3SWJAMClick(Sender: TObject);
                procedure ConverttoGP3HWJAMClick(Sender: TObject);
                procedure scaleFlagsClickCheck(Sender: TObject);
                procedure texScaleXChange(Sender: TObject);
                procedure texScaleYChange(Sender: TObject);
                procedure texScaleChange(Sender: TObject);
                procedure texScaleKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure texScaleXKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure texScaleYKeyDown(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure texScaleKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure texScaleXKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure texScaleYKeyUp(Sender: TObject; var Key: Word;
                  Shift: TShiftState);
                procedure Panel_TexPropertiesCollapse(Sender: TObject);
                procedure Panel_TexPropertiesExpand(Sender: TObject);
                procedure panel_TexFlagsCollapse(Sender: TObject);
                procedure panel_PalEditCollapse(Sender: TObject);
                procedure panel_PalEditExpand(Sender: TObject);
                procedure panel_RCRControlsCollapse(Sender: TObject);
                procedure panel_RCRControlsExpand(Sender: TObject);
                procedure panel_ScaleParametersCollapse(Sender: TObject);
                procedure panel_ScaleParametersExpand(Sender: TObject);
                procedure panel_TexFlagsExpand(Sender: TObject);
                procedure panel_TexturePreviewExpand(Sender: TObject);
                procedure panel_TexturePreviewCollapse(Sender: TObject);
                procedure JamAnalysis1Click(Sender: TObject);
                procedure RenderRCR1Click(Sender: TObject);
                procedure SaveDecryptedJAMClick(Sender: TObject);
                procedure mainMenuImportCanvasClick(Sender: TObject);
                procedure autoPackTexsClick(Sender: TObject);
                procedure undoTimerTimer(Sender: TObject);
                procedure tex_XMouseDown(Sender: TObject; Button: TMouseButton;
                  Shift: TShiftState; X, Y: integer);
                procedure tex_XMouseUp(Sender: TObject; Button: TMouseButton;
                  Shift: TShiftState; X, Y: integer);
                procedure canvasHeightChange(Sender: TObject);
                procedure Button1Click(Sender: TObject);
                procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure About1Click(Sender: TObject);

                // Form-level WM_MOVE handler — fires in the form's own WndProc
                // so it is guaranteed to run whenever this window is repositioned,
                // regardless of DPI-awareness mode or Application.OnMessage quirks.
                procedure WMFormMove(var Msg: TMessage); message WM_MOVE;

                // Receives a file path forwarded by a second instance
                // (see jamviewer.dpr); prompts, then opens it.
                procedure WMCopyData(var Msg: TWMCopyData);
                  message WM_COPYDATA;

        public
                FJamFile: TJamFile;
                FHWJamFile: THWJamFile;
                UpdatingFromCode: boolean;
                SelectFromCanvas: boolean;

                MRUList: TStringList;

                procedure CopyJAM(Entries: TList<TjamEntry>);
                function PasteJam: TList<TjamEntry>;

                procedure CopyHWJAM(Entries: TList<THWjamEntry>);
                function PasteHWJam: TList<THWjamEntry>;

                procedure Copy();

                procedure DoUndo();
                procedure PushUndoState();

                procedure RefreshCanvas;
                procedure RefreshPalette();
                procedure DrawTexture();
                procedure PalChange(palID: integer);
                procedure JamReGen;
                procedure TreeReDraw;
                procedure DrawTree;
                procedure SelectTexture(id: integer; treeupdate: boolean);
                procedure DeSelectTexture();
                procedure NewJam(filename: string; height: integer);
                procedure LoadJam(filename: string);
                procedure OpenCommandLineFile;
                procedure UpdateJamData(id: integer);
                procedure SelectTreeTex();
                procedure ClearPaletteImg();
                procedure LoadMRU;
                procedure SaveMRU;
                procedure UpdateMRU;
                procedure AddToMRU(const filename: string);
                procedure RecentFileClick(Sender: TObject);
                function CheckJamModified(): Boolean;
                procedure UISetup();
                procedure UpdateCaption();
                procedure UpdateUIData(id: integer);
                procedure ConvertJAM(output: TJamType);
                procedure DeleteTexture();
                procedure JamModified(modified: boolean);
                function JamSanityCheck(): boolean;
                function ScreenToCanvas(const P: TPoint): TPoint;
                function HitTestTextureZone(MouseX, MouseY: integer;
                  const R: TRect): TResizeMode;
                function GetSelectedTextureScreenRect: TRect;
                procedure ApplyTextureTransform(newX, newY, newW, newH: integer);
                procedure UpdateCursorForHitZone(X, Y: integer);
                procedure DeactivateMoveTool;
                procedure CaptureDragBackground;
                procedure ReleaseDragBackground;
                procedure DrawDragPreview;
                procedure DrawSnapGuidesOverlay;
                procedure RestoreBackgroundRect(bmp: TBitmap;
                  const R: TRect);
                procedure InvalidateDragRegion;
                procedure StartZoomTo(NewZoom: Double);
                procedure ApplySnap(Mode: TResizeMode;
                  var newX, newY, newW, newH: integer);
                procedure ToggleSnap;
                procedure ToggleCheckerboard;
                procedure ToggleDPIScaling;
                procedure ComposeCheckerboard(var bmp: TBitmap; keyColor: TColor);
                procedure ApplyOutlineOverlay(bmp: TBitmap);
                procedure CaptureOriginalSelectedState;
                procedure RestoreOriginalSelectedState;

                procedure genMask();

                procedure JamSanityCheckInform(onSave: boolean);

                function AddJamTreeNode(Tree: TTreeView; Parent: TTreeNode;
                  const Caption: string; data: integer; jamID: integer;
                  editNode: boolean; nodeType: TJamTreeNodeID): TTreeNode;
        private
                FCheckerPattern: TBitmap;
                FCheckerBrush: HBRUSH;
                // Tracks which monitor the window is currently on so WM_MOVE
                // only triggers a DPI refresh when the window crosses a screen
                // boundary rather than on every pixel of drag movement.
                FCurrentMonitorHandle: HMONITOR;
                procedure MsgHandler(var Msg: TMsg; var Handled: boolean);
                function CheckerBrush: HBRUSH;
                // Queries the physical (raw) DPI of hMon via GetDpiForMonitor
                // (shcore.dll, Win8.1+), falls back to Screen.PixelsPerInch.
                // If the computed factor differs from the current dblDPIFactor
                // and the DPI-scale toggle is active, the canvas is refreshed.
                procedure RefreshDPIFactor(hMon: HMONITOR);
                // Per-frame scroll correction to keep a canvas point pinned
                // under the mouse (or screen centre) while zoom animates.
                procedure ApplyZoomAnchorScroll;
                // Sets the zoom anchor to the centre of the visible ScrollBox
                // area — used by the toolbar +/- zoom buttons.
                procedure SetZoomAnchorToCenter;
        public

        end;

var

        // change to TQueue
        SWUndoStack, SWRedoStack: TStack<TJamFile>;
        HWUndoStack, HWRedoStack: TStack<THWJamFile>;

        FormMain: TFormMain;

        boolLCtrl: boolean;

        SelectedTreeNodes: TList<TTreeNode>;

        FMoveToolActive: Boolean;
        FDrag: TDragState;
        FDragBackground: TBitmap;   // cached scaled canvas with moving tex hidden
        FDragTextureCache: TBitmap; // borrowed reference to moving texture's bitmap
        FTargetZoom: Double;        // smooth-zoom target

        // Space-bar pan state
        FSpacePanArmed: Boolean;    // space held → ready to pan
        FPanActive: Boolean;        // mouse down during pan → dragging
        FPanStartMouse: TPoint;     // screen mouse pos at pan start
        FPanStartScrollX: Integer;  // ScrollBox scroll pos at pan start
        FPanStartScrollY: Integer;

        // Snap state (updated per drag frame)
        FSnapXActive: Boolean;
        FSnapYActive: Boolean;
        FSnapXLine: Integer; // canvas X where vertical guide should draw
        FSnapYLine: Integer; // canvas Y where horizontal guide should draw

        // Dirty-rect drag preview state — track previous frame's damaged
        // areas so we can restore only the affected pixels each frame
        // instead of copying the whole 32MB bitmap at high zoom.
        FDragPrevTexRect: TRect;            // screen rect of texture last frame
        FPrevSnapXActive: Boolean;
        FPrevSnapYActive: Boolean;
        FPrevSnapXLineScreen: Integer;      // screen X of last guide
        FPrevSnapYLineScreen: Integer;      // screen Y of last guide
        FDragDirtyRect: TRect;              // union of this frame's dirty regions

        // Zoom-anchor scroll state — keeps a specific canvas point pinned to
        // a specific screen position while the zoom animation runs.
        // FZoomAnchorRelX/Y  : raw-canvas pixel that should stay fixed
        //                       = (screenPos - ImgLeft) / intJamZoom_at_start
        // FZoomAnchorScreenX/Y: ScrollBox-client pixel it must stay at
        // FZoomHasAnchor     : false until set by FormMouseWheel / toolbar
        FZoomAnchorRelX:    Double;
        FZoomAnchorRelY:    Double;
        FZoomAnchorScreenX: Integer;
        FZoomAnchorScreenY: Integer;
        FZoomHasAnchor:     Boolean;

        // High-resolution drag-rate limiter (QueryPerformanceCounter).
        // FLastDragQPC  — QPF timestamp of the last accepted drag frame.
        // FQPFFreq      — QueryPerformanceFrequency result (counts / second).
        // FDragFrameInterval — QPF counts between allowed renders; set from
        //                     the monitor's actual refresh rate so we never
        //                     submit frames faster than the display can show.
        FLastDragQPC:       Int64;
        FQPFFreq:           Int64;
        FDragFrameInterval: Int64;

        // "Original" texture state captured when a texture is first
        // selected in move mode. Escape restores this state (like Photoshop
        // cancelling a Transform operation).
        FOriginalSelectedIdx: Integer;
        FOriginalSelectedX: Integer;
        FOriginalSelectedY: Integer;
        FOriginalSelectedW: Integer;
        FOriginalSelectedH: Integer;

        userisTyping: boolean = false;

        boolFlagChange: boolean;
        boolXChange: boolean;
        boolYChange: boolean;
        boolWidthChange: boolean;
        boolHeightChange: boolean;
        boolIDChange: boolean;
        boolScaleXChange: boolean;
        boolScaleYChange: boolean;
        boolScaleChange: boolean;
        boolScaleFlagsChange: boolean;
        boolCanvasChange: boolean;

implementation

{$R *.dfm}

uses JamBrowser;

procedure ForceCategoryPanelRedraw(CPG: TCategoryPanelGroup);
var
        i: integer;

        panel: TCategoryPanel;
begin
        CPG.DisableAlign;
        try
                CPG.Realign;
                CPG.Invalidate;
                CPG.Update;
        finally
                CPG.EnableAlign;
        end;

        begin
                for i := 0 to CPG.ControlCount - 1 do
                begin
                        if CPG.Controls[i] is TCategoryPanel then
                        begin
                                panel := TCategoryPanel(CPG.Controls[i]);
                                RedrawWindow(panel.Handle, nil, 0,
                                  RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or
                                  RDW_ALLCHILDREN);
                        end;
                end;

                RedrawWindow(CPG.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or
                  RDW_FRAME or RDW_ALLCHILDREN);
        end;
end;

procedure SaveExpandedNodes(Tree: TTreeView; ExpandedPaths: TStrings;
  out SelectedPath: string);
var
        Node: TTreeNode;
        function GetNodePath(Node: TTreeNode): string;
        begin
                Result := '';
                while Node <> nil do
                begin
                        Result := Node.Text + '/' + Result;
                        Node := Node.Parent;
                end;
                Result := '/' + Result;
        end;

begin
        ExpandedPaths.Clear;
        Node := Tree.Items.GetFirstNode;
        while Node <> nil do
        begin
                if Node.Expanded then
                        ExpandedPaths.Add(GetNodePath(Node));
                Node := Node.GetNext;
        end;

        if Assigned(Tree.Selected) then
                SelectedPath := GetNodePath(Tree.Selected)
        else
                SelectedPath := '';
end;

procedure RestoreExpandedNodes(Tree: TTreeView; ExpandedPaths: TStrings;
  const SelectedPath: string);
var
        Node: TTreeNode;

        function FindNodeByPath(Path: string): TTreeNode;
        var
                Parts: TArray<string>;
                i: integer;
                Current: TTreeNode;
        begin
                Result := nil;
                if Path = '' then
                        Exit;

                Parts := Path.Split(['/'], TStringSplitOptions.ExcludeEmpty);
                Current := nil;

                for i := 0 to High(Parts) do
                begin
                        Result := nil;
                        if Current = nil then
                                Current := Tree.Items.GetFirstNode
                        else
                                Current := Current.getFirstChild;

                        while Current <> nil do
                        begin
                                if SameText(Current.Text, Parts[i]) then
                                begin
                                        Result := Current;
                                        Break;
                                end;
                                Current := Current.getNextSibling;
                        end;

                        if Result = nil then
                                Exit;
                        Current := Result;
                end;

                Result := Current;
        end;

var
        i: integer;
        NodePath: string;
begin
        for i := 0 to ExpandedPaths.Count - 1 do
        begin
                NodePath := ExpandedPaths[i];
                Node := FindNodeByPath(NodePath);
                if Assigned(Node) then
                        Node.Expand(false);
        end;

        Node := FindNodeByPath(SelectedPath);
        if Assigned(Node) then
                Tree.Selected := Node;
end;

function TFormMain.ScreenToCanvas(const P: TPoint): TPoint;
var
        ez: Double;
begin
        ez := EffectiveJamZoom;
        if ez = 0 then
                Result := P
        else
        begin
                Result.X := Round(P.X / ez);
                Result.Y := Round(P.Y / ez);
        end;
end;

function TFormMain.HitTestTextureZone(MouseX, MouseY: integer;
  const R: TRect): TResizeMode;
// Returns which zone the mouse is in for the selected texture's screen
// rect R. Handles are padded OUTWARD by PADDING pixels (forgiveness for
// lazy clicks) and extend INWARD up to HANDLE pixels.  Body = inside R.
// Outside the outer bounds (R + PADDING) returns rmNone so cursor resets.
const
        HANDLE = 8;   // how far inward the corner/edge grab extends
        PADDING = 6;  // how far outward the corner/edge grab extends
var
        W, H, grabW, grabH: integer;
        outerL, outerT, outerR, outerB: integer;
        innerNorth, innerSouth, innerWest, innerEast: integer;
begin
        Result := rmNone;
        W := R.Right - R.Left;
        H := R.Bottom - R.Top;
        if (W <= 0) or (H <= 0) then Exit;

        // Tiny textures: shrink the inward grab so corners don't overlap.
        grabW := Min(HANDLE, W div 2);
        grabH := Min(HANDLE, H div 2);

        // Outer bounds = texture rect extended by PADDING. Outside this,
        // nothing to grab.
        outerL := R.Left   - PADDING;
        outerT := R.Top    - PADDING;
        outerR := R.Right  + PADDING;
        outerB := R.Bottom + PADDING;
        if (MouseX < outerL) or (MouseX > outerR) or
          (MouseY < outerT) or (MouseY > outerB) then
                Exit;

        // Corner zones: a rectangle anchored at the corner extending
        // PADDING outward and grabW/grabH inward.
        if (MouseX <= R.Left + grabW) and (MouseY <= R.Top + grabH) then
                Exit(rmTopLeft);
        if (MouseX >= R.Right - grabW) and (MouseY <= R.Top + grabH) then
                Exit(rmTopRight);
        if (MouseX >= R.Right - grabW) and (MouseY >= R.Bottom - grabH) then
                Exit(rmBottomRight);
        if (MouseX <= R.Left + grabW) and (MouseY >= R.Bottom - grabH) then
                Exit(rmBottomLeft);

        // Edges — only if the texture has a middle region between corners.
        // (innerNorth, innerSouth, innerWest, innerEast) define the body
        // area inside all four corner zones.
        innerNorth := R.Top    + grabH;
        innerSouth := R.Bottom - grabH;
        innerWest  := R.Left   + grabW;
        innerEast  := R.Right  - grabW;

        if (innerEast > innerWest) and (innerSouth > innerNorth) then
        begin
                // Top edge strip
                if (MouseY <= R.Top + HANDLE) and
                  (MouseX > innerWest) and (MouseX < innerEast) then
                        Exit(rmTop);
                // Bottom edge strip
                if (MouseY >= R.Bottom - HANDLE) and
                  (MouseX > innerWest) and (MouseX < innerEast) then
                        Exit(rmBottom);
                // Left edge strip
                if (MouseX <= R.Left + HANDLE) and
                  (MouseY > innerNorth) and (MouseY < innerSouth) then
                        Exit(rmLeft);
                // Right edge strip
                if (MouseX >= R.Right - HANDLE) and
                  (MouseY > innerNorth) and (MouseY < innerSouth) then
                        Exit(rmRight);
        end;

        // Body of the texture itself = move zone (no padding — only when
        // actually inside the texture rect)
        if PtInRect(R, Point(MouseX, MouseY)) then
                Result := rmMove;
end;

function TFormMain.GetSelectedTextureScreenRect: TRect;
var
        W, H: integer;
        ez: Double;
begin
        FillChar(Result, SizeOf(Result), 0);
        if intSelectedTexture < 0 then
                Exit;

        ez := EffectiveJamZoom;

        if boolHWJAM then
        begin
                if (FHWJamFile = nil) or
                  (intSelectedTexture >= FHWJamFile.Entries.Count) then
                        Exit;
                with FHWJamFile.FEntries[intSelectedTexture].FInfo do
                begin
                        Result.Left := Round(X * ez);
                        Result.Top := Round(Y * ez);
                        W := Round(Width * ez);
                        H := Round(Height * ez);
                end;
        end
        else
        begin
                if (FJamFile = nil) or
                  (intSelectedTexture >= FJamFile.Entries.Count) then
                        Exit;
                with FJamFile.FEntries[intSelectedTexture].FInfo do
                begin
                        Result.Left := Round(X * ez);
                        Result.Top := Round(Y * ez);
                        W := Round(Width * ez);
                        H := Round(Height * ez);
                end;
        end;
        Result.Right := Result.Left + W;
        Result.Bottom := Result.Top + H;
end;

procedure TFormMain.ApplyTextureTransform(newX, newY, newW, newH: integer);
var
        shiftHeld: Boolean;
begin
        if intSelectedTexture < 0 then
                Exit;

        if newW < 1 then newW := 1;
        if newH < 1 then newH := 1;

        // Apply edge snapping during active drag. Snap is active when
        // either the toolbar toggle is on OR the user is holding Shift
        // (temporary snap override — Photoshop-style).
        shiftHeld := (GetKeyState(VK_SHIFT) and $8000) <> 0;
        if FDrag.Active and (boolSnapEnabled or shiftHeld) then
                ApplySnap(FDrag.Mode, newX, newY, newW, newH);

        // Clamp X/Y to stay within the canvas — prevents dragging textures
        // outside 0,0. For SW JAMs this is also required by the packed
        // record format (byte X / Word Y) which would wrap on negatives.
        if newX < 0 then newX := 0;
        if newY < 0 then newY := 0;

        // Upper bound for SW only (byte X / Word Y storage limit)
        if not boolHWJAM then
        begin
                if newX > 255 then newX := 255;
                if newY > 65535 then newY := 65535;
        end;

        if boolHWJAM then
        begin
                FHWJamFile.FEntries[intSelectedTexture].FInfo.X := newX;
                FHWJamFile.FEntries[intSelectedTexture].FInfo.Y := newY;
                FHWJamFile.FEntries[intSelectedTexture].FInfo.Width := newW;
                FHWJamFile.FEntries[intSelectedTexture].FInfo.Height := newH;
        end
        else
        begin
                FJamFile.FEntries[intSelectedTexture].FInfo.X := newX;
                FJamFile.FEntries[intSelectedTexture].FInfo.Y := newY;
                FJamFile.FEntries[intSelectedTexture].FInfo.Width := newW;
                FJamFile.FEntries[intSelectedTexture].FInfo.Height := newH;
        end;

        // Update the spin-edit UI (suppress change events)
        UpdatingFromCode := true;
        try
                tex_X.Value := newX;
                tex_Y.Value := newY;
                tex_width.Value := newW;
                tex_height.Value := newH;
        finally
                UpdatingFromCode := false;
        end;

        boolJamModified := true;

        // Fast-path during an active drag with a cached background:
        // only re-draw the moving texture on top of the cached bitmap.
        if FDrag.Active and (FDragBackground <> nil) and (not boolHWJAM) then
        begin
                DrawDragPreview;
                // Snap guides (SW fast-path)
                DrawSnapGuidesOverlay;
                InvalidateDragRegion;

                // The fast-path skips RefreshCanvas, but we still want the
                // off-canvas / overlap flags to track the live drag so the
                // user sees the warning the moment a move OR resize crosses
                // a boundary or pushes into a neighbouring texture.
                JamSanityCheck;
                JamSanityCheckInform(false);
        end
        else
        begin
                RefreshCanvas;
                if FDrag.Active then
                        DrawSnapGuidesOverlay;
                ImageCanvas.Invalidate;
        end;
end;

procedure TFormMain.UpdateCursorForHitZone(X, Y: integer);
var
        zone: TResizeMode;
        R: TRect;
begin
        if (intSelectedTexture < 0) or boolRcrJam then
        begin
                ImageCanvas.Cursor := crDefault;
                Exit;
        end;

        R := GetSelectedTextureScreenRect;
        zone := HitTestTextureZone(X, Y, R);

        case zone of
                rmMove:
                        ImageCanvas.Cursor := crSizeAll;
                rmTopLeft, rmBottomRight:
                        ImageCanvas.Cursor := crSizeNWSE;
                rmTopRight, rmBottomLeft:
                        ImageCanvas.Cursor := crSizeNESW;
                rmTop, rmBottom:
                        ImageCanvas.Cursor := crSizeNS;
                rmLeft, rmRight:
                        ImageCanvas.Cursor := crSizeWE;
        else
                ImageCanvas.Cursor := crDefault;
        end;
end;

procedure TFormMain.DeactivateMoveTool;
begin
        FMoveToolActive := false;
        boolMoveToolActive := false;
        FDrag.Active := false;
        FDrag.Mode := rmNone;
        FSnapXActive := False;
        FSnapYActive := False;
        FOriginalSelectedIdx := -1;
        ReleaseDragBackground;
        if toolbarMove.Down then
                toolbarMove.Down := false;
        ImageCanvas.Cursor := crDefault;
        if booljamLoaded then
                RefreshCanvas;
end;

procedure TFormMain.CaptureDragBackground;
var
        src: TBitmap;
begin
        // Called once when a move/resize drag begins.
        // We render the canvas WITHOUT the moving texture (via the
        // intDragSkipEntry mechanism), capture that as the drag
        // background, and restore normal rendering. During drag, per-move
        // frames blit this pristine background and composite the moving
        // texture on top — so it always appears ABOVE other textures,
        // with overlapping textures underneath correctly preserved.
        ReleaseDragBackground;
        FLastDragQPC := 0;  // ensure first drag frame is always rendered

        if intSelectedTexture < 0 then Exit;
        if boolHWJAM then Exit; // HW: still re-renders fully for now

        // Tell DrawFullJam + DrawOutlines to skip the moving entry
        intDragSkipEntry := intSelectedTexture;
        try
                RefreshCanvas;
        finally
                intDragSkipEntry := -1;
        end;

        src := ImageCanvas.Picture.Bitmap;
        if (src = nil) or (src.Width = 0) or (src.Height = 0) then Exit;

        FDragBackground := TBitmap.Create;
        // Match the source's pixel format so BitBlt during drag is zero-cost
        FDragBackground.PixelFormat := src.PixelFormat;
        FDragBackground.SetSize(src.Width, src.Height);
        BitBlt(FDragBackground.Canvas.Handle, 0, 0, src.Width, src.Height,
          src.Canvas.Handle, 0, 0, SRCCOPY);

        // Reset dirty-rect tracking — no previous frame yet
        FDragPrevTexRect := Rect(0, 0, 0, 0);
        FPrevSnapXActive := False;
        FPrevSnapYActive := False;

        // Cache a reference to the moving texture's bitmap for redraw
        if (intPaletteID >= 0) and (intPaletteID <= 3) then
                FDragTextureCache := FJamFile.FEntries[intSelectedTexture]
                  .FCachedTex[intPaletteID];
        if not Assigned(FDragTextureCache) then
                FDragTextureCache := FJamFile.FEntries[intSelectedTexture]
                  .FOriginalTex;
end;

procedure TFormMain.ReleaseDragBackground;
begin
        FreeAndNil(FDragBackground);
        FDragTextureCache := nil; // borrowed, don't free
end;

procedure TFormMain.DrawDragPreview;
// High-frequency path — runs on every mouse-move during drag. Must avoid
// allocating or copying large bitmaps. Draws directly on
// ImageCanvas.Picture.Bitmap's canvas, using FDragBackground as a cached
// "clean" backdrop.
var
        bmp: TBitmap;
        sx, sy, sw, sh: integer;
        newTexRect: TRect;
begin
        if FDragBackground = nil then
        begin
                RefreshCanvas; // fallback
                Exit;
        end;
        if intSelectedTexture < 0 then Exit;
        if boolHWJAM then Exit;

        // ImageCanvas.Picture.Bitmap was established at drag-start with
        // the correct dimensions (by CaptureDragBackground → RefreshCanvas).
        bmp := ImageCanvas.Picture.Bitmap;
        if (bmp = nil) or (bmp.Width <> FDragBackground.Width) or
          (bmp.Height <> FDragBackground.Height) then
        begin
                // Shouldn't happen; fall back to full refresh
                RefreshCanvas;
                Exit;
        end;

        // Reset dirty-rect tracker — RestoreBackgroundRect expands it as
        // regions are touched, giving us a tight bounding rect to pass
        // to InvalidateRect later.
        FDragDirtyRect := Rect(0, 0, 0, 0);

        // Compute new texture screen rect with a 14px margin for outlines
        // + Photoshop handles (halfsize 4 + some buffer).
        with FJamFile.FEntries[intSelectedTexture].FInfo do
        begin
                sx := Round(X * EffectiveJamZoom);
                sy := Round(Y * EffectiveJamZoom);
                sw := Round(Width * EffectiveJamZoom);
                sh := Round(Height * EffectiveJamZoom);
        end;
        newTexRect := Rect(sx - 14, sy - 14, sx + sw + 14, sy + sh + 14);

        // 1. Restore the area where the texture WAS last frame (erase)
        if (FDragPrevTexRect.Right > FDragPrevTexRect.Left) and
          (FDragPrevTexRect.Bottom > FDragPrevTexRect.Top) then
                RestoreBackgroundRect(bmp, FDragPrevTexRect);

        // 2. Restore the area where the texture IS this frame (clear
        //    destination before drawing). Often overlaps with prev; that's
        //    fine — BitBlt of the overlapping region just happens twice,
        //    still way cheaper than the full bitmap.
        RestoreBackgroundRect(bmp, newTexRect);

        // 3. Restore previous snap guide strips (if any) so old lines vanish
        if FPrevSnapXActive then
                RestoreBackgroundRect(bmp, Rect(FPrevSnapXLineScreen - 2, 0,
                  FPrevSnapXLineScreen + 3, bmp.Height));
        if FPrevSnapYActive then
                RestoreBackgroundRect(bmp, Rect(0, FPrevSnapYLineScreen - 2,
                  bmp.Width, FPrevSnapYLineScreen + 3));

        // 4. Restore where new snap guides will be (clean slate for redraw)
        if FSnapXActive then
        begin
                sx := Round(FSnapXLine * EffectiveJamZoom);
                RestoreBackgroundRect(bmp, Rect(sx - 2, 0, sx + 3, bmp.Height));
        end;
        if FSnapYActive then
        begin
                sy := Round(FSnapYLine * EffectiveJamZoom);
                RestoreBackgroundRect(bmp, Rect(0, sy - 2, bmp.Width, sy + 3));
        end;

        // 5. Draw the moving texture at its new scaled rect with transparency
        if Assigned(FDragTextureCache) then
                with FJamFile.FEntries[intSelectedTexture].FInfo do
                begin
                        sx := Round(X * EffectiveJamZoom);
                        sy := Round(Y * EffectiveJamZoom);
                        sw := Round(Width * EffectiveJamZoom);
                        sh := Round(Height * EffectiveJamZoom);
                        if (sw > 0) and (sh > 0) then
                                TransparentBlt(bmp.Canvas.Handle, sx, sy, sw, sh,
                                  FDragTextureCache.Canvas.Handle, 0, 0,
                                  FDragTextureCache.Width,
                                  FDragTextureCache.Height,
                                  RGB(gpxPal[0].r, gpxPal[0].g, gpxPal[0].b));
                end;

        // 6. Draw outline for the moving texture only — dashed when it's
        // wandered into the off-canvas margin so the user gets immediate
        // feedback that they're dragging out of bounds.
        if boolDrawOutlines then
                with FJamFile.FEntries[intSelectedTexture].FInfo do
                        DrawTextureOutlines(bmp, X, Y, Width, Height,
                          intSelectedTexture, JamID,
                          (X < 0) or (Y < 0) or
                          (X + Width  > FJamFile.canvasWidth) or
                          (Y + Height > FJamFile.canvasHeight));

        // Update dirty-rect tracking for next frame
        FDragPrevTexRect := newTexRect;
        FPrevSnapXActive := FSnapXActive;
        FPrevSnapYActive := FSnapYActive;
        if FSnapXActive then
                FPrevSnapXLineScreen := Round(FSnapXLine * EffectiveJamZoom);
        if FSnapYActive then
                FPrevSnapYLineScreen := Round(FSnapYLine * EffectiveJamZoom);

        // Snap guides + final invalidate are performed by the caller
        // (ApplyTextureTransform) after this function returns, so both
        // the SW fast-path and the HW full-refresh path get consistent
        // guide drawing.
end;

procedure TFormMain.RestoreBackgroundRect(bmp: TBitmap; const R: TRect);
// BitBlt a rectangular region from FDragBackground into bmp, clipped to
// bitmap bounds. Used to erase previous-frame drawings without copying
// the whole bitmap each frame. Also expands FDragDirtyRect so the caller
// can InvalidateRect only the affected area.
var
        L, T, Rg, B: integer;
begin
        if FDragBackground = nil then Exit;
        L := R.Left;
        T := R.Top;
        Rg := R.Right;
        B := R.Bottom;
        if L < 0 then L := 0;
        if T < 0 then T := 0;
        if Rg > bmp.Width then Rg := bmp.Width;
        if B > bmp.Height then B := bmp.Height;
        if (Rg <= L) or (B <= T) then Exit;
        BitBlt(bmp.Canvas.Handle, L, T, Rg - L, B - T,
          FDragBackground.Canvas.Handle, L, T, SRCCOPY);
        // Expand dirty-rect tracker
        if (FDragDirtyRect.Right <= FDragDirtyRect.Left) or
          (FDragDirtyRect.Bottom <= FDragDirtyRect.Top) then
                FDragDirtyRect := Rect(L, T, Rg, B)
        else
        begin
                if L < FDragDirtyRect.Left then FDragDirtyRect.Left := L;
                if T < FDragDirtyRect.Top then FDragDirtyRect.Top := T;
                if Rg > FDragDirtyRect.Right then FDragDirtyRect.Right := Rg;
                if B > FDragDirtyRect.Bottom then FDragDirtyRect.Bottom := B;
        end;
end;

procedure TFormMain.InvalidateDragRegion;
// Invalidates just the FDragDirtyRect area in the parent (ScrollBox)
// coordinate space so Windows only repaints the small damaged region
// rather than the entire ImageCanvas. TImage is a TGraphicControl and
// has no window handle of its own — it paints through its parent.
var
        parentRect: TRect;
begin
        if (FDragDirtyRect.Right <= FDragDirtyRect.Left) or
          (FDragDirtyRect.Bottom <= FDragDirtyRect.Top) then
        begin
                ImageCanvas.Invalidate;
                Exit;
        end;
        if (ImageCanvas.Parent = nil) or
          (not ImageCanvas.Parent.HandleAllocated) then
        begin
                ImageCanvas.Invalidate;
                Exit;
        end;
        parentRect := FDragDirtyRect;
        OffsetRect(parentRect, ImageCanvas.Left, ImageCanvas.Top);
        Winapi.Windows.InvalidateRect(ImageCanvas.Parent.Handle,
          @parentRect, False);
end;

procedure TFormMain.DrawSnapGuidesOverlay;
// Draws the magenta dashed snap guide lines directly on ImageCanvas's
// current bitmap. Used for both SW (after DrawDragPreview) and HW (after
// RefreshCanvas) so guides appear consistently on both JAM types.
var
        bmp: TBitmap;
        sx, sy: integer;
begin
        if not (FSnapXActive or FSnapYActive) then Exit;
        bmp := ImageCanvas.Picture.Bitmap;
        if (bmp = nil) or (bmp.Width = 0) or (bmp.Height = 0) then Exit;

        bmp.Canvas.Pen.Style := psDash;
        bmp.Canvas.Pen.Width := 1;
        bmp.Canvas.Pen.Color := TColor($FF00FF); // magenta
        bmp.Canvas.Brush.Style := bsClear;
        if FSnapXActive then
        begin
                sx := Round(FSnapXLine * EffectiveJamZoom);
                bmp.Canvas.MoveTo(sx, 0);
                bmp.Canvas.LineTo(sx, bmp.Height);
        end;
        if FSnapYActive then
        begin
                sy := Round(FSnapYLine * EffectiveJamZoom);
                bmp.Canvas.MoveTo(0, sy);
                bmp.Canvas.LineTo(bmp.Width, sy);
        end;
end;

procedure TFormMain.LoadMRU();
var
        Reg: TRegistry;
        i: integer;
        s: string;
begin
        MRUList.Clear;
        Reg := TRegistry.Create(KEY_READ);
        try
                Reg.RootKey := HKEY_CURRENT_USER;
                if Reg.OpenKeyReadOnly(MRUKeyPath) then
                begin
                        for i := 0 to intMaxMRU - 1 do
                        begin
                                if Reg.ValueExists('File' + IntToStr(i)) then
                                begin
                                        s := Reg.ReadString
                                        ('File' + IntToStr(i));
                                        if FileExists(s) then
                                        MRUList.Add(s);
                                end;
                        end;
                        Reg.CloseKey;
                end;
        finally
                Reg.Free;
        end;
end;

procedure TFormMain.MainMenu1Change(Sender: TObject; Source: TMenuItem;
  Rebuild: boolean);
begin

        if boolHWJAM then
        begin
                if not Clipboard.HasFormat(ClipboardHWJAM) then
                        mainMenuPaste.Enabled := false;
        end
        else
        begin
                if not Clipboard.HasFormat(ClipboardJAM) then
                        mainMenuPaste.Enabled := false;
        end;

end;

procedure TFormMain.SaveDecryptedJAMClick(Sender: TObject);
begin

        if JamSanityCheck then
        begin
                JamSanityCheckInform(true);
                Exit;
        end;

        dlgSaveJam.filename := FJamFile.JamFileName + '.jamdec';

        if dlgSaveJam.Execute then
        begin
                FJamFile.SaveToFile(dlgSaveJam.filename, true);

        end
        else
                // user cancelled the Save As dialog
                Exit;

end;

procedure TFormMain.SaveMRU;
var
        Reg: TRegistry;
        i: integer;
begin
        Reg := TRegistry.Create(KEY_WRITE);
        try
                Reg.RootKey := HKEY_CURRENT_USER;
                if Reg.OpenKey(MRUKeyPath, true) then
                begin
                        // write up to MaxMRU entries
                        for i := 0 to MRUList.Count - 1 do
                                Reg.WriteString('File' + IntToStr(i),
                                  MRUList[i]);
                        Reg.CloseKey;
                end;
        finally
                Reg.Free;
        end;
end;

procedure TFormMain.scaleFlagsClickCheck(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode then
                Exit;
        boolScaleFlagsChange := true;
        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.Copy();
var
        i: integer;
        jamList: TList<TjamEntry>;
        jamHWList: TList<THWjamEntry>;

begin
        if boolHWJAM then
        begin
                SelectedTextureList.sort;
                jamHWList := TList<THWjamEntry>.Create;

                for i := 0 to SelectedTextureList.Count - 1 do
                begin
                        jamHWList.Add
                          (FHWJamFile.Entries[SelectedTextureList[i]]);
                end;
                CopyHWJAM(jamHWList);

                jamHWList.Clear;

        end
        else
        begin
                SelectedTextureList.sort;
                jamList := TList<TjamEntry>.Create;

                for i := 0 to SelectedTextureList.Count - 1 do
                begin
                        jamList.Add(FJamFile.Entries[SelectedTextureList[i]]);
                end;
                CopyJAM(jamList);

                jamList.Clear;
        end;
end;

procedure TFormMain.CopyHWJAM(Entries: TList<THWjamEntry>);
var
        Stream: TMemoryStream;
        Count, i: integer;
        Handle: THandle;
        P: Pointer;
begin
        Stream := TMemoryStream.Create;
        try
                Count := Entries.Count;
                Stream.WriteBuffer(Count, SizeOf(Count));

                for i := 0 to Count - 1 do
                        Entries[i].SaveToStream(Stream);

                Stream.Position := 0;
                Handle := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
                if Handle = 0 then
                        Exit;

                P := GlobalLock(Handle);
                try
                        Stream.ReadBuffer(P^, Stream.Size);
                finally
                        GlobalUnlock(Handle);
                end;

                Clipboard.SetAsHandle(ClipboardHWJAM, Handle);
        finally
                Stream.Free;
        end;
end;

procedure TFormMain.Panel_TexPropertiesCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.Panel_TexPropertiesExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_TexturePreviewCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_TexturePreviewExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

function TFormMain.PasteHWJam: TList<THWjamEntry>;
var
        Handle: THandle;
        P: Pointer;
        Stream: TMemoryStream;
        i, Count, X: integer;
        Entry: THWjamEntry;
begin
        Result := TList<THWjamEntry>.Create;

        if not Clipboard.HasFormat(ClipboardHWJAM) then
                Exit;

        Handle := Clipboard.GetAsHandle(ClipboardHWJAM);
        if Handle = 0 then
                Exit;

        P := GlobalLock(Handle);
        if P = nil then
                Exit;

        try
                Stream := TMemoryStream.Create;
                try
                        Stream.WriteBuffer(P^, GlobalSize(Handle));
                        Stream.Position := 0;

                        Stream.ReadBuffer(Count, SizeOf(Count));
                        for i := 0 to Count - 1 do
                        begin
                                Entry := THWjamEntry.Create
                                  (Default (THWJamEntryInfo));
                                Entry.LoadFromStream(Stream);
                                if Entry.FInfo.jamID = FHWJamFile.FEntries[X]
                                  .FInfo.jamID then
                                        Entry.FInfo.jamID :=
                                        FHWJamFile.GetNextJamID
                                        (FHWJamFile.FEntries) + i;

                                Result.Add(Entry);
                        end;
                finally
                        Stream.Free;
                end;
        finally
                GlobalUnlock(Handle);
        end;
end;

procedure TFormMain.CopyJAM(Entries: TList<TjamEntry>);
var
        Stream: TMemoryStream;
        Count, i: integer;
        Handle: THandle;
        P: Pointer;
begin
        Stream := TMemoryStream.Create;
        try
                Count := Entries.Count;
                Stream.WriteBuffer(Count, SizeOf(Count));

                for i := 0 to Count - 1 do
                        Entries[i].SaveToStream(Stream);

                Stream.Position := 0;
                Handle := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
                if Handle = 0 then
                        Exit;

                P := GlobalLock(Handle);
                try
                        Stream.ReadBuffer(P^, Stream.Size);
                finally
                        GlobalUnlock(Handle);
                end;

                Clipboard.SetAsHandle(ClipboardJAM, Handle);
        finally
                Stream.Free;
        end;
end;

function TFormMain.PasteJam: TList<TjamEntry>;
var
        Handle: THandle;
        P: Pointer;
        Stream: TMemoryStream;
        i, Count, X: integer;
        Entry: TjamEntry;
begin
        Result := TList<TjamEntry>.Create;

        if not Clipboard.HasFormat(ClipboardJAM) then
                Exit;

        Handle := Clipboard.GetAsHandle(ClipboardJAM);
        if Handle = 0 then
                Exit;

        P := GlobalLock(Handle);
        if P = nil then
                Exit;

        try
                Stream := TMemoryStream.Create;
                try
                        Stream.WriteBuffer(P^, GlobalSize(Handle));
                        Stream.Position := 0;

                        Stream.ReadBuffer(Count, SizeOf(Count));
                        for i := 0 to Count - 1 do
                        begin
                                Entry := TjamEntry.Create
                                  (Default (TJamEntryInfo));
                                Entry.LoadFromStream(Stream);
                                for X := 0 to FJamFile.FEntries.Count - 1 do
                                        if Entry.FInfo.jamID = FJamFile.FEntries
                                        [X].FInfo.jamID then
                                        Entry.FInfo.jamID :=
                                        FJamFile.GetNextJamID
                                        (FJamFile.FEntries) + i;
                                Result.Add(Entry);
                        end;
                finally
                        Stream.Free;
                end;
        finally
                GlobalUnlock(Handle);
        end;
end;

procedure TFormMain.UpdateMRU();
var
        i: integer;
        itm: TMenuItem;
begin
        mnuRecentFiles.Clear;
        for i := 0 to MRUList.Count - 1 do
        begin
                itm := TMenuItem.Create(mnuRecentFiles);
                itm.Caption :=
                  Format('&%d %s', [i + 1, WinShortPath(MRUList[i], 90)]);
                itm.Hint := MRUList[i]; // store full path
                itm.OnClick := RecentFileClick;
                mnuRecentFiles.Add(itm);
        end;
        mnuRecentFiles.Enabled := MRUList.Count > 0;
end;

procedure TFormMain.View2Click(Sender: TObject);
begin
        options.optionsForm.show;
end;

procedure TFormMain.AddToMRU(const filename: string);
var
        idx: integer;
begin
        idx := MRUList.IndexOf(filename);
        if idx <> -1 then
                MRUList.Delete(idx);
        MRUList.Insert(0, filename);
        if MRUList.Count > intMaxMRU then
                MRUList.Delete(MRUList.Count - 1);
        SaveMRU;
        UpdateMRU;
end;

procedure TFormMain.autoPackTexsClick(Sender: TObject);
var
        JamRects: TArray<TJamRect>;
        i: integer;
begin

        if boolUndo then
                PushUndoState;

        if boolHWJAM then
        begin
                FHWJamFile.BuildRect_HW(FHWJamFile, JamRects);
                FHWJamFile.ChangeJamCanvasHeight(PackRects(JamRects, 256,
                  FHWJamFile.canvasHeight));

                for i := 0 to high(JamRects) do
                begin
                        begin
                                FHWJamFile.FEntries[JamRects[i].index].FInfo.X
                                  := JamRects[i].X;

                                FHWJamFile.FEntries[JamRects[i].index].FInfo.Y
                                  := JamRects[i].Y;
                        end;

                end;

        end
        else
        begin
                FJamFile.BuildRect_SW(FJamFile, JamRects);
                FJamFile.ChangeJamCanvasHeight(PackRects(JamRects, 256,
                  FJamFile.canvasHeight));

                for i := 0 to high(JamRects) do
                begin

                        begin
                                FJamFile.FEntries[JamRects[i].index].FInfo.X :=
                                  JamRects[i].X;

                                FJamFile.FEntries[JamRects[i].index].FInfo.Y :=
                                  JamRects[i].Y;
                        end;

                end;

        end;

        timer_redrawTree.Enabled := true;
        if boolJipMode then

        FJamFile.DrawJIPMipmaps;

        RefreshCanvas;
        JamModified(true);

end;

procedure TFormMain.RecentFileClick(Sender: TObject);
var
        filename: string;
begin

        if not CheckJamModified() then Exit;

        filename := (Sender as TMenuItem).Hint;
        if FileExists(filename) then
        begin
                LoadJam(filename);
                AddToMRU(filename); // bump it back to the top
        end
        else
                MessageDlg('File not found: ' + filename, mtError, [mbOK], 0);
end;

procedure TFormMain.Redo1Click(Sender: TObject);
begin

        if boolHWJAM then
        begin
                if HWRedoStack.Count = 0 then
                        Exit;

                HWUndoStack.Push(FHWJamFile.Clone);

                FHWJamFile := HWRedoStack.pop;

                Undo1.Enabled := HWUndoStack.Count > 0;
                Redo1.Enabled := HWRedoStack.Count > 0;

        end
        else
        begin

                if SWRedoStack.Count = 0 then
                        Exit;

                SWUndoStack.Push(FJamFile.Clone);

                FJamFile := SWRedoStack.pop;

                Undo1.Enabled := SWUndoStack.Count > 0;
                Redo1.Enabled := SWRedoStack.Count > 0;

        end;

        RefreshCanvas;
        TreeReDraw;
        JamModified(true);
end;

procedure TFormMain.About1Click(Sender: TObject);
begin
aboutform.ShowModal;
end;

function TFormMain.AddJamTreeNode(Tree: TTreeView; Parent: TTreeNode;
  const Caption: string; data: integer; jamID: integer; editNode: boolean;
  nodeType: TJamTreeNodeID): TTreeNode;
var
        jamNode: TJamTreeNode;
begin

        jamNode := TJamTreeNode.Create;
        jamNode.data := data;
        jamNode.jamID := jamID;
        jamNode.editNode := editNode;
        jamNode.nodeType := nodeType;

        Result := Tree.Items.AddChild(Parent, Caption);

        if nodeType = jamPosX then
                Result.ImageIndex := 11;

        if nodeType = jamposY then
                Result.ImageIndex := 12;

        if nodeType = jamheight then
                Result.ImageIndex := 1;

        if nodeType = canvasDimensions then
                Result.ImageIndex := 1;

        if nodeType = jamwidth then
                Result.ImageIndex := 8;

        if nodeType = jamFlags then
                Result.ImageIndex := 14;

        if nodeType = jamData then
                Result.ImageIndex := 9;

        if nodeType = jamPalInfo then
                Result.ImageIndex := 5;

        if nodeType = jamColour then
                Result.ImageIndex := 10;

        if nodeType = jamUnk then
                Result.ImageIndex := 7;

        Result.SelectedIndex := Result.ImageIndex;
        Result.data := jamNode;

end;

procedure TFormMain.DrawTree();
var
        JamRoot, ItemsRoot, Node, ScalingNode, UnTexNode, UnkNode,
          CanvasHeightNode: TTreeNode;
        i, j: integer;
        E: TjamEntry;
        hwEntry: THWjamEntry;
        Tree: TTreeView;
begin
        Tree := JamTree;
        Tree.Items.BeginUpdate;
        try
                Tree.Items.Clear;

                if boolHWJAM then
                begin
                        JamRoot := Tree.Items.Add(nil, FHWJamFile.JamFileName);
                        JamRoot.ImageIndex := 2;
                        JamRoot.SelectedIndex := 2;

                        ItemsRoot := AddJamTreeNode(Tree, JamRoot,
                          Format('JAM Items: %d', [FHWJamFile.FHeader.NumItems]
                          ), FHWJamFile.FHeader.NumItems, -1, false, rootNode);

                        ItemsRoot.ImageIndex := 3;
                        ItemsRoot.SelectedIndex := 3;

                        for i := 0 to FHWJamFile.FEntries.Count - 1 do
                        begin
                                hwEntry := FHWJamFile.FEntries[i];

                                Node := AddJamTreeNode(Tree, ItemsRoot,
                                  Format('ID:%d  [%d x %d]',
                                  [hwEntry.Info.jamID, hwEntry.Info.Width,
                                  hwEntry.Info.height]), 0, i, false, jamID);

                                Node.ImageIndex := 4;
                                Node.SelectedIndex := 4;

                                AddJamTreeNode(Tree, Node,
                                  Format('X:%d', [hwEntry.Info.X]),
                                  hwEntry.Info.X, i, true, jamPosX);
                                AddJamTreeNode(Tree, Node,
                                  Format('Y:%d', [hwEntry.Info.Y]),
                                  hwEntry.Info.Y, i, true, jamposY);
                                AddJamTreeNode(Tree, Node,
                                  Format('Width:%d', [hwEntry.Info.Width]),
                                  hwEntry.Info.Width, i, false, jamwidth);
                                AddJamTreeNode(Tree, Node,
                                  Format('Height:%d', [hwEntry.Info.height]),
                                  hwEntry.Info.height, i, false, jamheight);
                                AddJamTreeNode(Tree, Node,
                                  Format('JamFlags:%d', [hwEntry.Info.jamFlags]
                                  ), hwEntry.Info.jamFlags, i, false, jamFlags);

                                ScalingNode :=
                                  AddJamTreeNode(Tree, Node, 'Scaling Info', 0,
                                  i, false, jamID);
                                ScalingNode.ImageIndex := 6;
                                ScalingNode.SelectedIndex := 6;

                                AddJamTreeNode(Tree, ScalingNode,
                                  Format('Origin X: %d', [hwEntry.Info.scaleX]),
                                  hwEntry.Info.scaleX, i, false, jamPosX);

                                AddJamTreeNode(Tree, ScalingNode,
                                  Format('Origin Y: %d', [hwEntry.Info.scaleY]),
                                  hwEntry.Info.scaleY, i, false, jamposY);

                                AddJamTreeNode(Tree, ScalingNode,
                                  Format('Scaling Factor: %d',
                                  [hwEntry.Info.scaleFactor]),
                                  (hwEntry.Info.scaleFactor), i, false,
                                  canvasDimensions);

                                AddJamTreeNode(Tree, ScalingNode,
                                  Format('Flags: %d', [(hwEntry.Info.scaleFlags)
                                  ]), hwEntry.Info.scaleFlags, i, false,
                                  jamFlags);

                                // AddJamTreeNode(Tree, Node, Format('Word6:%d', [hwEntry.Info.word6]),
                                // hwEntry.Info.word6, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word6a:%d', [hwEntry.Info.word6a]),
                                // hwEntry.Info.word6a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word6b:%d', [hwEntry.Info.word6b]),
                                // hwEntry.Info.word6b, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word7a:%d', [hwEntry.Info.word7a]),
                                // hwEntry.Info.word7a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word7b:%d', [hwEntry.Info.word7b]),
                                // hwEntry.Info.word7b, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word8a:%d', [hwEntry.Info.word8a]),
                                // hwEntry.Info.word8a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word8b:%d', [hwEntry.Info.word8b]),
                                // hwEntry.Info.word8b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word11:%d', [hwEntry.Info.word11]),
                                // hwEntry.Info.word11, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word11a:%d', [hwEntry.Info.word11a]),
                                // hwEntry.Info.word11a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word11b:%d', [hwEntry.Info.word11b]),
                                // hwEntry.Info.word11b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word12:%d', [hwEntry.Info.word12]),
                                // hwEntry.Info.word12, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word12a:%d', [hwEntry.Info.word12a]),
                                // hwEntry.Info.word12a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word12b:%d', [hwEntry.Info.word12b]),
                                // hwEntry.Info.word12b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word13:%d', [hwEntry.Info.word13]),
                                // hwEntry.Info.word13, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word13a:%d', [hwEntry.Info.word13a]),
                                // hwEntry.Info.word13a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word13b:%d', [hwEntry.Info.word13b]),
                                // hwEntry.Info.word13b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word14:%d', [hwEntry.Info.word14]),
                                // hwEntry.Info.word14, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word14a:%d', [hwEntry.Info.word14a]),
                                // hwEntry.Info.word14a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word14b:%d', [hwEntry.Info.word14b]),
                                // hwEntry.Info.word14b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word15:%d', [hwEntry.Info.word15]),
                                // hwEntry.Info.word15, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word15a:%d', [hwEntry.Info.word15a]),
                                // hwEntry.Info.word15a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word15b:%d', [hwEntry.Info.word15b]),
                                // hwEntry.Info.word15b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('Word16:%d', [hwEntry.Info.word16]),
                                // hwEntry.Info.word16, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word16a:%d', [hwEntry.Info.word16a]),
                                // hwEntry.Info.word16a, i, True, jamPosX);
                                // AddJamTreeNode(Tree, Node, Format('Word16b:%d', [hwEntry.Info.word16b]),
                                // hwEntry.Info.word16b, i, True, jamPosX);
                                //
                                // AddJamTreeNode(Tree, Node, Format('numframes:%d',
                                // [hwEntry.Info.NumFrames]), hwEntry.Info.NumFrames, i, True, jamPosX);
                        end;

                        AddJamTreeNode(Tree, JamRoot,
                          Format('Canvas Size: W: %d x H: %d',
                          [FHWJamFile.canvasWidth,
                          FHWJamFile.FHeader.JamTotalHeight]),
                          FHWJamFile.FHeader.JamTotalHeight, -1, true,
                          canvasDimensions);

                end
                else
                begin
                        with FJamFile do
                        begin
                                JamRoot := Tree.Items.Add(nil, JamFileName);
                                JamRoot.ImageIndex := 2;
                                JamRoot.SelectedIndex := 2;

                                ItemsRoot := AddJamTreeNode(Tree, JamRoot,
                                  Format('JAM Items: %d', [FHeader.NumItems]),
                                  FHeader.NumItems, -1, false, rootNode);

                                ItemsRoot.ImageIndex := 3;
                                ItemsRoot.SelectedIndex := 3;

                                for i := 0 to FEntries.Count - 1 do
                                begin
                                        E := FEntries[i];

                                        Node := AddJamTreeNode(Tree, ItemsRoot,
                                        Format('ID:%d  [%d x %d]',
                                        [E.Info.jamID, E.Info.Width,
                                        E.Info.height]), 0, i, false, jamID);

                                        Node.ImageIndex := 4;
                                        Node.SelectedIndex := 4;

                                        AddJamTreeNode(Tree, Node,
                                        Format('X:%d', [E.Info.X]), E.Info.X, i,
                                        true, jamPosX);
                                        AddJamTreeNode(Tree, Node,
                                        Format('Y:%d', [E.Info.Y]), E.Info.Y, i,
                                        true, jamposY);
                                        AddJamTreeNode(Tree, Node,
                                        Format('Width:%d', [E.Info.Width]),
                                        E.Info.Width, i, false, jamwidth);
                                        AddJamTreeNode(Tree, Node,
                                        Format('Height:%d', [E.Info.height]),
                                        E.Info.height, i, false, jamheight);
                                        AddJamTreeNode(Tree, Node,
                                        Format('ImagePTR:%d', [E.Info.ImagePtr]
                                        ), E.Info.jamFlags, i, false, jamData);
                                        AddJamTreeNode(Tree, Node,
                                        Format('JamFlags:%d', [E.Info.jamFlags]
                                        ), E.Info.jamFlags, i, false, jamFlags);
                                        AddJamTreeNode(Tree, Node,
                                        Format('PaletteSize:%d',
                                        [E.Info.PaletteSizeDiv4]),
                                        E.Info.PaletteSizeDiv4, i, false,
                                        jamPalInfo);

                                        ScalingNode :=
                                        AddJamTreeNode(Tree, Node,
                                        'Scaling Info', 0, i, false, jamID);
                                        ScalingNode.ImageIndex := 6;
                                        ScalingNode.SelectedIndex := 6;

                                        AddJamTreeNode(Tree, ScalingNode,
                                        Format('Origin X: %d', [E.Info.scaleX]),
                                        E.Info.scaleX, i, false, jamPosX);

                                        AddJamTreeNode(Tree, ScalingNode,
                                        Format('Origin Y: %d', [E.Info.scaleY]),
                                        E.Info.scaleY, i, false, jamposY);

                                        AddJamTreeNode(Tree, ScalingNode,
                                        Format('Scaling Factor: %d',
                                        [E.Info.scaleFactor]),
                                        (E.Info.scaleFactor), i, false,
                                        canvasDimensions);

                                        AddJamTreeNode(Tree, ScalingNode,
                                        Format('Flags: %d', [(E.Info.scaleFlag)]
                                        ), E.Info.scaleFlag, i, false,
                                        jamFlags);


                                        // AddJamTreeNode(Tree, ScalingNode, Format('Origin X: %d',[FJamFile.GetIDX08_X(E.Info.Idx08)]),
                                        // FJamFile.GetIDX08_X(E.Info.Idx08), I, false, jamPosX);
                                        //
                                        // AddJamTreeNode(Tree, ScalingNode, Format('Origin Y: %d',
                                        // [FJamFile.GetIDX08_Y(E.Info.Idx08)]),
                                        // FJamFile.GetIDX08_Y(E.Info.Idx08), I, false, jamposY);
                                        //
                                        // AddJamTreeNode(Tree, ScalingNode, Format('Scaling Factor: %d',
                                        // [FJamFile.GetIDX0aScale(E.Info.Idx0A)]),
                                        // FJamFile.GetIDX08_Y(E.Info.Idx08), I, false, canvasDimensions);
                                        //
                                        // AddJamTreeNode(Tree, ScalingNode,
                                        // Format('Flags: %d', [FJamFile.GetIDX0aFlags(E.Info.Idx0A)]),
                                        // FJamFile.GetIDX08_Y(E.Info.Idx08), I, false, jamFlags);

                                        UnTexNode :=
                                        AddJamTreeNode(Tree, Node,
                                        'Untextured Colour', 0, i, false,
                                        jamPalInfo);
                                        AddJamTreeNode(Tree, UnTexNode,
                                        Format('Primary: %d', [E.Info.Idx16]),
                                        E.Info.Idx16, i, true, jamColour);
                                        AddJamTreeNode(Tree, UnTexNode,
                                        Format('Secondary: %d', [E.Info.Idx17]),
                                        E.Info.Idx17, i, true, jamColour);

                                        UnkNode :=
                                        AddJamTreeNode(Tree, Node,
                                        'Unknown Data', 0, i, false, jamUnk);
                                        UnkNode.ImageIndex := 7;
                                        UnkNode.SelectedIndex := 7;
                                        AddJamTreeNode(Tree, UnkNode,
                                        Format('Idx03:%d', [E.Info.Unk]),
                                        E.Info.Unk, i, false, jamUnk);
                                        AddJamTreeNode(Tree, UnkNode,
                                        Format('Idx0E:%d', [E.Info.Idx0E]),
                                        E.Info.Idx0E, i, false, jamUnk);
                                        for j := 0 to 7 do
                                        AddJamTreeNode(Tree, UnkNode,
                                        Format('Idx18_0%d:%d',
                                        [j, E.Info.Idx18[j]]), E.Info.Idx18[j],
                                        i, false, jamUnk);
                                end;
                                AddJamTreeNode(Tree, JamRoot,
                                  Format('Canvas Size: W: %d x H: %d',
                                  [canvasWidth, FHeader.JamTotalHeight]),
                                  FHeader.JamTotalHeight, -1, true,
                                  canvasDimensions);
                        end;
                end;

                Tree.TopItem.Expanded := true;
        finally
                Tree.Items.EndUpdate;

        end;
end;

procedure TFormMain.Exit1Click(Sender: TObject);
begin
        close;
end;

function TFormMain.GetActiveJamFileName: string;
begin
        if boolHWJAM then
                Result := FHWJamFile.JamFileName
        else
                Result := FJamFile.JamFileName;
end;

function TFormMain.GetEntryJamID(EntryIndex: Integer): Word;
begin
        if boolHWJAM then
                Result := FHWJamFile.FEntries[EntryIndex].FInfo.JamID
        else
                Result := FJamFile.FEntries[EntryIndex].FInfo.JamID;
end;

function TFormMain.GetActiveEntryCount: Integer;
begin
        if boolHWJAM then
                Result := FHWJamFile.FEntries.Count
        else
                Result := FJamFile.FEntries.Count;
end;

procedure TFormMain.mainMenuExportCanvasClick(Sender: TObject);
var
        tempBMP: TBitmap;
begin
        if boolJamLoaded = true then
        begin
                exportDialog.InitialDir := strExportPath;
                exportDialog.Filename := GetActiveJamFileName + '.bmp';
                if exportDialog.Execute then
                begin
                        if boolHWJAM then
                        begin
                                tempBMP := FHWJamFile.DrawCanvas(false);
                                tempBMP.SaveToFile(exportDialog.filename);
                        end
                        else
                        begin
                                tempBMP := FJamFile.RenderJamCanvas(false);
                                tempBMP.SaveToFile(exportDialog.filename);
                        end;
                        strExportPath := ExtractFilePath(exportDialog.filename);
                end;
        end;
end;

procedure TFormMain.mainMenuExportAllTexturesClick(Sender: TObject);
var
        dlg: TFileOpenDialog;
        folder: string;
        i: Integer;
        fullPath: string;
        overwriteAll: Boolean;
        exported, skipped: Integer;
        cancelled: Boolean;
        choice: Integer;
        tempBMP: TBitmap;
        jamName: string;
begin
        if not boolJamLoaded then Exit;

        dlg := TFileOpenDialog.Create(nil);
        try
                dlg.Options := dlg.Options + [fdoPickFolders, fdoPathMustExist,
                        fdoForceFileSystem];
                dlg.Title := 'Choose folder to export all textures to';
                if strExportPath <> '' then
                        dlg.DefaultFolder := strExportPath;
                if not dlg.Execute then Exit;
                folder := dlg.FileName;
        finally
                dlg.Free;
        end;

        overwriteAll := False;
        exported := 0;
        skipped := 0;
        cancelled := False;
        jamName := GetActiveJamFileName;

        Screen.Cursor := crHourGlass;
        try
                for i := 0 to GetActiveEntryCount - 1 do
                begin
                        fullPath := IncludeTrailingPathDelimiter(folder) +
                                Format('%s_%.4d.bmp', [jamName, GetEntryJamID(i)]);

                        if FileExists(fullPath) and not overwriteAll then
                        begin
                                choice := MessageDlg(
                                        Format('File already exists:'#13#10'%s'#13#10#13#10 +
                                                'Overwrite?', [fullPath]),
                                        mtConfirmation,
                                        [mbYes, mbYesToAll, mbNo, mbCancel], 0);
                                case choice of
                                        mrYes: ; // overwrite this one
                                        mrYesToAll: overwriteAll := True;
                                        mrNo:
                                        begin
                                                Inc(skipped);
                                                Continue;
                                        end;
                                        mrCancel:
                                        begin
                                                cancelled := True;
                                                Break;
                                        end;
                                end;
                        end;

                        if boolHWJAM then
                        begin
                                FHWJamFile.ExportTexture(i, fullPath);
                        end
                        else
                        begin
                                tempBMP := FJamFile.FEntries[i].FCachedTex[0];
                                tempBMP.PixelFormat := pf8bit;
                                tempBMP.Palette := CreateGPxPal;
                                tempBMP.SaveToFile(fullPath);
                        end;

                        Inc(exported);
                end;

                strExportPath := folder;
        finally
                Screen.Cursor := crDefault;
        end;

        if cancelled then
                MessageDlg(Format('Cancelled. Exported %d texture(s), skipped %d.',
                        [exported, skipped]), mtInformation, [mbOK], 0)
        else
                MessageDlg(Format('Exported %d texture(s), skipped %d.',
                        [exported, skipped]), mtInformation, [mbOK], 0);
end;

procedure TFormMain.toolbar_NEWClick(Sender: TObject);
begin
        if not CheckJamModified() then Exit;

        if boolJamLoaded then
                DeSelectTexture();

        boolTexSelected := false;

        newJamDlg.newJamDialog.ShowModal;

end;

procedure TFormMain.toolbarZoomINClick(Sender: TObject);
var base: Double;
begin
        SetZoomAnchorToCenter;
        if timerZoom.Enabled then base := FTargetZoom else base := intJamZoom;
        StartZoomTo(base * 1.5);
end;

procedure TFormMain.toolbarZoomOUTClick(Sender: TObject);
var base: Double;
begin
        SetZoomAnchorToCenter;
        if timerZoom.Enabled then base := FTargetZoom else base := intJamZoom;
        StartZoomTo(base / 1.5);
end;

procedure TFormMain.toolbarZoomResetClick(Sender: TObject);
begin
        SetZoomAnchorToCenter;
        StartZoomTo(1.0);
end;

procedure TFormMain.toolbar_drawOutlinesClick(Sender: TObject);
begin
        btnDrawDataClick(Sender);
end;

procedure TFormMain.toolbarMoveClick(Sender: TObject);
begin
        FMoveToolActive := toolbarMove.Down;
        boolMoveToolActive := FMoveToolActive;
        FDrag.Active := false;
        FDrag.Mode := rmNone;
        if FMoveToolActive then
        begin
                // Capture the currently-selected texture's state so
                // Escape can revert to it.
                if (intSelectedTexture >= 0) and (not boolRcrJam) then
                        CaptureOriginalSelectedState;
        end
        else
        begin
                ImageCanvas.Cursor := crDefault;
                FOriginalSelectedIdx := -1;
        end;
        if booljamLoaded then
                RefreshCanvas;
end;

procedure TFormMain.toolbarSnapClick(Sender: TObject);
begin
        ToggleSnap;
end;

procedure TFormMain.menuSnapClick(Sender: TObject);
begin
        ToggleSnap;
end;

procedure TFormMain.toolbarCheckerboardClick(Sender: TObject);
begin
        ToggleCheckerboard;
end;

procedure TFormMain.menuCheckerboardClick(Sender: TObject);
begin
        ToggleCheckerboard;
end;

procedure TFormMain.menuDPIScaleClick(Sender: TObject);
begin
        ToggleDPIScaling;
end;

procedure TFormMain.ImageCanvasDblClick(Sender: TObject);
begin
        // Activate transform tool on double-click of a texture.
        // The first click already selected the texture; the second click
        // triggers this DblClick event.
        if not booljamLoaded then Exit;
        if boolRcrJam then Exit; // move tool not supported on RCR
        if intSelectedTexture < 0 then Exit;

        if not FMoveToolActive then
        begin
                toolbarMove.Down := True;
                toolbarMoveClick(nil);
        end;
end;

procedure TFormMain.TreeReDraw();
var
        Expanded: TStringList;
        SelectedPath: string;
begin
        Expanded := TStringList.Create;
        try
                SaveExpandedNodes(JamTree, Expanded, SelectedPath);
                DrawTree;
                RestoreExpandedNodes(JamTree, Expanded, SelectedPath);
        finally
                Expanded.Free;
        end;
end;

procedure TFormMain.JamAnalysis1Click(Sender: TObject);
begin
        frmJamAnalysis.show;
end;

procedure TFormMain.RenderRCR1Click(Sender: TObject);
var
        jamPath: string;
begin
        // The dialog runs in full isolation from the editor: it loads its
        // own TJamFile instances and snapshot/restores all global JAM
        // flags around every load (via LoadIsolatedJam). We only pass the
        // current filename (if any) so the dialog can preselect the
        // matching combo entry when the user currently has an RCR open.
        jamPath := '';
        if boolRcrJam and (MRUList <> nil) and (MRUList.Count > 0) then
                jamPath := MRUList[0];
        TJamRCRRenderDlgForm.Execute(Self, jamPath);
end;

procedure TFormMain.JamReGen;
var
        tmpCanvas: TBitmap;
        bmpPal: TBitmap;
        i: integer;

begin
        if not boolJamLoaded then
                Exit;

        if intSelectedTexture = -1 then
                Exit;

        i := intSelectedTexture;
        if boolHWJAM then
        begin
                tmpCanvas := FHWJamFile.FEntries[i].FOriginalTex;
                tmpCanvas := StretchF(tmpCanvas,
                  FHWJamFile.FEntries[i].Info.Width,
                  FHWJamFile.FEntries[i].Info.height);

                FHWJamFile.FEntries[i].FTexture.height := FHWJamFile.FEntries[i]
                  .Info.height;
                FHWJamFile.FEntries[i].FTexture.Width := FHWJamFile.FEntries[i]
                  .Info.Width;
                FHWJamFile.FEntries[i].FTexture := tmpCanvas;

                DrawTexture;
        end

        else
        begin

                intSimplifyThreshold := Round(numBox_SimpThresh.Value);
                intSimplifyMethod := comboSimpMethod.ItemIndex;
                intBlurThreshold := Round(numBox_BlurAmount.Value);
                boolSimpifyAllPals := chkBoxSimpPal.Checked;
                boolProtectTrans := chkBoxTrans.Checked;

                try
                        tmpCanvas := TBitmap.Create;
                        tmpCanvas.Assign(FJamFile.FEntries[i].FOriginalTex);

                        tmpCanvas :=
                          StretchF(tmpCanvas, FJamFile.FEntries[i].FInfo.Width,
                          FJamFile.FEntries[i].FInfo.height);

                        // Entries with a custom palette must regen palette
                        // AND texture from FOriginalTex on every pass —
                        // otherwise FCachedTex stays at its previous size and
                        // DrawFullJam stretches a low-res cached copy up to
                        // the new dims, compounding quality loss across
                        // repeated resizes. Non-palette entries already
                        // re-encode from the stretched original via the
                        // EncodeTexture branch below, so they're unaffected.
                        if FJamFile.FEntries[i].PaletteSizeDiv4 > 0 then
                                generatePal := true;

                        if generatePal then
                        begin
                                if Assigned(FJamFile.FEntries[i].FTexture) then
                                begin
                                        FreeAndNil
                                        (FJamFile.FEntries[i].FTexture);
                                        FJamFile.FEntries[i].FTexture :=
                                        TBitmap.Create;
                                end;

                                FJamFile.FEntries[i].FTexture :=
                                  FJamFile.GenerateGPxBMP(tmpCanvas, i,
                                  intSimplifyMethod, intSimplifyThreshold,
                                  intBlurThreshold, boolSimpifyAllPals,
                                  boolProtectTrans);

                        end
                        else
                        begin
                                if FJamFile.FEntries[i].PaletteSizeDiv4 > 0 then

                                else
                                begin
                                        bmpPal := TBitmap.Create;
                                        // bmpPal.Assign(tmpCanvas);
                                        // bmpPal.PixelFormat := pf8bit;
                                        bmpPal := CreateGPxPalBMP(tmpCanvas);
                                        bmpPal.Palette := creategpxpal;
                                        FJamFile.EncodeTexture(i, bmpPal);
                                        bmpPal.Free;
                                end;
                        end;

                        if FJamFile.FEntries[i].PaletteSizeDiv4 > 0 then
                                FJamFile.CachePaletteBMP(i)
                        else
                                FJamFile.CachePaletteBMP(i);

                        RefreshPalette;
                        if boolJipMode then
                        Fjamfile.DrawJIPMipmaps;
                        RefreshCanvas;
                        DrawTexture;




                        chkBoxTrans.Checked :=
                          DetectTransCol(FJamFile.FEntries[i].FTexture);

                finally
                        tmpCanvas.Free;
                        generatePal := false;
                end;
        end;
end;

procedure TFormMain.menuDrawOutlinesClick(Sender: TObject);
begin
        btnDrawDataClick(Sender);
end;

procedure TFormMain.DrawTexture;
var
        tmpDims: integer;
begin
        if (not boolJamLoaded) or (intSelectedTexture < 0) then
                Exit;

        if boolHWJAM then
                ImageEntry.Picture.Bitmap := FHWJamFile.FEntries
                  [intSelectedTexture].FTexture
        else if boolRCRJAM then

        begin
                // tmpDims := (FJamFile.FEntries[intSelectedTexture].Info.Width)* FJamFile.FEntries[intSelectedTexture].Info.Height;
                // showMessage(Format('%d v %d', [Length(FJamFile.FEntries[intSelectedTexture].FRawTexture), tmpDims]));
                ImageEntry.Picture.Bitmap :=
                  FJamFile.DrawRawData(FJamFile.FEntries[intSelectedTexture]
                  .FRawTexture, FJamFile.FEntries[intSelectedTexture].Info.Width
                  * 2, FJamFile.FEntries[intSelectedTexture].Info.height);
                ImageEntry.Picture.Bitmap.Width :=
                  ImageEntry.Picture.Bitmap.Width;
                // if boolRCRDrawMode then
                // ImageEntry.Picture.Bitmap := FJamFile.FEntries[intSelectedTexture].rcrB
                // else
                //
                // ImageEntry.Picture.Bitmap := FJamFile.FEntries[intSelectedTexture].rcrA
        end
        else
                ImageEntry.Picture.Bitmap := FJamFile.FEntries
                  [intSelectedTexture].FCachedTex[intPaletteID];
end;

procedure TFormMain.PalChange(palID: integer);
var
        X: integer;
        btnArray: array [0 .. 3] of TToolButton;
begin

        if boolJamLoaded = true then
        begin

                btnArray[0] := toolBar_Pal1;
                btnArray[1] := toolBar_Pal2;
                btnArray[2] := toolBar_Pal3;
                btnArray[3] := toolBar_Pal4;

                intPaletteID := palID;

                for X := 0 to 3 do
                        if X = intPaletteID then
                                btnArray[X].down := true;

                RefreshPalette();
                RefreshCanvas;
                if intSelectedTexture > -1 then
                        DrawTexture
        end;
end;

procedure TFormMain.panel_PalEditCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_PalEditExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_RCRControlsCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_RCRControlsExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_ScaleParametersCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_ScaleParametersExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_TexFlagsCollapse(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.panel_TexFlagsExpand(Sender: TObject);
begin
        ForceCategoryPanelRedraw(CategoryPanelGroup1);
end;

procedure TFormMain.BatchConvert1Click(Sender: TObject);
begin
        jambatch.JamBatchForm.show;
end;

procedure TFormMain.Browser1Click(Sender: TObject);
begin
        JamBrowser.JamBrowserFrm.show;
end;

procedure TFormMain.btnDrawDataClick(Sender: TObject);
begin
        if boolJamLoaded = true then
        begin
                boolDrawOutlines := not boolDrawOutlines;
                toolbar_drawOutlines.down := boolDrawOutlines;
                menuDrawOutlines.Checked := boolDrawOutlines;
                RefreshCanvas;
        end;
end;

procedure TFormMain.btnExportTextureClick(Sender: TObject);
var
        tempBMP: TBitmap;
begin
        if boolJamLoaded = true then
        begin
                exportDialog.InitialDir := strExportPath;
                exportDialog.Filename := Format('%s_%.4d.bmp',
                        [GetActiveJamFileName, GetEntryJamID(intSelectedTexture)]);
                if exportDialog.Execute then
                begin
                        if boolHWJAM then
                                FHWJamFile.ExportTexture(intSelectedTexture,
                                  exportDialog.filename)
                        else
                        begin
                                tempBMP := FJamFile.FEntries[intSelectedTexture]
                                  .FCachedTex[0];
                                tempBMP.PixelFormat := pf8bit;
                                tempBMP.Palette := creategpxpal;
                                tempBMP.SaveToFile(exportDialog.filename);
                        end;
                        strExportPath := ExtractFilePath(exportDialog.filename);
                end;
        end;
end;

procedure TFormMain.btnGP2palClick(Sender: TObject);
begin

        FJamFile.SetGpxPal(true);

        if boolJamLoaded = true then
        begin
                FJamFile.ReCacheTextures;

                RefreshPalette;
                RefreshCanvas;

                if boolTexSelected then
                        DrawTexture;

                boolGP2Jam := true;
                boolGP3Jam := false;
                boolHWJAM := false;

                toolBar_GP3PAL.down := false;
        end;

end;

procedure TFormMain.btnGP3palClick(Sender: TObject);

begin

        FJamFile.SetGpxPal(false);

        if boolJamLoaded = true then
        begin
                FJamFile.ReCacheTextures;

                RefreshPalette;
                RefreshCanvas;

                if boolTexSelected then
                        DrawTexture;

                boolGP2Jam := false;
                boolGP3Jam := true;
                boolHWJAM := false;

                toolBar_GP2PAL.down := false;

        end;
end;

procedure TFormMain.NewJam(filename: string; height: integer);
var
        i: integer;
begin

        boolUndo := false;

        if Assigned(FHWJamFile) then
                FreeAndNil(FHWJamFile);

        if Assigned(FJamFile) then
                FreeAndNil(FJamFile);

        if boolHWJAM then
        begin
                boolHWJAM := true;
                if panel_PalPreview.Visible then
                        ClearPaletteImg;

                FHWJamFile := THWJamFile.Create;

                FHWJamFile.CreateNewHWJam(filename, height);

        end
        else
        begin

                FJamFile := TJamFile.Create;

                FJamFile.CreateNewJAM(filename, height);

                for i := 0 to 255 do
                        localGpxPal[i] := GPXPal[i];

                PalChange(0);

        end;

        intSelectedTexture := -1;
        intJamZoom := 1;

        boolJamLoaded := true;

        boolJamModified := true;

        UISetup();

        DrawTree;

        RefreshCanvas;

        SetStretchBltMode(ImageCanvas.Canvas.Handle, COLORONCOLOR);

        HWUndoStack.Clear;
        SWUndoStack.Clear;

        boolUndo := true;

end;

procedure TFormMain.LoadJam(filename: string);

begin
        boolUndo := false;

        Undo1.Enabled := false;
        Redo1.Enabled := false;

        HWUndoStack.Clear;
        SWUndoStack.Clear;

        if Assigned(FHWJamFile) then
        begin
                DeSelectTexture;
                FreeAndNil(FHWJamFile);
        end;

        if Assigned(FJamFile) then
        begin
                DeSelectTexture;
                FreeAndNil(FJamFile);
        end;

        boolJamLoaded := false;

        boolTexSelected := false;

        JamModified(false);

        if isHWJAM(filename) then
        begin
                boolHWJAM := true;

                if not Assigned(FHWJamFile) then
                        FHWJamFile := THWJamFile.Create;

                boolJamLoaded := FHWJamFile.LoadFromFile(filename);
                jamtype := jamGP3HW;
        end
        else
        begin
                boolHWJAM := false;

                if not Assigned(FJamFile) then
                        FJamFile := TJamFile.Create;

                jamtype := TJamPaletteDetector.Instance.Detect(filename, false);
                case jamtype of
                        jamGP2:
                                begin
                                        FJamFile.SetGpxPal(true)
                                end;
                        jamGP3SW:
                                begin
                                        FJamFile.SetGpxPal(false)
                                end;
                end;
                FJamFile.JamType := jamtype;

                boolJamLoaded := FJamFile.LoadFromFile(filename, false);
        end;

        if boolJamLoaded then
        begin
                HWUndoStack.Clear;
                SWUndoStack.Clear;
                AddToMRU(filename);

                intSelectedTexture := -1;
                intJamZoom := 1;

                UISetup();

                DrawTree;

                RefreshCanvas;

                SetStretchBltMode(ImageCanvas.Canvas.Handle, COLORONCOLOR);
        end;

        boolUndo := true;

        JamModified(false);

end;

procedure TFormMain.OpenCommandLineFile;
var
        filePath, ext: string;
begin
        if ParamCount < 1 then
                Exit;

        filePath := ExpandFileName(ParamStr(1));
        ext := LowerCase(ExtractFileExt(filePath));

        if ((ext = '.jam') or (ext = '.jip')) and FileExists(filePath) then
        begin
                LoadJam(filePath);
                strOpenPath := ExtractFilePath(filePath);
        end;
end;

procedure TFormMain.WMCopyData(var Msg: TWMCopyData);
var
        fileToOpen: string;
        charCount: integer;
begin
        Msg.Result := 0;

        if (Msg.CopyDataStruct = nil) or
          (Msg.CopyDataStruct.dwData <> JamCopyDataOpenFile) or
          (Msg.CopyDataStruct.cbData < SizeOf(Char)) then
        begin
                inherited;
                Exit;
        end;

        // Copy the payload out immediately — the pointer is only valid
        // for the duration of this handler.
        charCount := Msg.CopyDataStruct.cbData div SizeOf(Char);
        SetString(fileToOpen, PChar(Msg.CopyDataStruct.lpData), charCount);
        // cbData includes the null terminator; strip it
        fileToOpen := fileToOpen.TrimRight([#0]);

        Msg.Result := 1;

        if IsIconic(Application.Handle) or IsIconic(Handle) then
                Application.Restore;
        SetForegroundWindow(Handle);

        if (fileToOpen = '') or not FileExists(fileToOpen) then
                Exit;

        // Only interrupt the user if the current session has unsaved
        // edits — CheckJamModified prompts (save / discard / cancel) in
        // that case and is silent otherwise, same guard as btnLoadJamClick.
        if not CheckJamModified() then
                Exit;

        LoadJam(fileToOpen);
        strOpenPath := ExtractFilePath(fileToOpen);
end;

procedure TFormMain.UISetup();
var
        i: integer;

begin
        if boolJamLoaded then
        begin
                SaveDecryptedJAM.Visible := false;
                toolbar_drawOutlines.Enabled := true;
                toolbar_drawOutlines.down := boolDrawOutlines;
                menuDrawOutlines.Checked := boolDrawOutlines;
                toolBar_Save.Enabled := true;
                toolBar_AddTexture.Enabled := true;
                toolbarZoomIN.Enabled := true;
                toolbarZoomOUT.Enabled := true;
                toolbarZoomReset.Enabled := true;
                mainMenuSave.Enabled := true;
                mainMenuSaveAs.Enabled := true;
                menuDrawOutlines.Enabled := true;
                ResetZoom1.Enabled := true;

                autoPackTexs.Enabled := true;

                if boolHWJAM then
                begin
                        if panel_PalPreview.Visible then
                                ClearPaletteImg;

                        panel_TexturePreview.Visible := true;
                        Panel_TexProperties.Visible := true;
                        panel_TexFlags.Visible := true;
                        panel_TexScaling.Visible := true;
                        panel_ScaleParameters.Visible := true;

                        panel_PalPreview.Visible := false;
                        // panel_PaletteEdit.Visible := false;

                        // panel_palEdit.Visible := false;
                        panel_RCRControls.Visible := false;

                        panel_TexProperties_Generic.Enabled := true;

                        toolBar_PalPrev.Visible := false;
                        toolBar_Pal1.Visible := false;
                        toolBar_Pal2.Visible := false;
                        toolBar_Pal3.Visible := false;
                        toolBar_Pal4.Visible := false;
                        toolBar_PalNext.Visible := false;
                        toolBar_GP2PAL.Enabled := false;
                        toolBar_GP3PAL.Enabled := false;

                        btnGenPal.Enabled := false;
                        btnPal0.Enabled := false;
                        btnPal1.Enabled := false;
                        btnPal2.Enabled := false;
                        btnPal3.Enabled := false;
                        btnRegenAllPals.Enabled := false;
                        btnRemoveAllPals.Enabled := false;
                        btnRemovePal.Enabled := false;

                        mainMenuAddTexture.Enabled := true;
                        mainMenuDeleteTexture.Enabled := true;
                        toolBar_AddTexture.Enabled := true;
                        toolBar_DeleteTexture.Enabled := true;

                        popUpAddTexture.Enabled := true;
                        popUpDeleteTexture.Enabled := true;

                        ConverttoGP2JAM.Enabled := true;
                        ConverttoGP3SWJAM.Enabled := true;
                        ConverttoGP3HWJAM.Enabled := false;

                        canvasHeight.Enabled := true;
                        Button5.Enabled := true;

                        canvasHeight.Value := FHWJamFile.FHeader.JamTotalHeight;

                        SaveDecryptedJAM.Visible := false;

                end
                else
                begin
                        for i := 0 to 255 do
                                localGpxPal[i] := GPXPal[i];
                        SaveDecryptedJAM.Visible := true;
                        PalChange(0);

                        panel_TexturePreview.Visible := true;
                        Panel_TexProperties.Visible := true;
                        panel_TexFlags.Visible := true;
                        panel_TexScaling.Visible := true;
                        panel_ScaleParameters.Visible := true;

                        panel_TexProperties_Generic.Enabled := true;

                        panel_PaletteEdit.Visible := true;

                        panel_PalEdit.Visible := true;
                        panel_RCRControls.Visible := false;

                        canvasHeight.Enabled := true;
                        Button5.Enabled := true;

                        mainMenuAddTexture.Enabled := true;
                        mainMenuDeleteTexture.Enabled := true;
                        toolBar_AddTexture.Enabled := true;
                        toolBar_DeleteTexture.Enabled := true;

                        popUpAddTexture.Enabled := true;
                        popUpDeleteTexture.Enabled := true;

                        toolBar_PalPrev.Visible := true;
                        toolBar_Pal1.Visible := true;
                        toolBar_Pal2.Visible := true;
                        toolBar_Pal3.Visible := true;
                        toolBar_Pal4.Visible := true;
                        toolBar_PalNext.Visible := true;
                        toolBar_GP2PAL.Enabled := true;
                        toolBar_GP3PAL.Enabled := true;

                        btnPal0.Enabled := true;
                        btnPal1.Enabled := true;
                        btnPal2.Enabled := true;
                        btnPal3.Enabled := true;
                        btnRegenAllPals.Enabled := true;
                        btnRemoveAllPals.Enabled := true;

                        canvasHeight.Value := FJamFile.FHeader.JamTotalHeight;

                        SaveDecryptedJAM.Visible := true;

                        case jamtype of
                                jamGP2:
                                        begin
                                        toolBar_GP3PAL.down := false;
                                        toolBar_GP2PAL.down := true;
                                        ConverttoGP2JAM.Enabled := false;
                                        ConverttoGP3SWJAM.Enabled := true;
                                        ConverttoGP3HWJAM.Enabled := true;
                                        end;
                                jamGP3SW:
                                        begin
                                        toolBar_GP3PAL.down := true;
                                        toolBar_GP2PAL.down := false;
                                        ConverttoGP2JAM.Enabled := true;
                                        ConverttoGP3SWJAM.Enabled := false;
                                        ConverttoGP3HWJAM.Enabled := true;

                                        end;
                        end;

                end;

                if boolRCRJAM or boolJipMode then
                begin

                        panel_PaletteEdit.Visible := false;
                        panel_PalEdit.Visible := false;

                        toolBar_PalPrev.Visible := false;
                        toolBar_Pal1.Visible := false;
                        toolBar_Pal2.Visible := false;
                        toolBar_Pal3.Visible := false;
                        toolBar_Pal4.Visible := false;
                        toolBar_PalNext.Visible := false;

                        btnGenPal.Enabled := false;
                        btnPal0.Enabled := false;
                        btnPal1.Enabled := false;
                        btnPal2.Enabled := false;
                        btnPal3.Enabled := false;
                        btnRegenAllPals.Enabled := false;
                        btnRemoveAllPals.Enabled := false;
                        btnRemovePal.Enabled := false;

                        ConverttoGP2JAM.Enabled := false;
                        ConverttoGP3SWJAM.Enabled := false;
                        ConverttoGP3HWJAM.Enabled := false;
                end
                else
                        panel_RCR.Visible := false;
                if boolRCRJAM then
                begin
                        panel_RCR.Visible := true;
                        panel_RCRControls.Visible := true;
                        panel_TexProperties_Generic.Enabled := false;
                        canvasHeight.Enabled := false;
                        Button5.Enabled := false;

                        autoPackTexs.Enabled := false;

                        mainMenuAddTexture.Enabled := false;
                        mainMenuDeleteTexture.Enabled := false;
                        toolBar_AddTexture.Enabled := false;
                        toolBar_DeleteTexture.Enabled := false;

                        popUpAddTexture.Enabled := false;
                        popUpDeleteTexture.Enabled := false;
                end
                else if boolJipMode then
                begin
                        toolBar_GP2PAL.Enabled := false;
                        toolBar_GP3PAL.Enabled := false;
                end;
        end;

        UpdateCaption;

end;

procedure TFormMain.Undo1Click(Sender: TObject);
begin
        DoUndo;
end;

procedure TFormMain.undoTimerTimer(Sender: TObject);
begin
        undoTimer.Enabled := false;
        boolUndo := true;
end;

procedure TFormMain.btnLoadJamClick(Sender: TObject);
begin

        if not CheckJamModified() then Exit;

        dlgOpenJam.InitialDir := strOpenPath;

        if dlgOpenJam.Execute then
        begin
                if (dlgOpenJam.filename <> '') and
                  FileExists(dlgOpenJam.filename) then
                begin
                        // if boolHWJAM = True then
                        // begin
                        // if Assigned(FHWJamFile) then
                        // begin
                        // DeSelectTexture;
                        // JamTree.Items.Clear;
                        // boolJamLoaded := false;
                        // end;
                        // end;
                        // if Assigned(FJamFile) then
                        // begin
                        // showmessage('jam file deloading');
                        // DeSelectTexture;
                        // JamTree.Items.Clear;
                        // boolJamLoaded := false;
                        // end;
                        LoadJam(dlgOpenJam.filename);
                        strOpenPath := ExtractFilePath(dlgOpenJam.filename);
                end;
        end;
end;

procedure TFormMain.btnPal0Click(Sender: TObject);
begin
        PalChange(0);
end;

procedure TFormMain.btnPal1Click(Sender: TObject);
begin
        PalChange(1);
end;

procedure TFormMain.btnPal2Click(Sender: TObject);
begin
        PalChange(2);
end;

procedure TFormMain.btnPal3Click(Sender: TObject);
begin
        PalChange(3);
end;

procedure TFormMain.btnSaveJamClick(Sender: TObject);
begin

        if JamSanityCheck then
        begin
                JamSanityCheckInform(true);
                Exit;
        end;

        if boolHWJAM then
                FHWJamFile.SaveToFile(FHWJamFile.JamFullPath)
        else
                FJamFile.SaveToFile(FJamFile.JamFullPath, false);

        JamModified(false);
end;

procedure TFormMain.genMask;
var

        bmp, scaledBMP: TBitmap;
        newWidth, newHeight: integer;
begin

        if boolHWJAM = false then
                bmp := CreateTransparencyMatte(FJamFile.DrawFullJam(true));

        if boolHWJAM = true then
                bmp := CreateTransparencyMatte(FHWJamFile.DrawCanvas(true));

        newWidth := Round(bmp.Width * EffectiveJamZoom);
        newHeight := Round(bmp.height * EffectiveJamZoom);

        try
                scaledBMP := TBitmap.Create;
                scaledBMP.height := newHeight;
                scaledBMP.Width := newWidth;

                SetStretchBltMode(scaledBMP.Canvas.Handle, COLORONCOLOR);

                StretchBlt(scaledBMP.Canvas.Handle, 0, 0, newWidth, newHeight,
                  bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.height, SRCCOPY);

                ApplyOutlineOverlay(scaledBMP);

                ImageCanvas.height := newHeight;
                ImageCanvas.Width := newWidth;
                ImageCanvas.Picture.Bitmap := scaledBMP;

        finally
                FreeAndNil(scaledBMP);
                FreeAndNil(bmp);
        end;
end;

procedure TFormMain.Button1Click(Sender: TObject);

begin

        boolRCRDrawMode := not boolRCRDrawMode;

        if boolRCRDrawMode then
                ImageEntry.Picture.Bitmap :=
                  IndexedToIndexRGB(FJamFile.FEntries[intSelectedTexture].rcrB)
        else
                ImageEntry.Picture.Bitmap :=
                  IndexedToIndexRGB(FJamFile.FEntries[intSelectedTexture].rcrA);

end;

procedure TFormMain.Button2Click(Sender: TObject);
var
        i: integer;
        tmpBMP: TBitmap;
        tempX, prevY, tempY, newWidth, newHeight: integer;
begin

        // Clone
        tmpBMP := TBitmap.Create;

        tmpBMP.SetSize(512, FJamFile.FHeader.JamTotalHeight);

        newWidth := Round(tmpBMP.Width * EffectiveJamZoom);
        newHeight := Round(tmpBMP.height * EffectiveJamZoom);

        boolRCRJAM := true;
        FJamFile.EncodeCanvas;

        tmpBMP := FJamFile.DrawRawJAM(FJamFile.FRawData);

        // Draw on the clone
        for i := 0 to FJamFile.FEntries.Count - 1 do
                with FJamFile.FEntries[i].Info do
                begin

                        tempX := X;
                        tempY := Y;

                        if boolRCRJAM then
                        begin
                                if Y mod 2 <> 0 then
                                begin
                                        // prevY := FEntries[i - 1].FInfo.Y;
                                        tempY := tempY - 1;
                                        tempX := tempX + 256;
                                end;

                                tempY := tempY div 2;
                                boolRCRJAM := false;
                                tmpBMP := DrawTextureOutlines(tmpBMP, tempX,
                                  tempY, Width * 2, height, i, jamID);
                                boolRCRJAM := true;
                        end;
                end;

        ImageCanvas.Picture.Bitmap := tmpBMP;

        ImageCanvas.height := newHeight;
        ImageCanvas.Width := newWidth;
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
if boolUndo then
PushUndoState;
Fjamfile.DrawJIPMipmaps;
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
        FJamFile.ResizeJam(FJamFile.FHeader.JamTotalHeight);
        RefreshPalette;
        RefreshCanvas;
        DrawTexture;
        TreeReDraw;
end;

procedure TFormMain.Button5Click(Sender: TObject);
var
        i: integer;
        newHeight: integer;
begin
        newHeight := 0;

        if boolHWJAM then
        begin
                for i := 0 to FHWJamFile.FEntries.Count - 1 do
                        newHeight :=
                          Max(newHeight, FHWJamFile.FEntries[i].FInfo.Y +
                          FHWJamFile.FEntries[i].FInfo.height);

                FHWJamFile.ChangeJamCanvasHeight(newHeight);

                RefreshCanvas;
                TreeReDraw;
                JamModified(true);
        end
        else
        begin
                for i := 0 to FJamFile.FEntries.Count - 1 do
                        newHeight :=
                          Max(newHeight, FJamFile.FEntries[i].FInfo.Y +
                          FJamFile.FEntries[i].FInfo.height);

                FJamFile.ChangeJamCanvasHeight(newHeight);

                RefreshCanvas;
                TreeReDraw;

                JamModified(true);

        end;

end;

procedure TFormMain.Button6Click(Sender: TObject);
var

        c: TRGB;
        i: integer;

begin

        for i := 0 to 255 do
        begin
                c.r := i;
                c.g := i;
                c.b := i;
                GPXPal[i] := c;
                localGpxPal[i] := c;
        end;

        RefreshCanvas;

end;

procedure TFormMain.ConvertJAM(output: TJamType);
var
        tmpJAM: TJamFile;
        i: integer;
        tmpFilename, tmpFullPath: string;
        sameTypeConversion: boolean;
begin

        UpdatingFromCode := true;

        // Capture the pre-conversion state so the user can undo the conversion.
        // PushUndoState clones the currently-active jam onto the correct stack
        // (HW or SW) and clears the redo stack.
        PushUndoState;

        // Same-type (SW <-> SW) conversions can be fully undone because the
        // pre-state lives in the SW stack that DoUndo will look at after the
        // conversion completes.  Cross-type conversions still clear stacks at
        // the end since the saved pre-state would otherwise live in the
        // opposite (now-inactive) stack.
        sameTypeConversion := (jamtype <> jamGP3HW) and (output <> jamGP3HW);

        // Capture both the filename and full path so the converted JAM
        // can display the same name in the form caption (UpdateCaption
        // reads JamFullPath) and downstream code that uses JamFileName
        // continues to see the original.
        if jamtype = jamGP3HW then
        begin
                tmpFilename := FHWJamFile.JamFileName;
                tmpFullPath := FHWJamFile.JamFullPath;
        end
        else
        begin
                tmpFilename := FJamFile.JamFileName;
                tmpFullPath := FJamFile.JamFullPath;
        end;

        case output of

                jamGP2:

                        begin
                                if jamtype <> jamGP3HW then
                                begin
                                        // SW → GP2: clone before clearing
                                        tmpJAM := FJamFile.Clone;
                                end;

                                if Assigned(FJamFile) then
                                begin
                                        for i := 0 to FJamFile.FEntries.
                                        Count - 1 do
                                        FJamFile.FEntries[i].Free;

                                        FJamFile.FEntries.Clear;
                                        FJamFile.FHeader.NumItems := 0;
                                end
                                else
                                begin
                                        FJamFile := TJamFile.Create
                                end;

                                if jamtype = jamGP3HW then
                                begin
                                        FJamFile.ConvertHWJam(FHWJamFile, true);
                                        FJamFile.SetGpxPal(true);
                                        FJamFile.JamFileName := tmpFilename;
                                        FJamFile.JamFullPath := tmpFullPath;
                                end
                                else
                                begin
                                        try
                                                FJamFile.ConvertGPxJam(tmpJAM, true);
                                        finally
                                                tmpJAM.Free;
                                        end;
                                        FJamFile.JamFileName := tmpFilename;
                                        FJamFile.JamFullPath := tmpFullPath;
                                end;

                                FJamFile.JamType := jamGP2;
                                boolGP2Jam := true;
                                boolGP3Jam := false;
                                boolHWJAM := false;

                                toolBar_GP3PAL.down := false;
                                toolBar_GP2PAL.down := true;
                                jamtype := jamGP2;

                        end;

                jamGP3SW:

                        begin

                                if jamtype <> jamGP3HW then
                                begin
                                        // SW → GP3SW: clone before clearing
                                        tmpJAM := FJamFile.Clone;
                                end;

                                if Assigned(FJamFile) then
                                begin
                                        for i := 0 to FJamFile.FEntries.
                                        Count - 1 do
                                        FJamFile.FEntries[i].Free;

                                        FJamFile.FEntries.Clear;

                                        FJamFile.FHeader.NumItems := 0;
                                end
                                else
                                begin
                                        FJamFile := TJamFile.Create
                                end;

                                if jamtype = jamGP3HW then
                                begin
                                        FJamFile.ConvertHWJam
                                        (FHWJamFile, false);
                                        FJamFile.JamFileName := tmpFilename;
                                        FJamFile.JamFullPath := tmpFullPath;
                                end
                                else
                                begin
                                        try
                                                FJamFile.ConvertGPxJam(tmpJAM, false);
                                        finally
                                                tmpJAM.Free;
                                        end;
                                        FJamFile.JamFileName := tmpFilename;
                                        FJamFile.JamFullPath := tmpFullPath;
                                end;
                                FJamFile.SetGpxPal(false);

                                FJamFile.JamType := jamGP3SW;
                                boolGP2Jam := false;
                                boolGP3Jam := true;
                                boolHWJAM := false;

                                toolBar_GP3PAL.down := true;
                                toolBar_GP2PAL.down := false;
                                jamtype := jamGP3SW;
                        end;

                jamGP3HW:

                        begin

                                if Assigned(FHWJamFile) then
                                begin
                                        for i := 0 to FHWJamFile.FEntries.
                                        Count - 1 do
                                        FHWJamFile.FEntries[i].Free;

                                        FHWJamFile.FEntries.Clear;

                                        FHWJamFile.FHeader.NumItems := 0;
                                end
                                else
                                begin
                                        FHWJamFile := THWJamFile.Create;
                                end;

                                // Inline former THWJamFile.ConvertGPxJam:
                                // FJamFile bitmaps are already decoded in memory;
                                // no file I/O or palette detection needed.
                                intJamMaxWidth := 256;
                                FHWJamFile.canvasWidth := 256;
                                FHWJamFile.FHeader.JamTotalHeight :=
                                  FJamFile.FHeader.JamTotalHeight;
                                intJamMaxHeight :=
                                  FHWJamFile.FHeader.JamTotalHeight;
                                FreeAndNil(FHWJamFile.CanvasBitmap);
                                FHWJamFile.CanvasBitmap := TBitmap.Create;
                                FHWJamFile.CanvasBitmap.Canvas.Lock;
                                with FHWJamFile.CanvasBitmap do
                                begin
                                        PixelFormat := pf24bit;
                                        Width := 256;
                                        Height :=
                                          FHWJamFile.FHeader.JamTotalHeight;
                                        Canvas.Brush.Color := TCol_TransGP3HW;
                                        Canvas.FillRect(Rect(0, 0,
                                          Width, Height));
                                end;
                                FHWJamFile.CanvasBitmap.Canvas.Unlock;
                                for i := 0 to FJamFile.FHeader.NumItems - 1 do
                                        FHWJamFile.AddTexture(
                                          FJamFile.FEntries[i].FTexture,
                                          FJamFile.FEntries[i].FInfo);
                                FHWJamFile.FHeader.NumItems :=
                                  FJamFile.FHeader.NumItems;
                                FreeAndNil(FJamFile);
                                FHWJamFile.JamFileName := tmpFilename;
                                FHWJamFile.JamFullPath := tmpFullPath;

                                boolGP2Jam := false;
                                boolGP3Jam := false;
                                boolHWJAM := true;

                                jamtype := jamGP3HW;

                                toolBar_GP3PAL.down := true;
                                toolBar_GP2PAL.down := false;
                        end;
        end;

        // For cross-type conversions (SW<->HW) the pre-state pushed at the top
        // lives in the now-inactive stack, so wipe everything to avoid leaving
        // an orphaned (and undoable-only-via-type-swap) entry behind.  For
        // same-type SW<->SW conversions the pre-state pushed at the top is
        // exactly what we want to keep on the SW undo stack.
        if not sameTypeConversion then
        begin
                HWUndoStack.Clear;
                SWUndoStack.Clear;
        end
        else
        begin
                // Only the inactive HW stack is meaningless for SW<->SW; keep
                // the SW stack intact for the undo we just pushed.
                HWUndoStack.Clear;
        end;

        Undo1.Enabled := (boolHWJAM and (HWUndoStack.Count > 0))
                or ((not boolHWJAM) and (SWUndoStack.Count > 0));

        UpdatingFromCode := false;

        UISetup;

        DrawTree;
        RefreshCanvas;

        if boolTexSelected then
                DrawTexture;

        // The converted JAM differs from the on-disk source, so mark the
        // file dirty.  JamModified(true) also refreshes the form caption,
        // which now reflects the filename / path we preserved above.
        JamModified(true);

end;

procedure TFormMain.ConverttoGP2JAMClick(Sender: TObject);
begin
        ConvertJAM(jamGP2);
end;

procedure TFormMain.ConverttoGP3HWJAMClick(Sender: TObject);
begin

        ConvertJAM(jamGP3HW);
end;

procedure TFormMain.ConverttoGP3SWJAMClick(Sender: TObject);
begin
        ConvertJAM(jamGP3SW);
end;

procedure TFormMain.btnRegenAllPalsClick(Sender: TObject);
var
        i: integer;
        tmpCanvas: TBitmap;
begin

        intSimplifyThreshold := Round(numBox_SimpThresh.Value);
        intSimplifyMethod := comboSimpMethod.ItemIndex;
        intBlurThreshold := Round(numBox_BlurAmount.Value);
        boolSimpifyAllPals := chkBoxSimpPal.Checked;
        boolProtectTrans := chkBoxTrans.Checked;

        // Mirrors JamReGen's per-entry work, with the UI refresh hoisted
        // out so it fires once instead of N times. Two things this MUST
        // get right per iteration:
        //   1) Stretch FOriginalTex to the entry's CURRENT FInfo dims
        //      before palette regen — without this, resized entries
        //      come back with FTexture at the original (wrong) size and
        //      render corrupted.
        //   2) Use a FRESH tmpCanvas each iteration. GenerateGPxBMP
        //      frees its input bitmap (SrcRGB.free in its finally), so
        //      reusing one tmpCanvas across iterations leaves it
        //      dangling after iter 0 — subsequent .Assign calls write
        //      into freed memory and corrupt unrelated entries.
        for i := 0 to FJamFile.FEntries.Count - 1 do
                if Assigned(FJamFile.FEntries[i].FOriginalTex) then
                begin
                        tmpCanvas := StretchF(
                          FJamFile.FEntries[i].FOriginalTex,
                          FJamFile.FEntries[i].FInfo.Width,
                          FJamFile.FEntries[i].FInfo.Height);

                        if Assigned(FJamFile.FEntries[i].FTexture) then
                                FreeAndNil(FJamFile.FEntries[i].FTexture);

                        FJamFile.FEntries[i].FTexture :=
                          FJamFile.GenerateGPxBMP(tmpCanvas, i,
                          intSimplifyMethod, intSimplifyThreshold,
                          intBlurThreshold, boolSimpifyAllPals,
                          boolProtectTrans);
                        // tmpCanvas was freed by GenerateGPxBMP

                        FJamFile.CachePaletteBMP(i);
                end;

        RefreshPalette;
        RefreshCanvas;
        DrawTexture;
        TreeReDraw;
end;

procedure TFormMain.rcrOddClick(Sender: TObject);

begin
        boolRCRDrawMode := true;
        RefreshCanvas;
        DrawTexture;
end;

procedure TFormMain.rcrResetClick(Sender: TObject);
begin

        ImageEntry.Picture.Bitmap := FJamFile.FEntries
          [intSelectedTexture].FTexture;
        // ImageEntry.Picture.Bitmap := FJamFile.DrawRawData(FJamFile.FEntries[intSelectedTexture].FRawTexture,FJamFile.FEntries[intSelectedTexture].Info.width, FJamFile.FEntries[intSelectedTexture].Info.height)

end;

procedure TFormMain.rcrEvenClick(Sender: TObject);
begin
        boolRCRDrawMode := false;
        RefreshCanvas;
        DrawTexture;
end;

procedure TFormMain.btnGenPalClick(Sender: TObject);

begin
        generatePal := true;
        JamReGen;

        RefreshPalette;
        RefreshCanvas;
        DrawTexture;

        TreeReDraw;
end;

procedure TFormMain.btnRemoveAllPalsClick(Sender: TObject);
var
        i: integer;
begin

        for i := 0 to FJamFile.FEntries.Count - 1 do
                FJamFile.ZeroPalette(i);
        TreeReDraw;
end;

procedure TFormMain.btnRemovePalClick(Sender: TObject);
begin
        FJamFile.ZeroPalette(intSelectedTexture);
        TreeReDraw;
end;

procedure TFormMain.canvasHeightChange(Sender: TObject);
begin

        if UpdatingFromCode or userisTyping then
                Exit;

        boolCanvasChange := true;
        UpdatingFromCode := true;

        if boolUndo then
                PushUndoState;

        boolUndo := false;
        undoTimer.Enabled := false;
        undoTimer.Enabled := true;

        if boolHWJAM then
        begin
                FHWJamFile.ChangeJamCanvasHeight(canvasHeight.Value);
        end
        else
        begin
                FJamFile.ChangeJamCanvasHeight(canvasHeight.Value);
        end;

        timer_JamRedrawPals.Enabled := false;
        timer_redrawTree.Enabled := false;

        timer_redrawTree.Enabled := true;

        timer_JamRedrawPals.Enabled := true;

        RefreshCanvas;
        JamModified(true);
        UpdatingFromCode := false;

end;

procedure TFormMain.canvasPopupMenuPopup(Sender: TObject);
begin

        popUpDeleteTexture.Enabled := boolTexSelected;
        popupImportTexture.Enabled := boolTexSelected;
        popupExportTexture.Enabled := boolTexSelected;
        popupExportAllTextures.Enabled := boolJamLoaded;
        popUpAddTexture.Enabled := boolJamLoaded;
end;

function TFormMain.CheckJamModified(): Boolean;
var
        filename: string;
begin
        // Result = True  -> caller may proceed (saved, discarded, or no changes)
        // Result = False -> user pressed Cancel; caller should abort
        Result := True;

        if not boolJamLoaded then Exit;

        if boolHWJAM then
                filename := FHWJamFile.JamFullPath
        else
                filename := FJamFile.JamFullPath;

        if not boolJamModified then Exit;

        case MessageDlg('Do you want to save the file?',
          mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
                mrYes:
                        begin
                                // If we have no filename yet, run Save As...
                                if filename = '' then
                                begin
                                        dlgSaveJam.filename :=
                                          FJamFile.JamFileName + '.jam';

                                        if dlgSaveJam.Execute then
                                        begin
                                                if boolHWJAM then
                                                        FHWJamFile.SaveToFile
                                                          (dlgSaveJam.filename)
                                                else
                                                        FJamFile.SaveToFile
                                                          (dlgSaveJam.filename, false);
                                        end
                                        else
                                                // user cancelled the Save As dialog
                                                Result := False;
                                end
                                else
                                begin
                                        if boolHWJAM then
                                                FHWJamFile.SaveToFile(filename)
                                        else
                                                FJamFile.SaveToFile(filename, false);
                                end;
                        end;

                mrNo:
                        // discard changes and continue
                        ;

                mrCancel:
                        Result := False;
        end;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
        CanClose := CheckJamModified;
end;

procedure TFormMain.ShowHintInStatusBar(Sender: TObject);
begin
        StatusBar1.Panels[0].Text := GetLongHint(Application.Hint);
end;

procedure TFormMain.MsgHandler(var Msg: TMsg; var Handled: boolean);

var
        i, idx: integer;
        Entry: TjamEntry;
        EntryHW: THWjamEntry;
        Key: Word;
        movestep: integer;
        NewX, NewY: integer;
        Changed: boolean;
begin
        Changed := false;

        if (Msg.message = WM_KEYUP) then
        begin
                Key := Msg.wParam;
                Handled := false;

                if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
                begin
                        boolUndo := true;
                end;

                case Key of
                        17:
                                begin
                                        boolLCtrl := false;
                                        Handled := true;
                                end;
                end;

        end;

        if (Msg.message = WM_KEYDOWN) then
        begin
                Key := Msg.wParam;
                Handled := false; // default is: let the message go through

                if Key = 17 then // VK_CONTROL
                begin
                        boolLCtrl := true;
                        Handled := true;
                        Exit;
                end;

                if (SelectedTextureList.Count = 0) or (not boolLCtrl) then
                        Exit;

                for idx in SelectedTextureList do
                begin
                        if boolHWJAM then
                                EntryHW := FHWJamFile.Entries[idx]
                        else
                                Entry := FJamFile.Entries[idx];

                        if GetKeyState(VK_SHIFT) < 0 then
                                movestep := 10
                        else
                                movestep := 1;

                        UpdatingFromCode := false;
                        Changed := false;

                        case Key of
                                VK_LEFT:
                                        begin
                                        if boolUndo then
                                        PushUndoState;
                                        boolUndo := false;
                                        if boolHWJAM then
                                        begin
                                        NewX := Max(0,
                                        EntryHW.FInfo.X - movestep);
                                        if EntryHW.FInfo.X <> NewX then
                                        begin
                                        EntryHW.FInfo.X := NewX;
                                        Changed := true;
                                        end;
                                        end
                                        else
                                        begin
                                        NewX := Max(0,
                                        Entry.FInfo.X - movestep);
                                        if Entry.FInfo.X <> NewX then
                                        begin
                                        Entry.FInfo.X := NewX;
                                        Changed := true;
                                        end;
                                        end;
                                        end;

                                VK_RIGHT:
                                        begin
                                        if boolUndo then
                                        PushUndoState;
                                        boolUndo := false;
                                        if boolHWJAM then
                                        begin
                                        NewX := Min(255,
                                        EntryHW.FInfo.X + movestep);
                                        if EntryHW.FInfo.X <> NewX then
                                        begin
                                        EntryHW.FInfo.X := NewX;
                                        Changed := true;
                                        end;
                                        end
                                        else
                                        begin
                                        NewX := Min(255,
                                        Entry.FInfo.X + movestep);
                                        if Entry.FInfo.X <> NewX then
                                        begin
                                        Entry.FInfo.X := NewX;
                                        Changed := true;
                                        end;
                                        end;
                                        end;

                                VK_UP:
                                        begin
                                        if boolUndo then
                                        PushUndoState;
                                        boolUndo := false;
                                        if boolHWJAM then
                                        begin
                                        NewY := Max(0,
                                        EntryHW.FInfo.Y - movestep);
                                        if EntryHW.FInfo.Y <> NewY then
                                        begin
                                        EntryHW.FInfo.Y := NewY;
                                        Changed := true;
                                        end;

                                        end
                                        else
                                        begin
                                        NewY := Max(0,
                                        Entry.FInfo.Y - movestep);
                                        if Entry.FInfo.Y <> NewY then
                                        begin
                                        Entry.FInfo.Y := NewY;
                                        Changed := true;
                                        end;
                                        end;
                                        end;

                                VK_DOWN:
                                        begin
                                        if boolUndo then
                                        PushUndoState;
                                        boolUndo := false;
                                        if boolHWJAM then
                                        begin
                                        NewY := Min
                                        (FHWJamFile.FHeader.JamTotalHeight - 1,
                                        EntryHW.FInfo.Y + movestep);
                                        if EntryHW.FInfo.Y <> NewY then
                                        begin
                                        EntryHW.FInfo.Y := NewY;
                                        Changed := true;
                                        end;

                                        end
                                        else
                                        begin
                                        NewY := Min
                                        (FJamFile.FHeader.JamTotalHeight - 1,
                                        Entry.FInfo.Y + movestep);
                                        if Entry.FInfo.Y <> NewY then
                                        begin
                                        Entry.FInfo.Y := NewY;
                                        Changed := true;
                                        end;
                                        end;
                                        end;

                        else
                                Exit; // unknown key: allow default processing (Handled stays False)
                        end;

                        if Changed then
                        begin
                                if SelectedTextureList.Count = 1 then
                                        UpdateUIData(intSelectedTexture);

                                timer_redrawTree.Enabled := false;
                                timer_redrawTree.Enabled := true;
                                RefreshCanvas;
                                JamModified(true);

                                Handled := true; // We handled this movement key
                        end;
                end;
        end;

        // WM_DPICHANGED: DPI-aware apps receive this when Windows changes the
        // effective DPI (e.g. user adjusts the scaling slider at runtime).
        // WMFormMove (a proper WM_MOVE message-map handler on the form class)
        // already handles monitor-crossing detection, so this is belt-and-
        // suspenders for the scaling-change case only.
        if Msg.message = $02E0 {WM_DPICHANGED} then
        begin
                FCurrentMonitorHandle := Self.Monitor.Handle;
                RefreshDPIFactor(FCurrentMonitorHandle);
                Handled := False; // let VCL handle default repositioning too
        end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
        i: integer;
        Reg: TRegistry;

begin
        boolLCtrl := false;
        FOriginalSelectedIdx := -1;

        ClipboardJAM := RegisterClipboardFormat(CLIPBOARD_JAM);
        ClipboardHWJAM := RegisterClipboardFormat(CLIPBOARD_HWJAM);

        SWUndoStack := TStack<TJamFile>.Create;
        HWUndoStack := TStack<THWJamFile>.Create;

        SWRedoStack := TStack<TJamFile>.Create;
        HWRedoStack := TStack<THWJamFile>.Create;

        boolUndo := true;

        Application.OnHint := ShowHintInStatusBar;
        SelectedTextureList := TList<integer>.Create;

        SelectedTreeNodes := TList<TTreeNode>.Create;

        Application.OnMessage := self.MsgHandler;

        // Recompute the canvas (and its off-canvas margin) whenever the
        // scrollbox area changes — the margin sizing depends on the
        // visible client width/height.
        ScrollBox1.OnResize := ScrollBox1Resize;

        FJamFile.SetGpxPal(false);

        for i := 0 to 255 do
                localGpxPal[i] := GPXPal[i];

        intPaletteID := 0;

        intJamZoom := 1;

        // Initialise high-resolution drag throttle.  Default to 100 Hz until
        // RefreshDPIFactor queries the actual monitor refresh rate below.
        QueryPerformanceFrequency(FQPFFreq);
        FLastDragQPC := 0;
        if FQPFFreq > 0 then
                FDragFrameInterval := FQPFFreq div 100  // 100 Hz fallback
        else
                FDragFrameInterval := 0; // QPF unavailable — never throttle

        // Compute the monitor's physical (hardware) DPI factor for the
        // DPI-scale toggle.  RefreshDPIFactor does the full detection
        // (GetDpiForMonitor MDT_RAW_DPI, fallback to Screen.PixelsPerInch).
        // We prime dblDPIFactor to 1.0 first so RefreshDPIFactor's "changed"
        // guard fires and sets the initial hint text.
        dblDPIFactor := 1.0;
        boolDPIScaling := False;  // loaded from registry below
        FCurrentMonitorHandle := Screen.PrimaryMonitor.Handle;
        RefreshDPIFactor(FCurrentMonitorHandle);

        intSimplifyThreshold := 20;
        intSimplifyMethod := 3;
        intBlurThreshold := 1;
        // intSimplifyDist := 20;
        boolSimpifyAllPals := false;
        boolProtectTrans := false;

        boolFlagChange := false;
        boolXChange := false;
        boolYChange := false;
        boolWidthChange := false;
        boolHeightChange := false;
        boolIDChange := false;


        JamModified(false);

        boolCanvasChange := false;

        boolJamIssues := false;

        generatePal := false;

        boolJamLoaded := false;

        boolHWJAM := false;

        UpdatingFromCode := false;

        timer_redrawTree.Enabled := false;

        comboSimpMethod.ItemIndex := intSimplifyMethod;

        numBox_SimpThresh.Value := Round(intSimplifyThreshold);
        numBox_BlurAmount.Value := intBlurThreshold;
        chkBoxSimpPal.Checked := boolSimpifyAllPals;
        chkBoxTrans.Checked := boolProtectTrans;

        Reg := TRegistry.Create(KEY_READ);

        try
                Reg.RootKey := HKEY_CURRENT_USER;
                if Reg.OpenKey(baseKeyPath, true) then
                begin
                        strOpenPath := Reg.ReadString('OpenPath');
                        strSavePath := Reg.ReadString('SavePath');
                        strImportPath := Reg.ReadString('ImportPath');
                        strExportPath := Reg.ReadString('ExportPath');
                        strBrowserPath := Reg.ReadString('BrowserPath');
                        strGP2Location := Reg.ReadString('GP2Location');
                        strGP3Location := Reg.ReadString('GP3Location');
                        strGP32kLocation := Reg.ReadString('GP32kLocation');
                        boolAutoLayout := Reg.ReadBool('AutoLayout');
                        boolDrawOutlines := Reg.ReadBool('DrawOutlines');
                        if Reg.ValueExists('ShowAdvancedFlags') then
                                boolShowAdvancedFlags := Reg.ReadBool('ShowAdvancedFlags');
                        if Reg.ValueExists('DPIScaling') then
                                boolDPIScaling := Reg.ReadBool('DPIScaling');

                        Reg.CloseKey;
                end;
        finally
                Reg.Free;
        end;

        // Sync DPI Scale menu item to persisted value
        menuDPIScale.Checked := boolDPIScaling;

        // Apply persisted advanced-flags preference. Suppress the OnClick
        // handler while we sync the checkbox to avoid a double rebuild.
        if boolShowAdvancedFlags then
        begin
                UpdatingFromCode := True;
                try
                        chkShowAdvancedFlags.Checked := True;
                finally
                        UpdatingFromCode := False;
                end;
                RebuildFlagsList;
        end;

        intMaxMRU := 10;
        MRUList := TStringList.Create;

        LoadMRU;
        UpdateMRU;

        with ImageEntry.Picture.Bitmap do
        begin
                Width := 1;
                height := 1;
                Canvas.Brush.Color := panel_TexPreview.Color;
                // or any background color
                Canvas.FillRect(Rect(0, 0, Width, height));
        end;

        PaintBoxPalette.Canvas.Brush.Color := panel_PalPreview.Color;
        // or clBtnFace
        PaintBoxPalette.Canvas.FillRect(PaintBoxPalette.ClientRect);

end;

procedure TFormMain.PreviewMask1Click(Sender: TObject);
begin
        genMask;
end;

procedure TFormMain.PushUndoState();
begin
        if boolHWJAM then
        begin
                HWUndoStack.Push(FHWJamFile.Clone);

                while HWRedoStack.Count > 0 do
                        HWRedoStack.pop.Free;

                Undo1.Enabled := HWUndoStack.Count > 0;
                Redo1.Enabled := HWRedoStack.Count > 0;

        end
        else
        begin
                SWUndoStack.Push(FJamFile.Clone);

                while SWRedoStack.Count > 0 do
                        SWRedoStack.pop.Free;

                Undo1.Enabled := SWUndoStack.Count > 0;
                Redo1.Enabled := SWRedoStack.Count > 0;

        end;

end;

procedure TFormMain.DoUndo();
begin

        if boolHWJAM then
        begin
                if HWUndoStack.Count = 0 then
                begin
                        Undo1.Enabled := false;
                        Exit;
                end;

                if HWUndoStack.Count = intMaxUndo then
                        HWUndoStack.pop;

                HWRedoStack.Push(FHWJamFile.Clone);

                if HWRedoStack.Count = 0 then
                        Redo1.Enabled := false
                else
                        Redo1.Enabled := true;

                // Free current file
                FHWJamFile.Free;

                // Restore previous
                FHWJamFile := HWUndoStack.pop;

        end
        else
        begin

                if SWUndoStack.Count = 0 then
                begin
                        Undo1.Enabled := false;
                        Exit;
                end;

                SWRedoStack.Push(FJamFile.Clone);

                if SWRedoStack.Count = 0 then
                        Redo1.Enabled := false
                else
                        Redo1.Enabled := true;

                // Free current file
                FJamFile.Free;

                // Restore previous
                FJamFile := SWUndoStack.pop;

        end;

        RefreshCanvas;
        TreeReDraw;
        JamModified(true);

end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
        Reg: TRegistry;
begin
        Reg := TRegistry.Create(KEY_WRITE);

        try
                Reg.RootKey := HKEY_CURRENT_USER;
                if Reg.OpenKey(baseKeyPath, true) then
                begin
                        Reg.WriteString('OpenPath', strOpenPath);
                        Reg.WriteString('SavePath', strSavePath);
                        Reg.WriteString('ImportPath', strImportPath);
                        Reg.WriteString('ExportPath', strExportPath);
                        Reg.WriteString('BrowserPath', strBrowserPath);
                        Reg.WriteString('GP2Location', strGP2Location);
                        Reg.WriteString('GP3Location', strGP3Location);
                        Reg.WriteString('GP32kLocation', strGP32kLocation);
                        Reg.WriteBool('AutoLayout', boolAutoLayout);
                        Reg.WriteBool('DrawOutlines', boolDrawOutlines);
                        Reg.WriteBool('ShowAdvancedFlags', boolShowAdvancedFlags);
                        Reg.WriteBool('DPIScaling', boolDPIScaling);
                        Reg.CloseKey;
                end;
        finally
                Reg.Free;
        end;
        MRUList.Free;
        SelectedTextureList.Free;

        while SWUndoStack.Count > 0 do
                SWUndoStack.pop.Free;

        while HWUndoStack.Count > 0 do
                HWUndoStack.pop.Free;

        while SWRedoStack.Count > 0 do
                SWRedoStack.pop.Free;

        while HWRedoStack.Count > 0 do
                HWRedoStack.pop.Free;

        SWUndoStack.Free;
        HWUndoStack.Free;

        SWRedoStack.Free;
        HWRedoStack.Free;

        if FCheckerBrush <> 0 then
        begin
                DeleteObject(FCheckerBrush);
                FCheckerBrush := 0;
        end;
        FreeAndNil(FCheckerPattern);
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
        i: integer;
begin
        // Enter commits the current move/scale state and deactivates the
        // tool. Escape CANCELS the current move/scale — it restores the
        // selected texture to its state at the moment it was first
        // selected in move mode, then deactivates the tool (Photoshop-
        // style cancel-transform). Don't steal Enter/Escape when user is
        // typing in a spin-edit.
        if FMoveToolActive then
        begin
                if Key = VK_ESCAPE then
                begin
                        RestoreOriginalSelectedState;
                        DeactivateMoveTool;
                        Key := 0;
                        Exit;
                end;
                if Key = VK_RETURN then
                begin
                        if (Screen.ActiveControl = nil) or
                          (not (Screen.ActiveControl is TCustomEdit)) then
                        begin
                                DeactivateMoveTool;
                                Key := 0;
                                Exit;
                        end;
                end;
        end;

        // Space arms pan mode — mouse drag will scroll the canvas view.
        // We consume the key at the form level to stop Windows from
        // interpreting it as a system command (which pops up the window
        // restore/move/size menu when no control owns focus).
        if Key = VK_SPACE then
        begin
                // If the user is typing in an edit control, let the edit
                // handle the space (don't arm pan, don't consume).
                if (Screen.ActiveControl <> nil) and
                  (Screen.ActiveControl is TCustomEdit) then
                        Exit;
                if userisTyping then
                        Exit;

                // Arm pan mode (only the first KeyDown — auto-repeat is fine)
                if (not FSpacePanArmed) and (not FDrag.Active) then
                begin
                        FSpacePanArmed := True;
                        ImageCanvas.Cursor := crSizeAll;
                end;
                Key := 0;  // always consume so Windows doesn't act on it
                Exit;
        end;
end;

procedure TFormMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        if Key = VK_SPACE then
        begin
                if (Screen.ActiveControl <> nil) and
                  (Screen.ActiveControl is TCustomEdit) then
                        Exit;

                FSpacePanArmed := False;
                FPanActive := False;
                ImageCanvas.Cursor := crDefault;
                Key := 0;  // consume on key up too
        end;
end;

procedure TFormMain.ApplySnap(Mode: TResizeMode;
  var newX, newY, newW, newH: integer);
// Snap the moving texture's active edges to nearby texture/canvas edges.
// Threshold is measured in screen pixels (so feels consistent at any zoom),
// converted to canvas pixels via intJamZoom. Sets FSnapXActive/FSnapYActive
// so the drag preview can show a guide line.
const
        SNAP_SCREEN_PX = 6; // Photoshop-style: constant screen tolerance
var
        snapPx: integer;
        i: integer;
        canvasW, canvasH: integer;
        xCands, yCands: array of integer;
        xCount, yCount: integer;
        activeLeft, activeRight, activeTop, activeBottom: Boolean;

        procedure AddX(v: integer);
        var k: integer;
        begin
                for k := 0 to xCount - 1 do
                        if xCands[k] = v then Exit;
                if xCount >= Length(xCands) then
                        SetLength(xCands, xCount + 16);
                xCands[xCount] := v;
                Inc(xCount);
        end;

        procedure AddY(v: integer);
        var k: integer;
        begin
                for k := 0 to yCount - 1 do
                        if yCands[k] = v then Exit;
                if yCount >= Length(yCands) then
                        SetLength(yCands, yCount + 16);
                yCands[yCount] := v;
                Inc(yCount);
        end;

var
        bestDX, bestDY: integer;
        bestScoreX, bestScoreY: integer;
        bestEdgeX, bestEdgeY: ShortString; // 'L','R' or 'T','B'
        bestTargetX, bestTargetY: integer;
        d, k: integer;
begin
        FSnapXActive := False;
        FSnapYActive := False;

        if not boolSnapEnabled then Exit;
        if intSelectedTexture < 0 then Exit;

        // Convert screen-pixel tolerance to canvas pixels
        if EffectiveJamZoom <= 0 then
                snapPx := SNAP_SCREEN_PX
        else
                snapPx := Max(1, Min(12, Round(SNAP_SCREEN_PX / EffectiveJamZoom)));

        // Resolve active edges for this drag mode
        activeLeft   := Mode in [rmMove, rmLeft,  rmTopLeft,  rmBottomLeft];
        activeRight  := Mode in [rmMove, rmRight, rmTopRight, rmBottomRight];
        activeTop    := Mode in [rmMove, rmTop,   rmTopLeft,  rmTopRight];
        activeBottom := Mode in [rmMove, rmBottom,rmBottomLeft,rmBottomRight];

        // Get canvas dimensions
        if boolHWJAM then
        begin
                canvasW := FHWJamFile.canvasWidth;
                canvasH := FHWJamFile.canvasHeight;
        end
        else
        begin
                canvasW := FJamFile.canvasWidth;
                canvasH := FJamFile.canvasHeight;
        end;

        // Collect candidate edge positions
        xCount := 0;
        yCount := 0;
        AddX(0);
        AddX(canvasW);
        AddY(0);
        AddY(canvasH);

        if boolHWJAM then
        begin
                for i := 0 to FHWJamFile.Entries.Count - 1 do
                        if i <> intSelectedTexture then
                                with FHWJamFile.FEntries[i].FInfo do
                                begin
                                        AddX(X);
                                        AddX(X + Width);
                                        AddY(Y);
                                        AddY(Y + Height);
                                end;
        end
        else
        begin
                for i := 0 to FJamFile.Entries.Count - 1 do
                        if i <> intSelectedTexture then
                                with FJamFile.FEntries[i].FInfo do
                                begin
                                        AddX(X);
                                        AddX(X + Width);
                                        AddY(Y);
                                        AddY(Y + Height);
                                end;
        end;

        // Find best X-axis snap
        bestScoreX := snapPx + 1;
        bestDX := 0;
        bestEdgeX := '';
        bestTargetX := 0;
        if activeLeft then
                for k := 0 to xCount - 1 do
                begin
                        d := xCands[k] - newX;
                        if Abs(d) < bestScoreX then
                        begin
                                bestScoreX := Abs(d);
                                bestDX := d;
                                bestEdgeX := 'L';
                                bestTargetX := xCands[k];
                        end;
                end;
        if activeRight then
                for k := 0 to xCount - 1 do
                begin
                        d := xCands[k] - (newX + newW);
                        if Abs(d) < bestScoreX then
                        begin
                                bestScoreX := Abs(d);
                                bestDX := d;
                                bestEdgeX := 'R';
                                bestTargetX := xCands[k];
                        end;
                end;

        if bestEdgeX <> '' then
        begin
                if Mode = rmMove then
                        newX := newX + bestDX
                else if bestEdgeX = 'L' then
                begin
                        newX := newX + bestDX;
                        newW := newW - bestDX;
                end
                else // 'R'
                        newW := newW + bestDX;

                FSnapXActive := True;
                FSnapXLine := bestTargetX;
        end;

        // Find best Y-axis snap
        bestScoreY := snapPx + 1;
        bestDY := 0;
        bestEdgeY := '';
        bestTargetY := 0;
        if activeTop then
                for k := 0 to yCount - 1 do
                begin
                        d := yCands[k] - newY;
                        if Abs(d) < bestScoreY then
                        begin
                                bestScoreY := Abs(d);
                                bestDY := d;
                                bestEdgeY := 'T';
                                bestTargetY := yCands[k];
                        end;
                end;
        if activeBottom then
                for k := 0 to yCount - 1 do
                begin
                        d := yCands[k] - (newY + newH);
                        if Abs(d) < bestScoreY then
                        begin
                                bestScoreY := Abs(d);
                                bestDY := d;
                                bestEdgeY := 'B';
                                bestTargetY := yCands[k];
                        end;
                end;

        if bestEdgeY <> '' then
        begin
                if Mode = rmMove then
                        newY := newY + bestDY
                else if bestEdgeY = 'T' then
                begin
                        newY := newY + bestDY;
                        newH := newH - bestDY;
                end
                else // 'B'
                        newH := newH + bestDY;

                FSnapYActive := True;
                FSnapYLine := bestTargetY;
        end;

        // Enforce minimum size after snap
        if newW < 1 then newW := 1;
        if newH < 1 then newH := 1;
end;

procedure TFormMain.ToggleSnap;
begin
        boolSnapEnabled := not boolSnapEnabled;
        toolbarSnap.Down := boolSnapEnabled;
        menuSnap.Checked := boolSnapEnabled;
end;

procedure TFormMain.ToggleCheckerboard;
begin
        boolShowCheckerboard := not boolShowCheckerboard;
        toolbarCheckerboard.Down := boolShowCheckerboard;
        menuCheckerboard.Checked := boolShowCheckerboard;
        if boolJamLoaded then
                RefreshCanvas;
end;

procedure TFormMain.WMFormMove(var Msg: TMessage);
// Handles WM_MOVE at the window-procedure level (not Application.OnMessage)
// so it fires whenever the form is repositioned — including drags, keyboard
// moves, Snap-to-Edge, and programmatic SetWindowPos calls — on all Windows
// versions and regardless of whether a DPI-awareness manifest is present.
//
// We compare Self.Monitor.Handle against the cached FCurrentMonitorHandle.
// The comparison is O(1) and safe to do on every WM_MOVE.  We only call the
// (slightly more expensive) RefreshDPIFactor when the window has actually
// crossed a screen boundary, so there is no performance penalty during
// ordinary within-monitor window drags.
var
        newMon: HMONITOR;
begin
        inherited;  // let VCL do its normal WM_MOVE work first

        // FCurrentMonitorHandle is a class field, so it is zero before
        // FormCreate runs.  WM_MOVE fires during window construction (before
        // FormCreate), at which point menuDPIScale and other components do not
        // exist yet.  Guard here so we never enter RefreshDPIFactor early.
        if FCurrentMonitorHandle = 0 then
                Exit;

        newMon := Self.Monitor.Handle;
        if newMon <> FCurrentMonitorHandle then
        begin
                FCurrentMonitorHandle := newMon;
                RefreshDPIFactor(FCurrentMonitorHandle);
        end;
end;

procedure TFormMain.RefreshDPIFactor(hMon: HMONITOR);
// Re-queries the physical hardware DPI of the given monitor and also
// updates the drag-frame-rate throttle to the monitor's actual refresh rate.
// Uses GetDpiForMonitor(MDT_RAW_DPI) via late-binding to shcore.dll so it
// works regardless of the app's DPI-awareness declaration and regardless of
// the Windows display-scaling setting.  A 4K 27" panel reports ~163 raw DPI
// (factor ≈ 1.70) whether the user has Windows scaling at 100% or 200%.
// Falls back to Screen.PixelsPerInch when shcore is unavailable.
var
        hShcore: HMODULE;
        pfnGetDpi: function(hM: HMONITOR; dpiType: UINT;
          var dpiX, dpiY: UINT): HRESULT; stdcall;
        rawDpiX, rawDpiY: UINT;
        newFactor: Double;
        hz: Integer;
begin
        newFactor := 1.0;
        hShcore := LoadLibrary('shcore.dll');
        if hShcore <> 0 then
        try
                @pfnGetDpi := GetProcAddress(hShcore, 'GetDpiForMonitor');
                if Assigned(pfnGetDpi) then
                begin
                        rawDpiX := 96;
                        rawDpiY := 96;
                        // MDT_RAW_DPI = 2
                        if pfnGetDpi(hMon, 2, rawDpiX, rawDpiY) = S_OK then
                                newFactor := rawDpiX / 96.0;
                end;
        finally
                FreeLibrary(hShcore);
        end;

        // Fallback: effective (logical) DPI from Windows — reflects scaling %
        if newFactor <= 1.001 then
                newFactor := Screen.PixelsPerInch / 96.0;

        // Never scale below 1× regardless of quirky monitor reports
        if newFactor < 1.0 then
                newFactor := 1.0;

        // ── Refresh rate ────────────────────────────────────────────────────
        // GetDeviceCaps(VREFRESH) on the window's own DC returns the refresh
        // rate of whichever monitor the window is currently on — no need for
        // MONITORINFOEX or EnumDisplaySettings (and their type-matching
        // headaches across Delphi versions).
        hz := 0;
        if Handle <> 0 then
        begin
                var hWinDC: HDC := GetDC(Handle);
                if hWinDC <> 0 then
                try
                        hz := GetDeviceCaps(hWinDC, VREFRESH);
                finally
                        ReleaseDC(Handle, hWinDC);
                end;
        end;
        if (hz < 30) or (hz > 500) then
                hz := 60;  // sane fallback
        if FQPFFreq > 0 then
                FDragFrameInterval := FQPFFreq div hz;

        // ── DPI factor ──────────────────────────────────────────────────────
        // Only redraw when the factor actually changed and scaling is active
        if Abs(newFactor - dblDPIFactor) > 0.01 then
        begin
                dblDPIFactor := newFactor;
                menuDPIScale.Hint :=
                  Format('Scale canvas for high-DPI display  ' +
                         '(monitor: %d Hz, DPI factor: ×%.2g)',
                  [hz, dblDPIFactor]);
                if boolDPIScaling and boolJamLoaded then
                        RefreshCanvas;
        end
        else
        begin
                dblDPIFactor := newFactor;
                menuDPIScale.Hint :=
                  Format('Scale canvas for high-DPI display  ' +
                         '(monitor: %d Hz, DPI factor: ×%.2g)',
                  [hz, dblDPIFactor]);
        end;
end;

procedure TFormMain.ToggleDPIScaling;
begin
        boolDPIScaling := not boolDPIScaling;
        menuDPIScale.Checked := boolDPIScaling;
        if boolJamLoaded then
                RefreshCanvas;
end;

function TFormMain.CheckerBrush: HBRUSH;
// Lazily builds a 16x16 checkerboard pattern brush. Reused for every
// ComposeCheckerboard call so painting the background becomes a single
// FillRect instead of tens of thousands of per-square FillRects at high
// zoom.
const
        SQ = 8;
        PATSIZE = SQ * 2;
var
        light, dark: TColor;
begin
        if FCheckerBrush <> 0 then
                Exit(FCheckerBrush);

        light := RGB(210, 210, 215);
        dark  := RGB(170, 170, 180);

        FCheckerPattern := TBitmap.Create;
        FCheckerPattern.PixelFormat := pf24bit;
        FCheckerPattern.SetSize(PATSIZE, PATSIZE);
        FCheckerPattern.Canvas.Brush.Color := light;
        FCheckerPattern.Canvas.FillRect(Rect(0,   0,   SQ,      SQ));
        FCheckerPattern.Canvas.FillRect(Rect(SQ,  SQ,  PATSIZE, PATSIZE));
        FCheckerPattern.Canvas.Brush.Color := dark;
        FCheckerPattern.Canvas.FillRect(Rect(SQ,  0,   PATSIZE, SQ));
        FCheckerPattern.Canvas.FillRect(Rect(0,   SQ,  SQ,      PATSIZE));

        FCheckerBrush := CreatePatternBrush(FCheckerPattern.Handle);
        Result := FCheckerBrush;
end;

procedure TFormMain.ComposeCheckerboard(var bmp: TBitmap; keyColor: TColor);
// View-layer only: composites the JAM render (bmp) onto a checkerboard
// background, treating keyColor as transparent. Caller supplies the
// color key explicitly so this routine works for both SW (palette[0])
// and HW (TCol_TransGP3HW) JAMs. The source is flattened to pf24bit
// because TransparentBlt's behavior on pf32bit sources with an alpha
// channel is unreliable (alpha can suppress color-key matching).
// Does not touch the JAM model; swaps bmp for a new display bitmap.
var
        composed, flat: TBitmap;
        fullRect: TRect;
begin
        if (bmp = nil) or (bmp.Width <= 0) or (bmp.Height <= 0) then Exit;

        flat     := nil;
        composed := nil;
        try
                // Flatten only when source has alpha (HW JAM, pf32bit).
                // TransparentBlt's color-key match is unreliable on sources
                // with an alpha channel. Skip the copy for pf24bit sources.
                if bmp.PixelFormat = pf32bit then
                begin
                        flat := TBitmap.Create;
                        flat.PixelFormat := pf24bit;
                        flat.SetSize(bmp.Width, bmp.Height);
                        flat.Canvas.Draw(0, 0, bmp);
                end;

                composed := TBitmap.Create;
                composed.PixelFormat := pf24bit;
                composed.SetSize(bmp.Width, bmp.Height);

                // Paint checkerboard with a tiled pattern brush: one GDI
                // call regardless of zoom. The prior per-square FillRect
                // loop fired 10k+ times at high zoom and stalled the UI.
                fullRect := Rect(0, 0, composed.Width, composed.Height);
                Winapi.Windows.FillRect(composed.Canvas.Handle, fullRect,
                  CheckerBrush);

                // transparent blit (use flattened source if we had to flatten)
                if flat <> nil then
                        TransparentBlt(composed.Canvas.Handle, 0, 0,
                          flat.Width, flat.Height,
                          flat.Canvas.Handle, 0, 0, flat.Width, flat.Height,
                          keyColor)
                else
                        TransparentBlt(composed.Canvas.Handle, 0, 0,
                          bmp.Width, bmp.Height,
                          bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
                          keyColor);

                // swap: free the incoming JAM bmp, return the composed view bmp
                FreeAndNil(bmp);
                bmp := composed;
                composed := nil;
        finally
                composed.Free;
                flat.Free;
        end;
end;

procedure TFormMain.ApplyOutlineOverlay(bmp: TBitmap);
// View-layer overlay: paints texture-ID outlines on the supplied display
// bitmap. Iterates the model's entries (read-only) but does not mutate
// them. RCR half-height layout is handled here because outlines are a
// display concern, not a model concern.
var
        i: Integer;
        tempX, tempY: Integer;
        canvasW, canvasH: Integer;
        isOff: Boolean;
begin
        if not boolDrawOutlines then Exit;
        if bmp = nil then Exit;

        if boolHWJAM then
        begin
                if FHWJamFile = nil then Exit;
                canvasW := FHWJamFile.canvasWidth;
                canvasH := FHWJamFile.canvasHeight;
                for i := 0 to FHWJamFile.Entries.Count - 1 do
                        with FHWJamFile.Entries[i].Info do
                        begin
                                isOff := (X < 0) or (Y < 0) or
                                  (X + Width  > canvasW) or
                                  (Y + Height > canvasH);
                                DrawTextureOutlines(bmp, X, Y, Width, Height,
                                  i, JamId, isOff);
                        end;
                Exit;
        end;

        if FJamFile = nil then Exit;
        canvasW := FJamFile.canvasWidth;
        canvasH := FJamFile.canvasHeight;
        for i := 0 to FJamFile.Entries.Count - 1 do
        begin
                // Drag-preview: skip outline for the moving entry
                if i = intDragSkipEntry then Continue;
                with FJamFile.Entries[i].Info do
                begin
                        // Off-canvas detection in JAM coords (the same space
                        // canvasWidth/canvasHeight are stored in). RCR's
                        // displayed-X gymnastics (+256 for odd Y, Width*2)
                        // are a render trick — the underlying JAM bounds
                        // are still 0..canvasW / 0..canvasH.
                        isOff := (X < 0) or (Y < 0) or
                          (X + Width  > canvasW) or
                          (Y + Height > canvasH);
                        tempX := X;
                        tempY := Y;
                        if boolRcrJam then
                        begin
                                if Y mod 2 <> 0 then
                                begin
                                        tempY := tempY - 1;
                                        tempX := tempX + 256;
                                end;
                                tempY := tempY div 2;
                                DrawTextureOutlines(bmp, tempX, tempY,
                                  Width * 2, Height, i, JamId, isOff);
                        end
                        else
                                DrawTextureOutlines(bmp, X, Y,
                                  Width, Height, i, JamId, isOff);
                end;
        end;
end;

procedure TFormMain.CaptureOriginalSelectedState;
// Records the currently selected texture's position+size. Escape will
// restore to this. Called when a texture enters move-mode "editing"
// (either by selecting it while tool is on, or by activating the tool
// while it's selected).
begin
        if (intSelectedTexture < 0) or boolRcrJam then
        begin
                FOriginalSelectedIdx := -1;
                Exit;
        end;
        if boolHWJAM then
                with FHWJamFile.FEntries[intSelectedTexture].FInfo do
                begin
                        FOriginalSelectedX := X;
                        FOriginalSelectedY := Y;
                        FOriginalSelectedW := Width;
                        FOriginalSelectedH := Height;
                end
        else
                with FJamFile.FEntries[intSelectedTexture].FInfo do
                begin
                        FOriginalSelectedX := X;
                        FOriginalSelectedY := Y;
                        FOriginalSelectedW := Width;
                        FOriginalSelectedH := Height;
                end;
        FOriginalSelectedIdx := intSelectedTexture;
end;

procedure TFormMain.RestoreOriginalSelectedState;
// Escape cancels the current move/scale: revert to the state captured
// at the time the texture first entered move-mode editing.
begin
        if FOriginalSelectedIdx < 0 then Exit;
        if FOriginalSelectedIdx <> intSelectedTexture then Exit;

        // Stop any active drag so ApplyTextureTransform doesn't try to
        // snap or capture anything weird.
        FDrag.Active := False;
        FDrag.Mode := rmNone;
        ReleaseDragBackground;

        ApplyTextureTransform(FOriginalSelectedX, FOriginalSelectedY,
          FOriginalSelectedW, FOriginalSelectedH);
end;

procedure TFormMain.StartZoomTo(NewZoom: Double);
// Schedules a smooth animation from intJamZoom to NewZoom. Successive calls
// just update the target — animation re-aims mid-flight for fluid feel.
const
        MIN_ZOOM = 0.25; // 4× zoomed out
        MAX_ZOOM = 8.0;  // 8× zoomed in — more than enough for pixel-level work
begin
        if NewZoom < MIN_ZOOM then NewZoom := MIN_ZOOM;
        if NewZoom > MAX_ZOOM then NewZoom := MAX_ZOOM;

        FTargetZoom := NewZoom;

        // Skip animation while a drag is active (snap instantly to avoid
        // interfering with the live drag preview), or if timer isn't wired.
        if FDrag.Active or (timerZoom = nil) then
        begin
                intJamZoom := FTargetZoom;
                if booljamLoaded then RefreshCanvas;
                ApplyZoomAnchorScroll;
                Exit;
        end;

        timerZoom.Enabled := True;
end;

procedure TFormMain.ApplyZoomAnchorScroll;
// Called after every RefreshCanvas during a zoom animation (and on instant-
// zoom paths). Scrolls the ScrollBox so that the canvas point recorded in
// FZoomAnchorRelX/Y stays at screen position FZoomAnchorScreenX/Y.
//
// Derivation: screen_x_of_canvas_point = ImageCanvas.Left + RelX * EffZoom
//             We want that = FZoomAnchorScreenX, and ImageCanvas.Left = -ScrollPos
//             → ScrollPos = RelX * EffZoom − AnchorScreenX
begin
        if not FZoomHasAnchor then Exit;
        ScrollBox1.HorzScrollBar.Position :=
                Max(0, Round(FZoomAnchorRelX * EffectiveJamZoom) - FZoomAnchorScreenX);
        ScrollBox1.VertScrollBar.Position :=
                Max(0, Round(FZoomAnchorRelY * EffectiveJamZoom) - FZoomAnchorScreenY);
end;

procedure TFormMain.SetZoomAnchorToCenter;
// Anchors zoom to the current centre of the visible ScrollBox client area.
// Used by toolbar +/- zoom buttons so they zoom toward/away from the centre.
var
        cx, cy: Integer;
begin
        cx := ScrollBox1.ClientWidth  div 2;
        cy := ScrollBox1.ClientHeight div 2;
        // Guard against degenerate state before the canvas is loaded
        if EffectiveJamZoom <= 0 then Exit;
        FZoomAnchorRelX    := (cx - ImageCanvas.Left) / EffectiveJamZoom;
        FZoomAnchorRelY    := (cy - ImageCanvas.Top)  / EffectiveJamZoom;
        FZoomAnchorScreenX := cx;
        FZoomAnchorScreenY := cy;
        FZoomHasAnchor     := True;
end;

procedure TFormMain.timerZoomTimer(Sender: TObject);
const
        EASE = 0.30; // fraction of remaining distance per tick (~60fps)
        SNAP = 0.01; // close enough — snap to target
var
        delta: Double;
begin
        delta := FTargetZoom - intJamZoom;
        if Abs(delta) <= SNAP then
        begin
                intJamZoom := FTargetZoom;
                timerZoom.Enabled := False;
        end
        else
                intJamZoom := intJamZoom + delta * EASE;

        if booljamLoaded then
                RefreshCanvas;

        // Pin the canvas anchor point to its recorded screen position on
        // every frame so the view tracks the zoom origin smoothly.
        ApplyZoomAnchorScroll;
end;

procedure TFormMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
const
        ZOOM_FACTOR = 1.15; // multiplicative step — feels natural
var
        OldZoom, NewTarget: Double;
        CursorPos: TPoint;
        ImgPos: TPoint;
        RelX, RelY: Double;
begin
        // Only zoom when ALT is held; otherwise pass the wheel through to
        // the ScrollBox for normal scrolling.
        if not (ssAlt in Shift) then
        begin
                Handled := False;
                Exit;
        end;

        if boolJamLoaded = false then
                Exit;

        CursorPos := ScrollBox1.ScreenToClient(MousePos);
        if not PtInRect(ScrollBox1.ClientRect, CursorPos) then
                Exit;

        // Use the effective zoom (includes DPI factor) so the canvas coordinate
        // is in true texture pixels regardless of DPI-scale mode.
        OldZoom := EffectiveJamZoom;

        // Successive wheel notches keep building on the target rather than
        // current intJamZoom (which may still be mid-animation)
        if timerZoom.Enabled then
                NewTarget := FTargetZoom
        else
                NewTarget := intJamZoom;

        if WheelDelta > 0 then
                NewTarget := NewTarget * ZOOM_FACTOR
        else
                NewTarget := NewTarget / ZOOM_FACTOR;

        // Record canvas point under cursor and its screen position.
        // ApplyZoomAnchorScroll will pin this point on every animation tick
        // so the view stays anchored rather than jumping at animation end.
        ImgPos := Point(ImageCanvas.Left, ImageCanvas.Top);
        RelX := (CursorPos.X - ImgPos.X) / OldZoom;
        RelY := (CursorPos.Y - ImgPos.Y) / OldZoom;

        FZoomAnchorRelX    := RelX;
        FZoomAnchorRelY    := RelY;
        FZoomAnchorScreenX := CursorPos.X;
        FZoomAnchorScreenY := CursorPos.Y;
        FZoomHasAnchor     := True;

        StartZoomTo(NewTarget);

        Handled := true;
end;

//
// procedure TFormMain.ImageCanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// var
// I, localX, localY: Integer;
// EntryRef: TJamEntryRef;
// intCount : integer;
// begin
// if Button <> mbLeft then Exit;
// if not boolJamLoaded then Exit;
//
// localX := Round(X / intJamZoom);
// localY := Round(Y / intJamZoom);
// intSelectedTexture := -1;
//
//
//
// for I := 0 to intCount do
// begin
//
// if boolHWJAM then
// EntryRef := TJamEntryRef.FromHW(FHWJamFile.Entries[i].Info)
// else
// EntryRef := TJamEntryRef.FromSW(FJamFile.Entries[i].Info);
//
// if PtInRect(Rect(EntryRef.X, EntryRef.Y, EntryRef.X + EntryRef.Width, EntryRef.Y + EntryRef.Height), Point(localX, localY)) then
// begin
// intSelectedTexture := I;
// CurrentResizeMode := HitTestResizeZone(localX, localY, EntryRef.X, EntryRef.Y, EntryRef.Width, EntryRef.Height);
// LastMousePos := Point(localX, localY);
// Break;
// end;
// end;
//
//
// if intSelectedTexture = -1 then
// DeSelectTexture
// else
// SelectTexture(intSelectedTexture);
//
// end;

procedure TFormMain.ImageCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
        i, jamX, jamY, jamW, jamH, tempX, tempY: integer;
        selRect: TRect;
        hitMode: TResizeMode;
        canvasPt: TPoint;
        screenPt: TPoint;
begin

        if not boolJamLoaded then
                Exit;

        // ----- Space-bar panning: hold space + drag to scroll the canvas -----
        if FSpacePanArmed and (Button = mbLeft) then
        begin
                FPanActive := True;
                // Record screen-space start so we can compute deltas across
                // scroll-box positions reliably
                screenPt := ImageCanvas.ClientToScreen(Point(X, Y));
                FPanStartMouse := screenPt;
                FPanStartScrollX := ScrollBox1.HorzScrollBar.Position;
                FPanStartScrollY := ScrollBox1.VertScrollBar.Position;
                ImageCanvas.Cursor := crSizeAll;
                Exit;
        end;

        // ----- Move/scale tool: start drag if click is on the current
        // selection's body or handles. Any click elsewhere falls through
        // to normal selection (which will pick whichever texture was
        // clicked, or deselect if empty space).
        if FMoveToolActive and (Button = mbLeft) and (not boolRcrJam) and
          (intSelectedTexture >= 0) then
        begin
                selRect := GetSelectedTextureScreenRect;
                hitMode := HitTestTextureZone(X, Y, selRect);

                if hitMode <> rmNone then
                begin
                        canvasPt := ScreenToCanvas(Point(X, Y));
                        FDrag.Active := true;
                        FDrag.Mode := hitMode;
                        FDrag.StartMouseX := canvasPt.X;
                        FDrag.StartMouseY := canvasPt.Y;
                        if boolHWJAM then
                                with FHWJamFile.FEntries[intSelectedTexture].FInfo do
                                begin
                                        FDrag.StartX := X;
                                        FDrag.StartY := Y;
                                        FDrag.StartW := Width;
                                        FDrag.StartH := Height;
                                end
                        else
                                with FJamFile.FEntries[intSelectedTexture].FInfo do
                                begin
                                        FDrag.StartX := X;
                                        FDrag.StartY := Y;
                                        FDrag.StartW := Width;
                                        FDrag.StartH := Height;
                                end;
                        if FDrag.StartH > 0 then
                                FDrag.AspectRatio := FDrag.StartW / FDrag.StartH
                        else
                                FDrag.AspectRatio := 1;
                        if boolUndo then
                                PushUndoState;
                        boolUndo := false;
                        // Cache the scaled canvas WITHOUT the moving texture
                        // so per-move frames don't need to StretchBlt the
                        // whole canvas. Disabled for HW for now.
                        if not boolHWJAM then
                                CaptureDragBackground;
                        Exit; // Skip normal selection logic during drag
                end;
                // rmNone: click is outside the selected texture's hit zone.
                // Fall through to normal selection — the code below will
                // pick up any texture the user actually clicked on.
        end;

        if not(ssShift in Shift) then
        begin
                SelectedTextureList.Clear;
                SelectedTreeNodes.Clear;
        end;

        UpdatingFromCode := true;
        SelectFromCanvas := true;
        intSelectedTexture := -1;

        tempX := X;
        tempY := Y;

        if boolHWJAM then
        begin
                for i := 0 to FHWJamFile.Entries.Count - 1 do
                begin
                        with FHWJamFile.Entries[i].Info do
                        begin
                                jamX := Round(X * EffectiveJamZoom);
                                jamY := Round(Y * EffectiveJamZoom);
                                jamW := Round(Width * EffectiveJamZoom);
                                jamH := Round(height * EffectiveJamZoom);
                        end;

                        if (tempX >= jamX) and (tempX < jamX + jamW) and
                          (tempY >= jamY) and (tempY < jamY + jamH) then
                        begin
                                intSelectedTexture := i;
                                if not SelectedTextureList.Contains(i) then
                                        SelectedTextureList.Add(i);

                                Break;
                        end;
                end;
        end
        else
        begin
                for i := 0 to FJamFile.Entries.Count - 1 do
                begin
                        with FJamFile.Entries[i].Info do
                        begin
                                if boolRcrJam then
                                begin
                                        // Match DrawOutlines + DrawTextureOutlines
                                        // coordinate transform exactly
                                        if Y mod 2 <> 0 then
                                        begin
                                                // Odd Y: right half of deinterlaced canvas
                                                jamX := Round(((X + 256) div 2) * EffectiveJamZoom);
                                                jamY := Round(((Y - 1) div 2) * EffectiveJamZoom);
                                        end
                                        else
                                        begin
                                                // Even Y: left half
                                                jamX := Round((X div 2) * EffectiveJamZoom);
                                                jamY := Round((Y div 2) * EffectiveJamZoom);
                                        end;
                                        // Width: *2 then /2 in outline pipeline = original
                                        jamW := Round(Width * EffectiveJamZoom);
                                        // Height: NOT halved (matches DrawTextureOutlines)
                                        jamH := Round(Height * EffectiveJamZoom);
                                end
                                else
                                begin
                                        jamX := Round(X * EffectiveJamZoom);
                                        jamY := Round(Y * EffectiveJamZoom);
                                        jamW := Round(Width * EffectiveJamZoom);
                                        jamH := Round(Height * EffectiveJamZoom);
                                end;
                        end;

                        if (tempX >= jamX) and (tempX < jamX + jamW) and
                          (tempY >= jamY) and (tempY < jamY + jamH) then
                        begin
                                intSelectedTexture := i;
                                if not SelectedTextureList.Contains(i) then
                                        SelectedTextureList.Add(i);
                                Break;
                        end;
                end;
        end;

        if intSelectedTexture = -1 then
        begin
                DeSelectTexture;
                SelectedTextureList.Clear;
                UpdatingFromCode := false;
                SelectFromCanvas := false;
        end
        else
        begin
                SelectTexture(intSelectedTexture, false);
                if SelectedTextureList.Count > 1 then
                begin
                        UpdatingFromCode := true;
                        tex_Y.Value := 0;
                        tex_X.Value := 0;
                        tex_ID.Value := 0;
                        tex_width.Value := 0;
                        tex_height.Value := 0;
                end;
                UpdatingFromCode := false;
                SelectFromCanvas := false;
        end;

end;

procedure TFormMain.ImageCanvasMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
        canvasPt: TPoint;
        dx, dy: integer;
        newX, newY, newW, newH: integer;
        shiftHeld: Boolean;
        screenPt: TPoint;
begin
        if not boolJamLoaded then
                Exit;

        // ----- Space-bar panning -----
        if FPanActive then
        begin
                screenPt := ImageCanvas.ClientToScreen(Point(X, Y));
                dx := FPanStartMouse.X - screenPt.X;
                dy := FPanStartMouse.Y - screenPt.Y;
                ScrollBox1.HorzScrollBar.Position := FPanStartScrollX + dx;
                ScrollBox1.VertScrollBar.Position := FPanStartScrollY + dy;
                Exit;
        end;

        if boolRcrJam then
                Exit;

        // Hover: cursor feedback when move tool active but not dragging
        if FMoveToolActive and (not FDrag.Active) then
        begin
                UpdateCursorForHitZone(X, Y);
                Exit;
        end;

        if not FDrag.Active then
                Exit;

        // Throttle drag renders to the monitor's refresh rate.
        // QueryPerformanceCounter gives sub-millisecond precision so the
        // interval is exactly right — no ±15ms jitter from GetTickCount.
        // FDragFrameInterval is set from the real Hz in RefreshDPIFactor;
        // FLastDragQPC = 0 the first time so the first frame is never skipped.
        // The final position on MouseUp is always exact regardless.
        if FDragFrameInterval > 0 then
        begin
                var now: Int64;
                QueryPerformanceCounter(now);
                if (FLastDragQPC > 0) and (now - FLastDragQPC < FDragFrameInterval) then
                        Exit;
                FLastDragQPC := now;
        end;

        canvasPt := ScreenToCanvas(Point(X, Y));
        dx := canvasPt.X - FDrag.StartMouseX;
        dy := canvasPt.Y - FDrag.StartMouseY;
        shiftHeld := ssShift in Shift;

        case FDrag.Mode of
                rmMove:
                        ApplyTextureTransform(FDrag.StartX + dx, FDrag.StartY + dy,
                          FDrag.StartW, FDrag.StartH);

                rmRight:
                        ApplyTextureTransform(FDrag.StartX, FDrag.StartY,
                          Max(1, FDrag.StartW + dx), FDrag.StartH);

                rmBottom:
                        ApplyTextureTransform(FDrag.StartX, FDrag.StartY,
                          FDrag.StartW, Max(1, FDrag.StartH + dy));

                rmLeft:
                        begin
                                newW := Max(1, FDrag.StartW - dx);
                                ApplyTextureTransform(
                                  FDrag.StartX + (FDrag.StartW - newW),
                                  FDrag.StartY, newW, FDrag.StartH);
                        end;

                rmTop:
                        begin
                                newH := Max(1, FDrag.StartH - dy);
                                ApplyTextureTransform(FDrag.StartX,
                                  FDrag.StartY + (FDrag.StartH - newH),
                                  FDrag.StartW, newH);
                        end;

                rmBottomRight:
                        begin
                                newW := Max(1, FDrag.StartW + dx);
                                newH := Max(1, FDrag.StartH + dy);
                                if not shiftHeld then
                                        newH := Max(1,
                                          Round(newW / FDrag.AspectRatio));
                                ApplyTextureTransform(FDrag.StartX, FDrag.StartY,
                                  newW, newH);
                        end;

                rmTopLeft:
                        begin
                                newW := Max(1, FDrag.StartW - dx);
                                newH := Max(1, FDrag.StartH - dy);
                                if not shiftHeld then
                                        newH := Max(1,
                                          Round(newW / FDrag.AspectRatio));
                                newX := FDrag.StartX + (FDrag.StartW - newW);
                                newY := FDrag.StartY + (FDrag.StartH - newH);
                                ApplyTextureTransform(newX, newY, newW, newH);
                        end;

                rmTopRight:
                        begin
                                newW := Max(1, FDrag.StartW + dx);
                                newH := Max(1, FDrag.StartH - dy);
                                if not shiftHeld then
                                        newH := Max(1,
                                          Round(newW / FDrag.AspectRatio));
                                newY := FDrag.StartY + (FDrag.StartH - newH);
                                ApplyTextureTransform(FDrag.StartX, newY,
                                  newW, newH);
                        end;

                rmBottomLeft:
                        begin
                                newW := Max(1, FDrag.StartW - dx);
                                newH := Max(1, FDrag.StartH + dy);
                                if not shiftHeld then
                                        newH := Max(1,
                                          Round(newW / FDrag.AspectRatio));
                                newX := FDrag.StartX + (FDrag.StartW - newW);
                                ApplyTextureTransform(newX, FDrag.StartY,
                                  newW, newH);
                        end;
        end;
end;

procedure TFormMain.ImageCanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
        wasResize: Boolean;
begin
        if Button = mbLeft then
        begin
                // End pan
                if FPanActive then
                begin
                        FPanActive := False;
                        // If space still held, keep pan cursor; else default
                        if FSpacePanArmed then
                                ImageCanvas.Cursor := crSizeAll
                        else
                                ImageCanvas.Cursor := crDefault;
                        Exit;
                end;

                if FDrag.Active then
                begin
                        // Capture mode BEFORE we clear it — needed below to
                        // decide between move-only and resize finish paths.
                        wasResize := FDrag.Mode <> rmMove;
                        FDrag.Active := false;
                        FDrag.Mode := rmNone;
                        boolUndo := true; // re-arm undo for next action
                        FSnapXActive := False;
                        FSnapYActive := False;
                        ReleaseDragBackground;
                        // Do a full composite refresh now that drag is done.
                        // In JIP mode the mipmap section and canvas height are
                        // only updated by DrawJIPMipmaps; if the drag was a
                        // resize, FRawTexture is still at the old W*H and
                        // DrawJIPMipmaps would read past its end (crash at
                        // JamSW line ~1547). JamReGen re-encodes FRawTexture
                        // from FOriginalTex at the new size and then runs
                        // the JIP refresh itself.
                        if booljamLoaded then
                        begin
                                if boolJipMode and wasResize and
                                  (not boolHWJAM) and (intSelectedTexture >= 0) then
                                        JamReGen
                                else
                                begin
                                        if boolJipMode then
                                                FJamFile.DrawJIPMipmaps;
                                        RefreshCanvas;
                                end;
                        end;
                end;
        end;
end;

procedure TFormMain.JamTreeAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: boolean);
var
        JNode: TJamTreeNode;
        TextRect: TRect;
        TextWidth: integer;
        SwatchRect: TRect;
        SwatchSize: integer;
        ColorValue: TColor;
        Canvas: TCanvas;
begin
        if Stage = cdPrePaint then
        begin
                if SelectedTreeNodes.Contains(Node) then
                begin
                        Sender.Canvas.Brush.Color := clSkyBlue;
                        Sender.Canvas.FillRect(Node.DisplayRect(true));
                end;
        end;

        if Stage <> cdPostPaint then
                Exit;

        if not Assigned(Node) or not Assigned(Node.data) then
                Exit;

        JNode := TJamTreeNode(Node.data);
        if not(JNode.nodeType in [jamColour]) then
                Exit; // draw only on colour nodes

        Canvas := Sender.Canvas;

        // 1. Get the area where the node is drawn
        TextRect := Node.DisplayRect(true);

        // 2. Measure text width
        TextWidth := Canvas.TextWidth(Node.Text);

        // 3. Define swatch size and location (right of text, with margin)
        SwatchSize := 12;
        SwatchRect.Left := TextRect.Left + TextWidth + 8;
        SwatchRect.Top := TextRect.Top + ((TextRect.height - SwatchSize) div 2);
        SwatchRect.Right := SwatchRect.Left + SwatchSize;
        SwatchRect.Bottom := SwatchRect.Top + SwatchSize;

        // 4. Get the color to draw (example assumes grayscale from Data)
        ColorValue := RGBFromTRGB(GPXPal[JNode.data]); // Example grayscale

        // 5. Draw the color swatch
        with Canvas do
        begin
                Brush.Style := bsSolid;
                Brush.Color := ColorValue;
                FillRect(SwatchRect);

                Pen.Color := clBlack;
                Rectangle(SwatchRect); // border
        end;

        DefaultDraw := true;
end;

procedure TFormMain.JamTreeChange(Sender: TObject; Node: TTreeNode);
var
        jamNode: TJamTreeNode;
begin

        if UpdatingFromCode = false then
        begin
                if not Assigned(Node) or not Assigned(Node.data) then
                begin
                        DeSelectTexture;
                        Exit;
                end;

                jamNode := TJamTreeNode(Node.data);

                case jamNode.nodeType of
                        jamDimensions:
                                begin
                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamPosX:
                                begin
                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamposY:
                                begin
                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamwidth:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamheight:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;
                        jamData:
                                begin
                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamPalInfo:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamFlags:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamColour:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamUnk:
                                begin

                                        SelectTexture(jamNode.jamID, true);
                                end;

                        jamID:
                                begin
                                        SelectTexture(jamNode.jamID, true);
                                end;

                        canvasDimensions:
                                begin
                                        DeSelectTexture();
                                end;

                        rootNode:
                                begin
                                        DeSelectTexture();
                                end;
                end;
        end;
        JamTree.Invalidate;
end;

procedure TFormMain.JamTreeDeletion(Sender: TObject; Node: TTreeNode);
begin
        if Assigned(Node.data) then
        begin
                TObject(Node.data).Free;
                Node.data := nil;
        end;
end;

procedure TFormMain.JamTreeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
        ClickedNode: TTreeNode;
        ClickedData, ExistingData: TJamTreeNode;
        i, j: integer;
begin
        // ClickedNode := JamTree.GetNodeAt(X, Y);
        //
        // if not Assigned(ClickedNode) or not Assigned(ClickedNode.Data) then
        // Exit;
        //
        // ClickedData := TJamTreeNode(ClickedNode.Data);
        //
        //
        // // Check if user is attempting a multi-selection
        // if (ssCtrl in Shift) or (ssShift in Shift) then
        // begin
        // // We only allow multi-selection if ALL are of type jamID
        // if ClickedData.NodeType <> jamID then
        // begin
        // // Block multi-select for this type: clear selection and allow only the clicked one
        // for I := 0 to JamTree.Items.Count - 1 do
        // JamTree.Items[I].Selected := False;
        //
        // ClickedNode.Selected := True;
        // Exit;
        // end;
        //
        // // If we are adding to a multi-select, make sure all selected nodes are jamID
        // for I := 0 to JamTree.Items.Count - 1 do
        // begin
        // if JamTree.Items[I].Selected then
        // begin
        // ExistingData := TJamTreeNode(JamTree.Items[I].Data);
        // if ExistingData.NodeType <> jamID then
        // begin
        // // Invalid multi-select — clear and select only the clicked one
        // for  j:= 0 to JamTree.Items.Count - 1 do
        // JamTree.Items[I].Selected := False;
        // ClickedNode.Selected := True;
        // Exit;
        // end;
        // end;
        // end;
        // end;
end;

procedure TFormMain.RefreshCanvas;
var
        bmp, canvasBMP, scaledBMP: TBitmap;
        newWidth, newHeight: integer;
        extW, extH, marginW, marginH: integer;
begin

        if boolRCRJAM = false then
        begin
                JamSanityCheck;
                JamSanityCheckInform(false);

        end;

        if boolHWJAM then
                bmp := FHWJamFile.DrawCanvas(true)
        else
                bmp := FJamFile.DrawFullJam(true);

        newWidth := Round(bmp.Width * EffectiveJamZoom);
        newHeight := Round(bmp.height * EffectiveJamZoom);

        lblCanvasSize.Caption := Format('%d x %d px', [bmp.Width, bmp.Height]);
        if boolDPIScaling and (dblDPIFactor > 1.001) then
                lblCanvasZoom.Caption := Format('Zoom: %d%% [DPI ×%.2g]',
                  [Round(intJamZoom * 100), dblDPIFactor])
        else
                lblCanvasZoom.Caption := Format('Zoom: %d%%',
                  [Round(intJamZoom * 100)]);

        canvasBMP := nil;
        scaledBMP := nil;
        try
                // Build the natural canvas content (StretchBlt + optional
                // checkerboard) into a temporary at exactly the canvas
                // size — keeps the checkerboard from leaking onto the
                // off-canvas margin we add below.
                canvasBMP := TBitmap.Create;
                canvasBMP.height := newHeight;
                canvasBMP.Width := newWidth;

                SetStretchBltMode(canvasBMP.Canvas.Handle, COLORONCOLOR);

                StretchBlt(canvasBMP.Canvas.Handle, 0, 0, newWidth, newHeight,
                  bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.height, SRCCOPY);

                if boolShowCheckerboard then
                begin
                        if boolHWJAM then
                                ComposeCheckerboard(canvasBMP, TCol_TransGP3HW)
                        else
                                ComposeCheckerboard(canvasBMP,
                                  RGB(gpxPal[0].r, gpxPal[0].g, gpxPal[0].b));
                end;

                // Composite the canvas onto a larger surface with a margin
                // on the right/bottom. ApplyOutlineOverlay then naturally
                // draws outlines + handles for any texture that extends
                // into the margin, keeping it visible + grabbable.
                //
                // The margin fills whatever empty space the canvas leaves
                // inside the ScrollBox client area, so we get as much
                // off-canvas room as the ScrollBox can show without
                // forcing extra scrollbars.  If the canvas already fills
                // (or exceeds) the ScrollBox, the margin collapses to 0
                // and the user pans via the normal scrollbars.
                marginW := Max(0, ScrollBox1.ClientWidth  - newWidth);
                marginH := Max(0, ScrollBox1.ClientHeight - newHeight);

                extW := newWidth  + marginW;
                extH := newHeight + marginH;

                scaledBMP := TBitmap.Create;
                scaledBMP.PixelFormat := pf24bit;
                scaledBMP.Width  := extW;
                scaledBMP.Height := extH;
                scaledBMP.Canvas.Brush.Color := clMedGray;
                scaledBMP.Canvas.FillRect(Rect(0, 0, extW, extH));
                scaledBMP.Canvas.Draw(0, 0, canvasBMP);

                ApplyOutlineOverlay(scaledBMP);

                ImageCanvas.height := extH;
                ImageCanvas.Width  := extW;
                ImageCanvas.Picture.Bitmap := scaledBMP;

        finally
                FreeAndNil(canvasBMP);
                FreeAndNil(scaledBMP);
                FreeAndNil(bmp);
        end;

end;

procedure TFormMain.RefreshPalette();
begin
        if boolTexSelected then
                if FJamFile.Entries[intSelectedTexture].Info.PaletteSizeDiv4 = 0
                then
                        panel_PalPreview.Visible := false
                else
                begin
                        panel_PalPreview.Visible := true;
                        PaintBoxPalette.Repaint;
                end;
        PaintBoxPalette.Invalidate;
end;

procedure TFormMain.ResetZoom1Click(Sender: TObject);
begin
        intJamZoom := 1;
        RefreshCanvas;
end;

procedure TFormMain.Splitter2Paint(Sender: TObject);
var
        ratio: Double;
begin

        if boolJamLoaded = false then
                Exit;

        ratio := ImageEntry.Picture.Graphic.height /
          ImageEntry.Picture.Graphic.Width;

        ImageEntry.height := Round(ImageEntry.Width * ratio);

        if ImageEntry.height > 256 then
                ImageEntry.height := 256;

end;

procedure TFormMain.texScaleChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;
        boolScaleChange := true;
        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.texScaleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                texScaleChange(Sender); // manually trigger change
        end;
end;

procedure TFormMain.texScaleKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false
end;

procedure TFormMain.texScaleXChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;
        boolScaleXChange := true;
        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.texScaleXKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                texScaleXChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.texScaleXKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false
end;

procedure TFormMain.texScaleYChange(Sender: TObject);
begin
        var
                i: integer;
        begin
                if UpdatingFromCode or userisTyping then
                        Exit;
                boolScaleYChange := true;
                for i := 0 to SelectedTextureList.Count - 1 do
                        UpdateJamData(SelectedTextureList[i]);
        end;

end;

procedure TFormMain.texScaleYKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                texScaleYChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.texScaleYKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false

end;

procedure TFormMain.tex_flagsClickCheck(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode then
                Exit;
        boolFlagChange := true;
        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.RebuildFlagsList;
// Rebuilds the Texture Flags list based on boolShowAdvancedFlags.
// When off: only the 10 named flags.
// When on:  all 16 bit positions, with unknown ones labeled Flag 11..16.
// After rebuild, checked state is re-synced from the currently selected
// texture so visible boxes reflect the underlying jamFlags value.
const
        FLAG_NAMES_BASIC: array[0..9] of string = (
                'Car Shadow (?)',
                'Helmet Texture (?)',
                'Flag 3',
                'Transparent',
                'Multi-Part Texture (?)',
                'Multi-Part Texture (?)',
                'Use Pit Crew Colours',
                'No Local Palettes',
                'Non-Standard Height',
                'Non-Standard Width');
var
        i: Integer;
        jamFlags: Word;
        hasSel: Boolean;
        prevUpdating: Boolean;
begin
        // Suppress OnClickCheck fire-back while we mutate the list
        prevUpdating := UpdatingFromCode;
        UpdatingFromCode := True;
        try
                tex_flags.Items.BeginUpdate;
                try
                        tex_flags.Items.Clear;
                        for i := Low(FLAG_NAMES_BASIC) to High(FLAG_NAMES_BASIC) do
                                tex_flags.Items.Add(FLAG_NAMES_BASIC[i]);
                        if boolShowAdvancedFlags then
                                for i := 11 to 16 do
                                        tex_flags.Items.Add('Flag ' + IntToStr(i));
                finally
                        tex_flags.Items.EndUpdate;
                end;

                // Re-sync checked state from the selected texture, if any
                hasSel := boolJamLoaded and (intSelectedTexture >= 0);
                if hasSel then
                begin
                        if boolHWJAM then
                                jamFlags := FHWJamFile.FEntries[intSelectedTexture].FInfo.jamFlags
                        else
                                jamFlags := FJamFile.FEntries[intSelectedTexture].FInfo.jamFlags;
                        for i := 0 to tex_flags.Items.Count - 1 do
                                tex_flags.Checked[i] := UnPackFlag(jamFlags, i);
                end;
        finally
                UpdatingFromCode := prevUpdating;
        end;
end;

procedure TFormMain.chkShowAdvancedFlagsClick(Sender: TObject);
begin
        if UpdatingFromCode then
                Exit;
        boolShowAdvancedFlags := chkShowAdvancedFlags.Checked;
        RebuildFlagsList;
end;

procedure TFormMain.tex_heightChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;

        boolHeightChange := true;

        if boolUndo then
                PushUndoState;

        boolUndo := false;
        undoTimer.Enabled := false;
        undoTimer.Enabled := true;

        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.tex_heightKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                tex_heightChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.tex_heightKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false;
end;

procedure TFormMain.tex_IDChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;

        boolIDChange := true;

        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.tex_IDKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                tex_IDChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.tex_IDKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false;

end;

procedure TFormMain.tex_widthChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;

        boolWidthChange := true;

        if boolUndo then
                PushUndoState;

        boolUndo := false;
        undoTimer.Enabled := false;
        undoTimer.Enabled := true;

        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.tex_widthKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                tex_widthChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.tex_widthKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false;
end;

procedure TFormMain.tex_XChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;
        boolXChange := true;
        if boolUndo then
                PushUndoState;

        boolUndo := false;
        undoTimer.Enabled := false;
        undoTimer.Enabled := true;

        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.tex_XKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                tex_XChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.tex_XKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false;

end;

procedure TFormMain.tex_XMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
        if boolUndo then
                PushUndoState;

        boolUndo := false;
end;

procedure TFormMain.tex_XMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
        boolUndo := true;
end;

procedure TFormMain.tex_YChange(Sender: TObject);
var
        i: integer;
begin
        if UpdatingFromCode or userisTyping then
                Exit;

        boolYChange := true;

        if boolUndo then
                PushUndoState;

        boolUndo := false;
        undoTimer.Enabled := false;
        undoTimer.Enabled := true;

        for i := 0 to SelectedTextureList.Count - 1 do
                UpdateJamData(SelectedTextureList[i]);
end;

procedure TFormMain.tex_YKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        userisTyping := true;
        if Key = VK_RETURN then
        begin
                userisTyping := false;
                tex_YChange(Sender); // manually trigger change
        end;

end;

procedure TFormMain.tex_YKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

        // If the user presses a non-editing key, you might reset typing
        if Key = VK_ESCAPE then
                userisTyping := false;
end;

procedure TFormMain.timer_JamRedrawPalsTimer(Sender: TObject);
begin
        timer_JamRedrawPals.Enabled := false;
        JamReGen;
end;

procedure TFormMain.timer_redrawTreeTimer(Sender: TObject);
begin
        timer_redrawTree.Enabled := false;
        UpdatingFromCode := true;
        TreeReDraw;

        UpdatingFromCode := false;
end;

procedure TFormMain.toolBar_GP2PALMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
        if toolBar_GP2PAL.down = false then
                toolBar_GP2PAL.down := true;
end;

procedure TFormMain.toolBar_GP3PALMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
        if toolBar_GP3PAL.down = false then
                toolBar_GP3PAL.down := true;
end;

procedure TFormMain.toolBar_PalNextClick(Sender: TObject);
begin

        if intPaletteID = 3 then
        begin
                PalChange(0);
        end
        else
        begin
                PalChange(intPaletteID + 1);
        end;
end;

procedure TFormMain.toolBar_PalPrevClick(Sender: TObject);

begin

        if intPaletteID = 0 then
        begin
                PalChange(3);
        end
        else
        begin
                PalChange(intPaletteID - 1);
        end;

end;

procedure TFormMain.PaintBoxPalettePaint(Sender: TObject);
var
        Count, i: integer;
        PalBytes: TBytes;
        c: TColor;
        CellLeft, CellRight: integer;
        Scale: Double;
begin
        if not Assigned(FJamFile) then
                Exit;

        if intSelectedTexture > -1 then
        begin
                Count := FJamFile.Entries[intSelectedTexture]
                  .Info.PaletteSizeDiv4;
                if Count = 0 then
                        Exit;

                PalBytes := FJamFile.Entries[intSelectedTexture].Palettes
                  [intPaletteID];

                Scale := PaintBoxPalette.Width / Count;

                for i := 0 to Count - 1 do
                begin
                        c := RGBFromTRGB(GPXPal[PalBytes[i]]);
                        localGpxPal[i] := GPXPal[PalBytes[i]];

                        // Use rounded boundaries
                        CellLeft := Round(i * Scale);
                        CellRight := Round((i + 1) * Scale);

                        PaintBoxPalette.Canvas.Brush.Color := c;
                        PaintBoxPalette.Canvas.FillRect
                          (Rect(CellLeft, 0, CellRight,
                          PaintBoxPalette.height));
                end;
        end;
end;

procedure TFormMain.mainMenuImportCanvasClick(Sender: TObject);
begin

        importDialog.InitialDir := strImportPath;
        if importDialog.Execute then
        begin
                if (importDialog.filename <> '') and
                  FileExists(importDialog.filename) then
                begin
                        if boolHWJAM then
                                FHWJamFile.ImportCanvas(importDialog.filename)
                        else
                                FJamFile.ImportCanvas(importDialog.filename);
                        strImportPath := ExtractFilePath(importDialog.filename);
                end;

        end
        else
                Exit;

        RefreshCanvas;

        if not boolHWJAM then
                RefreshPalette;

        DrawTexture;

end;

procedure TFormMain.mainMenuImportTextureClick(Sender: TObject);
begin
        ImportTexture(Sender);
end;

procedure TFormMain.mainMenuPasteClick(Sender: TObject);
var
        jamList: TList<TjamEntry>;
        jamHWList: TList<THWjamEntry>;
        i: integer;
begin
        if boolHWJAM then
        begin
                if not Clipboard.HasFormat(ClipboardHWJAM) then
                        Exit;

                DeSelectTexture;
                SelectedTextureList.Clear;

                jamHWList := PasteHWJam();

                for i := 0 to jamHWList.Count - 1 do
                        FHWJamFile.FEntries.Add(jamHWList[i]);

                intSelectedTexture := FHWJamFile.FEntries.Count - 1;
                if not SelectedTextureList.Contains(intSelectedTexture) then
                        SelectedTextureList.Add(intSelectedTexture);

                RefreshCanvas;

                UpdatingFromCode := true;

                DrawTree;
                SelectTreeTex;
                JamModified(true);

                UpdatingFromCode := false;

                jamHWList.Clear;
                jamHWList.Free;

        end
        else
        begin

                if not Clipboard.HasFormat(ClipboardJAM) then
                        Exit;

                DeSelectTexture;
                SelectedTextureList.Clear;

                jamList := PasteJam();

                for i := 0 to jamList.Count - 1 do
                        FJamFile.FEntries.Add(jamList[i]);

                intSelectedTexture := FJamFile.FEntries.Count - 1;
                if not SelectedTextureList.Contains(intSelectedTexture) then
                        SelectedTextureList.Add(intSelectedTexture);

                JamReGen;

                UpdatingFromCode := true;

                DrawTree;
                SelectTreeTex;
                JamModified(true);

                UpdatingFromCode := false;

                jamList.Clear;
                jamList.Free;
        end;

end;

procedure TFormMain.mainMenuSaveAsClick(Sender: TObject);
begin

        if JamSanityCheck then
        begin
                JamSanityCheckInform(true);
                Exit;
        end;

        if boolHWJAM then
                dlgSaveJam.filename := FHWJamFile.JamFileName + '.jam'
        else
                dlgSaveJam.filename := FJamFile.JamFileName + '.jam';

        if dlgSaveJam.Execute then
        begin
                if boolHWJAM then
                begin
                        FHWJamFile.SaveToFile(dlgSaveJam.filename);
                        FHWJamFile.JamFileName :=
                          lowercase(ChangeFileExt
                          (ExtractFileName(dlgSaveJam.filename), ''));
                        FHWJamFile.JamFullPath := dlgSaveJam.filename;
                end
                else
                begin
                        FJamFile.SaveToFile(dlgSaveJam.filename, false);
                        FJamFile.JamFileName :=
                          lowercase(ChangeFileExt
                          (ExtractFileName(dlgSaveJam.filename), ''));
                        FJamFile.JamFullPath := dlgSaveJam.filename;
                end;

                JamModified(false);

        end
        else
                // user cancelled the Save As dialog
                Exit;

end;

procedure TFormMain.ImportTexture(Sender: TObject);
begin
        importDialog.InitialDir := strImportPath;
        if importDialog.Execute then
        begin
                if (importDialog.filename <> '') and
                  FileExists(importDialog.filename) then
                begin
                        if boolHWJAM then
                                FHWJamFile.ImportTexture(intSelectedTexture,
                                  importDialog.filename)
                        else
                                FJamFile.ImportTexture(intSelectedTexture,
                                  importDialog.filename);
                        strImportPath := ExtractFilePath(importDialog.filename);
                end;

        end
        else
                Exit;

        RefreshCanvas;

        if not boolHWJAM then
                RefreshPalette;

        DrawTexture;

end;

procedure TFormMain.AddNewTexture(Sender: TObject);
var
        JamRects: TArray<TJamRect>;
        i: integer;

begin
        if importDialog.Execute then
        begin
                if (importDialog.filename <> '') and
                  FileExists(importDialog.filename) then
                begin
                        PushUndoState;
                        if boolHWJAM then
                        begin
                                FHWJamFile.AddTexture(importDialog.filename);

                                if boolJipMode or boolAutoLayout then
                                begin
                                        FHWJamFile.BuildRect_HW(FHWJamFile,
                                        JamRects);
                                        PackRects(JamRects, 256,
                                        FHWJamFile.canvasHeight);

                                        for i := 0 to high(JamRects) do
                                        begin

                                        begin
                                        FHWJamFile.FEntries[JamRects[i].index]
                                        .FInfo.X := JamRects[i].X;
                                        FHWJamFile.FEntries[JamRects[i].index]
                                        .FInfo.Y := JamRects[i].Y;
                                        end;

                                        end;
                                end;

                                intSelectedTexture :=
                                  FHWJamFile.FEntries.Count - 1;

                                JamReGen;

                                UpdatingFromCode := true;

                                RefreshCanvas;
                                DrawTexture;
                                DrawTree;
                                SelectTreeTex;

                                UpdatingFromCode := false;
                                JamModified(true);
                        end
                        else
                        begin
                                FJamFile.AddTexture(importDialog.filename);

                                if boolJipMode or boolAutoLayout then
                                begin
                                        FJamFile.BuildRect_SW(FJamFile,
                                        JamRects);
                                        PackRects(JamRects, 256,
                                        FJamFile.canvasHeight);

                                        for i := 0 to high(JamRects) do
                                        begin

                                        begin
                                        FJamFile.FEntries[JamRects[i].index]
                                        .FInfo.X := JamRects[i].X;
                                        FJamFile.FEntries[JamRects[i].index]
                                        .FInfo.Y := JamRects[i].Y;
                                        end;
                                        Fjamfile.DrawJIPMipmaps;

                                        end;
                                end;
                                JamReGen;

                                intSelectedTexture :=
                                  FJamFile.FEntries.Count - 1;

                                UpdatingFromCode := true;

                                 DrawTree;
                                SelectTreeTex;
                                JamModified(true);

                                UpdatingFromCode := false;
                        end;
                end
                else
                        Exit;
        end;
end;

procedure TFormMain.mainMenuAddTextureClick(Sender: TObject);
begin
        AddNewTexture(Sender);
end;

// procedure TFormMain.mainMenuCopyClick(Sender: TObject);
// var
// I: integer;
// jamList: TList<TjamEntry>;
// begin
//
// jamList := TList<TjamEntry>.Create;
//
// for I := 0 to SelectedTextureList.Count - 1 do
// begin
// jamList.Add(FJamFile.Entries[SelectedTextureList[I]]);
// end;
//
// CopyJAM(jamList);
//
// jamList.Clear;
// end;

procedure TFormMain.mainMenuCopyClick(Sender: TObject);
begin

        Copy;

end;

procedure TFormMain.mainMenuCutClick(Sender: TObject);
var
        i: integer;
begin

        Copy;

        if boolHWJAM then
        begin
                for i := SelectedTextureList.Count - 1 downto 0 do
                begin
                        FHWJamFile.DeleteTexture(SelectedTextureList[i])
                end;
        end
        else
        begin
                for i := SelectedTextureList.Count - 1 downto 0 do
                begin
                        FJamFile.DeleteTexture(SelectedTextureList[i])
                end;
        end;

        DeSelectTexture;
        SelectedTextureList.Clear;

        UpdatingFromCode := true;

        DrawTree;
        SelectTreeTex;
        JamModified(true);

        UpdatingFromCode := false;

end;

procedure TFormMain.mainMenuDeleteTextureClick(Sender: TObject);
begin
        DeleteTexture;
end;

procedure TFormMain.numBox_BlurAmountChange(Sender: TObject);
begin
        // PaletteReGen;
end;

procedure TFormMain.numBox_SimpThreshChange(Sender: TObject);
begin
        // PaletteReGen;
end;

procedure TFormMain.ScrollBox1Click(Sender: TObject);
begin
        if boolJamLoaded then
        begin
                UpdatingFromCode := true;
                DeSelectTexture();
                SelectTreeTex();
                UpdatingFromCode := false;
        end;
end;

procedure TFormMain.ScrollBox1Resize(Sender: TObject);
begin
        // Recompute the off-canvas margin against the new client area when
        // the user resizes the form. Without this the margin would stay
        // sized for the old client width/height and either leave wasted
        // space (if the scrollbox grew) or trigger scrollbars that should
        // no longer be needed (if it shrank).
        // Skip mid-drag — DrawDragPreview owns ImageCanvas's bitmap during
        // a drag and would have its cached background invalidated.
        if boolJamLoaded and (not FDrag.Active) then
                RefreshCanvas;
end;

procedure TFormMain.UpdateUIData(id: integer);
var
        i: integer;
begin
        if boolHWJAM then
        begin

                tex_ID.Enabled := true;
                tex_X.Enabled := true;
                tex_Y.Enabled := true;
                tex_width.Enabled := true;
                tex_height.Enabled := true;

                tex_ID.Value := FHWJamFile.FEntries[id].FInfo.jamID;
                tex_X.Value := FHWJamFile.FEntries[id].FInfo.X;
                tex_Y.Value := FHWJamFile.FEntries[id].FInfo.Y;
                tex_width.Value := FHWJamFile.FEntries[id].FInfo.Width;
                tex_height.Value := FHWJamFile.FEntries[id].FInfo.height;

                canvasHeight.Value := FHWJamFile.FHeader.JamTotalHeight;

                tex_flags.Enabled := true;
                for i := 0 to tex_flags.Items.Count - 1 do
                        tex_flags.Checked[i] :=
                          UnPackFlag(FHWJamFile.FEntries[id].FInfo.jamFlags, i);

        end
        else
        begin
                RefreshPalette;

                tex_ID.Enabled := true;
                tex_X.Enabled := true;
                tex_Y.Enabled := true;
                tex_width.Enabled := true;
                tex_height.Enabled := true;

                btnPal0.Enabled := true;
                btnPal1.Enabled := true;
                btnPal2.Enabled := true;
                btnPal3.Enabled := true;

                btnGenPal.Enabled := true;
                btnRemovePal.Enabled := true;

                tex_ID.Value := FJamFile.FEntries[id].FInfo.jamID;
                tex_X.Value := FJamFile.FEntries[id].FInfo.X;
                tex_Y.Value := FJamFile.FEntries[id].FInfo.Y;
                tex_width.Value := FJamFile.FEntries[id].FInfo.Width;
                tex_height.Value := FJamFile.FEntries[id].FInfo.height;

                chkBoxTrans.Checked :=
                  DetectTransCol(FJamFile.FEntries[id].FTexture);

                tex_flags.Enabled := true;

                texScale.Enabled := true;
                texScaleX.Enabled := true;
                texScaleY.Enabled := true;
                scaleFlags.Enabled := true;

                texScale.Value := FJamFile.FEntries[id].FInfo.scaleFactor;
                texScaleX.Value := FJamFile.FEntries[id].FInfo.scaleX;
                texScaleY.Value := FJamFile.FEntries[id].FInfo.scaleY;

                canvasHeight.Value := FJamFile.FHeader.JamTotalHeight;

                for i := 0 to tex_flags.Items.Count - 1 do
                        tex_flags.Checked[i] :=
                          UnPackFlag(FJamFile.FEntries[id].FInfo.jamFlags, i);

                for i := 0 to 7 do
                        scaleFlags.Checked[i] :=
                          UnPackFlag(FJamFile.FEntries[id].FInfo.scaleFlag, i);

        end;
end;

procedure TFormMain.SelectTexture(id: integer; treeupdate: boolean);
var
        wasSelected: integer;
begin

        if id = -1 then
                Exit;

        wasSelected := intSelectedTexture;

        if treeupdate then
        begin
                SelectedTextureList.Clear;
                SelectedTreeNodes.Clear;
        end;

        if not SelectedTextureList.Contains(id) then
                SelectedTextureList.Add(id);

        boolTexSelected := true;

        intSelectedTexture := id;

        // Move-tool "original state" snapshot: record this texture's
        // current position+size when it first becomes the active target
        // in move mode, so Escape can restore it.
        if FMoveToolActive and (not boolRcrJam) and
          (wasSelected <> id) and (not FDrag.Active) then
                CaptureOriginalSelectedState;

        UpdatingFromCode := true;

        UpdateUIData(id);

        DrawTexture;
        RefreshCanvas;

        toolBar_DeleteTexture.Enabled := true;
        toolBar_ImportTexture.Enabled := true;
        toolBar_ExportTexture.Enabled := true;

        mainMenuDeleteTexture.Enabled := boolTexSelected;
        mainMenuImportTexture.Enabled := boolTexSelected;
        mainMenuExportTexture.Enabled := boolTexSelected;
        mainMenuCut.Enabled := boolTexSelected;
        mainMenuCopy.Enabled := boolTexSelected;
        mainMenuModifyPalette.Enabled := boolTexSelected;
        mainMenuTextureProperties.Enabled := boolTexSelected;

        mainMenuPaste.Enabled := boolJamLoaded;

        mainMenuAddTexture.Enabled := boolJamLoaded;

        mainMenuImportCanvas.Enabled := boolJamLoaded;
        mainMenuExportCanvas.Enabled := boolJamLoaded;
        mainMenuExportAllTextures.Enabled := boolJamLoaded;
        popupExportAllTextures.Enabled := boolJamLoaded;
        mainMenuSave.Enabled := boolJamLoaded;
        mainMenuSaveAs.Enabled := boolJamLoaded;
        mainMenuClose.Enabled := boolJamLoaded;

        if SelectFromCanvas = true then
                SelectTreeTex;

        UpdatingFromCode := false;
end;

procedure TFormMain.SelectTreeTex();
var
        N: TTreeNode;
        JNode: TJamTreeNode;
begin
        if (intSelectedTexture < 0) or (JamTree.Items.Count = 0) then
                Exit;

        JamTree.Items.BeginUpdate;
        try
                JamTree.Selected := nil;

                // Collapse all texture nodes first (optional)
                var
                Root := JamTree.Items[1];
                N := Root.getFirstChild;
                while Assigned(N) do
                begin
                        N.Collapse(false);
                        N := N.getNextSibling;
                end;

                // Walk all tree nodes to find a matching jamID node
                N := JamTree.Items.GetFirstNode;
                while Assigned(N) do
                begin
                        if Assigned(N.data) then
                        begin
                                JNode := TJamTreeNode(N.data);
                                if (JNode.nodeType = jamID) and
                                  (JNode.jamID = intSelectedTexture) then
                                begin
                                        JamTree.Selected := N;
                                        N.Expand(false);
                                        N.MakeVisible;
                                        SelectedTreeNodes.Add(N);
                                        Break;
                                end;
                        end;
                        N := N.GetNext;
                end;

        finally
                JamTree.Items.EndUpdate;
        end;
end;

procedure TFormMain.popUpDeleteTextureClick(Sender: TObject);
begin
        DeleteTexture;

end;

procedure TFormMain.DeleteTexture;
var
        JamRects: TArray<TJamRect>;
        i: integer;
begin

        PushUndoState;

        SelectedTextureList.sort;

        if boolHWJAM then
        begin
                for i := SelectedTextureList.Count - 1 downto 0 do
                        FHWJamFile.DeleteTexture(SelectedTextureList[i]);

                if boolJipMode or boolAutoLayout then
                begin
                        FHWJamFile.BuildRect_HW(FHWJamFile, JamRects);
                        PackRects(JamRects, 256, FHWJamFile.canvasHeight);

                        for i := 0 to high(JamRects) do
                        begin

                                begin
                                        FHWJamFile.FEntries[JamRects[i].index]
                                        .FInfo.X := JamRects[i].X;
                                        FHWJamFile.FEntries[JamRects[i].index]
                                        .FInfo.Y := JamRects[i].Y;
                                end;

                        end;
                end;

        end
        else
        begin

                for i := SelectedTextureList.Count - 1 downto 0 do
                        FJamFile.DeleteTexture(SelectedTextureList[i]);

                FJamFile.CalculateImagePtrs;

                if boolJipMode or boolAutoLayout then
                begin
                        FJamFile.BuildRect_SW(FJamFile, JamRects);
                        PackRects(JamRects, 256, FJamFile.canvasHeight);

                        for i := 0 to high(JamRects) do
                        begin

                                begin
                                        FJamFile.FEntries[JamRects[i].index]
                                        .FInfo.X := JamRects[i].X;
                                        FJamFile.FEntries[JamRects[i].index]
                                        .FInfo.Y := JamRects[i].Y;
                                end;

                        end;
                Fjamfile.DrawJIPMipmaps;
                end;

        end;
        DeSelectTexture();

        JamModified(true);

        RefreshPalette;
        RefreshCanvas;
        DrawTree();
end;

procedure TFormMain.DeSelectTexture();
var
        i: integer;

        N: TTreeNode;

begin

        if SelectedTextureList.Count < 0 then
                Exit;

        intSelectedTexture := -1;

        SelectedTextureList.Clear;

        SelectedTreeNodes.Clear;

        RefreshCanvas;

        toolBar_DeleteTexture.Enabled := false;
        toolBar_ImportTexture.Enabled := false;
        toolBar_ExportTexture.Enabled := false;

        ImageEntry.Picture := nil;
        panel_PalPreview.Visible := false;

        UpdatingFromCode := true;

        tex_ID.Enabled := false;
        tex_X.Enabled := false;
        tex_Y.Enabled := false;
        tex_width.Enabled := false;
        tex_height.Enabled := false;

        btnPal0.Enabled := false;
        btnPal1.Enabled := false;
        btnPal2.Enabled := false;
        btnPal3.Enabled := false;

        btnGenPal.Enabled := false;
        btnRemovePal.Enabled := false;

        tex_ID.Value := 0;
        tex_X.Value := 0;
        tex_Y.Value := 0;
        tex_width.Value := 0;
        tex_height.Value := 0;

        for i := 0 to tex_flags.Items.Count - 1 do
                tex_flags.Checked[i] := false;

        texScale.Value := 0;
        texScaleX.Value := 0;
        texScaleY.Value := 0;

        for i := 0 to 7 do
                scaleFlags.Checked[i] := false;

        texScale.Enabled := false;
        texScaleX.Enabled := false;
        texScaleY.Enabled := false;
        scaleFlags.Enabled := false;

        tex_flags.Enabled := false;

        UpdatingFromCode := false;
        boolTexSelected := false;

        mainMenuDeleteTexture.Enabled := boolTexSelected;
        mainMenuImportTexture.Enabled := boolTexSelected;
        mainMenuExportTexture.Enabled := boolTexSelected;
        mainMenuCut.Enabled := boolTexSelected;
        mainMenuCopy.Enabled := boolTexSelected;
        mainMenuModifyPalette.Enabled := boolTexSelected;
        mainMenuTextureProperties.Enabled := boolTexSelected;

        mainMenuPaste.Enabled := boolJamLoaded;

        mainMenuAddTexture.Enabled := boolJamLoaded;

        mainMenuImportCanvas.Enabled := boolJamLoaded;
        mainMenuExportCanvas.Enabled := boolJamLoaded;
        mainMenuExportAllTextures.Enabled := boolJamLoaded;
        popupExportAllTextures.Enabled := boolJamLoaded;
        mainMenuSave.Enabled := boolJamLoaded;
        mainMenuSaveAs.Enabled := boolJamLoaded;
        mainMenuClose.Enabled := boolJamLoaded;

        JamTree.Items.BeginUpdate;
        // JamTree.Selected := nil;

        // Collapse all texture nodes first (optional)
        var
        Root := JamTree.Items[1];
        N := Root.getFirstChild;
        while Assigned(N) do
        begin
                N.Collapse(false);
                N := N.getNextSibling;
        end;

        JamTree.Items.EndUpdate;

end;

procedure TFormMain.UpdateJamData(id: integer);
var
        i: integer;
        changedFlags: array [0 .. 15] of boolean;
        changedScaleFlags: array [0 .. 7] of boolean;
        tempflags: byte;

begin

        if (id < 0) or (boolHWJAM and (id >= FHWJamFile.Entries.Count)) or
          (not boolHWJAM and (id >= FJamFile.Entries.Count)) then
                Exit;

        if boolUndo = true then
                PushUndoState;

        if boolHWJAM then
        begin
                with FHWJamFile.FEntries[id] do
                begin
                        timer_JamRedrawPals.Interval := 90;
                        tempDimensions.X := FInfo.X;
                        tempDimensions.Y := FInfo.Y;
                        tempDimensions.Width := FInfo.Width;
                        tempDimensions.height := FInfo.height;

                        if boolIDChange then
                                FInfo.jamID := tex_ID.Value;
                        if boolXChange then
                                FInfo.X := tex_X.Value;
                        if boolYChange then
                                FInfo.Y := tex_Y.Value;
                        if boolWidthChange then
                                FInfo.Width := tex_width.Value;
                        if boolHeightChange then
                                FInfo.height := tex_height.Value;

                        if boolFlagChange then
                        begin
                                for i := 0 to tex_flags.Items.Count - 1 do
                                        changedFlags[i] := tex_flags.Checked[i]
                                        <> UnPackFlag(FInfo.jamFlags, i);

                                for i := 0 to tex_flags.Items.Count - 1 do
                                        if changedFlags[i] then
                                        if tex_flags.Checked[i] then
                                        FInfo.jamFlags :=
                                        FInfo.jamFlags or (1 shl i)
                                        else
                                        FInfo.jamFlags := FInfo.jamFlags and
                                        not(1 shl i);
                        end;

                end;
        end
        else
        begin
                with FJamFile.FEntries[id] do
                begin
                        timer_JamRedrawPals.Interval := 250;
                        tempDimensions.X := FInfo.X;
                        tempDimensions.Y := FInfo.Y;
                        tempDimensions.Width := FInfo.Width;
                        tempDimensions.height := FInfo.height;

                        if boolIDChange then
                                FInfo.jamID := tex_ID.Value;

                        if boolXChange then
                                if boolRCRJAM then
                                begin
                                        if tempDimensions.Y mod 2 <> 0 then

                                        FInfo.X := tex_X.Value + 256;

                                end
                                else
                                        FInfo.X := tex_X.Value;

                        if boolYChange then
                                if boolRCRJAM then
                                begin

                                        FInfo.Y := tex_Y.Value div 2;

                                end
                                else
                                        FInfo.Y := tex_Y.Value;

                        if boolWidthChange then
                                if boolRCRJAM then
                                begin
                                        FInfo.Width := tex_width.Value * 2;
                                end
                                else
                                        FInfo.Width := tex_width.Value;

                        if boolHeightChange then
                                FInfo.height := tex_height.Value;

                        if boolFlagChange then
                        begin
                                for i := 0 to tex_flags.Items.Count - 1 do
                                        changedFlags[i] := tex_flags.Checked[i]
                                        <> UnPackFlag(FInfo.jamFlags, i);

                                for i := 0 to tex_flags.Items.Count - 1 do
                                        if changedFlags[i] then
                                        if tex_flags.Checked[i] then
                                        FInfo.jamFlags :=
                                        FInfo.jamFlags or (1 shl i)
                                        else
                                        FInfo.jamFlags := FInfo.jamFlags and
                                        not(1 shl i);
                        end;

                        if boolScaleXChange then
                                FInfo.scaleX := texScaleX.Value;

                        if boolScaleYChange then
                                FInfo.scaleY := texScaleY.Value;

                        if boolScaleChange then
                                FInfo.scaleFactor := texScale.Value;
                        // if boolScaleXChange then
                        // FInfo.Idx08 := FJamFile.SetIDX08(texScaleX.Value, fjamfile.GetIDX08_Y(finfo.Idx08));
                        //
                        // if boolScaleYChange then
                        // FInfo.Idx08 := FJamFile.SetIDX08(fjamfile.GetIDX08_X(finfo.Idx08), texScaleY.Value);
                        //
                        // if boolScaleChange then
                        // FInfo.Idx0A := FJamFIle.SetIDX0a(fjamfile.GetIDX0aFlags(info.idx0a), texScale.Value);

                        if boolScaleFlagsChange then
                        begin

                                for i := 0 to 7 do
                                begin
                                        tempflags := Info.scaleFlag;
                                        changedScaleFlags[i] :=
                                        scaleFlags.Checked[i] <>
                                        UnPackFlag(tempflags, i);
                                end;

                                for i := 0 to 7 do
                                        if changedScaleFlags[i] then
                                        if scaleFlags.Checked[i] then
                                        begin
                                        tempflags := Info.scaleFlag;
                                        tempflags := tempflags or (1 shl i);
                                        FInfo.scaleFlag := tempflags;
                                        end
                                        else
                                        begin
                                        tempflags := Info.scaleFlag;
                                        tempflags := tempflags and not(1 shl i);
                                        FInfo.scaleFlag := tempflags;
                                        end;

                        end;

                end;
        end;

        timer_JamRedrawPals.Enabled := false;
        timer_redrawTree.Enabled := false;

        timer_redrawTree.Enabled := true;

        timer_JamRedrawPals.Enabled := true;

        RefreshCanvas;
        JamModified(true);

        boolXChange := false;
        boolYChange := false;
        boolWidthChange := false;
        boolHeightChange := false;

end;

procedure TFormMain.ClearPaletteImg();
begin
        panel_PalPreview.Visible := false;
end;

procedure TFormMain.UpdateCaption();
var
        modText: string;
begin
        Caption := Application.Title;

        if boolJamLoaded then
        begin
                if boolJamModified then
                        modText := '*'
                else
                        modText := '';

                if boolHWJAM then
                        Caption :=
                          Format('%s%s - %s', [FHWJamFile.JamFullPath, modText,
                          Application.Title])
                else
                        Caption :=
                          Format('%s%s - %s', [FJamFile.JamFullPath, modText,
                          Application.Title])
        end;
end;

function TFormMain.JamSanityCheck: boolean;
var
        JamRects: TArray<TJamRect>;
        canvasW, canvasH, X, Y, W, H, JamId, i: integer;
begin

        // Refresh the off-canvas list every call so it tracks the current
        // entry positions.
        if Assigned(OffCanvasList) then
                OffCanvasList.Clear
        else
                OffCanvasList := TList<Integer>.Create;

        if boolHWJAM then
        begin

                FHWJamFile.BuildRect_HW(FHWJamFile, JamRects);
                Result := DetectRectsOverlap(JamRects);

                canvasW := FHWJamFile.canvasWidth;
                canvasH := FHWJamFile.canvasHeight;
                for i := 0 to FHWJamFile.Entries.Count - 1 do
                begin
                        X := FHWJamFile.Entries[i].Info.X;
                        Y := FHWJamFile.Entries[i].Info.Y;
                        W := FHWJamFile.Entries[i].Info.Width;
                        H := FHWJamFile.Entries[i].Info.Height;
                        JamId := FHWJamFile.Entries[i].Info.JamId;
                        if (X < 0) or (Y < 0) or (X + W > canvasW)
                          or (Y + H > canvasH) then
                                OffCanvasList.Add(JamId);
                end;

                boolJamIssues := Result or (OffCanvasList.Count > 0);

        end
        else
        begin

                FJamFile.BuildRect_SW(FJamFile, JamRects);

                Result := DetectRectsOverlap(JamRects);

                canvasW := FJamFile.canvasWidth;
                canvasH := FJamFile.canvasHeight;
                for i := 0 to FJamFile.Entries.Count - 1 do
                begin
                        X := FJamFile.Entries[i].Info.X;
                        Y := FJamFile.Entries[i].Info.Y;
                        W := FJamFile.Entries[i].Info.Width;
                        H := FJamFile.Entries[i].Info.Height;
                        JamId := FJamFile.Entries[i].Info.JamId;
                        if (X < 0) or (Y < 0) or (X + W > canvasW)
                          or (Y + H > canvasH) then
                                OffCanvasList.Add(JamId);
                end;

                boolJamIssues := Result or (OffCanvasList.Count > 0);

        end;

end;

procedure TFormMain.JamSanityCheckInform(onSave: boolean);
var
        errorMessage, intersectPart, offCanvasPart: string;
        X: integer;
        hasIntersects, hasOffCanvas: boolean;
begin

        errorMessage := 'Jam Sanity Check: All clear';

        hasIntersects := Assigned(IntersectList) and (IntersectList.Count > 0);
        hasOffCanvas  := Assigned(OffCanvasList) and (OffCanvasList.Count > 0);

        if onSave then
        begin
                errorMessage := '';

                if hasIntersects then
                begin
                        intersectPart := 'The following textures are intersecting: '
                          + sLineBreak + sLineBreak;
                        for X := 0 to IntersectList.Count - 1 do
                                intersectPart := intersectPart +
                                  IntToStr(IntersectList[X].jamID) + ' ' +
                                  IntToStr(IntersectList[X].intersectID) +
                                  sLineBreak;
                        errorMessage := intersectPart;
                end;

                if hasOffCanvas then
                begin
                        if errorMessage <> '' then
                                errorMessage := errorMessage + sLineBreak;
                        offCanvasPart :=
                          'The following textures are outside the canvas: '
                          + sLineBreak + sLineBreak;
                        for X := 0 to OffCanvasList.Count - 1 do
                                offCanvasPart := offCanvasPart +
                                  IntToStr(OffCanvasList[X]) + sLineBreak;
                        errorMessage := errorMessage + offCanvasPart;
                end;

                if errorMessage <> '' then
                        MessageDlg(errorMessage, mtError, [mbOK], 0);
        end
        else
        begin
                if boolJamIssues then
                begin
                        errorMessage := 'Jam Sanity Check:';

                        if hasIntersects then
                        begin
                                errorMessage := errorMessage + ' Textures';
                                for X := 0 to IntersectList.Count - 1 do
                                        errorMessage := Format('%s %d,',
                                          [errorMessage,
                                          IntersectList[X].jamID]);
                                errorMessage := errorMessage +
                                  ' have intersections.';
                        end;

                        if hasOffCanvas then
                        begin
                                errorMessage := errorMessage + ' Textures';
                                for X := 0 to OffCanvasList.Count - 1 do
                                        errorMessage := Format('%s %d,',
                                          [errorMessage, OffCanvasList[X]]);
                                errorMessage := errorMessage +
                                  ' are outside the canvas.';
                        end;
                end;
        end;

        StatusBar1.Panels[1].Text := errorMessage;
end;

procedure TFormMain.JamModified(modified: boolean);
begin
        boolJamModified := modified;
        if boolJamLoaded then
                UpdateCaption;
end;

end.
