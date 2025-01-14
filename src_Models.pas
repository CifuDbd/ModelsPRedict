unit src_Models;

interface

uses
  src_Pred_Mod, System.SysUtils, System.Classes, System.Types,
  Vcl.Grids, Vcl.Dialogs, System.JSON, REST.Client, Math;

implementation

// __________________________________________________
function MAPE(RealV, PredV: TStringList): Double;
var
  Sum, Error: Double;
  I, n: Integer;
begin
  Sum := 0;
  n := RealV.Count;

  if n = 0 then
  begin
    Result := 0; // Evita división por cero
    Exit;
  end;

  for I := 0 to n - 1 do
  begin
    if StrToFloat(RealV[I]) <> 0 then // Evita división por cero
    begin
      Error := Abs((StrToFloat(RealV[I]) - StrToFloat(PredV[I])) /
        StrToFloat(RealV[I]));
      Sum := Sum + Error;
    end
    else
    begin

      Sum := Sum + 0;
    end;
  end;

  // Calcula el MAPE
  Result := (Sum / n) * 100; // Multiplicado por 100 para porcentaje
end;

// ________________________________________


function MAPExMod(RealV: TStringList; PredV: TArray<TArray<Double>>;
  Temp: Integer): TArray<Double>;
var
  Sum, Error: Double;
  I, J, n: Integer;
  x, y: Integer;
  Res: TArray<Double>;
begin

  Sum := 0;
  n := RealV.Count;
  x := Length(PredV[0]);
  y := Length(PredV);
  if (n = 0) or (x = 0) or (y = 0) then
  begin
    Result := 0; // Evita división por cero
    Exit;
  end;
  SetLength(Res, x);
  for J := 0 to x - 1 do
  begin
    for I := Temp - 1 to n - 1 do
    begin
      if (StrToFloat(RealV[I]) <> 0) and ((I + J) <= n - 1) then
      begin
        Error := Abs((StrToFloat(RealV[I + J]) - (PredV[I][J])) /
          StrToFloat(RealV[I+J]));
        Sum := Sum + Error;
      end
      else
      begin

        Sum := Sum + 0;
      end;
    end;

    Res[J] := (Sum / n) * 100;
    Sum := 0;
  end;

  Result := Res;
end;

procedure Swap(var A, B: Integer);
var
  Temp: Integer;
begin
  Temp := A;
  A := B;
  B := Temp;
end;

end.
