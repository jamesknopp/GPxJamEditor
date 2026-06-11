unit JamRCRAnim;

interface

uses
  System.SysUtils, System.Math, System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Graphics;

type
  TAnimOrdering = (aoByEntryIndex, aoByJamID);
  TAnimAnchor   = (aaCenter, aaFInfoXY, aaTopLeft);

  // Lightweight per-frame record. The owning form keeps a TArray<TFrameRec>
  // and is responsible for freeing Bitmap. Pure logic in this unit treats
  // the bitmap as opaque - it only reads SrcW/SrcH and OrigX/OrigY.
  TFrameRec = record
    Bitmap:   TBitmap;
    JamID:    Word;
    SrcW:     Integer;
    SrcH:     Integer;
    OrigX:    Integer; // copied from FInfo.X at build time
    OrigY:    Integer; // copied from FInfo.Y at build time
    AnchorX:  Integer; // filled by ComputeAnchors
    AnchorY:  Integer; // filled by ComputeAnchors
    SrcEntryIdx: Integer; // index into the source JAM, used by live-render
    IsMirrored:  Boolean; // True for back-half frames in 360 mode
  end;

  // Item used by OrderFrames to express "this source entry produced a
  // frame with this JamID". The form fills one of these per surviving
  // entry, then OrderFrames returns them in playback order.
  TFrameOrderItem = record
    EntryIndex: Integer;
    JamID:      Word;
  end;

// Returns Items reordered per Ordering. Stable: items with equal JamID
// keep their original relative order.
function OrderFrames(const Items: TArray<TFrameOrderItem>;
  Ordering: TAnimOrdering): TArray<TFrameOrderItem>;

// Pure transport step.
//   Cur, Dir          - current logical position; Dir is +1 or -1
//   StartIdx, EndIdx  - playable range, inclusive; StartIdx <= EndIdx
//   Loop, PingPong    - mode flags. PingPong implies Loop (forces wrap behavior).
// Outputs:
//   NewCur, NewDir    - position and direction for the next tick
//   StillPlaying      - False only when (Loop=False and PingPong=False) and
//                       we just advanced past EndIdx; caller should pause timer.
procedure AdvanceFrame(Cur, Dir, StartIdx, EndIdx: Integer;
  Loop, PingPong: Boolean;
  out NewCur, NewDir: Integer; out StillPlaying: Boolean);

// Recomputes per-frame AnchorX/AnchorY and the overall canvas size.
// Reads SrcW/SrcH and (for aaFInfoXY) OrigX/OrigY from each TFrameRec.
// Writes AnchorX/AnchorY back into each TFrameRec.
// Frames is var because the AnchorX/Y fields are mutated in place.
procedure ComputeAnchors(var Frames: TArray<TFrameRec>;
  Anchor: TAnimAnchor;
  out CanvasW, CanvasH: Integer);

implementation

function OrderFrames(const Items: TArray<TFrameOrderItem>;
  Ordering: TAnimOrdering): TArray<TFrameOrderItem>;
var
  i: Integer;
  list: TList<TFrameOrderItem>;
begin
  list := TList<TFrameOrderItem>.Create;
  try
    for i := 0 to High(Items) do list.Add(Items[i]);
    case Ordering of
      aoByEntryIndex:
        list.Sort(TComparer<TFrameOrderItem>.Construct(
          function(const A, B: TFrameOrderItem): Integer
          begin
            Result := A.EntryIndex - B.EntryIndex;
          end));
      aoByJamID:
        list.Sort(TComparer<TFrameOrderItem>.Construct(
          function(const A, B: TFrameOrderItem): Integer
          begin
            Result := Integer(A.JamID) - Integer(B.JamID);
            if Result = 0 then
              Result := A.EntryIndex - B.EntryIndex; // stable tiebreak
          end));
    end;
    Result := list.ToArray;
  finally
    list.Free;
  end;
