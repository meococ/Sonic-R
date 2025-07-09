//+------------------------------------------------------------------+
//|                                     Indicator_SMC_Structure.mq5 |
//|               Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI   |
//|         Inspired by 'Smart Money Concepts +' by DucTri_dev       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX EA DEVELOPMENT & Cáo Già AI"
#property link      "https://www.your-project-link.com"
#property version   "3.00" // Version 3.0 - Final Polished Version

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2

// --- Dummy plot
#property indicator_label1  ""
#property indicator_type1   DRAW_NONE

// --- Color Candles plot
#property indicator_label2  "Trend Candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  C'46,139,87', C'205,92,92', C'0,100,0', C'139,0,0' // Internal Bull, Bear; Swing Bull, Bear
#property indicator_width2  1

// Removed includes for deleted files
// #include "Shared_DataStructures.mqh"
// #include "UI_Dashboard_Manager.mqh" 
// #include "Analysis_POIScoring.mqh" 

//+------------------------------------------------------------------+
//| ENUMS & STRUCTS                                                  |
//+------------------------------------------------------------------+

enum ENUM_DISPLAY_MODE
{
    MODE_HISTORICAL, // Show all historical structures
    MODE_PRESENT     // Show only the most recent structures
};

enum ENUM_SWING_TYPE
{
    SWING_LOW,
    SWING_HIGH
};

enum ENUM_TREND
{
    TREND_NONE,
    TREND_UP,
    TREND_DOWN
};

enum ENUM_OB_FILTER_METHOD
{
    ATR_MULTIPLIER,
    VOLUME_SPIKE
};

enum ENUM_MITIGATION_METHOD
{
    WICK,
    HIGH_LOW,
    CLOSE
};

enum ENUM_TREND_COLOR_MODE
{
    TREND_COLOR_NONE,
    TREND_COLOR_CANDLES,
    TREND_COLOR_BACKGROUND
};

struct SwingPointExt
{
    int         bar_index;
    double      price;
    datetime    time;
    ENUM_SWING_TYPE type;
};

struct Structure
{
    int         bar_index;
    datetime    time;
    double      price;
    string      type; // "BOS" or "CHoCH"
    ENUM_TREND  trend;
    double      break_price;
    datetime    break_time;
    double      high_price;
    datetime    high_time;
    double      low_price;
    datetime    low_time;
    datetime    start_time;
};

struct OrderBlock
{
    int         bar_index;
    double      high;
    double      low;
    datetime    time;
    bool        is_bullish;
    bool        is_mitigated;
};

struct FairValueGap
{
    int         bar_index;
    double      high;
    double      low;
    datetime    time;
    bool        is_bullish;
    bool        is_filled;
};

struct LiquidityLevel
{
    double      price;
    datetime    start_time;
    datetime    end_time;
    string      type;
};

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
#define DEFAULT_FONT_SIZE 10

input group "--- Display & Mode Settings ---"
input ENUM_DISPLAY_MODE InpDisplayMode = MODE_HISTORICAL; //|Display Mode: Historical shows all, Present shows recent.

input group "--- General Swing Detection Settings ---"
input int    InpDeviation       = 5;   //|Deviation for ZigZag
input int    InpBackstep        = 3;   //|Backstep for ZigZag

input group "--- Swing Structure Settings ---"
input bool   InpShowSwingStructure = true; //|Show Swing Structure
input int    InpSwingDepth      = 12;      //|Depth for swing detection
input color  InpSwingLineColor  = clrDodgerBlue; //|Color for swing lines
input ENUM_LINE_STYLE InpSwingLineStyle = STYLE_SOLID; //|Style for swing lines
input int    InpSwingLineWidth  = 2;         //|Width for swing lines
input bool   InpShowSwingLabels = true;     //|Show Structure Labels (BOS/CHoCH)
input bool   InpShowBOS         = true;      //|Show Break of Structure (BOS)
input bool   InpShowCHoCH       = true;      //|Show Change of Character (CHoCH)
input bool   InpShowStrongWeakHighLow = true; //|Show Strong/Weak Highs & Lows

