//+------------------------------------------------------------------+
//|                              Analysis_SonicR_SupportResistance.mqh |
//|                                                    Sonic R MC System |
//|                     Advanced Support/Resistance with ICT Integration |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"

//+------------------------------------------------------------------+
//| Support/Resistance Enums                                         |
//+------------------------------------------------------------------+

enum ENUM_SR_TYPE
{
    SR_HORIZONTAL_SUPPORT,          // Horizontal support level
    SR_HORIZONTAL_RESISTANCE,       // Horizontal resistance level
    SR_DYNAMIC_SUPPORT,             // Dynamic support (trendline)
    SR_DYNAMIC_RESISTANCE,          // Dynamic resistance (trendline)
    SR_PSYCHOLOGICAL_LEVEL,         // Round number/psychological
    SR_FIBONACCI_LEVEL,             // Fibonacci retracement/extension
    SR_PIVOT_POINT,                 // Pivot point level
    SR_VOLUME_PROFILE,              // Volume profile level
    SR_ORDER_BLOCK,                 // ICT Order Block
    SR_FAIR_VALUE_GAP,              // ICT Fair Value Gap
    SR_LIQUIDITY_ZONE,              // Liquidity concentration zone
    SR_INSTITUTIONAL_LEVEL          // Institutional reference level
};

enum ENUM_SR_STRENGTH
{
    SR_STRENGTH_WEAK = 1,           // Weak S/R (1-25)
    SR_STRENGTH_MODERATE = 2,       // Moderate S/R (26-50)
    SR_STRENGTH_STRONG = 3,         // Strong S/R (51-75)
    SR_STRENGTH_VERY_STRONG = 4     // Very Strong S/R (76-100)
};

enum ENUM_SR_STATUS
{
    SR_STATUS_ACTIVE,               // Currently active
    SR_STATUS_TESTED,               // Recently tested
    SR_STATUS_BROKEN,               // Broken/penetrated
    SR_STATUS_FLIPPED,              // Support became resistance or vice versa
    SR_STATUS_EXPIRED,              // Too old to be relevant
    SR_STATUS_FORMING               // In process of forming
};

enum ENUM_REACTION_TYPE
{
    REACTION_BOUNCE,                // Price bounced from level
    REACTION_BREAK,                 // Price broke through level
    REACTION_FALSE_BREAK,           // False break (quickly returned)
    REACTION_RETEST,                // Retesting after break
    REACTION_REJECTION,             // Strong rejection from level
    REACTION_ABSORPTION             // Level absorbed volume
};

//+------------------------------------------------------------------+
//| Support/Resistance Data Structures                               |
//+------------------------------------------------------------------+

struct SSupportResistanceLevel
{
    double              price;              // S/R price level
    ENUM_SR_TYPE        type;               // Type of S/R
    ENUM_SR_STRENGTH    strength;           // Strength classification
    ENUM_SR_STATUS      status;             // Current status
    datetime            formation_time;     // When level was formed
    datetime            last_test_time;     // Last time price tested level
    int                 touch_count;        // Number of touches
    int                 bounce_count;       // Number of bounces
    int                 break_count;        // Number of breaks
    double              max_penetration;    // Maximum penetration depth
    double              avg_reaction_pips;  // Average reaction in pips
    double              volume_at_level;    // Volume when price at level
    bool                is_major_level;     // Major institutional level
    bool                is_psychological;   // Psychological level (round number)
    bool                has_volume_confirm; // Volume confirmation
    double              fibonacci_ratio;    // If Fibonacci level, the ratio
    string              description;        // Level description
    bool                is_valid;           // Still valid for trading
    double              tolerance_pips;     // Tolerance for level test
};

struct SReactionAnalysis
{
    ENUM_REACTION_TYPE  type;               // Type of reaction
    datetime            reaction_time;      // When reaction occurred
    double              reaction_price;     // Price of reaction
    double              reaction_strength;  // Strength of reaction (pips)
    double              reaction_volume;    // Volume during reaction
    int                 reaction_duration;  // Duration in bars
    bool                is_significant;     // Significant reaction
    double              follow_through;     // Follow-through after reaction
    bool                created_new_level;  // Created new S/R level
};

