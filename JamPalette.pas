unit JamPalette;

interface

uses System.SysUtils, System.Generics.Collections,
  Generics.Defaults, Winapi.Windows, Vcl.Graphics, System.Math,
  GeneralHelpers, JamGeneral, Vcl.dialogs,  System.Threading, System.Classes, System.SyncObjs;


type
  TLab = record
    L, a, b: Double;
  end;

  // Define RGB record and array types
type
  TRGB = record
    R: Byte;
    G: Byte;
    b: Byte;
  end;

  TRGBArray = array [0 .. 255] of TRGB;

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [0 .. MaxInt div SizeOf(TRGBTriple) - 1]
    of TRGBTriple;

  TIndex4 = array [0 .. 3] of Byte; // a 4-tuple of palette indices

type
  TLocalPaletteArray = array [0 .. 3] of TBytes;

  TPaletteEntry = record
    peRed, peGreen, peBlue, peFlags: Byte;
  end;

  TLogPal2 = record
    palVersion: Word;
    palNumEntries: Word;
    palPalEntry: array [0 .. 255] of TPaletteEntry;
  end;

  PLogPal2 = ^TLogPal2;

  TBoolGrid = array of array of Boolean;

  TRGBTripleGrid = array of array of TRGBTriple;

  // Local types used by BuildBmpIdxPal:
  TTupleKey = string; // exactly 4 chars

  // Full 256-color GP2 palette
