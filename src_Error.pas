unit src_Error;

interface

uses
  src_Pred_Mod, System.SysUtils, System.Classes, System.Types,
  Vcl.Grids, Vcl.Dialogs, System.JSON, REST.Client, Math, src_Mod_HW_POO,
  src_Mod_HW, src_ARIMA;

function MSE(RealV, PredV: TStringList): Double;
function MAE(RealV, PredV: TStringList): Double;
function MAPE(RealV, PredV: TStringList): Double;
function Error_Month(Seas: Integer; Modl: string;
  RealX, RealV, PredV: TStringList): TArray<TArray<String>>;
function MAPExMod(RealV: TStringList; PredV: TArray<TArray<Double>>;
  Temp: Integer): TArray<Double>;
function OptimizeHWad(StrLis: TStringList; Pred: Integer): TArray<Double>;
function OptimizeHWad_GA(StrLis: TStringList; Pred: Integer): TArray<Double>;
function OptimizeARIMA_GA(StrLis: TStringList; Pred: Integer): TArray<Double>;
function OptimizeARIMA(StrLis: TStringList; Pred: Integer): TArray<Double>;
function Errorarima(StrLis: TStringList; Pred: Integer): TArray<Double>;
function ErrorHW(StrLis: TStringList; Pred: Integer): TArray<Double>;

implementation

function MSE(RealV, PredV: TStringList): Double;
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
    // Convierte los elementos de TStringList a Double para el cálculo
    Error := StrToFloat(RealV[I]) - StrToFloat(PredV[I]);
    Sum := Sum + (Error * Error);
  end;

  // Calcula el MSE
  Result := Sum / n;
end;

// _________________________________________________
function MAE(RealV, PredV: TStringList): Double;
var
  Sum, Error: Double;
  I, n: Integer;
begin
  Sum := 0;
  n := RealV.Count;

  if n < 1 then
  begin
    Result := 0; // Evita división por cero
    Exit;
  end;

  for I := 0 to n - 1 do
  begin
    // Convierte los elementos de TStringList a Double para el cálculo
    Error := Abs(StrToFloat(RealV[I]) - StrToFloat(PredV[I]));
    Sum := Sum + Error;
  end;

  // Calcula el MAE
  Result := Sum / n;
end;

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

function Error_Month(Seas: Integer; Modl: string;
  RealX, RealV, PredV: TStringList): TArray<TArray<String>>;
var
  I, J, NumPackets: Integer;
  StartIdx, EndIdx: Integer;
  PacketRealV, PacketPredV: TStringList;
  PacketResult: TArray<TArray<String>>;
  MetricResult: Double;
begin
  NumPackets := RealV.Count;
  SetLength(PacketResult, NumPackets, 2);

  PacketRealV := TStringList.Create;
  PacketPredV := TStringList.Create;
  try
    try
      for I := Seas to NumPackets - 1 do
      begin
        StartIdx := Min(I - Seas, RealV.Count - 1);
        EndIdx := I;

        PacketRealV.Clear;
        PacketPredV.Clear;

        // Llenar las listas con los valores del paquete actual
        for J := StartIdx to EndIdx do
        begin
          PacketRealV.Add(RealV[J]);
          PacketPredV.Add(PredV[J]);
        end;

        // Calcular la métrica deseada
        if Modl = 'MAE' then
          MetricResult := MAE(PacketRealV, PacketPredV)
        else if Modl = 'MAPE' then
          MetricResult := MAPE(PacketRealV, PacketPredV);

        // Guardar el rango de elementos de RealX y el resultado de la métrica
        PacketResult[I][0] := RealX[StartIdx] + '-' + RealX[EndIdx];
        PacketResult[I][1] := FloatToStr(MetricResult);
      end;
    finally
      PacketRealV.Free;
      PacketPredV.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;

  Result := PacketResult;
end;

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
          StrToFloat(RealV[I + J]));
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

// ________________________________________
function OptimizeHWad(StrLis: TStringList; Pred: Integer): TArray<Double>;
var
  I, J, BestIndex1, BestIndex2: Integer;
  Predictions: TArray<TArray<Double>>;
  Fir, Trend, Seas, Seas_I, BestFir, BestTrend, BestSeas: TArray<Double>;
  BestSeas_I: TArray<Integer>;
  Dist, Inter: Double;
  Errors_End: TArray<Double>;
  NumIterations, ParamIndex: Integer;
