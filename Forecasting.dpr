program Forecasting;

uses
  Vcl.Forms,
  Modelos in 'Modelos.pas' {Form1},
  src_CSV_StrGrt in 'src_CSV_StrGrt.pas',
  src_Grafica in 'src_Grafica.pas',
  src_cbCol in 'src_cbCol.pas',
  src_Mod_HW in 'src_Mod_HW.pas',
  src_PrepDatStrGr in 'src_PrepDatStrGr.pas',
  src_ARIMA in 'src_ARIMA.pas',
  src_Pred_Mod in 'src_Pred_Mod.pas',
  scr_ARIMAPM in 'scr_ARIMAPM.pas',
  Vcl.Themes,
  Vcl.Styles,
  src_Error in 'src_Error.pas',
  src_Mod_HW_POO in 'src_Mod_HW_POO.pas',
  src_Models in 'src_Models.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Luna');
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
