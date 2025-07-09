//+------------------------------------------------------------------+
//|                                                  SMC_Config.mqh |
//|                                     Sonic R EA - Market Analysis |
//|                                     Smart Money Concepts Configs |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Configuration Structures                                         |
//+------------------------------------------------------------------+

// Configuration for Market Structure detection
struct MSConfig
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

// Configuration for Order Block detection
struct OBConfig
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

// Configuration for S/R detection
struct SRConfig
{
    int lookback_period;        // How many bars to scan
    int min_touches;            // Minimum touches to form a level
    double touch_tolerance_pips; // How close touches need to be
    bool detect_flips;          // Detect S/R flips
    double min_strength;        // Minimum strength to be considered a valid level

    void SetDefaults()
    {
        lookback_period = 500;
        min_touches = 2;
        touch_tolerance_pips = 5;
        detect_flips = true;
        min_strength = 0.3;
    }
};