const
  GP2Pal: array [0 .. 255] of TRGB = ((R: 151; G: 171; b: 127), // Color 0
    (R: 19; G: 19; b: 19), // Color 1
    (R: 27; G: 27; b: 27), // Color 2
    (R: 35; G: 35; b: 35), // Color 3
    (R: 43; G: 43; b: 43), // Color 4
    (R: 51; G: 51; b: 51), // Color 5
    (R: 59; G: 59; b: 59), // Color 6
    (R: 67; G: 67; b: 67), // Color 7
    (R: 75; G: 75; b: 75), // Color 8
    (R: 83; G: 83; b: 83), // Color 9
    (R: 91; G: 91; b: 91), // Color 10
    (R: 99; G: 99; b: 99), // Color 11
    (R: 107; G: 107; b: 107), // Color 12
    (R: 115; G: 115; b: 115), // Color 13
    (R: 123; G: 123; b: 123), // Color 14
    (R: 131; G: 131; b: 131), // Color 15
    (R: 139; G: 139; b: 139), // Color 16
    (R: 147; G: 147; b: 147), // Color 17
    (R: 155; G: 155; b: 155), // Color 18
    (R: 163; G: 163; b: 163), // Color 19
    (R: 167; G: 167; b: 167), // Color 20
    (R: 175; G: 175; b: 175), // Color 21
    (R: 183; G: 183; b: 183), // Color 22
    (R: 191; G: 191; b: 191), // Color 23
    (R: 199; G: 199; b: 199), // Color 24
    (R: 207; G: 207; b: 207), // Color 25
    (R: 215; G: 215; b: 215), // Color 26
    (R: 223; G: 223; b: 223), // Color 27
    (R: 231; G: 231; b: 231), // Color 28
    (R: 239; G: 239; b: 239), // Color 29
    (R: 247; G: 247; b: 247), // Color 30
    (R: 255; G: 255; b: 255), // Color 31
    (R: 75; G: 15; b: 11), // Color 32
    (R: 87; G: 15; b: 11), // Color 33
    (R: 99; G: 19; b: 15), // Color 34
    (R: 107; G: 19; b: 15), // Color 35
    (R: 119; G: 23; b: 19), // Color 36
    (R: 131; G: 27; b: 23), // Color 37
    (R: 143; G: 27; b: 27), // Color 38
    (R: 155; G: 31; b: 31), // Color 39
    (R: 163; G: 35; b: 39), // Color 40
    (R: 175; G: 43; b: 43), // Color 41
    (R: 187; G: 47; b: 51), // Color 42
    (R: 199; G: 51; b: 59), // Color 43
    (R: 211; G: 59; b: 67), // Color 44
    (R: 223; G: 63; b: 75), // Color 45
    (R: 231; G: 71; b: 83), // Color 46
    (R: 243; G: 79; b: 95), // Color 47
    (R: 139; G: 143; b: 7), // Color 48
    (R: 151; G: 151; b: 7), // Color 49
    (R: 159; G: 159; b: 7), // Color 50
    (R: 167; G: 163; b: 7), // Color 51
    (R: 175; G: 167; b: 7), // Color 52
    (R: 179; G: 175; b: 7), // Color 53
    (R: 187; G: 179; b: 7), // Color 54
    (R: 195; G: 183; b: 7), // Color 55
    (R: 203; G: 187; b: 7), // Color 56
    (R: 211; G: 191; b: 7), // Color 57
    (R: 219; G: 199; b: 7), // Color 58
    (R: 227; G: 203; b: 7), // Color 59
    (R: 235; G: 207; b: 7), // Color 60
    (R: 239; G: 211; b: 7), // Color 61
    (R: 247; G: 215; b: 7), // Color 62
    (R: 255; G: 215; b: 7), // Color 63
    (R: 83; G: 15; b: 15), // Color 64
    (R: 91; G: 19; b: 19), // Color 65
    (R: 99; G: 23; b: 23), // Color 66
    (R: 107; G: 27; b: 27), // Color 67
    (R: 115; G: 35; b: 35), // Color 68
    (R: 123; G: 39; b: 39), // Color 69
    (R: 127; G: 47; b: 47), // Color 70
    (R: 135; G: 51; b: 51), // Color 71
    (R: 143; G: 59; b: 59), // Color 72
    (R: 151; G: 67; b: 67), // Color 73
    (R: 159; G: 75; b: 75), // Color 74
    (R: 167; G: 83; b: 83), // Color 75
    (R: 175; G: 91; b: 91), // Color 76
    (R: 183; G: 99; b: 99), // Color 77
    (R: 191; G: 111; b: 111), // Color 78
    (R: 199; G: 119; b: 119), // Color 79
    (R: 203; G: 131; b: 131), // Color 80
    (R: 211; G: 143; b: 143), // Color 81
    (R: 219; G: 151; b: 151), // Color 82
    (R: 227; G: 163; b: 163), // Color 83
    (R: 83; G: 79; b: 59), // Color 84
    (R: 87; G: 87; b: 63), // Color 85
    (R: 95; G: 91; b: 71), // Color 86
    (R: 99; G: 99; b: 75), // Color 87
    (R: 107; G: 103; b: 79), // Color 88
    (R: 111; G: 111; b: 83), // Color 89
    (R: 119; G: 115; b: 91), // Color 90
    (R: 123; G: 123; b: 95), // Color 91
    (R: 131; G: 127; b: 99), // Color 92
    (R: 135; G: 135; b: 103), // Color 93
    (R: 143; G: 139; b: 111), // Color 94
    (R: 147; G: 147; b: 115), // Color 95
    (R: 155; G: 151; b: 119), // Color 96
    (R: 159; G: 159; b: 127), // Color 97
    (R: 167; G: 163; b: 131), // Color 98
    (R: 171; G: 171; b: 135), // Color 99
    (R: 179; G: 175; b: 143), // Color 100
    (R: 183; G: 183; b: 147), // Color 101
    (R: 191; G: 187; b: 155), // Color 102
    (R: 195; G: 195; b: 159), // Color 103
    (R: 63; G: 111; b: 47), // Color 104
    (R: 67; G: 115; b: 51), // Color 105
    (R: 71; G: 119; b: 55), // Color 106
    (R: 75; G: 123; b: 63), // Color 107
    (R: 79; G: 127; b: 67), // Color 108
    (R: 83; G: 131; b: 71), // Color 109
    (R: 87; G: 135; b: 79), // Color 110
    (R: 91; G: 139; b: 83), // Color 111
    (R: 99; G: 143; b: 91), // Color 112
    (R: 103; G: 147; b: 95), // Color 113
    (R: 107; G: 151; b: 103), // Color 114
    (R: 115; G: 155; b: 107), // Color 115
    (R: 119; G: 155; b: 115), // Color 116
    (R: 127; G: 159; b: 123), // Color 117
    (R: 131; G: 163; b: 131), // Color 118
    (R: 139; G: 167; b: 139), // Color 119
    (R: 147; G: 171; b: 147), // Color 120
    (R: 155; G: 175; b: 151), // Color 121
    (R: 163; G: 179; b: 163), // Color 122
    (R: 171; G: 183; b: 171), // Color 123
    (R: 91; G: 123; b: 179), // Color 124
    (R: 95; G: 127; b: 183), // Color 125
    (R: 103; G: 131; b: 187), // Color 126
    (R: 107; G: 135; b: 191), // Color 127
    (R: 111; G: 139; b: 195), // Color 128
    (R: 115; G: 143; b: 199), // Color 129
    (R: 123; G: 147; b: 203), // Color 130
    (R: 127; G: 151; b: 207), // Color 131
    (R: 135; G: 155; b: 211), // Color 132
    (R: 139; G: 159; b: 215), // Color 133
    (R: 147; G: 163; b: 219), // Color 134
    (R: 151; G: 167; b: 223), // Color 135
    (R: 159; G: 171; b: 223), // Color 136
    (R: 163; G: 179; b: 227), // Color 137
    (R: 171; G: 183; b: 231), // Color 138
    (R: 179; G: 187; b: 235), // Color 139
    (R: 183; G: 195; b: 239), // Color 140
    (R: 191; G: 199; b: 243), // Color 141
    (R: 199; G: 203; b: 247), // Color 142
    (R: 203; G: 211; b: 251), // Color 143
    (R: 15; G: 19; b: 83), // Color 144
    (R: 19; G: 23; b: 91), // Color 145
    (R: 23; G: 27; b: 99), // Color 146
    (R: 27; G: 35; b: 107), // Color 147
    (R: 35; G: 39; b: 115), // Color 148
    (R: 39; G: 43; b: 123), // Color 149
    (R: 47; G: 51; b: 127), // Color 150
    (R: 51; G: 55; b: 135), // Color 151
    (R: 59; G: 63; b: 143), // Color 152
    (R: 67; G: 71; b: 151), // Color 153
    (R: 75; G: 79; b: 159), // Color 154
    (R: 83; G: 87; b: 167), // Color 155
    (R: 91; G: 95; b: 175), // Color 156
    (R: 99; G: 103; b: 183), // Color 157
    (R: 111; G: 115; b: 191), // Color 158
    (R: 119; G: 123; b: 199), // Color 159
    (R: 131; G: 135; b: 203), // Color 160
    (R: 143; G: 147; b: 211), // Color 161
    (R: 151; G: 155; b: 219), // Color 162
    (R: 163; G: 167; b: 227), // Color 163
    (R: 47; G: 59; b: 23), // Color 164
    (R: 55; G: 67; b: 27), // Color 165
    (R: 67; G: 75; b: 31), // Color 166
    (R: 75; G: 83; b: 39), // Color 167
    (R: 83; G: 91; b: 43), // Color 168
    (R: 95; G: 99; b: 51), // Color 169
    (R: 103; G: 107; b: 55), // Color 170
    (R: 115; G: 115; b: 63), // Color 171
    (R: 123; G: 123; b: 71), // Color 172
    (R: 131; G: 127; b: 79), // Color 173
    (R: 139; G: 135; b: 87), // Color 174
    (R: 147; G: 139; b: 99), // Color 175
    (R: 83; G: 83; b: 63), // Color 176
    (R: 95; G: 95; b: 75), // Color 177
    (R: 111; G: 107; b: 87), // Color 178
    (R: 127; G: 123; b: 99), // Color 179
    (R: 139; G: 135; b: 111), // Color 180
    (R: 155; G: 147; b: 123), // Color 181
    (R: 167; G: 163; b: 139), // Color 182
    (R: 183; G: 175; b: 151), // Color 183
    (R: 199; G: 187; b: 163), // Color 184
    (R: 211; G: 199; b: 179), // Color 185
    (R: 135; G: 135; b: 127), // Color 186
    (R: 139; G: 139; b: 131), // Color 187
    (R: 143; G: 143; b: 135), // Color 188
    (R: 147; G: 147; b: 143), // Color 189
    (R: 151; G: 147; b: 147), // Color 190
    (R: 151; G: 151; b: 151), // Color 191
    (R: 155; G: 155; b: 155), // Color 192
    (R: 159; G: 159; b: 159), // Color 193
    (R: 31; G: 59; b: 23), // Color 194
    (R: 35; G: 67; b: 23), // Color 195
    (R: 35; G: 71; b: 27), // Color 196
    (R: 39; G: 79; b: 31), // Color 197
    (R: 47; G: 83; b: 35), // Color 198
    (R: 51; G: 87; b: 39), // Color 199
    (R: 55; G: 95; b: 47), // Color 200
    (R: 59; G: 99; b: 51), // Color 201
    (R: 67; G: 103; b: 59), // Color 202
    (R: 71; G: 111; b: 63), // Color 203
    (R: 79; G: 115; b: 71), // Color 204
    (R: 83; G: 119; b: 79), // Color 205
    (R: 91; G: 127; b: 87), // Color 206
    (R: 99; G: 131; b: 95), // Color 207
    (R: 107; G: 135; b: 103), // Color 208
    (R: 115; G: 143; b: 111), // Color 209
    (R: 123; G: 147; b: 123), // Color 210
    (R: 131; G: 151; b: 131), // Color 211
    (R: 143; G: 159; b: 139), // Color 212
    (R: 151; G: 163; b: 151), // Color 213
    (R: 65; G: 90; b: 7), // Color 214
    (R: 68; G: 99; b: 7), // Color 215
    (R: 65; G: 104; b: 11), // Color 216
    (R: 67; G: 105; b: 15), // Color 217
    (R: 73; G: 113; b: 19), // Color 218
    (R: 76; G: 122; b: 23), // Color 219
    (R: 79; G: 129; b: 27), // Color 220
    (R: 82; G: 137; b: 31), // Color 221
    (R: 88; G: 139; b: 35), // Color 222
    (R: 91; G: 147; b: 39), // Color 223
    (R: 97; G: 149; b: 47), // Color 224
    (R: 101; G: 157; b: 51), // Color 225
    (R: 107; G: 160; b: 59), // Color 226
    (R: 115; G: 168; b: 63), // Color 227
    (R: 122; G: 171; b: 71), // Color 228
    (R: 130; G: 180; b: 79), // Color 229
    (R: 136; G: 182; b: 87), // Color 230
    (R: 143; G: 189; b: 95), // Color 231
    (R: 154; G: 196; b: 103), // Color 232
    (R: 161; G: 199; b: 111), // Color 233
    (R: 19; G: 39; b: 147), // Color 234
    (R: 99; G: 127; b: 207), // Color 235
    (R: 143; G: 143; b: 103), // Color 236
    (R: 135; G: 135; b: 95), // Color 237
    (R: 123; G: 119; b: 71), // Color 238
    (R: 51; G: 51; b: 35), // Color 239
    (R: 7; G: 203; b: 0), // Color 240
    (R: 7; G: 115; b: 0), // Color 241
    (R: 255; G: 63; b: 0), // Color 242
    (R: 199; G: 0; b: 0), // Color 243
    (R: 255; G: 167; b: 7), // Color 244
    (R: 219; G: 107; b: 7), // Color 245
    (R: 163; G: 0; b: 163), // Color 246
    (R: 163; G: 0; b: 163), // Color 247
    (R: 163; G: 0; b: 163), // Color 248
    (R: 163; G: 0; b: 163), // Color 249
    (R: 163; G: 0; b: 163), // Color 250
    (R: 163; G: 0; b: 163), // Color 251
    (R: 163; G: 0; b: 163), // Color 252
    (R: 163; G: 0; b: 163), // Color 253
    (R: 163; G: 0; b: 163), // Color 254
    (R: 255; G: 255; b: 255) // Color 255
    );

  GP3Pal: array [0 .. 255] of TRGB = ((R: 63; G: 103; b: 103), // Color 0
    (R: 0; G: 0; b: 0), // Color 1
    (R: 16; G: 16; b: 16), // Color 2
    (R: 24; G: 24; b: 24), // Color 3
    (R: 32; G: 32; b: 32), // Color 4
    (R: 40; G: 40; b: 40), // Color 5
    (R: 48; G: 48; b: 48), // Color 6
    (R: 56; G: 56; b: 56), // Color 7
    (R: 64; G: 64; b: 64), // Color 8
    (R: 72; G: 72; b: 72), // Color 9
    (R: 76; G: 76; b: 76), // Color 10
    (R: 80; G: 80; b: 80), // Color 11
    (R: 84; G: 84; b: 84), // Color 12
    (R: 88; G: 88; b: 88), // Color 13
    (R: 92; G: 92; b: 92), // Color 14
    (R: 96; G: 96; b: 96), // Color 15
    (R: 100; G: 100; b: 100), // Color 16
    (R: 104; G: 104; b: 104), // Color 17
    (R: 108; G: 108; b: 108), // Color 18
    (R: 112; G: 112; b: 112), // Color 19
    (R: 116; G: 116; b: 116), // Color 20
    (R: 120; G: 120; b: 120), // Color 21
    (R: 124; G: 124; b: 124), // Color 22
    (R: 128; G: 128; b: 128), // Color 23
    (R: 132; G: 132; b: 132), // Color 24
    (R: 140; G: 140; b: 140), // Color 25
    (R: 148; G: 148; b: 148), // Color 26
    (R: 156; G: 156; b: 156), // Color 27
    (R: 164; G: 164; b: 164), // Color 28
    (R: 172; G: 172; b: 172), // Color 29
    (R: 180; G: 180; b: 180), // Color 30
    (R: 188; G: 188; b: 188), // Color 31
    (R: 196; G: 196; b: 196), // Color 32
    (R: 204; G: 204; b: 204), // Color 33
    (R: 212; G: 212; b: 212), // Color 34
    (R: 220; G: 220; b: 220), // Color 35
    (R: 228; G: 228; b: 228), // Color 36
    (R: 236; G: 236; b: 236), // Color 37
    (R: 244; G: 244; b: 244), // Color 38
    (R: 252; G: 252; b: 252), // Color 39
    (R: 64; G: 64; b: 48), // Color 40
    (R: 85; G: 84; b: 65), // Color 41
    (R: 105; G: 103; b: 82), // Color 42
    (R: 126; G: 122; b: 99), // Color 43
    (R: 146; G: 141; b: 118), // Color 44
    (R: 167; G: 160; b: 136), // Color 45
    (R: 187; G: 178; b: 156), // Color 46
    (R: 208; G: 197; b: 175), // Color 47
    (R: 60; G: 9; b: 4), // Color 48
    (R: 72; G: 10; b: 5), // Color 49
    (R: 84; G: 11; b: 6), // Color 50
    (R: 96; G: 12; b: 7), // Color 51
    (R: 108; G: 13; b: 9), // Color 52
    (R: 120; G: 13; b: 10), // Color 53
    (R: 132; G: 14; b: 12), // Color 54
    (R: 144; G: 14; b: 13), // Color 55
    (R: 156; G: 15; b: 16), // Color 56
    (R: 168; G: 17; b: 20), // Color 57
    (R: 180; G: 19; b: 24), // Color 58
    (R: 192; G: 21; b: 28), // Color 59
    (R: 204; G: 23; b: 33), // Color 60
    (R: 216; G: 25; b: 38), // Color 61
    (R: 228; G: 27; b: 44), // Color 62
    (R: 240; G: 30; b: 49), // Color 63
    (R: 81; G: 84; b: 1), // Color 64
    (R: 93; G: 95; b: 2), // Color 65
    (R: 105; G: 106; b: 3), // Color 66
    (R: 117; G: 118; b: 4), // Color 67
    (R: 129; G: 128; b: 6), // Color 68
    (R: 140; G: 138; b: 7), // Color 69
    (R: 151; G: 148; b: 9), // Color 70
    (R: 162; G: 157; b: 11), // Color 71
    (R: 174; G: 167; b: 13), // Color 72
    (R: 185; G: 176; b: 15), // Color 73
    (R: 196; G: 185; b: 17), // Color 74
    (R: 207; G: 194; b: 20), // Color 75
    (R: 218; G: 202; b: 22), // Color 76
    (R: 229; G: 211; b: 25), // Color 77
    (R: 241; G: 219; b: 28), // Color 78
    (R: 252; G: 228; b: 31), // Color 79
    (R: 55; G: 108; b: 22), // Color 80
    (R: 62; G: 115; b: 26), // Color 81
    (R: 69; G: 122; b: 31), // Color 82
    (R: 77; G: 129; b: 36), // Color 83
    (R: 85; G: 135; b: 41), // Color 84
    (R: 93; G: 142; b: 46), // Color 85
    (R: 101; G: 149; b: 52), // Color 86
    (R: 109; G: 156; b: 58), // Color 87
    (R: 104; G: 69; b: 50), // Color 88
    (R: 122; G: 84; b: 61), // Color 89
    (R: 139; G: 99; b: 72), // Color 90
    (R: 157; G: 115; b: 83), // Color 91
    (R: 175; G: 131; b: 96), // Color 92
    (R: 193; G: 148; b: 108), // Color 93
    (R: 210; G: 165; b: 122), // Color 94
    (R: 228; G: 183; b: 135), // Color 95
    (R: 9; G: 13; b: 72), // Color 96
    (R: 13; G: 19; b: 82), // Color 97
    (R: 17; G: 25; b: 92), // Color 98
    (R: 22; G: 33; b: 102), // Color 99
    (R: 28; G: 41; b: 113), // Color 100
    (R: 34; G: 50; b: 123), // Color 101
    (R: 41; G: 60; b: 133), // Color 102
    (R: 49; G: 70; b: 143), // Color 103
    (R: 57; G: 81; b: 153), // Color 104
    (R: 66; G: 93; b: 163), // Color 105
    (R: 76; G: 105; b: 173), // Color 106
    (R: 86; G: 117; b: 183), // Color 107
    (R: 97; G: 130; b: 194), // Color 108
    (R: 108; G: 143; b: 204), // Color 109
    (R: 120; G: 157; b: 214), // Color 110
    (R: 133; G: 171; b: 224), // Color 111
    (R: 137; G: 173; b: 224), // Color 112
    (R: 140; G: 175; b: 224), // Color 113
    (R: 144; G: 177; b: 224), // Color 114
    (R: 147; G: 179; b: 224), // Color 115
    (R: 151; G: 181; b: 224), // Color 116
    (R: 155; G: 183; b: 224), // Color 117
    (R: 158; G: 186; b: 224), // Color 118
    (R: 162; G: 188; b: 224), // Color 119
    (R: 166; G: 190; b: 224), // Color 120
    (R: 169; G: 192; b: 224), // Color 121
    (R: 173; G: 194; b: 224), // Color 122
    (R: 177; G: 196; b: 224), // Color 123
    (R: 180; G: 198; b: 224), // Color 124
    (R: 184; G: 201; b: 224), // Color 125
    (R: 188; G: 203; b: 224), // Color 126
    (R: 191; G: 205; b: 224), // Color 127
    (R: 195; G: 207; b: 224), // Color 128
    (R: 199; G: 209; b: 224), // Color 129
    (R: 202; G: 211; b: 224), // Color 130
    (R: 206; G: 213; b: 224), // Color 131
    (R: 210; G: 216; b: 224), // Color 132
    (R: 213; G: 218; b: 224), // Color 133
    (R: 217; G: 220; b: 224), // Color 134
    (R: 220; G: 222; b: 224), // Color 135
    (R: 14; G: 24; b: 21), // Color 136
    (R: 20; G: 38; b: 31), // Color 137
    (R: 24; G: 51; b: 40), // Color 138
    (R: 27; G: 65; b: 45), // Color 139
    (R: 28; G: 79; b: 48), // Color 140
    (R: 28; G: 93; b: 48), // Color 141
    (R: 26; G: 106; b: 44), // Color 142
    (R: 22; G: 120; b: 35), // Color 143
    (R: 38; G: 56; b: 26), // Color 144
    (R: 51; G: 81; b: 30), // Color 145
    (R: 60; G: 107; b: 28), // Color 146
    (R: 66; G: 132; b: 21), // Color 147
    (R: 12; G: 20; b: 12), // Color 148
    (R: 27; G: 51; b: 26), // Color 149
    (R: 37; G: 81; b: 37), // Color 150
    (R: 44; G: 112; b: 46), // Color 151
    (R: 44; G: 72; b: 17), // Color 152
    (R: 57; G: 94; b: 31), // Color 153
    (R: 71; G: 115; b: 49), // Color 154
    (R: 88; G: 137; b: 71), // Color 155
    (R: 108; G: 158; b: 97), // Color 156
    (R: 132; G: 180; b: 127), // Color 157
    (R: 40; G: 60; b: 26), // Color 158
    (R: 51; G: 75; b: 36), // Color 159
    (R: 63; G: 89; b: 47), // Color 160
    (R: 76; G: 104; b: 60), // Color 161
    (R: 139; G: 160; b: 105), // Color 162
    (R: 152; G: 168; b: 118), // Color 163
    (R: 165; G: 176; b: 132), // Color 164
    (R: 178; G: 184; b: 147), // Color 165
    (R: 189; G: 192; b: 162), // Color 166
    (R: 199; G: 200; b: 178), // Color 167
    (R: 81; G: 26; b: 20), // Color 168
    (R: 100; G: 30; b: 26), // Color 169
    (R: 119; G: 35; b: 32), // Color 170
    (R: 138; G: 39; b: 38), // Color 171
    (R: 158; G: 44; b: 45), // Color 172
    (R: 177; G: 50; b: 55), // Color 173
    (R: 196; G: 57; b: 66), // Color 174
    (R: 215; G: 64; b: 77), // Color 175
    (R: 98; G: 100; b: 21), // Color 176
    (R: 117; G: 118; b: 27), // Color 177
    (R: 135; G: 134; b: 32), // Color 178
    (R: 153; G: 150; b: 38), // Color 179
    (R: 171; G: 165; b: 45), // Color 180
    (R: 189; G: 180; b: 52), // Color 181
    (R: 207; G: 194; b: 59), // Color 182
    (R: 225; G: 208; b: 67), // Color 183
    (R: 72; G: 117; b: 44), // Color 184
    (R: 85; G: 128; b: 53), // Color 185
    (R: 99; G: 139; b: 63), // Color 186
    (R: 113; G: 150; b: 74), // Color 187
    (R: 118; G: 88; b: 70), // Color 188
    (R: 147; G: 114; b: 91), // Color 189
    (R: 175; G: 141; b: 113), // Color 190
    (R: 203; G: 170; b: 136), // Color 191
    (R: 28; G: 33; b: 90), // Color 192
    (R: 38; G: 47; b: 106), // Color 193
    (R: 50; G: 62; b: 122), // Color 194
    (R: 64; G: 80; b: 138), // Color 195
    (R: 79; G: 99; b: 154), // Color 196
    (R: 96; G: 119; b: 171), // Color 197
    (R: 114; G: 140; b: 187), // Color 198
    (R: 135; G: 162; b: 203), // Color 199
    (R: 103; G: 50; b: 45), // Color 200
    (R: 132; G: 61; b: 59), // Color 201
    (R: 160; G: 74; b: 76), // Color 202
    (R: 189; G: 89; b: 97), // Color 203
    (R: 115; G: 116; b: 48), // Color 204
    (R: 143; G: 142; b: 62), // Color 205
    (R: 170; G: 165; b: 77), // Color 206
    (R: 197; G: 187; b: 92), // Color 207
    (R: 93; G: 127; b: 69), // Color 208
    (R: 115; G: 143; b: 86), // Color 209
    (R: 134; G: 110; b: 95), // Color 210
    (R: 177; G: 153; b: 131), // Color 211
    (R: 54; G: 60; b: 108), // Color 212
    (R: 77; G: 87; b: 133), // Color 213
    (R: 102; G: 118; b: 157), // Color 214
    (R: 132; G: 151; b: 181), // Color 215
    (R: 115; G: 76; b: 72), // Color 216
    (R: 134; G: 86; b: 85), // Color 217
    (R: 154; G: 98; b: 100), // Color 218
    (R: 173; G: 112; b: 116), // Color 219
    (R: 123; G: 124; b: 76), // Color 220
    (R: 142; G: 141; b: 88), // Color 221
    (R: 160; G: 157; b: 101), // Color 222
    (R: 178; G: 172; b: 115), // Color 223
    (R: 108; G: 131; b: 91), // Color 224
    (R: 123; G: 142; b: 105), // Color 225
    (R: 136; G: 120; b: 109), // Color 226
    (R: 165; G: 150; b: 136), // Color 227
    (R: 79; G: 83; b: 119), // Color 228
    (R: 97; G: 104; b: 135), // Color 229
    (R: 116; G: 126; b: 151), // Color 230
    (R: 137; G: 149; b: 167), // Color 231
    (R: 132; G: 109; b: 108), // Color 232
    (R: 152; G: 125; b: 126), // Color 233
    (R: 137; G: 137; b: 110), // Color 234
    (R: 155; G: 152; b: 127), // Color 235
    (R: 128; G: 138; b: 119), // Color 236
    (R: 145; G: 138; b: 132), // Color 237
    (R: 113; G: 116; b: 133), // Color 238
    (R: 134; G: 139; b: 150), // Color 239
    (R: 72; G: 72; b: 35), // Color 240
    (R: 88; G: 88; b: 43), // Color 241
    (R: 252; G: 59; b: 0), // Color 242
    (R: 176; G: 0; b: 0), // Color 243
    (R: 252; G: 207; b: 0), // Color 244
    (R: 216; G: 97; b: 10), // Color 245
    (R: 23; G: 43; b: 148), // Color 246
    (R: 99; G: 128; b: 204), // Color 247
    (R: 140; G: 140; b: 98), // Color 248
    (R: 132; G: 132; b: 93), // Color 249
    (R: 120; G: 114; b: 69), // Color 250
    (R: 92; G: 100; b: 48), // Color 251
    (R: 7; G: 208; b: 0), // Color 252
    (R: 4; G: 140; b: 0), // Color 253
    (R: 159; G: 0; b: 160), // Color 254
    (R: 255; G: 255; b: 255) // Color 255
    );

  PAL_MAX_CUSTOM_INDEX = 192;