begin
  // Inicializar arrays
  SetLength(Fir, 2);
  SetLength(Trend, 2);
  SetLength(Seas, 2);
  SetLength(Seas_I, 2);

  SetLength(BestFir, 2);
  SetLength(BestTrend, 2);
  SetLength(BestSeas, 2);
  SetLength(BestSeas_I, 2);

  // Inicializar valores iniciales
  BestFir[0] := 0.1; // Asumiendo mejores iniciales
  BestTrend[0] := 0.1;
  BestSeas[0] := 0.1;
  BestSeas_I[0] := 2;

  Fir[0] := 0.001;
  Fir[1] := 0.999;
  Trend[0] := 0.001;
  Trend[1] := 0.999;
  Seas[0] := 0.001;
  Seas[1] := 0.999;
  Seas_I[0] := 2;
  Seas_I[1] := (StrLis.Count - 2);

  SetLength(Errors_End, 11);

  // Ciclo principal de iteraciones
  NumIterations := 3;

  for ParamIndex := 0 to 3 do
  begin
    for I := 0 to NumIterations do
    begin
      for J := -1 to 9 do
      begin
        case ParamIndex of
          0: // Optimizando Fir
            begin
              Dist := Abs(Fir[0] - Fir[1]) / 10;
              Predictions := CrePredHWAd(StrLis, BestFir[0] + (Dist * J),
                BestTrend[0], BestSeas[0], BestSeas_I[0], Pred);
            end;
          1: // Optimizando Trend
            begin
              Dist := Abs(Trend[0] - Trend[1]) / 10;
              Predictions := CrePredHWAd(StrLis, BestFir[0],
                BestTrend[0] + (Dist * J), BestSeas[0], BestSeas_I[0], Pred);
            end;
          2: // Optimizando Seas
            begin
              Dist := Abs(Seas[0] - Seas[1]) / 10;
              Predictions := CrePredHWAd(StrLis, BestFir[0], BestTrend[0],
                BestSeas[0] + (Dist * J), BestSeas_I[0], Pred);
            end;
          3: // Optimizando Seas_I
            begin
              Dist := Abs(Seas_I[0] - Seas_I[1]) / 10;
              Predictions := CrePredHWAd(StrLis, BestFir[0], BestTrend[0],
                BestSeas[0], Ceil(BestSeas_I[0] + (Dist * (J + 1))), Pred);
            end;
        end;

        // Asignar errores correctamente
        Errors_End[J + 1] := Sum(MAPExMod(StrLis, Predictions, BestSeas_I[0]));
      end;

      // Encontrar los dos mejores índices
      BestIndex1 := 0;
      BestIndex2 := 1;
      if Errors_End[BestIndex2] < Errors_End[BestIndex1] then
        Swap(BestIndex1, BestIndex2);

      for J := 2 to 10 do
      begin
        if Errors_End[J] < Errors_End[BestIndex1] then
        begin
          BestIndex2 := BestIndex1;
          BestIndex1 := J;
        end
        else if Errors_End[J] < Errors_End[BestIndex2] then
          BestIndex2 := J;
      end;

      // Actualizar Fir, Trend, Seas o Seas_I
      case ParamIndex of
        0:
          begin
            Fir[0] := BestFir[0] + (Dist * (BestIndex1 - 1));
            Fir[1] := BestFir[0] + (Dist * (BestIndex2 - 1));
            BestFir := Copy(Fir);
          end;
        1:
          begin
            Trend[0] := BestTrend[0] + (Dist * (BestIndex1 - 1));
            Trend[1] := BestTrend[0] + (Dist * (BestIndex2 - 1));
            BestTrend := Copy(Trend);
          end;
        2:
          begin
            Seas[0] := BestSeas[0] + (Dist * (BestIndex1 - 1));
            Seas[1] := BestSeas[0] + (Dist * (BestIndex2 - 1));
            BestSeas := Copy(Seas);
          end;
        3:
          begin
            Seas_I[0] := Ceil(BestSeas_I[0] + (Dist * (BestIndex1)));
            Seas_I[1] := Ceil(BestSeas_I[0] + (Dist * (BestIndex2)));
            BestSeas_I[0] := Ceil(Seas_I[0]);
            BestSeas_I[1] := Ceil(Seas_I[1]);
          end;
      end;
    end;
  end;

  // Devolver los mejores valores encontrados
  SetLength(Result, 4);
  Result[0] := BestFir[0];
  Result[1] := BestTrend[0];
  Result[2] := BestSeas[0];
  Result[3] := BestSeas_I[0];
