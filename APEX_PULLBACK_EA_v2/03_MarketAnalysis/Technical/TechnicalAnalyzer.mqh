//+------------------------------------------------------------------+
//|                                           TechnicalAnalyzer.mqh |
//|                 APEX Pullback EA v5 FINAL - Technical Analysis  |
//|      Description: Advanced technical analysis component with    |
//|                   multi-timeframe analysis and pattern rec.     |
//+------------------------------------------------------------------+

#ifndef TECHNICAL_ANALYZER_MQH
#define TECHNICAL_ANALYZER_MQH

#include "..\..\00_Core\Common\CommonStructs.mqh"
#include "..\..\00_Core\Common\Enums.mqh"

//+------------------------------------------------------------------+
//| Technical Analysis Data Structures                              |
//+------------------------------------------------------------------+

// Technical analysis result
struct STechnicalAnalysis {
    double TrendStrength;                // Trend strength (-1 to 1)
    double MomentumScore;                // Momentum score (0-100)
    double VolatilityLevel;              // Volatility level (0-100)
    double SupportLevel;                 // Key support level
    double ResistanceLevel;              // Key resistance level
    bool IsBullish;                      // Overall bullish sentiment
    bool IsBearish;                      // Overall bearish sentiment
    double ConfidenceLevel;              // Analysis confidence (0-1)
    string AnalysisReason;               // Reason for analysis
    datetime LastUpdate;                 // Last update time
    
    void Reset() {
        TrendStrength = 0.0;
        MomentumScore = 50.0;
        VolatilityLevel = 50.0;
        SupportLevel = 0.0;
        ResistanceLevel = 0.0;
        IsBullish = false;
        IsBearish = false;
        ConfidenceLevel = 0.0;
        AnalysisReason = "";
        LastUpdate = 0;
    }
};

//+------------------------------------------------------------------+
//| CTechnicalAnalyzer Class                                         |
//+------------------------------------------------------------------+
class CTechnicalAnalyzer {
private:
    // Core references
    EAContext*                    m_pContext;
    bool                         m_bInitialized;
    
    // Analysis results
    STechnicalAnalysis           m_CurrentAnalysis;
    STechnicalAnalysis           m_PreviousAnalysis;
    
    // Technical indicators
    double                       m_MA_Values[];
    double                       m_RSI_Values[];
    double                       m_MACD_Values[];
    double                       m_ATR_Values[];
    static const int             BUFFER_SIZE = 50;
    
    // Analysis settings
    int                          m_MA_Period;
    int                          m_RSI_Period;
    int                          m_MACD_Fast;
    int                          m_MACD_Slow;
    int                          m_MACD_Signal;
    int                          m_ATR_Period;
    
    // Internal methods
    void                         UpdateIndicators();
    double                       CalculateTrendStrength();
    double                       CalculateMomentumScore();
    double                       CalculateVolatilityLevel();
    double                       FindSupportLevel();
    double                       FindResistanceLevel();
    bool                         DetermineBullishSentiment();
    bool                         DetermineBearishSentiment();
    double                       CalculateConfidence();
    
public:
    // Constructor and destructor
                                 CTechnicalAnalyzer();
                                ~CTechnicalAnalyzer();
    
    // Initialization and cleanup
    bool                         Initialize(EAContext* context);
    void                         Cleanup();
    
    // Core analysis methods
    void                         Update();
    STechnicalAnalysis           GetCurrentAnalysis() { return m_CurrentAnalysis; }
    STechnicalAnalysis           GetPreviousAnalysis() { return m_PreviousAnalysis; }
    
    // Specific analysis functions
    double                       GetTrendStrength() { return m_CurrentAnalysis.TrendStrength; }
    double                       GetMomentumScore() { return m_CurrentAnalysis.MomentumScore; }
    double                       GetVolatilityLevel() { return m_CurrentAnalysis.VolatilityLevel; }
    bool                         IsBullishMarket() { return m_CurrentAnalysis.IsBullish; }
    bool                         IsBearishMarket() { return m_CurrentAnalysis.IsBearish; }
    
