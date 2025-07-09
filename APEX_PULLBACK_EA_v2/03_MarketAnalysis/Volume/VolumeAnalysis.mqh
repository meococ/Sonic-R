//+------------------------------------------------------------------+
//|                                             VolumeAnalysis.mqh |
//|                                    APEX Pullback EA v5.0 FINAL |
//|                                     Advanced Volume Analysis    |
//+------------------------------------------------------------------+
#ifndef VOLUME_ANALYSIS_MQH
#define VOLUME_ANALYSIS_MQH

#include "../../01_Framework/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Volume Analysis Enumerations                                     |
//+------------------------------------------------------------------+
enum ENUM_VOLUME_TYPE {
    VOLUME_TICK,
    VOLUME_REAL,
    VOLUME_SPREAD,
    VOLUME_DELTA,
    VOLUME_CUMULATIVE,
    VOLUME_PROFILE
};

enum ENUM_VOLUME_TREND {
    VOLUME_TREND_INCREASING,
    VOLUME_TREND_DECREASING,
    VOLUME_TREND_STABLE,
    VOLUME_TREND_EXPLOSIVE,
    VOLUME_TREND_DRYING_UP,
    VOLUME_TREND_IRREGULAR
};

enum ENUM_VOLUME_PATTERN {
    PATTERN_ACCUMULATION,
    PATTERN_DISTRIBUTION,
    PATTERN_CLIMAX_BUYING,
    PATTERN_CLIMAX_SELLING,
    PATTERN_NO_DEMAND,
    PATTERN_NO_SUPPLY,
    PATTERN_EFFORT_RESULT,
    PATTERN_SPRING,
    PATTERN_UPTHRUST,
    PATTERN_SHAKEOUT
};

enum ENUM_VOLUME_STRENGTH {
    VOLUME_STRENGTH_VERY_WEAK,
    VOLUME_STRENGTH_WEAK,
    VOLUME_STRENGTH_NORMAL,
    VOLUME_STRENGTH_STRONG,
    VOLUME_STRENGTH_VERY_STRONG,
    VOLUME_STRENGTH_EXTREME
};

enum ENUM_VOLUME_DIVERGENCE {
    DIVERGENCE_NONE,
    DIVERGENCE_BULLISH,
    DIVERGENCE_BEARISH,
    DIVERGENCE_HIDDEN_BULLISH,
    DIVERGENCE_HIDDEN_BEARISH
};

enum ENUM_VOLUME_SIGNAL {
    SIGNAL_VOLUME_BREAKOUT,
    SIGNAL_VOLUME_EXHAUSTION,
    SIGNAL_VOLUME_CONFIRMATION,
    SIGNAL_VOLUME_DIVERGENCE,
    SIGNAL_VOLUME_ACCUMULATION,
    SIGNAL_VOLUME_DISTRIBUTION,
    SIGNAL_VOLUME_CLIMAX
};

//+------------------------------------------------------------------+
//| Volume Analysis Structures                                       |
//+------------------------------------------------------------------+
struct SVolumeBar {
    datetime              Time;
    double                Volume;
    double                BuyVolume;
    double                SellVolume;
    double                Delta;
    double                CumulativeDelta;
    double                VWAP;
    double                High;
    double                Low;
    double                Close;
    double                Range;
    double                VolumeRate;
    bool                  IsHighVolume;
    bool                  IsLowVolume;
    ENUM_VOLUME_STRENGTH  Strength;
};

struct SVolumeProfile {
    double                Price;
    double                Volume;
    double                BuyVolume;
    double                SellVolume;
    double                Delta;
    double                Percentage;
    bool                  IsPOC; // Point of Control
    bool                  IsValueArea;
    bool                  IsHighVolumeNode;
    bool                  IsLowVolumeNode;
};

struct SVolumeCluster {
    double                StartPrice;
    double                EndPrice;
    double                TotalVolume;
    double                AvgPrice;
    double                MaxVolume;
    int                   BarCount;
    ENUM_VOLUME_STRENGTH  Strength;
    bool                  IsSupport;
    bool                  IsResistance;
    datetime              StartTime;
    datetime              EndTime;
};

struct SVolumeAnalysis {
    ENUM_VOLUME_TREND     Trend;
    ENUM_VOLUME_PATTERN   Pattern;
    ENUM_VOLUME_STRENGTH  Strength;
    ENUM_VOLUME_DIVERGENCE Divergence;
    double                AvgVolume;
    double                RelativeVolume;
    double                VolumeRatio;
    double                BuyPressure;
    double                SellPressure;
    double                NetPressure;
    double                VolumeOscillator;
    bool                  IsBreakoutVolume;
    bool                  IsExhaustionVolume;
    datetime              Time;
};

struct SVolumeSignal {
    ENUM_VOLUME_SIGNAL    Type;
    ENUM_SIGNAL_STRENGTH  Strength;
    double                Price;
    double                Volume;
    double                Confidence;
    string                Description;
    datetime              Time;
    bool                  IsValid;
    bool                  IsConfirmed;
};