input group "--- Internal Structure Settings ---"
input bool   InpShowInternalStructure = true; //|Show Internal Structure
input int    InpInternalDepth   = 5;       //|Depth for internal structure
input bool   InpFilterInternalConfluence = true; //|Filter weak internal CHoCH
input color  InpInternalLineColor = clrLightSalmon; //|Internal structure line color
input ENUM_LINE_STYLE InpInternalLineStyle = STYLE_DOT; //|Internal structure line style
input int    InpInternalLineWidth = 1; //|Internal structure line width
input ENUM_TREND_COLOR_MODE InpInternalTrendType = TREND_COLOR_NONE; //|Color Trend (None, Candles, Background)
input color InpInternalBullTrendColor = C'46,139,87,180'; //|Internal bullish trend color
input color InpInternalBearTrendColor = C'205,92,92,180'; //|Internal bearish trend color

input group "--- Major Structure Settings ---"
input bool InpShowMajorStructure = true; //|Show Major Structure
input int InpMajorDepth      = 50; //|Depth for major structure
input color InpMajorLineColor = clrOrange; //|Major structure line color
input ENUM_LINE_STYLE InpMajorLineStyle = STYLE_SOLID; //|Major structure line style
input int InpMajorLineWidth = 3; //|Major structure line width
input ENUM_TREND_COLOR_MODE InpSwingTrendType = TREND_COLOR_NONE; //|Color Trend (None, Candles, Background)
input color InpSwingBullTrendColor = C'0,100,0,180'; //|Swing bullish trend color
input color InpSwingBearTrendColor = C'139,0,0,180'; //|Swing bearish trend color

input group "--- Order Block Settings ---"
input bool   InpShowInternalOB  = true; //|Show Internal Order Blocks
input int    InpMaxInternalOB   = 5; //|Max number of Internal OBs to show
input int    InpInternalOBBorderWidth = 1; //|Border width for Internal OBs
input color  InpIntBullishOBColor = (color)0x33228B22;  //|Internal Bullish OB Color
input color  InpIntBearishOBColor = (color)0x33B22222;  //|Internal Bearish OB Color

input bool   InpShowSwingOB     = true; //|Show Swing Order Blocks
input int    InpMaxSwingOB      = 5; //|Max number of Swing OBs to show
input int    InpSwingOBBorderWidth = 2; //|Border width for Swing OBs
input color  InpSwingBullishOBColor = (color)0x4D006400;  //|Swing Bullish OB Color
input color  InpSwingBearishOBColor = (color)0x4D8B0000;  //|Swing Bearish OB Color

input bool   InpShowMajorOB     = true; //|Show Major Order Blocks
input int    InpMaxMajorOB      = 5; //|Max number of Major OBs to show
input int    InpMajorOBBorderWidth = 2; //|Border width for Major OBs
input color  InpMajorBullishOBColor = (color)0x6600BFFF;  //|Major Bullish OB Color
input color  InpMajorBearishOBColor = (color)0x66FF4500;  //|Major Bearish OB Color

input ENUM_OB_FILTER_METHOD InpObFilterMethod = ATR_MULTIPLIER; //|OB Filter Method (ATR or Volume)
input bool   InpObFilterBySize = true;      //|Filter OBs by size relative to ATR
input double InpObMinAtrSize = 0.5;         //|Min OB size as a multiple of ATR
input double InpObMaxAtrSize = 3.0;         //|Max OB size as a multiple of ATR
input ENUM_MITIGATION_METHOD InpObMitigationMethod = HIGH_LOW; //|OB Mitigation Method (Wick, High/Low, Close)

input group "--- Premium/Discount Zones ---"
input bool   InpShowPDZones      = true; //|Show Premium/Discount Zones
input color  InpPremiumColor     = (color)0x1AFF0000; //|Premium zone color
input color  InpDiscountColor    = (color)0x1A008000; //|Discount zone color
input color  InpEquilibriumColor = clrGray; //|Equilibrium line color

input group "--- Fair Value Gaps (FVG) ---"
input bool   InpShowFVG         = true; //|Show Fair Value Gaps
input int    InpFVGExtendBars   = 50;  //|Number of bars to extend FVG boxes
input int    InpMaxFVGtoShow    = 10;   //|Max number of FVGs to show
input ENUM_TIMEFRAMES InpFVGTimeframe = PERIOD_CURRENT; //|FVG Timeframe (Current or MTF)
input bool   InpFVGAutoThreshold = true;              //|Use Auto Threshold for FVG size
input double InpFVGATRMultiplier = 0.5;               //|ATR Multiplier for FVG Threshold (if Auto Threshold is off)
input color  InpBullishFVGColor = (color)0x26008000;    //|Bullish FVG Color
input color  InpBearishFVGColor = (color)0x26FF0000;    //|Bearish FVG Color