    // Support and resistance
    double                       GetSupportLevel() { return m_CurrentAnalysis.SupportLevel; }
    double                       GetResistanceLevel() { return m_CurrentAnalysis.ResistanceLevel; }
    
    // Utility methods
    string                       GetAnalysisReport();
    void                         RunDiagnostics();
    bool                         UpdateConfiguration(EAContext* context);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTechnicalAnalyzer::CTechnicalAnalyzer() {
    m_pContext = NULL;
    m_bInitialized = false;
    
    // Initialize arrays
    ArrayResize(m_MA_Values, BUFFER_SIZE);
    ArrayResize(m_RSI_Values, BUFFER_SIZE);
    ArrayResize(m_MACD_Values, BUFFER_SIZE);
    ArrayResize(m_ATR_Values, BUFFER_SIZE);
    
    // Set default periods
    m_MA_Period = 20;
    m_RSI_Period = 14;
    m_MACD_Fast = 12;
    m_MACD_Slow = 26;
    m_MACD_Signal = 9;
    m_ATR_Period = 14;
    
    // Reset analysis
    m_CurrentAnalysis.Reset();
    m_PreviousAnalysis.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTechnicalAnalyzer::~CTechnicalAnalyzer() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize Technical Analyzer                                    |
//+------------------------------------------------------------------+
bool CTechnicalAnalyzer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[TECHNICAL] ERROR: Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Update indicator periods from context
    if (context.InputParams.RSI_Period > 0) {
        m_RSI_Period = context.InputParams.RSI_Period;
    }
    if (context.InputParams.ATR_Period > 0) {
        m_ATR_Period = context.InputParams.ATR_Period;
    }
    
    // Initialize indicators
    UpdateIndicators();
    
    m_bInitialized = true;
    Print("[TECHNICAL] Technical Analyzer initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CTechnicalAnalyzer::Cleanup() {
    if (m_bInitialized) {
        Print("[TECHNICAL] Technical Analyzer cleaned up");
        m_bInitialized = false;
    }
}

//+------------------------------------------------------------------+
//| Main Update Method                                               |
//+------------------------------------------------------------------+
void CTechnicalAnalyzer::Update() {
    if (!m_bInitialized) return;
    
    // Store previous analysis
    m_PreviousAnalysis = m_CurrentAnalysis;
    
    // Update indicators
    UpdateIndicators();
    
    // Perform technical analysis
    m_CurrentAnalysis.TrendStrength = CalculateTrendStrength();
    m_CurrentAnalysis.MomentumScore = CalculateMomentumScore();
    m_CurrentAnalysis.VolatilityLevel = CalculateVolatilityLevel();
    m_CurrentAnalysis.SupportLevel = FindSupportLevel();
    m_CurrentAnalysis.ResistanceLevel = FindResistanceLevel();
    m_CurrentAnalysis.IsBullish = DetermineBullishSentiment();
    m_CurrentAnalysis.IsBearish = DetermineBearishSentiment();
    m_CurrentAnalysis.ConfidenceLevel = CalculateConfidence();
    m_CurrentAnalysis.LastUpdate = TimeCurrent();
    
    // Generate analysis reason
    if (m_CurrentAnalysis.IsBullish) {
        m_CurrentAnalysis.AnalysisReason = StringFormat("Bullish: Trend=%.2f, Momentum=%.1f", 
                                                       m_CurrentAnalysis.TrendStrength, 
                                                       m_CurrentAnalysis.MomentumScore);
    } else if (m_CurrentAnalysis.IsBearish) {
        m_CurrentAnalysis.AnalysisReason = StringFormat("Bearish: Trend=%.2f, Momentum=%.1f", 
                                                       m_CurrentAnalysis.TrendStrength, 
                                                       m_CurrentAnalysis.MomentumScore);
    } else {
        m_CurrentAnalysis.AnalysisReason = StringFormat("Neutral: Trend=%.2f, Momentum=%.1f", 
                                                       m_CurrentAnalysis.TrendStrength, 
                                                       m_CurrentAnalysis.MomentumScore);
    }
}

//+------------------------------------------------------------------+
//| Update Technical Indicators                                      |
//+------------------------------------------------------------------+
void CTechnicalAnalyzer::UpdateIndicators() {
    // Update moving averages
    for (int i = 0; i < BUFFER_SIZE; i++) {
        m_MA_Values[i] = iMA(_Symbol, _Period, m_MA_Period, 0, MODE_SMA, PRICE_CLOSE, i);
        m_RSI_Values[i] = iRSI(_Symbol, _Period, m_RSI_Period, PRICE_CLOSE, i);
        m_MACD_Values[i] = iMACD(_Symbol, _Period, m_MACD_Fast, m_MACD_Slow, m_MACD_Signal, PRICE_CLOSE, MODE_MAIN, i);
        m_ATR_Values[i] = iATR(_Symbol, _Period, m_ATR_Period, i);
    }
}

//+------------------------------------------------------------------+
//| Calculate Trend Strength                                         |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::CalculateTrendStrength() {
    if (ArraySize(m_MA_Values) < 5) return 0.0;
    
    double currentPrice = iClose(_Symbol, _Period, 0);
    double ma_current = m_MA_Values[0];
    double ma_previous = m_MA_Values[4];
    
    // Calculate trend direction
    double priceMA_ratio = (currentPrice - ma_current) / ma_current * 100.0;
    double ma_slope = (ma_current - ma_previous) / ma_previous * 100.0;
    
    // Combine price position and MA slope
    double trendStrength = (priceMA_ratio + ma_slope) / 2.0;
    
    // Normalize to -1 to 1 range
    trendStrength = MathMax(-1.0, MathMin(1.0, trendStrength / 5.0));
    
    return trendStrength;
}

//+------------------------------------------------------------------+
//| Calculate Momentum Score                                         |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::CalculateMomentumScore() {
    if (ArraySize(m_RSI_Values) < 2 || ArraySize(m_MACD_Values) < 2) return 50.0;
    
