//+------------------------------------------------------------------+
//|                               Analysis_SonicR_Oscillator.mqh |
//|                  APEX Pullback EA v4.6 - Refactored              |
//|      "Refactored for Flat Architecture and DSI Pattern"          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.10"
#property strict

#include "Core_Logger.mqh"
#include "Analysis_Indicators.mqh"
#include "Core_SymbolInfo.mqh"
#include "Analysis_SonicR_WavePattern.mqh" // For divergence detection

// --- Global Enumerations for Oscillator Analysis ---
enum ENUM_OSCILLATOR_STATE
{
    OSC_OVERBOUGHT,         // Overbought condition
    OSC_OVERSOLD,           // Oversold condition
    OSC_NEUTRAL,            // Neutral zone
    OSC_BULLISH_MOMENTUM,   // Bullish momentum
    OSC_BEARISH_MOMENTUM    // Bearish momentum
};

enum ENUM_DIVERGENCE_TYPE
{
    DIV_NONE,               // No divergence
    DIV_BULLISH_REGULAR,    // Regular bullish divergence
    DIV_BEARISH_REGULAR,    // Regular bearish divergence
    DIV_BULLISH_HIDDEN,     // Hidden bullish divergence
    DIV_BEARISH_HIDDEN      // Hidden bearish divergence
};

// --- Global Structures for Oscillator Analysis ---
struct SOscillatorInfo
{
    double                  value;              // Main oscillator value
    double                  signal;             // Signal line value
    double                  histogram;          // Histogram value
    ENUM_OSCILLATOR_STATE   state;              // Current state
    bool                    isBullish;          // Bullish condition
    bool                    isBearish;          // Bearish condition
    bool                    isOverbought;       // Overbought flag
    bool                    isOversold;         // Oversold flag
    double                  momentum;           // Momentum strength
    datetime                lastUpdate;         // Last update time
};

struct SOscillatorContext
{
    SOscillatorInfo         oscillator;
    SDivergenceInfo         divergence;
};

struct SDivergenceInfo
{
    ENUM_DIVERGENCE_TYPE    type;               // Divergence type
    bool                    isActive;           // Divergence active flag
    double                  strength;           // Divergence strength (0.0-1.0)
    datetime                startTime;          // Divergence start time
    datetime                endTime;            // Divergence end time
    double                  priceStart;         // Price at divergence start
    double                  priceEnd;           // Price at divergence end
    double                  oscStart;           // Oscillator at divergence start
    double                  oscEnd;             // Oscillator at divergence end
};


//+------------------------------------------------------------------+
//| Class CSonicROscillator                                          |
//| Purpose: Custom momentum oscillator with divergence detection    |
//+------------------------------------------------------------------+
class CSonicROscillator
{

private:
    // Core dependencies
    CLogger*                m_pLogger;
    CAppIndicators*         m_pIndicators;
    CAppSymbolInfo*         m_pSymbolInfo;
    CSonicRWavePattern*     m_pWavePattern;

    // Configuration
    int                     m_fastPeriod;
    int                     m_slowPeriod;
    int                     m_signalPeriod;
    double                  m_overboughtLevel;
    double                  m_oversoldLevel;
    int                     m_divergenceLookback;

    // Oscillator data
    SOscillatorContext      m_context;

    // Buffers
    double                  m_mainBuffer[];
    double                  m_signalBuffer[];
    double                  m_histogramBuffer[];
    double                  m_fastEmaBuffer[];
    double                  m_slowEmaBuffer[];

public:
    // Constructor & Destructor
                     CSonicROscillator();
                    ~CSonicROscillator();

    // Initialization
    bool Initialize(CLogger* pLogger, CAppIndicators* pIndicators, CAppSymbolInfo* pSymbolInfo, CSonicRWavePattern* pWavePattern);
    void Deinitialize();

    // Configuration
    void SetPeriods(int fast, int slow, int signal);
    void SetOverboughtLevel(double level) { m_overboughtLevel = level; }
    void SetOversoldLevel(double level) { m_oversoldLevel = level; }
    void SetDivergenceLookback(int lookback) { m_divergenceLookback = lookback; }

    // Main analysis functions
    bool Update(const int shift);
    bool CalculateOscillator(const int shift);
    void UpdateOscillatorState(const int shift);
    bool DetectDivergence(const int shift);

    // Data Access
    SOscillatorContext* GetContext() { return &m_context; }

    // Oscillator info queries
    bool GetOscillatorInfo(SOscillatorInfo& oscInfo) const { oscInfo = m_context.oscillator; return true; }
    bool GetDivergenceInfo(SDivergenceInfo& divInfo) const { divInfo = m_context.divergence; return true; }

    // State queries
    bool IsOverbought() const { return m_context.oscillator.isOverbought; }
    bool IsOversold() const { return m_context.oscillator.isOversold; }
    bool IsBullish() const { return m_context.oscillator.isBullish; }
    bool IsBearish() const { return m_context.oscillator.isBearish; }
    ENUM_OSCILLATOR_STATE GetState() const { return m_context.oscillator.state; }