struct SLiquidityAnalysis
{
    double              liquidity_price;    // Price where liquidity exists
    double              estimated_volume;   // Estimated volume
    bool                is_buy_liquidity;   // Buy side liquidity
    bool                is_sell_liquidity;  // Sell side liquidity
    bool                is_obvious;         // Obvious to retail traders
    bool                is_swept;           // Has been swept
    datetime            sweep_time;         // When swept
    double              sweep_reaction;     // Reaction after sweep
    bool                expect_reversal;    // Expect reversal after sweep
};

struct SZoneAnalysis
{
    double              zone_high;          // Zone high boundary
    double              zone_low;           // Zone low boundary
    double              zone_center;        // Zone center
    ENUM_SR_TYPE        zone_type;          // Type of zone
    int                 zone_strength;      // Zone strength (1-100)
    bool                is_supply_zone;     // Supply zone (resistance)
    bool                is_demand_zone;     // Demand zone (support)
    bool                is_fresh;           // Fresh zone (untested)
    bool                is_tested;          // Previously tested
    int                 test_count;         // Number of tests
    double              zone_thickness;     // Zone thickness in pips
    datetime            formation_time;     // Zone formation time
    bool                has_imbalance;      // Contains price imbalance
};

struct SSupportResistanceContext
{
    SSupportResistanceLevel     support_levels[];
    SSupportResistanceLevel     resistance_levels[];
    SReactionAnalysis           reactions[];
    SLiquidityAnalysis          liquidity_zones[];
    SZoneAnalysis               supply_zones[];
    SZoneAnalysis               demand_zones[];
    double                      current_support;
    double                      current_resistance;
    double                      nearest_support;
    double                      nearest_resistance;
    bool                        at_major_support;
    bool                        at_major_resistance;
};

//+------------------------------------------------------------------+
//| Sonic R Support/Resistance Analysis Class                        |
//+------------------------------------------------------------------+

class CSonicRSupportResistance
{
private:
    // Core dependencies
    CLogger*                    m_logger;
    
    // Configuration
    int                         m_lookback_period;
    int                         m_min_touches;
    double                      m_touch_tolerance_pips;
    double                      m_break_confirmation_pips;
    double                      m_min_strength_threshold;
    int                         m_max_levels_display;
    bool                        m_show_psychological_levels;
    bool                        m_show_fibonacci_levels;
    bool                        m_use_volume_confirmation;
    
    // S/R Data
    SSupportResistanceContext   m_context;
    
    // Calculation buffers
    double                      m_high_buffer[];
    double                      m_low_buffer[];
    double                      m_close_buffer[];
    double                      m_volume_buffer[];
    
    // Fibonacci levels
    double                      m_fib_levels[13];
    
public:
    // Constructor/Destructor
    CSonicRSupportResistance();
    ~CSonicRSupportResistance();
    
    // Initialization
    bool Initialize(CLogger* logger);
    void Deinitialize();
    
    // Configuration
    void SetLookbackPeriod(int period) { m_lookback_period = period; }
    void SetMinTouches(int touches) { m_min_touches = touches; }
    void SetTouchTolerance(double pips) { m_touch_tolerance_pips = pips; }
    void SetBreakConfirmation(double pips) { m_break_confirmation_pips = pips; }
    void SetMinStrength(double strength) { m_min_strength_threshold = strength; }
    void SetMaxLevels(int max_levels) { m_max_levels_display = max_levels; }
    void ShowPsychologicalLevels(bool show) { m_show_psychological_levels = show; }
    void ShowFibonacciLevels(bool show) { m_show_fibonacci_levels = show; }
    void SetVolumeConfirmation(bool use_volume) { m_use_volume_confirmation = use_volume; }

    // Context Access
    SSupportResistanceContext* GetContext() { return &m_context; }
    