end;

function OptimizeHWad_GA(StrLis: TStringList; Pred: Integer): TArray<Double>;
const
  PopSize = 20; // Tamaño de la población
  Generations = 50; // Número de generaciones
  MutationRate = 0.1; // Tasa de mutación
  CrossoverRate = 0.8; // Tasa de cruce
var
  Population: TArray<TArray<Double>>;
  Fitness: TArray<Double>;
  BestSolution: TArray<Double>;
  I, J, g, Parent1, Parent2: Integer;
  Fir, Trend, Seas, Seas_I: Double;
  Offspring: TArray<Double>;
  Errors_End: TArray<Double>;
  BestIndex: Integer;
  Predictions: TArray<TArray<Double>>;
begin
  // Inicialización de la población (valores aleatorios dentro de los rangos permitidos)
  SetLength(Population, PopSize);
  for I := 0 to PopSize - 1 do
  begin
    SetLength(Population[I], 4);
    Population[I][0] := RandomRange(1, 1000) / 1000; // Fir
    Population[I][1] := RandomRange(1, 1000) / 1000; // Trend
    Population[I][2] := RandomRange(1, 1000) / 1000; // Seas
    Population[I][3] := RandomRange(2, (StrLis.Count div 2)); // Seas_I
  end;

  SetLength(Fitness, PopSize);

  // Ciclo principal de generaciones
  for g := 0 to Generations - 1 do
  begin
    // Evaluación de la población
    for I := 0 to PopSize - 1 do
    begin
      Fir := Population[I][0];
      Trend := Population[I][1];
      Seas := Population[I][2];
      Seas_I := Population[I][3];

      // Generar predicciones y calcular el error
      Predictions := CrePredHWAd(StrLis, Fir, Trend, Seas, Round(Seas_I), Pred);
      Fitness[I] := Sum(MAPExMod(StrLis, Predictions, Round(Seas_I)));
    end;

    // Encontrar el mejor individuo
    BestIndex := 0;
    for I := 1 to PopSize - 1 do
    begin
      if Fitness[I] < Fitness[BestIndex] then
        BestIndex := I;
    end;

    BestSolution := Copy(Population[BestIndex]);

    // Selección y creación de la nueva generación
    for I := 0 to PopSize div 2 - 1 do
    begin
      // Seleccionar dos padres mediante torneo
      Parent1 := RandomRange(0, PopSize);
      Parent2 := RandomRange(0, PopSize);

      // Cruce
      if Random < CrossoverRate then
      begin
        SetLength(Offspring, 4);
        for J := 0 to 3 do
        begin
          if Random < 0.5 then
            Offspring[J] := Population[Parent1][J]
          else
            Offspring[J] := Population[Parent2][J];
        end;
      end
      else
      begin
        Offspring := Copy(Population[Parent1]);
      end;

      // Mutación
      if Random < MutationRate then
      begin
        J := RandomRange(0, 4); // Seleccionar parámetro aleatorio
        if J = 3 then
          Offspring[J] := RandomRange(2, StrLis.Count - 2) // Mutar Seas_I
        else
          Offspring[J] := RandomRange(1, 1000) / 1000;
        // Mutar Fir, Trend o Seas
      end;

      // Reemplazar con la nueva generación
      Population[I * 2] := Copy(Offspring);
      Population[I * 2 + 1] := Copy(Population[BestIndex]); // Elitismo
    end;
  end;

  // Devolver la mejor solución encontrada
  SetLength(Result, 4);
  Result[0] := BestSolution[0]; // Fir
  Result[1] := BestSolution[1]; // Trend
  Result[2] := BestSolution[2]; // Seas
  Result[3] := BestSolution[3]; // Seas_I
end;

// _________________________________________________________
function OptimizeHWAMul(StrLis: TStringList; Pred: Integer): TArray<Double>;
var
  I, J, BestIndex1, BestIndex2: Integer;
  Predictions: TArray<TArray<Double>>;
  Fir, Trend, Seas, Seas_I, BestFir, BestTrend, BestSeas: TArray<Double>;
  BestSeas_I: TArray<Integer>;
  Dist, Inter: Double;
  Errors_End: TArray<Double>;
  NumIterations, ParamIndex: Integer;
