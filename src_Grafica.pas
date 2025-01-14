unit src_Grafica;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.StdCtrls, GDIPAPI, GDIPOBJ, System.types, Vcl.grids, Math;

type
  tGraph = record
    Graphics: TGPGraphics;
    pen: TGPPen;
    brush: TGPSolidBrush;
  end;

procedure MyFillRectangle(var can: tCanvas; x1, y1, x2, y2: Integer;
  color: tColor; opacity: Integer);

procedure Graficar1(Image_Graf: TImage; pred, data: Integer;
  XValues1, YValues1: TStringList);
procedure Graficar2(Image_Graf: TImage; pred, data: Integer;
  XValues1, YValues1, YValues2: TStringList);
procedure ReGr(Image1: TImage);

implementation

procedure ReGr(Image1: TImage);
var
  NewBitmap: TBitmap;
  x1, y1, x2, y2: Integer;

begin
  // Limpia la imagen actual
  Image1.Picture.Assign(nil);
  NewBitmap := TBitmap.Create;

  try
    // Crea un nuevo bitmap
    Image1.Picture.Bitmap := NewBitmap;
    Image1.Picture.Bitmap.SetSize(Image1.Width, Image1.Height);

    // Pinta el fondo de blanco
    Image1.Canvas.brush.color := clWhite;
    Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
    // pintar linea

    // Dibuja el eje X
    Image1.Canvas.brush.color := clWebDarkGray;
    x1 := 0;
    y1 := Image1.Height - Image1.Height div 10;
    x2 := Image1.Width;
    y2 := Image1.Height - Image1.Height div 10 + 5;
    Image1.Canvas.FillRect(Rect(x1, y1, x2, y2));

    // Dibuja el eje Y
    Image1.Canvas.brush.color := clWebDarkGray;
    x1 := 0;
    y1 := 0;
    x2 := 5;
    y2 := Image1.Height - (Image1.Height div 10);
    Image1.Canvas.FillRect(Rect(x1, y1, x2, y2));

  finally
    NewBitmap.Free;

  end;

end;

// ____________________________________________________________

procedure MyFillRectangle(var can: tCanvas; x1, y1, x2, y2: Integer;
  color: tColor; opacity: Integer);
var
  g: tGraph;
  c1, c2, c3: word;
  x, y: Integer;
begin

  if y2 < y1 then
  begin
    y := y1;
    y1 := y2;
    y2 := y;
  end;

  if x2 < x1 then
  begin
    x := x1;
    x1 := x2;
    x2 := x;
  end;

  c1 := color mod 256;
  c2 := (color div 256) mod 256;
  c3 := ((color div 256) div 256) mod 256;

  g.Graphics := TGPGraphics.Create(can.handle);
  g.Graphics.SetSmoothingMode(SmoothingModeHighQuality);
  g.brush := TGPSolidBrush.Create(MakeColor(trunc(1.0 * opacity * 255 / 100),
    c1, c2, c3));
  g.Graphics.FillRectangle(g.brush, x1, y1, x2 - x1, y2 - y1);

  g.Graphics.Free;
  g.brush.Free;
end;

// -------------------------------------------------------------
procedure Graficar2(Image_Graf: TImage; pred, data: Integer;
  XValues1, YValues1, YValues2: TStringList);
var
  i, XPos, YPos, BarWidth, MaxYValue, BarHeight, StartIndex: Integer;
  x1, y1, x2, y2: Integer;
  ScaleInterval, ValueStep: Double;
  LabelText: String;
  TextWidth: Integer;
  can: tCanvas;

