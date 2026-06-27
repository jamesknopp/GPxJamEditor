# Jam Editor

A texture editor for the **Grand Prix** series by Geoff Crammond — it works with
Grand Prix 2 and Grand Prix 3 JAM files, plus GP3 and GP4 JIP files.

I decided to make an up-to-date editor because the original Jam Editor source code
is no longer available. Trevor Kellaway's code for decrypting the JAM files formed
the basis — the hardware (HW) JAM format took a bit more digging to get working.

## Features

- **GP2 & GP3 JAM files** — open, view, edit and save both software (SW) and
  hardware (HW) JAMs.
- **GP3 & GP4 JIP files** — view and work with the JIP image format.
- **Batch conversion** — process whole folders of JAMs in one pass.
- **"Proper palette" generation** for SW JAMs.
- **Texture export** — export a single texture, the whole canvas, or every texture
  in a JAM at once, saved as BMPs with pre-filled filenames (`<JamName>_<JamID>.bmp`).
- **Canvas tools** — canvas packing (bin-packing), a move tool, zoom and high-DPI support.
- **RCR (car) JAM viewing** — with experimental sprite rendering.
- **Jam browser** — browse for Jams.

## Building

Built with **Embarcadero Delphi / RAD Studio 12 (Athens)**, target **Win32**.

1. Open `jamviewer.dproj` in the IDE.
2. Choose the **Release / Win32** build configuration.
3. Build (Project → Build).

Both third-party component libraries are **bundled** and already on the project's
search path — nothing extra to install:

- **Virtual TreeView** — `virtualTrees/`
- **MustangPeak EasyListView + Common Library** — `mustangpeak/`

They retain their own MPL 1.1 / LGPL 2.1 licenses (see `NOTICE`). To *edit* the Jam
Browser / Jam Analysis forms in the visual designer you'd also want the MustangPeak
package installed in the IDE, but it isn't needed just to compile.

## Thanks

Trevor Kellaway, Paul Hoad, Mal Ross, John Verheijen, René Smit.

Enjoy!
