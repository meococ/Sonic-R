//+------------------------------------------------------------------+
//|                                      Indicator_SonicR_Dragon.mq5 |
//|               Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI   |
//|      Converted from MQL4 version by traderathome and qFish       |
//|      Enhanced with PVA from SonicR Black Chart Setup             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI"
#property link      "https://www.your-project-link.com"
#property version   "2.01" // Reverted from Rainbow, with fixes

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   7

//--- Input Parameters
//--- Dragon & Trend Settings
input int InpDragonPeriod = 34;    // Dragon EMA Period
input int InpTrendPeriod = 89;     // Trend EMA Period
input int InpEMA200Period = 200;   // Long-term Trend EMA Period

//--- PVA Settings
input bool InpPVAEnable = true;                      // Enable Price-Volume Analysis
input int  InpPVAPeriod = 10;                        // PVA Lookback Period
input double InpRisingVolumeFactor = 1.5;            // Rising Volume Factor (e.g., 1.5 = 150%)
input double InpClimaxVolumeFactor = 2.0;            // Climax Volume Factor (e.g., 2.0 = 200%)
input color InpPVA_NormalBull = clrSilver;           // Normal Bullish Candle
input color InpPVA_NormalBear = clrGray;             // Normal Bearish Candle
input color InpPVA_RisingBull = clrDodgerBlue;       // Rising Volume Bullish
input color InpPVA_RisingBear = clrBlueViolet;       // Rising Volume Bearish
input color InpPVA_ClimaxBull = clrLimeGreen;        // Climax Volume Bullish
input color InpPVA_ClimaxBear = clrRed;              // Climax Volume Bearish


//--- Plot 1: Dragon Upper
#property indicator_label1  "Dragon Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot 2: Dragon Middle
#property indicator_label2  "Dragon Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Plot 3: Dragon Lower
#property indicator_label3  "Dragon Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRoyalBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- Plot 4: Trend Line
#property indicator_label4  "Trend Line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

//--- Plot 5: EMA 200
#property indicator_label5  "EMA(200)"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

//--- Plot 6: Dragon Fill
#property indicator_label6  "Dragon Fill"
#property indicator_type6   DRAW_FILLING
#property indicator_color6  C'20,135,206,250' // Lighter Transparent Blue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- Plot 7: PVA Candles
#property indicator_label7  "PVA Candles"
#property indicator_type7   DRAW_COLOR_CANDLES
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1

//--- Indicator Buffers
double DragonUpperBuffer[];
double DragonMiddleBuffer[];
double DragonLowerBuffer[];
double TrendBuffer[];
double EMA200Buffer[];
double FillUpBuffer[];
double FillDownBuffer[];

//--- PVA Buffers
double PVACandleOpen[];
double PVACandleHigh[];
double PVACandleLow[];
double PVACandleClose[];
double PVACandleColor[];