    // Main analysis functions
    bool AnalyzeSupportResistance();
    bool IdentifyHorizontalLevels();
    bool IdentifyDynamicLevels();
    bool IdentifyPsychologicalLevels();
    bool IdentifyFibonacciLevels();
    bool IdentifyInstitutionalLevels();
    bool AnalyzeReactions();
    bool AnalyzeLiquidity();
    bool IdentifySupplyDemandZones();
    
    // Level identification
    bool FindSupportLevels();
    bool FindResistanceLevels();
    bool ValidateLevel(SSupportResistanceLevel& level);
    int  CalculateLevelStrength(const SSupportResistanceLevel& level);
    bool IsLevelValid(const SSupportResistanceLevel& level);
    bool IsLevelBroken(const SSupportResistanceLevel& level);
    
    // Reaction analysis
    bool DetectBounce(const SSupportResistanceLevel& level);
    bool DetectBreak(const SSupportResistanceLevel& level);
    bool DetectFalseBreak(const SSupportResistanceLevel& level);
    bool DetectRetest(const SSupportResistanceLevel& level);
    ENUM_REACTION_TYPE GetLastReaction(const SSupportResistanceLevel& level);
    
    // Liquidity analysis
    bool IdentifyLiquidityLevels();
    bool DetectLiquiditySweep();
    bool IsLiquidityGrab(double price_level);
    double GetNearestLiquidity(bool above_price);
    bool ExpectReversalAfterSweep();
    
    // Zone analysis
    bool IdentifySupplyZones();
    bool IdentifyDemandZones();
    bool IsInSupplyZone(double price);
    bool IsInDemandZone(double price);
    bool IsFreshZone(const SZoneAnalysis& zone);
    
    // Signal generation
    bool IsSupportBounceSignal();
    bool IsResistanceBounceSignal();
    bool IsBreakoutSignal();
    bool IsRetestSignal();
    bool IsLiquidityReversalSignal();
    bool IsZoneReactionSignal();
    
    // Current market analysis
    double GetCurrentSupport() { return m_context.current_support; }
    double GetCurrentResistance() { return m_context.current_resistance; }
    double GetNearestSupport() { return m_context.nearest_support; }
    double GetNearestResistance() { return m_context.nearest_resistance; }
    bool IsAtMajorSupport() { return m_context.at_major_support; }
    bool IsAtMajorResistance() { return m_context.at_major_resistance; }
    
    // Level queries
    bool GetStrongestSupport(SSupportResistanceLevel& level);
    bool GetStrongestResistance(SSupportResistanceLevel& level);
    bool GetNearestLevel(bool is_support, SSupportResistanceLevel& level);
    int  GetActiveLevelsCount(bool is_support);
    
    // Fibonacci analysis
    bool CalculateFibonacciLevels(double high, double low);
    bool IsAtFibonacciLevel(double price, double tolerance = 0.0);
    double GetNearestFibLevel(double price);
    bool IsOptimalFibEntry(double price);
    
    // Psychological levels
    bool IsPsychologicalLevel(double price);
    double GetNearestPsychLevel(double price);
    bool IsRoundNumber(double price);
    
    // Risk management
    double CalculateSRStopLoss(bool is_buy_signal);
    double CalculateSRTakeProfit(bool is_buy_signal);
    double GetOptimalEntry(bool is_buy_signal);
    
    // Confluence analysis
    bool HasSupportConfluence(double price);
    bool HasResistanceConfluence(double price);
    int  CountSupportFactors(double price);
    int  CountResistanceFactors(double price);
    
    // Status functions
    string GetSRAnalysisSummary();
    string GetLevelDescription(const SSupportResistanceLevel& level);
    void PrintSupportLevels();
    void PrintResistanceLevels();
    void PrintLiquidityAnalysis();
    
    // Utility functions
    void LogAnalysis();
    
private:
    // Helper functions
    bool UpdateBuffers();
    double PipsToPrice(double pips);
    double PriceToPips(double price_diff);
    bool IsWithinTolerance(double price1, double price2, double tolerance);
    double GetAverageVolume(int period);
    bool HasVolumeConfirmation(double price, datetime time);
    
