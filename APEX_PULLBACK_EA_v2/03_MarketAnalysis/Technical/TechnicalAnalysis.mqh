//+------------------------------------------------------------------+
//|                                           TechnicalAnalysis.mqh |
//|                                    APEX Pullback EA v5.0 FINAL |
//|                                   Advanced Technical Analysis   |
//+------------------------------------------------------------------+
#ifndef TECHNICAL_ANALYSIS_MQH
#define TECHNICAL_ANALYSIS_MQH

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Technical Analysis Enumerations                                  |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE {
    SIGNAL_NONE,
    SIGNAL_BUY,
    SIGNAL_SELL,
    SIGNAL_BUY_STRONG,
    SIGNAL_SELL_STRONG,
    SIGNAL_NEUTRAL
};

enum ENUM_SIGNAL_STRENGTH {
    STRENGTH_VERY_WEAK,
    STRENGTH_WEAK,
    STRENGTH_MODERATE,
    STRENGTH_STRONG,
    STRENGTH_VERY_STRONG
};

enum ENUM_DIVERGENCE_TYPE {
    DIVERGENCE_NONE,
    DIVERGENCE_BULLISH,
    DIVERGENCE_BEARISH,
    DIVERGENCE_HIDDEN_BULLISH,
    DIVERGENCE_HIDDEN_BEARISH
};

enum ENUM_MOMENTUM_STATE {
    MOMENTUM_ACCELERATING,
    MOMENTUM_DECELERATING,
    MOMENTUM_NEUTRAL,
    MOMENTUM_EXHAUSTED
};

enum ENUM_VOLATILITY_STATE {
    VOLATILITY_LOW,
    VOLATILITY_NORMAL,
    VOLATILITY_HIGH,
    VOLATILITY_EXTREME
};

//+------------------------------------------------------------------+
//| Technical Analysis Structures                                    |
//+------------------------------------------------------------------+
struct STechnicalSignal {
    ENUM_SIGNAL_TYPE      Type;
    ENUM_SIGNAL_STRENGTH  Strength;
    double                Confidence;
    double                EntryPrice;
    double                StopLoss;
    double                TakeProfit;
    string                Description;
    datetime              Time;
    string                Source;
    bool                  IsValid;
};

struct SDivergenceInfo {
    ENUM_DIVERGENCE_TYPE  Type;
    double                PriceHigh;
    double                PriceLow;
    double                IndicatorHigh;
    double                IndicatorLow;
    datetime              StartTime;
    datetime              EndTime;
    double                Strength;
    bool                  IsConfirmed;
};

struct SMomentumAnalysis {
    ENUM_MOMENTUM_STATE   State;
    double                RSI;
    double                MACD;
    double                MACDSignal;
    double                MACDHistogram;
    double                Stochastic;
    double                StochasticSignal;
    double                Williams;
    double                CCI;
    double                MomentumScore;
    bool                  IsOverbought;
    bool                  IsOversold;
};

struct SVolatilityAnalysis {
    ENUM_VOLATILITY_STATE State;
    double                ATR;
    double                BollingerWidth;
    double                StandardDeviation;
    double                VolatilityRatio;
    double                VolatilityScore;
    bool                  IsExpanding;
    bool                  IsContracting;
};

struct STrendAnalysis {
    ENUM_TREND_DIRECTION  Direction;
    ENUM_TREND_STRENGTH   Strength;
    double                ADX;
    double                ADXPlus;
    double                ADXMinus;
    double                ParabolicSAR;
    double                TrendScore;
    bool                  IsTrending;
    bool                  IsRanging;
};

struct STechnicalConfig {
    // RSI Settings
    int                   RSIPeriod;
    double                RSIOverbought;
    double                RSIOversold;
    
    // MACD Settings
    int                   MACDFast;
    int                   MACDSlow;
    int                   MACDSignal;
    
    // Stochastic Settings
    int                   StochKPeriod;
    int                   StochDPeriod;
    int                   StochSlowing;
    
    // Bollinger Bands Settings
    int                   BBPeriod;
    double                BBDeviation;
    
    // ADX Settings
    int                   ADXPeriod;
    double                ADXTrendLevel;
    
    // ATR Settings
    int                   ATRPeriod;
    
    // Analysis Settings
    bool                  UseDivergence;
    bool                  UseMomentum;
    bool                  UseVolatility;
    bool                  UseTrend;
    bool                  UseOscillators;
    bool                  UseMovingAverages;
    
