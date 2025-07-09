//+------------------------------------------------------------------+
//|                                         Indicator_SMC_Complete.mq5 |
//|                                                    Sonic R MC System |
//|                                Complete SMC + ICT + S/R Indicator |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property description "Complete SMC Indicator with ICT concepts and S/R analysis"
#property description "Features: Order Blocks, Fair Value Gaps, Market Structure, Support/Resistance"

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   5

// Plot definitions
#property indicator_label1  "Order Block Bull"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Order Block Bear"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Fair Value Gap Bull"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Fair Value Gap Bear"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

#property indicator_label5  "Structure Break"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_SOLID
#property indicator_width5  3

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

input group "=== Order Block Settings ==="
input int InpOB_LookbackPeriod = 100;                       // OB: Lookback Period
input double InpOB_MinImpulsePips = 10.0;                   // OB: Min Impulse (Pips)
input int InpOB_MaxImpulseCandles = 5;                      // OB: Max Impulse Candles
input double InpOB_VolumeThreshold = 1.2;                   // OB: Volume Threshold
input int InpOB_MinStrength = 30;                           // OB: Min Strength

input group "=== Fair Value Gap Settings ==="
input double InpFVG_MinGapPips = 2.0;                       // FVG: Min Gap Size (Pips)
input double InpFVG_MaxAgeHours = 24.0;                     // FVG: Max Age (Hours)
input bool InpFVG_RequireVolume = false;                    // FVG: Require Volume
input double InpFVG_VolumeMultiplier = 1.3;                 // FVG: Volume Multiplier

input group "=== Market Structure Settings ==="
input int InpMS_SwingStrength = 3;                          // MS: Swing Strength
input double InpMS_MinBreakPips = 3.0;                      // MS: Min Break Distance (Pips)
input bool InpMS_RequireVolumeConfirm = true;               // MS: Require Volume Confirmation
input double InpMS_VolumeThreshold = 1.1;                   // MS: Volume Threshold

input group "=== Support/Resistance Settings ==="
input int InpSR_LookbackPeriod = 200;                       // SR: Lookback Period
input int InpSR_MinTouches = 2;                             // SR: Min Touches
input double InpSR_TouchTolerance = 2.0;                    // SR: Touch Tolerance (Pips)
input bool InpSR_ShowPsychological = true;                  // SR: Show Psychological Levels

input group "=== Display Settings ==="
input bool InpShowOrderBlocks = true;                       // Show Order Blocks
input bool InpShowFairValueGaps = true;                     // Show Fair Value Gaps
input bool InpShowStructureBreaks = true;                   // Show Structure Breaks
input bool InpShowSupportResistance = true;                 // Show Support/Resistance
input bool InpShowLabels = true;                            // Show Labels
input bool InpShowAlerts = true;                            // Show Alerts

input group "=== Alert Settings ==="
input bool InpAlertOrderBlocks = true;                      // Alert on Order Blocks
input bool InpAlertFairValueGaps = true;                    // Alert on Fair Value Gaps
input bool InpAlertStructureBreaks = true;                  // Alert on Structure Breaks
input bool InpSendNotifications = false;                    // Send Notifications

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

// Indicator buffers
double BufferOrderBlockBull[];
double BufferOrderBlockBear[];
double BufferFairValueGapBull[];
double BufferFairValueGapBear[];
double BufferStructureBreak[];

// Hidden buffers for calculations
double BufferHighs[];
double BufferLows[];
double BufferVolumes[];
double BufferSwings[];
double BufferSRLevels[];

// Data arrays
struct SOrderBlock
{
    datetime time;
    double high;
    double low;
    double open;
    double close;
    bool is_bullish;
    int strength;
    bool is_valid;
    bool is_touched;
    datetime touch_time;
};

struct SFairValueGap
{
    datetime time;
    double gap_high;
    double gap_low;
    bool is_bullish;
    bool is_valid;
    bool is_filled;
    datetime fill_time;
};

struct SSwingPoint
{
    datetime time;
    double price;
    bool is_high;
    int strength;
    bool is_broken;
    datetime break_time;
};

struct SSupportResistance
{
    double level;
    int touches;
    datetime first_touch;
    datetime last_touch;
    bool is_support;
    double strength;
    bool is_valid;
};

// Global arrays
SOrderBlock g_order_blocks[];
SFairValueGap g_fair_value_gaps[];
SSwingPoint g_swing_points[];
SSupportResistance g_sr_levels[];

