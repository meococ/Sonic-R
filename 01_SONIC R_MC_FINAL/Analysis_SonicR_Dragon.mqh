//+------------------------------------------------------------------+
//|                  Analysis_SonicR_Dragon.mqh                      |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef ANALYSIS_SONICR_DRAGON_MQH
#define ANALYSIS_SONICR_DRAGON_MQH

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"

// Namespace has been removed.

//+------------------------------------------------------------------+
//| CSonicRDragon - Enhanced Sonic R Dragon Analysis Engine         |
//| Multi-timeframe Dragon Band Analysis with Adaptive Algorithms   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| SDragonContext - Context for Dragon Analysis                     |
//+------------------------------------------------------------------+
struct SDragonContext
{
    // Indicator Buffers
    double              dragonUpper[];
    double              dragonMiddle[];
    double              dragonLower[];
    double              trendLine[];

    // State Analysis
    bool                isDragonSqueeze;        // Dragon bands converging
    bool                isDragonBreakout;       // Price breaking Dragon bands
    double              dragonWidth;            // Current Dragon band width
    double              avgDragonWidth;         // Average Dragon width

    // Angle Analysis
    double              currentAngle;           // Current Dragon angle
    double              smoothedAngle;          // Smoothed angle for stability
    double              angleStrength;          // Angle strength (0.0-1.0)
};

//+------------------------------------------------------------------+
//| CSonicRDragon - Enhanced Sonic R Dragon Analysis Engine         |
//| Multi-timeframe Dragon Analysis with Adaptive Algorithms   |
//+------------------------------------------------------------------+
class CSonicRDragon
{
private:
    // Core Members
    bool                m_initialized;
    int                 m_dragonHandle;
    string              m_symbol;
    ENUM_TIMEFRAMES     m_timeframe;
    CLogger*            m_pLogger;
    int                 m_handle;                 // Legacy handle reference

    // Configuration
    int                 m_dragonPeriod;
    int                 m_trendPeriod;
    double              m_adaptiveAngleFactor;    // ATR-based angle adjustment
    int                 m_atrPeriod;              // ATR period for volatility

    // Multi-timeframe Analysis
    ENUM_TIMEFRAMES     m_higherTimeframe;        // Higher TF for trend confirmation
    int                 m_higherTfHandle;         // Higher TF Dragon handle

    // Analysis Context
    SDragonContext      m_context;

public:
    //--- Constructor / Destructor
    CSonicRDragon();
    ~CSonicRDragon();

    //--- Enhanced Initialization
    bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, int dragonPeriod, int trendPeriod, CLogger* pLogger);
    bool              InitializeMultiTimeframe(ENUM_TIMEFRAMES higherTf);
    void              Deinitialize();

    //--- Enhanced Dragon Data Access
    bool              GetDragonValues(const int shift, double &upper, double &middle, double &lower);
    bool              GetTrendValue(const int shift, double &trend);
    double            GetDragonUpper(int index = 0);
    double            GetDragonMiddle(int index = 0);
    double            GetDragonLower(int index = 0);
    
    //--- Advanced Dragon Analysis
    double            CalculateAdaptiveDragonAngle(int lookback = 5);
    double            CalculateDragonWidth(int index = 0);
    bool              DetectDragonSqueeze(int lookback = 10);
    bool              DetectDragonBreakout(int index = 0);
    double            GetDragonStrength(int index = 0);
    
    //--- Multi-timeframe Analysis
    bool              IsHigherTimeframeBullish();
    bool              IsHigherTimeframeBearish();
    double            GetHigherTfTrend();
    
    //--- Dragon State Getters
    bool              IsDragonSqueeze() const { return m_isDragonSqueeze; }
    bool              IsDragonBreakout() const { return m_isDragonBreakout; }
    double            GetCurrentAngle() const { return m_currentAngle; }
    double            GetSmoothedAngle() const { return m_smoothedAngle; }
    double            GetAngleStrength() const { return m_context.angleStrength; }
    double            GetDragonWidth() const { return m_context.dragonWidth; }
    SDragonContext*   GetContext() { return &m_context; }
    
    //--- Configuration
    void              SetAdaptiveAngleFactor(double factor) { m_adaptiveAngleFactor = factor; }
    void              SetATRPeriod(int period) { m_atrPeriod = period; }
    
    //--- Legacy compatibility
    double            CalculateDragonAngle(const int lookback = 5) { return CalculateAdaptiveDragonAngle(lookback); }
    double            GetDragonHigh(int index = 0) { return GetDragonUpper(index); }
    double            GetDragonLow(int index = 0) { return GetDragonLower(index); }
    double            GetTrendLine(int index = 0) { double trend; GetTrendValue(index, trend); return trend; }

private:
    //--- Phương thức nội bộ
    bool              CreateIndicator();
};

