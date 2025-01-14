unit src_ARIMA;

interface

uses
  Variants, Contnrs, System.SysUtils, System.Classes, Math;

function AutoCorrelation(StrLis: TStringList; p, pre: Integer)
  : TArray<TArray<Double>>;
function ARMA(StrLis: TStringList; ar, ma, pre: Integer)
  : TArray<TArray<Double>>;

function Differencing(StrLis: TStringList; d: Integer): TArray<TArray<Double>>;
function ARIMA(StrLis: TStringList; ar, int, ma, pre: Integer)
  : TArray<TArray<Double>>;
function TStringListToDoubleArray(StrLis: TStringList): TArray<TArray<Double>>;

function CalcularCoeficientes(X: TArray<TArray<Double>>; Y: TArray<Double>)
  : TArray<Double>;

implementation

function AutoCorrelation(StrLis: TStringList; p, pre: Integer)
  : TArray<TArray<Double>>;
var
  i, j, n, k: Integer;
  X: array of array of Double;
  Y: array of Double;
  Coefs: array of Double;
  Predicciones: TArray<TArray<Double>>;
  SumX, SumY, SumXY, SumXX: Double;
begin
  n := StrLis.Count;
  SetLength(Predicciones, n + 1, pre); // Ajustar el tamaño de la matriz

  for k := 0 to pre - 1 do
  begin
    SetLength(X, n - p - k, p);
    SetLength(Y, n - p - k);
    SetLength(Coefs, p);

    // Preparar las matrices X e Y para la regresión
    for i := 0 to n - p - 1 - k do
    begin
      for j := 0 to p - 1 do
      begin
        X[i, j] := StrToFloat(StrLis[i + j]);
      end;
      Y[i] := StrToFloat(StrLis[i + p + k]);
    end;

    // Calcular los coeficientes de la regresión lineal usando mínimos cuadrados
    for j := 0 to p - 1 do
    begin
      SumX := 0;
      SumY := 0;
      SumXY := 0;
      SumXX := 0;
      for i := 0 to n - p - 1 - k do
      begin
        SumX := SumX + X[i, j];
        SumY := SumY + Y[i];
        SumXY := SumXY + X[i, j] * Y[i];
        SumXX := SumXX + X[i, j] * X[i, j];
      end;
      Coefs[j] := (SumXY - (SumX * SumY) / (n - p - k)) /
        (SumXX - (SumX * SumX) / (n - p - k));
    end;

    // Calcular las predicciones usando los coeficientes obtenidos
    for i := 0 to p - 1 + k do
    begin
      Predicciones[i, k] := 0; // Los primeros p valores se dejan en 0
    end;

    for i := p to n - k do
    begin
      Predicciones[i + k, k] := 0;
      for j := 0 to p - 1 do
      begin
        Predicciones[i + k, k] := Predicciones[i + k, k] + Coefs[j] *
          StrToFloat(StrLis[i - p + j]);
      end;
    end;
  end;

  Result := Predicciones;
end;





// ___________________________________---

function ARMA(StrLis: TStringList; ar, ma, pre: Integer)
  : TArray<TArray<Double>>;
var
  i, j, n, k: Integer;
  X: array of array of Double;
  Y: array of Double;
  Coefs: array of Double;
  Predicciones_ar: TArray<TArray<Double>>;
  Predicciones_ma: TArray<TArray<Double>>;
  Predicciones_arma: TArray<TArray<Double>>;
  SumX, SumY, SumXY, SumXX: Double;