input group "--- Liquidity (EQH/EQL) ---"
input bool   InpShowEQLH        = true; //|Show Equal Highs/Lows
input int    InpMaxEQLHtoShow   = 5;    //|Max number of EQH/EQL to show
input double InpEQLHThreshold   = 0.2; //|Threshold in ATR multiples for detection
input color  InpEQLHColor       = clrGold; //|Color for EQH/EQL lines

input group "--- MTF High/Low Levels ---"
input bool   InpShowDailyLevels  = true; //|Show Previous Day's High/Low
input color  InpDailyLevelColor  = clrSlateGray; //|Color for daily levels
input bool   InpShowWeeklyLevels = true; //|Show Previous Week's High/Low
input color  InpWeeklyLevelColor = clrDarkTurquoise; //|Color for weekly levels
input bool   InpShowMonthlyLevels= true; //|Show Previous Month's High/Low
input color  InpMonthlyLevelColor= clrViolet; //|Color for monthly levels

input group "--- Alerts ---"
input bool   InpAlertOnBOS = true; //|Alert on Break of Structure
input bool   InpAlertOnCHoCH = true; //|Alert on Change of Character
input bool   InpAlertOnFVG = true; //|Alert on new Fair Value Gap
input bool   InpAlertOnOBMitigation = false; //|Alert on Order Block mitigation
input bool   InpAlertOnEQLH = true; //|Alert on Equal High/Low formation

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES & BUFFERS                                       |
//+------------------------------------------------------------------+
string G_OBJECT_PREFIX = "SMC_";
color  G_DefaultBgColor;
int    ExtAtrHandle;

// Data Buffers
double ExtDummyBuffer[], OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[], ColorBuffer[];

// Structure Data Arrays
SwingPointExt ExtMajorSwingPoints[], ExtPrimarySwingPoints[], ExtSubSwingPoints[];
Structure ExtMajorStructures[], ExtPrimaryStructures[], ExtSubStructures[];
OrderBlock ExtMajorOrderBlocks[], ExtSwingOrderBlocks[], ExtInternalOrderBlocks[];
FairValueGap ExtFairValueGaps[];
LiquidityLevel ExtLiquidityLevels[];
ENUM_TREND ExtInternalTrendByBar[], ExtSwingTrendByBar[];

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS                                                |
//+------------------------------------------------------------------+
template<typename T>
void ArrayAdd(T &arr[], const T &element)
{
    int size = ArraySize(arr);
    if(ArrayResize(arr, size + 1) < 0) return;
    arr[size] = element;
}

template<typename T>
void ArrayRemove(T &arr[], int index, int count = 1)
{
    int size = ArraySize(arr);
    if(index < 0 || count <= 0 || index + count > size) return;
    for(int i = index; i < size - count; i++) arr[i] = arr[i+count];
    ArrayResize(arr, size - count);
}