//+------------------------------------------------------------------+
//| Implementation                                                   |
//+------------------------------------------------------------------+
CSonicRDragon::CSonicRDragon() :
    m_initialized(false),
    m_dragonHandle(INVALID_HANDLE),
    m_symbol(""),
    m_timeframe(PERIOD_CURRENT),
    m_dragonPeriod(34),
    m_trendPeriod(89),
    m_adaptiveAngleFactor(1.0),
    m_atrPeriod(14),
    m_higherTimeframe(PERIOD_H1),
    m_higherTfHandle(INVALID_HANDLE),
    
    m_pLogger(NULL),
    m_handle(INVALID_HANDLE)
{
        // Initialize context
    ZeroMemory(m_context);

    // Initialize arrays within the context
    ArraySetAsSeries(m_context.dragonUpper, true);
    ArraySetAsSeries(m_context.dragonMiddle, true);
    ArraySetAsSeries(m_context.dragonLower, true);
    ArraySetAsSeries(m_context.trendLine, true);
}

CSonicRDragon::~CSonicRDragon()
{
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Enhanced Sonic R Dragon Initialization                          |
//+------------------------------------------------------------------+
bool CSonicRDragon::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, int dragonPeriod, int trendPeriod, CLogger* pLogger)
{
    m_symbol = symbol;
    m_timeframe = timeframe;
    m_dragonPeriod = dragonPeriod;
    m_trendPeriod = trendPeriod;
    m_pLogger = pLogger;
    
    // Create main Dragon indicator handle
    m_dragonHandle = iCustom(m_symbol, m_timeframe, "Indicator_SonicR_Dragon", m_dragonPeriod, m_trendPeriod);
    m_handle = m_dragonHandle; // Legacy compatibility
    
    if (m_dragonHandle == INVALID_HANDLE)
    {
        if (m_pLogger != NULL)
            m_pLogger->Log(LOG_LEVEL_ERROR, "Failed to create Enhanced Sonic R Dragon indicator handle");
        return false;
    }
    
    // Initialize higher timeframe analysis
    if (m_timeframe < PERIOD_H1)
        m_higherTimeframe = PERIOD_H1;
    else if (m_timeframe < PERIOD_D1)
        m_higherTimeframe = PERIOD_D1;
    else
        m_higherTimeframe = PERIOD_W1;
    
    InitializeMultiTimeframe(m_higherTimeframe);
    
    m_initialized = true;
    
    if (m_pLogger != NULL)
        m_pLogger->Log(LOG_LEVEL_INFO, "Enhanced Sonic R Dragon initialized successfully with multi-timeframe support");
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize Multi-timeframe Analysis                             |
//+------------------------------------------------------------------+
bool CSonicRDragon::InitializeMultiTimeframe(ENUM_TIMEFRAMES higherTf)
{
    m_higherTimeframe = higherTf;
    
    // Create higher timeframe Dragon handle
    m_higherTfHandle = iCustom(m_symbol, m_higherTimeframe, "Indicator_SonicR_Dragon", m_dragonPeriod, m_trendPeriod);
    
    if (m_higherTfHandle == INVALID_HANDLE)
    {
        if (m_pLogger != NULL)
            m_pLogger->Log(LOG_LEVEL_WARN, "Failed to create higher timeframe Dragon handle - continuing without MTF analysis");
        return false;
    }
    
    if (m_pLogger != NULL)
        m_pLogger->Log(LOG_LEVEL_INFO, StringFormat("Multi-timeframe Dragon analysis initialized for %s", EnumToString(higherTf)));
    
    return true;
}

void CSonicRDragon::Deinitialize()
{
    if (m_dragonHandle != INVALID_HANDLE)
    {
        IndicatorRelease(m_dragonHandle);
        m_dragonHandle = INVALID_HANDLE;
    }
    
    if (m_higherTfHandle != INVALID_HANDLE)
    {
        IndicatorRelease(m_higherTfHandle);
        m_higherTfHandle = INVALID_HANDLE;
    }
    
    m_handle = INVALID_HANDLE; // Legacy compatibility
    m_initialized = false;

    // Reset context
    ZeroMemory(m_context);
}

bool CSonicRDragon::CreateIndicator()
{
    // Tên file chỉ báo tùy chỉnh (sẽ được tạo ở bước tiếp theo)
    string indicator_path = "Indicator_SonicR_Dragon";

    m_handle = iCustom(m_symbol, m_timeframe, indicator_path, m_dragonPeriod, m_trendPeriod);

    return (m_handle != INVALID_HANDLE);
}

bool CSonicRDragon::GetDragonValues(const int shift, double &upper, double &middle, double &lower)
{
    if (m_handle == INVALID_HANDLE) return false;

    double bufferUpper[1], bufferMiddle[1], bufferLower[1];

    // Copy data từ các buffer của chỉ báo
    // Buffer 0: Dragon Upper, Buffer 1: Dragon Middle, Buffer 2: Dragon Lower
    if (CopyBuffer(m_handle, 0, shift, 1, bufferUpper) <= 0 ||
        CopyBuffer(m_handle, 1, shift, 1, bufferMiddle) <= 0 ||
        CopyBuffer(m_handle, 2, shift, 1, bufferLower) <= 0)
    {
        return false;
    }

    upper = bufferUpper[0];
    middle = bufferMiddle[0];
    lower = bufferLower[0];

    return true;
}

bool CSonicRDragon::GetTrendValue(const int shift, double &trend)
{
    if (m_dragonHandle == INVALID_HANDLE) return false;

    double bufferTrend[1];

    // Buffer 3: Trend Line
    if (CopyBuffer(m_dragonHandle, 3, shift, 1, bufferTrend) <= 0)
    {
        return false;
    }

    trend = bufferTrend[0];
    return true;
}

//+------------------------------------------------------------------+
//| Enhanced Adaptive Dragon Angle Calculation                      |
//+------------------------------------------------------------------+
double CSonicRDragon::CalculateAdaptiveDragonAngle(int lookback)
{
    if (m_dragonHandle == INVALID_HANDLE || !m_initialized)
        return 0.0;
    
    // Copy Dragon Middle buffer
    if (CopyBuffer(m_dragonHandle, 1, 0, lookback + 1, m_dragonMiddle) <= 0)
        return 0.0;
    
    // Get ATR for volatility adjustment
    int atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
    double atrValues[];
    ArraySetAsSeries(atrValues, true);
    
    if (atrHandle != INVALID_HANDLE && CopyBuffer(atrHandle, 0, 0, 1, atrValues) > 0)
    {
        double currentATR = atrValues[0];
        double avgPrice = (iHigh(m_symbol, m_timeframe, 0) + iLow(m_symbol, m_timeframe, 0)) / 2.0;
        
        if (avgPrice > 0)
            m_adaptiveAngleFactor = 1.0 + (currentATR / avgPrice) * 10.0; // Volatility adjustment
        
        IndicatorRelease(atrHandle);
    }
    
    // Calculate slope with adaptive factor
    double currentValue = m_context.dragonMiddle[0];
    double pastValue = m_context.dragonMiddle[lookback];
    
    if (pastValue == 0.0)
        return 0.0;
    
    // Enhanced slope calculation
    double slope = (currentValue - pastValue) / lookback;
    double adaptiveSlope = slope * m_adaptiveAngleFactor;
    
    // Calculate angle in degrees
    double angle = MathArctan(adaptiveSlope) * 180.0 / M_PI;
    
    // Smooth the angle for stability
    m_context.currentAngle = angle;
    m_context.smoothedAngle = (m_context.smoothedAngle * 0.7) + (angle * 0.3); // EMA smoothing
    
    // Calculate angle strength (0.0-1.0)
    m_context.angleStrength = MathMin(MathAbs(angle) / 45.0, 1.0); // Normalize to 45 degrees
    
    return m_context.smoothedAngle;
}

//+------------------------------------------------------------------+
//| Calculate Dragon Band Width                                     |
//+------------------------------------------------------------------+
double CSonicRDragon::CalculateDragonWidth(int index)
{
    if (m_dragonHandle == INVALID_HANDLE || !m_initialized)
        return 0.0;
    
    // Copy Dragon buffers
    if (CopyBuffer(m_dragonHandle, 0, index, 1, m_context.dragonUpper) <= 0 ||
        CopyBuffer(m_dragonHandle, 2, index, 1, m_context.dragonLower) <= 0)
        return 0.0;
    
    double width = m_context.dragonUpper[0] - m_context.dragonLower[0];
    
    if (index == 0)
    {
        m_context.dragonWidth = width;
        
        // Update average width (simple moving average)
        static double widthHistory[20];
        static int widthIndex = 0;
        
        widthHistory[widthIndex % 20] = width;
        widthIndex++;
        
        double totalWidth = 0.0;
        int count = MathMin(widthIndex, 20);
        for (int i = 0; i < count; i++)
            totalWidth += widthHistory[i];
        
        m_context.avgDragonWidth = totalWidth / count;
    }
    
    return width;
}

//+------------------------------------------------------------------+
//| Detect Dragon Squeeze (Bands Converging)                       |
//+------------------------------------------------------------------+
bool CSonicRDragon::DetectDragonSqueeze(int lookback)
{
    if (m_dragonHandle == INVALID_HANDLE || !m_initialized)
        return false;
    
    // Calculate current and historical widths
    double currentWidth = CalculateDragonWidth(0);
    double pastWidth = CalculateDragonWidth(lookback);
    
    if (currentWidth <= 0.0 || pastWidth <= 0.0)
        return false;
    
    // Check if bands are converging
    double widthRatio = currentWidth / pastWidth;
    bool isConverging = widthRatio < 0.8; // 20% reduction in width
    
    // Check if current width is below average
    bool isBelowAverage = currentWidth < (m_context.avgDragonWidth * 0.7);
    
    m_context.isDragonSqueeze = isConverging && isBelowAverage;
    
    if (m_context.isDragonSqueeze && m_pLogger != NULL)
        m_pLogger->Log(LOG_LEVEL_INFO, "Dragon Squeeze detected - bands converging");
    
    return m_isDragonSqueeze;
}

//+------------------------------------------------------------------+
//| Detect Dragon Breakout                                         |
//+------------------------------------------------------------------+
bool CSonicRDragon::DetectDragonBreakout(int index)
{
    if (m_dragonHandle == INVALID_HANDLE || !m_initialized)
        return false;
    
    // Get current price and Dragon levels
    double currentClose = iClose(m_symbol, m_timeframe, index);
    
    if (CopyBuffer(m_dragonHandle, 0, index, 1, m_context.dragonUpper) <= 0 ||
        CopyBuffer(m_dragonHandle, 2, index, 1, m_context.dragonLower) <= 0)
        return false;
    
    double upperLevel = m_context.dragonUpper[0];
    double lowerLevel = m_context.dragonLower[0];
    
    // Check for breakout
    bool bullishBreakout = currentClose > upperLevel;
    bool bearishBreakout = currentClose < lowerLevel;
    
    m_context.isDragonBreakout = bullishBreakout || bearishBreakout;
    
    if (m_context.isDragonBreakout && m_pLogger != NULL)
    {
        string breakoutType = bullishBreakout ? "Bullish" : "Bearish";
        m_pLogger->Log(LOG_LEVEL_INFO, StringFormat("%s Dragon Breakout detected at %.5f", breakoutType, currentClose));
    }
    
    return m_isDragonBreakout;
}

//+------------------------------------------------------------------+
//| Get Dragon Strength Based on Multiple Factors                  |
//+------------------------------------------------------------------+
double CSonicRDragon::GetDragonStrength(int index)
{
    if (m_dragonHandle == INVALID_HANDLE || !m_initialized)
        return 0.0;
    
    double strength = 0.0;
    
    // Factor 1: Angle strength (40%)
    strength += m_context.angleStrength * 0.4;
    
    // Factor 2: Width relative to average (30%)
    double currentWidth = CalculateDragonWidth(index);
    if (m_context.avgDragonWidth > 0)
    {
        double widthRatio = currentWidth / m_context.avgDragonWidth;
        double widthStrength = MathMin(widthRatio, 2.0) / 2.0; // Normalize to 0-1
        strength += widthStrength * 0.3;
    }
    
    // Factor 3: Trend consistency (30%)
    if (CopyBuffer(m_dragonHandle, 3, index, 5, m_context.trendLine) > 0)
    {
        bool trendConsistent = true;
        for (int i = 1; i < 5; i++)
        {
            if ((m_context.trendLine[0] > m_context.trendLine[i-1] && m_context.trendLine[i] < m_context.trendLine[i-1]) ||
                (m_context.trendLine[0] < m_context.trendLine[i-1] && m_context.trendLine[i] > m_context.trendLine[i-1]))
            {
                trendConsistent = false;
                break;
            }
        }
        strength += (trendConsistent ? 1.0 : 0.5) * 0.3;
    }
    
    return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| Multi-timeframe Analysis Methods                                |
//+------------------------------------------------------------------+
bool CSonicRDragon::IsHigherTimeframeBullish()
{
    if (m_higherTfHandle == INVALID_HANDLE)
        return true; // Default to true if no higher TF data
    
    double htfTrend;
    if (GetTrendValue(0, htfTrend))
    {
        return htfTrend > 0;
    }
    
    return true;
}

bool CSonicRDragon::IsHigherTimeframeBearish()
{
    if (m_higherTfHandle == INVALID_HANDLE)
        return true; // Default to true if no higher TF data
    
    double htfTrend;
    if (GetTrendValue(0, htfTrend))
    {
        return htfTrend < 0;
    }
    
    return true;
}

double CSonicRDragon::GetHigherTfTrend()
{
    if (m_higherTfHandle == INVALID_HANDLE)
        return 0.0;
    
    double bufferTrend[1];
    if (CopyBuffer(m_higherTfHandle, 3, 0, 1, bufferTrend) > 0)
    {
        return bufferTrend[0];
    }
    
    return 0.0;
}

// End of namespace removal

#endif // ANALYSIS_SONICR_DRAGON_MQH