var

  GPXPal: array [0 .. 255] of TRGB;
  LocalGpxPal: array [0 .. 255] of TRGB;
  tmpPal: array [0 .. 255] of TRGB;

  HPalettePerLevel: array [0 .. 3] of HPalette;

type
  TThreadExceptionList = class
  private
    FList: TList<string>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Msg: string);
    function HasErrors: Boolean;
    function GetAll: string;
  end;


function CreateGPxPal: HPalette;

function CreateLocalPalette(localPal: array of TRGB): HPalette;

function RGBFromTRGB(const C: TRGB): TColor;

function BitmapToIndices(const bmp: TBitmap): TBytes;

function FindGPxCol(const Palette: array of TRGB; const Color: TRGB): Integer;

function NearestPaletteEntryRGB(C: TRGB): TColor;

function NearestPaletteEntry(matchRGB: TRGB): Byte;

procedure GaussianBlur(const Src: TBitmap; const Mask: TBoolGrid;
  UserBlurValue: Integer; out OutImg: TBitmap);

procedure IndexedTo24bit(const SrcIndexed: TBitmap; out Out24: TBitmap);

function CreateGPxPalBMP(Src: TBitmap): TBitmap overload;

function CreateGPxPalBMP(Src: TBitmap; matte: TBitmap): TBitmap overload;

function BuildSingleIdxMap(const bmp: TBitmap): TBitmap;

procedure SimplifyByNeighborThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);

procedure BuildBmpIdxPal(const LevelsIdx: array of TBitmap;
  out SingleIdx: TBitmap; out PalPerLevel: array of TArray<TColor>);

procedure BuildGPxMatteMask(const Src: TBitmap;
  const TransColors: array of TColor; out Mask: TBoolGrid);

procedure BuildMaskFromBMP(const Src: TBitmap; out Mask: TBoolGrid);

procedure QuadtreeSimplify(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);

procedure ProcessQuad(const SrcGrid: TRGBTripleGrid;
  var DstGrid: TRGBTripleGrid; X0, Y0, X1, Y1: Integer; Thresh2: Double);

procedure SimplifyByRegionMeanThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);

procedure SimplifyBySeedThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);

function ApplyMatteToImage(Resized: TBitmap; matte: TBitmap;
  const TransparentColor: TColor): TBitmap;

function resizeTransProtection(Source: TBitmap; NewWidth, NewHeight: Integer;
  const TransparentColor: TColor): TBitmap;

function DrawBitToBmp(const values: array of Byte;
  width, height: Integer): TBitmap;

procedure BleedEdges(var bmp: TBitmap; const matte: TBitmap;
  const TransparentColor: TColor; Iterations: Integer = 4);

function IndexedToIndexRGB(const Src: TBitmap): TBitmap;

procedure BoxBlurV_MT_SIMD(const Src, Dst: TBitmap; Radius: Integer);
procedure BoxBlurH_MT_SIMD(const Src, Dst: TBitmap; Radius: Integer);

function FastBoxBlur_MT_SIMD(Bitmap: TBitmap; RadiusX, RadiusY: Integer) : TBitmap;

implementation

constructor TThreadExceptionList.Create;
begin
  FList := TList<string>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TThreadExceptionList.Destroy;
begin
  FList.Free;
  FLock.Free;
  inherited;
end;

procedure TThreadExceptionList.Add(const Msg: string);
begin
  FLock.Acquire;
  try
    FList.Add(Msg);
  finally
    FLock.Release;
  end;
end;

function TThreadExceptionList.HasErrors: Boolean;
begin
  Result := FList.Count > 0;
end;

function TThreadExceptionList.GetAll: string;
begin
  FLock.Acquire;
  try
    Result := string.Join(sLineBreak, FList.ToArray);
  finally
    FLock.Release;
  end;
end;

function IndexedToIndexRGB(const Src: TBitmap): TBitmap;
var
  X, Y: Integer;
  SrcRow: PByteArray;
  DstRow: PRGBTripleArray;
  Idx: Byte;
begin
  Result := TBitmap.Create;
  try
    if Src.PixelFormat <> pf8bit then
      raise Exception.Create('Source bitmap must be pf8bit');

    Result.PixelFormat := pf24bit;
    Result.SetSize(Src.width, Src.height);

    for Y := 0 to Src.height - 1 do
    begin
      SrcRow := Src.ScanLine[Y];
      DstRow := Result.ScanLine[Y];

      for X := 0 to Src.width - 1 do
      begin
        Idx := SrcRow[X];

        DstRow[X].rgbtRed := Idx;
        DstRow[X].rgbtGreen := Idx;
        DstRow[X].rgbtBlue := Idx;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function FindGPxCol(const Palette: array of TRGB; const Color: TRGB): Integer;
var
  i: Integer;
begin
  for i := 0 to High(Palette) do
  begin
    if (Palette[i].R = Color.R) and (Palette[i].G = Color.G) and
      (Palette[i].b = Color.b) then
    begin
      Exit(i); // Match found
    end;
  end;
  Result := -1; // Not found
