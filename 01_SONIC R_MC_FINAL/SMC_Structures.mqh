//+------------------------------------------------------------------+
//|                                               SMC_Structures.mqh |
//|                                    Smart Money Concepts Indicator |
//|                                             Data Structures & Enums |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+

// Signal types for EA integration
enum SMC_SIGNAL_TYPE
{
    SIGNAL_NONE = 0,
    SIGNAL_OB_BULLISH = 1,
    SIGNAL_OB_BEARISH = 2,
    SIGNAL_FVG_BULLISH = 3,
    SIGNAL_FVG_BEARISH = 4,
    SIGNAL_BOS_BULLISH = 5,
    SIGNAL_BOS_BEARISH = 6,
    SIGNAL_CHOCH_BULLISH = 7,
    SIGNAL_CHOCH_BEARISH = 8,
    SIGNAL_SR_BREAK_UP = 9,
    SIGNAL_SR_BREAK_DOWN = 10,
    SIGNAL_LIQUIDITY_SWEEP = 11
};

// Market structure states
enum MARKET_STRUCTURE_STATE
{
    STRUCTURE_UNKNOWN = 0,
    STRUCTURE_UPTREND = 1,
    STRUCTURE_DOWNTREND = 2,
    STRUCTURE_RANGING = 3,
    STRUCTURE_TRANSITION = 4
};

// Order block types
enum ORDER_BLOCK_TYPE
{
    OB_NONE = 0,
    OB_BULLISH = 1,
    OB_BEARISH = 2,
    OB_BREAKER_BULLISH = 3,
    OB_BREAKER_BEARISH = 4
};

// Fair Value Gap types
enum FVG_TYPE
{
    FVG_NONE = 0,
    FVG_BULLISH = 1,
    FVG_BEARISH = 2,
    FVG_BALANCED = 3
};

// Support/Resistance level types
enum SR_LEVEL_TYPE
{
    SR_NONE = 0,
    SR_SUPPORT = 1,
    SR_RESISTANCE = 2,
    SR_FLIP_ZONE = 3
};

//+------------------------------------------------------------------+
//| Core Data Structures                                             |
//+------------------------------------------------------------------+

// Basic price point structure
struct PricePoint
{
    datetime time;              // Timestamp
    double   price;             // Price level
    double   volume;            // Volume at this point
    int      bar_index;         // Bar index
    
    void Reset()
    {
        time = 0;
        price = 0.0;
        volume = 0.0;
        bar_index = -1;
    }
    
    double GetMidPrice() { return price; }
};

// Swing point structure
struct SwingPoint
{
    PricePoint point;           // Basic price point data
    int        type;            // 1 = High, -1 = Low
    int        strength;        // Swing strength (1-10)
    bool       is_broken;       // Has been broken
    datetime   break_time;      // When it was broken
    double     break_volume;    // Volume on break
    
    void Reset()
    {
        point.Reset();
        type = 0;
        strength = 0;
        is_broken = false;
        break_time = 0;
        break_volume = 0.0;
    }
};

// Order Block structure
struct OrderBlock
{
    datetime formation_time;    // When block was formed
    double   high_price;        // Block high boundary
    double   low_price;         // Block low boundary
    double   impulse_start;     // Start price of impulse
    double   impulse_end;       // End price of impulse
    double   impulse_volume;    // Volume during impulse
    int      impulse_candles;   // Number of candles in impulse
    int      strength;          // Block strength (1-100)
    ORDER_BLOCK_TYPE type;      // Block type
    bool     is_tested;         // Has been retested
    int      test_count;        // Number of retests
    datetime last_test_time;    // Last retest time
    bool     is_valid;          // Current validity status
    bool     is_mitigated;      // Has been mitigated
    double   mitigation_price;  // Price where mitigated
    datetime mitigation_time;   // When mitigated
    int      bar_index;         // Formation bar index
    