    double rsi_current = m_RSI_Values[0];
    double macd_current = m_MACD_Values[0];
    double macd_previous = m_MACD_Values[1];
    
    // RSI momentum component (0-100)
    double rsi_momentum = rsi_current;
    
    // MACD momentum component
    double macd_momentum = 50.0; // Neutral
    if (macd_current > macd_previous) {
        macd_momentum += 25.0; // Positive momentum
    } else if (macd_current < macd_previous) {
        macd_momentum -= 25.0; // Negative momentum
    }
    
    // Combine and normalize
    double momentum = (rsi_momentum + macd_momentum) / 2.0;
    return MathMax(0.0, MathMin(100.0, momentum));
}

//+------------------------------------------------------------------+
//| Calculate Volatility Level                                       |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::CalculateVolatilityLevel() {
    if (ArraySize(m_ATR_Values) < 10) return 50.0;
    
    double atr_current = m_ATR_Values[0];
    
    // Calculate average ATR over last 10 periods
    double atr_sum = 0.0;
    for (int i = 0; i < 10; i++) {
        atr_sum += m_ATR_Values[i];
    }
    double atr_average = atr_sum / 10.0;
    
    // Calculate relative volatility
    double volatility_ratio = (atr_average > 0) ? atr_current / atr_average : 1.0;
    
    // Convert to 0-100 scale
    double volatility_level = volatility_ratio * 50.0;
    return MathMax(0.0, MathMin(100.0, volatility_level));
}

//+------------------------------------------------------------------+
//| Find Support Level                                               |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::FindSupportLevel() {
    double min_low = iLow(_Symbol, _Period, 0);
    
    // Find lowest low in recent periods
    for (int i = 1; i < 20; i++) {
        double low = iLow(_Symbol, _Period, i);
        if (low < min_low) {
            min_low = low;
        }
    }
    
    return min_low;
}

//+------------------------------------------------------------------+
//| Find Resistance Level                                            |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::FindResistanceLevel() {
    double max_high = iHigh(_Symbol, _Period, 0);
    
    // Find highest high in recent periods
    for (int i = 1; i < 20; i++) {
        double high = iHigh(_Symbol, _Period, i);
        if (high > max_high) {
            max_high = high;
        }
    }
    
    return max_high;
}