end;

function CreateGPxPal: HPalette;
var
  i: Integer;
  LogPal: TMaxLogPalette;
begin
  FillChar(LogPal, SizeOf(LogPal), 0);
  LogPal.palVersion := $300;
  LogPal.palNumEntries := 256;

  for i := 0 to 255 do
  begin
    if i < Length(GPXPal) then
    begin
      LogPal.palPalEntry[i].peRed := GPXPal[i].R;
      LogPal.palPalEntry[i].peGreen := GPXPal[i].G;
      LogPal.palPalEntry[i].peBlue := GPXPal[i].b;
    end
    else
    begin
      LogPal.palPalEntry[i].peRed := i;
      LogPal.palPalEntry[i].peGreen := i;
      LogPal.palPalEntry[i].peBlue := i;
    end;
    LogPal.palPalEntry[i].peFlags := 0;
  end;

  Result := CreatePalette(PLogPalette(@LogPal)^);

end;

function CreateLocalPalette(localPal: array of TRGB): HPalette;
var
  i: Integer;
  LogPal: TMaxLogPalette;
begin
  FillChar(LogPal, SizeOf(LogPal), 0);
  LogPal.palVersion := $300;
  LogPal.palNumEntries := 256;

  for i := 0 to 255 do
  begin
    begin
      LogPal.palPalEntry[i].peRed := localPal[i].R;
      LogPal.palPalEntry[i].peGreen := localPal[i].G;
      LogPal.palPalEntry[i].peBlue := localPal[i].b;
    end;
    LogPal.palPalEntry[i].peFlags := 0;
  end;

  Result := CreatePalette(PLogPalette(@LogPal)^);

end;

function RGBFromTRGB(const C: TRGB): TColor;
begin
  Result := RGB(C.R, C.G, C.b);
end;

function NearestPaletteEntry(matchRGB: TRGB): Byte;
var
  i: Integer;
  bestIndex: Integer;
  dMin, d: Cardinal;
  dr, dg, db: Integer;
begin
  dMin := High(Cardinal);
  bestIndex := 0;

  for i := 0 to 255 do
  begin
    dr := Integer(matchRGB.R) - GPXPal[i].R;
    dg := Integer(matchRGB.G) - GPXPal[i].G;
    db := Integer(matchRGB.b) - GPXPal[i].b;

    d := Cardinal(dr * dr + dg * dg + db * db);

    if d < dMin then
    begin
      dMin := d;
      bestIndex := i;
    end;
  end;

  Result := Byte(bestIndex);
end;

function NearestPaletteEntryRGB(C: TRGB): TColor;
var
  bestDist, d: Cardinal;
  dr, dg, db: Integer;
  i: Integer;
begin
  bestDist := High(Cardinal);

  for i := 0 to 255 do
  begin
    dr := Integer(C.R) - GPXPal[i].R;
    dg := Integer(C.G) - GPXPal[i].G;
    db := Integer(C.b) - GPXPal[i].b;

    // squared Euclidean distance in RGB space
    d := Cardinal(dr * dr + dg * dg + db * db);
    if d < bestDist then
    begin
      bestDist := d;
      Result := RGB(GPXPal[i].R, GPXPal[i].G, GPXPal[i].b);
    end;
  end;

end;

function BitmapToIndices(const bmp: TBitmap): TBytes;
var
  W, H, Y: Integer;
  rowPtr: PByte;
begin
  // Ensure it's an 8-bit indexed bitmap
  bmp.PixelFormat := pf8bit;

  W := bmp.width;
  H := bmp.height;
  SetLength(Result, W * H);

  // Each ScanLine[y] points to one padded DIB row.
  // We only copy the first W bytes (the pixel indices).
  for Y := 0 to H - 1 do
  begin
    rowPtr := bmp.ScanLine[Y];
    Move(rowPtr^, Result[Y * W], W);
  end;
end;

// ------------------------------------------------------------------------------
// IndexedTo24bit: expand an 8bit‐indexed TBitmap → 24bit by reading its Palette[]
// ------------------------------------------------------------------------------
procedure IndexedTo24bit(const SrcIndexed: TBitmap; out Out24: TBitmap);
var
  X, Y: Integer;
  RowSrc: PByteArray;
  RowDst: PRGBTripleArray;
  PalEntries: array [0 .. 255] of TPaletteEntry;
  hPal: HPalette;
begin
  Assert(SrcIndexed.PixelFormat = pf8bit);
  hPal := SrcIndexed.Palette;
  if hPal = 0 then
    Exit;

  Out24 := TBitmap.Create;
  Out24.PixelFormat := pf24bit;
  Out24.width := SrcIndexed.width;
  Out24.height := SrcIndexed.height;
  GetPaletteEntries(hPal, 0, 256, PalEntries[0]);

  for Y := 0 to SrcIndexed.height - 1 do
  begin
    RowSrc := SrcIndexed.ScanLine[Y];
    RowDst := Out24.ScanLine[Y];
    for X := 0 to SrcIndexed.width - 1 do
    begin
      RowDst^[X].rgbtRed := PalEntries[RowSrc^[X]].peRed;
      RowDst^[X].rgbtGreen := PalEntries[RowSrc^[X]].peGreen;
      RowDst^[X].rgbtBlue := PalEntries[RowSrc^[X]].peBlue;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// QuantizeToPalette24bit: brute‐force map each pixel in Src (24bit) to nearest in GP3PalColors → OutIndexed (8bit).
// ------------------------------------------------------------------------------
function CreateGPxPalBMP(Src: TBitmap): TBitmap;
var
  X, Y, i, bestIndex: Integer;
  PalR, PalG, PalB: array [0 .. 255] of Byte;
  Dist, bestDist: Int64;
  RowSrc: PRGBTripleArray;
  RowDst: PByteArray;
  dr, dg, db: Integer;
  Dst: TBitmap;
begin
  // Prepare destination
  Dst := TBitmap.Create;
  Src.PixelFormat := pf24bit;
  // force input to be 24bit so scanline processes work correctly
  try
    Dst.PixelFormat := pf8bit;
    Dst.width := Src.width;
    Dst.height := Src.height;
    Dst.Palette := CreateGPxPal;

    // Cache palette RGB
    for i := 0 to 255 do
    begin
      PalR[i] := GPXPal[i].R;
      PalG[i] := GPXPal[i].G;
      PalB[i] := GPXPal[i].b;
    end;

    // Single scanline pass
    for Y := 0 to Src.height - 1 do
    begin
      RowSrc := Src.ScanLine[Y];
      RowDst := Dst.ScanLine[Y];
      for X := 0 to Src.width - 1 do
      begin
        bestDist := High(Int64);
        bestIndex := 0;
        dr := RowSrc^[X].rgbtRed;
        dg := RowSrc^[X].rgbtGreen;
        db := RowSrc^[X].rgbtBlue;
        for i := 0 to 255 do
        begin
          Dist := Int64(dr - PalR[i]) * (dr - PalR[i]) + Int64(dg - PalG[i]) *
            (dg - PalG[i]) + Int64(db - PalB[i]) * (db - PalB[i]);
          if Dist < bestDist then
          begin
            bestDist := Dist;
            bestIndex := i;
          end;
        end;
        RowDst^[X] := Byte(bestIndex);
      end;
    end;

    Result := Dst;
  except
    Dst.Free;
    raise;
  end;
end;

function CreateGPxPalBMP(Src: TBitmap; matte: TBitmap): TBitmap;
var
  X, Y, i, bestIndex: Integer;
  PalR, PalG, PalB: array [0 .. 255] of Byte;
  Dist, bestDist: Int64;
  RowSrc, matteRow: PRGBTripleArray;
  RowDst: PByteArray;
  dr, dg, db: Integer;

  Dst: TBitmap;

begin
  // Prepare destination
  Dst := TBitmap.Create;

  try
    Dst.PixelFormat := pf8bit;
    Dst.width := Src.width;
    Dst.height := Src.height;
    Dst.Palette := CreateGPxPal;

    // Cache palette RGB
    for i := 0 to 255 do
    begin
      PalR[i] := GPXPal[i].R;
      PalG[i] := GPXPal[i].G;
      PalB[i] := GPXPal[i].b;
    end;

    // Single scanline pass
    for Y := 0 to Src.height - 1 do
    begin
      RowSrc := Src.ScanLine[Y];
      RowDst := Dst.ScanLine[Y];
      matteRow := matte.ScanLine[Y];
      for X := 0 to Src.width - 1 do
      begin
        bestDist := High(Int64);
        bestIndex := 0;
        dr := RowSrc^[X].rgbtRed;
        dg := RowSrc^[X].rgbtGreen;
        db := RowSrc^[X].rgbtBlue;

        for i := 1 to 253 do
        begin
          Dist := Int64(dr - PalR[i]) * (dr - PalR[i]) + Int64(dg - PalG[i]) *
            (dg - PalG[i]) + Int64(db - PalB[i]) * (db - PalB[i]);
          if Dist < bestDist then
          begin
            bestDist := Dist;
            bestIndex := i;
            if bestIndex = 255 then
              bestIndex := 39;
            if bestIndex = 254 then
              bestIndex := 0;
            if bestIndex = 0 then
              bestIndex := 195;
          end;
        end;

        if matteRow^[X].rgbtRed = 255 then
        begin
          bestIndex := 0;
        end;

        RowDst^[X] := Byte(bestIndex);
      end;
    end;

    // dst := ApplyMatteToImage(dst, matte, RGBFromTRGB(gpxPal[0]));

    Result := Dst;
  except
    Dst.Free;
    raise;
  end;
end;

procedure GaussianBlur(const Src: TBitmap; const Mask: TBoolGrid;
  UserBlurValue: Integer; out OutImg: TBitmap);

  function EnsureRange(Value, MinVal, MaxVal: Integer): Integer;
  begin
    if Value < MinVal then
      Result := MinVal
    else if Value > MaxVal then
      Result := MaxVal
    else
      Result := Value;
  end;

var
  Sigma: Double;
  Radius, KernelSize: Integer;
  Kernel: TArray<Double>;
  SumKernel, UsedKernelSum: Double;
  W, H, X, Y, i, iOff, Y2, V: Integer;
  RowSrc, RowTmp, RowOut: PRGBTripleArray;
  TempLines: array of PRGBTripleArray;
  dAccR, dAccG, dAccB: Double;
  Tmp: TBitmap;