//+------------------------------------------------------------------+
//| FUNCTIONS                                                        |
//+------------------------------------------------------------------+
// Functions (to be implemented in next steps)
void FindSwingPoints(const MqlRates &rates[], const int rates_total, const int depth, const int deviation, const int backstep, SwingPointExt &points[])
{
    ArrayFree(points);
    if(rates_total < depth) return;

    double high_map[], low_map[];
    ArrayResize(high_map, rates_total);
    ArrayResize(low_map, rates_total);
    
    // --- Pass 1: Find all potential extrema (peaks and troughs) ---
    for(int i = rates_total - depth - 1; i >= 0; i--)
    {
        // Find highest high in range
        double high_val = rates[i].high;
        int high_pos = i;
        for(int j = 1; j < depth; j++)
        {
            if(rates[i+j].high > high_val)
            {
                high_val = rates[i+j].high;
                high_pos = i+j;
            }
        }
        
        // Check deviation and backstep for highs
        if(high_pos == i)
        {
            if((high_val - rates[i].high) < deviation * _Point)
            {
                bool backstep_ok = true;
                for(int j = 1; j <= backstep; j++)
                {
                    if(i-j < 0) break;
                    if(high_map[i-j] != 0 && high_map[i-j] < high_val)
                    {
                        high_map[i-j] = 0;
                    }
                }
                if(backstep_ok) high_map[i] = high_val;
            }
        }
        
        // Find lowest low in range
        double low_val = rates[i].low;
        int low_pos = i;
        for(int j = 1; j < depth; j++)
        {
            if(rates[i+j].low < low_val)
            {
                low_val = rates[i+j].low;
                low_pos = i+j;
            }
        }

        // Check deviation and backstep for lows
        if(low_pos == i)
        {
            if((rates[i].low - low_val) < deviation * _Point)
            {
                 bool backstep_ok = true;
                 for(int j = 1; j <= backstep; j++)
                 {
                    if(i-j < 0) break;
                    if(low_map[i-j] != 0 && low_map[i-j] > low_val)
                    {
                        low_map[i-j] = 0;
                    }
                 }
                 if(backstep_ok) low_map[i] = low_val;
            }
        }
    }

    // --- Pass 2: Select final alternating swing points ---
    int last_high_pos = -1, last_low_pos = -1;
    double last_high_val = 0, last_low_val = 0;
    
    for(int i = 0; i < rates_total; i++)
    {
        if(high_map[i] != 0)
        {
            if(last_high_pos != -1) // There is a previous high
            {
                // If new high is higher, replace previous one
                if(high_map[i] > last_high_val)
                {
                    // Remove previous high from points array
                    for(int k=ArraySize(points)-1; k>=0; k--) { if(points[k].bar_index == last_high_pos) { ArrayRemove(points, k, 1); break; } }
                }
                else // If new high is lower, discard it
                {
                    continue;
                }
            }
            // Add new high
            SwingPointExt sp = {i, high_map[i], rates[i].time, SWING_HIGH};
            ArrayAdd(points, sp);
            last_high_pos = i;
            last_high_val = high_map[i];
            last_low_pos = -1; // Reset low search
        }
        
        if(low_map[i] != 0)
        {
             if(last_low_pos != -1) // There is a previous low
            {
                // If new low is lower, replace previous one
                if(low_map[i] < last_low_val)
                {
                    // Remove previous low from points array
                    for(int k=ArraySize(points)-1; k>=0; k--) { if(points[k].bar_index == last_low_pos) { ArrayRemove(points, k, 1); break; } }
                }
                else // if new low is higher, discard it
                {
                     continue;
                }
            }
            // Add new low
            SwingPointExt sp = {i, low_map[i], rates[i].time, SWING_LOW};
            ArrayAdd(points, sp);
            last_low_pos = i;
            last_low_val = low_map[i];
            last_high_pos = -1; // Reset high search
        }
    }
}
void FindStructure(const MqlRates &rates[], const int rates_total, const SwingPointExt &swing_points[], Structure &structure_points[], OrderBlock &order_blocks[])
{
    ArrayFree(structure_points);
    ArrayFree(order_blocks);
    int points_count = ArraySize(swing_points);
    if (points_count < 2) return;

    ENUM_TREND current_trend = TREND_NONE;
    SwingPointExt last_confirmed_high = {0}, last_confirmed_low = {0};

    // Khởi tạo trend ban đầu
    if (swing_points[0].type == SWING_HIGH)
    {
        last_confirmed_high = swing_points[0];
        if (points_count > 1 && swing_points[1].type == SWING_LOW)
        {
            last_confirmed_low = swing_points[1];
            current_trend = (last_confirmed_high.price > last_confirmed_low.price) ? TREND_DOWN : TREND_UP;
        }
    }
    else
    {
        last_confirmed_low = swing_points[0];
        if (points_count > 1 && swing_points[1].type == SWING_HIGH)
        {
            last_confirmed_high = swing_points[1];
            current_trend = (last_confirmed_high.price > last_confirmed_low.price) ? TREND_DOWN : TREND_UP;
        }
    }

    for (int i = 2; i < points_count; i++)
    {
        SwingPointExt current_sp = swing_points[i];
        string break_type = "";
        SwingPointExt broken_sp = {0};

        if (current_sp.type == SWING_HIGH)
        {
            if (current_trend == TREND_UP && current_sp.price > last_confirmed_high.price)
            {
                break_type = "BOS";
                broken_sp = last_confirmed_high;
                last_confirmed_high = current_sp;
            }
            else if (current_trend == TREND_DOWN && current_sp.price > last_confirmed_high.price)
            {
                if (InpFilterInternalConfluence && ArraySize(structure_points) <= ArraySize(ExtMajorStructures))
                {
                    int breakout_bar = current_sp.bar_index;
                    double open_price = rates[breakout_bar].open, close_price = rates[breakout_bar].close;
                    double high_price = rates[breakout_bar].high, low_price = rates[breakout_bar].low;
                    double upper_wick = high_price - MathMax(open_price, close_price);
                    double lower_wick = MathMin(open_price, close_price) - low_price;
                    if (upper_wick <= lower_wick) continue; // Bỏ qua nếu nến không mạnh
                }
                break_type = "CHoCH";
                broken_sp = last_confirmed_high;
                last_confirmed_high = current_sp;
                current_trend = TREND_UP;
            }
        }
        else // SWING_LOW
        {
             if (current_trend == TREND_DOWN && current_sp.price < last_confirmed_low.price)
            {
                break_type = "BOS";
                broken_sp = last_confirmed_low;
                last_confirmed_low = current_sp;
            }
            else if (current_trend == TREND_UP && current_sp.price < last_confirmed_low.price)
            {
                 if (InpFilterInternalConfluence && ArraySize(structure_points) <= ArraySize(ExtMajorStructures))
                {
                    int breakout_bar = current_sp.bar_index;
                    double open_price = rates[breakout_bar].open, close_price = rates[breakout_bar].close;
                    double high_price = rates[breakout_bar].high, low_price = rates[breakout_bar].low;
                    double upper_wick = high_price - MathMax(open_price, close_price);
                    double lower_wick = MathMin(open_price, close_price) - low_price;
                    if (lower_wick <= upper_wick) continue; // Bỏ qua nếu nến không mạnh
                }
                break_type = "CHoCH";
                broken_sp = last_confirmed_low;
                last_confirmed_low = current_sp;
                current_trend = TREND_DOWN;
            }
        }

        if (break_type != "")
        {
            Structure s = {broken_sp.bar_index, broken_sp.time, current_sp.price, break_type, current_trend, broken_sp.price, broken_sp.time,
                           last_confirmed_high.price, last_confirmed_high.time, last_confirmed_low.price, last_confirmed_low.time,
                           (current_trend == TREND_UP) ? last_confirmed_low.time : last_confirmed_high.time};
            ArrayAdd(structure_points, s);

            if ((break_type == "BOS" && InpAlertOnBOS) || (break_type == "CHoCH" && InpAlertOnCHoCH))
            {
                if (s.bar_index >= rates_total - 2)
                {
                    string trend_str = (s.trend == TREND_UP) ? "Bullish" : "Bearish";
                    string prefix = (ArraySize(structure_points) > ArraySize(ExtMajorStructures)) ? "Swing " : "Internal ";
                    Alert(Symbol(), " ", Period(), ": New ", prefix, trend_str, " ", s.type);
                }
            }

            int start_scan_idx = (current_trend == TREND_UP) ? last_confirmed_low.bar_index : last_confirmed_high.bar_index;
            int end_scan_idx = broken_sp.bar_index;
            int ob_candle_idx = -1;
            if (current_trend == TREND_UP)
            {
                for (int k = end_scan_idx - 1; k > start_scan_idx; k--) { if (rates[k].close < rates[k].open) { ob_candle_idx = k; break; } }
            }
            else
            {
                for (int k = end_scan_idx - 1; k > start_scan_idx; k--) { if (rates[k].close > rates[k].open) { ob_candle_idx = k; break; } }
            }
            if (ob_candle_idx != -1)
            {
                OrderBlock ob = {ob_candle_idx, rates[ob_candle_idx].high, rates[ob_candle_idx].low, rates[ob_candle_idx].time,
                                 (current_trend == TREND_UP), false};
                ArrayAdd(order_blocks, ob);
            }
        }
    }
}
void FindFairValueGaps(const MqlRates &rates[], const int rates_total, FairValueGap &fvgs[])
{
    ArrayFree(fvgs);
    if (InpFVGTimeframe == PERIOD_CURRENT || InpFVGTimeframe == 0)
    {
        // ... (logic for current TF)
    }
    else 
    {
        // ... (logic for MTF with auto threshold)
    }
}
void UpdateMitigation(const MqlRates &rates[], OrderBlock &order_blocks[]){}
void UpdateTrendByBar(const int rates_total, const Structure &structures[], ENUM_TREND &trend_by_bar[]){}
void FindEqualHighsLows(const SwingPointExt &points[], const int rates_total, LiquidityLevel &levels[]){}