begin
  // Inicializar arrays
  SetLength(Fir, 2);
  SetLength(Trend, 2);
  SetLength(Seas, 2);
  SetLength(Seas_I, 2);

  SetLength(BestFir, 2);
  SetLength(BestTrend, 2);
  SetLength(BestSeas, 2);
  SetLength(BestSeas_I, 2);

  // Inicializar valores iniciales
  BestFir[0] := 0.1; // Asumiendo mejores iniciales
  BestTrend[0] := 0.1;
  BestSeas[0] := 0.1;
  BestSeas_I[0] := 2;

  Fir[0] := 0.004;
  Fir[1] := 0.996;
  Trend[0] := 0.004;
  Trend[1] := 0.996;
  Seas[0] := 0.004;
  Seas[1] := 0.996;
  Seas_I[0] := 2;
  Seas_I[1] := (StrLis.Count - 2);

  SetLength(Errors_End, 11);

  // Ciclo principal de iteraciones
  NumIterations := 3;

  for ParamIndex := 0 to 3 do
  begin
    for I := 0 to NumIterations do
    begin
      for J := -1 to 9 do
      begin
        case ParamIndex of
          0: // Optimizando Fir
            begin
              Dist := Abs(Fir[0] - Fir[1]) / 10;
              Predictions := CrePredHWAd(StrLis, BestFir[0] + (Dist * J),
                BestTrend[0], BestSeas[0], BestSeas_I[0], Pred);
            end;
          1: // Optimizando Trend
            begin
              Dist := Abs(Trend[0] - Trend[1]) / 10;
              Predictions := CrePredHWMul(StrLis, BestFir[0],
                BestTrend[0] + (Dist * J), BestSeas[0], BestSeas_I[0], Pred);
            end;
          2: // Optimizando Seas
            begin
              Dist := Abs(Seas[0] - Seas[1]) / 10;
              Predictions := CrePredHWMul(StrLis, BestFir[0], BestTrend[0],
                BestSeas[0] + (Dist * J), BestSeas_I[0], Pred);
            end;
          3: // Optimizando Seas_I
            begin
              Dist := Abs(Seas_I[0] - Seas_I[1]) / 10;
              Predictions := CrePredHWMul(StrLis, BestFir[0], BestTrend[0],
                BestSeas[0], Ceil(BestSeas_I[0] + (Dist * (J + 1))), Pred);
            end;
        end;

        // Asignar errores correctamente
        Errors_End[J + 1] := Sum(MAPExMod(StrLis, Predictions, BestSeas_I[0]));
      end;

      // Encontrar los dos mejores índices
      BestIndex1 := 0;
      BestIndex2 := 1;
      if Errors_End[BestIndex2] < Errors_End[BestIndex1] then
        Swap(BestIndex1, BestIndex2);

      for J := 2 to 10 do
      begin
        if Errors_End[J] < Errors_End[BestIndex1] then
        begin
          BestIndex2 := BestIndex1;
          BestIndex1 := J;
        end
        else if Errors_End[J] < Errors_End[BestIndex2] then
          BestIndex2 := J;
      end;

      // Actualizar Fir, Trend, Seas o Seas_I
      case ParamIndex of
        0:
          begin
            Fir[0] := BestFir[0] + (Dist * (BestIndex1 - 1));
            Fir[1] := BestFir[0] + (Dist * (BestIndex2 - 1));
            BestFir := Copy(Fir);
          end;
        1:
          begin
            Trend[0] := BestTrend[0] + (Dist * (BestIndex1 - 1));
            Trend[1] := BestTrend[0] + (Dist * (BestIndex2 - 1));
            BestTrend := Copy(Trend);
          end;
        2:
          begin
            Seas[0] := BestSeas[0] + (Dist * (BestIndex1 - 1));
            Seas[1] := BestSeas[0] + (Dist * (BestIndex2 - 1));
            BestSeas := Copy(Seas);
          end;
        3:
          begin
            Seas_I[0] := Ceil(BestSeas_I[0] + (Dist * (BestIndex1)));
            Seas_I[1] := Ceil(BestSeas_I[0] + (Dist * (BestIndex2)));
            BestSeas_I[0] := Ceil(Seas_I[0]);
            BestSeas_I[1] := Ceil(Seas_I[1]);
          end;
      end;
    end;
  end;

  // Devolver los mejores valores encontrados
  SetLength(Result, 4);
  Result[0] := BestFir[0];
  Result[1] := BestTrend[0];
  Result[2] := BestSeas[0];
  Result[3] := BestSeas_I[0];