begin
  Assert(Src.PixelFormat = pf24bit);

  W := Src.width;
  H := Src.height;

  // Map UserBlurValue (1..10) to sigma range 1.0 to 3.0
  UserBlurValue := EnsureRange(UserBlurValue, 1, 10);
  Sigma := 1.0 + (UserBlurValue - 1) * (2.0 / 9.0); // Linear map to 1.0..3.0
  Sigma := Sigma * 0.5;
  Radius := Ceil(2 * Sigma); // Covers 99% of Gaussian area
  KernelSize := 2 * Radius + 1;
  SetLength(Kernel, KernelSize);

  // Build normalized 1D Gaussian kernel
  SumKernel := 0.0;
  for i := -Radius to Radius do
  begin
    Kernel[i + Radius] := Exp(-(i * i) / (2.0 * Sqr(Sigma)));
    SumKernel := SumKernel + Kernel[i + Radius];
  end;

  for i := 0 to KernelSize - 1 do
    Kernel[i] := Kernel[i] / SumKernel;

  // --- Horizontal Pass ---
  Tmp := TBitmap.Create;
  try
    Tmp.PixelFormat := pf24bit;
    Tmp.SetSize(W, H);

    for Y := 0 to H - 1 do
    begin
      RowSrc := Src.ScanLine[Y];
      RowTmp := Tmp.ScanLine[Y];

      for X := 0 to W - 1 do
      begin
        if Mask[Y][X] then
        begin
          RowTmp^[X] := RowSrc^[X];
          Continue;
        end;

        dAccR := 0.0;
        dAccG := 0.0;
        dAccB := 0.0;
        UsedKernelSum := 0.0;

        for i := -Radius to Radius do
        begin
          iOff := X + i;
          if iOff < 0 then
            iOff := 0
          else if iOff >= W then
            iOff := W - 1;

          if not Mask[Y][iOff] then
          begin
            dAccR := dAccR + RowSrc^[iOff].rgbtRed * Kernel[i + Radius];
            dAccG := dAccG + RowSrc^[iOff].rgbtGreen * Kernel[i + Radius];
            dAccB := dAccB + RowSrc^[iOff].rgbtBlue * Kernel[i + Radius];
            UsedKernelSum := UsedKernelSum + Kernel[i + Radius];
          end;
        end;

        if UsedKernelSum > 0 then
        begin
          V := Round(dAccR / UsedKernelSum);
          RowTmp^[X].rgbtRed := EnsureRange(V, 0, 255);
          V := Round(dAccG / UsedKernelSum);
          RowTmp^[X].rgbtGreen := EnsureRange(V, 0, 255);
          V := Round(dAccB / UsedKernelSum);
          RowTmp^[X].rgbtBlue := EnsureRange(V, 0, 255);
        end
        else
          RowTmp^[X] := RowSrc^[X];
      end;
    end;

    // --- Vertical Pass ---
    OutImg := TBitmap.Create;
    OutImg.PixelFormat := pf24bit;
    OutImg.SetSize(W, H);

    SetLength(TempLines, H);
    for Y := 0 to H - 1 do
      TempLines[Y] := Tmp.ScanLine[Y];

    for Y := 0 to H - 1 do
    begin
      RowOut := OutImg.ScanLine[Y];

      for X := 0 to W - 1 do
      begin
        if Mask[Y][X] then
        begin
          RowOut^[X] := TempLines[Y]^[X];
          Continue;
        end;

        dAccR := 0.0;
        dAccG := 0.0;
        dAccB := 0.0;
        UsedKernelSum := 0.0;

        for i := -Radius to Radius do
        begin
          Y2 := Y + i;
          if Y2 < 0 then
            Y2 := 0
          else if Y2 >= H then
            Y2 := H - 1;

          if not Mask[Y2][X] then
          begin
            dAccR := dAccR + TempLines[Y2]^[X].rgbtRed * Kernel[i + Radius];
            dAccG := dAccG + TempLines[Y2]^[X].rgbtGreen * Kernel[i + Radius];
            dAccB := dAccB + TempLines[Y2]^[X].rgbtBlue * Kernel[i + Radius];
            UsedKernelSum := UsedKernelSum + Kernel[i + Radius];
          end;
        end;

        if UsedKernelSum > 0 then
        begin
          V := Round(dAccR / UsedKernelSum);
          RowOut^[X].rgbtRed := EnsureRange(V, 0, 255);
          V := Round(dAccG / UsedKernelSum);
          RowOut^[X].rgbtGreen := EnsureRange(V, 0, 255);
          V := Round(dAccB / UsedKernelSum);
          RowOut^[X].rgbtBlue := EnsureRange(V, 0, 255);
        end
        else
          RowOut^[X] := TempLines[Y]^[X];
      end;
    end;

  finally
    Tmp.Free;
  end;
end;

procedure SimplifyByNeighborThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);
var
  W, H, i: Integer;
  Visited: TBoolGrid;
  X, Y: Integer;
  SeedColor: TRGBTriple;
  Thresh2: Double;

  // Flood-fill queue holds encoded coordinates (Y * W + X)
  Q: TQueue<Integer>;

  // Buffers for region accumulation
  RegionPixels: TList<Integer>;
  SumR, SumG, SumB: Int64;
  CountPixels: Integer;

  // Convert TBitmap data to a 2D TRGBTripleGrid for easy random access
  SrcData, DstData: TRGBTripleGrid;

  // Helper to push a neighbor if it’s unvisited and “close enough.”
  procedure TryEnqueueNeighbor(const NX, NY: Integer);
  var
    Idx: Integer;
    C: TRGBTriple;
  begin
    if (NX < 0) or (NX >= W) or (NY < 0) or (NY >= H) then
      Exit;
    if Visited[NY][NX] then
      Exit;
    C := SrcData[NY][NX];
    // Compare neighbor’s color to the *seed* color (fixed) or
    // you could compare to region’s running average if you prefer.
    if ColorDist2(C, SeedColor) <= Thresh2 then
    begin
      Idx := NY * W + NX;
      Q.Enqueue(Idx);
      Visited[NY][NX] := True;
      RegionPixels.Add(Idx);
      Inc(SumR, C.rgbtRed);
      Inc(SumG, C.rgbtGreen);
      Inc(SumB, C.rgbtBlue);
      Inc(CountPixels);
    end;
  end;

var
  RowSrc: PRGBTripleArray;
  RowDst: PRGBTripleArray;
  iIdx, currIdx, curX, curY: Integer;
  repColor: TRGBTriple;
begin
  Assert(Src24.PixelFormat = pf24bit);
  W := Src24.width;
  H := Src24.height;
  Thresh2 := Sqr(Thresh);

  // 1) Copy all pixel data from Src24 into SrcData[y][x]
  SetLength(SrcData, H, W);
  for Y := 0 to H - 1 do
  begin
    RowSrc := Src24.ScanLine[Y];
    for X := 0 to W - 1 do
    begin
      SrcData[Y][X] := RowSrc^[X];
    end;
  end;

  // 2) Prepare DstData (same size), and Visited[H][W] = False
  SetLength(DstData, H, W);
  SetLength(Visited, H, W);
  for Y := 0 to H - 1 do
    for X := 0 to W - 1 do
      Visited[Y][X] := False;

  // 3) Create helper queue and container for collecting region pixels
  Q := TQueue<Integer>.Create;
  RegionPixels := TList<Integer>.Create;

  try
    // 4) Main loop: visit each pixel once
    for Y := 0 to H - 1 do
    begin
      for X := 0 to W - 1 do
      begin
        if Visited[Y][X] then
          Continue;

        // Start a new region with seed (X,Y)
        Visited[Y][X] := True;
        RegionPixels.Clear;

        SeedColor := SrcData[Y][X];
        SumR := SeedColor.rgbtRed;
        SumG := SeedColor.rgbtGreen;
        SumB := SeedColor.rgbtBlue;
        CountPixels := 1;

        // Enqueue the seed
        Q.Clear;
        Q.Enqueue(Y * W + X);
        RegionPixels.Add(Y * W + X);

        // 5) Flood‐fill: pull indices from Q, look at 4‐neighbors
        while Q.Count > 0 do
        begin
          currIdx := Q.Dequeue;
          curY := currIdx div W;
          curX := currIdx mod W;

          // Check neighbours

          TryEnqueueNeighbor(curX - 1, curY); // left
          TryEnqueueNeighbor(curX + 1, curY); // right
          TryEnqueueNeighbor(curX, curY - 1); // up
          TryEnqueueNeighbor(curX, curY + 1); // down

          TryEnqueueNeighbor(curX - 1, curY - 1); // left
          TryEnqueueNeighbor(curX + 1, curY - 1); // right
          TryEnqueueNeighbor(curX + 1, curY - 1); // up
          TryEnqueueNeighbor(curX - 1, curY + 1); // down

        end;

        // 6) Region is collected in RegionPixels[].  Compute average color:
        repColor.rgbtRed := Round(SumR / CountPixels);
        repColor.rgbtGreen := Round(SumG / CountPixels);
        repColor.rgbtBlue := Round(SumB / CountPixels);

        // 7) Paint every pixel in that region into DstData with repColor:
        for iIdx in RegionPixels do
        begin
          curY := iIdx div W;
          curX := iIdx mod W;
          DstData[curY][curX] := repColor;
        end;
      end;
    end;

    // 8) Finally, copy DstData back into a new 24‐bit TBitmap
    Dst24 := TBitmap.Create;
    Dst24.PixelFormat := pf24bit;
    Dst24.SetSize(W, H);
    for Y := 0 to H - 1 do
    begin
      RowDst := Dst24.ScanLine[Y];
      for X := 0 to W - 1 do
      begin
        RowDst^[X] := DstData[Y][X];
      end;
    end;

  finally
    Q.Free;
    RegionPixels.Free;
    // (You can free SrcData/DstData arrays if needed, but they’ll auto‐free when out of scope)
  end;
end;

// ------------------------------------------------------------------------------
// 1) SEED‐BASED FLOOD‐FILL
// ------------------------------------------------------------------------------
/// <summary>
/// Simplify by flood‐filling each unvisited pixel using a fixed seed color.
/// Adjacent (4‐connected) neighbors join if ColorDist²(neighbor, seed) ≤ Thresh².
/// Each region is painted with its seed’s original color.
/// </summary>

procedure SimplifyBySeedThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);
var
  W, H: Integer;
  Thresh2: Double;
  SrcData, DstData: TRGBTripleGrid;
  Visited: TBoolGrid;
  X, Y: Integer;

  Q: TQueue<Integer>;
  currIdx, curX, curY: Integer;
  SeedColor: TRGBTriple;

  procedure TryEnqueueNeighbor(const NX, NY: Integer);
  var
    idxN: Integer;
    Cn: TRGBTriple;
  begin
    if (NX < 0) or (NX >= W) or (NY < 0) or (NY >= H) then
      Exit;
    if Visited[NY][NX] then
      Exit;
    Cn := SrcData[NY][NX];
    if ColorDist2(Cn, SeedColor) <= Thresh2 then
    begin
      idxN := NY * W + NX;
      Q.Enqueue(idxN);
      Visited[NY][NX] := True;
      // Paint immediately in DstData with the seed color:
      DstData[NY][NX] := SeedColor;
    end;
  end;

var
  RowSrc: PRGBTripleArray;
  RowDst: PRGBTripleArray;
begin
  Assert(Src24.PixelFormat = pf24bit);
  W := Src24.width;
  H := Src24.height;
  Thresh2 := Sqr(Thresh);

  // 1) Copy source pixels into SrcData[y][x]
  SetLength(SrcData, H, W);
  for Y := 0 to H - 1 do
  begin
    RowSrc := Src24.ScanLine[Y];
    for X := 0 to W - 1 do
      SrcData[Y][X] := RowSrc^[X];
  end;

  // 2) Prepare DstData & Visited grid
  SetLength(DstData, H, W);
  SetLength(Visited, H, W);
  for Y := 0 to H - 1 do
    for X := 0 to W - 1 do
      Visited[Y][X] := False;

  // 3) Queue for flood‐fill
  Q := TQueue<Integer>.Create;
  try
    // Loop each pixel
    for Y := 0 to H - 1 do
      for X := 0 to W - 1 do
      begin
        if Visited[Y][X] then
          Continue;

        // Start new region with seed (X,Y)
        SeedColor := SrcData[Y][X];
        Visited[Y][X] := True;
        DstData[Y][X] := SeedColor; // paint seed in Dst
        Q.Clear;
        Q.Enqueue(Y * W + X);

        // Flood‐fill neighbors
        while Q.Count > 0 do
        begin
          currIdx := Q.Dequeue;
          curY := currIdx div W;
          curX := currIdx mod W;
          // 4‐neighbors
          TryEnqueueNeighbor(curX - 1, curY);
          TryEnqueueNeighbor(curX + 1, curY);
          TryEnqueueNeighbor(curX, curY - 1);
          TryEnqueueNeighbor(curX, curY + 1);
        end;
      end;

    // 4) Copy DstData into a new TBitmap
    Dst24 := TBitmap.Create;
    Dst24.PixelFormat := pf24bit;
    Dst24.SetSize(W, H);
    for Y := 0 to H - 1 do
    begin
      RowDst := Dst24.ScanLine[Y];
      for X := 0 to W - 1 do
        RowDst^[X] := DstData[Y][X];
    end;
  finally
    Q.Free;
  end;
