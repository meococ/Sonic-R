//+------------------------------------------------------------------+
//|                               Indicator_SonicR_PVA_Volumes.mq5 |
//|               Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI   |
//|      Adapted from 'SonicR PVA Volumes.mq4' for modern MQL5       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI"
#property link      "https://www.your-project-link.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_minimum 0

//--- Plot 1: PVA Volume Histogram
#property indicator_label1  "PVA Volume"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDodgerBlue,clrBlueViolet,clrLimeGreen,clrRed // Color palette
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- Input Parameters
input group "--- PVA Volume Settings ---"
input bool   InpIndicatorOn = true;         // Indicator On
input int    InpPVAPeriod = 10;             // PVA Lookback Period
input double InpRisingVolumeFactor = 1.5;   // Rising Volume Factor (e.g., 1.5 = 150%)
input double InpClimaxVolumeFactor = 2.0;   // Climax Volume Factor (e.g., 2.0 = 200%)

input group "--- Colors ---"
input color InpPVA_Normal = clrDimGray;          // Normal Volume
input color InpPVA_RisingBull = clrDodgerBlue;   // Rising Volume Bullish
input color InpPVA_RisingBear = clrBlueViolet;   // Rising Volume Bearish
input color InpPVA_ClimaxBull = clrLimeGreen;    // Climax Volume Bullish
input color InpPVA_ClimaxBear = clrRed;          // Climax Volume Bearish

//--- Indicator Buffers
double VolumeBuffer[];
double ColorBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Indicator buffers mapping
    SetIndexBuffer(0, VolumeBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);

    //--- Set plot properties
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 3);
    
    //--- Define the color palette for the histogram
    PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 5);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpPVA_Normal);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpPVA_RisingBull);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, InpPVA_RisingBear);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, InpPVA_ClimaxBull);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 4, InpPVA_ClimaxBear);
    
    //--- Indicator ShortName
    IndicatorSetString(INDICATOR_SHORTNAME, "PVA Volumes(" + IntegerToString(InpPVAPeriod) + ")");
    
    return(INIT_SUCCEEDED);
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
    if(!InpIndicatorOn)
        return(rates_total);

    int start_pos = prev_calculated > 0 ? prev_calculated - 1 : 0;
    for(int i = start_pos; i < rates_total; i++)
    {
        VolumeBuffer[i] = (double)tick_volume[i];

        // Not enough history for PVA calculation
        if(i < InpPVAPeriod)
        {
            ColorBuffer[i] = 0; // Normal color
            continue;
        }

        // --- PVA Logic ---
        // Calculate average volume over the lookback period
        double avg_vol = 0;
        for(int j = 1; j <= InpPVAPeriod; j++)
        {
            avg_vol += (double)tick_volume[i - j];
        }
        avg_vol /= InpPVAPeriod;

        // Calculate max (spread * volume) over the lookback period
        double max_spread_vol = 0;
        for(int j = 1; j <= InpPVAPeriod; j++)
        {
            double spread_vol = (double)tick_volume[i - j] * (high[i - j] - low[i - j]);
            if(spread_vol > max_spread_vol)
            {
                max_spread_vol = spread_vol;
            }
        }
        
        // Check current bar's PVA conditions
        double current_spread_vol = (double)tick_volume[i] * (high[i] - low[i]);
        bool isClimax = (current_spread_vol >= max_spread_vol && max_spread_vol > 0) || ((double)tick_volume[i] >= InpClimaxVolumeFactor * avg_vol && avg_vol > 0);
        bool isRising = (double)tick_volume[i] >= InpRisingVolumeFactor * avg_vol && avg_vol > 0;
        bool isBullish = close[i] >= open[i];

        // Set color index based on conditions
        if(isClimax)
        {
            ColorBuffer[i] = isBullish ? 3 : 4; // Climax Bull/Bear
        }
        else if(isRising)
        {
            ColorBuffer[i] = isBullish ? 1 : 2; // Rising Bull/Bear
        }
        else
        {
            ColorBuffer[i] = 0; // Normal
        }
    }
    
    return(rates_total);
}
//+------------------------------------------------------------------+ 