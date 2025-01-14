unit Modelos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Grids, src_CSV_StrGrt, Vcl.StdCtrls, src_Grafica, src_cbCol,
  src_PrepDatStrGr, src_Mod_HW, src_ARIMA, scr_ARIMAPM, src_Pred_Mod,
  Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections, src_Error,

  Vcl.AppAnalytics, src_Mod_HW_POO;

function ProcessDataModel(StrLis: TStringList; CB_ModText: string;
  MA_HW, Trend, Seas_Con: Double; SeasonLength, AR, I, MA, pred: Integer)
  : TArray<TArray<Double>>;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    StringGrid_Load: TStringGrid;
    Panel3: TPanel;
    Lab_Temp: TLabel;
    ComBoxX: TComboBox;
    ComBoxY: TComboBox;
    Panel4: TPanel;
    Image_Graf: TImage;
    Panel_Argum: TPanel;
    Lab_Mod: TLabel;
    CB_Mod: TComboBox;
    btnProcess: TButton;
    StringGrid_Result: TStringGrid;
    Lab_Pred: TLabel;
    SpEd_Pred: TSpinEdit;
    CB_Pred: TComboBox;
    Lab_Arg: TLabel;
    btnLoad: TButton;
    TabsModels: TPageControl;
    LoadData: TTabSheet;
    DataResult: TTabSheet;
    Graphs: TTabSheet;
    cmbxSep: TComboBox;
    Lab_Load: TLabel;
    Ed_MA_HW: TEdit;
    Ed_Trend: TEdit;
    Ed_Seas_Con: TEdit;
    Lb_Trend: TLabel;
    Lb_Seas_Cons: TLabel;
    Lb_season: TLabel;
    Lb_AR: TLabel;
    Lb_I: TLabel;
    Lb_MA: TLabel;
    SpEd_AR: TSpinEdit;
    SpEd_I: TSpinEdit;
    SpEd_MA: TSpinEdit;
    Lb_MA_HW: TLabel;
    SpEd_Season: TSpinEdit;
    Btn_Optimize: TButton;
    SpEd_Graf: TSpinEdit;
    Data: TTabSheet;
    PageControl1: TPageControl;
    Error: TTabSheet;
    SG_Error: TStringGrid;
    Pan_Graph_er: TPanel;
    Cb_Error: TComboBox;
    Image_Error: TImage;
    Lb_Error: TLabel;
    SpEd_Error: TSpinEdit;
    Mem_MAPE: TMemo;
    procedure ComBox1Change(Sender: TObject);

    procedure btnProcessClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure CB_PredChange(Sender: TObject);
    procedure CB_ModChange(Sender: TObject);
    procedure Cb_ErrorChange(Sender: TObject);
    procedure Btn_OptimizeClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnLoadClick(Sender: TObject);
Var
  FileName: String;

begin

  OpenDialog1.InitialDir := 'C:\';
  OpenDialog1.Filter := 'CSV Files (*.csv)|*.csv';
  if OpenDialog1.Execute then
  begin
    FileName := OpenDialog1.FileName;
    LoadCSVToStringGrid(StringGrid_Load, FileName, cmbxSep.Text[1]);
    LoadCSVToStringGrid(StringGrid_Result, FileName, cmbxSep.Text[1]);
    cbcol(StringGrid_Load, ComBoxX, ComBoxY);

  end;
  ComBoxY.ItemIndex := 1;

end;

function ProcessDataModel(StrLis: TStringList; CB_ModText: string;
  MA_HW, Trend, Seas_Con: Double; SeasonLength, AR, I, MA, pred: Integer)
  : TArray<TArray<Double>>;
begin
  if CB_ModText = 'EWMA' then
  begin
    Result := WeightedMovingAverage(StrLis, MA_HW, pred);
  end
  else if CB_ModText = 'HoltWintersAdditive' then
  begin
    Result := CrePredHWAd(StrLis, MA_HW, Trend, Seas_Con, SeasonLength, pred);
  end
  else if CB_ModText = 'HoltWintersMul' then
  begin
    Result := CrePredHWMul(StrLis, MA_HW, Trend, Seas_Con, SeasonLength, pred);
  end
  else if CB_ModText = 'ARIMA' then
  begin
    Result := ARIMA(StrLis, AR, I, MA, pred);
  end
  else
  begin
    raise Exception.Create('Modelo no soportado');
  end;
