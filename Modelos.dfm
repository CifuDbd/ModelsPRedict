object Form1: TForm1
  Left = 161
  Top = 98
  Caption = #39
  ClientHeight = 490
  ClientWidth = 1033
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnResize = CB_PredChange
  TextHeight = 15
  object TabsModels: TPageControl
    Left = 0
    Top = 0
    Width = 847
    Height = 490
    ActivePage = Graphs
    Align = alClient
    TabOrder = 0
    Touch.InteractiveGestures = []
    object Data: TTabSheet
      Caption = 'Data'
      ImageIndex = 4
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 839
        Height = 460
        ActivePage = DataResult
        Align = alClient
        TabOrder = 0
        object LoadData: TTabSheet
          Caption = 'LoadData'
          object StringGrid_Load: TStringGrid
            Left = 0
            Top = 0
            Width = 831
            Height = 430
            Align = alClient
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
            TabOrder = 0
            RowHeights = (
              24
              24
              24
              24
              24)
          end
        end
        object DataResult: TTabSheet
          Caption = 'DataResult'
          ImageIndex = 1
          object StringGrid_Result: TStringGrid
            Left = 0
            Top = 0
            Width = 831
            Height = 430
            Align = alClient
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
            TabOrder = 0
            ColWidths = (
              64
              62
              51
              66
              63)
            RowHeights = (
              24
              24
              24
              24
              24)
          end
        end
        object Error: TTabSheet
          Caption = 'Error'
          ImageIndex = 2
          object SG_Error: TStringGrid
            Left = 0
            Top = 0
            Width = 831
            Height = 430
            Align = alClient
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
            TabOrder = 0
          end
        end
      end
    end
    object Graphs: TTabSheet
      Caption = 'Graphs'
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 839
        Height = 460
        Align = alClient
        TabOrder = 0
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 837
          Height = 59
          Align = alTop
          Anchors = []
          TabOrder = 0
          object Lab_Temp: TLabel
            Left = 16
            Top = 5
            Width = 104
            Height = 15
            Caption = 'Temporary measure'
          end
          object Lab_Pred: TLabel
            Left = 152
            Top = 5
            Width = 89
            Height = 15
            Caption = 'Graph Prediction'
          end
          object ComBoxX: TComboBox
            Left = 16
            Top = 26
            Width = 104
            Height = 23
            ImeName = 'CB_AxX'
            TabOrder = 0
            Text = 'Select'
            OnChange = CB_PredChange
          end
          object CB_Pred: TComboBox
            Left = 152
            Top = 26
            Width = 113
            Height = 23
            ImeName = 'CB_Pred'
            TabOrder = 1
            Text = 'Select'
            OnChange = CB_PredChange
          end
          object SpEd_Graf: TSpinEdit
            Left = 301
            Top = 19
            Width = 42
            Height = 24
            MaxValue = 100
            MinValue = 1
            TabOrder = 2
            Value = 5
            OnChange = CB_PredChange
          end
          object Mem_MAPE: TMemo
            Left = 427
            Top = 2
            Width = 185
            Height = 52
            Lines.Strings = (
              'Mem_MAPE')
            TabOrder = 3
          end
        end
        object Panel4: TPanel
          Left = 1
          Top = 60
          Width = 837
          Height = 399
          Align = alClient
          TabOrder = 1
          object Image_Graf: TImage
            Left = 1
            Top = 1
            Width = 835
            Height = 167
            Align = alClient
            AutoSize = True
            Center = True
            ExplicitLeft = 7
            ExplicitTop = 6
            ExplicitWidth = 852
            ExplicitHeight = 401
          end
          object Pan_Graph_er: TPanel
            Left = 1
            Top = 168
            Width = 835
            Height = 230
            Align = alBottom
            Anchors = []
            TabOrder = 0
            object Image_Error: TImage
              Left = 1
              Top = 52
              Width = 833
              Height = 177
              Align = alBottom
            end
            object Lb_Error: TLabel
              Left = 15
              Top = 1
              Width = 73
              Height = 15
              Caption = 'Error measure'
            end
            object Cb_Error: TComboBox
              Left = 15
              Top = 22
              Width = 145
              Height = 23
              TabOrder = 0
              Text = 'Error'
              OnChange = Cb_ErrorChange
              Items.Strings = (
                'MAPE'
                'MAE')
            end
            object SpEd_Error: TSpinEdit
              Left = 198
              Top = 22
              Width = 42
              Height = 24
              MaxValue = 100
              MinValue = 1
              TabOrder = 1
              Value = 5
              OnChange = Cb_ErrorChange
            end
          end
        end
      end
    end
  end
  object Panel_Argum: TPanel
    Left = 847
    Top = 0
    Width = 186
    Height = 490
    Align = alRight
    TabOrder = 1
    object Lab_Mod: TLabel
      Left = 6
      Top = 78
      Width = 34
      Height = 15
      Caption = 'Model'
    end
    object Lab_Arg: TLabel
      Left = 6
      Top = 176
      Width = 54
      Height = 15
      Caption = 'Argument'
    end
    object Lab_Load: TLabel
      Left = 6
      Top = 17
      Width = 18
      Height = 15
      Caption = 'File'
    end
    object Lb_Trend: TLabel
      Left = 16
      Top = 343
      Width = 29
      Height = 15
      Caption = 'Trend'
      Visible = False
    end
    object Lb_Seas_Cons: TLabel
      Left = 16
      Top = 393
      Width = 95
      Height = 15
      Caption = 'Seasonal constant'
      Visible = False
    end
    object Lb_season: TLabel
      Left = 16
      Top = 443
      Width = 37
      Height = 15
      Caption = 'Season'
      Visible = False
    end
    object Lb_AR: TLabel
      Left = 112
      Top = 292
      Width = 15
      Height = 15
      Caption = 'AR'
      Visible = False
    end
    object Lb_I: TLabel
      Left = 113
      Top = 343
      Width = 3
      Height = 15
      Caption = 'I'
      Visible = False
    end
    object Lb_MA: TLabel
      Left = 109
      Top = 393
      Width = 19
      Height = 15
      Caption = 'MA'
      Visible = False
    end
    object Lb_MA_HW: TLabel
      Left = 16
      Top = 289
      Width = 19
      Height = 15
      Caption = 'MA'
      Visible = False
    end
    object CB_Mod: TComboBox
      Left = 6
      Top = 99
      Width = 171
      Height = 23
      ImeName = 'CbMod'
      TabOrder = 0
      Text = #39
      OnChange = CB_ModChange
      Items.Strings = (
        'HoltWintersAdditive'
        'HoltWintersMul'
        'ARIMA')
    end
    object btnProcess: TButton
      Left = 6
      Top = 234
      Width = 75
      Height = 25
      Caption = 'Process'
      TabOrder = 1
      OnClick = btnProcessClick
    end
    object SpEd_Pred: TSpinEdit
      Left = 133
      Top = 235
      Width = 42
      Height = 24
      MaxValue = 100
      MinValue = 1
      TabOrder = 2
      Value = 5
    end
    object btnLoad: TButton
      Left = 6
      Top = 38
      Width = 75
      Height = 25
      Caption = 'Load CSV'
      TabOrder = 3
      OnClick = btnLoadClick
    end
    object cmbxSep: TComboBox
      Left = 87
      Top = 39
      Width = 90
      Height = 23
      TabOrder = 4
      Text = ','
      Items.Strings = (
        ';'
        ',')
    end
    object ComBoxY: TComboBox
      Left = 6
      Top = 197
      Width = 171
      Height = 23
      ImeName = 'ComBox'
      TabOrder = 5
      Text = 'Select'
      OnChange = CB_PredChange
    end
    object Ed_MA_HW: TEdit
      Left = 14
      Top = 314
      Width = 59
      Height = 23
      TabOrder = 6
      Text = '0.5'
      Visible = False
    end
    object Ed_Trend: TEdit
      Left = 14
      Top = 364
      Width = 59
      Height = 23
      TabOrder = 7
      Text = '0.5'
      Visible = False
    end
    object Ed_Seas_Con: TEdit
      Left = 14
      Top = 414
      Width = 59
      Height = 23
      TabOrder = 8
      Text = '0.5'
      Visible = False
    end
    object SpEd_AR: TSpinEdit
      Left = 111
      Top = 313
      Width = 42
      Height = 24
      MaxValue = 100
      MinValue = 0
      TabOrder = 9
      Value = 12
      Visible = False
    end
    object SpEd_I: TSpinEdit
      Left = 109
      Top = 363
      Width = 42
      Height = 24
      MaxValue = 100
      MinValue = 0
      TabOrder = 10
      Value = 1
      Visible = False
    end
    object SpEd_MA: TSpinEdit
      Left = 109
      Top = 414
      Width = 42
      Height = 24
      MaxValue = 100
      MinValue = 0
      TabOrder = 11
      Value = 12
      Visible = False
    end
    object SpEd_Season: TSpinEdit
      Left = 15
      Top = 464
      Width = 42
      Height = 24
      MaxValue = 100
      MinValue = 0
      TabOrder = 12
      Value = 12
      Visible = False
    end
    object Btn_Optimize: TButton
      Left = 6
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Optimize'
      TabOrder = 13
      OnClick = Btn_OptimizeClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 1000
    Top = 128
  end
end