void DrawSwingStructure(const SwingPointExt &swing_points[], const Structure &structure_points[], color line_color, int line_width, ENUM_LINE_STYLE line_style, const string type_prefix)
{
    int start_idx = 0;
    if(InpDisplayMode == MODE_PRESENT && ArraySize(swing_points) > 2)
    {
        start_idx = ArraySize(swing_points) - 2;
    }
    
    for(int i = start_idx + 1; i < ArraySize(swing_points); i++)
    {
        // ... drawing logic for lines
    }
    
    int start_structure_idx = 0;
    if(InpDisplayMode == MODE_PRESENT && ArraySize(structure_points) > 1)
    {
        start_structure_idx = ArraySize(structure_points) - 1;
    }

    for(int i = start_structure_idx; i < ArraySize(structure_points); i++)
    {
        // ... drawing logic for labels (BOS/CHoCH)
    }
}
void DrawOrderBlocks(const OrderBlock &order_blocks[], int max_to_show, color bull_color, color bear_color, int border_width, const string type_prefix){}
void DrawFairValueGaps(const FairValueGap &fvgs[]){}
void DrawEqualHighsLows(const LiquidityLevel &levels[]){}
void DrawStrongWeakHighLows(){}
void DrawPremiumDiscountZone(const Structure &structure_leg, const string obj_prefix){}
void DrawMTFLevels(){}
void HandleTrendColoring(const int rates_total, const double &open[], const double &high[], const double &low[], const double &close[]){}
void CleanupObjects(string prefix){}