end;

function OptimizeHWMul_GA(StrLis: TStringList; Pred: Integer): TArray<Double>;
const
  PopSize = 20; // Tamaño de la población
  Generations = 50; // Número de generaciones
  MutationRate = 0.1; // Tasa de mutación
  CrossoverRate = 0.8; // Tasa de cruce
var
  Population: TArray<TArray<Double>>;
  Fitness: TArray<Double>;
  BestSolution: TArray<Double>;
  I, J, g, Parent1, Parent2: Integer;
  Fir, Trend, Seas, Seas_I: Double;
  Offspring: TArray<Double>;
  Errors_End: TArray<Double>;
  BestIndex: Integer;
  Predictions: TArray<TArray<Double>>;
begin
  // Inicialización de la población (valores aleatorios dentro de los rangos permitidos)
  SetLength(Population, PopSize);
  for I := 0 to PopSize - 1 do
  begin
    SetLength(Population[I], 4);
    Population[I][0] := RandomRange(1, 1000) / 1000; // Fir
    Population[I][1] := RandomRange(1, 1000) / 1000; // Trend
    Population[I][2] := RandomRange(1, 1000) / 1000; // Seas
    Population[I][3] := RandomRange(2, (StrLis.Count div 2)); // Seas_I
  end;

  SetLength(Fitness, PopSize);

  // Ciclo principal de generaciones
  for g := 0 to Generations - 1 do
  begin
    // Evaluación de la población
    for I := 0 to PopSize - 1 do
    begin
      Fir := Population[I][0];
      Trend := Population[I][1];
      Seas := Population[I][2];
      Seas_I := Population[I][3];

      // Generar predicciones y calcular el error
      Predictions := CrePredHWMul(StrLis, Fir, Trend, Seas,
        Round(Seas_I), Pred);
      Fitness[I] := Sum(MAPExMod(StrLis, Predictions, Round(Seas_I)));
    end;

    // Encontrar el mejor individuo
    BestIndex := 0;
    for I := 1 to PopSize - 1 do
    begin
      if Fitness[I] < Fitness[BestIndex] then
        BestIndex := I;
    end;

    BestSolution := Copy(Population[BestIndex]);

    // Selección y creación de la nueva generación
    for I := 0 to PopSize div 2 - 1 do
    begin
      // Seleccionar dos padres mediante torneo
      Parent1 := RandomRange(0, PopSize);
      Parent2 := RandomRange(0, PopSize);

      // Cruce
      if Random < CrossoverRate then
      begin
        SetLength(Offspring, 4);
        for J := 0 to 3 do
        begin
          if Random < 0.5 then
            Offspring[J] := Population[Parent1][J]
          else
            Offspring[J] := Population[Parent2][J];
        end;
      end
      else
      begin
        Offspring := Copy(Population[Parent1]);
      end;

      // Mutación
      if Random < MutationRate then
      begin
        J := RandomRange(0, 4); // Seleccionar parámetro aleatorio
        if J = 3 then
          Offspring[J] := RandomRange(2, StrLis.Count - 2) // Mutar Seas_I
        else
          Offspring[J] := RandomRange(1, 1000) / 1000;
        // Mutar Fir, Trend o Seas
      end;

      // Reemplazar con la nueva generación
      Population[I * 2] := Copy(Offspring);
      Population[I * 2 + 1] := Copy(Population[BestIndex]); // Elitismo
    end;
  end;

  // Devolver la mejor solución encontrada
  SetLength(Result, 4);
  Result[0] := BestSolution[0]; // Fir
  Result[1] := BestSolution[1]; // Trend
  Result[2] := BestSolution[2]; // Seas
  Result[3] := BestSolution[3]; // Seas_I
end;


// ____________________________________________________________________________

function OptimizeARIMA(StrLis: TStringList; Pred: Integer): TArray<Double>;
var
  I, J, BestIndex1, BestIndex2: Integer;
  Predictions: TArray<TArray<Double>>;
  AR, IParam, MA, BestAR, BestIParam, BestMA: TArray<Double>;
  Dist: Double;
  Errors_End: TArray<Double>;
  NumIterations, ParamIndex, Limit: Integer;