    // Signal Settings
    double                MinConfidence;
    int                   SignalTimeout;
    bool                  CombineSignals;
    bool                  FilterByTrend;
    bool                  FilterByVolatility;
};

struct STechnicalStats {
    int                   TotalSignals;
    int                   BuySignals;
    int                   SellSignals;
    int                   CorrectSignals;
    int                   FalseSignals;
    double                AccuracyRate;
    double                AvgConfidence;
    datetime              LastSignalTime;
    datetime              LastUpdateTime;
};

//+------------------------------------------------------------------+
//| Technical Analysis Class                                         |
//+------------------------------------------------------------------+
class CTechnicalAnalysis {
private:
    // Core properties
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    string                m_Symbol;
    ENUM_TIMEFRAMES       m_Timeframe;
    
    // Configuration
    STechnicalConfig      m_Config;
    STechnicalStats       m_Stats;
    
    // Indicator handles
    int                   m_RSIHandle;
    int                   m_MACDHandle;
    int                   m_StochHandle;
    int                   m_BBHandle;
    int                   m_ADXHandle;
    int                   m_ATRHandle;
    int                   m_SARHandle;
    int                   m_CCIHandle;
    int                   m_WilliamsHandle;

public:
    //--- Constructor/Destructor ---
    CTechnicalAnalysis();
    ~CTechnicalAnalysis();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol, const ENUM_TIMEFRAMES timeframe, const STechnicalConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();

}; // END CLASS CTechnicalAnalysis
    
    // Analysis results
    SMomentumAnalysis     m_Momentum;
    SVolatilityAnalysis   m_Volatility;
    STrendAnalysis        m_Trend;
    STechnicalSignal      m_LastSignal;
    SDivergenceInfo       m_LastDivergence;
    
    // Signal history
    STechnicalSignal      m_SignalHistory[];
    int                   m_SignalCount;
    
    // Analysis state
    datetime              m_LastUpdate;
    bool                  m_AnalysisValid;
    
    // Constants
    static const int      MAX_SIGNALS;
    static const double   SIGNAL_THRESHOLD;
    
public:
    //--- Constructor/Destructor ---
    CTechnicalAnalysis(EAContext* context);
    ~CTechnicalAnalysis();
    
    //--- Core Methods ---
    bool                  Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const STechnicalConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Signal Analysis ---
    STechnicalSignal      AnalyzeSignals();
    STechnicalSignal      GetCurrentSignal() const { return m_LastSignal; }
    bool                  HasValidSignal() const { return m_LastSignal.IsValid; }
    ENUM_SIGNAL_TYPE      GetSignalType() const { return m_LastSignal.Type; }
    double                GetSignalConfidence() const { return m_LastSignal.Confidence; }
    
    //--- Momentum Analysis ---
    SMomentumAnalysis     AnalyzeMomentum();
    SMomentumAnalysis     GetMomentumAnalysis() const { return m_Momentum; }
    bool                  IsOverbought() const { return m_Momentum.IsOverbought; }
    bool                  IsOversold() const { return m_Momentum.IsOversold; }
    double                GetRSI() const { return m_Momentum.RSI; }
    double                GetMACD() const { return m_Momentum.MACD; }
    
    //--- Volatility Analysis ---
    SVolatilityAnalysis   AnalyzeVolatility();
    SVolatilityAnalysis   GetVolatilityAnalysis() const { return m_Volatility; }
    ENUM_VOLATILITY_STATE GetVolatilityState() const { return m_Volatility.State; }
    double                GetATR() const { return m_Volatility.ATR; }
    bool                  IsVolatilityExpanding() const { return m_Volatility.IsExpanding; }
    
    //--- Trend Analysis ---
    STrendAnalysis        AnalyzeTrend();
    STrendAnalysis        GetTrendAnalysis() const { return m_Trend; }
    ENUM_TREND_DIRECTION  GetTrendDirection() const { return m_Trend.Direction; }
    ENUM_TREND_STRENGTH   GetTrendStrength() const { return m_Trend.Strength; }
    double                GetADX() const { return m_Trend.ADX; }
    bool                  IsTrending() const { return m_Trend.IsTrending; }
    
    //--- Divergence Analysis ---
    SDivergenceInfo       DetectDivergence();
    SDivergenceInfo       GetLastDivergence() const { return m_LastDivergence; }
    bool                  HasDivergence() const { return m_LastDivergence.Type != DIVERGENCE_NONE; }
    
    //--- Signal Validation ---
    bool                  ValidateSignal(const STechnicalSignal& signal);
    double                CalculateSignalConfidence(const STechnicalSignal& signal);
    ENUM_SIGNAL_STRENGTH  DetermineSignalStrength(const double confidence);
    
    //--- Signal History ---
    int                   GetSignalCount() const { return m_SignalCount; }
    STechnicalSignal      GetSignal(const int index);
    bool                  GetRecentSignals(STechnicalSignal& signals[], const int count = 10);
    
    //--- Oscillator Analysis ---
    bool                  IsRSIDivergence();
    bool                  IsMACDCrossover();
    bool                  IsStochasticCrossover();
    bool                  IsCCIExtreme();
    bool                  IsWilliamsExtreme();
    
    //--- Moving Average Analysis ---
    bool                  IsMABullish(const int period);
    bool                  IsMABearish(const int period);
    bool                  IsMACrossover(const int fast_period, const int slow_period);
    double                GetMASlope(const int period);
    
    //--- Support/Resistance Analysis ---
    bool                  IsPriceAtBollingerBand(const ENUM_BAND_TYPE band);
    bool                  IsBollingerSqueeze();
    bool                  IsBollingerExpansion();
    
    //--- Pattern Recognition ---
    bool                  IsDoubleTop();
    bool                  IsDoubleBottom();
    bool                  IsHeadAndShoulders();
    bool                  IsInverseHeadAndShoulders();
    
    //--- Statistics ---
    STechnicalStats       GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetAccuracyRate() const { return m_Stats.AccuracyRate; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const STechnicalConfig& config);
    STechnicalConfig      GetConfiguration() const { return m_Config; }
    
    //--- Information ---
    string                GetAnalysisSummary();
    string                GetSignalSummary();
    string                GetMomentumSummary();
    string                GetVolatilitySummary();
    string                GetTrendSummary();
    
