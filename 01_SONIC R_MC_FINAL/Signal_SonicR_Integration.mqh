//+------------------------------------------------------------------+
//|                              Signal_SonicR_Integration.mqh |
//|                  APEX Pullback EA v4.6 - Refactored              |
//|      "The Conductor: Unifying signals into a symphony"           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.10"
#property strict

// Included via Includes.mqh to manage dependencies correctly
#include "Core_Defines.mqh"
#include "Shared_DataStructures.mqh"
#include "Analysis_MarketAnalysisManager.mqh" // The new central manager
#include "Signal_SonicR_ScoutEntry.mqh"



// Forward declaration if needed
class CSonicRIntegration;

//+------------------------------------------------------------------+
//| Class CSonicRIntegration                                         |
//| Purpose: Acts as the central coordinator for all Sonic R signals.|
//+------------------------------------------------------------------+
#include "Signal_Strategy.mqh" // Include the interface

class CSonicRIntegration : public ISignalStrategy
{
private:
    // --- Core Dependencies ---
    CLogger*                    m_pLogger;
    CMarketAnalysisManager*     m_pMarketAnalysisManager; // Pointer to the manager

    // --- Signal Logic Modules ---
    CSonicRScoutEntry*          m_pScoutEntry;

    // --- Configuration ---
    double                      m_minConfidenceThreshold; // Minimum confidence to generate a signal

    // --- Internal State ---
    SSonicRUnifiedSignal        m_lastSignal;
    ENUM_STRATEGY_TYPE          m_strategyType; // Required by interface

    // --- Private Methods ---
    double      CalculateConfidenceScore(SSonicRUnifiedSignal &signal, const SDragonBandInfo &band, const SOscillatorInfo &osc, const SDivergenceInfo &div, const SVPSRAInfo &pvsra, const CSonicRWavePattern::SWavePattern &wave);
    string      BuildSignalReason(const SSonicRUnifiedSignal &signal, const SDragonBandInfo &band, const SOscillatorInfo &osc, const SDivergenceInfo &div, const SVPSRAInfo &pvsra, const CSonicRWavePattern::SWavePattern &wave);

public:
    // --- Constructor & Destructor ---
                CSonicRIntegration();
               ~CSonicRIntegration();

    // --- Initialization ---
    bool        Initialize(CMarketAnalysisManager* pManager, CSonicRScoutEntry* pScoutEntry);
    void        Deinitialize();

    // --- Configuration ---
    void        SetMinConfidence(double threshold) { m_minConfidenceThreshold = threshold; }

    // --- Main Signal Generation ---
    bool        GenerateSignal(SSonicRUnifiedSignal &unifiedSignal);

    // --- Post-generation Queries ---
    bool        GetLastSignal(SSonicRUnifiedSignal &signal);