end;

// ------------------------------------------------------------------------------
// 2) REGION‐MEAN FLOOD‐FILL
// ------------------------------------------------------------------------------
/// <summary>
/// Simplify by flood‐filling each region, comparing neighbors to the current
/// region’s **dynamic mean** (rather than a fixed seed).
/// If ColorDist²(neighbor, regionMean) ≤ Thresh², the neighbor joins.
/// Each region is painted with the average color of all its members.
/// </summary>

procedure SimplifyByRegionMeanThreshold(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);
var
  W, H: Integer;
  Thresh2: Double;
  SrcData, DstData: TRGBTripleGrid;
  Visited: TBoolGrid;
  X, Y: Integer;

  Q: TQueue<Integer>;
  RegionPixels: TList<Integer>;
  currIdx, curX, curY: Integer;
  SumR, SumG, SumB: Int64;
  CountPixels: Integer;
  meanColor: TRGBTriple;

  procedure TryEnqueueNeighbor(const NX, NY: Integer);
  var
    idxN: Integer;
    Cn: TRGBTriple;
    d2: Double;
  begin
    if (NX < 0) or (NX >= W) or (NY < 0) or (NY >= H) then
      Exit;
    if Visited[NY][NX] then
      Exit;

    Cn := SrcData[NY][NX];
    // Compute dynamic region mean so far:
    meanColor.rgbtRed := Round(SumR / CountPixels);
    meanColor.rgbtGreen := Round(SumG / CountPixels);
    meanColor.rgbtBlue := Round(SumB / CountPixels);

    d2 := Sqr(Cn.rgbtRed - meanColor.rgbtRed) +
      Sqr(Cn.rgbtGreen - meanColor.rgbtGreen) +
      Sqr(Cn.rgbtBlue - meanColor.rgbtBlue);
    if d2 <= Thresh2 then
    begin
      idxN := NY * W + NX;
      Q.Enqueue(idxN);
      Visited[NY][NX] := True;
      RegionPixels.Add(idxN);
      Inc(SumR, Cn.rgbtRed);
      Inc(SumG, Cn.rgbtGreen);
      Inc(SumB, Cn.rgbtBlue);
      Inc(CountPixels);
    end;
  end;

var
  RowSrc: PRGBTripleArray;
  RowDst: PRGBTripleArray;
  iIdx: Integer;
  Ravg, Gavg, Bavg: Integer;
begin
  Assert(Src24.PixelFormat = pf24bit);
  W := Src24.width;
  H := Src24.height;
  Thresh2 := Sqr(Thresh);

  // Copy source to a 2D array
  SetLength(SrcData, H, W);
  for Y := 0 to H - 1 do
  begin
    RowSrc := Src24.ScanLine[Y];
    for X := 0 to W - 1 do
      SrcData[Y][X] := RowSrc^[X];
  end;

  // Prepare DstData and visited mask
  SetLength(DstData, H, W);
  SetLength(Visited, H, W);
  for Y := 0 to H - 1 do
    for X := 0 to W - 1 do
      Visited[Y][X] := False;

  Q := TQueue<Integer>.Create;
  RegionPixels := TList<Integer>.Create;
  try
    for Y := 0 to H - 1 do
      for X := 0 to W - 1 do
      begin
        if Visited[Y][X] then
          Continue;

        // Initialize new region
        Visited[Y][X] := True;
        RegionPixels.Clear;
        SumR := SrcData[Y][X].rgbtRed;
        SumG := SrcData[Y][X].rgbtGreen;
        SumB := SrcData[Y][X].rgbtBlue;
        CountPixels := 1;

        // Paint the seed’s position later after we know average
        Q.Clear;
        Q.Enqueue(Y * W + X);
        RegionPixels.Add(Y * W + X);

        // Flood‐fill by dynamic mean
        while Q.Count > 0 do
        begin
          currIdx := Q.Dequeue;
          curY := currIdx div W;
          curX := currIdx mod W;

          TryEnqueueNeighbor(curX - 1, curY);
          TryEnqueueNeighbor(curX + 1, curY);
          TryEnqueueNeighbor(curX, curY - 1);
          TryEnqueueNeighbor(curX, curY + 1);
        end;

        // Compute region average color
        Ravg := Round(SumR / CountPixels);
        Gavg := Round(SumG / CountPixels);
        Bavg := Round(SumB / CountPixels);
        meanColor.rgbtRed := Ravg;
        meanColor.rgbtGreen := Gavg;
        meanColor.rgbtBlue := Bavg;

        // Paint entire region with meanColor
        for iIdx in RegionPixels do
        begin
          curY := iIdx div W;
          curX := iIdx mod W;
          DstData[curY][curX] := meanColor;
        end;
      end;

    // Copy DstData back to a new 24-bit bitmap
    Dst24 := TBitmap.Create;
    Dst24.PixelFormat := pf24bit;
    Dst24.SetSize(W, H);
    for Y := 0 to H - 1 do
    begin
      RowDst := Dst24.ScanLine[Y];
      for X := 0 to W - 1 do
        RowDst^[X] := DstData[Y][X];
    end;
  finally
    Q.Free;
    RegionPixels.Free;
  end;
end;

// ------------------------------------------------------------------------------
// 3) QUADTREE SIMPLIFICATION
// ------------------------------------------------------------------------------
/// <summary>
/// Recursively subdivide [X0..X1]×[Y0..Y1] in SrcGrid. If all pixels in that block
/// lie within Thresh² of the block’s average, paint DstGrid with that average.
/// Otherwise, split into four quadrants and recurse.
/// </summary>

procedure ProcessQuad(const SrcGrid: TRGBTripleGrid;
  var DstGrid: TRGBTripleGrid; X0, Y0, X1, Y1: Integer; Thresh2: Double);

var
  X, Y: Integer;
  SumR, SumG, SumB, cnt: Int64;
  avgR, avgG, avgB: Integer;
  C: TRGBTriple;
  maxDist2: Double;
  midX, midY: Integer;
  IgnoreR, IgnoreG, IgnoreB: array [0 .. 2] of Byte;

  function IsIgnored(const C: TRGBTriple): Boolean;
  var
    i: Integer;
  begin
    for i := 0 to 2 do
      if (C.rgbtRed = IgnoreR[i]) and (C.rgbtGreen = IgnoreG[i]) and
        (C.rgbtBlue = IgnoreB[i]) then
        Exit(True);
    Result := False;
  end;

begin
  // Convert ignore colors to TRGBTriple-compatible bytes
  IgnoreR[0] := GetRValue(TCol_TransGP2);
  IgnoreG[0] := GetGValue(TCol_TransGP2);
  IgnoreB[0] := GetBValue(TCol_TransGP2);

  IgnoreR[1] := GetRValue(TCol_TransGP3);
  IgnoreG[1] := GetGValue(TCol_TransGP3);
  IgnoreB[1] := GetBValue(TCol_TransGP3);

  IgnoreR[2] := GetRValue(TCol_TransGP3HW);
  IgnoreG[2] := GetGValue(TCol_TransGP3HW);
  IgnoreB[2] := GetBValue(TCol_TransGP3HW);

  // 1) Compute average of non-ignored pixels
  SumR := 0;
  SumG := 0;
  SumB := 0;
  cnt := 0;
  for Y := Y0 to Y1 do
    for X := X0 to X1 do
    begin
      C := SrcGrid[Y][X];
      if not IsIgnored(C) then
      begin
        Inc(SumR, C.rgbtRed);
        Inc(SumG, C.rgbtGreen);
        Inc(SumB, C.rgbtBlue);
        Inc(cnt);
      end;
    end;

  if cnt = 0 then
  begin
    // All pixels are ignored — copy block unchanged
    for Y := Y0 to Y1 do
      for X := X0 to X1 do
        DstGrid[Y][X] := SrcGrid[Y][X];
    Exit;
  end;

  avgR := Round(SumR / cnt);
  avgG := Round(SumG / cnt);
  avgB := Round(SumB / cnt);

  // 2) Compute maximum squared distance for non-ignored pixels
  maxDist2 := 0.0;
  for Y := Y0 to Y1 do
  begin
    for X := X0 to X1 do
    begin
      C := SrcGrid[Y][X];
      if IsIgnored(C) then
        Continue;
      maxDist2 := Max(maxDist2, Sqr(C.rgbtRed - avgR) + Sqr(C.rgbtGreen - avgG)
        + Sqr(C.rgbtBlue - avgB));
      if maxDist2 > Thresh2 then
        Break;
    end;
    if maxDist2 > Thresh2 then
      Break;
  end;

  if maxDist2 <= Thresh2 then
  begin
    // 3) Fill simplified block, preserving ignored pixels
    C.rgbtRed := avgR;
    C.rgbtGreen := avgG;
    C.rgbtBlue := avgB;
    for Y := Y0 to Y1 do
      for X := X0 to X1 do
      begin
        if IsIgnored(SrcGrid[Y][X]) then
          DstGrid[Y][X] := SrcGrid[Y][X]
        else
          DstGrid[Y][X] := C;
      end;
  end
  else
  begin
    // 4) Subdivide
    if (X1 > X0) or (Y1 > Y0) then
    begin
      midX := (X0 + X1) div 2;
      midY := (Y0 + Y1) div 2;

      ProcessQuad(SrcGrid, DstGrid, X0, Y0, midX, midY, Thresh2);
      if midX + 1 <= X1 then
        ProcessQuad(SrcGrid, DstGrid, midX + 1, Y0, X1, midY, Thresh2);
      if midY + 1 <= Y1 then
        ProcessQuad(SrcGrid, DstGrid, X0, midY + 1, midX, Y1, Thresh2);
      if (midX + 1 <= X1) and (midY + 1 <= Y1) then
        ProcessQuad(SrcGrid, DstGrid, midX + 1, midY + 1, X1, Y1, Thresh2);
    end
    else
    begin
      DstGrid[Y0][X0] := SrcGrid[Y0][X0];
    end;
  end;
end;

/// // <summary>
/// // Simplify a 24-bit bitmap by quadtree splitting. Each block is tested:
/// // if all pixels in block are within Thresh of the block’s average, fill block
/// // with that average. Otherwise, subdivide into four.
/// // </summary>
procedure QuadtreeSimplify(const Src24: TBitmap; Thresh: Double;
  out Dst24: TBitmap);
var
  W, H: Integer;
  Thresh2: Double;
  SrcData, DstData: TRGBTripleGrid;
  X, Y: Integer;
  RowSrc, RowDst: PRGBTripleArray;
begin
  Assert(Src24.PixelFormat = pf24bit);
  W := Src24.width;
  H := Src24.height;
  Thresh2 := Sqr(Thresh);

  // 1) Copy the source into a 2D array for easy random access
  SetLength(SrcData, H, W);
  for Y := 0 to H - 1 do
  begin
    RowSrc := Src24.ScanLine[Y];
    for X := 0 to W - 1 do
      SrcData[Y][X] := RowSrc^[X];
  end;

  // 2) Prepare the destination 2D array
  SetLength(DstData, H, W);

  // 3) Process the entire image region [0..W-1]×[0..H-1]
  ProcessQuad(SrcData, DstData, 0, 0, W - 1, H - 1, Thresh2);

  // 4) Copy DstData back into a new 24-bit TBitmap
  Dst24 := TBitmap.Create;
  Dst24.PixelFormat := pf24bit;
  Dst24.SetSize(W, H);
  for Y := 0 to H - 1 do
  begin
    RowDst := Dst24.ScanLine[Y];
    for X := 0 to W - 1 do
      RowDst^[X] := DstData[Y][X];
  end;
end;

procedure BuildBmpIdxPal(const LevelsIdx: array of TBitmap;
  out SingleIdx: TBitmap; out PalPerLevel: array of TArray<TColor>);