private:
    //--- Initialization ---
    bool                  CreateIndicators();
    void                  ReleaseIndicators();
    bool                  ValidateIndicators();
    
    //--- Data Collection ---
    bool                  UpdateIndicatorData();
    bool                  GetRSIData(double& rsi_buffer[]);
    bool                  GetMACDData(double& macd_buffer[], double& signal_buffer[]);
    bool                  GetStochasticData(double& main_buffer[], double& signal_buffer[]);
    bool                  GetBollingerData(double& upper_buffer[], double& middle_buffer[], double& lower_buffer[]);
    bool                  GetADXData(double& adx_buffer[], double& plus_buffer[], double& minus_buffer[]);
    bool                  GetATRData(double& atr_buffer[]);
    
    //--- Signal Generation ---
    STechnicalSignal      GenerateMomentumSignal();
    STechnicalSignal      GenerateTrendSignal();
    STechnicalSignal      GenerateVolatilitySignal();
    STechnicalSignal      GenerateOscillatorSignal();
    STechnicalSignal      CombineSignals(const STechnicalSignal& signals[]);
    
    //--- Signal Processing ---
    void                  AddSignalToHistory(const STechnicalSignal& signal);
    void                  CleanupOldSignals();
    bool                  IsSignalTimeout(const STechnicalSignal& signal);
    
    //--- Analysis Helpers ---
    double                CalculateMomentumScore();
    double                CalculateVolatilityScore();
    double                CalculateTrendScore();
    ENUM_MOMENTUM_STATE   DetermineMomentumState();
    ENUM_VOLATILITY_STATE DetermineVolatilityState();
    
    //--- Divergence Detection ---
    bool                  DetectRSIDivergence();
    bool                  DetectMACDDivergence();
    bool                  DetectStochasticDivergence();
    SDivergenceInfo       CreateDivergence(const ENUM_DIVERGENCE_TYPE type, const double strength);
    
    //--- Utility Methods ---
    bool                  IsValidHandle(const int handle);
    void                  LogTechnicalEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    string                SignalTypeToString(const ENUM_SIGNAL_TYPE type);
    string                SignalStrengthToString(const ENUM_SIGNAL_STRENGTH strength);
};

// Static constants definition
const int CTechnicalAnalysis::MAX_SIGNALS = 100;
const double CTechnicalAnalysis::SIGNAL_THRESHOLD = 60.0;

} // namespace ApexPullback::v5

#endif // TECHNICAL_ANALYSIS_MQH