//--- Indicator Handles
int DragonHighHandle;
int DragonLowHandle;
int DragonMiddleHandle;
int TrendHandle;
int EMA200Handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Indicator buffers mapping
    SetIndexBuffer(0, DragonUpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, DragonMiddleBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, DragonLowerBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, TrendBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, EMA200Buffer, INDICATOR_DATA);
    SetIndexBuffer(5, FillUpBuffer, INDICATOR_DATA);
    SetIndexBuffer(6, FillDownBuffer, INDICATOR_DATA);
    
    //--- Map PVA buffers
    SetIndexBuffer(7, PVACandleOpen, INDICATOR_DATA);
    SetIndexBuffer(8, PVACandleHigh, INDICATOR_DATA);
    SetIndexBuffer(9, PVACandleLow, INDICATOR_DATA);
    SetIndexBuffer(10, PVACandleClose, INDICATOR_DATA);
    SetIndexBuffer(11, PVACandleColor, INDICATOR_COLOR_INDEX);

    //--- Create indicator handles
    DragonHighHandle = iMA(_Symbol, _Period, InpDragonPeriod, 0, MODE_EMA, PRICE_HIGH);
    DragonLowHandle = iMA(_Symbol, _Period, InpDragonPeriod, 0, MODE_EMA, PRICE_LOW);
    DragonMiddleHandle = iMA(_Symbol, _Period, InpDragonPeriod, 0, MODE_EMA, PRICE_CLOSE);
    TrendHandle = iMA(_Symbol, _Period, InpTrendPeriod, 0, MODE_EMA, PRICE_CLOSE);
    EMA200Handle = iMA(_Symbol, _Period, InpEMA200Period, 0, MODE_EMA, PRICE_CLOSE);

    if (DragonHighHandle == INVALID_HANDLE || DragonLowHandle == INVALID_HANDLE ||
        DragonMiddleHandle == INVALID_HANDLE || TrendHandle == INVALID_HANDLE || EMA200Handle == INVALID_HANDLE)
    {
        printf("Error creating indicator handles");
        return(INIT_FAILED);
    }
    
    //--- Set empty value for plots
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0.0);

    //--- Set PVA plot properties
    PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
    PlotIndexSetString(6, PLOT_LABEL, "PVA Candles");
    PlotIndexSetInteger(6, PLOT_SHOW_DATA, InpPVAEnable);
    
    //--- Define the color palette for PVA candles
    PlotIndexSetInteger(6, PLOT_COLOR_INDEXES, 6);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 0, InpPVA_NormalBull);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 1, InpPVA_NormalBear);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 2, InpPVA_RisingBull);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 3, InpPVA_RisingBear);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 4, InpPVA_ClimaxBull);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, 5, InpPVA_ClimaxBear);

    //--- Set plot labels and short name
    string short_name = StringFormat("SonicR Dragon+PVA(%d, %d, %d)", InpDragonPeriod, InpTrendPeriod, InpEMA200Period);
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handles
    IndicatorRelease(DragonHighHandle);
    IndicatorRelease(DragonLowHandle);
    IndicatorRelease(DragonMiddleHandle);
    IndicatorRelease(TrendHandle);
    IndicatorRelease(EMA200Handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    //--- Copy data from indicator handles to buffers
    if(CopyBuffer(DragonHighHandle, 0, 0, rates_total, DragonUpperBuffer) <= 0) return 0;
    if(CopyBuffer(DragonLowHandle, 0, 0, rates_total, DragonLowerBuffer) <= 0) return 0;
    if(CopyBuffer(DragonMiddleHandle, 0, 0, rates_total, DragonMiddleBuffer) <= 0) return 0;
    if(CopyBuffer(TrendHandle, 0, 0, rates_total, TrendBuffer) <= 0) return 0;
    if(CopyBuffer(EMA200Handle, 0, 0, rates_total, EMA200Buffer) <= 0) return 0;

    //--- Copy data to fill buffers
    if(CopyBuffer(DragonHighHandle, 0, 0, rates_total, FillUpBuffer) <= 0) return 0;
    if(CopyBuffer(DragonLowHandle, 0, 0, rates_total, FillDownBuffer) <= 0) return 0;

    //--- PVA Candle Calculation
    if(InpPVAEnable)
    {
        int start_pos = prev_calculated > 0 ? prev_calculated - 1 : 0;
        for(int i = start_pos; i < rates_total; i++)
        {
            // Set candle OHLC data
            PVACandleOpen[i] = open[i];
            PVACandleHigh[i] = high[i];
            PVACandleLow[i] = low[i];
            PVACandleClose[i] = close[i];

            // Not enough history for PVA calculation
            if(i < InpPVAPeriod)
            {
                PVACandleColor[i] = (close[i] >= open[i]) ? 0 : 1; // Normal colors
                continue;
            }

            // Calculate average volume
            double avg_vol = 0;
            for(int j = 1; j <= InpPVAPeriod; j++)
            {
                avg_vol += (double)tick_volume[i - j];
            }
            avg_vol /= InpPVAPeriod;

            // Calculate max (spread * volume)
            double max_spread_vol = 0;
            for(int j = 1; j <= InpPVAPeriod; j++)
            {
                double spread_vol = (double)tick_volume[i - j] * (high[i - j] - low[i - j]);
                if(spread_vol > max_spread_vol)
                {
                    max_spread_vol = spread_vol;
                }
            }
            
            // Check PVA conditions
            double current_spread_vol = (double)tick_volume[i] * (high[i] - low[i]);
            bool isClimax = (current_spread_vol >= max_spread_vol && max_spread_vol > 0) || ((double)tick_volume[i] >= InpClimaxVolumeFactor * avg_vol && avg_vol > 0);
            bool isRising = (double)tick_volume[i] >= InpRisingVolumeFactor * avg_vol && avg_vol > 0;
            bool isBullish = close[i] >= open[i];

            // Set candle color index
            if(isClimax)
            {
                PVACandleColor[i] = isBullish ? 4 : 5; // Climax Bull/Bear
            }
            else if(isRising)
            {
                PVACandleColor[i] = isBullish ? 2 : 3; // Rising Bull/Bear
            }
            else
            {
                PVACandleColor[i] = isBullish ? 0 : 1; // Normal Bull/Bear
            }
        }
    }

    //--- Return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+