var
  W, H, X, Y, L, i, j: Integer;
  CountMap: TDictionary<TTupleKey, Integer>;
  TupleToIndices: TDictionary<TTupleKey, TIndex4>;
  PairList: TArray<TPair<TTupleKey, Integer>>;
  BaseTuples: TArray<TTupleKey>;
  TupleToBaseIndex: TDictionary<TTupleKey, Byte>;
  PalColors: array [0 .. 255, 0 .. 3] of TColor;
  Idx4, TmpIdx4: TIndex4;
  Key: TTupleKey;
  bestDist, Dist: Int64;
  BestBaseIdx: Integer;
  RowIdx: array [0 .. 3] of PByteArray;
  RowS: PByteArray;
  PalSize3: Integer;
  LogPalPerLevel: TMaxLogPalette;
  EucDist: Double;

  function MakeKey(const Arr: TIndex4): TTupleKey;
  begin
    SetLength(Result, 4);
    Result[1] := Chr(Arr[0]);
    Result[2] := Chr(Arr[1]);
    Result[3] := Chr(Arr[2]);
    Result[4] := Chr(Arr[3]);
  end;

begin
  Assert(Length(LevelsIdx) = 4);
  W := LevelsIdx[0].width;
  H := LevelsIdx[0].height;
  for L := 0 to 3 do
    if (LevelsIdx[L].width <> W) or (LevelsIdx[L].height <> H) or
      (LevelsIdx[L].PixelFormat <> pf8bit) then
      raise Exception.CreateFmt
        ('Level %d must be pf8bit and same dims.', [L + 1]);

  // 1) Count each pixel’s 4-tuple frequency
  CountMap := TDictionary<TTupleKey, Integer>.Create;
  TupleToIndices := TDictionary<TTupleKey, TIndex4>.Create;
  try
    for Y := 0 to H - 1 do
    begin
      for L := 0 to 3 do
        RowIdx[L] := LevelsIdx[L].ScanLine[Y];
      for X := 0 to W - 1 do
      begin
        for L := 0 to 3 do
          Idx4[L] := RowIdx[L]^[X];
        Key := MakeKey(Idx4);
        if not CountMap.TryGetValue(Key, i) then
        begin
          CountMap.Add(Key, 1);
          TupleToIndices.Add(Key, Idx4);
        end
        else
          CountMap[Key] := i + 1;
      end;
    end;

    // 2) Sort by descending frequency
    SetLength(PairList, CountMap.Count);
    i := 0;
    for Key in CountMap.Keys do
    begin
      PairList[i] := TPair<TTupleKey, Integer>.Create(Key, CountMap[Key]);
      Inc(i);
    end;
    TArray.Sort < TPair < TTupleKey,
      Integer >> (PairList, TComparer < TPair < TTupleKey, Integer >>.Construct(
      function(const a, b: TPair<TTupleKey, Integer>): Integer
      begin
        if a.Value > b.Value then
          Result := -1
        else if a.Value < b.Value then
          Result := 1
        else
          Result := 0;
      end));

    // 3) Take top ≤256 as base, then pad to 256
    var
    M := Min(Length(PairList), 256);
    SetLength(BaseTuples, M);
    for j := 0 to M - 1 do
      BaseTuples[j] := PairList[j].Key;
    SetLength(BaseTuples, 256);
    for j := M to 255 do
      BaseTuples[j] := BaseTuples[M - 1];

    // 4) Precompute PalColors[j, L] = GPxPal[IdxFromBaseTuple[j][L]]
    for j := 0 to 255 do
    begin
      Idx4 := TupleToIndices[BaseTuples[j]];
      for L := 0 to 3 do
        PalColors[j, L] := RGBFromTRGB(GPXPal[Idx4[L]]);
    end;

    // 5) Build TupleToBaseIndex (nearest‐neighbor merge)
    TupleToBaseIndex := TDictionary<TTupleKey, Byte>.Create;
    try
      for j := 0 to 255 do
      begin
        if TupleToBaseIndex.ContainsKey(BaseTuples[j]) then
          Break;
        TupleToBaseIndex.Add(BaseTuples[j], Byte(j));
      end;

      for Key in CountMap.Keys do
      begin
        if TupleToBaseIndex.ContainsKey(Key) then
          Continue;
        TmpIdx4 := TupleToIndices[Key];
        bestDist := High(Int64);
        BestBaseIdx := 0;
        for j := 0 to 255 do
        begin
          Dist := 0;
          for L := 0 to 3 do
          begin
            var
            C1 := RGBFromTRGB(GPXPal[TmpIdx4[L]]);
            var
            C2 := PalColors[j, L];
            var
            dr := GetRValue(C1) - GetRValue(C2);
            var
            dg := GetGValue(C1) - GetGValue(C2);
            var
            db := GetBValue(C1) - GetBValue(C2);

            EucDist := Sqrt(Int64(dr) * dr + Int64(dg) * dg + Int64(db) * db);
            Dist := Dist + Floor(EucDist);
          end;
          if Dist < bestDist then
          begin
            bestDist := Dist;
            BestBaseIdx := j;
          end;
        end;
        TupleToBaseIndex.Add(Key, Byte(BestBaseIdx));
      end;

      // 6) Build SingleIdx map (pf8bit) with dummy palette so we can write pixels
      SingleIdx := TBitmap.Create;
      SingleIdx.PixelFormat := pf8bit;
      SingleIdx.width := W;
      SingleIdx.height := H;
      begin
        var
          LP2: PLogPal2;
        var
          PalSize2: Integer;
        var
          hPalTemp: HPalette;
        PalSize2 := SizeOf(Word) * 2 + SizeOf(TPaletteEntry) * 256;
        GetMem(LP2, PalSize2);
        try
          LP2^.palVersion := $0300;
          LP2^.palNumEntries := 256;

          for j := 0 to 255 do
          begin
            LP2^.palPalEntry[j].peRed := GPXPal[j].R;
            LP2^.palPalEntry[j].peGreen := GPXPal[j].G;
            LP2^.palPalEntry[j].peBlue := GPXPal[j].b;
            LP2^.palPalEntry[j].peFlags := 0;
          end;

          hPalTemp := CreatePalette(PLogPalette(@LP2)^);
          SingleIdx.Palette := hPalTemp;
        finally
          FreeMem(LP2, PalSize2);
        end;
      end;

      for Y := 0 to H - 1 do
      begin
        for L := 0 to 3 do
          RowIdx[L] := LevelsIdx[L].ScanLine[Y];
        RowS := SingleIdx.ScanLine[Y];
        for X := 0 to W - 1 do
        begin
          for L := 0 to 3 do
            Idx4[L] := RowIdx[L]^[X];
          Key := MakeKey(Idx4);
          RowS^[X] := TupleToBaseIndex[Key];
        end;
      end;

      // 7) Build PalPerLevel[L][0..255]
      for L := 0 to 3 do
      begin
        // Overwrite the palette with PalPerLevel[i]
        FillChar(LogPalPerLevel, SizeOf(LogPalPerLevel), 0);
        LogPalPerLevel.palVersion := $300;
        LogPalPerLevel.palNumEntries := 256;

        SetLength(PalPerLevel[L], 256);
        for j := 0 to 255 do
        begin
          PalPerLevel[L][j] := PalColors[j, L];
          LogPalPerLevel.palPalEntry[j].peRed := GetRValue(PalColors[j, L]);
          LogPalPerLevel.palPalEntry[j].peGreen := GetGValue(PalColors[j, L]);
          LogPalPerLevel.palPalEntry[j].peBlue := GetBValue(PalColors[j, L]);
          LogPalPerLevel.palPalEntry[j].peFlags := 0;
        end;

        HPalettePerLevel[L] := CreatePalette(PLogPalette(@LogPalPerLevel)^);

      end;
    finally
      TupleToBaseIndex.Free;
    end;

  finally
    TupleToIndices.Free;
    CountMap.Free;
  end;
end;

function BuildSingleIdxMap(const bmp: TBitmap): TBitmap;
type
  TColorKey = string[3];
var
  W, H, X, Y: Integer;
  Row: PByteArray;
  ColorMap: TDictionary<TColorKey, Byte>;
  KeyList: TList<TColorKey>;
  ColorIdx: Byte;
  OutBmp: TBitmap;
  OutRow: PByteArray;
  PaletteEntries: array [0 .. 255] of TPaletteEntry;
  PalColor: TColor;
  Key: TColorKey;

  function ColorToKey(const C: TColor): TColorKey;
  begin
    Result := Chr(GetRValue(C)) + Chr(GetGValue(C)) + Chr(GetBValue(C));
  end;

  function CreateDummyPalette: HPalette;
  var
    LP: PLogPalette;
    i: Integer;
  begin
    GetMem(LP, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * 255);
    try
      LP^.palVersion := $0300;
      LP^.palNumEntries := 256;
      for i := 0 to 255 do
      begin
        LP^.palPalEntry[i].peRed := i;
        LP^.palPalEntry[i].peGreen := i;
        LP^.palPalEntry[i].peBlue := i;
        LP^.palPalEntry[i].peFlags := 0;
      end;
      Result := CreatePalette(LP^);
    finally
      FreeMem(LP);
    end;
  end;

begin
  if bmp.PixelFormat <> pf8bit then
    raise Exception.Create('Input bitmap must be pf8bit');

  W := bmp.width;
  H := bmp.height;

  // Get palette entries once
  if GetPaletteEntries(bmp.Palette, 0, 256, PaletteEntries) = 0 then
    raise Exception.Create('Failed to retrieve bitmap palette entries.');

  ColorMap := TDictionary<TColorKey, Byte>.Create;
  KeyList := TList<TColorKey>.Create;
  try
    // Create output bitmap
    OutBmp := TBitmap.Create;
    OutBmp.PixelFormat := pf8bit;
    OutBmp.width := W;
    OutBmp.height := H;
    OutBmp.Palette := CreateDummyPalette;

    for Y := 0 to H - 1 do
    begin
      Row := bmp.ScanLine[Y];
      OutRow := OutBmp.ScanLine[Y];

      for X := 0 to W - 1 do
      begin
        PalColor := RGB(PaletteEntries[Row^[X]].peRed,
          PaletteEntries[Row^[X]].peGreen, PaletteEntries[Row^[X]].peBlue);

        Key := ColorToKey(PalColor);

        if not ColorMap.TryGetValue(Key, ColorIdx) then
        begin
          ColorIdx := ColorMap.Count;

          ColorMap.Add(Key, ColorIdx);
          KeyList.Add(Key);
        end;

        OutRow^[X] := ColorIdx;
      end;
    end;

    Result := OutBmp;
  finally
    KeyList.Free;
    ColorMap.Free;
  end;
end;

procedure BuildGPxMatteMask(const Src: TBitmap;
const TransColors: array of TColor; out Mask: TBoolGrid);
var
  W, H, X, Y, i: Integer;
  Row: PRGBTripleArray;
  pix: TRGBTriple;
  rgb2: TColor;
begin
 src.pixelformat := pf24bit;
  Assert(Src.PixelFormat = pf24bit, 'Source must be pf24bit');

  W := Src.width;
  H := Src.height;
  SetLength(Mask, H, W);

  for Y := 0 to H - 1 do
  begin
    Row := Src.ScanLine[Y]; // each row is an array of TRGBTriple
    for X := 0 to W - 1 do
    begin
      pix := Row^[X];
      rgb2 := RGB(pix.rgbtRed, pix.rgbtGreen, pix.rgbtBlue);
      Mask[Y][X] := False;
      if boolProtectTrans = False then
        Break;
      // Check against each transparent color
      for i := Low(TransColors) to High(TransColors) do
      begin
        if rgb2 = TransColors[i] then
        begin
          Mask[Y][X] := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure BuildMaskFromBMP(const Src: TBitmap; out Mask: TBoolGrid);
