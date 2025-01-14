unit src_cbCol;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.StdCtrls;

procedure cbcol(StringGrid1: TStringGrid; ComBoxX: TComboBox;
  ComBoxY: TComboBox);
procedure cbcol1(StringGrid1: TStringGrid; ComBoxX: TComboBox);

implementation

procedure cbcol(StringGrid1: TStringGrid; ComBoxX, ComBoxY: TComboBox);
var
  i: Integer;
  XData: array of String;
  YData: array of Integer;
  XPos, YPos: Integer;
begin
  ComBoxX.Clear;
  ComBoxY.Clear;

  // Poblar cbXAxis y cbYAxis con los nombres de las columnas
  for i := 0 to StringGrid1.ColCount - 1 do
  begin
    ComBoxX.Items.Add(StringGrid1.Cells[i, 0]);
    // Suponiendo que la primera fila tiene los nombres de las columnas
    ComBoxY.Items.Add(StringGrid1.Cells[i, 0]);
  end;

end;

procedure cbcol1(StringGrid1: TStringGrid; ComBoxX: TComboBox);
var
  i: Integer;
  XData: array of String;
  YData: array of Integer;
  XPos, YPos: Integer;
begin
  ComBoxX.Clear;

  // Poblar cbXAxis y cbYAxis con los nombres de las columnas
  for i := 0 to StringGrid1.ColCount - 1 do
  begin
    ComBoxX.Items.Add(StringGrid1.Cells[i, 0]);

  end;

end;

end.