// Status variables
datetime g_last_update = 0;
bool g_initialized = false;
int g_total_bars = 0;
int g_max_objects = 500;  // Maximum objects on chart
int g_cleanup_counter = 0; // Counter for periodic cleanup

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("SMC Complete Indicator: Initializing...");
    
    // Set up indicator buffers
    SetIndexBuffer(0, BufferOrderBlockBull, INDICATOR_DATA);
    SetIndexBuffer(1, BufferOrderBlockBear, INDICATOR_DATA);
    SetIndexBuffer(2, BufferFairValueGapBull, INDICATOR_DATA);
    SetIndexBuffer(3, BufferFairValueGapBear, INDICATOR_DATA);
    SetIndexBuffer(4, BufferStructureBreak, INDICATOR_DATA);
    
    // Hidden buffers
    SetIndexBuffer(5, BufferHighs, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, BufferLows, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, BufferVolumes, INDICATOR_CALCULATIONS);
    SetIndexBuffer(8, BufferSwings, INDICATOR_CALCULATIONS);
    SetIndexBuffer(9, BufferSRLevels, INDICATOR_CALCULATIONS);
    
    // Set arrow codes
    PlotIndexSetInteger(0, PLOT_ARROW, 233); // Up arrow for bullish OB
    PlotIndexSetInteger(1, PLOT_ARROW, 234); // Down arrow for bearish OB
    PlotIndexSetInteger(2, PLOT_ARROW, 159); // Up triangle for bullish FVG
    PlotIndexSetInteger(3, PLOT_ARROW, 160); // Down triangle for bearish FVG
    PlotIndexSetInteger(4, PLOT_ARROW, 168); // Diamond for structure break
    
    // Set empty values
    for(int i = 0; i < 5; i++)
    {
        PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    }
    
    // Initialize arrays as series
    ArraySetAsSeries(BufferOrderBlockBull, true);
    ArraySetAsSeries(BufferOrderBlockBear, true);
    ArraySetAsSeries(BufferFairValueGapBull, true);
    ArraySetAsSeries(BufferFairValueGapBear, true);
    ArraySetAsSeries(BufferStructureBreak, true);
    
    // Initialize data arrays
    ArrayResize(g_order_blocks, 0);
    ArrayResize(g_fair_value_gaps, 0);
    ArrayResize(g_swing_points, 0);
    ArrayResize(g_sr_levels, 0);
    
    g_initialized = true;
    Print("SMC Complete Indicator: Initialized successfully");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up all SMC objects
    ObjectsDeleteAll(0, "SMC_");
    
    // Clear all arrays
    ArrayResize(g_order_blocks, 0);
    ArrayResize(g_fair_value_gaps, 0);
    ArrayResize(g_swing_points, 0);
    ArrayResize(g_sr_levels, 0);
    
    Print("SMC Complete Indicator: Deinitialized");
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
    if(!g_initialized || rates_total < 10)
        return prev_calculated;
    
    // Check if new bar formed
    if(rates_total == g_total_bars)
        return rates_total;
    
    g_total_bars = rates_total;
    
    // Clear all buffers
    ClearBuffers();
    
    // Periodic cleanup of old objects (every 100 bars)
    g_cleanup_counter++;
    if(g_cleanup_counter >= 100)
    {
        CleanupOldObjects();
        g_cleanup_counter = 0;
    }
    
    // Analyze market structure
    AnalyzeMarketStructure(rates_total, time, open, high, low, close, tick_volume);
    
    // Identify order blocks
    if(InpShowOrderBlocks)
        IdentifyOrderBlocks(rates_total, time, open, high, low, close, tick_volume);
    
    // Identify fair value gaps
    if(InpShowFairValueGaps)
        IdentifyFairValueGaps(rates_total, time, open, high, low, close, tick_volume);
    
    // Identify support/resistance levels
    if(InpShowSupportResistance)
        IdentifySupportResistance(rates_total, time, high, low, close);
    
    // Check for FVG fills
    CheckFVGFills(rates_total, high, low, close);
    
    // Display signals on chart
    DisplaySignals(rates_total, time, high, low, close);
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Clear All Buffers                                                |
//+------------------------------------------------------------------+
void ClearBuffers()
{
    ArrayInitialize(BufferOrderBlockBull, EMPTY_VALUE);
    ArrayInitialize(BufferOrderBlockBear, EMPTY_VALUE);
    ArrayInitialize(BufferFairValueGapBull, EMPTY_VALUE);
    ArrayInitialize(BufferFairValueGapBear, EMPTY_VALUE);
    ArrayInitialize(BufferStructureBreak, EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//| Cleanup Old Objects                                              |
//+------------------------------------------------------------------+
void CleanupOldObjects()
{
    datetime current_time = TimeCurrent();
    datetime cleanup_time = current_time - InpFVG_MaxAgeHours * 3600; // Age limit
    
    // Clean up old order blocks
    for(int i = ArraySize(g_order_blocks) - 1; i >= 0; i--)
    {
        if(g_order_blocks[i].time < cleanup_time || !g_order_blocks[i].is_valid)
        {
            // Delete associated objects
            string ob_name = g_order_blocks[i].is_bullish ? 
                "SMC_OB_Bull_" + TimeToString(g_order_blocks[i].time) :
                "SMC_OB_Bear_" + TimeToString(g_order_blocks[i].time);
            ObjectDelete(0, ob_name);
            
            // Remove from array
            for(int j = i; j < ArraySize(g_order_blocks) - 1; j++)
            {
                g_order_blocks[j] = g_order_blocks[j + 1];
            }
            ArrayResize(g_order_blocks, ArraySize(g_order_blocks) - 1);
        }
    }
    
    // Clean up old fair value gaps
    for(int i = ArraySize(g_fair_value_gaps) - 1; i >= 0; i--)
    {
        if(g_fair_value_gaps[i].time < cleanup_time || !g_fair_value_gaps[i].is_valid || g_fair_value_gaps[i].is_filled)
        {
            // Delete associated objects
            string fvg_name = g_fair_value_gaps[i].is_bullish ? 
                "SMC_FVG_Bull_" + TimeToString(g_fair_value_gaps[i].time) :
                "SMC_FVG_Bear_" + TimeToString(g_fair_value_gaps[i].time);
            ObjectDelete(0, fvg_name);
            
            // Remove from array
            for(int j = i; j < ArraySize(g_fair_value_gaps) - 1; j++)
            {
                g_fair_value_gaps[j] = g_fair_value_gaps[j + 1];
            }
            ArrayResize(g_fair_value_gaps, ArraySize(g_fair_value_gaps) - 1);
        }
    }
    
    // Clean up old structure break labels
    for(int i = ArraySize(g_swing_points) - 1; i >= 0; i--)
    {
        if(g_swing_points[i].time < cleanup_time)
        {
            // Delete associated objects
            string bos_name = "SMC_BOS_" + TimeToString(g_swing_points[i].break_time);
            ObjectDelete(0, bos_name);
            
            // Remove from array
            for(int j = i; j < ArraySize(g_swing_points) - 1; j++)
            {
                g_swing_points[j] = g_swing_points[j + 1];
            }
            ArrayResize(g_swing_points, ArraySize(g_swing_points) - 1);
        }
    }
    
    // Limit array sizes to prevent memory issues
    if(ArraySize(g_order_blocks) > 50)
        ArrayResize(g_order_blocks, 50);
    if(ArraySize(g_fair_value_gaps) > 30)
        ArrayResize(g_fair_value_gaps, 30);
    if(ArraySize(g_swing_points) > 100)
        ArrayResize(g_swing_points, 100);
    if(ArraySize(g_sr_levels) > 20)
        ArrayResize(g_sr_levels, 20);
}

//+------------------------------------------------------------------+
//| Check Fair Value Gap Fills                                       |
//+------------------------------------------------------------------+
void CheckFVGFills(int rates_total, const double &high[], const double &low[], const double &close[])
{
    for(int i = 0; i < ArraySize(g_fair_value_gaps); i++)
    {
        if(!g_fair_value_gaps[i].is_valid || g_fair_value_gaps[i].is_filled)
            continue;
        
        // Check current bar for FVG fill
        int current_bar = rates_total - 1;
        
        if(g_fair_value_gaps[i].is_bullish)
        {
            // Bullish FVG filled when price goes below gap low
            if(low[current_bar] <= g_fair_value_gaps[i].gap_low)
            {
                g_fair_value_gaps[i].is_filled = true;
                g_fair_value_gaps[i].fill_time = TimeCurrent();
                g_fair_value_gaps[i].is_valid = false; // Mark for cleanup
            }
        }
        else
        {
            // Bearish FVG filled when price goes above gap high
            if(high[current_bar] >= g_fair_value_gaps[i].gap_high)
            {
                g_fair_value_gaps[i].is_filled = true;
                g_fair_value_gaps[i].fill_time = TimeCurrent();
                g_fair_value_gaps[i].is_valid = false; // Mark for cleanup
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Analyze Market Structure                                         |
//+------------------------------------------------------------------+
void AnalyzeMarketStructure(int rates_total, const datetime &time[], const double &open[], 
                           const double &high[], const double &low[], const double &close[], 
                           const long &tick_volume[])
{
    // Clear previous swing points
    ArrayResize(g_swing_points, 0);
    
    // Identify swing highs and lows
    for(int i = InpMS_SwingStrength; i < rates_total - InpMS_SwingStrength - 1; i++)
    {
        bool is_swing_high = true;
        bool is_swing_low = true;
        
        // Check for swing high
        for(int j = i - InpMS_SwingStrength; j <= i + InpMS_SwingStrength; j++)
        {
            if(j != i && high[j] >= high[i])
            {
                is_swing_high = false;
                break;
            }
        }
        
        // Check for swing low
        for(int j = i - InpMS_SwingStrength; j <= i + InpMS_SwingStrength; j++)
        {
            if(j != i && low[j] <= low[i])
            {
                is_swing_low = false;
                break;
            }
        }
        
        // Add swing point if found
        if(is_swing_high || is_swing_low)
        {
            SSwingPoint swing;
            swing.time = time[i];
            swing.price = is_swing_high ? high[i] : low[i];
            swing.is_high = is_swing_high;
            swing.strength = InpMS_SwingStrength;
            swing.is_broken = false;
            swing.break_time = 0;
            
            ArrayResize(g_swing_points, ArraySize(g_swing_points) + 1);
            g_swing_points[ArraySize(g_swing_points) - 1] = swing;
        }
    }
    
    // Check for structure breaks
    CheckStructureBreaks(rates_total, time, high, low, close, tick_volume);
}

//+------------------------------------------------------------------+
//| Check Structure Breaks                                           |
//+------------------------------------------------------------------+
void CheckStructureBreaks(int rates_total, const datetime &time[], const double &high[], 
                         const double &low[], const double &close[], const long &tick_volume[])
{
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double min_break_distance = InpMS_MinBreakPips * point_value;
    
    for(int i = 0; i < ArraySize(g_swing_points); i++)
    {
        if(g_swing_points[i].is_broken)
            continue;
        
        // Find the bar index for this swing point
        int swing_bar = -1;
        for(int j = 0; j < rates_total; j++)
        {
            if(time[j] == g_swing_points[i].time)
            {
                swing_bar = j;
                break;
            }
        }
        
        if(swing_bar == -1)
            continue;
        
        // Check for break from swing_bar to current
        for(int j = swing_bar + 1; j < rates_total; j++)
        {
            bool volume_confirm = true;
            if(InpMS_RequireVolumeConfirm)
            {
                // Check if volume is above threshold
                long avg_volume = 0;
                int volume_period = MathMin(20, j);
                for(int k = j - volume_period; k < j; k++)
                {
                    if(k >= 0)
                        avg_volume += tick_volume[k];
                }
                avg_volume /= volume_period;
                volume_confirm = (tick_volume[j] > avg_volume * InpMS_VolumeThreshold);
            }
            
            // Check for structure break
            if(g_swing_points[i].is_high)
            {
                // Check for break of swing high
                if(close[j] > g_swing_points[i].price + min_break_distance && volume_confirm)
                {
                    g_swing_points[i].is_broken = true;
                    g_swing_points[i].break_time = time[j];
                    
                    // Mark structure break on chart
                    if(InpShowStructureBreaks)
                    {
                        int buffer_index = rates_total - 1 - j;
                        BufferStructureBreak[buffer_index] = high[j] + 20 * point_value;
                        
                        if(InpShowLabels)
                        {
                            string label_name = "SMC_BOS_" + TimeToString(time[j]);
                            CreateLabel(label_name, time[j], BufferStructureBreak[buffer_index], "BOS↑", clrYellow);
                        }
                        
                        if(InpAlertStructureBreaks && InpShowAlerts)
                        {
                            Alert("SMC: Bullish Structure Break at ", close[j]);
                        }
                    }
                    break;
                }
            }
            else
            {
                // Check for break of swing low
                if(close[j] < g_swing_points[i].price - min_break_distance && volume_confirm)
                {
                    g_swing_points[i].is_broken = true;
                    g_swing_points[i].break_time = time[j];
                    
                    // Mark structure break on chart
                    if(InpShowStructureBreaks)
                    {
                        int buffer_index = rates_total - 1 - j;
                        BufferStructureBreak[buffer_index] = low[j] - 20 * point_value;
                        
                        if(InpShowLabels)
                        {
                            string label_name = "SMC_BOS_" + TimeToString(time[j]);
                            CreateLabel(label_name, time[j], BufferStructureBreak[buffer_index], "BOS↓", clrYellow);
                        }
                        
                        if(InpAlertStructureBreaks && InpShowAlerts)
                        {
                            Alert("SMC: Bearish Structure Break at ", close[j]);
                        }
                    }
                    break;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Identify Order Blocks                                            |
//+------------------------------------------------------------------+
void IdentifyOrderBlocks(int rates_total, const datetime &time[], const double &open[], 
                        const double &high[], const double &low[], const double &close[], 
                        const long &tick_volume[])
{
    // Clear previous order blocks
    ArrayResize(g_order_blocks, 0);
    
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double min_impulse = InpOB_MinImpulsePips * point_value;
    
    // Look for impulse moves followed by order blocks
    for(int i = InpOB_MaxImpulseCandles; i < rates_total - 1; i++)
    {
        // Check for bullish impulse
        double impulse_start = low[i - InpOB_MaxImpulseCandles];
        double impulse_end = high[i];
        double impulse_size = impulse_end - impulse_start;
        
        if(impulse_size >= min_impulse)
        {
            // Find the last bearish candle before the impulse
            for(int j = i - InpOB_MaxImpulseCandles; j < i; j++)
            {
                if(close[j] < open[j]) // Bearish candle
                {
                    // Check volume confirmation
                    bool volume_confirm = true;
                    if(InpOB_VolumeThreshold > 1.0)
                    {
                        long avg_volume = 0;
                        int volume_period = MathMin(20, j);
                        for(int k = j - volume_period; k < j; k++)
                        {
                            if(k >= 0)
                                avg_volume += tick_volume[k];
                        }
                        avg_volume /= volume_period;
                        volume_confirm = (tick_volume[j] > avg_volume * InpOB_VolumeThreshold);
                    }
                    
                    if(volume_confirm)
                    {
                        // Create bullish order block
                        SOrderBlock ob;
                        ob.time = time[j];
                        ob.high = high[j];
                        ob.low = low[j];
                        ob.open = open[j];
                        ob.close = close[j];
                        ob.is_bullish = true;
                        ob.strength = (int)(impulse_size / point_value);
                        ob.is_valid = true;
                        ob.is_touched = false;
                        ob.touch_time = 0;
                        
                        if(ob.strength >= InpOB_MinStrength)
                        {
                            ArrayResize(g_order_blocks, ArraySize(g_order_blocks) + 1);
                            g_order_blocks[ArraySize(g_order_blocks) - 1] = ob;
                        }
                    }
                    break;
                }
            }
        }
        
        // Check for bearish impulse
        impulse_start = high[i - InpOB_MaxImpulseCandles];
        impulse_end = low[i];
        impulse_size = impulse_start - impulse_end;
        
        if(impulse_size >= min_impulse)
        {
            // Find the last bullish candle before the impulse
            for(int j = i - InpOB_MaxImpulseCandles; j < i; j++)
            {
                if(close[j] > open[j]) // Bullish candle
                {
                    // Check volume confirmation
                    bool volume_confirm = true;
                    if(InpOB_VolumeThreshold > 1.0)
                    {
                        long avg_volume = 0;
                        int volume_period = MathMin(20, j);
                        for(int k = j - volume_period; k < j; k++)
                        {
                            if(k >= 0)
                                avg_volume += tick_volume[k];
                        }
                        avg_volume /= volume_period;
                        volume_confirm = (tick_volume[j] > avg_volume * InpOB_VolumeThreshold);
                    }
                    
                    if(volume_confirm)
                    {
                        // Create bearish order block
                        SOrderBlock ob;
                        ob.time = time[j];
                        ob.high = high[j];
                        ob.low = low[j];
                        ob.open = open[j];
                        ob.close = close[j];
                        ob.is_bullish = false;
                        ob.strength = (int)(impulse_size / point_value);
                        ob.is_valid = true;
                        ob.is_touched = false;
                        ob.touch_time = 0;
                        
                        if(ob.strength >= InpOB_MinStrength)
                        {
                            ArrayResize(g_order_blocks, ArraySize(g_order_blocks) + 1);
                            g_order_blocks[ArraySize(g_order_blocks) - 1] = ob;
                        }
                    }
                    break;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Identify Fair Value Gaps                                         |
//+------------------------------------------------------------------+
void IdentifyFairValueGaps(int rates_total, const datetime &time[], const double &open[], 
                          const double &high[], const double &low[], const double &close[], 
                          const long &tick_volume[])
{
    // Clear previous fair value gaps
    ArrayResize(g_fair_value_gaps, 0);
    
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double min_gap = InpFVG_MinGapPips * point_value;
    
    // Look for fair value gaps (3-candle pattern)
    for(int i = 2; i < rates_total - 1; i++)
    {
        // Check for bullish FVG (corrected logic)
        double gap_low = high[i - 2];   // Previous candle high
        double gap_high = low[i];       // Current candle low
        
        if(gap_high > gap_low + min_gap)
        {
            // Validate the gap
            bool valid_gap = true;
            
            // Check if middle candle is bullish impulse
            double middle_body = MathAbs(close[i - 1] - open[i - 1]);
            double middle_range = high[i - 1] - low[i - 1];
            if(close[i - 1] <= open[i - 1] || middle_body < 0.5 * middle_range)
                valid_gap = false;
            
            // Check volume if required
            if(InpFVG_RequireVolume && valid_gap)
            {
                long avg_volume = 0;
                for(int k = i - 10; k < i; k++)
                {
                    if(k >= 0) avg_volume += tick_volume[k];
                }
                avg_volume /= 10;
                valid_gap = (tick_volume[i - 1] > avg_volume * InpFVG_VolumeMultiplier);
            }
            
            if(valid_gap)
            {
                SFairValueGap fvg;
                fvg.time = time[i - 1];
                fvg.gap_high = gap_high;
                fvg.gap_low = gap_low;
                fvg.is_bullish = true;
                fvg.is_valid = true;
                fvg.is_filled = false;
                fvg.fill_time = 0;
                
                ArrayResize(g_fair_value_gaps, ArraySize(g_fair_value_gaps) + 1);
                g_fair_value_gaps[ArraySize(g_fair_value_gaps) - 1] = fvg;
            }
        }
        
        // Check for bearish FVG (corrected logic)
        gap_high = low[i - 2];   // Previous candle low
        gap_low = high[i];       // Current candle high
        
        if(gap_high > gap_low + min_gap)
        {
            // Validate the gap
            bool valid_gap = true;
            
            // Check if middle candle is bearish impulse
            double middle_body = MathAbs(close[i - 1] - open[i - 1]);
            double middle_range = high[i - 1] - low[i - 1];
            if(close[i - 1] >= open[i - 1] || middle_body < 0.5 * middle_range)
                valid_gap = false;
            
            // Check volume if required
            if(InpFVG_RequireVolume && valid_gap)
            {
                long avg_volume = 0;
                for(int k = i - 10; k < i; k++)
                {
                    if(k >= 0) avg_volume += tick_volume[k];
                }
                avg_volume /= 10;
                valid_gap = (tick_volume[i - 1] > avg_volume * InpFVG_VolumeMultiplier);
            }
            
            if(valid_gap)
            {
                SFairValueGap fvg;
                fvg.time = time[i - 1];
                fvg.gap_high = gap_high;
                fvg.gap_low = gap_low;
                fvg.is_bullish = false;
                fvg.is_valid = true;
                fvg.is_filled = false;
                fvg.fill_time = 0;
                
                ArrayResize(g_fair_value_gaps, ArraySize(g_fair_value_gaps) + 1);
                g_fair_value_gaps[ArraySize(g_fair_value_gaps) - 1] = fvg;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Identify Support/Resistance Levels                              |
//+------------------------------------------------------------------+
void IdentifySupportResistance(int rates_total, const datetime &time[], const double &high[], 
                              const double &low[], const double &close[])
{
    // Clear previous S/R levels
    ArrayResize(g_sr_levels, 0);
    
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double touch_tolerance = InpSR_TouchTolerance * point_value;
    
    // Use swing points to identify S/R levels
    for(int i = 0; i < ArraySize(g_swing_points); i++)
    {
        double level = g_swing_points[i].price;
        int touches = 1;
        datetime first_touch = g_swing_points[i].time;
        datetime last_touch = g_swing_points[i].time;
        
        // Count touches at this level
        for(int j = 0; j < ArraySize(g_swing_points); j++)
        {
            if(i != j && MathAbs(g_swing_points[j].price - level) <= touch_tolerance)
            {
                touches++;
                if(g_swing_points[j].time > last_touch)
                    last_touch = g_swing_points[j].time;
            }
        }
        
        // Create S/R level if it has enough touches
        if(touches >= InpSR_MinTouches)
        {
            // Check if this level already exists
            bool exists = false;
            for(int k = 0; k < ArraySize(g_sr_levels); k++)
            {
                if(MathAbs(g_sr_levels[k].level - level) <= touch_tolerance)
                {
                    exists = true;
                    break;
                }
            }
            
            if(!exists)
            {
                SSupportResistance sr;
                sr.level = level;
                sr.touches = touches;
                sr.first_touch = first_touch;
                sr.last_touch = last_touch;
                sr.is_support = !g_swing_points[i].is_high;
                sr.strength = touches * 10.0;
                sr.is_valid = true;
                
                ArrayResize(g_sr_levels, ArraySize(g_sr_levels) + 1);
                g_sr_levels[ArraySize(g_sr_levels) - 1] = sr;
            }
        }
    }
    
    // Add psychological levels if enabled
    if(InpSR_ShowPsychological)
    {
        AddPsychologicalLevels(close[rates_total - 1]);
    }
}

//+------------------------------------------------------------------+
//| Add Psychological Levels                                         |
//+------------------------------------------------------------------+
void AddPsychologicalLevels(double current_price)
{
    // Add round number levels
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
    
    // Calculate psychological levels based on price
    double base_level = 0;
    double increment = 0;
    
    if(current_price >= 1.0)
    {
        base_level = MathFloor(current_price * 100) / 100.0;
        increment = 0.01;
    }
    else if(current_price >= 0.1)
    {
        base_level = MathFloor(current_price * 1000) / 1000.0;
        increment = 0.001;
    }
    else
    {
        base_level = MathFloor(current_price * 10000) / 10000.0;
        increment = 0.0001;
    }
    
    // Add levels above and below current price
    for(int i = -5; i <= 5; i++)
    {
        double level = base_level + (i * increment);
        
        if(level > 0)
        {
            SSupportResistance sr;
            sr.level = level;
            sr.touches = 1;
            sr.first_touch = TimeCurrent();
            sr.last_touch = TimeCurrent();
            sr.is_support = (level < current_price);
            sr.strength = 5.0;
            sr.is_valid = true;
            
            ArrayResize(g_sr_levels, ArraySize(g_sr_levels) + 1);
            g_sr_levels[ArraySize(g_sr_levels) - 1] = sr;
        }
    }
}

//+------------------------------------------------------------------+
//| Display Signals on Chart                                         |
//+------------------------------------------------------------------+
void DisplaySignals(int rates_total, const datetime &time[], const double &high[], 
                   const double &low[], const double &close[])
{
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    // Display Order Blocks
    for(int i = 0; i < ArraySize(g_order_blocks); i++)
    {
        if(!g_order_blocks[i].is_valid)
            continue;
        
        // Find the bar index for this order block
        int ob_bar = -1;
        for(int j = 0; j < rates_total; j++)
        {
            if(time[j] == g_order_blocks[i].time)
            {
                ob_bar = j;
                break;
            }
        }
        
        if(ob_bar == -1)
            continue;
        
        int buffer_index = rates_total - 1 - ob_bar;
        
        if(buffer_index >= 0 && buffer_index < rates_total && g_order_blocks[i].is_bullish)
        {
            BufferOrderBlockBull[buffer_index] = g_order_blocks[i].low - 10 * point_value;
            
            if(InpShowLabels)
            {
                string label_name = "SMC_OB_Bull_" + TimeToString(g_order_blocks[i].time);
                CreateLabel(label_name, g_order_blocks[i].time, BufferOrderBlockBull[buffer_index], 
                           "OB+" + IntegerToString(g_order_blocks[i].strength), clrLimeGreen);
            }
            
            if(InpAlertOrderBlocks && InpShowAlerts)
            {
                Alert("SMC: Bullish Order Block identified at ", g_order_blocks[i].low);
            }
        }
        else if(buffer_index >= 0 && buffer_index < rates_total)
        {
            BufferOrderBlockBear[buffer_index] = g_order_blocks[i].high + 10 * point_value;
            
            if(InpShowLabels)
            {
                string label_name = "SMC_OB_Bear_" + TimeToString(g_order_blocks[i].time);
                CreateLabel(label_name, g_order_blocks[i].time, BufferOrderBlockBear[buffer_index], 
                           "OB-" + IntegerToString(g_order_blocks[i].strength), clrCrimson);
            }
            
            if(InpAlertOrderBlocks && InpShowAlerts)
            {
                Alert("SMC: Bearish Order Block identified at ", g_order_blocks[i].high);
            }
        }
    }
    
    // Display Fair Value Gaps
    for(int i = 0; i < ArraySize(g_fair_value_gaps); i++)
    {
        if(!g_fair_value_gaps[i].is_valid || g_fair_value_gaps[i].is_filled)
            continue;
        
        // Find the bar index for this FVG
        int fvg_bar = -1;
        for(int j = 0; j < rates_total; j++)
        {
            if(time[j] == g_fair_value_gaps[i].time)
            {
                fvg_bar = j;
                break;
            }
        }
        
        if(fvg_bar == -1)
            continue;
        
        int buffer_index = rates_total - 1 - fvg_bar;
        
        if(buffer_index >= 0 && buffer_index < rates_total && g_fair_value_gaps[i].is_bullish)
        {
            BufferFairValueGapBull[buffer_index] = g_fair_value_gaps[i].gap_low - 5 * point_value;
            
            if(InpShowLabels)
            {
                string label_name = "SMC_FVG_Bull_" + TimeToString(g_fair_value_gaps[i].time);
                CreateLabel(label_name, g_fair_value_gaps[i].time, BufferFairValueGapBull[buffer_index], 
                           "FVG+", clrDodgerBlue);
            }
            
            if(InpAlertFairValueGaps && InpShowAlerts)
            {
                Alert("SMC: Bullish Fair Value Gap at ", g_fair_value_gaps[i].gap_low);
            }
        }
        else if(buffer_index >= 0 && buffer_index < rates_total)
        {
            BufferFairValueGapBear[buffer_index] = g_fair_value_gaps[i].gap_high + 5 * point_value;
            
            if(InpShowLabels)
            {
                string label_name = "SMC_FVG_Bear_" + TimeToString(g_fair_value_gaps[i].time);
                CreateLabel(label_name, g_fair_value_gaps[i].time, BufferFairValueGapBear[buffer_index], 
                           "FVG-", clrOrange);
            }
            
            if(InpAlertFairValueGaps && InpShowAlerts)
            {
                Alert("SMC: Bearish Fair Value Gap at ", g_fair_value_gaps[i].gap_high);
            }
        }
    }
    
    // Draw Support/Resistance lines
    DrawSupportResistanceLines();
}

//+------------------------------------------------------------------+
//| Draw Support/Resistance Lines                                    |
//+------------------------------------------------------------------+
void DrawSupportResistanceLines()
{
    // Clear previous S/R lines
    ObjectsDeleteAll(0, "SMC_SR_");
    
    for(int i = 0; i < ArraySize(g_sr_levels); i++)
    {
        if(!g_sr_levels[i].is_valid)
            continue;
        
        string line_name = "SMC_SR_" + IntegerToString(i);
        color line_color = g_sr_levels[i].is_support ? clrGreen : clrRed;
        
        ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, g_sr_levels[i].level);
        ObjectSetInteger(0, line_name, OBJPROP_COLOR, line_color);
        ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
        ObjectSetString(0, line_name, OBJPROP_TEXT, 
                       (g_sr_levels[i].is_support ? "Support " : "Resistance ") + 
                       IntegerToString(g_sr_levels[i].touches) + " touches");
    }
}

//+------------------------------------------------------------------+
//| Create Label on Chart                                            |
//+------------------------------------------------------------------+
void CreateLabel(string name, datetime time, double price, string text, color clr)
{
    if(!InpShowLabels)
        return;
    
    if(ObjectFind(0, name) >= 0)
        ObjectDelete(0, name);
    
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
}

//+------------------------------------------------------------------+
//| Get Market Analysis Summary                                      |
//+------------------------------------------------------------------+
string GetMarketAnalysisSummary()
{
    string summary = "=== SMC MARKET ANALYSIS ===\n";
    
    summary += StringFormat("Order Blocks: %d (Bull: %d, Bear: %d)\n", 
                           ArraySize(g_order_blocks),
                           CountBullishOrderBlocks(),
                           CountBearishOrderBlocks());
    
    summary += StringFormat("Fair Value Gaps: %d (Bull: %d, Bear: %d)\n", 
                           ArraySize(g_fair_value_gaps),
                           CountBullishFVGs(),
                           CountBearishFVGs());
    
    summary += StringFormat("Swing Points: %d (Highs: %d, Lows: %d)\n", 
                           ArraySize(g_swing_points),
                           CountSwingHighs(),
                           CountSwingLows());
    
    summary += StringFormat("S/R Levels: %d (Support: %d, Resistance: %d)\n", 
                           ArraySize(g_sr_levels),
                           CountSupportLevels(),
                           CountResistanceLevels());
    
    // Market bias
    int bullish_signals = CountBullishOrderBlocks() + CountBullishFVGs();
    int bearish_signals = CountBearishOrderBlocks() + CountBearishFVGs();
    
    if(bullish_signals > bearish_signals)
        summary += "Market Bias: BULLISH\n";
    else if(bearish_signals > bullish_signals)
        summary += "Market Bias: BEARISH\n";
    else
        summary += "Market Bias: NEUTRAL\n";
    
    return summary;
}

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
int CountBullishOrderBlocks()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_order_blocks); i++)
    {
        if(g_order_blocks[i].is_valid && g_order_blocks[i].is_bullish)
            count++;
    }
    return count;
}

int CountBearishOrderBlocks()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_order_blocks); i++)
    {
        if(g_order_blocks[i].is_valid && !g_order_blocks[i].is_bullish)
            count++;
    }
    return count;
}

int CountBullishFVGs()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_fair_value_gaps); i++)
    {
        if(g_fair_value_gaps[i].is_valid && g_fair_value_gaps[i].is_bullish)
            count++;
    }
    return count;
}

int CountBearishFVGs()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_fair_value_gaps); i++)
    {
        if(g_fair_value_gaps[i].is_valid && !g_fair_value_gaps[i].is_bullish)
            count++;
    }
    return count;
}

int CountSwingHighs()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_swing_points); i++)
    {
        if(g_swing_points[i].is_high)
            count++;
    }
    return count;
}

int CountSwingLows()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_swing_points); i++)
    {
        if(!g_swing_points[i].is_high)
            count++;
    }
    return count;
}

int CountSupportLevels()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_sr_levels); i++)
    {
        if(g_sr_levels[i].is_valid && g_sr_levels[i].is_support)
            count++;
    }
    return count;
}

int CountResistanceLevels()
{
    int count = 0;
    for(int i = 0; i < ArraySize(g_sr_levels); i++)
    {
        if(g_sr_levels[i].is_valid && !g_sr_levels[i].is_support)
            count++;
    }
    return count;
}

//+------------------------------------------------------------------+ 