    // Internal calculations
    bool CalculateLevelStatistics();
    bool UpdateLevelStatus();
    bool CleanupExpiredLevels();
    bool SortLevelsByStrength();
    bool ValidateDataIntegrity();
    
    // Sonic R specific functions
    bool IsSonicRSupportLevel(double price);
    bool IsSonicRResistanceLevel(double price);
    bool IsOptimalSonicREntry(double price, bool is_buy);
    bool HasSonicRConfluence(double price, bool is_support);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSonicRSupportResistance::CSonicRSupportResistance()
{
    m_logger = NULL;
    m_lookback_period = 500;
    m_min_touches = 2;
    m_touch_tolerance_pips = 3.0;
    m_break_confirmation_pips = 5.0;
    m_min_strength_threshold = 40.0;
    m_max_levels_display = 20;
    m_show_psychological_levels = true;
    m_show_fibonacci_levels = true;
    m_use_volume_confirmation = true;
    
    ZeroMemory(m_context);
    
    // Initialize Fibonacci levels
    m_fib_levels[0] = 0.0;      // 0%
    m_fib_levels[1] = 0.236;    // 23.6%
    m_fib_levels[2] = 0.382;    // 38.2%
    m_fib_levels[3] = 0.5;      // 50%
    m_fib_levels[4] = 0.618;    // 61.8%
    m_fib_levels[5] = 0.786;    // 78.6%
    m_fib_levels[6] = 1.0;      // 100%
    m_fib_levels[7] = 1.272;    // 127.2%
    m_fib_levels[8] = 1.414;    // 141.4%
    m_fib_levels[9] = 1.618;    // 161.8%
    m_fib_levels[10] = 2.0;     // 200%
    m_fib_levels[11] = 2.618;   // 261.8%
    m_fib_levels[12] = 4.236;   // 423.6%
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CSonicRSupportResistance::Initialize(CLogger* logger)
{
    if(logger == NULL)
    {
        Print("CSonicRSupportResistance::Initialize - Logger is NULL");
        return false;
    }
    
    m_logger = logger;
    m_logger.Log(LOG_LEVEL_INFO, "Sonic R Support/Resistance initialized");
    
    // Initialize buffers
    int bars_available = iBars(Symbol(), Period());
    if(bars_available < m_lookback_period)
    {
        m_logger.Log(LOG_LEVEL_WARNING, "Insufficient bars for S/R analysis");
        return false;
    }
    
    ArrayResize(m_high_buffer, bars_available);
    ArrayResize(m_low_buffer, bars_available);
    ArrayResize(m_close_buffer, bars_available);
    ArrayResize(m_volume_buffer, bars_available);
    
    return UpdateBuffers();
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CSonicRSupportResistance::Deinitialize()
{
    if(m_logger != NULL)
    {
        m_logger.Log(LOG_LEVEL_INFO, "Sonic R Support/Resistance deinitialized");
    }

    // Clean up arrays
    ArrayFree(m_context.support_levels);
    ArrayFree(m_context.resistance_levels);
    ArrayFree(m_context.reactions);
    ArrayFree(m_context.liquidity_zones);
    ArrayFree(m_context.supply_zones);
    ArrayFree(m_context.demand_zones);

    // Clean up buffers
    ArrayFree(m_high_buffer);
    ArrayFree(m_low_buffer);
    ArrayFree(m_close_buffer);
    ArrayFree(m_volume_buffer);
}

//+------------------------------------------------------------------+
//| Main Support/Resistance Analysis                                 |
//+------------------------------------------------------------------+
bool CSonicRSupportResistance::AnalyzeSupportResistance()
{
    if(m_logger == NULL)
        return false;
    
    // Update market data
    if(!UpdateBuffers())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to update market data");
        return false;
    }
    
    // Identify all types of levels
    if(!IdentifyHorizontalLevels())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to identify horizontal levels");
        return false;
    }
    
    if(m_show_psychological_levels && !IdentifyPsychologicalLevels())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to identify psychological levels");
        return false;
    }
    
