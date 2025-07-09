//+------------------------------------------------------------------+
//| Indicator_Momentum.mq5 - Squeeze Momentum Indicator (Pro v4.0)   |
//| Copyright 2024, APEX Pullback EA                                |
//| TradingView PineScript logic ported to MQL5                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Pullback EA"
#property link      "https://www.mql5.com"
#property version   "4.0"

#include <Indicators/Indicators.mqh>

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2

//--- plot momentum histogram
#property indicator_label1  "Squeeze Momentum"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLawnGreen, clrDarkGreen, clrRed, clrIndianRed
#property indicator_width1  2

//--- plot squeeze line
#property indicator_label2  "Squeeze"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrBlue,clrBlack,clrGray
#property indicator_width2  2

//--- input parameters
input int    InpBBLength     = 20;    // Bollinger Bands period
input double InpBBMult       = 2.0;   // BB StdDev multiplier
input int    InpKCLength     = 20;    // Keltner Channel period
input double InpKCMult       = 1.5;   // KC ATR multiplier
input bool   InpUseTrueRange = true;  // Use TrueRange for KC

//--- indicator buffers
double MomentumBuffer[];        // Histogram
double MomentumColorBuffer[];   // Histogram color index
double ZeroLineBuffer[];        // Zero line data buffer
double ZeroLineColorBuffer[];   // Zero line color index

//--- handles for built-in indicators
int    ExtBBSmaHandle;  // Handle for BB basis (SMA)
int    ExtStdDevHandle; // Handle for StdDev
int    ExtKCSmaHandle;  // Handle for KC basis (SMA)
int    ExtAtrHandle;    // Handle for ATR

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Set buffers
    SetIndexBuffer(0, MomentumBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, MomentumColorBuffer, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, ZeroLineBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, ZeroLineColorBuffer, INDICATOR_COLOR_INDEX);
    
    //--- Set plot properties
    PlotIndexSetString(0, PLOT_LABEL, "Momentum");
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    PlotIndexSetString(1, PLOT_LABEL, "Squeeze");
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_COLOR_LINE);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
    
    //--- Short name
    IndicatorSetString(INDICATOR_SHORTNAME, "SqueezeMom(" + (string)InpBBLength + "," + (string)InpKCLength + ")");
    
    //--- Initialize zero line
    ArraySetAsSeries(ZeroLineBuffer, true);
    for(int i = 0; i < ArraySize(ZeroLineBuffer); i++)
        ZeroLineBuffer[i] = 0.0;
    
    //--- Create handles for indicators
    ExtBBSmaHandle = iMA(_Symbol, _Period, InpBBLength, 0, MODE_SMA, PRICE_CLOSE);
    ExtStdDevHandle = iStdDev(_Symbol, _Period, InpBBLength, 0, MODE_SMA, PRICE_CLOSE);
    ExtKCSmaHandle = iMA(_Symbol, _Period, InpKCLength, 0, MODE_SMA, PRICE_CLOSE);
    ExtAtrHandle = iATR(_Symbol, _Period, InpKCLength);
    
    if(ExtBBSmaHandle == INVALID_HANDLE || ExtStdDevHandle == INVALID_HANDLE || ExtKCSmaHandle == INVALID_HANDLE || ExtAtrHandle == INVALID_HANDLE)
    {
        Print("Error creating indicator handles");
        return INIT_FAILED;
    }
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(ExtBBSmaHandle);
    IndicatorRelease(ExtStdDevHandle);
    IndicatorRelease(ExtKCSmaHandle);
    IndicatorRelease(ExtAtrHandle);
}