end;

procedure TForm1.btnProcessClick(Sender: TObject);
var
  StrLis: TStringList;
  W: TStringList;
  DataArray: TArray<TArray<Double>>;
  j: Integer;
  Model: TPredictionModels;
  pred: Integer;

begin
  StrLis := PrepDatStrGr(StringGrid_Load, ComBoxY);
  pred := SpEd_Pred.Value;


  DataArray := ProcessDataModel(StrLis, CB_Mod.Text, StrToFloat(Ed_MA_HW.Text),
    StrToFloat(Ed_Trend.Text), StrToFloat(Ed_Seas_Con.Text), SpEd_Season.Value,
    SpEd_AR.Value, SpEd_I.Value, SpEd_MA.Value, pred);

  CopyStringGrid(StringGrid_Load, StringGrid_Result);
  AddColStGr2(StringGrid_Result, DataArray, 'Modelo');
  cbcol1(StringGrid_Result, CB_Pred);
  ComBoxX.ItemIndex := 0;
end;

procedure TForm1.Btn_OptimizeClick(Sender: TObject);
var
  StrLis: TStringList;
  DataArray: TArray<TArray<Double>>;
  Optmiar: TArray<Integer>;
  pred: Integer;
  I, j: Integer;
  MAPE, Optim: TArray<Double>;
  listOptim, ResultHW, ResultARIMA: TArray<Double>;
begin
  StrLis := PrepDatStrGr(StringGrid_Load, ComBoxY);
  pred := SpEd_Pred.Value;
  DataArray := ProcessDataModel(StrLis, CB_Mod.Text, StrToFloat(Ed_MA_HW.Text),
    StrToFloat(Ed_Trend.Text), StrToFloat(Ed_Seas_Con.Text), SpEd_Season.Value,
    SpEd_AR.Value, SpEd_I.Value, SpEd_MA.Value, pred);
  Mem_MAPE.Clear;
  MAPE := MAPExMod(StrLis, DataArray, SpEd_Season.Value);
  for I := 0 to Length(MAPE) - 1 do
  begin
    Mem_MAPE.Lines.Add(FloatToStr(MAPE[I]));
  end;


  ResultHW := ErrorHW(StrLis, pred);
  ResultARIMA := Errorarima(StrLis, pred);


  SetLength(listOptim, Length(ResultHW) + Length(ResultARIMA));


  Move(ResultHW[0], listOptim[0], Length(ResultHW) * SizeOf(Double));


  Move(ResultARIMA[0], listOptim[Length(ResultHW)], Length(ResultARIMA) *
    SizeOf(Double));

  for j := 0 to Length( ResultHW ) - 1 do
  begin
    Mem_MAPE.Lines.Add(FloatToStr( ResultHW [j]));

  end;

end;

procedure TForm1.Cb_ErrorChange(Sender: TObject);
var
  DataArray: TArray<TArray<String>>;
  X, Y: TStringList;
begin
  ReGr(Image_Error);
  DataArray := Error_Month(SpEd_Error.Value, Cb_Error.Text,
    GetColData(StringGrid_Load, ComBoxX), GetColData(StringGrid_Load, ComBoxY),
    GetColRowData(StringGrid_Result, CB_Pred));
  ClearStrGrid(StringGrid_Load, SG_Error);
  AddColStGr3(SG_Error, DataArray, 'Modelo');
  X := GetColDataint(SG_Error, 0);
  Y := GetColDataint(SG_Error, 1);

  Graficar1(Image_Error, SpEd_Pred.Value, SpEd_Graf.Value, X, Y);

end;