    void Reset()
    {
        formation_time = 0;
        high_price = 0.0;
        low_price = 0.0;
        impulse_start = 0.0;
        impulse_end = 0.0;
        impulse_volume = 0.0;
        impulse_candles = 0;
        strength = 0;
        type = OB_NONE;
        is_tested = false;
        test_count = 0;
        last_test_time = 0;
        is_valid = false;
        is_mitigated = false;
        mitigation_price = 0.0;
        mitigation_time = 0;
        bar_index = -1;
    }
    
    bool IsActive()
    {
        return is_valid && !is_mitigated;
    }
    
    bool IsBullish()
    {
        return (type == OB_BULLISH || type == OB_BREAKER_BULLISH);
    }
    
    bool IsBearish()
    {
        return (type == OB_BEARISH || type == OB_BREAKER_BEARISH);
    }
    
    double GetMidPrice()
    {
        return (high_price + low_price) / 2.0;
    }
};

// Fair Value Gap structure
struct FairValueGap
{
    datetime creation_time;     // Gap formation time
    double   gap_high;          // Upper boundary
    double   gap_low;           // Lower boundary
    double   gap_size;          // Size in points
    FVG_TYPE type;              // Gap type
    double   fill_percentage;   // How much has been filled (0-100)
    bool     is_filled;         // Completely filled status
    bool     is_partially_filled; // Partially filled status
    datetime fill_time;         // When completely filled
    int      priority;          // Gap priority (1-5)
    bool     is_active;         // Currently active
    double   creation_volume;   // Volume when created
    int      bar_index;         // Creation bar index
    double   expected_fill_price; // Expected fill target
    
    void Reset()
    {
        creation_time = 0;
        gap_high = 0.0;
        gap_low = 0.0;
        gap_size = 0.0;
        type = FVG_NONE;
        fill_percentage = 0.0;
        is_filled = false;
        is_partially_filled = false;
        fill_time = 0;
        priority = 0;
        is_active = false;
        creation_volume = 0.0;
        bar_index = -1;
        expected_fill_price = 0.0;
    }
    
    bool IsBullish()
    {
        return type == FVG_BULLISH;
    }
    
    bool IsBearish()
    {
        return type == FVG_BEARISH;
    }
    
    double GetMidPrice()
    {
        return (gap_high + gap_low) / 2.0;
    }
};

// Market Structure Point (BOS/CHOCH)
struct MarketStructurePoint
{
    datetime time;
    double   price;
    int      bar_index;
    SMC_SIGNAL_TYPE type; // BOS_BULLISH, BOS_BEARISH, CHOCH_BULLISH, CHOCH_BEARISH
    int      strength; // Strength of the break
    
    void Reset()
    {
        time = 0;
        price = 0.0;
        bar_index = -1;
        type = SIGNAL_NONE;
        strength = 0;
    }
};

// Support/Resistance Level
struct SR_Level
{
    double   price_high;
    double   price_low;
    SR_LEVEL_TYPE type;
    int      strength; // Number of touches, etc.
    datetime first_touch_time;
    datetime last_touch_time;
    bool     is_active;
    bool     is_broken;
    
    void Reset()
    {
        price_high = 0.0;
        price_low = 0.0;
        type = SR_NONE;
        strength = 0;
        first_touch_time = 0;
        last_touch_time = 0;
        is_active = false;
        is_broken = false;
    }
    
    double GetMidPrice()
    {
        return (price_high + price_low) / 2.0;
    }
};

//+------------------------------------------------------------------+
//| Array Structures for Management                                  |
//+------------------------------------------------------------------+
#define DYNAMIC_ARRAY_INCREMENT 10

// Dynamic Array for Order Blocks
class OrderBlockArray
{
private:
    OrderBlock m_blocks[];
    int        m_total_blocks;
    int        m_array_size;

public:
    void OrderBlockArray() { m_total_blocks = 0; m_array_size = 0; }
    
    void Initialize(int initial_size = DYNAMIC_ARRAY_INCREMENT)
    {
        ArrayResize(m_blocks, initial_size);
        m_array_size = initial_size;
        m_total_blocks = 0;
    }
    
    void Clear()
    {
        m_total_blocks = 0;
    }
    
    int Total() const { return m_total_blocks; }
    