//+------------------------------------------------------------------+
//| Linear Regression Value                                          |
//+------------------------------------------------------------------+
double LinRegValue(const double &src[], int length, int position)
{
    // Array passed to this function is newest-to-oldest (series).
    // Linear regression needs oldest-to-newest for a positive time-slope.
    if(position < length - 1)
        return 0.0;
    
    // The source (src) is already a pre-calculated series of (close-centerline)
    // We just need to perform regression on the last 'length' elements ending at 'position'
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    for(int i = 0; i < length; i++)
    {
        double x = i;
        // Accessing series from oldest to newest for regression
        double y = src[position - length + 1 + i];
        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumXX += x * x;
    }

    double D = length * sumXX - sumX * sumX;
    if(D == 0)
        return 0.0;

    double slope = (length * sumXY - sumX * sumY) / D;
    double intercept = (sumY - slope * sumX) / length;
    return slope * (length - 1) + intercept;
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
    //--- Check for enough data
    int required_bars = MathMax(InpBBLength, InpKCLength) + InpKCLength;
    if(rates_total < required_bars)
        return 0;

    //--- Determine calculation range
    int start_pos = prev_calculated > 0 ? prev_calculated - 1 : 0;
    if(start_pos == 0)
    {
        for(int i = 0; i < required_bars; i++) MomentumBuffer[i] = 0;
        start_pos = required_bars;
    }

    //--- Get indicator values
    double bbsma[], stdev[], kcsma[], atr[];
    ArrayResize(bbsma, rates_total);
    ArrayResize(stdev, rates_total);
    ArrayResize(kcsma, rates_total);
    ArrayResize(atr, rates_total);

    if(CopyBuffer(ExtBBSmaHandle, 0, 0, rates_total, bbsma) <= 0) return 0;
    if(CopyBuffer(ExtStdDevHandle, 0, 0, rates_total, stdev) <= 0) return 0;
    if(CopyBuffer(ExtKCSmaHandle, 0, 0, rates_total, kcsma) <= 0) return 0;
    if(CopyBuffer(ExtAtrHandle, 0, 0, rates_total, atr) <= 0) return 0;

    //--- Precompute Highest High, Lowest Low
    double highestHigh[], lowestLow[];
    ArrayResize(highestHigh, rates_total);
    ArrayResize(lowestLow, rates_total);
    for(int i = 1; i < rates_total; i++)
    {
        double hh = high[i];
        for(int j = 1; j < InpKCLength; j++)
        {
            if(i - j < 0) break;
            if(high[i - j] > hh) hh = high[i - j];
        }
        highestHigh[i] = hh;

        double ll = low[i];
        for(int j = 1; j < InpKCLength; j++)
        {
            if(i - j < 0) break;
            if(low[i - j] < ll) ll = low[i - j];
        }
        lowestLow[i] = ll;
    }

    //--- Prepare source for linear regression
    double linreg_src[];
    ArrayResize(linreg_src, rates_total);
    for(int i = 1; i < rates_total; i++)
    {
        double avgHighLow = (highestHigh[i] + lowestLow[i]) / 2.0;
        double centerline = (avgHighLow + kcsma[i]) / 2.0;
        linreg_src[i] = close[i] - centerline;
    }
    
    //--- Main calculation loop
    for(int i = start_pos; i < rates_total && !IsStopped(); i++)
    {
        //--- Calculate Bollinger Bands
        double upperBB = bbsma[i] + stdev[i] * InpBBMult;
        double lowerBB = bbsma[i] - stdev[i] * InpBBMult;

        //--- Calculate Keltner Channel
        double range = InpUseTrueRange ? atr[i] : (high[i] - low[i]);
        double kcUpper = kcsma[i] + range * InpKCMult;
        double kcLower = kcsma[i] - range * InpKCMult;

        //--- Squeeze detection (Corrected logic from PineScript)
        bool sqzOn  = (lowerBB > kcLower) && (upperBB < kcUpper);
        bool sqzOff = (lowerBB < kcLower) && (upperBB > kcUpper);
        bool noSqz  = !sqzOn && !sqzOff;

        //--- Calculate momentum
        MomentumBuffer[i] = LinRegValue(linreg_src, InpKCLength, i);
        ZeroLineBuffer[i] = 0.0;

        //--- Histogram color logic
        if(i > 0)
        {
            double prevMom = MomentumBuffer[i - 1];
            if(MomentumBuffer[i] > 0)
                MomentumColorBuffer[i] = (MomentumBuffer[i] > prevMom) ? 0.0 : 1.0; // lime or green
            else
                MomentumColorBuffer[i] = (MomentumBuffer[i] < prevMom) ? 2.0 : 3.0; // red or maroon
        }
        else
        {
            MomentumColorBuffer[i] = (MomentumBuffer[i] > 0) ? 0.0 : 2.0;
        }

        //--- Squeeze line color logic
        if(noSqz)
            ZeroLineColorBuffer[i] = 0.0; // blue
        else if(sqzOn)
            ZeroLineColorBuffer[i] = 1.0; // black
        else // sqzOff
            ZeroLineColorBuffer[i] = 2.0; // gray
    }

    return rates_total;
}
//+------------------------------------------------------------------+ 