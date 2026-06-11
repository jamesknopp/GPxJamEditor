object aboutForm: TaboutForm
  AlignWithMargins = True
  Left = 0
  Top = 0
  Margins.Left = 0
  Margins.Top = 25
  Margins.Right = 0
  Margins.Bottom = 0
  AlphaBlend = True
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 683
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Padding.Left = 25
  Padding.Top = 10
  Padding.Right = 25
  Padding.Bottom = 10
  Position = poScreenCenter
  PrintScale = poNone
  RoundedCorners = rcSmall
  StyleName = 'Windows'
  TextHeight = 15
  object Label1: TLabel
    Left = 25
    Top = 10
    Width = 568
    Height = 45
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Jam Editor'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    StyleName = 'Windows'
    ExplicitWidth = 148
  end
  object Label2: TLabel
    Left = 25
    Top = 55
    Width = 568
    Height = 15
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Jam Editor for GP2, GP3, GP3 2000 and GP4 JIP files'
    StyleName = 'Windows'
    ExplicitWidth = 266
  end
  object Label3: TLabel
    Left = 25
    Top = 70
    Width = 568
    Height = 540
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    Caption = 
      'This is a development based on initial work by Trevor Kellaway w' +
      'ith GP2JAM, through to Paul Hoad'#39's Jam Editor, which he released' +
      ' as open source.'#13#10#13#10'Jam Editor was further opened up by this and' +
      ' with the GPx Opensource group. Mal Ross developed Jam Editor fu' +
      'rther for GP2 and GP3.'#13#10#13#10'Back in the day, John Verheijen very k' +
      'indly dealt with hosting and coordinating of the open source pro' +
      'jects.'#13#10#13#10'Continued support came from Addie Walti, Ashley Frieze' +
      ', Marc Aarts, Adalberto Zapparoli.'#13#10#13#10'This version is a personal' +
      ' project; I attempted some tools back in-the-day as an enthusias' +
      'tic individual - the results despite my best intentions were not' +
      ' so good. GP4 followed and took one'#39's attention away and any att' +
      'empts to right some significatly wrong code came to nothing and ' +
      'stopped entirely.'#13#10#13#10'It'#39's over 20 years on since I decided to co' +
      'de and given some time over lock-down in COVID and some down-tim' +
      'e due to work drying up, I found myself wanting to go back to th' +
      'e old projects. It turned out, the source code was lost. So this' +
      ' became a full rebuild from scratch whilst forgetting things lik' +
      'e the HW JAM format and the understanding of how the software JA' +
      'Ms effectively dealt with mipmapping/textures at distance.'#13#10#13#10'So' +
      ' what do we have? '#13#10#13#10'- RCR Jam opening'#13#10'- JIP Support'#13#10'- Full e' +
      'diting of GP2/GP3 Jams'#13#10'- Palette editing '#13#10'- Batch Conversion'#13#10 +
      '- JAM Browser'#13#10'- Analysis table - should one want it'#13#10#13#10'Hopefull' +
      'y opening up a bit of additional workflows to edit GP2/GP3, plus' +
      ' now offering live documented code as Open Source.'#13#10#13#10'Enjoy!'#13#10#13#10 +
      '- James Knopp'
    WordWrap = True
    StyleName = 'Windows'
  end
end