var
  W, H, X, Y: Integer;
  Row: PRGBTripleArray;
  pix: TRGBTriple;
  rgb2: TColor;
begin
  Assert(Src.PixelFormat = pf24bit, 'Source must be pf24bit');

  W := Src.width;
  H := Src.height;
  SetLength(Mask, H, W);

  for Y := 0 to H - 1 do
  begin
    Row := Src.ScanLine[Y]; // each row is an array of TRGBTriple
    for X := 0 to W - 1 do
    begin
      pix := Row^[X];
      rgb2 := RGB(pix.rgbtRed, pix.rgbtGreen, pix.rgbtBlue);
      Mask[Y][X] := False;
      // Check against each transparent color

      if rgb2 = RGB(0, 0, 0) then
      begin
        Mask[Y][X] := True;
        Break;
      end;

    end;
  end;
end;

function ApplyMatteToImage(Resized, matte: TBitmap;
const TransparentColor: TColor): TBitmap;
var
  X, Y: Integer;
  ResLine, MatteLine: PRGBTripleArray;
  OutLine: PRGBTripleArray;
  tcR, tcG, tcB: Byte;
begin
  // Pre‐compute transparent color components
  tcR := GetRValue(TransparentColor);
  tcG := GetGValue(TransparentColor);
  tcB := GetBValue(TransparentColor);

  // Create output
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(Resized.width, Resized.height);

  // Draw per scanline
  for Y := 0 to Resized.height - 1 do
  begin
    ResLine := Resized.ScanLine[Y];
    MatteLine := matte.ScanLine[Y];
    OutLine := Result.ScanLine[Y];
    for X := 0 to Resized.width - 1 do
    begin
      if MatteLine^[X].rgbtRed > 127 then
      begin
        // Transparent pixel
        OutLine^[X].rgbtRed := tcR;
        OutLine^[X].rgbtGreen := tcG;
        OutLine^[X].rgbtBlue := tcB;
      end
      else
      begin
        // Opaque pixel from resized image
        OutLine^[X] := ResLine^[X];
      end;
    end;
  end;
end;

function resizeTransProtection(Source: TBitmap; NewWidth, NewHeight: Integer;
const TransparentColor: TColor): TBitmap;
var
  matte, ResizedImg, ResizedMatte: TBitmap;
begin
  // 1) Build transparency matte
  matte := CreateTransparencyMatte(Source);
  try
    // 2) Resize source and matte
    ResizedImg := StretchF(Source, NewWidth, NewHeight);
    try
      ResizedMatte := StretchF(matte, NewWidth, NewHeight);
      try
        // 3) Composite → this returns a *new* TBitmap we hand back
        Result := ApplyMatteToImage(ResizedImg, ResizedMatte, TransparentColor);
      finally
        // Free only the *resized* matte
        ResizedMatte.Free;
      end;
    finally
      // Free only the *resized* image
      ResizedImg.Free;
    end;
  finally
    // Free the original matte
    matte.Free;
  end;

end;

function DrawBitToBmp(const values: array of Byte;
width, height: Integer): TBitmap;
var
  X, Y, Idx: Integer;
  bmp: TBitmap;
  Row: PRGBTriple;
  Val: Byte;
begin
  bmp := TBitmap.Create;
  bmp.PixelFormat := pf24bit;
  bmp.SetSize(width, height);

  Idx := 0;
  {$R-}
  for Y := 0 to height - 1 do
  begin
    Row := bmp.ScanLine[Y];
    for X := 0 to width - 1 do
    begin
      if values[Idx] = $01 then
        Val := 255
      else
        Val := 0;
      Row^.rgbtRed := Val;
      Row^.rgbtGreen := Val;
      Row^.rgbtBlue := Val;
      Inc(Row);
      Inc(Idx);
    end;
  end;
  {$R+}

  Result := bmp;
end;

procedure BleedEdges(var bmp: TBitmap; const matte: TBitmap;
const TransparentColor: TColor; Iterations: Integer = 4);
var
  W, H, X, Y, i, dx, dy: Integer;
  Src, Tmp: TBitmap;
  SrcLine, DstLine, NeighLine: PRGBTripleArray;
  Col, NeighColor: TColor;
begin
  W := bmp.width;
  H := bmp.height;

  for i := 1 to Iterations do
  begin
    Src := TBitmap.Create;
    Tmp := TBitmap.Create;
    try
      Src.Assign(bmp);
      Src.PixelFormat := pf24bit;
      Tmp.Assign(bmp); // Working copy
      Tmp.PixelFormat := pf24bit;

      for Y := 1 to H - 2 do
      begin
        SrcLine := Src.ScanLine[Y];
        DstLine := Tmp.ScanLine[Y];

        for X := 1 to W - 2 do
        begin
          Col := RGB(SrcLine[X].rgbtRed, SrcLine[X].rgbtGreen,
            SrcLine[X].rgbtBlue);
          if Col = TransparentColor then
          begin
            // Look around in 8-neighborhood
            for dy := -1 to 1 do
            begin
              NeighLine := Src.ScanLine[Y + dy];
              for dx := -1 to 1 do
              begin
                if (dx = 0) and (dy = 0) then
                  Continue;

                NeighColor := RGB(NeighLine[X + dx].rgbtRed,
                  NeighLine[X + dx].rgbtGreen, NeighLine[X + dx].rgbtBlue);

                if NeighColor <> TransparentColor then
                begin
                  // Extend neighbor color into this transparent pixel
                  DstLine[X].rgbtRed := GetRValue(NeighColor);
                  DstLine[X].rgbtGreen := GetGValue(NeighColor);
                  DstLine[X].rgbtBlue := GetBValue(NeighColor);
                  Break;
                end;
              end;
              if RGB(DstLine[X].rgbtRed, DstLine[X].rgbtGreen,
                DstLine[X].rgbtBlue) <> TransparentColor then
                Break;
            end;
          end;
        end;
      end;

      // Write updated pixels back
      bmp.Assign(Tmp);

    finally
      Src.Free;
      Tmp.Free;
    end;
  end;
end;

type
  PPixel32 = ^TPixel32;
  TPixel32 = packed record
    B, G, R, A: Byte;
  end;

{$R-}
procedure BoxBlurH_MT_SIMD(const Src, Dst: TBitmap; Radius: Integer);
var
  x, y: Integer;
  r, g, b: Integer;
  count: Integer;
  invCount: Single;

  SrcLine, DstLine: PPixel32;
  pSrc, pDst: PPixel32;
  c: Cardinal;

  XClamp: array of Integer;
  left, right: Integer;
  W: Integer;
begin
  W := Src.Width;
  count := Radius * 2 + 1;
  invCount := 1.0 / count;

  // Precompute clamp table
  SetLength(XClamp, W + Radius * 2 + 2);
  for x := -Radius to W + Radius do
  begin
    if x < 0 then
      XClamp[x + Radius] := 0
    else if x >= W then
      XClamp[x + Radius] := W - 1
    else
      XClamp[x + Radius] := x;
  end;

  for y := 0 to Src.Height - 1 do
  begin
    SrcLine := Src.ScanLine[y];
    DstLine := Dst.ScanLine[y];

    r := 0; g := 0; b := 0;

    // Initial window
    for x := -Radius to Radius do
    begin
      pSrc := SrcLine;
      Inc(pSrc, XClamp[x + Radius]);
      c := PCardinal(pSrc)^;

      Inc(b, c and $FF);
      Inc(g, (c shr 8) and $FF);
      Inc(r, (c shr 16) and $FF);
    end;

    pDst := DstLine;

    for x := 0 to W - 1 do
    begin
      // write pixel
      pDst.B := round(b * invCount);
      pDst.G := round(g * invCount);
      pDst.R := round(r * invCount);

      // remove left
      left := XClamp[x - Radius + Radius];
      pSrc := SrcLine;
      Inc(pSrc, left);
      c := PCardinal(pSrc)^;

      Dec(b, c and $FF);
      Dec(g, (c shr 8) and $FF);
      Dec(r, (c shr 16) and $FF);

      // add right
      right := XClamp[x + Radius + 1 + Radius];
      pSrc := SrcLine;
      Inc(pSrc, right);
      c := PCardinal(pSrc)^;

      Inc(b, c and $FF);
      Inc(g, (c shr 8) and $FF);
      Inc(r, (c shr 16) and $FF);

      Inc(pDst);
    end;
  end;
end;
procedure BoxBlurV_MT_SIMD(const Src, Dst: TBitmap; Radius: Integer);
var
  x, y: Integer;
  r, g, b: Integer;
  count: Integer;
  invCount: Single;

  Lines: array of PPixel32;
  pSrc, pDst: PPixel32;
  c: Cardinal;

  YClamp: array of Integer;
  top, bottom: Integer;
  H: Integer;
begin
  H := Src.Height;
  count := Radius * 2 + 1;
  invCount := 1.0 / count;

  // Cache scanlines
  SetLength(Lines, H);
  for y := 0 to H - 1 do
    Lines[y] := Src.ScanLine[y];

  // Precompute clamp table
  SetLength(YClamp, H + Radius * 2 + 2);
  for y := -Radius to H + Radius do
  begin
    if y < 0 then
      YClamp[y + Radius] := 0
    else if y >= H then
      YClamp[y + Radius] := H - 1
    else
      YClamp[y + Radius] := y;
  end;

  for x := 0 to Src.Width - 1 do
  begin
    r := 0; g := 0; b := 0;

    // Initial window
    for y := -Radius to Radius do
    begin
      pSrc := Lines[YClamp[y + Radius]];
      Inc(pSrc, x);
      c := PCardinal(pSrc)^;

      Inc(b, c and $FF);
      Inc(g, (c shr 8) and $FF);
      Inc(r, (c shr 16) and $FF);
    end;

    for y := 0 to H - 1 do
    begin
      pDst := Dst.ScanLine[y];
      Inc(pDst, x);

      pDst.B := round(b * invCount);
      pDst.G := round(g * invCount);
      pDst.R := round(r * invCount);

      // remove top
      top := YClamp[y - Radius + Radius];
      pSrc := Lines[top];
      Inc(pSrc, x);
      c := PCardinal(pSrc)^;

      Dec(b, c and $FF);
      Dec(g, (c shr 8) and $FF);
      Dec(r, (c shr 16) and $FF);

      // add bottom
      bottom := YClamp[y + Radius + 1 + Radius];
      pSrc := Lines[bottom];
      Inc(pSrc, x);
      c := PCardinal(pSrc)^;

      Inc(b, c and $FF);
      Inc(g, (c shr 8) and $FF);
      Inc(r, (c shr 16) and $FF);
    end;
  end;
end;

function FastBoxBlur_MT_SIMD(Bitmap: TBitmap; RadiusX, RadiusY: Integer) : TBitmap;
var
  Temp: TBitmap;
begin
  if (RadiusX <= 0) and (RadiusY <= 0) then Exit;

  Bitmap.PixelFormat := pf32bit;

  Temp := TBitmap.Create;
  try
    Temp.PixelFormat := pf32bit;
    Temp.SetSize(Bitmap.Width, Bitmap.Height);
    Temp.Canvas.Draw(0, 0, Bitmap);

    if RadiusX > 0 then
      BoxBlurH_MT_SIMD(Bitmap, Temp, RadiusX)
    else
      Temp.Assign(Bitmap);

    if RadiusY > 0 then
      BoxBlurV_MT_SIMD(Temp, Bitmap, RadiusY)
    else
      Bitmap.Assign(Temp);

    // Convert AFTER blur
    Bitmap.PixelFormat := pf24bit;

    Result := TBitmap.Create;
    Result.PixelFormat := pf24bit;
    Result.SetSize(Bitmap.Width, Bitmap.Height);
    Result.Canvas.Draw(0, 0, Bitmap);

  finally
    Temp.Free;
  end;
end;
{$R+}
end.
