unit src_PrepDatStrGr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Grids, Vcl.StdCtrls;

function PrepDatStrGr(StringGrid1: TStringGrid; ComBoxY: TComboBox)
  : TStringList;
procedure AddColStGr(StringGrid1: TStringGrid; DataList: TStringList;
  const ColumnName: string);
procedure AddColStGr2(StringGrid1: TStringGrid;
  DataArray: TArray<TArray<Double>>; const ColumnBaseName: string);
procedure CopyStringGrid(SourceGrid, DestGrid: TStringGrid);
function GetColData(StringGrid: TStringGrid; ComboBox: TComboBox): TStringList;
function GetColRowData(StringGrid: TStringGrid; ComboBox: TComboBox)
  : TStringList;
procedure AddColStGr3(StringGrid1: TStringGrid;
  DataArray: TArray<TArray<String>>; const ColumnBaseName: string);
procedure ClearStrGrid(SourceGrid, DestGrid: TStringGrid);
function GetColDataint(StringGrid: TStringGrid; ColIndex: Integer): TStringList;

implementation

function PrepDatStrGr(StringGrid1: TStringGrid; ComBoxY: TComboBox)
  : TStringList;
var
  I: Integer;
  YColumn: Integer;
  YData: TStringList;
  Value: Double;
  TextValue: string;
begin

  YData := TStringList.Create;
  try
    YColumn := ComBoxY.ItemIndex;
    if YColumn < 0 then
      raise Exception.Create('Selecione una columna');

    for I := 1 to StringGrid1.RowCount - 1 do
    begin
      TextValue := StringGrid1.Cells[YColumn, I];

      if TryStrToFloat(TextValue, Value) then
        YData.Add(FloatToStr(Value))
      else
        YData.Add('0');
    end;

    Result := YData;
  except
    YData.Free;
    raise;
  end;

end;

procedure AddColStGr(StringGrid1: TStringGrid; DataList: TStringList;
  const ColumnName: string);
var
  I, ColIndex, NewColumnIndex: Integer;
  ColumnExists: Boolean;
begin
  ColumnExists := False;
  ColIndex := -1;

  // Verificar si ya existe una columna con el mismo nombre
  for I := 0 to StringGrid1.ColCount - 1 do
  begin
    if StringGrid1.Cells[I, 0] = ColumnName then
    begin
      ColumnExists := True;
      ColIndex := I;
      Break;
    end;
  end;

  // Si la columna ya existe, se usará esa columna, de lo contrario, se agrega una nueva
  if ColumnExists then
    NewColumnIndex := ColIndex
  else
  begin
    StringGrid1.ColCount := StringGrid1.ColCount + 1;
    NewColumnIndex := StringGrid1.ColCount - 1;
    // Asignar el nombre a la nueva columna
    StringGrid1.Cells[NewColumnIndex, 0] := ColumnName;
  end;

  // Ajustar el número de filas del StringGrid si es necesario
  if StringGrid1.RowCount < DataList.Count + 1 then
    StringGrid1.RowCount := DataList.Count + 1;

  // Llenar la columna (existente o nueva) con los datos del TStringList
  for I := 0 to DataList.Count - 1 do
  begin
    StringGrid1.Cells[NewColumnIndex, I + 1] := DataList[I];
  end;
end;
// _______________________________________________________________________

procedure AddColStGr2(StringGrid1: TStringGrid;
  DataArray: TArray<TArray<Double>>; const ColumnBaseName: string);
var
  I, J, ColIndex, NewColumnIndex: Integer;
  ColumnName: string;
  ColumnExists: Boolean;
begin
  // Iterar sobre cada columna del TArray TArray Double
  for J := 0 to Length(DataArray[0]) - 1 do
  begin

    ColumnName := ColumnBaseName + IntToStr(J + 1);

    ColumnExists := False;
    ColIndex := -1;
    for I := 0 to StringGrid1.ColCount - 1 do
    begin
      if (StringGrid1.Cells[I, 0] = ColumnName) then
      begin
        ColumnExists := True;
        ColIndex := I;
        Break;
      end;
    end;

    if ColumnExists then
      NewColumnIndex := ColIndex
    else
    begin
      StringGrid1.ColCount := StringGrid1.ColCount + 1;
      NewColumnIndex := StringGrid1.ColCount - 1;
      // Asignar el nombre a la nueva columna
      StringGrid1.Cells[NewColumnIndex, 0] := ColumnName;
    end;

    // Ajustar el número de filas del StringGrid si es necesario
    if StringGrid1.RowCount < Length(DataArray) + 1 then
      StringGrid1.RowCount := Length(DataArray) + 1;

    // Llenar la columna (existente o nueva) con los datos correspondientes de la matriz
    for I := 0 to Length(DataArray) - 1 do
    begin
      StringGrid1.Cells[NewColumnIndex, I + 1] := FloatToStr(DataArray[I, J]);
    end;
  end;
end;

// _________________________________________________
procedure AddColStGr3(StringGrid1: TStringGrid;
  DataArray: TArray<TArray<String>>; const ColumnBaseName: string);
var
  I, J, ColIndex, NewColumnIndex: Integer;
  ColumnName: string;
  ColumnExists: Boolean;
