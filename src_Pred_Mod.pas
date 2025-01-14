unit src_Pred_Mod;

interface

uses

  System.SysUtils, System.Classes;

type
  TPredictionModels = class
  protected
    FStrLis: TStringList;
  public
    constructor Create(StrLis: TStringList); virtual;
    function Predict(NumberOfPredictions: Integer): TArray<TArray<Double>>;
      virtual; abstract;
  end;

implementation

constructor TPredictionModels.Create(StrLis: TStringList);
begin
  FStrLis := StrLis;
end;

end.