begin
  can := Image_Graf.Canvas;
  MaxYValue := 0; // Encuentra el valor máximo para escalar el eje Y

  // Configura el ancho de las barras
  if pred + data > 11 then
  begin
    BarWidth := Image_Graf.Width div ((3 + pred + data) * 2);
  end
  else
  begin
    BarWidth := Image_Graf.Width div 40;
  end;

  // Determina el índice de inicio para los últimos data
  StartIndex := Max(0, YValues1.Count - data);

  // Encuentra el valor máximo de YValues1 y YValues2 para escalar el eje Y
  for i := StartIndex to YValues1.Count - 1 do
  begin
    if StrToFloatDef(YValues1[i], 0) > MaxYValue then
      MaxYValue := Round(StrToFloat(YValues1[i]));
  end;

  for i := StartIndex to YValues2.Count - 1 do
  begin
    if StrToFloatDef(YValues2[i], 0) > MaxYValue then
      MaxYValue := Round(StrToFloat(YValues2[i]));
  end;

  for i := StartIndex to YValues1.Count - 1 do
  begin
    BarHeight := Round((StrToFloatDef(YValues1[i], 0) / MaxYValue) *
      (0.8 * Image_Graf.Height - (Image_Graf.Height div 10)));
    XPos := ((i - StartIndex) * 2 * BarWidth) + (Image_Graf.Width div 20) + 25;
    YPos := Image_Graf.Height - (Image_Graf.Height div 10) - BarHeight;

    MyFillRectangle(can, XPos, YPos, XPos + BarWidth,
      Image_Graf.Height - (Image_Graf.Height div 10), clAqua, 100);
  end;

  // Dibuja las barras para los datos de la segunda lista
  for i := StartIndex to YValues2.Count - 1 do
  begin
    BarHeight := Round((StrToFloatDef(YValues2[i], 0) / MaxYValue) *
      (0.8 * Image_Graf.Height - (Image_Graf.Height div 10)));
    XPos := ((i - StartIndex) * 2 * BarWidth) + (Image_Graf.Width div 20) + 25
      + BarWidth;
    YPos := Image_Graf.Height - (Image_Graf.Height div 10) - BarHeight;

    MyFillRectangle(can, XPos, YPos, XPos + BarWidth,
      Image_Graf.Height - (Image_Graf.Height div 10), clBlue, 100);
  end;

  // Añade las etiquetas del eje X para XValues1
  Image_Graf.Canvas.brush.Style := bsClear;
  Image_Graf.Canvas.Font.color := clBlack;
  Image_Graf.Canvas.Font.Size := 7;

  for i := StartIndex to XValues1.Count - 1 do
  begin
    TextWidth := Image_Graf.Canvas.TextWidth(XValues1[i]);
    XPos := ((i - StartIndex) * 2 * BarWidth) + 25 + (Image_Graf.Width div 20) +
      ((BarWidth - TextWidth) div 2);
    YPos := Image_Graf.Height - (Image_Graf.Height div 10) + 5;
    Image_Graf.Canvas.TextOut(XPos, YPos, XValues1[i]);
  end;

  // Dibuja divisiones y etiquetas en el eje Y
  ScaleInterval := (0.9 * Image_Graf.Height - (Image_Graf.Height div 6)) / 6;

  for i := 0 to 6 do
  begin
    y1 := Image_Graf.Height - (Image_Graf.Height div 10) -
      Round((6 - i) * ScaleInterval);
    x1 := 0;
    x2 := 5;
    y2 := y1 + 5;
    Image_Graf.Canvas.FillRect(Rect(x1, y1, x2, y2));

    // Añade etiquetas de valores en el eje Y
    ValueStep := MaxYValue / 6;
    LabelText := FormatFloat('0', ValueStep * (6 - i));
    Image_Graf.Canvas.TextOut(10, y1 - 10, LabelText);
  end;
end;

// -------------------------------------------------------------

procedure Graficar1(Image_Graf: TImage; pred, data: Integer;
  XValues1, YValues1: TStringList);
var
  i, XPos, YPos, BarWidth, MaxYValue, BarHeight, StartIndex: Integer;
  x1, y1, x2, y2: Integer;
  ScaleInterval, ValueStep: Double;
  LabelText: String;
  TextWidth: Integer;
  can: tCanvas;

begin
  can := Image_Graf.Canvas;
  MaxYValue := 0; // Encuentra el valor máximo para escalar el eje Y

  // Configura el ancho de las barras
  if data + pred > 11 then
  begin
    BarWidth := Image_Graf.Width div ((3 + pred + data) * 2);
  end
  else
  begin
    BarWidth := Image_Graf.Width div 40;
  end;

  // Determina el índice de inicio para los últimos data
  StartIndex := Max(0, YValues1.Count - data);

  // Encuentra el valor máximo de YValues1 y YValues2 para escalar el eje Y
  for i := StartIndex to YValues1.Count - 1 do
  begin
    if StrToFloatDef(YValues1[i], 0) > MaxYValue then
      MaxYValue := Round(StrToFloat(YValues1[i]));
  end;
  if  MaxYValue = 0 then
  begin
       exit
  end;

  for i := StartIndex to YValues1.Count - 1 do
  begin
    BarHeight := Round((StrToFloatDef(YValues1[i], 0) / MaxYValue) *
      (0.8 * Image_Graf.Height - (Image_Graf.Height div 10)));
    XPos := ((i - StartIndex) * 2 * BarWidth) + (Image_Graf.Width div 20) + 25;
    YPos := Image_Graf.Height - (Image_Graf.Height div 10) - BarHeight;

    MyFillRectangle(can, XPos, YPos, XPos + BarWidth,
      Image_Graf.Height - (Image_Graf.Height div 10), clWebDarkRed, 100);
  end;

  // Añade las etiquetas del eje X para XValues1
  Image_Graf.Canvas.brush.Style := bsClear;
  Image_Graf.Canvas.Font.color := clBlack;
  Image_Graf.Canvas.Font.Size := 7;

  for i := StartIndex to XValues1.Count - 1 do
  begin
    TextWidth := Image_Graf.Canvas.TextWidth(XValues1[i]);
    XPos := ((i - StartIndex) * 2 * BarWidth) + 25 + (Image_Graf.Width div 20) +
      ((BarWidth - TextWidth) div 2);
    YPos := Image_Graf.Height - (Image_Graf.Height div 10) + 5;
    Image_Graf.Canvas.TextOut(XPos, YPos, XValues1[i]);
  end;

  // Dibuja divisiones y etiquetas en el eje Y
  ScaleInterval := (0.9 * Image_Graf.Height - (Image_Graf.Height div 6)) / 6;

  for i := 0 to 6 do
  begin
    y1 := Image_Graf.Height - (Image_Graf.Height div 10) -
      Round((6 - i) * ScaleInterval);
    x1 := 0;
    x2 := 5;
    y2 := y1 + 5;
    Image_Graf.Canvas.FillRect(Rect(x1, y1, x2, y2));

    // Añade etiquetas de valores en el eje Y
    ValueStep := MaxYValue / 6;
    LabelText := FormatFloat('0', ValueStep * (6 - i));
    Image_Graf.Canvas.TextOut(10, y1 - 10, LabelText);
  end;
end;

end.