end;

procedure AdvanceFrame(Cur, Dir, StartIdx, EndIdx: Integer;
  Loop, PingPong: Boolean;
  out NewCur, NewDir: Integer; out StillPlaying: Boolean);
begin
  StillPlaying := True;
  NewDir := Dir;
  if NewDir = 0 then NewDir := 1;

  // Clamp inputs.
  if Cur < StartIdx then Cur := StartIdx;
  if Cur > EndIdx   then Cur := EndIdx;
  if EndIdx < StartIdx then
  begin
    NewCur := Cur;
    Exit;
  end;

  if PingPong then
  begin
    NewCur := Cur + NewDir;
    if NewCur > EndIdx then
    begin
      NewDir := -1;
      NewCur := EndIdx - 1;
      if NewCur < StartIdx then NewCur := StartIdx;
    end
    else if NewCur < StartIdx then
    begin
      NewDir := 1;
      NewCur := StartIdx + 1;
      if NewCur > EndIdx then NewCur := EndIdx;
    end;
    Exit;
  end;

  // Loop or one-shot, no ping-pong.
  NewCur := Cur + NewDir;
  if NewCur > EndIdx then
  begin
    if Loop then NewCur := StartIdx
    else
    begin
      NewCur := EndIdx;
      StillPlaying := False;
    end;
  end
  else if NewCur < StartIdx then
  begin
    // Only reachable via step-back at start.
    if Loop then NewCur := EndIdx
    else
    begin
      NewCur := StartIdx;
      StillPlaying := False;
    end;
  end;
end;

procedure ComputeAnchors(var Frames: TArray<TFrameRec>;
  Anchor: TAnimAnchor;
  out CanvasW, CanvasH: Integer);
var
  i: Integer;
  maxW, maxH: Integer;
  minX, minY, maxRight, maxBottom: Integer;
begin
  CanvasW := 0;
  CanvasH := 0;
  if Length(Frames) = 0 then Exit;

  case Anchor of
    aaCenter, aaTopLeft:
      begin
        maxW := 0; maxH := 0;
        for i := 0 to High(Frames) do
        begin
          if Frames[i].SrcW > maxW then maxW := Frames[i].SrcW;
          if Frames[i].SrcH > maxH then maxH := Frames[i].SrcH;
        end;
        CanvasW := maxW;
        CanvasH := maxH;
        for i := 0 to High(Frames) do
        begin
          if Anchor = aaCenter then
          begin
            Frames[i].AnchorX := (CanvasW - Frames[i].SrcW) div 2;
            Frames[i].AnchorY := (CanvasH - Frames[i].SrcH) div 2;
          end
          else
          begin
            Frames[i].AnchorX := 0;
            Frames[i].AnchorY := 0;
          end;
        end;
      end;
    aaFInfoXY:
      begin
        minX := Frames[0].OrigX;
        minY := Frames[0].OrigY;
        maxRight  := Frames[0].OrigX + Frames[0].SrcW;
        maxBottom := Frames[0].OrigY + Frames[0].SrcH;
        for i := 1 to High(Frames) do
        begin
          if Frames[i].OrigX < minX then minX := Frames[i].OrigX;
          if Frames[i].OrigY < minY then minY := Frames[i].OrigY;
          if Frames[i].OrigX + Frames[i].SrcW > maxRight then
            maxRight := Frames[i].OrigX + Frames[i].SrcW;
          if Frames[i].OrigY + Frames[i].SrcH > maxBottom then
            maxBottom := Frames[i].OrigY + Frames[i].SrcH;
        end;
        CanvasW := maxRight  - minX;
        CanvasH := maxBottom - minY;
        for i := 0 to High(Frames) do
        begin
          Frames[i].AnchorX := Frames[i].OrigX - minX;
          Frames[i].AnchorY := Frames[i].OrigY - minY;
        end;
      end;
  end;
end;

end.