procedure TForm1.CB_ModChange(Sender: TObject);
begin

  Lb_MA_HW.Visible := False;
  Ed_MA_HW.Visible := False;
  Lb_Trend.Visible := False;
  Ed_Trend.Visible := False;
  Lb_Seas_Cons.Visible := False;
  Ed_Seas_Con.Visible := False;
  Lb_season.Visible := False;
  SpEd_Season.Visible := False;
  Lb_AR.Visible := False;
  SpEd_AR.Visible := False;
  Lb_MA.Visible := False;
  SpEd_MA.Visible := False;
  Lb_I.Visible := False;
  SpEd_I.Visible := False;

  if -1 < CB_Mod.ItemIndex then
  begin
    if CB_Mod.Text = 'EWMA' then
    begin
      Lb_MA_HW.Visible := True;
      Ed_MA_HW.Visible := True;

    end
    else if CB_Mod.Text = 'Holt' then
    begin
      Lb_MA_HW.Visible := True;
      Ed_MA_HW.Visible := True;
      Lb_Trend.Visible := True;
      Ed_Trend.Visible := True;

    end
    else if CB_Mod.Text = 'HoltWintersAdditive' then
    begin
      Lb_MA_HW.Visible := True;
      Ed_MA_HW.Visible := True;
      Lb_Trend.Visible := True;
      Ed_Trend.Visible := True;
      Lb_Seas_Cons.Visible := True;
      Ed_Seas_Con.Visible := True;
      Lb_season.Visible := True;
      SpEd_Season.Visible := True;

    end
    else if CB_Mod.Text = 'HoltWintersMul' then
    begin
      Lb_MA_HW.Visible := True;
      Ed_MA_HW.Visible := True;
      Lb_Trend.Visible := True;
      Ed_Trend.Visible := True;
      Lb_Seas_Cons.Visible := True;
      Ed_Seas_Con.Visible := True;
      Lb_season.Visible := True;
      SpEd_Season.Visible := True;

    end
    else if CB_Mod.Text = 'ARIMA' then
    begin
      Lb_AR.Visible := True;
      SpEd_AR.Visible := True;
      Lb_MA.Visible := True;
      SpEd_MA.Visible := True;
      Lb_I.Visible := True;
      SpEd_I.Visible := True;

    end;

  end;

end;

procedure TForm1.CB_PredChange(Sender: TObject);
var
  StrLis, W, X, Y: TStringList;
  DataArray: TArray<TArray<Double>>;
  j, pred: Integer;
  Model: TPredictionModels;
  ModelActions: TDictionary<string, TFunc<TStringList>>;
  Action: TFunc<TStringList>;
begin

  ReGr(Image_Graf);
  ReGr(Image_Error);

  if ComBoxY.ItemIndex > 0 then
  begin
    StrLis := PrepDatStrGr(StringGrid_Load, ComBoxY);
    pred := SpEd_Pred.Value;
    ReGr(Image_Graf);
    X := GetColData(StringGrid_Load, ComBoxX);
    Y := GetColData(StringGrid_Load, ComBoxY);
    W := TStringList.Create;
    W := TStringList.Create;

    // Crear un diccionario con las funciones correspondientes
    ModelActions := TDictionary < string, TFunc < TStringList >>.Create;
    try
      ModelActions.Add('EWMA',
        function: TStringList
        begin
          Result := GetColRowData(StringGrid_Result, CB_Pred);
        end);
      ModelActions.Add('HoltWintersAdditive',
        function: TStringList
        begin
          Result := GetColRowData(StringGrid_Result, CB_Pred);
        end);
      ModelActions.Add('HoltWintersMul',
        function: TStringList
        begin
          Result := GetColRowData(StringGrid_Result, CB_Pred);
        end);
      ModelActions.Add('ARIMA',
        function: TStringList
        begin
          Result := GetColRowData(StringGrid_Result, CB_Pred);
        end);

      if ModelActions.TryGetValue(CB_Mod.Text, Action) then
      begin
        W := Action();

      end;

    finally
      ModelActions.Free;
    end;

    ReGr(Image_Graf);

    Graficar2(Image_Graf, SpEd_Pred.Value, SpEd_Graf.Value, X, Y, W);

    if (-1 < CB_Pred.ItemIndex) and (-1 < ComBoxY.ItemIndex) and
      not(W.Count = 0) and not(Y.Count = 0) then
    begin
      X := GetColDataint(SG_Error, 0);
      Y := GetColDataint(SG_Error, 1);
      Graficar1(Image_Error, SpEd_Pred.Value, SpEd_Graf.Value, X, Y);
    end;

  end;

end;

procedure TForm1.ComBox1Change(Sender: TObject);

begin
  cbcol(StringGrid_Result, ComBoxX, ComBoxY);
end;

end.
