unit src_Mod_HW;

interface

uses
  System.SysUtils, System.Classes, Math;

function WeightedMovingAverage(StrLis: TStringList; delta: Double; pre: Integer)
  : TArray<TArray<Double>>;

function Holt(StrLis: TStringList; alpha, beta: Double; futureSteps: Integer)
  : TArray<TArray<Double>>;
function HoltWintersAdditive(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TStringList;

function HoltWintersMul(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TStringList;
function CrePredHWAd(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TArray<TArray<Double>>;
function CrePredHWMul(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TArray<TArray<Double>>;

implementation

function WeightedMovingAverage(StrLis: TStringList; delta: Double; pre: Integer)
  : TArray<TArray<Double>>;
var
  i, j, n, k: Integer;
  InitialCount: Integer;
  WeightedSum, Average: Double;
  Predicciones: TArray<TArray<Double>>;
begin
  n := StrLis.Count;
  SetLength(Predicciones, n + 1, pre); // Ajustar el tamaño de la matriz

  // Calcular el 5% del tamaño de la lista y redondear hacia arriba
  InitialCount := Ceil(n * 0.05);

  // Calcular el promedio de los primeros elementos
  WeightedSum := 0;
  for i := 0 to InitialCount - 1 do
  begin
    WeightedSum := WeightedSum + StrToFloat(StrLis[i]);
  end;
  Average := WeightedSum / InitialCount;

  // Establecer el valor inicial de la predicción
  for k := 0 to pre - 1 do
  begin
    Predicciones[0, k] := Average;
  end;

  // Calcular los demás elementos de la matriz de predicciones
  for k := 0 to pre - 1 do
  begin
    for i := 1 to n do
    begin
      if i + k < n then
      begin
        Predicciones[i, k] := delta * StrToFloat(StrLis[i]) + (1 - delta) *
          Predicciones[i - 1, k];
      end
      else
      begin
        Predicciones[i, k] := Predicciones[i - 1, k];
      end;
    end;
  end;

  // Devolver la matriz de predicciones
  Result := Predicciones;
end;


// ----------------------------

function Holt(StrLis: TStringList; alpha, beta: Double; futureSteps: Integer)
  : TArray<TArray<Double>>;
var
  i, j, n: Integer;
  InitialCount: Integer;
  WeightedSum: Double;
  Level, Trend, Forecast: Double;
  Predictions: TArray<TArray<Double>>;
begin
  // Crear la lista de predicciones
  n := StrLis.Count;
  SetLength(Predictions, n + 1, futureSteps + 1);
  // Calcular el 5% del tamaño de la lista y redondear hacia arriba
  InitialCount := Ceil(StrLis.Count * 0.05);

  // Calcular el nivel inicial (Average) y la tendencia inicial
  WeightedSum := 0;
  for i := 0 to InitialCount - 1 do
  begin
    WeightedSum := WeightedSum + StrToFloat(StrLis[i]);
  end;
  Level := WeightedSum / InitialCount;
  Trend := (StrToFloat(StrLis[InitialCount - 1]) - StrToFloat(StrLis[0])) /
    (InitialCount - 1);

  // Agregar el primer pronóstico a la lista de predicciones
  Predictions[0, 0] := (Level + Trend);

  // Calcular los demás elementos de la lista de predicciones
  for i := 0 to StrLis.Count - 1 do
  begin
    // Actualizar el nivel y la tendencia
    Level := alpha * StrToFloat(StrLis[i]) + (1 - alpha) * (Level + Trend);
    Trend := beta * (Level - (Predictions[i, 0])) + (1 - beta) * Trend;

    // Calcular el pronóstico
    Forecast := Level + Trend;

    // Agregar el pronóstico a la lista de predicciones
    Predictions[i + 1, 0] := (Forecast);

    if i = StrLis.Count - 1 then
    begin
      for j := 1 to futureSteps do
      begin
        Level := alpha * StrToFloat(StrLis[i]) + (1 - alpha) * (Level + Trend);
        Trend := beta * (Level - (Predictions[StrLis.Count, j - 1])) +
          (1 - beta) * Trend;
        Forecast := Level + Trend;
        Predictions[StrLis.Count, j] := (Forecast);
      end;

    end;
  end;

  // Devolver la lista de predicciones
  Result := Predictions;
end;


// -------------------------------------------------

function HoltWintersAdditive(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TStringList;
var
  i: Integer;
  InitialCount: Integer;
  WeightedSum, Level, Trend, Seasonality, Forecast: Double;
  Predictions, Seasonal: TStringList;
begin
  Predictions := TStringList.Create;
  Seasonal := TStringList.Create;

  // Calcular el 5% del tamaño de la lista y redondear hacia arriba
  InitialCount := Ceil(StrLis.Count * 0.05) + 1;

  // Calcular el nivel inicial (promedio) y la tendencia inicial
  WeightedSum := 0;
  for i := 0 to InitialCount - 1 do
  begin
    WeightedSum := WeightedSum + StrToFloat(StrLis[i]);
  end;
  Level := WeightedSum / InitialCount;
  Trend := (StrToFloat(StrLis[InitialCount - 1]) - StrToFloat(StrLis[0])) /
    (InitialCount - 1);

  // Inicializar la componente estacional para la primera temporada
  for i := 0 to seasonLength - 1 do
  begin
    Seasonality := StrToFloat(StrLis[i]) - Level;
    Seasonal.Add(FloatToStr(Seasonality));
  end;

  // Agregar las primeras predicciones a la lista
  for i := 0 to StrLis.Count - 1 do
  begin
    Seasonality := StrToFloat(Seasonal[i mod seasonLength]);

    // Actualizar el nivel y la tendencia
    Level := alpha * (StrToFloat(StrLis[i]) - Seasonality) + (1 - alpha) *
      (Level + Trend);
    Trend := beta * (Level - (Level - Trend)) + (1 - beta) * Trend;
    Seasonality := gamma * (StrToFloat(StrLis[i]) - Level) + (1 - gamma) *
      Seasonality;

    // Calcular el pronóstico
    Forecast := Level + Trend + Seasonality;

    // Actualizar la componente estacional
    Seasonal[i mod seasonLength] := FloatToStr(Seasonality);

    // Agregar el pronóstico a la lista de predicciones
    Predictions.Add(FloatToStr(Forecast));
  end;

  // Generar predicciones futuras
  for i := 0 to futureSteps - 1 do
  begin
    Seasonality := StrToFloat(Seasonal[(StrLis.Count + i) mod seasonLength]);
    Forecast := Level + ((i + 1) * Trend) + Seasonality;
    Predictions.Add(FloatToStr(Forecast));
  end;

  Result := Predictions;
end;



// -------------------------------------------------

function HoltWintersMul(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TStringList;
var
  i: Integer;
  InitialCount: Integer;
  WeightedSum, Level, Trend, Seasonality, Forecast: Double;
  Predictions, Seasonal: TStringList;
begin
  Predictions := TStringList.Create;
  Seasonal := TStringList.Create;

  // Calcular el 5% del tamaño de la lista y redondear hacia arriba
  InitialCount := Ceil(StrLis.Count * 0.05) + 1;

  // Calcular el nivel inicial (promedio) y la tendencia inicial
  WeightedSum := 0;
  for i := 0 to InitialCount - 1 do
  begin
    WeightedSum := WeightedSum + StrToFloat(StrLis[i]);
  end;
  Level := WeightedSum / InitialCount;
  Trend := (StrToFloat(StrLis[InitialCount - 1]) - StrToFloat(StrLis[0])) /
    (InitialCount - 1);

  // Inicializar la componente estacional para la primera temporada
  for i := 0 to seasonLength - 1 do
  begin
    Seasonality := StrToFloat(StrLis[i]) / Level;
    Seasonal.Add(FloatToStr(Seasonality));
  end;

  // Agregar el primer pronóstico a la lista de predicciones
  for i := 0 to StrLis.Count - 1 do
  begin
    Seasonality := StrToFloat(Seasonal[i mod seasonLength]);

    // Actualizar el nivel y la tendencia
    Level := alpha * (StrToFloat(StrLis[i]) / Seasonality) + (1 - alpha) *
      (Level + Trend);
    Trend := beta * (Level - (Level - Trend)) + (1 - beta) * Trend;
    Seasonality := gamma * (StrToFloat(StrLis[i]) / Level) + (1 - gamma) *
      Seasonality;

    // Calcular el pronóstico
    Forecast := (Level + Trend) * Seasonality;

    // Actualizar la componente estacional
    Seasonal[i mod seasonLength] := FloatToStr(Seasonality);

    // Agregar el pronóstico a la lista de predicciones
    Predictions.Add(FloatToStr(Forecast));
  end;

  // Generar predicciones futuras
  for i := 0 to futureSteps - 1 do
  begin
    Seasonality := StrToFloat(Seasonal[(StrLis.Count + i) mod seasonLength]);
    Forecast := (Level + (i + 1) * Trend) * Seasonality;
    Predictions.Add(FloatToStr(Forecast));
  end;

  Result := Predictions;
end;


// ______________________________________________________

function CrePredHWAd(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TArray<TArray<Double>>;
var
  i, j: Integer;
  Predicciones: TStringList;
  resultados: TArray<TArray<Double>>;
  valor: Double;
  tempList: TStringList;
begin
  // Inicializar el array de resultados
  SetLength(resultados, StrLis.Count + 1, futureSteps );

  // Rellenar los primeros 'seasonLength' elementos con ceros
  for i := 0 to seasonLength - 1 do
    for j := 0 to futureSteps - 1 do
      resultados[i][j] := 0.0;

  // Comenzar desde 'seasonLength' para calcular predicciones
  for i := seasonLength to StrLis.Count - 1 do
  begin
    // Crear un TStringList temporal con los elementos hasta el índice actual
    tempList := TStringList.Create;
    try
      for j := 0 to i do
      begin
        tempList.Add(StrLis[j]);
      end;

      // Llamar a la función de Holt-Winters pasada como argumento
      Predicciones := HoltWintersAdditive(tempList, alpha, beta, gamma,
        seasonLength, futureSteps);

      try
        // Almacenar las predicciones en el arreglo de resultados
        for j := 0 to i + 1 do
        begin
          valor := StrToFloatDef(Predicciones[j], 0.0);
          resultados[j][0] := valor;
        end;
        for j := i + 2 to Predicciones.Count - 1 do
        begin
          valor := StrToFloatDef(Predicciones[j], 0.0);
          resultados[i + 1][j - i - 1] := valor;
        end;

      finally
        Predicciones.Free;
      end;
    finally
      tempList.Free;
    end;
  end;

  Result := resultados;
end;

function CrePredHWMul(StrLis: TStringList; alpha, beta, gamma: Double;
  seasonLength, futureSteps: Integer): TArray<TArray<Double>>;
var
  i, j: Integer;
  Predicciones: TStringList;
  resultados: TArray<TArray<Double>>;
  valor: Double;
  tempList: TStringList;
begin
  // Inicializar el array de resultados
  SetLength(resultados, StrLis.Count + 1, futureSteps );

  // Rellenar los primeros 'seasonLength' elementos con ceros
  for i := 0 to seasonLength - 1 do
    for j := 0 to futureSteps - 1 do
      resultados[i][j] := 0.0;

  // Comenzar desde 'seasonLength' para calcular predicciones
  for i := seasonLength to StrLis.Count - 1 do
  begin
    // Crear un TStringList temporal con los elementos hasta el índice actual
    tempList := TStringList.Create;
    try
      for j := 0 to i do
      begin
        tempList.Add(StrLis[j]);
      end;

      // Llamar a la función de Holt-Winters pasada como argumento
      Predicciones := HoltWintersMul(tempList, alpha, beta, gamma, seasonLength,
        futureSteps);

      try
        // Almacenar las predicciones en el arreglo de resultados
        for j := 0 to i + 1 do
        begin
          valor := StrToFloatDef(Predicciones[j], 0.0);
          resultados[j][0] := valor;
        end;
        for j := i + 2 to Predicciones.Count - 1 do
        begin
          valor := StrToFloatDef(Predicciones[j], 0.0);
          resultados[i + 1][j - i - 1] := valor;
        end;

      finally
        Predicciones.Free;
      end;
    finally
      tempList.Free;
    end;
  end;

  Result := resultados;
end;

end.