begin
  if StrLis.Count < 200 then
  begin
    Limit := StrLis.Count div 2;
  end
  else
  begin
    Limit := 100;
  end;

  // Inicializar arrays
  SetLength(AR, 2);
  SetLength(IParam, 2);
  SetLength(MA, 2);
  SetLength(BestAR, 2);
  SetLength(BestIParam, 2);
  SetLength(BestMA, 2);

  BestAR[0] := Limit div 10;
  BestIParam[0] := 1;
  BestMA[0] := Limit div 10;

  AR[0] := 0;
  AR[1] := Limit;
  IParam[0] := 0;
  IParam[1] := 10;
  MA[0] := 0.1;
  MA[1] := Limit;

  SetLength(Errors_End, 11);

  // Ciclo principal de iteraciones
  NumIterations := 3;

  for ParamIndex := 0 to 2 do
  begin
    for I := 0 to NumIterations do
    begin
      for J := -1 to 9 do
      begin
        case ParamIndex of
          0: // Optimizando AR
            begin
              Dist := Abs(AR[0] - AR[1]) / 10;
              Predictions := ARIMA(StrLis, Round(BestAR[0] + (Dist * J)),
                Round(BestIParam[0]), Round(BestMA[0]), Pred);
            end;
          1: // Optimizando I
            begin
              Dist := Abs(IParam[0] - IParam[1]) / 10;
              Predictions := ARIMA(StrLis, Round(BestAR[0]),
                Round(BestIParam[0] + (Dist * J)) mod 5,
                Round(BestMA[0]), Pred);
            end;
          2: // Optimizando MA
            begin
              Dist := Abs(MA[0] - MA[1]) / 10;
              Predictions := ARIMA(StrLis, Round(BestAR[0]),
                Round(BestIParam[0]), Round(BestMA[0] + (Dist * J)), Pred);
            end;
        end;

        // Asignar errores correctamente
        Errors_End[J + 1] := Sum(MAPExMod(StrLis, Predictions, Pred));
      end;

      // Encontrar los dos mejores índices
      BestIndex1 := 0;
      BestIndex2 := 1;
      if Errors_End[BestIndex2] < Errors_End[BestIndex1] then
        Swap(BestIndex1, BestIndex2);

      for J := 2 to 10 do
      begin
        if Errors_End[J] < Errors_End[BestIndex1] then
        begin
          BestIndex2 := BestIndex1;
          BestIndex1 := J;
        end
        else if Errors_End[J] < Errors_End[BestIndex2] then
          BestIndex2 := J;
      end;

      // Actualizar AR, I, MA
      case ParamIndex of
        0:
          begin
            AR[0] := Round(BestAR[0] + (Dist * (BestIndex1 - 1)));
            AR[1] := Round(BestAR[0] + (Dist * (BestIndex2 - 1)));
            BestAR := Copy(AR);
          end;
        1:
          begin
            IParam[0] := Round(BestIParam[0] + (Dist * (BestIndex1 - 1))) mod 5;
            IParam[1] := Round(BestIParam[0] + (Dist * (BestIndex2 - 1))) mod 5;
            BestIParam := Copy(IParam);
          end;
        2:
          begin
            MA[0] := Round(BestMA[0] + (Dist * (BestIndex1 - 1)));
            MA[1] := Round(BestMA[0] + (Dist * (BestIndex2 - 1)));
            BestMA := Copy(MA);
          end;
      end;
    end;
  end;

  // Devolver los mejores valores encontrados
  SetLength(Result, 3);
  Result[0] := BestAR[0];
  Result[1] := BestIParam[0];
  Result[2] := BestMA[0];
end;

function OptimizeARIMA_GA(StrLis: TStringList; Pred: Integer): TArray<Double>;
const
  PopSize = 20; // Tamaño de la población
  Generations = 50; // Número de generaciones
  MutationRate = 0.1; // Tasa de mutación
  CrossoverRate = 0.8; // Tasa de cruce
var
  Population: TArray<TArray<Integer>>;
  Fitness: TArray<Double>;
  Limit: Integer;
  BestSolution: TArray<Integer>;
  I, J, g, Parent1, Parent2: Integer;
  AR, Inte, MA: Integer;
  Offspring: TArray<Integer>;
  Errors_End: TArray<Double>;
  BestIndex: Integer;
  Predictions: TArray<TArray<Double>>;
