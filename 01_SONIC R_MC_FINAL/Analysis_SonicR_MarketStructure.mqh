//+------------------------------------------------------------------+
//|                                    Analysis_SonicR_MarketStructure.mqh |
//|                            Sonic R Market Structure Analysis            |
//|                     Based on Sonic R System Documentation               |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_SONICR_MARKETSTRUCTURE_MQH
#define ANALYSIS_SONICR_MARKETSTRUCTURE_MQH

#include "Core_Defines.mqh"
#include "SMC_Structures.mqh"

//+------------------------------------------------------------------+
//| Market Structure States                                          |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_STATE {
    STRUCTURE_UNDEFINED = 0,
    STRUCTURE_UPTREND,          // Higher Highs, Higher Lows
    STRUCTURE_DOWNTREND,        // Lower Highs, Lower Lows  
    STRUCTURE_RANGING,          // Sideways movement
    STRUCTURE_TRANSITIONAL      // Changing structure
};

enum ENUM_STRUCTURE_BREAK_TYPE {
    BREAK_NONE = 0,
    BREAK_BULLISH,              // Break of previous high
    BREAK_BEARISH,              // Break of previous low
    BREAK_FALSE                 // False breakout
};

//+------------------------------------------------------------------+
//| Structure Point Definition                                       |
//+------------------------------------------------------------------+
struct SStructurePoint {
    datetime time;
    double price;
    bool isHigh;
    double strength;
    bool isConfirmed;
    bool isBroken;
    datetime breakTime;
};

//+------------------------------------------------------------------+
//| Sonic R Market Structure Analyzer                              |
//+------------------------------------------------------------------+
class CSonicRMarketStructure {
private:
    // Configuration
    int m_swingStrength;
    int m_lookbackPeriods;
    double m_minStrengthThreshold;
    
    // Structure tracking
    SStructurePoint m_structurePoints[];
    ENUM_MARKET_STRUCTURE_STATE m_currentState;
    ENUM_STRUCTURE_BREAK_TYPE m_lastBreakType;
    
    // Analysis buffers
    double m_highs[];
    double m_lows[];
    datetime m_times[];
    
public:
    CSonicRMarketStructure();
    ~CSonicRMarketStructure();
    
    // Initialization
    bool Initialize(int swingStrength = 5, int lookback = 100);
    void Deinitialize();
    
    // Main analysis functions
    bool AnalyzeMarketStructure();
    bool UpdateStructurePoints();
    bool DetectStructureBreaks();
    
    // Structure identification
    bool IsSwingHigh(int shift);
    bool IsSwingLow(int shift);
    double CalculateSwingStrength(int shift, bool isHigh);
    
    // State analysis
    ENUM_MARKET_STRUCTURE_STATE DetermineMarketState();
    bool IsStructureBreak(double currentPrice, ENUM_SIGNAL_DIRECTION direction);
    
    // Trend confirmation for Sonic R
    bool IsTrendConfirmed(ENUM_SIGNAL_DIRECTION direction);
    bool IsStructureSupporting(ENUM_SIGNAL_DIRECTION direction);
    
    // Getters
    ENUM_MARKET_STRUCTURE_STATE GetCurrentState() const { return m_currentState; }
    ENUM_STRUCTURE_BREAK_TYPE GetLastBreakType() const { return m_lastBreakType; }
    SStructurePoint GetLastStructurePoint();
    
