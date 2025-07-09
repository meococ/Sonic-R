//+------------------------------------------------------------------+
//| Indicator_Momentum.mq5 - Squeeze Momentum Indicator (Pro)        |
//| Copyright 2024, APEX Pullback EA                                |
//| TradingView PineScript logic ported to MQL5                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Pullback EA"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3

//--- Histogram (momentum)
#property indicator_label1  "Squeeze Momentum"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLime, clrGreen, clrRed, clrMaroon
#property indicator_width1  4

//--- Squeeze state (dots)
#property indicator_label2  "Squeeze State"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue, clrBlack, clrGray
#property indicator_width2  2

//--- Zero line
#property indicator_label3  "Zero Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_width3  1

//--- Input parameters
input int    InpBBLength = 20;        // Bollinger Bands Length
input double InpBBMult   = 2.0;       // Bollinger Bands Multiplier
input int    InpKCLength = 20;        // Keltner Channel Length
input double InpKCMult   = 1.5;       // Keltner Channel Multiplier
input bool   InpUseTrueRange = true;  // Use True Range for KC
input int    InpLinregLength = 20;    // Linear Regression Length

//--- Buffers
double MomentumBuffer[];      // Histogram
double MomentumColorBuffer[]; // Histogram color index

double SqueezeDotBuffer[];    // Dot/cross on zero line
double SqueezeDotColorBuffer[];// Dot color index

double ZeroBuffer[];          // Zero line

//--- Handles for iMA, iStdDev, iATR
int BB_MA_Handle, BB_Std_Handle, KC_MA_Handle, KC_ATR_Handle;

//--- Arrow code for dot (Wingdings 159)
#define DOT_CODE 159

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, MomentumBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, SqueezeDotBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ZeroBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, MomentumColorBuffer, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(4, SqueezeDotColorBuffer, INDICATOR_COLOR_INDEX);

    PlotIndexSetInteger(1, PLOT_ARROW, DOT_CODE);
    IndicatorSetInteger(INDICATOR_DIGITS, 5);
    IndicatorSetString(INDICATOR_SHORTNAME, "SQZMOM_LB Pro");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if(BB_MA_Handle != INVALID_HANDLE) IndicatorRelease(BB_MA_Handle);
    if(BB_Std_Handle != INVALID_HANDLE) IndicatorRelease(BB_Std_Handle);
    if(KC_MA_Handle != INVALID_HANDLE) IndicatorRelease(KC_MA_Handle);
    if(KC_ATR_Handle != INVALID_HANDLE) IndicatorRelease(KC_ATR_Handle);
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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
    int start = MathMax(InpBBLength, MathMax(InpKCLength, InpLinregLength));
    if(rates_total <= start+2) return 0;

    //--- Create handles if needed
    if(BB_MA_Handle == INVALID_HANDLE)
        BB_MA_Handle = iMA(_Symbol, _Period, InpBBLength, 0, MODE_SMA, PRICE_CLOSE);
    if(BB_Std_Handle == INVALID_HANDLE)
        BB_Std_Handle = iStdDev(_Symbol, _Period, InpBBLength, 0, MODE_SMA, PRICE_CLOSE);
    if(KC_MA_Handle == INVALID_HANDLE)
        KC_MA_Handle = iMA(_Symbol, _Period, InpKCLength, 0, MODE_SMA, PRICE_CLOSE);
    if(KC_ATR_Handle == INVALID_HANDLE)
        KC_ATR_Handle = iATR(_Symbol, _Period, InpKCLength);

    //--- Copy buffers
    static double bb_ma[], bb_std[], kc_ma[], kc_atr[];
    ArraySetAsSeries(bb_ma, true); ArraySetAsSeries(bb_std, true);
    ArraySetAsSeries(kc_ma, true); ArraySetAsSeries(kc_atr, true);
    CopyBuffer(BB_MA_Handle, 0, 0, rates_total, bb_ma);
    CopyBuffer(BB_Std_Handle, 0, 0, rates_total, bb_std);
    CopyBuffer(KC_MA_Handle, 0, 0, rates_total, kc_ma);
    CopyBuffer(KC_ATR_Handle, 0, 0, rates_total, kc_atr);

    //--- Main loop
    for(int i=start; i<rates_total; i++)
    {
        //--- Bollinger Bands
        double basis = bb_ma[i];
        double dev = InpBBMult * bb_std[i];
        double upperBB = basis + dev;
        double lowerBB = basis - dev;

        //--- Keltner Channel
        double rangema = InpUseTrueRange ? kc_atr[i] : (ArrayMaximum(high, InpKCLength, i-InpKCLength+1) - ArrayMinimum(low, InpKCLength, i-InpKCLength+1));
        double upperKC = kc_ma[i] + rangema * InpKCMult;
        double lowerKC = kc_ma[i] - rangema * InpKCMult;

        //--- Squeeze state
        bool sqzOn  = (lowerBB > lowerKC) && (upperBB < upperKC);
        bool sqzOff = (lowerBB < lowerKC) && (upperBB > upperKC);
        bool noSqz  = (!sqzOn && !sqzOff);

        //--- Centerline for momentum
        double highestHigh = ArrayMaximum(high, InpKCLength, i-InpKCLength+1);
        double lowestLow   = ArrayMinimum(low, InpKCLength, i-InpKCLength+1);
        double avgHL = (highestHigh + lowestLow) / 2.0;
        double smaClose = 0.0;
        for(int j=0; j<InpKCLength; j++) smaClose += close[i-j];
        smaClose /= InpKCLength;
        double centerline = (avgHL + smaClose) / 2.0;

        //--- Source for linreg
        double src = close[i] - centerline;
        //--- Build array for linreg
        double linregArr[];
        ArrayResize(linregArr, InpLinregLength);
        for(int j=0; j<InpLinregLength; j++)
            linregArr[j] = close[i-j] - centerline;
        //--- Calculate linreg value (not slope!)
        double linregVal = LinearRegressionValue(linregArr, InpLinregLength);
        MomentumBuffer[i] = linregVal;
        ZeroBuffer[i] = 0.0;

        //--- Histogram color
        if(i>0)
        {
            if(MomentumBuffer[i] > 0)
                MomentumColorBuffer[i] = (MomentumBuffer[i] > MomentumBuffer[i-1]) ? 0.0 : 1.0; // lime/green
            else
                MomentumColorBuffer[i] = (MomentumBuffer[i] < MomentumBuffer[i-1]) ? 2.0 : 3.0; // red/maroon
        }
        else
            MomentumColorBuffer[i] = 0.0;

        //--- Squeeze dot
        SqueezeDotBuffer[i] = 0.0;
        if(sqzOn)      SqueezeDotColorBuffer[i] = 1.0; // black
        else if(sqzOff)SqueezeDotColorBuffer[i] = 2.0; // gray
        else           SqueezeDotColorBuffer[i] = 0.0; // blue
    }
    return rates_total;
}

//+------------------------------------------------------------------+
//| Linear Regression Value (like PineScript linreg, not slope)      |
//+------------------------------------------------------------------+
double LinearRegressionValue(const double &arr[], int length)
{
    double sumX=0, sumY=0, sumXY=0, sumX2=0;
    for(int i=0; i<length; i++)
    {
        double x = i;
        double y = arr[length-1-i]; // reverse for MQL5
        sumX += x;
        sumY += y;
        sumXY += x*y;
        sumX2 += x*x;
    }
    double slope = (length*sumXY - sumX*sumY) / (length*sumX2 - sumX*sumX);
    double intercept = (sumY - slope*sumX) / length;
    return slope*(length-1) + intercept;
}
//+------------------------------------------------------------------+