//+------------------------------------------------------------------+
//| Determine Bullish Sentiment                                      |
//+------------------------------------------------------------------+
bool CTechnicalAnalyzer::DetermineBullishSentiment() {
    return (m_CurrentAnalysis.TrendStrength > 0.3 && 
            m_CurrentAnalysis.MomentumScore > 60.0);
}

//+------------------------------------------------------------------+
//| Determine Bearish Sentiment                                      |
//+------------------------------------------------------------------+
bool CTechnicalAnalyzer::DetermineBearishSentiment() {
    return (m_CurrentAnalysis.TrendStrength < -0.3 && 
            m_CurrentAnalysis.MomentumScore < 40.0);
}

//+------------------------------------------------------------------+
//| Calculate Analysis Confidence                                    |
//+------------------------------------------------------------------+
double CTechnicalAnalyzer::CalculateConfidence() {
    double confidence = 0.5; // Base confidence
    
    // Add confidence based on trend strength
    confidence += MathAbs(m_CurrentAnalysis.TrendStrength) * 0.3;
    
    // Add confidence based on momentum clarity
    double momentum_distance = MathAbs(m_CurrentAnalysis.MomentumScore - 50.0);
    confidence += momentum_distance / 50.0 * 0.2;
    
    // Ensure bounds
    return MathMax(0.0, MathMin(1.0, confidence));
}

//+------------------------------------------------------------------+
//| Get Analysis Report                                              |
//+------------------------------------------------------------------+
string CTechnicalAnalyzer::GetAnalysisReport() {
    string report = "=== TECHNICAL ANALYSIS REPORT ===\n";
    report += StringFormat("Trend Strength: %.2f\n", m_CurrentAnalysis.TrendStrength);
    report += StringFormat("Momentum Score: %.1f\n", m_CurrentAnalysis.MomentumScore);
    report += StringFormat("Volatility Level: %.1f\n", m_CurrentAnalysis.VolatilityLevel);
    report += StringFormat("Support Level: %.5f\n", m_CurrentAnalysis.SupportLevel);
    report += StringFormat("Resistance Level: %.5f\n", m_CurrentAnalysis.ResistanceLevel);
    report += StringFormat("Market Sentiment: %s\n", 
              m_CurrentAnalysis.IsBullish ? "BULLISH" : 
              (m_CurrentAnalysis.IsBearish ? "BEARISH" : "NEUTRAL"));
    report += StringFormat("Confidence: %.1f%%\n", m_CurrentAnalysis.ConfidenceLevel * 100.0);
    report += StringFormat("Analysis: %s\n", m_CurrentAnalysis.AnalysisReason);
    
    return report;
}

//+------------------------------------------------------------------+
//| Run Diagnostics                                                  |
//+------------------------------------------------------------------+
void CTechnicalAnalyzer::RunDiagnostics() {
    Print("=== TECHNICAL ANALYZER DIAGNOSTICS ===");
    Print("Initialized: ", m_bInitialized ? "YES" : "NO");
    Print("Trend Strength: ", m_CurrentAnalysis.TrendStrength);
    Print("Momentum Score: ", m_CurrentAnalysis.MomentumScore);
    Print("Volatility Level: ", m_CurrentAnalysis.VolatilityLevel);
    Print("Is Bullish: ", m_CurrentAnalysis.IsBullish ? "YES" : "NO");
    Print("Is Bearish: ", m_CurrentAnalysis.IsBearish ? "YES" : "NO");
    Print("Confidence: ", m_CurrentAnalysis.ConfidenceLevel);
    Print("======================================");
}

//+------------------------------------------------------------------+
//| Update Configuration                                             |
//+------------------------------------------------------------------+
bool CTechnicalAnalyzer::UpdateConfiguration(EAContext* context) {
    if (context == NULL) return false;
    
    // Update periods if changed
    if (context.InputParams.RSI_Period > 0) {
        m_RSI_Period = context.InputParams.RSI_Period;
    }
    if (context.InputParams.ATR_Period > 0) {
        m_ATR_Period = context.InputParams.ATR_Period;
    }
    
    return true;
}

#endif // TECHNICAL_ANALYZER_MQH 