begin
  try
    for J := 0 to Length(DataArray[0]) - 1 do
    begin
      ColumnName := ColumnBaseName + IntToStr(J + 1);

      ColumnExists := False;
      ColIndex := -1;
      for I := 0 to StringGrid1.ColCount - 1 do
      begin
        // Verificar si la columna existe o si el encabezado está vacío
        if (StringGrid1.Cells[I, 0] = ColumnName) or
          (StringGrid1.Cells[I, 0] = '') then
        begin
          ColumnExists := True;
          ColIndex := I;
          // Si el encabezado está vacío, asignar el nombre
          if StringGrid1.Cells[I, 0] = '' then
            StringGrid1.Cells[I, 0] := ColumnName;
          Break;
        end;
      end;

      if ColumnExists then
        NewColumnIndex := ColIndex
      else
      begin
        StringGrid1.ColCount := StringGrid1.ColCount + 1;
        NewColumnIndex := StringGrid1.ColCount - 1;
        // Asignar el nombre a la nueva columna
        StringGrid1.Cells[NewColumnIndex, 0] := ColumnName;
      end;

      // Ajustar el número de filas del StringGrid si es necesario
      if not(StringGrid1.RowCount = Length(DataArray) + 1) then
        StringGrid1.RowCount := Length(DataArray) + 1;
      if not(StringGrid1.ColCount = Length(DataArray[0])) then
        StringGrid1.ColCount := Length(DataArray[0]);

      // Llenar la columna (existente o nueva) con los datos correspondientes de la matriz
      for I := 0 to Length(DataArray) - 1 do
      begin
        StringGrid1.Cells[NewColumnIndex, I + 1] := DataArray[I, J];
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end;


// _____________________________________________________________

procedure ClearStrGrid(SourceGrid, DestGrid: TStringGrid);
var
  I, J: Integer;
begin
  // Limpiar el DestGrid
  DestGrid.RowCount := 1;
  DestGrid.ColCount := 1;

  // Ajustar la estructura del DestGrid para que coincida con el SourceGrid
  DestGrid.ColCount := SourceGrid.ColCount;
  DestGrid.RowCount := SourceGrid.RowCount;
  // Copiar las propiedades del SourceGrid al DestGrid
  DestGrid.FixedCols := SourceGrid.FixedCols;
  DestGrid.FixedRows := SourceGrid.FixedRows;
  DestGrid.Options := SourceGrid.Options;
end;

// _____________________________________________________________
procedure CopyStringGrid(SourceGrid, DestGrid: TStringGrid);
var
  I, J: Integer;
begin
  // Limpiar el DestGrid
  DestGrid.RowCount := 1; // Mantener solo la fila de encabezado
  DestGrid.ColCount := 1; // Mantener solo una columna

  // Ajustar la estructura del DestGrid para que coincida con el SourceGrid
  DestGrid.ColCount := SourceGrid.ColCount;
  DestGrid.RowCount := SourceGrid.RowCount;
  // Copiar las propiedades del SourceGrid al DestGrid
  DestGrid.FixedCols := SourceGrid.FixedCols;
  DestGrid.FixedRows := SourceGrid.FixedRows;
  DestGrid.Options := SourceGrid.Options;
  // Esto copia todas las opciones, incluido goColSizing

  // Copiar los valores del SourceGrid al DestGrid
  for I := 0 to SourceGrid.ColCount - 1 do
  begin
    for J := 0 to SourceGrid.RowCount - 1 do
    begin
      DestGrid.Cells[I, J] := SourceGrid.Cells[I, J];
    end;
  end;
end;

// ______________________________________________________________
function GetColRowData(StringGrid: TStringGrid; ComboBox: TComboBox)
  : TStringList;
var
  I, J, ColIndex: Integer;
  SelectedColumnList: TStringList;
begin
  SelectedColumnList := TStringList.Create;
  try
    ColIndex := ComboBox.ItemIndex;

    // Verificar que ColIndex sea válido
    if (ColIndex >= 0) and (ColIndex < StringGrid.ColCount) then
    begin
      // Recorre la columna seleccionada
      for I := 1 to StringGrid.RowCount - 1 do
      begin
        SelectedColumnList.Add(StringGrid.Cells[ColIndex, I]);
      end;

      // Una vez en la última fila, recorre hacia la derecha hasta el final del StringGrid
      for J := ColIndex + 1 to StringGrid.ColCount - 1 do
      begin
        SelectedColumnList.Add(StringGrid.Cells[J, StringGrid.RowCount - 1]);
      end;
    end;

    Result := SelectedColumnList;
  except
    SelectedColumnList.Free;
    raise;
  end;
end;

// ___________________________________________________
function GetColData(StringGrid: TStringGrid; ComboBox: TComboBox): TStringList;
var
  I, J, ColIndex: Integer;
  SelectedColumnList: TStringList;
begin
  SelectedColumnList := TStringList.Create;
  try
    ColIndex := ComboBox.ItemIndex;

    // Verificar que ColIndex sea válido
    if (ColIndex >= 0) and (ColIndex < StringGrid.ColCount) then
    begin
      // Recorre la columna seleccionada
      for I := 1 to StringGrid.RowCount - 1 do
      begin
        SelectedColumnList.Add(StringGrid.Cells[ColIndex, I]);
      end;

    end;

    Result := SelectedColumnList;
  except
    SelectedColumnList.Free;
    raise;
  end;
end;

// ___________________________________________________
function GetColDataint(StringGrid: TStringGrid; ColIndex: Integer): TStringList;
var
  I, J: Integer;
  SelectedColumnList: TStringList;
begin
  SelectedColumnList := TStringList.Create;
  try

    // Verificar que ColIndex sea válido
    if (ColIndex >= 0) and (ColIndex < StringGrid.ColCount) then
    begin
      // Recorre la columna seleccionada
      for I := 1 to StringGrid.RowCount - 1 do
      begin
        SelectedColumnList.Add(StringGrid.Cells[ColIndex, I]);
      end;

    end;

    Result := SelectedColumnList;
  except
    SelectedColumnList.Free;
    raise;
  end;
end;

end.