begin

  if StrLis.Count < 200 then
  begin
    Limit := StrLis.Count div 2;
  end
  else
  begin
    Limit := 100;
  end;

  // Inicialización de la población (valores aleatorios dentro de los rangos permitidos)
  SetLength(Population, PopSize);
  for I := 0 to PopSize - 1 do
  begin
    SetLength(Population[I], 3);
    Population[I][0] := RandomRange(1, Limit); // AR
    Population[I][1] := RandomRange(1, 5); // I
    Population[I][2] := RandomRange(1, Limit); // MA
  end;

  SetLength(Fitness, PopSize);

  // Ciclo principal de generaciones
  for g := 0 to Generations - 1 do
  begin
    // Evaluación de la población
    for I := 0 to PopSize - 1 do
    begin
      AR := Population[I][0];
      Inte := Population[I][1];
      MA := Population[I][2];

      // Generar predicciones usando el modelo ARIMA
      Predictions := ARIMA(StrLis, AR, Inte, MA, Pred);

      Fitness[I] := Sum(MAPExMod(StrLis, Predictions, AR + MA));
    end;

    // Encontrar el mejor individuo
    BestIndex := 0;
    for I := 1 to PopSize - 1 do
    begin
      if Fitness[I] < Fitness[BestIndex] then
        BestIndex := I;
    end;

    // mejor solución
    BestSolution := Copy(Population[BestIndex]);

    // nueva generación
    for I := 0 to PopSize div 2 - 1 do
    begin
      // Seleccionar
      Parent1 := RandomRange(0, PopSize);
      Parent2 := RandomRange(0, PopSize);

      // Cruce
      if Random < CrossoverRate then
      begin
        SetLength(Offspring, 3);
        for J := 0 to 2 do
        begin
          if Random < 0.5 then
            Offspring[J] := Population[Parent1][J]
          else
            Offspring[J] := Population[Parent2][J];
        end;
      end
      else
      begin
        Offspring := Copy(Population[Parent1]);
      end;

      // Mutación
      if Random < MutationRate then
      begin
        J := RandomRange(0, 3);
        case J of
          0:
            Offspring[0] := RandomRange(1, Limit);
          1:
            Offspring[1] := RandomRange(1, 5);
          2:
            Offspring[2] := RandomRange(1, Limit);
        end;
      end;

      Population[I * 2] := Copy(Offspring);
      Population[I * 2 + 1] := Copy(Population[BestIndex]);

    end;
  end;

  SetLength(Result, 3);
  Result[0] := BestSolution[0];
  Result[1] := BestSolution[1];
  Result[2] := BestSolution[2];
end;

function Errorarima(StrLis: TStringList; Pred: Integer): TArray<Double>;
var
  PredictionsGA, PredictionsNoGA: TArray<TArray<Double>>;
  ConsGA, ConsNoGA: TArray<Double>;
  ErrorGA, ErrorNoGA: Double;
  Alma: TArray<Double>;

begin
  SetLength(Alma, 5);

  ConsGA := OptimizeARIMA_GA(StrLis, Pred);
  PredictionsGA := ARIMA(StrLis, Round(ConsGA[0]), Round(ConsGA[1]),
    Round(ConsGA[2]), Pred);
  ErrorGA := Sum(MAPExMod(StrLis, PredictionsGA,
    Round(ConsGA[0]) + Round(ConsGA[2])));

  ConsNoGA := OptimizeARIMA(StrLis, Pred);
  PredictionsNoGA := ARIMA(StrLis, Round(ConsNoGA[0]), Round(ConsNoGA[1]),
    Round(ConsNoGA[2]), Pred);
  ErrorNoGA := Sum(MAPExMod(StrLis, PredictionsNoGA,
    Round(ConsNoGA[0]) + Round(ConsNoGA[2])));

  if ErrorGA < ErrorNoGA then
  begin
    Alma[0] := 3;
    Alma[1] := ErrorGA;
    Alma[2] := Round(ConsGA[0]);
    Alma[3] := Round(ConsGA[1]);
    Alma[4] := Round(ConsGA[2]);
  end
  else
  begin
    Alma[0] := ErrorNoGA;
    Alma[1] := ErrorNoGA;
    Alma[2] := Round(ConsNoGA[0]);
    Alma[3] := Round(ConsNoGA[1]);
    Alma[4] := Round(ConsNoGA[2]);
  end;

  Result := Alma;
