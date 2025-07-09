//+------------------------------------------------------------------+
//|                                      Indicator_SonicR_SMC_Lite.mq5 |
//|                                                    Sonic R MC System |
//|                                   Lightweight SMC Indicator for EA |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property description "Lightweight SMC Indicator for EA Data Feed"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4

// Plot definitions
#property indicator_label1  "SMC Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "SMC Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Order Block"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Structure Break"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

input group "=== SMC Lite Settings ==="
input int InpLookbackPeriod = 100;                          // Lookback Period
input int InpSwingStrength = 3;                             // Swing Strength
input double InpMinImpulsePips = 10.0;                      // Min Impulse (Pips)
input double InpMinGapPips = 2.0;                           // Min Gap Size (Pips)
input int InpMinConfidence = 70;                            // Min Confidence Level

input group "=== Display Settings ==="
input bool InpShowSignals = true;                           // Show Trading Signals
input bool InpShowOrderBlocks = true;                       // Show Order Blocks
input bool InpShowStructureBreaks = true;                   // Show Structure Breaks
input bool InpShowAlerts = true;                            // Show Alerts

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

// Indicator buffers
double BufferBuySignal[];
double BufferSellSignal[];
double BufferOrderBlock[];
double BufferStructureBreak[];

// Hidden buffers
double BufferCalculation1[];
double BufferCalculation2[];
double BufferCalculation3[];
double BufferCalculation4[];

// Simple structures for data
struct SimpleOrderBlock
{
    datetime time;
    double price;
    bool is_bullish;
    bool is_valid;
};

struct SimpleSignal
{
    datetime time;
    double price;
    bool is_buy;
    int confidence;
    bool is_valid;
};

// Data arrays
SimpleOrderBlock g_order_blocks[50];
SimpleSignal g_current_signal;
int g_ob_count = 0;

// Status variables
bool g_initialized = false;
datetime g_last_bar_time = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("SMC Lite Indicator: Initializing...");
    
    // Set up indicator buffers
    SetIndexBuffer(0, BufferBuySignal, INDICATOR_DATA);
    SetIndexBuffer(1, BufferSellSignal, INDICATOR_DATA);
    SetIndexBuffer(2, BufferOrderBlock, INDICATOR_DATA);
    SetIndexBuffer(3, BufferStructureBreak, INDICATOR_DATA);
    
    // Hidden buffers
    SetIndexBuffer(4, BufferCalculation1, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, BufferCalculation2, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, BufferCalculation3, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, BufferCalculation4, INDICATOR_CALCULATIONS);
    
    // Set arrow codes
    PlotIndexSetInteger(0, PLOT_ARROW, 233); // Up arrow for buy
    PlotIndexSetInteger(1, PLOT_ARROW, 234); // Down arrow for sell
    PlotIndexSetInteger(2, PLOT_ARROW, 159); // Triangle for order block
    PlotIndexSetInteger(3, PLOT_ARROW, 168); // Diamond for structure break
    
    // Set empty values
    for(int i = 0; i < 4; i++)
    {
        PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    }
    
    // Initialize arrays as series
    ArraySetAsSeries(BufferBuySignal, true);
    ArraySetAsSeries(BufferSellSignal, true);
    ArraySetAsSeries(BufferOrderBlock, true);
    ArraySetAsSeries(BufferStructureBreak, true);
    
    // Initialize data
    for(int i = 0; i < 50; i++)
    {
        g_order_blocks[i].is_valid = false;
    }
    g_current_signal.is_valid = false;
    g_ob_count = 0;
    
    g_initialized = true;
    Print("SMC Lite Indicator: Initialized successfully");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("SMC Lite Indicator: Deinitialized");
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
    if(time[rates_total - 1] == g_last_bar_time)
        return rates_total;
    
    g_last_bar_time = time[rates_total - 1];
    
    // Clear all buffers
    ArrayInitialize(BufferBuySignal, EMPTY_VALUE);
    ArrayInitialize(BufferSellSignal, EMPTY_VALUE);
    ArrayInitialize(BufferOrderBlock, EMPTY_VALUE);
    ArrayInitialize(BufferStructureBreak, EMPTY_VALUE);
    
    // Simple SMC analysis
    AnalyzeSMC(rates_total, time, open, high, low, close, tick_volume);
    
    // Display signals
    DisplaySignals(rates_total, time, high, low, close);
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Simple SMC Analysis                                              |
//+------------------------------------------------------------------+
void AnalyzeSMC(int rates_total, const datetime &time[], const double &open[], 
               const double &high[], const double &low[], const double &close[], 
               const long &tick_volume[])
{
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double min_impulse = InpMinImpulsePips * point_value;
    
    // Reset current signal
    g_current_signal.is_valid = false;
    
    // Simple swing analysis
    for(int i = InpSwingStrength; i < rates_total - InpSwingStrength - 1; i++)
    {
        bool is_swing_high = true;
        bool is_swing_low = true;
        
        // Check for swing high
        for(int j = i - InpSwingStrength; j <= i + InpSwingStrength; j++)
        {
            if(j != i && high[j] >= high[i])
            {
                is_swing_high = false;
                break;
            }
        }
        
        // Check for swing low
        for(int j = i - InpSwingStrength; j <= i + InpSwingStrength; j++)
        {
            if(j != i && low[j] <= low[i])
            {
                is_swing_low = false;
                break;
            }
        }
        
        // Check for order blocks after swings
        if(is_swing_high || is_swing_low)
        {
            CheckForOrderBlocks(i, rates_total, time, open, high, low, close, tick_volume, is_swing_high);
        }
    }
    
    // Generate trading signals
    GenerateSignals(rates_total, time, open, high, low, close, tick_volume);
}