struct SVolumeConfig {
    // Analysis Settings
    ENUM_VOLUME_TYPE      VolumeType;
    int                   LookbackPeriod;
    int                   SmoothingPeriod;
    bool                  UseRealVolume;
    bool                  AnalyzeDelta;
    bool                  AnalyzeProfile;
    
    // Thresholds
    double                HighVolumeThreshold;
    double                LowVolumeThreshold;
    double                BreakoutVolumeMultiplier;
    double                ExhaustionThreshold;
    double                DivergenceThreshold;
    
    // Profile Settings
    int                   ProfileBars;
    int                   ProfileLevels;
    double                ValueAreaPercentage;
    bool                  ShowPOC;
    bool                  ShowValueArea;
    
    // Signal Settings
    bool                  GenerateSignals;
    bool                  FilterByTrend;
    bool                  RequireConfirmation;
    double                MinSignalStrength;
    
    // Display Settings
    bool                  ShowVolumeProfile;
    bool                  ShowVolumeClusters;
    bool                  ShowVWAP;
    bool                  ShowDelta;
};

struct SVolumeStats {
    double                AvgDailyVolume;
    double                MaxVolume;
    double                MinVolume;
    double                VolumeStdDev;
    double                AvgBuyVolume;
    double                AvgSellVolume;
    double                BuyVolumeRatio;
    double                SellVolumeRatio;
    int                   HighVolumeCount;
    int                   LowVolumeCount;
    int                   BreakoutCount;
    int                   ExhaustionCount;
    datetime              LastHighVolume;
    datetime              LastLowVolume;
    datetime              LastUpdate;
};

//+------------------------------------------------------------------+
//| Volume Analysis Class                                             |
//+------------------------------------------------------------------+
class CVolumeAnalysis {
private:
    // Core properties
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    string                m_Symbol;
    ENUM_TIMEFRAMES       m_Timeframe;
    
    // Configuration
    SVolumeConfig         m_Config;
    SVolumeStats          m_Stats;
    
    // Volume data
    SVolumeBar            m_VolumeBars[];
    int                   m_BarCount;
    SVolumeProfile        m_VolumeProfile[];
    int                   m_ProfileCount;
    SVolumeCluster        m_VolumeClusters[];
    int                   m_ClusterCount;
    
    // Analysis results
    SVolumeAnalysis       m_CurrentAnalysis;
    SVolumeSignal         m_Signals[];
    int                   m_SignalCount;
    
    // Indicators
    double                m_VWAP[];
    double                m_VolumeOscillator[];
    double                m_RelativeVolume[];
    double                m_CumulativeDelta[];
    
    // Analysis state
    datetime              m_LastUpdate;
    bool                  m_DataValid;
    double                m_POC; // Point of Control
    double                m_ValueAreaHigh;
    double                m_ValueAreaLow;
    
    // Constants
    static const int      MAX_BARS;
    static const int      MAX_PROFILE_LEVELS;
    static const int      MAX_CLUSTERS;
    static const int      MAX_SIGNALS;
    
public:
    //--- Constructor/Destructor ---
    CVolumeAnalysis();
    ~CVolumeAnalysis();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol, const ENUM_TIMEFRAMES timeframe, const SVolumeConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Data Collection ---
    bool                  LoadVolumeData();
    bool                  UpdateVolumeData();
    void                  CalculateVolumeIndicators();
    void                  BuildVolumeProfile();
    
    //--- Volume Analysis ---
    SVolumeAnalysis       AnalyzeVolume();
    SVolumeAnalysis       GetCurrentAnalysis() const { return m_CurrentAnalysis; }
    ENUM_VOLUME_TREND     GetVolumeTrend();
    ENUM_VOLUME_PATTERN   DetectVolumePattern();
    ENUM_VOLUME_STRENGTH  GetVolumeStrength();
    
    //--- Volume Metrics ---
    double                GetCurrentVolume();
    double                GetAverageVolume(const int periods = 20);
    double                GetRelativeVolume();
    double                GetVolumeRatio();
    double                GetVolumeOscillator();
    
    //--- Delta Analysis ---
    double                GetVolumeDelta();
    double                GetCumulativeDelta();
    double                GetBuyPressure();
    double                GetSellPressure();
    double                GetNetPressure();
    
    //--- VWAP Analysis ---
    double                GetVWAP();
    double                GetVWAPDeviation();
    bool                  IsPriceAboveVWAP();
    bool                  IsPriceBelowVWAP();
    
    //--- Volume Profile ---
    double                GetPOC() const { return m_POC; }
    double                GetValueAreaHigh() const { return m_ValueAreaHigh; }
    double                GetValueAreaLow() const { return m_ValueAreaLow; }
    bool                  IsPriceInValueArea(const double price);
    SVolumeProfile        GetVolumeAtPrice(const double price);
    
    //--- Volume Clusters ---
    int                   GetClusterCount() const { return m_ClusterCount; }
    SVolumeCluster        GetCluster(const int index);
    SVolumeCluster        GetNearestCluster(const double price);
    bool                  IsHighVolumeNode(const double price);
    bool                  IsLowVolumeNode(const double price);
    