begin

  n := StrLis.Count;

  // Ajustar el tamaño de las matrices de predicción
  SetLength(Predicciones_ar, n + 1, pre);
  SetLength(Predicciones_ma, n + 1, pre);
  SetLength(Predicciones_arma, n + 1, pre);

  for k := 0 to pre - 1 do
  begin
    // Ajustar el tamaño de las matrices X e Y para la parte AR
    SetLength(X, n - ar - k, ar);
    SetLength(Y, n - ar - k);
    SetLength(Coefs, ar);

    // Preparar las matrices X e Y para la regresión AR
    for i := 0 to n - ar - 1 - k do
    begin
      for j := 0 to ar - 1 do
      begin
        X[i, j] := StrToFloat(StrLis[i + j]);
      end;
      Y[i] := StrToFloat(StrLis[i + ar + k]);
    end;

    // Calcular los coeficientes de la regresión lineal usando mínimos cuadrados
    for j := 0 to ar - 1 do
    begin
      SumX := 0;
      SumY := 0;
      SumXY := 0;
      SumXX := 0;
      for i := 0 to n - ar - 1 - k do
      begin
        SumX := SumX + X[i, j];
        SumY := SumY + Y[i];
        SumXY := SumXY + X[i, j] * Y[i];
        SumXX := SumXX + X[i, j] * X[i, j];
      end;
      Coefs[j] := (SumXY - (SumX * SumY) / (n - ar - k)) /
        (SumXX - (SumX * SumX) / (n - ar - k));
    end;

    // Calcular las predicciones AR usando los coeficientes obtenidos
    for i := 0 to ar - 1 + k do
    begin
      Predicciones_ar[i, k] := 0; // Los primeros p valores se dejan en 0
    end;

    for i := ar to n - k do
    begin
      Predicciones_ar[i + k, k] := 0;
      for j := 0 to ar - 1 do
      begin
        Predicciones_ar[i + k, k] := Predicciones_ar[i + k, k] + Coefs[j] *
          StrToFloat(StrLis[i - ar + j]);
      end;
    end;

    // Ajustar el tamaño de las matrices X e Y para la parte MA
    SetLength(X, n - ma - k, ma);
    SetLength(Y, n - ma - k);
    SetLength(Coefs, ma);

    // Preparar las matrices X e Y para la regresión MA
    for i := ar to n - ma - 1 - k do
    begin
      for j := 0 to ma - 1 do
      begin
        X[i, j] := StrToFloat(StrLis[i + j + k]) - Predicciones_ar[i + j, k];
      end;
      Y[i] := StrToFloat(StrLis[i + ma + k]) - Predicciones_ar[i + ma, k];
    end;

    // Calcular los coeficientes de la regresión lineal usando mínimos cuadrados (para MA)
    for j := 0 to ma - 1 do
    begin
      SumX := 0;
      SumY := 0;
      SumXY := 0;
      SumXX := 0;
      for i := 0 to n - ma - 1 - k do
      begin
        SumX := SumX + X[i, j];
        SumY := SumY + Y[i];
        SumXY := SumXY + X[i, j] * Y[i];
        SumXX := SumXX + X[i, j] * X[i, j];
      end;
      Coefs[j] := (SumXY - (SumX * SumY) / (n - ma - k)) /
        (SumXX - (SumX * SumX) / (n - ma - k));
    end;

    // Calcular las predicciones MA usando los coeficientes obtenidos
    for i := 0 to ma - 1 + k + ar do
    begin
      Predicciones_ma[i, k] := 0; // Los primeros p valores se dejan en 0
    end;

    for i := ma + ar to n - k do
    begin
      Predicciones_ma[i + k, k] := 0;
      for j := 0 to ma - 1 do
      begin
        Predicciones_ma[i + k, k] := Predicciones_ma[i + k, k] + Coefs[j] *
          (StrToFloat(StrLis[i - ma + j + k]) - Predicciones_ar[i - ma + j, k]);
      end;
    end;
  end;

  // Combinar predicciones AR y MA en ARMA
  for i := 0 to n do
  begin
    for j := 0 to pre - 1 do
    begin
      Predicciones_arma[i, j] := Predicciones_ar[i, j] + Predicciones_ma[i, j];
    end;
  end;

  Result := Predicciones_arma;
end;




// ------------------------------------------------------------------------

function ARIMA(StrLis: TStringList; ar, int, ma, pre: Integer)
  : TArray<TArray<Double>>;
var
  i, j, n, k: Integer;
  X: TArray<TArray<Double>>;
  Y: TArray<Double>;
  Coefs: TArray<Double>;
  Diferenciados, Predicciones_ar, Predicciones_ma, Predicciones_arma,
    Predicciones_final: TArray<TArray<Double>>;