//+------------------------------------------------------------------+
//| Check For Order Blocks                                           |
//+------------------------------------------------------------------+
void CheckForOrderBlocks(int swing_bar, int rates_total, const datetime &time[], 
                        const double &open[], const double &high[], const double &low[], 
                        const double &close[], const long &tick_volume[], bool is_swing_high)
{
    if(g_ob_count >= 49) return; // Prevent overflow
    
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double min_impulse = InpMinImpulsePips * point_value;
    
    // Look for impulse before swing
    int lookback = MathMin(10, swing_bar);
    
    for(int i = swing_bar - lookback; i < swing_bar; i++)
    {
        if(i < 0) continue;
        
        bool is_order_block = false;
        double ob_price = 0;
        
        if(is_swing_high)
        {
            // Look for bearish order block (last bullish candle before bearish impulse)
            if(close[i] > open[i] && close[i + 1] < open[i + 1])
            {
                double impulse_size = high[swing_bar] - low[i];
                if(impulse_size >= min_impulse)
                {
                    is_order_block = true;
                    ob_price = (high[i] + low[i]) / 2;
                }
            }
        }
        else
        {
            // Look for bullish order block (last bearish candle before bullish impulse)
            if(close[i] < open[i] && close[i + 1] > open[i + 1])
            {
                double impulse_size = high[i] - low[swing_bar];
                if(impulse_size >= min_impulse)
                {
                    is_order_block = true;
                    ob_price = (high[i] + low[i]) / 2;
                }
            }
        }
        
        if(is_order_block)
        {
            g_order_blocks[g_ob_count].time = time[i];
            g_order_blocks[g_ob_count].price = ob_price;
            g_order_blocks[g_ob_count].is_bullish = !is_swing_high;
            g_order_blocks[g_ob_count].is_valid = true;
            g_ob_count++;
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Generate Trading Signals                                         |
//+------------------------------------------------------------------+
void GenerateSignals(int rates_total, const datetime &time[], const double &open[], 
                    const double &high[], const double &low[], const double &close[], 
                    const long &tick_volume[])
{
    if(rates_total < 5) return;
    
    double current_price = close[rates_total - 1];
    double prev_price = close[rates_total - 2];
    
    // Simple signal generation based on order blocks and price action
    int bullish_factors = 0;
    int bearish_factors = 0;
    
    // Check proximity to order blocks
    for(int i = 0; i < g_ob_count; i++)
    {
        if(!g_order_blocks[i].is_valid) continue;
        
        double distance = MathAbs(current_price - g_order_blocks[i].price);
        double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
        
        if(distance < 20 * point_value) // Within 20 pips of order block
        {
            if(g_order_blocks[i].is_bullish)
                bullish_factors++;
            else
                bearish_factors++;
        }
    }
    
    // Check price momentum
    if(current_price > prev_price)
        bullish_factors++;
    else if(current_price < prev_price)
        bearish_factors++;
    
    // Check volume (simplified)
    long current_volume = tick_volume[rates_total - 1];
    long avg_volume = 0;
    for(int i = rates_total - 10; i < rates_total - 1; i++)
    {
        if(i >= 0) avg_volume += tick_volume[i];
    }
    avg_volume /= 9;
    
    if(current_volume > avg_volume * 1.2)
    {
        if(current_price > prev_price)
            bullish_factors++;
        else
            bearish_factors++;
    }
    
    // Generate signal based on factors
    int confidence = 0;
    bool is_buy = false;
    
    if(bullish_factors >= 2)
    {
        is_buy = true;
        confidence = MathMin(95, 50 + bullish_factors * 15);
    }
    else if(bearish_factors >= 2)
    {
        is_buy = false;
        confidence = MathMin(95, 50 + bearish_factors * 15);
    }
    
    if(confidence >= InpMinConfidence)
    {
        g_current_signal.time = time[rates_total - 1];
        g_current_signal.price = current_price;
        g_current_signal.is_buy = is_buy;
        g_current_signal.confidence = confidence;
        g_current_signal.is_valid = true;
    }
}

//+------------------------------------------------------------------+
//| Display Signals                                                  |
//+------------------------------------------------------------------+
void DisplaySignals(int rates_total, const datetime &time[], const double &high[], 
                   const double &low[], const double &close[])
{
    double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    // Display current signal
    if(g_current_signal.is_valid && InpShowSignals)
    {
        int buffer_index = 0; // Current bar
        
        if(g_current_signal.is_buy)
        {
            BufferBuySignal[buffer_index] = low[rates_total - 1] - 10 * point_value;
            
            if(InpShowAlerts)
            {
                Alert("SMC Lite: BUY Signal - Confidence: ", g_current_signal.confidence, "%");
            }
        }
        else
        {
            BufferSellSignal[buffer_index] = high[rates_total - 1] + 10 * point_value;
            
            if(InpShowAlerts)
            {
                Alert("SMC Lite: SELL Signal - Confidence: ", g_current_signal.confidence, "%");
            }
        }
    }
    
    // Display order blocks
    if(InpShowOrderBlocks)
    {
        for(int i = 0; i < g_ob_count; i++)
        {
            if(!g_order_blocks[i].is_valid) continue;
            
            // Find bar index for this order block
            for(int j = 0; j < rates_total; j++)
            {
                if(time[j] == g_order_blocks[i].time)
                {
                    int buffer_index = rates_total - 1 - j;
                    if(buffer_index >= 0 && buffer_index < rates_total)
                    {
                        BufferOrderBlock[buffer_index] = g_order_blocks[i].price;
                    }
                    break;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Get Current Signal for EA                                        |
//+------------------------------------------------------------------+
bool GetSMCSignal(bool &is_buy, double &entry_price, int &confidence)
{
    if(!g_current_signal.is_valid)
        return false;
    
    is_buy = g_current_signal.is_buy;
    entry_price = g_current_signal.price;
    confidence = g_current_signal.confidence;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Order Block Count                                            |
//+------------------------------------------------------------------+
int GetOrderBlockCount()
{
    int count = 0;
    for(int i = 0; i < g_ob_count; i++)
    {
        if(g_order_blocks[i].is_valid)
            count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Get Market Analysis Summary                                      |
//+------------------------------------------------------------------+
string GetSMCAnalysisSummary()
{
    string summary = "=== SMC LITE ANALYSIS ===\n";
    
    summary += StringFormat("Order Blocks: %d\n", GetOrderBlockCount());
    
    if(g_current_signal.is_valid)
    {
        summary += StringFormat("Current Signal: %s (Confidence: %d%%)\n", 
                               g_current_signal.is_buy ? "BUY" : "SELL", 
                               g_current_signal.confidence);
    }
    else
    {
        summary += "Current Signal: None\n";
    }
    
    return summary;
}

//+------------------------------------------------------------------+ 