    // --- ISignalStrategy Interface Implementation ---
    virtual ENUM_SIGNAL_TYPE CheckForSignal() override;
    virtual bool             GetSignalInfo(SSignalInfo &signalInfo) override;
    virtual string           GetStrategyName() const override { return "SonicR_Unified"; }
    virtual void             SetStrategyType(ENUM_STRATEGY_TYPE type) override { m_strategyType = type; }
    virtual ENUM_STRATEGY_TYPE GetStrategyType() const override { return m_strategyType; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSonicRIntegration::CSonicRIntegration() : m_pLogger(NULL),
                                           m_pMarketAnalysisManager(NULL),
                                           m_pScoutEntry(NULL),
                                           m_minConfidenceThreshold(60.0)
{
    m_lastSignal.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSonicRIntegration::~CSonicRIntegration()
{
    Deinitialize();
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CSonicRIntegration::Initialize(CMarketAnalysisManager* pManager, CSonicRScoutEntry* pScoutEntry)
{
    if(!pManager || !pScoutEntry)
    {
        printf("Error: MarketAnalysisManager or ScoutEntry is NULL in CSonicRIntegration::Initialize");
        return false;
    }
    m_pMarketAnalysisManager = pManager;
    m_pScoutEntry = pScoutEntry;
    
    // Get dependencies from the manager
    CEaContext* context = pManager.GetContext();
    if(CheckPointer(context) == POINTER_INVALID)
    {
        printf("Error: Failed to get EA Context in CSonicRIntegration");
        return false;
    }
    m_pLogger = context.pLogger;
    if(CheckPointer(m_pLogger) == POINTER_INVALID)
    {
        printf("Error: Failed to get Logger from EA Context in CSonicRIntegration");
        return false;
    }

    if(m_pLogger) m_pLogger.LogInfo("CSonicRIntegration initialized successfully with Scout Entry module.");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CSonicRIntegration::Deinitialize()
{
    // Pointers are managed externally, just log.
    if(m_pLogger) m_pLogger.LogInfo("CSonicRIntegration deinitialized.");
}

//+------------------------------------------------------------------+
//| GenerateSignal                                                   |
//+------------------------------------------------------------------+
bool CSonicRIntegration::GenerateSignal(SSonicRUnifiedSignal &unifiedSignal)
{
    unifiedSignal.Reset();

    if(CheckPointer(m_pMarketAnalysisManager) == POINTER_INVALID)
    {
        if(m_pLogger) m_pLogger.LogWarn(__FUNCTION__ + ": Market Analysis Manager is not set.");
        return false;
    }

    // --- 1. Get the consolidated market context --- 
    // The manager has already updated all modules.
    const SMarketContext* context = m_pMarketAnalysisManager.GetMarketContext();
    if(CheckPointer(context) == POINTER_INVALID)
    {
        if(m_pLogger) m_pLogger.LogWarn(__FUNCTION__ + ": Failed to get Market Context.");
        return false;
    }

    // --- 2. Check for a Scout Entry first ---
    if (m_pScoutEntry)
    {
        SScoutEntryInfo scoutInfo;
        if (m_pScoutEntry->ScanForScoutEntries(scoutInfo))
        {
            // A scout signal was found, let's use it as the base
            unifiedSignal.timestamp = TimeCurrent();
            unifiedSignal.signalType = scoutInfo.direction == DIRECTION_BUY ? SIGNAL_TYPE_BUY : SIGNAL_TYPE_SELL;
            unifiedSignal.isScoutEntry = true;
            // The rest of the logic will add confidence to this scout signal
        }
    }

    // --- 3. If no scout, check for classic Dragon Breakout ---
    if (unifiedSignal.signalType == SIGNAL_TYPE_NONE)
    {
        if(context.dragon_band != NULL && context.dragon_band.breakoutState == DRAGON_BREAKOUT_UP) unifiedSignal.signalType = SIGNAL_TYPE_BUY;
        else if(context.dragon_band != NULL && context.dragon_band.breakoutState == DRAGON_BREAKOUT_DOWN) unifiedSignal.signalType = SIGNAL_TYPE_SELL;
        else return false; // No base signal, no need to continue
        unifiedSignal.timestamp = TimeCurrent();
    }

    // --- 3. Calculate Confidence Score --- 
    if(context.dragon_band == NULL || context.oscillator == NULL || context.pvsra == NULL || context.wave_pattern == NULL)
    {
        if(m_pLogger) m_pLogger.LogWarn(__FUNCTION__ + ": One or more analysis contexts are NULL, cannot calculate confidence score.");
        return false;
    }
    unifiedSignal.confidenceScore = CalculateConfidenceScore(unifiedSignal, *context.dragon_band, *context.oscillator, *context.pvsra, *context.wave_pattern);

    // --- 4. Final Decision --- 
    if(unifiedSignal.confidenceScore >= m_minConfidenceThreshold)
    {
        unifiedSignal.isValid = true;
        unifiedSignal.reason = BuildSignalReason(unifiedSignal, *context.dragon_band, *context.oscillator, *context.pvsra, *context.wave_pattern);
        m_lastSignal = unifiedSignal;
        if(m_pLogger) m_pLogger.LogInfo(StringFormat("Unified Signal Generated: %s, Score: %.1f, Reason: %s", 
            EnumToString(unifiedSignal.signalType), unifiedSignal.confidenceScore, unifiedSignal.reason));
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| ISignalStrategy::CheckForSignal                                  |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CSonicRIntegration::CheckForSignal()
{
    SSonicRUnifiedSignal unifiedSignal;
    if (GenerateSignal(unifiedSignal))
    {
        return unifiedSignal.signalType;
    }
    return SIGNAL_TYPE_NONE;
}

//+------------------------------------------------------------------+
//| ISignalStrategy::GetSignalInfo                                   |
//+------------------------------------------------------------------+
bool CSonicRIntegration::GetSignalInfo(SSignalInfo &signalInfo)
{
    if (!m_lastSignal.isValid)
        return false;

    signalInfo.Reset();
    signalInfo.IsValid = true;
    signalInfo.Direction = m_lastSignal.signalType;
    signalInfo.Timestamp = m_lastSignal.timestamp;
    signalInfo.sonicConfidenceScore = m_lastSignal.confidenceScore;
    signalInfo.sonicReason = m_lastSignal.reason;
    signalInfo.Comment = StringFormat("SonicR Signal (Score: %.1f)", m_lastSignal.confidenceScore);
    
    // You might want to map some unified signal details to the standard SSignalInfo fields
    // For example, if you have a concept of entry price in the unified signal:
    // signalInfo.EntryPrice = m_lastSignal.suggestedEntry;

    return true;
}

//+------------------------------------------------------------------+
//| CalculateConfidenceScore                                         |
//+------------------------------------------------------------------+
double CSonicRIntegration::CalculateConfidenceScore(SSonicRUnifiedSignal &signal, 
                                                    const SDragonBandInfo &band,
                                                    const SOscillatorInfo &osc,
                                                    const SVPSRAInfo &pvsra,
                                                    const CSonicRWavePattern::SWavePattern &wave)
{
    double score = 0.0;
    
    // Get market profile data
    if(CheckPointer(m_pMarketAnalysisManager) == POINTER_INVALID || CheckPointer(m_pMarketAnalysisManager.GetMarketProfile()) == POINTER_INVALID) return 0.0;
    ENUM_MARKET_REGIME currentRegime = m_pMarketAnalysisManager.GetMarketProfile().GetCurrentRegime();
    double poc = m_pMarketAnalysisManager.GetMarketProfile().GetPointOfControl();
    double vah = m_pMarketAnalysisManager.GetMarketProfile().GetValueAreaHigh();
    double val = m_pMarketAnalysisManager.GetMarketProfile().GetValueAreaLow();
    double currentPrice = m_pMarketAnalysisManager.GetContext().pSymbolInfo.Bid(); // Hoặc Ask tùy hướng
    
    // Base Score from Dragon Band Breakout
    if(band.breakoutState == DRAGON_BREAKOUT_UP || band.breakoutState == DRAGON_BREAKOUT_DOWN)
        score += 50.0;
        
    // Market Regime Score
    if (signal.signalType == SIGNAL_TYPE_BUY && 
        (currentRegime == REGIME_TRENDING_BULL || currentRegime == REGIME_BULL_PULLBACK)) {
        score += 15.0; // Bonus lớn cho tín hiệu hợp xu hướng
    } 
    else if (signal.signalType == SIGNAL_TYPE_SELL && 
             (currentRegime == REGIME_TRENDING_BEAR || currentRegime == REGIME_BEAR_PULLBACK)) {
        score += 15.0;
    } 
    else if (currentRegime == REGIME_RANGING_STABLE || currentRegime == REGIME_VOLATILE_EXPANSION) {
        score -= 20.0; // Phạt nặng nếu tín hiệu trong sideway không phù hợp
    }
    
    // Value Area Score
    double priceToPocDist = MathAbs(currentPrice - poc) / m_pMarketAnalysisManager.GetContext().pSymbolInfo.GetPipSize();
    if (priceToPocDist < 10) { // Trong vòng 10 pips của POC
        score += 10.0; // Bonus cho tín hiệu gần POC
    }
    if (signal.signalType == SIGNAL_TYPE_BUY && currentPrice < val && 
        MathAbs(currentPrice - val) < 10) { // Buy gần VAL
        score += 5.0;
    } 
    else if (signal.signalType == SIGNAL_TYPE_SELL && currentPrice > vah && 
             MathAbs(currentPrice - vah) < 10) { // Sell gần VAH
        score += 5.0;
    }
    
    if(signal.signalType == SIGNAL_TYPE_BUY)
    {
        if(pvsra.rhythmState == RHYTHM_CONVERGENCE_BULLISH) score += 20.0;
        // Divergence is now part of the oscillator info
        if(osc.divergence.isActive && osc.divergence.type == DIV_BULLISH_REGULAR) score += 30.0;
        if(wave.isImpulsePattern && (wave.currentWave == CSonicRWavePattern::WAVE_IMPULSE_3 || wave.currentWave == CSonicRWavePattern::WAVE_IMPULSE_5)) score += 15.0;
        if(pvsra.rhythmState == RHYTHM_DIVERGENCE_BEARISH) score -= 20.0; // Warning
    }
    else if(signal.signalType == SIGNAL_TYPE_SELL)
    {
        if(pvsra.rhythmState == RHYTHM_CONVERGENCE_BEARISH) score += 20.0;
        // Divergence is now part of the oscillator info
        if(osc.divergence.isActive && osc.divergence.type == DIV_BEARISH_REGULAR) score += 30.0;
        if(wave.isImpulsePattern && (wave.currentWave == CSonicRWavePattern::WAVE_IMPULSE_3 || wave.currentWave == CSonicRWavePattern::WAVE_IMPULSE_5)) score += 15.0;
        if(pvsra.rhythmState == RHYTHM_DIVERGENCE_BULLISH) score -= 20.0; // Warning
    }

    return MathMax(0, score);
}

//+------------------------------------------------------------------+
//| BuildSignalReason                                                |
//+------------------------------------------------------------------+
string CSonicRIntegration::BuildSignalReason(const SSonicRUnifiedSignal &signal, 
                                             const SDragonBandInfo &band,
                                             const SOscillatorInfo &osc,
                                             const SVPSRAInfo &pvsra,
                                             const CSonicRWavePattern::SWavePattern &wave)
{
    string reason = "";
    //--- Market Profile Analysis
    if(CheckPointer(m_pMarketAnalysisManager) == POINTER_INVALID || CheckPointer(m_pMarketAnalysisManager.GetMarketProfile()) == POINTER_INVALID) return "";
    ENUM_MARKET_REGIME currentRegime = m_pMarketAnalysisManager.GetMarketProfile().GetCurrentRegime();
    double poc = m_pMarketAnalysisManager.GetMarketProfile().GetPointOfControl();
    double vah = m_pMarketAnalysisManager.GetMarketProfile().GetValueAreaHigh();
    double val = m_pMarketAnalysisManager.GetMarketProfile().GetValueAreaLow();
    double currentPrice = m_pMarketAnalysisManager.GetContext().pSymbolInfo.Bid();

    reason += "MP(" + EnumToString(currentRegime) + "); ";
    if (MathAbs(currentPrice - poc) / m_pMarketAnalysisManager.GetContext().pSymbolInfo.GetPipSize() < 10) reason += "NearPOC; ";
    if (signal.signalType == SIGNAL_TYPE_BUY && currentPrice < val) reason += "BelowVAL; ";
    if (signal.signalType == SIGNAL_TYPE_SELL && currentPrice > vah) reason += "AboveVAH; ";

    //--- Original Reasons
    if(band.breakoutState == DRAGON_BREAKOUT_UP) reason += "DB_Break(Up); ";
    if(band.breakoutState == DRAGON_BREAKOUT_DOWN) reason += "DB_Break(Down); ";
    if(pvsra.rhythmState == RHYTHM_CONVERGENCE_BULLISH) reason += "PVSRA(BullConv); ";
    if(pvsra.rhythmState == RHYTHM_CONVERGENCE_BEARISH) reason += "PVSRA(BearConv); ";
    if(osc.divergence.isActive && osc.divergence.type == DIV_BULLISH_REGULAR) reason += "Div(Bull); ";
    if(osc.divergence.isActive && osc.divergence.type == DIV_BEARISH_REGULAR) reason += "Div(Bear); ";
    if(wave.isImpulsePattern) reason += StringFormat("Wave(%s); ", wave.GetWaveTypeString(wave.currentWave));
    return reason;
}

//+------------------------------------------------------------------+
//| GetLastSignal                                                    |
//+------------------------------------------------------------------+
bool CSonicRIntegration::GetLastSignal(SSonicRUnifiedSignal &signal)
{
    if(m_lastSignal.isValid)
    {
        signal = m_lastSignal;
        return true;
    }
    return false;
}

