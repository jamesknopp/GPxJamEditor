# Changelog

## v1.1.1 — Import fixes & palette generation options

### Fixed
- **Range check error when importing textures.** With *Auto Arrange Textures on
  Add & Delete* enabled, adding or deleting a texture in a regular JAM invoked
  the JIP-only mip-strip generation — once per texture — which crashed on
  freshly imported entries and could corrupt the JAM header. Mip strips are now
  generated only for JIP files, once per operation, and the generator itself
  refuses to run outside JIP mode.
- **New JAM files had no canvas width.** `canvasWidth` was only set when
  loading or converting a file, so a newly created SW or HW JAM reported a
  0-wide canvas, breaking bounds checks and canvas drawing.
- **Import Canvas did not feed the new image into the texture entries.**
  For SW JAMs the per-entry raw indices were left stale (so the import
  silently reverted on save or regeneration); for HW JAMs the redrawn crops
  were discarded entirely. Both now rebuild every entry from the imported
  canvas, and the action participates in undo and the modified flag.
- **Import Canvas produced wrong colours on GP2/GP3 paletted JAMs.** The
  imported image is now nearest-matched into the GP2/GP3 palette before its
  indices are read, instead of being quantised against the bitmap's own
  palette.
- Fixed double-frees around palette generation (texture import and
  regenerate), which frees its input bitmap internally.
- **Cut/paste fixes.** Pasting into a HW JAM crashed with a list-index
  error (an uninitialised index was used for the duplicate-JamID check).
  Pasted entries now also update the header item count — previously pasted
  HW textures neither drew nor saved, and a saved SW JAM's header
  undercounted its entries. Cut and paste are now undoable.
- **High-DPI fixes.** Release builds now declare Per-Monitor v2 DPI
  awareness (previously v1, unlike debug builds), so menus, title bars and
  dialogs scale correctly on mixed-DPI monitor setups. Options-dialog
  labels that could clip at 125%/150% display scaling now auto-size or
  have room to grow.

### Added
- **Options → Generate palettes on texture import** and **Generate palettes on
  canvas import** (both on by default, persisted). When enabled, imports build
  per-texture palettes using the palette settings from the main window
  (simplify method, thresholds, transparency protection); when disabled,
  imported pixels are encoded straight against the global GP2/GP3 palette.

## v1.1.0 — File associations, single instance & app icon

- Register .jam / .jip file associations from the Options dialog.
- Single-instance mode: opening a file from Explorer reuses the running
  editor (prompting only when the session has unsaved changes).
- Application icon.

## v1.0.1 — GP3 JIP distance-mipmap fix

- Corrected GP3 JIP distance-mipmap (mip strip) generation.

## v1.0 — Initial public release

- Visual editing of GP2/GP3 JAMs, palette editing, batch conversion.
