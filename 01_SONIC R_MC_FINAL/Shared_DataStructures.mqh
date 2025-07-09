//+------------------------------------------------------------------+
//|                                     Shared_DataStructures.mqh |
//|                          Copyright 2024, Cáo Già & Đại Bàng    |
//|                      Centralized Data Structures for APEX EA   |
//+------------------------------------------------------------------+
#ifndef SHARED_DATA_STRUCTURES_MQH
#define SHARED_DATA_STRUCTURES_MQH

// INCLUDE ENUMS FIRST
#include "SonicR_Enums.mqh"

//+------------------------------------------------------------------+
//| Wave Pattern Analysis Structures (used by CSonicRWavePattern)    |
//+------------------------------------------------------------------+

// --- Structures for Wave Analysis ---
struct SWavePoint
{
    datetime time;              // Wave point time
    double   price;             // Wave point price
    int      barIndex;          // Bar index
    bool     isHigh;            // Is swing high
    bool     isLow;             // Is swing low
    double   strength;          // Point strength (0.0-1.0)
};

struct SWaveInfo
{
    ApexSonicR::ENUM_WAVE_TYPE   type;          // Wave type
    ApexSonicR::ENUM_WAVE_DEGREE degree;        // Wave degree
    SWavePoint       startPoint;    // Wave start
    SWavePoint       endPoint;      // Wave end
    double           length;        // Wave length in pips
    double           duration;      // Wave duration in minutes
    double           strength;      // Wave strength (0.0-1.0)
    double           fibRatio;      // Fibonacci ratio
    bool             isComplete;    // Wave completion status
    string           description;   // Wave description
};

struct SWavePattern
{
    SWaveInfo        waves[13];     // Up to 13 waves (8 impulse + 5 correction)
    int              waveCount;     // Number of identified waves
    ApexSonicR::ENUM_WAVE_TYPE   currentWave;   // Current active wave
    double           patternStrength; // Overall pattern strength
    bool             isImpulsePattern; // Is impulse pattern
    bool             isCorrectionPattern; // Is correction pattern
    datetime         patternStart;   // Pattern start time
    datetime         lastUpdate;    // Last update time
};

//+------------------------------------------------------------------+
//| Sonic R Unified Signal Structure                                 |
//+------------------------------------------------------------------+
struct SSonicRUnifiedSignal
{
    datetime         timestamp;         // Signal generation time
    ApexSonicR::ENUM_SIGNAL_TYPE signalType;        // SIGNAL_TYPE_BUY, SIGNAL_TYPE_SELL, SIGNAL_TYPE_NONE
    double           confidenceScore;   // 0-100 score based on confluence
    string           reason;            // Detailed reason for the signal
    bool             isValid;           // Is the signal valid based on threshold

    void Reset()
    {
        timestamp = 0;
        signalType = ApexSonicR::SIGNAL_TYPE_NONE;
        confidenceScore = 0.0;
        reason = "";
        isValid = false;
    }
};

//+------------------------------------------------------------------+
//| Signal Information Structure (used by CSignalEngine)             |
//+------------------------------------------------------------------+
struct SSignalInfo
{
    long           magicNumber;
    ApexSonicR::ENUM_SIGNAL_TYPE signalType;       // Use proper enum type
    double         entryPrice;
    double         stopLoss;
    double         takeProfit;
    string         symbol;
    ApexSonicR::ENUM_TIMEFRAMES timeframe;
    double         confidenceScore; // 0.0 to 1.0
    string         strategySource; // e.g., "SonicR_Classic", "Pullback_v1"
    string         comment;
};

//+------------------------------------------------------------------+
//| Dragon Band Information Structure                                 |
//+------------------------------------------------------------------+
struct SDragonBandInfo
{
    double upper;           // Upper band value
    double middle;          // Middle line value
    double lower;           // Lower band value
    double trend;           // Trend direction (-1, 0, 1)
    double strength;        // Band strength (0.0-1.0)
    datetime timestamp;     // Last update time
    bool isValid;           // Is data valid
    
    void Reset()
    {
        upper = 0.0;
        middle = 0.0;
        lower = 0.0;
        trend = 0.0;
        strength = 0.0;
        timestamp = 0;
        isValid = false;
    }
};

#endif // SHARED_DATA_STRUCTURES_MQH