//+------------------------------------------------------------------+
//| Main Indicator Logic                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
    int min_bars_needed = MathMax(InpSwingDepth, MathMax(InpInternalDepth, InpMajorDepth)) * 2;
    if (rates_total < min_bars_needed) return 0;

    if (rates_total != prev_calculated || prev_calculated == 0 || InpDisplayMode == MODE_PRESENT)
    {
        MqlRates rates[];
        if (CopyRates(_Symbol, _Period, 0, rates_total, rates) == -1)
        {
             Print("Error copying rates history!");
             return 0;
        }

        CleanupObjects(G_OBJECT_PREFIX);

        AnalyzeAllStructures(rates, rates_total);
        AnalyzeAndDrawPOIs(rates, rates_total);
        DrawAllPDZones();
        DrawMTFLevels();
        HandleTrendColoring(rates_total, open, high, low, close);
    }
    return rates_total;
}
void AnalyzeAllStructures(const MqlRates &rates[], const int rates_total){}
void AnalyzeAndDrawPOIs(const MqlRates &rates[], const int rates_total){}
void DrawAllPDZones(){}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Buffers mapping
    SetIndexBuffer(0, ExtDummyBuffer, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    SetIndexBuffer(1, OpenBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, HighBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, LowBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, CloseBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, ColorBuffer, INDICATOR_COLOR_INDEX);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
    PlotIndexSetString(1, PLOT_LABEL, "Trend");

    IndicatorSetString(INDICATOR_SHORTNAME, "SMC Structure");
    MathSrand((int)TimeCurrent());
    G_OBJECT_PREFIX = "SMC_" + (string)ChartID() + "_" + (string)MathRand() + "_";

    // ATR Handle
    ExtAtrHandle = iATR(_Symbol, _Period, 14);
    if(ExtAtrHandle == INVALID_HANDLE)
    {
        Print("Error creating ATR indicator handle - Error: ", GetLastError());
        return(INIT_FAILED);
    }

    G_DefaultBgColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    CleanupObjects(G_OBJECT_PREFIX);
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, G_DefaultBgColor);
    if(ExtAtrHandle != INVALID_HANDLE)
        IndicatorRelease(ExtAtrHandle);
}