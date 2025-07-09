//+------------------------------------------------------------------+
//|      Signal_SonicR_Advanced_Strategy.mqh - Advanced Sonic R      |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNAL_SONICR_ADVANCED_STRATEGY_MQH_
#define APEX_SIGNAL_SONICR_ADVANCED_STRATEGY_MQH_

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"
#include "Signal_Strategy.mqh"
#include "Analysis_Indicators.mqh"
#include "Analysis_SonicR_WavePattern.mqh"
#include "Analysis_SonicR_PVSRA.mqh"

//+------------------------------------------------------------------+
//| Advanced Sonic R Configuration                                   |
//+------------------------------------------------------------------+
struct SSonicRAdvancedConfig
{
    // Core Strategy Parameters
    bool enableDragonBandFilter;         // Enable Dragon Band filtering
    bool enableScoutEntrySystem;         // Enable Scout Entry system
    bool enableWaveAnalysis;             // Enable Wave pattern analysis
    bool enablePVSRAConfirmation;        // Enable PVSRA confirmation
    bool enableMultiTimeframeAnalysis;   // Enable MTF analysis
    
    // Signal Generation
    double minSignalStrength;            // Minimum signal strength (0-1)
    double minEntryQuality;              // Minimum entry quality (0-1)
    int maxSignalsPerSession;            // Maximum signals per trading session
    int signalCooldownMinutes;           // Cooldown between signals
    
    // Risk Management Integration
    double maxRiskPerSignal;             // Maximum risk per signal
    double dynamicRiskMultiplier;        // Dynamic risk adjustment multiplier
    bool useAdaptivePositionSizing;      // Use adaptive position sizing
    
    // Advanced Features
    bool enableAISignalFiltering;        // Enable AI-based signal filtering
    bool enableMarketRegimeDetection;    // Enable market regime detection
    bool enableVolatilityAdjustment;     // Enable volatility-based adjustments
    
    // Performance Optimization
    int maxConcurrentAnalysis;           // Maximum concurrent analysis threads
    bool enableCaching;                  // Enable result caching
    int cacheExpirySeconds;              // Cache expiry time
};

// Market Regime Types already defined in Core_Defines.mqh

//+------------------------------------------------------------------+
//| Advanced Signal Information                                       |
//+------------------------------------------------------------------+
struct SSonicRAdvancedSignal
{
    // Basic Signal Information
    ENUM_DIRECTION direction;            // Signal direction
    double strength;                     // Signal strength (0-1)
    double confidence;                   // Signal confidence (0-1)
    double quality;                      // Overall signal quality (0-1)
    
    // Entry Information
    double entryPrice;                   // Recommended entry price
    double stopLoss;                     // Stop loss level
    double takeProfit1;                  // First take profit level
    double takeProfit2;                  // Second take profit level
    double takeProfit3;                  // Third take profit level
    
    // Component Analysis
    SDragonBandInfo dragonBandInfo;      // Dragon Band analysis
    SScoutEntryInfo scoutEntryInfo;      // Scout Entry analysis
    bool wavePatternValid;               // Wave pattern validation
    bool pvsraConfirmed;                 // PVSRA confirmation
    
    // Market Context
    ENUM_MARKET_REGIME marketRegime;     // Current market regime
    double volatilityLevel;              // Current volatility level
    double trendStrength;                // Trend strength (0-1)
    
    // Risk Assessment
    double riskLevel;                    // Risk level (0-1)
    double positionSize;                 // Recommended position size
    double riskRewardRatio;              // Risk/reward ratio
    
    // Timing Information
    datetime signalTime;                 // Signal generation time
    datetime expiryTime;                 // Signal expiry time
    int timeframeGenerated;              // Timeframe where signal was generated
    
    // Performance Metrics
    double expectedReturn;               // Expected return percentage
    double successProbability;           // Success probability estimate
    int historicalAccuracy;              // Historical accuracy percentage
    
    // Additional Information
    string signalDescription;            // Human-readable description
    string riskWarning;                  // Risk warning message
    int signalId;                        // Unique signal identifier
};

//+------------------------------------------------------------------+
//| CSonicRAdvancedStrategy - Next-Generation Sonic R Strategy       |
//+------------------------------------------------------------------+
class CSonicRAdvancedStrategy : public ISignalStrategy
{
private:
    // --- Pointers to external services (injected) ---
    CLogger*                    m_pLogger;
    CIndicators*                m_pIndicators;
    CWaveAnalysis*              m_pWaveAnalysis;
    CPVSRAAnalysis*             m_pPVSRA;
    CSonicRDragon*              m_pDragonBand; // Renamed for clarity

    // --- Internal components (owned by this class) ---
    CSonicRScoutEntry*          m_pScoutEntry;