    //--- Pattern Recognition ---
    bool                  IsAccumulation();
    bool                  IsDistribution();
    bool                  IsClimaxBuying();
    bool                  IsClimaxSelling();
    bool                  IsNoDemand();
    bool                  IsNoSupply();
    bool                  IsEffortVsResult();
    
    //--- Divergence Analysis ---
    ENUM_VOLUME_DIVERGENCE DetectVolumeDivergence();
    bool                  IsBullishDivergence();
    bool                  IsBearishDivergence();
    bool                  IsHiddenDivergence();
    
    //--- Breakout Analysis ---
    bool                  IsBreakoutVolume();
    bool                  IsVolumeConfirmation();
    bool                  IsVolumeExhaustion();
    double                GetBreakoutStrength();
    
    //--- Signal Generation ---
    bool                  GenerateVolumeSignals();
    int                   GetSignalCount() const { return m_SignalCount; }
    SVolumeSignal         GetSignal(const int index);
    SVolumeSignal         GetLatestSignal();
    bool                  HasActiveSignal(const ENUM_VOLUME_SIGNAL type);
    
    //--- Volume Strength ---
    ENUM_VOLUME_STRENGTH  CalculateVolumeStrength(const double volume);
    bool                  IsHighVolume(const double volume);
    bool                  IsLowVolume(const double volume);
    bool                  IsAverageVolume(const double volume);
    
    //--- Support/Resistance ---
    bool                  IsVolumeSupport(const double price);
    bool                  IsVolumeResistance(const double price);
    double                GetVolumeSupportLevel();
    double                GetVolumeResistanceLevel();
    
    //--- Statistics ---
    SVolumeStats          GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetVolumePercentile(const double volume);
    
    //--- Configuration ---
    bool                  SetConfiguration(const SVolumeConfig& config);
    SVolumeConfig         GetConfiguration() const { return m_Config; }
    bool                  SetThresholds(const double high_threshold, const double low_threshold);
    
    //--- Information ---
    string                GetVolumeSummary();
    string                GetProfileSummary();
    string                GetDeltaSummary();
    string                GetSignalSummary();
    
private:
    //--- Data Processing ---
    void                  ProcessVolumeBar(const int index);
    void                  CalculateVolumeDelta(const int index);
    void                  UpdateCumulativeDelta();
    void                  CalculateVWAP();
    
    //--- Profile Calculation ---
    void                  CalculateVolumeProfile();
    void                  FindPOC();
    void                  CalculateValueArea();
    void                  IdentifyVolumeNodes();
    
    //--- Cluster Analysis ---
    void                  IdentifyVolumeClusters();
    void                  MergeNearbyNodes();
    void                  ClassifyClusterStrength();
    
    //--- Pattern Detection ---
    ENUM_VOLUME_PATTERN   AnalyzeVolumePattern();
    bool                  DetectAccumulation();
    bool                  DetectDistribution();
    bool                  DetectClimax();
    bool                  DetectEffortResult();
    
    //--- Trend Analysis ---
    ENUM_VOLUME_TREND     AnalyzeVolumeTrend();
    double                CalculateVolumeSlope(const int periods = 10);
    bool                  IsVolumeIncreasing(const int periods = 5);
    bool                  IsVolumeDecreasing(const int periods = 5);
    
    //--- Divergence Detection ---
    void                  DetectDivergences();
    bool                  ComparePriceVolumeSwings();
    double                CalculateDivergenceStrength();
    
    //--- Signal Processing ---
    void                  ProcessVolumeSignals();
    bool                  ValidateSignal(const SVolumeSignal& signal);
    void                  FilterSignals();
    
    //--- Utility Methods ---
    double                GetVolumeAtBar(const int index);
    double                GetBuyVolumeAtBar(const int index);
    double                GetSellVolumeAtBar(const int index);
    bool                  IsValidVolumeData(const int index);
    void                  LogVolumeEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    string                VolumeTrendToString(const ENUM_VOLUME_TREND trend);
    string                VolumePatternToString(const ENUM_VOLUME_PATTERN pattern);
    string                VolumeStrengthToString(const ENUM_VOLUME_STRENGTH strength);
    string                VolumeSignalToString(const ENUM_VOLUME_SIGNAL signal);
    
    //--- Array Management ---
    void                  AddVolumeBar(const SVolumeBar& bar);
    void                  AddVolumeProfile(const SVolumeProfile& profile);
    void                  AddVolumeCluster(const SVolumeCluster& cluster);
    void                  AddVolumeSignal(const SVolumeSignal& signal);
    void                  ResizeVolumeArrays(const int new_size);
    void                  CleanupOldData();
};

// Static constants definition
const int CVolumeAnalysis::MAX_BARS = 2000;
const int CVolumeAnalysis::MAX_PROFILE_LEVELS = 200;
const int CVolumeAnalysis::MAX_CLUSTERS = 50;
const int CVolumeAnalysis::MAX_SIGNALS = 100;

#endif // VOLUME_ANALYSIS_MQH