    bool Add(const OrderBlock &block)
    {
        if(m_total_blocks >= m_array_size)
        {
            int new_size = m_array_size + DYNAMIC_ARRAY_INCREMENT;
            if(ArrayResize(m_blocks, new_size) != new_size)
                return false;
            m_array_size = new_size;
        }
        m_blocks[m_total_blocks] = block;
        m_total_blocks++;
        return true;
    }
    
    OrderBlock* At(int index)
    {
        if(index < 0 || index >= m_total_blocks)
            return NULL;
        return &m_blocks[index];
    }
    
    void Delete(int index)
    {
        if(index < 0 || index >= m_total_blocks)
            return;
            
        for(int i = index; i < m_total_blocks - 1; i++)
        {
            m_blocks[i] = m_blocks[i+1];
        }
        m_total_blocks--;
    }
};

// Dynamic Array for Fair Value Gaps
class FVGArray
{
private:
    FairValueGap m_gaps[];
    int          m_total_gaps;
    int          m_array_size;

public:
    void FVGArray() { m_total_gaps = 0; m_array_size = 0; }
    
    void Initialize(int initial_size = DYNAMIC_ARRAY_INCREMENT)
    {
        ArrayResize(m_gaps, initial_size);
        m_array_size = initial_size;
        m_total_gaps = 0;
    }
    
    void Clear()
    {
        m_total_gaps = 0;
    }
    
    int Total() const { return m_total_gaps; }
    
    bool Add(const FairValueGap &gap)
    {
        if(m_total_gaps >= m_array_size)
        {
            int new_size = m_array_size + DYNAMIC_ARRAY_INCREMENT;
            if(ArrayResize(m_gaps, new_size) != new_size)
                return false;
            m_array_size = new_size;
        }
        m_gaps[m_total_gaps] = gap;
        m_total_gaps++;
        return true;
    }
    
    FairValueGap* At(int index)
    {
        if(index < 0 || index >= m_total_gaps)
            return NULL;
        return &m_gaps[index];
    }
    
    void Delete(int index)
    {
        if(index < 0 || index >= m_total_gaps)
            return;
            
        for(int i = index; i < m_total_gaps - 1; i++)
        {
            m_gaps[i] = m_gaps[i+1];
        }
        m_total_gaps--;
    }
};

//+------------------------------------------------------------------+
//| Configuration Structures                                         |
//+------------------------------------------------------------------+

// Configuration for Order Block detection
struct OrderBlockConfig
{
    int lookback_period;        // How many bars to scan
    int min_impulse_pips;       // Minimum impulse move size in pips
    int max_impulse_candles;    // Max candles for an impulse move
    double volume_threshold;    // Volume must be X times average
    bool use_breaker_logic;     // Detect breaker blocks
    
    void SetDefaults()
    {
        lookback_period = 200;
        min_impulse_pips = 15;
        max_impulse_candles = 5;
        volume_threshold = 1.5;
        use_breaker_logic = true;
    }
};

// Configuration for Fair Value Gap detection
struct FVGConfig
{
    int min_gap_pips;           // Minimum gap size in pips
    bool require_volume;        // Require high volume on gap candle
    double volume_multiplier;   // Volume multiplier for validation
    bool auto_fill_gaps;        // Automatically detect when gaps are filled
    
    void SetDefaults()
    {
        min_gap_pips = 2;
        require_volume = true;
        volume_multiplier = 1.2;
        auto_fill_gaps = true;
    }
};

// Configuration for Market Structure detection
struct MarketStructureConfig
{
    int swing_strength;         // Strength for swing point detection
    bool detect_bos;            // Detect Break of Structure
    bool detect_choch;          // Detect Change of Character
    
    void SetDefaults()
    {
        swing_strength = 10;
        detect_bos = true;
        detect_choch = true;
    }
};

// Configuration for S/R detection
struct SR_Config
{
    int lookback_period;        // How many bars to scan
    int min_touches;            // Minimum touches to form a level
    int proximity_pips;         // How close touches need to be
    bool detect_flips;          // Detect S/R flips
    
    void SetDefaults()
    {
        lookback_period = 500;
        min_touches = 2;
        proximity_pips = 10;
        detect_flips = true;
    }
};