    // Divergence queries
    bool HasDivergence() const { return m_context.divergence.isActive; }
    ENUM_DIVERGENCE_TYPE GetDivergenceType() const { return m_context.divergence.type; }
    double GetDivergenceStrength() const { return m_context.divergence.strength; }

    // Utility functions
    void LogOscillatorState();

private:
    double FindOscillatorPeak(int startIdx, int window, bool findMax);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSonicROscillator::CSonicROscillator() : m_pLogger(NULL),
                                         m_pIndicators(NULL),
                                         m_pSymbolInfo(NULL),
                                         m_pWavePattern(NULL),
                                         m_fastPeriod(12),
                                         m_slowPeriod(26),
                                         m_signalPeriod(9),
                                         m_overboughtLevel(0.005), // Adjusted for MACD-style values
                                         m_oversoldLevel(-0.005),
                                         m_divergenceLookback(50)
{
    ZeroMemory(m_context);
    ArraySetAsSeries(m_mainBuffer, true);
    ArraySetAsSeries(m_signalBuffer, true);
    ArraySetAsSeries(m_histogramBuffer, true);
    ArraySetAsSeries(m_fastEmaBuffer, true);
    ArraySetAsSeries(m_slowEmaBuffer, true);
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSonicROscillator::~CSonicROscillator()
{
    Deinitialize();
}
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CSonicROscillator::Initialize(CLogger* pLogger, CAppIndicators* pIndicators, CAppSymbolInfo* pSymbolInfo, CSonicRWavePattern* pWavePattern)
{
    if(!pLogger || !pIndicators || !pSymbolInfo || !pWavePattern)
    {
        Print("ERROR: CSonicROscillator::Initialize - NULL pointers received");
        return false;
    }
    m_pLogger = pLogger;
    m_pIndicators = pIndicators;
    m_pSymbolInfo = pSymbolInfo;
    m_pWavePattern = pWavePattern;

    LOG_INFO("CSonicROscillator initialized successfully.");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CSonicROscillator::Deinitialize()
{
    // Buffers are automatically managed
}

//+------------------------------------------------------------------+
//| SetPeriods                                                       |
//+------------------------------------------------------------------+
void CSonicROscillator::SetPeriods(int fast, int slow, int signal)
{
    m_fastPeriod = fast;
    m_slowPeriod = slow;
    m_signalPeriod = signal;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
bool CSonicROscillator::Update(const int shift)
{
    if(!CalculateOscillator(shift)) return false;
    UpdateOscillatorState(shift);
    DetectDivergence(shift);
    return true;
}

//+------------------------------------------------------------------+
//| CalculateOscillator                                              |
//+------------------------------------------------------------------+
bool CSonicROscillator::CalculateOscillator(const int shift)
{
    int needed_bars = m_pSymbolInfo.Bars() - shift;
    if (needed_bars <= m_slowPeriod + m_signalPeriod) return false;

    if(m_pIndicators.GetEMA(PRICE_CLOSE, m_fastPeriod, shift, needed_bars, m_fastEmaBuffer) < needed_bars ||
       m_pIndicators.GetEMA(PRICE_CLOSE, m_slowPeriod, shift, needed_bars, m_slowEmaBuffer) < needed_bars)
    {
        LOG_WARN(*m_pLogger, "Could not get EMA data.", __FUNCTION__);
        return false;
    }

    for(int i = 0; i < needed_bars; i++)
    {
        m_mainBuffer[i] = m_fastEmaBuffer[i] - m_slowEmaBuffer[i];
    }
    
    if(m_pIndicators.GetEMAOnArray(m_mainBuffer, needed_bars, m_signalPeriod, 0, m_signalBuffer) < needed_bars)
    {
        LOG_WARN(*m_pLogger, "Could not calculate signal line.", __FUNCTION__);
        return false;
    }

    for(int i = 0; i < needed_bars; i++)
    {
        m_histogramBuffer[i] = m_mainBuffer[i] - m_signalBuffer[i];
    }

    return true;
}

//+------------------------------------------------------------------+
//| UpdateOscillatorState                                            |
//+------------------------------------------------------------------+
void CSonicROscillator::UpdateOscillatorState(const int shift)
{
    m_context.oscillator.value = m_mainBuffer[shift];
    m_context.oscillator.signal = m_signalBuffer[shift];
    m_context.oscillator.histogram = m_histogramBuffer[shift];
    m_context.oscillator.lastUpdate = TimeCurrent();

    m_context.oscillator.isBullish = m_context.oscillator.value > m_context.oscillator.signal;
    m_context.oscillator.isBearish = m_context.oscillator.value < m_context.oscillator.signal;

    m_context.oscillator.isOverbought = m_context.oscillator.value > m_overboughtLevel;
    m_context.oscillator.isOversold = m_context.oscillator.value < m_oversoldLevel;

    if(m_context.oscillator.isOverbought) m_context.oscillator.state = OSC_OVERBOUGHT;
    else if(m_context.oscillator.isOversold) m_context.oscillator.state = OSC_OVERSOLD;
    else if(m_context.oscillator.isBullish) m_context.oscillator.state = OSC_BULLISH_MOMENTUM;
    else if(m_context.oscillator.isBearish) m_context.oscillator.state = OSC_BEARISH_MOMENTUM;
    else m_context.oscillator.state = OSC_NEUTRAL;
}

//+------------------------------------------------------------------+
//| DetectDivergence                                                 |
//+------------------------------------------------------------------+
bool CSonicROscillator::DetectDivergence(const int shift)
{
    if(!m_pWavePattern) return false;

    m_context.divergence.isActive = false;
    m_context.divergence.type = DIV_NONE;

    CSonicRWavePattern::SWavePoint swingPoints[4];
    if(m_pWavePattern.GetSwingPoints(swingPoints, 4) < 4) return true; 

    CSonicRWavePattern::SWavePoint lastHigh, prevHigh, lastLow, prevLow;
    int highsFound = 0, lowsFound = 0;

    for(int i = 0; i < 4; i++)
    {
        if(swingPoints[i].isHigh)
        {
            if(highsFound == 0) lastHigh = swingPoints[i];
            else if(highsFound == 1) prevHigh = swingPoints[i];
            highsFound++;
        }
        if(swingPoints[i].isLow)
        {
            if(lowsFound == 0) lastLow = swingPoints[i];
            else if(lowsFound == 1) prevLow = swingPoints[i];
            lowsFound++;
        }
    }

    int searchWindow = 3;

    if(highsFound >= 2)
    {
        double lastHighOsc = FindOscillatorPeak(lastHigh.barIndex, searchWindow, true);
        double prevHighOsc = FindOscillatorPeak(prevHigh.barIndex, searchWindow, true);

        if (lastHigh.price > prevHigh.price && lastHighOsc < prevHighOsc)
        {
            m_context.divergence.isActive = true;
            m_context.divergence.type = DIV_BEARISH_REGULAR;
            m_context.divergence.startTime = prevHigh.time;
            m_context.divergence.endTime = lastHigh.time;
            m_context.divergence.priceStart = prevHigh.price;
            m_context.divergence.priceEnd = lastHigh.price;
            m_context.divergence.oscStart = prevHighOsc;
            m_context.divergence.oscEnd = lastHighOsc;
            m_context.divergence.strength = 0.75; // Placeholder strength
            LOG_INFO("Regular Bearish Divergence Detected.");
            return true;
        }
    }

    if(lowsFound >= 2)
    {
        double lastLowOsc = FindOscillatorPeak(lastLow.barIndex, searchWindow, false);
        double prevLowOsc = FindOscillatorPeak(prevLow.barIndex, searchWindow, false);

        if (lastLow.price < prevLow.price && lastLowOsc > prevLowOsc)
        {
            m_context.divergence.isActive = true;
            m_context.divergence.type = DIV_BULLISH_REGULAR;
            m_context.divergence.startTime = prevLow.time;
            m_context.divergence.endTime = lastLow.time;
            m_context.divergence.priceStart = prevLow.price;
            m_context.divergence.priceEnd = lastLow.price;
            m_context.divergence.oscStart = prevLowOsc;
            m_context.divergence.oscEnd = lastLowOsc;
            m_context.divergence.strength = 0.75; // Placeholder strength
            LOG_INFO("Regular Bullish Divergence Detected.");
            return true;
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| FindOscillatorPeak (Helper function)                             |
//+------------------------------------------------------------------+
double CSonicROscillator::FindOscillatorPeak(int startIdx, int window, bool findMax)
{
    double peakValue = findMax ? -DBL_MAX : DBL_MAX;
    int searchStart = MathMax(0, startIdx - window);
    int searchEnd = MathMin(ArraySize(m_mainBuffer) - 1, startIdx + window);

    for(int i = searchStart; i <= searchEnd; i++)
    {
        if(findMax)
        {
            if(m_mainBuffer[i] > peakValue) peakValue = m_mainBuffer[i];
        }
        else
        {
            if(m_mainBuffer[i] < peakValue) peakValue = m_mainBuffer[i];
        }
    }
    return peakValue;
}

//+------------------------------------------------------------------+
//| GetOscillatorInfo                                                |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| GetDivergenceInfo                                                |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| LogOscillatorState                                               |
//+------------------------------------------------------------------+
void CSonicROscillator::LogOscillatorState()
{
    string stateStr = EnumToString(m_context.oscillator.state);
    string message = StringFormat("Oscillator State: %s | Val: %.5f | Sig: %.5f | Hist: %.5f",
                                  stateStr, m_context.oscillator.value, m_context.oscillator.signal, m_context.oscillator.histogram);
    LOG_INFO(message);
}


