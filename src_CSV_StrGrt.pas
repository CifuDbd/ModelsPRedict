unit src_CSV_StrGrt;

interface

uses
  Vcl.Controls, Vcl.Grids, Vcl.Dialogs, System.SysUtils, System.Classes,
  System.JSON, REST.Client;
procedure LoadCSVToStringGrid(StringGrid1: TStringGrid; const FileName: string;
  sep: Char);

implementation

procedure LoadCSVToStringGrid(StringGrid1: TStringGrid; const FileName: string;
  sep: Char);
var
  FileLines: TStringList;
  Columns: TStringList;
  I, J: Integer;
begin
  FileLines := TStringList.Create;
  Columns := TStringList.Create;
  try
    FileLines.LoadFromFile(FileName);
    StringGrid1.RowCount := FileLines.Count;
    Columns.Delimiter := sep;
    for I := 0 to FileLines.Count - 1 do
    begin
      Columns.DelimitedText := FileLines[I];

      if I = 1 then
      begin
        StringGrid1.ColCount := Columns.Count;
      end;

      for J := 0 to Columns.Count - 1 do
      begin
        StringGrid1.Cells[J, I] := Columns[J];
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
  FileLines.Free;
  Columns.Free;

end;

end.