    if(m_show_fibonacci_levels && !IdentifyFibonacciLevels())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to identify Fibonacci levels");
        return false;
    }
    
    if(!IdentifyInstitutionalLevels())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to identify institutional levels");
        return false;
    }
    
    // Analyze reactions and liquidity
    if(!AnalyzeReactions())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to analyze reactions");
        return false;
    }
    
    if(!AnalyzeLiquidity())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to analyze liquidity");
        return false;
    }
    
    if(!IdentifySupplyDemandZones())
    {
        m_logger.Log(LOG_LEVEL_ERROR, "Failed to identify supply/demand zones");
        return false;
    }
    
    // Update current market state
    UpdateLevelStatus();
    
    // Clean up old/invalid levels
    CleanupExpiredLevels();
    
    m_logger.Log(LOG_LEVEL_DEBUG, "S/R analysis completed successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Identify Horizontal Support/Resistance Levels                   |
//+------------------------------------------------------------------+
bool CSonicRSupportResistance::IdentifyHorizontalLevels()
{
    // Clear existing levels
    ArrayResize(m_context.support_levels, 0);
    ArrayResize(m_context.resistance_levels, 0);
    
    // Find swing highs and lows
    for(int i = 3; i < ArraySize(m_high_buffer) - 3; i++)
    {
        // Check for swing high
        bool is_swing_high = true;
        for(int j = i - 3; j <= i + 3; j++)
        {
            if(j != i && m_high_buffer[j] >= m_high_buffer[i])
            {
                is_swing_high = false;
                break;
            }
        }
        
        if(is_swing_high)
        {
            // Count touches at this level
            int touches = 0;
            double level_price = m_high_buffer[i];
            double tolerance = PipsToPrice(m_touch_tolerance_pips);
            
            for(int k = 0; k < ArraySize(m_high_buffer); k++)
            {
                if(MathAbs(m_high_buffer[k] - level_price) <= tolerance)
                    touches++;
            }
            
            if(touches >= m_min_touches)
            {
                SSupportResistanceLevel level;
                level.price = level_price;
                level.type = SR_HORIZONTAL_RESISTANCE;
                level.strength = (ENUM_SR_STRENGTH)MathMin(4, touches / 2 + 1);
                level.status = SR_STATUS_ACTIVE;
                level.formation_time = iTime(Symbol(), Period(), i);
                level.touch_count = touches;
                level.bounce_count = 0;
                level.break_count = 0;
                level.is_major_level = (touches >= 4);
                level.is_valid = true;
                level.tolerance_pips = m_touch_tolerance_pips;
                level.description = StringFormat("Horizontal Resistance %.5f (%d touches)", 
                                                level_price, touches);
                
                // Add to resistance levels
                int size = ArraySize(m_context.resistance_levels);
                ArrayResize(m_context.resistance_levels, size + 1);
                m_context.resistance_levels[size] = level;
            }
        }
        
        // Check for swing low
        bool is_swing_low = true;
        for(int j = i - 3; j <= i + 3; j++)
        {
            if(j != i && m_low_buffer[j] <= m_low_buffer[i])
            {
                is_swing_low = false;
                break;
            }
        }
        
        if(is_swing_low)
        {
            // Count touches at this level
            int touches = 0;
            double level_price = m_low_buffer[i];
            double tolerance = PipsToPrice(m_touch_tolerance_pips);
            
            for(int k = 0; k < ArraySize(m_low_buffer); k++)
            {
                if(MathAbs(m_low_buffer[k] - level_price) <= tolerance)
                    touches++;
            }
            
            if(touches >= m_min_touches)
            {
                SSupportResistanceLevel level;
                level.price = level_price;
                level.type = SR_HORIZONTAL_SUPPORT;
                level.strength = (ENUM_SR_STRENGTH)MathMin(4, touches / 2 + 1);
                level.status = SR_STATUS_ACTIVE;
                level.formation_time = iTime(Symbol(), Period(), i);
                level.touch_count = touches;
                level.bounce_count = 0;
                level.break_count = 0;
                level.is_major_level = (touches >= 4);
                level.is_valid = true;
                level.tolerance_pips = m_touch_tolerance_pips;
                level.description = StringFormat("Horizontal Support %.5f (%d touches)", 
                                                level_price, touches);
                
                // Add to support levels
                int size = ArraySize(m_context.support_levels);
                ArrayResize(m_context.support_levels, size + 1);
                m_context.support_levels[size] = level;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Identify Psychological Levels                                    |
//+------------------------------------------------------------------+
bool CSonicRSupportResistance::IdentifyPsychologicalLevels()
{
    double current_price = m_close_buffer[0];
    double price_range = PipsToPrice(1000);  // Look within 1000 pips
    
    // Generate round number levels
    double start_price = current_price - price_range;
    double end_price = current_price + price_range;
    
    // Major psychological levels (00, 50)
    double major_increment = PipsToPrice(500);  // 500 pips
    for(double price = start_price; price <= end_price; price += major_increment)
    {
        // Round to nearest major level
        double rounded_price = MathRound(price / major_increment) * major_increment;
        
        if(IsPsychologicalLevel(rounded_price))
        {
            SSupportResistanceLevel level;
            level.price = rounded_price;
            level.type = SR_PSYCHOLOGICAL_LEVEL;
            level.strength = SR_STRENGTH_MODERATE;
            level.status = SR_STATUS_ACTIVE;
            level.formation_time = TimeCurrent();
            level.is_psychological = true;
            level.is_valid = true;
            level.tolerance_pips = m_touch_tolerance_pips * 2;  // Wider tolerance
            level.description = StringFormat("Psychological Level %.5f", rounded_price);
            
            // Determine if support or resistance based on current price
            if(rounded_price > current_price)
            {
                // Add to resistance
                int size = ArraySize(m_context.resistance_levels);
                ArrayResize(m_context.resistance_levels, size + 1);
                m_context.resistance_levels[size] = level;
            }
            else
            {
                // Add to support
                int size = ArraySize(m_context.support_levels);
                ArrayResize(m_context.support_levels, size + 1);
                m_context.support_levels[size] = level;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Support/Resistance Analysis Summary                          |
//+------------------------------------------------------------------+
string CSonicRSupportResistance::GetSRAnalysisSummary()
{
    string summary = "";
    
    summary += "=== SONIC R SUPPORT/RESISTANCE ===\n";
    summary += StringFormat("Support Levels: %d\n", ArraySize(m_context.support_levels));
    summary += StringFormat("Resistance Levels: %d\n", ArraySize(m_context.resistance_levels));
    summary += StringFormat("Current Support: %.5f\n", m_context.current_support);
    summary += StringFormat("Current Resistance: %.5f\n", m_context.current_resistance);
    summary += StringFormat("Nearest Support: %.5f\n", m_context.nearest_support);
    summary += StringFormat("Nearest Resistance: %.5f\n", m_context.nearest_resistance);
    summary += StringFormat("At Major Support: %s\n", m_context.at_major_support ? "YES" : "NO");
    summary += StringFormat("At Major Resistance: %s\n", m_context.at_major_resistance ? "YES" : "NO");
    summary += StringFormat("Supply Zones: %d\n", ArraySize(m_context.supply_zones));
    summary += StringFormat("Demand Zones: %d\n", ArraySize(m_context.demand_zones));
    summary += StringFormat("Liquidity Zones: %d\n", ArraySize(m_context.liquidity_zones));
    
    if(IsSupportBounceSignal())
        summary += ">>> SUPPORT BOUNCE SIGNAL <<<\n";
    else if(IsResistanceBounceSignal())
        summary += ">>> RESISTANCE BOUNCE SIGNAL <<<\n";
    else if(IsBreakoutSignal())
        summary += ">>> BREAKOUT SIGNAL <<<\n";
    else if(IsRetestSignal())
        summary += ">>> RETEST SIGNAL <<<\n";
    
    return summary;
}

//+------------------------------------------------------------------+