    // Utility
    string GetStateString() const;
    void LogStructureAnalysis() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSonicRMarketStructure::CSonicRMarketStructure() {
    m_swingStrength = 5;
    m_lookbackPeriods = 100;
    m_minStrengthThreshold = 0.5;
    m_currentState = STRUCTURE_UNDEFINED;
    m_lastBreakType = BREAK_NONE;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSonicRMarketStructure::~CSonicRMarketStructure() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Market Structure Analysis                             |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::Initialize(int swingStrength = 5, int lookback = 100) {
    m_swingStrength = swingStrength;
    m_lookbackPeriods = lookback;
    
    // Resize arrays
    ArrayResize(m_structurePoints, 0);
    ArrayResize(m_highs, lookback);
    ArrayResize(m_lows, lookback);
    ArrayResize(m_times, lookback);
    
    APEX_LOG_INFO("Market Structure analyzer initialized - Swing: " + IntegerToString(swingStrength));
    return true;
}

//+------------------------------------------------------------------+
//| Analyze Market Structure - Main Function                        |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::AnalyzeMarketStructure() {
    if (!UpdateStructurePoints()) {
        return false;
    }
    
    if (!DetectStructureBreaks()) {
        return false;
    }
    
    m_currentState = DetermineMarketState();
    return true;
}

//+------------------------------------------------------------------+
//| Update Structure Points                                          |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::UpdateStructurePoints() {
    for (int i = m_swingStrength; i < m_lookbackPeriods - m_swingStrength; i++) {
        // Check for swing high
        if (IsSwingHigh(i)) {
            SStructurePoint point;
            point.time = iTime(_Symbol, PERIOD_CURRENT, i);
            point.price = iHigh(_Symbol, PERIOD_CURRENT, i);
            point.isHigh = true;
            point.strength = CalculateSwingStrength(i, true);
            point.isConfirmed = true;
            point.isBroken = false;
            
            if (point.strength >= m_minStrengthThreshold) {
                int size = ArraySize(m_structurePoints);
                ArrayResize(m_structurePoints, size + 1);
                m_structurePoints[size] = point;
            }
        }
        
        // Check for swing low
        if (IsSwingLow(i)) {
            SStructurePoint point;
            point.time = iTime(_Symbol, PERIOD_CURRENT, i);
            point.price = iLow(_Symbol, PERIOD_CURRENT, i);
            point.isHigh = false;
            point.strength = CalculateSwingStrength(i, false);
            point.isConfirmed = true;
            point.isBroken = false;
            
            if (point.strength >= m_minStrengthThreshold) {
                int size = ArraySize(m_structurePoints);
                ArrayResize(m_structurePoints, size + 1);
                m_structurePoints[size] = point;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if bar is swing high                                      |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::IsSwingHigh(int shift) {
    double centerHigh = iHigh(_Symbol, PERIOD_CURRENT, shift);
    
    // Check left side
    for (int i = 1; i <= m_swingStrength; i++) {
        if (iHigh(_Symbol, PERIOD_CURRENT, shift + i) >= centerHigh) {
            return false;
        }
    }
    
    // Check right side
    for (int i = 1; i <= m_swingStrength; i++) {
        if (iHigh(_Symbol, PERIOD_CURRENT, shift - i) >= centerHigh) {
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if bar is swing low                                       |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::IsSwingLow(int shift) {
    double centerLow = iLow(_Symbol, PERIOD_CURRENT, shift);
    
    // Check left side
    for (int i = 1; i <= m_swingStrength; i++) {
        if (iLow(_Symbol, PERIOD_CURRENT, shift + i) <= centerLow) {
            return false;
        }
    }
    
    // Check right side
    for (int i = 1; i <= m_swingStrength; i++) {
        if (iLow(_Symbol, PERIOD_CURRENT, shift - i) <= centerLow) {
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate swing strength                                         |
//+------------------------------------------------------------------+
double CSonicRMarketStructure::CalculateSwingStrength(int shift, bool isHigh) {
    double strength = 0.0;
    double referencePrice = isHigh ? iHigh(_Symbol, PERIOD_CURRENT, shift) : 
                                   iLow(_Symbol, PERIOD_CURRENT, shift);
    
    // Calculate based on price difference and volume
    double avgPrice = 0.0;
    for (int i = 1; i <= m_swingStrength; i++) {
        avgPrice += (iHigh(_Symbol, PERIOD_CURRENT, shift + i) + 
                    iLow(_Symbol, PERIOD_CURRENT, shift + i)) / 2.0;
        avgPrice += (iHigh(_Symbol, PERIOD_CURRENT, shift - i) + 
                    iLow(_Symbol, PERIOD_CURRENT, shift - i)) / 2.0;
    }
    avgPrice /= (m_swingStrength * 2);
    
    strength = MathAbs(referencePrice - avgPrice) / (avgPrice * 0.01); // Normalize to percentage
    
    return MathMin(strength, 1.0); // Cap at 1.0
}

//+------------------------------------------------------------------+
//| Determine Market State                                           |
//+------------------------------------------------------------------+
ENUM_MARKET_STRUCTURE_STATE CSonicRMarketStructure::DetermineMarketState() {
    int pointsCount = ArraySize(m_structurePoints);
    if (pointsCount < 4) {
        return STRUCTURE_UNDEFINED;
    }
    
    // Analyze last 4 structure points for trend
    bool higherHighs = true, higherLows = true;
    bool lowerHighs = true, lowerLows = true;
    
    for (int i = pointsCount - 3; i < pointsCount; i++) {
        if (i <= 0) continue;
        
        SStructurePoint current = m_structurePoints[i];
        SStructurePoint previous = m_structurePoints[i-1];
        
        if (current.isHigh == previous.isHigh) {
            if (current.isHigh) {
                // Comparing highs
                if (current.price <= previous.price) higherHighs = false;
                if (current.price >= previous.price) lowerHighs = false;
            } else {
                // Comparing lows
                if (current.price <= previous.price) higherLows = false;
                if (current.price >= previous.price) lowerLows = false;
            }
        }
    }
    
    if (higherHighs && higherLows) {
        return STRUCTURE_UPTREND;
    } else if (lowerHighs && lowerLows) {
        return STRUCTURE_DOWNTREND;
    } else {
        return STRUCTURE_RANGING;
    }
}

//+------------------------------------------------------------------+
//| Check if trend is confirmed for Sonic R                         |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::IsTrendConfirmed(ENUM_SIGNAL_DIRECTION direction) {
    if (direction == SIGNAL_DIRECTION_BUY) {
        return (m_currentState == STRUCTURE_UPTREND);
    } else if (direction == SIGNAL_DIRECTION_SELL) {
        return (m_currentState == STRUCTURE_DOWNTREND);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check if structure supports signal direction                    |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::IsStructureSupporting(ENUM_SIGNAL_DIRECTION direction) {
    if (m_currentState == STRUCTURE_RANGING) {
        return false; // No clear structure in ranging market
    }
    
    return IsTrendConfirmed(direction);
}

//+------------------------------------------------------------------+
//| Get state as string                                              |
//+------------------------------------------------------------------+
string CSonicRMarketStructure::GetStateString() const {
    switch(m_currentState) {
        case STRUCTURE_UPTREND: return "UPTREND";
        case STRUCTURE_DOWNTREND: return "DOWNTREND";
        case STRUCTURE_RANGING: return "RANGING";
        case STRUCTURE_TRANSITIONAL: return "TRANSITIONAL";
        default: return "UNDEFINED";
    }
}

//+------------------------------------------------------------------+
//| Detect Structure Breaks                                         |
//+------------------------------------------------------------------+
bool CSonicRMarketStructure::DetectStructureBreaks() {
    double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
    int pointsCount = ArraySize(m_structurePoints);
    
    if (pointsCount < 2) return false;
    
    // Check recent structure points for breaks
    for (int i = pointsCount - 1; i >= MathMax(0, pointsCount - 5); i--) {
        SStructurePoint &point = m_structurePoints[i];
        
        if (!point.isBroken) {
            if (point.isHigh && currentPrice > point.price) {
                point.isBroken = true;
                point.breakTime = TimeCurrent();
                m_lastBreakType = BREAK_BULLISH;
                APEX_LOG_INFO("Bullish structure break at " + DoubleToStr(point.price, _Digits));
            } else if (!point.isHigh && currentPrice < point.price) {
                point.isBroken = true;
                point.breakTime = TimeCurrent();
                m_lastBreakType = BREAK_BEARISH;
                APEX_LOG_INFO("Bearish structure break at " + DoubleToStr(point.price, _Digits));
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Log structure analysis                                          |
//+------------------------------------------------------------------+
void CSonicRMarketStructure::LogStructureAnalysis() const {
    string message = "Market Structure: " + GetStateString() + 
                    " | Points: " + IntegerToString(ArraySize(m_structurePoints)) +
                    " | Last Break: " + IntegerToString(m_lastBreakType);
    
    APEX_LOG_DEBUG(message);
}

#endif // ANALYSIS_SONICR_MARKETSTRUCTURE_MQH 