begin
  if int > 0 then
  begin
    Diferenciados := Differencing(StrLis, int);
    n := Length(Diferenciados);
  end
  else
  begin
    Diferenciados := TStringListToDoubleArray(StrLis);
    n := StrLis.Count;
  end;

  SetLength(Predicciones_ar, n + 1, pre);
  SetLength(Predicciones_ma, n + 1, pre);
  SetLength(Predicciones_arma, n + 1, pre);
  SetLength(Predicciones_final, n + 1, pre);

  for k := 0 to pre - 1 do
  begin
    if ar > 0 then
    begin
      SetLength(X, n - ar - k, ar);
      SetLength(Y, n - ar - k);

      for i := 0 to n - ar - 1 - k do
      begin
        for j := 0 to ar - 1 do
        begin
          X[i, j] := Diferenciados[i + j, 0];
        end;
        Y[i] := Diferenciados[i + ar + k, 0];
      end;

      Coefs := CalcularCoeficientes(X, Y);

      for i := ar to n - k do
      begin
        Predicciones_ar[i + k, k] := 0;
        for j := 0 to ar - 1 do
        begin
          Predicciones_ar[i + k, k] := Predicciones_ar[i + k, k] + Coefs[j] *
            Diferenciados[i - ar + j, 0];
        end;
      end;
    end;

    if ma > 0 then
    begin
      SetLength(X, n - ma - k, ma);
      SetLength(Y, n - ma - k);

      for i := 0 to n - ma - 1 - k do
      begin
        for j := 0 to ma - 1 do
        begin
          X[i, j] := Diferenciados[i + j + k, 0] - Predicciones_ar[i + j, k];
        end;
        Y[i] := Diferenciados[i + ma + k, 0] - Predicciones_ar[i + ma, k];
      end;

      Coefs := CalcularCoeficientes(X, Y);

      for i := ma to n - k do
      begin
        Predicciones_ma[i + k, k] := 0;
        for j := 0 to ma - 1 do
        begin
          Predicciones_ma[i + k, k] := Predicciones_ma[i + k, k] + Coefs[j] *
            (Diferenciados[i - ma + j + k, 0] - Predicciones_ar[i - ma + j, k]);
        end;
      end;
    end;
  end;

  for i := 0 to n do
  begin
    for j := 0 to pre - 1 do
    begin
      Predicciones_arma[i, j] := 0;
      if ar > 0 then
        Predicciones_arma[i, j] := Predicciones_ar[i, j];
      if ma > 0 then
        Predicciones_arma[i, j] := Predicciones_arma[i, j] +
          Predicciones_ma[i, j];
    end;
  end;
  if int > 0 then
  begin
    for i := int to n do
    begin
      for j := 0 to pre - 1 do
      begin
        Predicciones_final[i, j] := Predicciones_arma[i, j] +
          StrToFloat(StrLis[i - int]);
      end;
    end;
      Result := Predicciones_final;
  end
  else
  begin
     Result := Predicciones_arma;
  end;


end;

// ------------------------------------------------------------------------
function Differencing(StrLis: TStringList; d: Integer): TArray<TArray<Double>>;
var
  i, j, n: Integer;
  Diferenci: TArray<TArray<Double>>;
  tempList: TArray<Double>;
begin
  n := StrLis.Count;

  if (d < 1) then
  begin
    // Inicializar la matriz con una columna y n filas
    SetLength(Diferenci, n, 1);
    for i := 0 to n - 1 do
      Diferenci[i, 0] := StrToFloat(StrLis[i]);
    Result := Diferenci;
    Exit;
  end;

  // Inicializar el array de diferencias
  SetLength(Diferenci, n, 1);

  // Convertir los elementos de StrLis a un array de Double
  SetLength(tempList, n);
  for i := 0 to n - 1 do
    tempList[i] := StrToFloat(StrLis[i]);

  // Realizar diferenciación de orden d
  for j := 1 to d do
  begin
    for i := n - 1 downto j do
    begin
      tempList[i] := tempList[i] - tempList[i - 1];
    end;
  end;

  for i := 0 to n - 1 do
  begin
    Diferenci[i, 0] := tempList[i];
  end;

  Result := Diferenci;
end;

// _______________________________________--
function TStringListToDoubleArray(StrLis: TStringList): TArray<TArray<Double>>;
var
  i: Integer;
begin
  SetLength(Result, StrLis.Count, 1);
  for i := 0 to StrLis.Count - 1 do
  begin
    Result[i, 0] := StrToFloat(StrLis[i]);
  end;
end;

// _______________________________________--

function CalcularCoeficientes(X: TArray<TArray<Double>>; Y: TArray<Double>)
  : TArray<Double>;
var
  i, j, n, p: Integer;
  SumX, SumY, SumXY, SumXX: Double;
  Coefs: TArray<Double>;
begin
  n := Length(Y);
  p := Length(X[0]);
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

end.