    // --- Configuration & State ---
    SSonicRAdvancedConfig       m_config;
    SSignalInfo                 m_lastSignalInfo;
    bool                        m_initialized;
    datetime                    m_lastSignalTime;

public:
    CSonicRAdvancedStrategy() : 
        m_pLogger(NULL),
        m_pIndicators(NULL),
        m_pWaveAnalysis(NULL),
        m_pPVSRA(NULL),
        m_pDragonBand(NULL),
        m_pScoutEntry(NULL),
        m_initialized(false),
        m_lastSignalTime(0)
    {
        // Initialize config with sane defaults
        // This can be overridden by user inputs later
        ZeroMemory(m_config);
        m_config.enableDragonBandFilter = true;
        m_config.enableScoutEntrySystem = true;
        m_config.minSignalStrength = 0.7;
        m_config.signalCooldownMinutes = 30;
        m_config.maxRiskPerSignal = 0.02;
        m_config.useAdaptivePositionSizing = true;

        m_lastSignalInfo.Reset();
    }

    ~CSonicRAdvancedStrategy()
    {
        Deinitialize();
    }

    //+------------------------------------------------------------------+
    //| Initialize: Receives all dependencies                          |
    //+------------------------------------------------------------------+
    virtual bool Initialize(CLogger* pLogger, CIndicators* pIndicators, CWaveAnalysis* pWave, CPVSRAAnalysis* pPVSRA, CSonicRDragon* pDragon) override
    {
        if (m_initialized) return true;

        if (!pLogger || !pIndicators || !pWave || !pPVSRA || !pDragon)
        {
            printf("CSonicRAdvancedStrategy::Initialize - Critical dependency is NULL");
            return false;
        }

        m_pLogger = pLogger;
        m_pIndicators = pIndicators;
        m_pWaveAnalysis = pWave;
        m_pPVSRA = pPVSRA;
        m_pDragonBand = pDragon;

        // Create internal components
        m_pScoutEntry = new CSonicRScoutEntry();
        if (!m_pScoutEntry)
        {
            LOG_ERROR("Failed to create Scout Entry system");
            return false;
        }

        // Initialize internal components with their dependencies
        if (!m_pScoutEntry->Initialize(m_pLogger, m_pDragonBand, m_pWaveAnalysis, m_pPVSRA))
        {
            LOG_ERROR("Failed to initialize Scout Entry system");
            Deinitialize(); // Clean up partially created objects
            return false;
        }

        m_initialized = true;
        LOG_INFO("CSonicRAdvancedStrategy initialized successfully.");
        return true;
    }

    //+------------------------------------------------------------------+
    //| Deinitialize: Cleans up owned resources                        |
    //+------------------------------------------------------------------+
    void Deinitialize()
    {
        if (m_pScoutEntry) { delete m_pScoutEntry; m_pScoutEntry = NULL; }
        m_initialized = false;
    }

    //+------------------------------------------------------------------+
    //| CheckForSignal: Main logic entry point                         |
    //+------------------------------------------------------------------+
    virtual ENUM_SIGNAL_TYPE CheckForSignal() override
    {
        if (!m_initialized) return SIGNAL_NONE;

        // Reset previous signal
        Reset();

        // Cooldown check
        if (TimeCurrent() - m_lastSignalTime < m_config.signalCooldownMinutes * 60)
        {
            return SIGNAL_NONE;
        }

        // --- Main Strategy Logic ---
        // 1. Dragon Band Filter (Trend Direction)
        if (m_config.enableDragonBandFilter)
        {
            // ... Add Dragon Band trend check logic here ...
        }

        // 2. Scout Entry System (Primary Signal)
        if (m_config.enableScoutEntrySystem)
        {
            SScoutEntryInfo scoutInfo = m_pScoutEntry->CheckForEntry();
            if (scoutInfo.direction != SIGNAL_NONE)
            {
                // Translate Scout Info to SSignalInfo
                m_lastSignalInfo.Type = scoutInfo.direction;
                m_lastSignalInfo.EntryPrice = scoutInfo.entryPrice;
                m_lastSignalInfo.StopLoss = scoutInfo.stopLoss;
                m_lastSignalInfo.TakeProfit = scoutInfo.takeProfit;
                m_lastSignalInfo.Strength = scoutInfo.confidence;
                m_lastSignalInfo.Timestamp = TimeCurrent();
                m_lastSignalInfo.Comment = "Scout Entry Signal";

                m_lastSignalTime = TimeCurrent();
                return m_lastSignalInfo.Type;
            }
        }

        return SIGNAL_NONE;
    }

    //+------------------------------------------------------------------+
    //| GetLastSignalInfo: Returns the last generated signal           |
    //+------------------------------------------------------------------+
    virtual SSignalInfo GetLastSignalInfo() override
    {
        return m_lastSignalInfo;
    }

    //+------------------------------------------------------------------+
    //| Reset: Clears the last signal state                            |
    //+------------------------------------------------------------------+
    virtual void Reset() override
    {
        m_lastSignalInfo.Reset();
    }
};

#endif // APEX_SIGNAL_SONICR_ADVANCED_STRATEGY_MQH_


#endif // APEX_SIGNAL_SONICR_ADVANCED_STRATEGY_MQH_