end;

function ErrorHW(StrLis: TStringList; Pred: Integer): TArray<Double>;
var
  PredictionsAdGA, PredictionsMulGA, PredictionsAdNoGA, PredictionsMulNoGA
    : TArray<TArray<Double>>;
  ConsAdGA, ConsMulGA, ConsAdNoGA, ConsMulNoGA: TArray<Double>;
  ErrorAdGA, ErrorMulGA, ErrorAdNoGA, ErrorMulNoGA: Double;
  Alma: TArray<Double>;
begin
  SetLength(Alma, 6);

  // Optimización HW Aditivo con GA
  ConsAdGA := OptimizeHWad_GA(StrLis, Pred);
  PredictionsAdGA := CrePredHWAd(StrLis, ConsAdGA[0], ConsAdGA[1], ConsAdGA[2],
    Round(ConsAdGA[3]), Pred);
  ErrorAdGA := Sum(MAPExMod(StrLis, PredictionsAdGA, Round(ConsAdGA[3])));

  // Optimización HW Multiplicativo con GA
  ConsMulGA := OptimizeHWMul_GA(StrLis, Pred);
  PredictionsMulGA := CrePredHWMul(StrLis, ConsMulGA[0], ConsMulGA[1],
    ConsMulGA[2], Round(ConsMulGA[3]), Pred);
  ErrorMulGA := Sum(MAPExMod(StrLis, PredictionsMulGA, Round(ConsMulGA[3])));

  // Optimización HW Aditivo sin GA
  ConsAdNoGA := OptimizeHWad(StrLis, Pred);
  PredictionsAdNoGA := CrePredHWAd(StrLis, ConsAdNoGA[0], ConsAdNoGA[1],
    ConsAdNoGA[2], Round(ConsAdNoGA[3]), Pred);
  ErrorAdNoGA := Sum(MAPExMod(StrLis, PredictionsAdNoGA, Round(ConsAdNoGA[3])));

  // Optimización HW Multiplicativo sin GA
  ConsMulNoGA := OptimizeHWAMul(StrLis, Pred);
  PredictionsMulNoGA := CrePredHWMul(StrLis, ConsMulNoGA[0], ConsMulNoGA[1],
    ConsMulNoGA[2], Round(ConsMulNoGA[3]), Pred);
  ErrorMulNoGA := Sum(MAPExMod(StrLis, PredictionsMulNoGA,
    Round(ConsMulNoGA[3])));

  // Comparar errores y almacenar el mejor resultado
  if (ErrorAdGA < ErrorMulGA) and (ErrorAdGA < ErrorAdNoGA) and
    (ErrorAdGA < ErrorMulNoGA) then
  begin
    Alma[0] := 1;
    Alma[1] := ErrorAdGA;
    Alma[2] := ConsAdGA[0];
    Alma[3] := ConsAdGA[1];
    Alma[4] := ConsAdGA[2];
    Alma[5] := ConsAdGA[3];
  end
  else if (ErrorMulGA < ErrorAdGA) and (ErrorMulGA < ErrorAdNoGA) and
    (ErrorMulGA < ErrorMulNoGA) then
  begin
    Alma[0] := 2;
    Alma[1] := ErrorMulGA;
    Alma[2] := ConsMulGA[0];
    Alma[3] := ConsMulGA[1];
    Alma[4] := ConsMulGA[2];
    Alma[5] := ConsMulGA[3];
  end
  else if (ErrorAdNoGA < ErrorAdGA) and (ErrorAdNoGA < ErrorMulGA) and
    (ErrorAdNoGA < ErrorMulNoGA) then
  begin
    Alma[0] := 1;
    Alma[1] := ErrorAdNoGA;
    Alma[2] := ConsAdNoGA[0];
    Alma[3] := ConsAdNoGA[1];
    Alma[4] := ConsAdNoGA[2];
    Alma[5] := ConsAdNoGA[3];
  end
  else
  begin
    Alma[0] := 2;
    Alma[1] := ErrorMulNoGA;
    Alma[2] := ConsMulNoGA[0];
    Alma[3] := ConsMulNoGA[1];
    Alma[4] := ConsMulNoGA[2];
    Alma[5] := ConsMulNoGA[3];
  end;

  Result := Alma;
end;

end.
