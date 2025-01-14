unit scr_ARIMAPM;

interface

uses
  src_Pred_Mod, System.SysUtils, System.Classes, System.Types, Math;

type
  TARModel = class(TPredictionModels)
  protected
    FOrder: Integer; // Orden del modelo AR
    function CalculateCoefficients(const X: TArray<TArray<Double>>;
      const Y: TArray<Double>): TArray<Double>;
  public
    constructor Create(StrLis: TStringList; Order: Integer); reintroduce;
    function Predict(NumberOfPredictions: Integer)
      : TArray<TArray<Double>>; override;
  end;

implementation

constructor TARModel.Create(StrLis: TStringList; Order: Integer);
begin
  inherited Create(StrLis);
  FOrder := Order;
end;

function TARModel.CalculateCoefficients(const X: TArray<TArray<Double>>;
  const Y: TArray<Double>): TArray<Double>;
var
  i, j, n, p: Integer;
  SumX, SumY, SumXY, SumXX: Double;
  Coefs: TArray<Double>;
begin
  p := Length(X[0]);
  n := Length(X);
  SetLength(Coefs, p);

  for j := 0 to p - 1 do
  begin
    SumX := 0;
    SumY := 0;
    SumXY := 0;
    SumXX := 0;
    for i := 0 to n - 1 do
    begin
      SumX := SumX + X[i, j];
      SumY := SumY + Y[i];
      SumXY := SumXY + X[i, j] * Y[i];
      SumXX := SumXX + X[i, j] * X[i, j];
    end;
    Coefs[j] := (SumXY - (SumX * SumY) / n) / (SumXX - (SumX * SumX) / n);
  end;

  Result := Coefs;
end;

function TARModel.Predict(NumberOfPredictions: Integer): TArray<TArray<Double>>;
var
  i, j, n, k: Integer;
  X: TArray<TArray<Double>>;
  Y: TArray<Double>;
  Coefs: TArray<Double>;
  Predicciones: TArray<TArray<Double>>;
begin
  n := FStrLis.Count;
  SetLength(Predicciones, n + 1, NumberOfPredictions);
  // Ajustar el tamaño de la matriz

  for k := 0 to NumberOfPredictions - 1 do
  begin
    SetLength(X, n - FOrder - k);
    for i := 0 to Length(X) - 1 do
      SetLength(X[i], FOrder);

    SetLength(Y, n - FOrder - k);

    // Preparar las matrices X e Y para la regresión
    for i := 0 to Length(X) - 1 do
    begin
      for j := 0 to FOrder - 1 do
      begin
        X[i][j] := StrToFloat(FStrLis[i + j]);
      end;
      Y[i] := StrToFloat(FStrLis[i + FOrder + k]);
    end;

    // Calcular los coeficientes de la regresión lineal usando mínimos cuadrados
    Coefs := CalculateCoefficients(X, Y);

    // Calcular las predicciones usando los coeficientes obtenidos
    for i := 0 to FOrder - 1 + k do
    begin
      Predicciones[i, k] := 0; // Los primeros FOrder valores se dejan en 0
    end;

    for i := FOrder to n - k do
    begin
      Predicciones[i + k, k] := 0;
      for j := 0 to FOrder - 1 do
      begin
        Predicciones[i + k, k] := Predicciones[i + k, k] + Coefs[j] *
          StrToFloat(FStrLis[i - FOrder + j]);
      end;
    end;
  end;

  Result := Predicciones;
end;

end.
