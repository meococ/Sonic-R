//+------------------------------------------------------------------+
//|       Signal_SonicR_Classic_Strategy.mqh - Concrete Strategy     |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNAL_SONICR_CLASSIC_STRATEGY_MQH_
#define APEX_SIGNAL_SONICR_CLASSIC_STRATEGY_MQH_

#include "Signal_Strategy.mqh"
#include "Analysis_SonicR_WavePattern.mqh"
#include "Analysis_SonicR_PVSRA.mqh"
#include "Core_Inputs.mqh"

//+------------------------------------------------------------------+
//| CSonicRClassicStrategy - Enhanced Sonic R Trading Strategy      |
//| Advanced wave pattern detection with multi-factor confirmation  |
//+------------------------------------------------------------------+
class CSonicRClassicStrategy : public ISignalStrategy
{
private:
    bool                m_initialized;
    CLogger*            m_pLogger;
    CWaveAnalysis*      m_pWaveAnalysis;
    CSonicRDragon*      m_pDragonAnalysis;
    CPVSRAAnalysis*     m_pPVSRAAnalysis;
    
    // Enhanced Configuration
    double              m_minDragonAngle;
    double              m_minWaveStrength;        // Minimum wave pattern strength
    double              m_minDragonStrength;      // Minimum Dragon strength
    double              m_riskRewardRatio;
    int                 m_slBufferPips;
    
    // Advanced Filtering
    bool                m_useMultiTimeframeFilter;  // MTF trend confirmation
    bool                m_useDragonSqueezeFilter;   // Dragon squeeze detection
    bool                m_useVolumeConfirmation;    // Enhanced volume analysis
    double              m_minWaveQuality;           // Minimum wave quality score
    
    // Signal Strength Calculation
    double              m_lastSignalStrength;       // Overall signal strength
    datetime            m_lastSignalTime;           // Last signal timestamp

    // State for signal info
    SSignalInfo         m_lastSignalInfo;

public:
    CSonicRClassicStrategy() : m_initialized(false), m_pLogger(NULL), 
                               m_pWaveAnalysis(NULL), m_pDragonAnalysis(NULL), m_pPVSRAAnalysis(NULL),
                               m_minDragonAngle(15.0), m_minWaveStrength(0.6), m_minDragonStrength(0.5),
                               m_riskRewardRatio(2.0), m_slBufferPips(5),
                               m_useMultiTimeframeFilter(true), m_useDragonSqueezeFilter(true),
                               m_useVolumeConfirmation(true), m_minWaveQuality(0.7),
                               m_lastSignalStrength(0.0), m_lastSignalTime(0)
    {
        m_lastSignalInfo.Type = SIGNAL_NONE;
    }

    virtual ~CSonicRClassicStrategy() {}

    // --- ISignalStrategy Implementation ---
    virtual bool Initialize(CLogger* pLogger, CIndicators* pIndicators, CWaveAnalysis* pWave, CPVSRAAnalysis* pPVSRA, CSonicRDragon* pDragon) override
    {
        if (!pLogger || !pWave || !pDragon || !pPVSRA)
        {
            LOG_ERROR("Received NULL pointers for Classic Strategy.");
            return false;
        }

        m_pLogger = pLogger;
        m_pWaveAnalysis = pWave;
        m_pDragonAnalysis = pDragon;
        m_pPVSRAAnalysis = pPVSRA;
        // pIndicators is not used in the classic strategy but is part of the interface
         
         // Initialize enhanced parameters from inputs
         m_minDragonAngle = InpMinDragonAngle;
         m_riskRewardRatio = InpRiskRewardRatio;
         m_slBufferPips = InpSLBufferPips;
         
         // Configure enhanced filtering
         m_useMultiTimeframeFilter = true;
         m_useDragonSqueezeFilter = true;
         m_useVolumeConfirmation = true;
         m_minWaveQuality = 0.7;
         m_minWaveStrength = 0.6;
         m_minDragonStrength = 0.5;
         
         m_initialized = true;
         LOG_INFO("CSonicRClassicStrategy initialized successfully with enhanced Sonic R parameters.");
         return true;
     }
    
    virtual ENUM_SIGNAL_TYPE CheckForSignal() override
    {
        if (!m_initialized)
        {
            LOG_ERROR("CSonicRClassicStrategy not initialized.");
            return SIGNAL_NONE;
        }

        // Reset signal info
        m_lastSignalInfo.Type = SIGNAL_NONE;
        m_lastSignalInfo.Timestamp = TimeCurrent();

        // Step 1: Enhanced Wave Pattern Analysis
        ENUM_SIGNAL_TYPE waveSignal = m_pWaveAnalysis->GetLastWavePattern();
        if (waveSignal == SIGNAL_NONE)
        {
            return SIGNAL_NONE;
        }
        
        // Check wave quality and strength
        double waveStrength = m_pWaveAnalysis->GetLastWaveStrength();
        double waveQuality = m_pWaveAnalysis->GetWaveQualityScore();
        bool isWaveValid = m_pWaveAnalysis->IsWaveValid();
        
        if (!isWaveValid || waveStrength < m_minWaveStrength || waveQuality < m_minWaveQuality)
        {
            LOG_DEBUG(StringFormat("Wave validation failed: Valid=%s, Strength=%.3f, Quality=%.3f",
                     isWaveValid ? "true" : "false", waveStrength, waveQuality));
            return SIGNAL_NONE;
        }

        // Step 2: Enhanced PVSRA Analysis
        if (!m_pPVSRAAnalysis->CanTrade(waveSignal))
        {
            LOG_DEBUG("Sonic R signal rejected by PVSRA filter.");
            return SIGNAL_NONE;
        }
        
        // Volume confirmation if enabled
        if (m_useVolumeConfirmation)
        {
            bool volumeConfirmed = m_pPVSRAAnalysis->IsVolumeConfirmed();
            if (!volumeConfirmed)
            {
                LOG_DEBUG("Volume confirmation failed");
                return SIGNAL_NONE;
            }
        }

        // Step 3: Enhanced Dragon Analysis
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double dragonHigh = m_pDragonAnalysis->GetDragonHigh(0);
        double dragonLow = m_pDragonAnalysis->GetDragonLow(0);
        double dragonMiddle = m_pDragonAnalysis->GetDragonMiddle(0);
        double trendLine = m_pDragonAnalysis->GetTrendLine(0);
        double dragonAngle = m_pDragonAnalysis->CalculateAdaptiveDragonAngle();
        double dragonStrength = m_pDragonAnalysis->GetDragonStrength();
        
        // Check Dragon strength
        if (dragonStrength < m_minDragonStrength)
        {
            LOG_DEBUG(StringFormat("Dragon strength insufficient: %.3f < %.3f", dragonStrength, m_minDragonStrength));
            return SIGNAL_NONE;
        }
        
        // Dragon squeeze filter
        if (m_useDragonSqueezeFilter && m_pDragonAnalysis->IsDragonSqueeze())
        {
            LOG_DEBUG("Dragon squeeze detected - waiting for breakout");
            return SIGNAL_NONE;
        }

        // Step 4: Multi-timeframe confirmation
        bool mtfConfirmation = true;
        if (m_useMultiTimeframeFilter)
        {
            mtfConfirmation = CheckMultiTimeframeConfirmation(waveSignal);
            if (!mtfConfirmation)
            {
                LOG_DEBUG("Multi-timeframe confirmation failed");
                return SIGNAL_NONE;
            }
        }

        // Step 5: Signal Generation with Enhanced Logic
        ENUM_SIGNAL_TYPE signalType = SIGNAL_NONE;
        
        // Enhanced BUY signal
        if (waveSignal == SIGNAL_BUY)
        {
            bool dragonBullish = (currentPrice > dragonHigh && currentPrice > trendLine && dragonAngle > m_minDragonAngle);
            bool dragonBreakout = m_pDragonAnalysis->IsDragonBreakout() && currentPrice > dragonHigh;
            
            if (dragonBullish || dragonBreakout)
            {
                signalType = SIGNAL_BUY;
            }
        }
        // Enhanced SELL signal
        else if (waveSignal == SIGNAL_SELL)
        {
            bool dragonBearish = (currentPrice < dragonLow && currentPrice < trendLine && dragonAngle < -m_minDragonAngle);
            bool dragonBreakout = m_pDragonAnalysis->IsDragonBreakout() && currentPrice < dragonLow;
            
            if (dragonBearish || dragonBreakout)
            {
                signalType = SIGNAL_SELL;
            }
        }
        
        // Finalize signal if detected
        if (signalType != SIGNAL_NONE)
        {
            m_lastSignalInfo.Type = signalType;
            m_lastSignalInfo.Timestamp = TimeCurrent();
            
            m_lastSignalStrength = CalculateEnhancedSignalStrength(signalType, waveStrength, dragonStrength, dragonAngle);
            m_lastSignalTime = TimeCurrent();
            
            LOG_INFO(StringFormat("%s signal detected: Wave(%.3f), Dragon(%.2f°/%.3f), MTF=%s",
                     signalType == SIGNAL_BUY ? "BUY" : "SELL",
                     waveStrength, dragonAngle, dragonStrength,
                     mtfConfirmation ? "true" : "false"));
            
            return signalType;
        }

        return SIGNAL_NONE;
    }
    
    virtual SSignalInfo GetLastSignalInfo() override
    {
        if(m_lastSignalInfo.Type == SIGNAL_NONE) return m_lastSignalInfo;

        // --- DYNAMIC SL/TP CALCULATION ---
        double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

        if (m_lastSignalInfo.Type == SIGNAL_BUY)
        {
            m_lastSignalInfo.EntryPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            SSwingPoint* last_swing_low = m_pWaveAnalysis.GetLastSwing(SWING_LOW);
            if(last_swing_low == NULL || last_swing_low.time == 0) return m_lastSignalInfo;

            m_lastSignalInfo.StopLoss = last_swing_low.price - (m_slBufferPips * point);
            double sl_distance = m_lastSignalInfo.EntryPrice - m_lastSignalInfo.StopLoss;
            if(sl_distance <= 0) return m_lastSignalInfo;
            m_lastSignalInfo.TakeProfit = m_lastSignalInfo.EntryPrice + (sl_distance * m_riskRewardRatio);
        }
        else if (m_lastSignalInfo.Type == SIGNAL_SELL)
        {
            m_lastSignalInfo.EntryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            SSwingPoint* last_swing_high = m_pWaveAnalysis.GetLastSwing(SWING_HIGH);
            if(last_swing_high == NULL || last_swing_high.time == 0) return m_lastSignalInfo;

            m_lastSignalInfo.StopLoss = last_swing_high.price + (m_slBufferPips * point);
            double sl_distance = m_lastSignalInfo.StopLoss - m_lastSignalInfo.EntryPrice;
            if(sl_distance <= 0) return m_lastSignalInfo;
            m_lastSignalInfo.TakeProfit = m_lastSignalInfo.EntryPrice - (sl_distance * m_riskRewardRatio);
        }
        
        LOG_DEBUG(StringFormat("Signal Info Prepared - Entry: %.5f, SL: %.5f, TP: %.5f", 
                                          m_lastSignalInfo.EntryPrice, m_lastSignalInfo.StopLoss, m_lastSignalInfo.TakeProfit));
        
        return m_lastSignalInfo;
    }

    virtual void Reset() override
    {
        m_lastSignalInfo.Reset();
    }
     
     // Enhanced Configuration Methods
     void SetMinDragonAngle(double angle) { m_minDragonAngle = angle; }
     void SetMinWaveStrength(double strength) { m_minWaveStrength = strength; }
     void SetMinDragonStrength(double strength) { m_minDragonStrength = strength; }
     void SetRiskRewardRatio(double ratio) { m_riskRewardRatio = ratio; }
     void SetSLBufferPips(int pips) { m_slBufferPips = pips; }
     void SetMinWaveQuality(double quality) { m_minWaveQuality = quality; }
     
     void EnableMultiTimeframeFilter(bool enable) { m_useMultiTimeframeFilter = enable; }
     void EnableDragonSqueezeFilter(bool enable) { m_useDragonSqueezeFilter = enable; }
     void EnableVolumeConfirmation(bool enable) { m_useVolumeConfirmation = enable; }
     
     // Enhanced Getters
     double GetMinDragonAngle() const { return m_minDragonAngle; }
     double GetMinWaveStrength() const { return m_minWaveStrength; }
     double GetMinDragonStrength() const { return m_minDragonStrength; }
     double GetLastSignalStrength() const { return m_lastSignalStrength; }
     datetime GetLastSignalTime() const { return m_lastSignalTime; }
     
     bool IsMultiTimeframeFilterEnabled() const { return m_useMultiTimeframeFilter; }
     bool IsDragonSqueezeFilterEnabled() const { return m_useDragonSqueezeFilter; }
     bool IsVolumeConfirmationEnabled() const { return m_useVolumeConfirmation; }

private:
    // Enhanced Helper Methods
    double CalculateEnhancedSignalStrength(ENUM_SIGNAL_TYPE signalType, double waveStrength, 
                                         double dragonStrength, double dragonAngle)
    {
        double strength = 0.3; // Base strength
        
        // Wave strength contribution (40%)
        strength += waveStrength * 0.4;
        
        // Dragon strength contribution (30%)
        strength += dragonStrength * 0.3;
        
        // Dragon angle contribution (20%)
        double angleStrength = MathMin(MathAbs(dragonAngle) / 45.0, 1.0); // Normalize to 0-1 (45° = max)
        strength += angleStrength * 0.2;
        
        // Dragon breakout bonus (10%)
        if (m_pDragonAnalysis.IsDragonBreakout())
        {
            strength += 0.1;
        }
        
        return MathMin(strength, 1.0);
    }
    
    double CalculateSignalConfidence(double waveQuality, double dragonStrength, bool mtfConfirmation)
    {
        double confidence = 0.0;
        
        // Wave quality contribution (40%)
        confidence += waveQuality * 0.4;
        
        // Dragon strength contribution (35%)
        confidence += dragonStrength * 0.35;
        
        // Multi-timeframe confirmation (25%)
        if (mtfConfirmation)
        {
            confidence += 0.25;
        }
        
        return MathMin(confidence, 1.0);
    }
    
    bool CheckMultiTimeframeConfirmation(ENUM_SIGNAL_TYPE signalType)
    {
        // Get higher timeframe trend from Dragon analysis
        ENUM_TIMEFRAMES higherTf = GetHigherTimeframe();
        if (higherTf == PERIOD_CURRENT)
        {
            return true; // Skip if no higher timeframe available
        }
        
        // Check higher timeframe Dragon trend
        double htfTrendAngle = m_pDragonAnalysis.GetHigherTimeframeTrend();
        
        if (signalType == SIGNAL_BUY)
        {
            return htfTrendAngle > 0; // Higher TF should be bullish
        }
        else if (signalType == SIGNAL_SELL)
        {
            return htfTrendAngle < 0; // Higher TF should be bearish
        }
        
        return false;
    }
    
    void CalculateEnhancedStopLossAndTakeProfit(ENUM_SIGNAL_TYPE signalType)
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
        int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
        
        // Get Dragon levels for enhanced SL/TP calculation
        double dragonHigh = m_pDragonAnalysis->GetDragonHigh(0);
        double dragonLow = m_pDragonAnalysis->GetDragonLow(0);
        double dragonMiddle = m_pDragonAnalysis->GetDragonMiddle(0);
        
        if (signalType == SIGNAL_BUY)
        {
            // Enhanced BUY SL: Use the lower of swing low or Dragon low
            SSwingPoint* lastSwingLow = m_pWaveAnalysis->GetLastSwing(SWING_LOW);
            double swingLow = (lastSwingLow != NULL) ? lastSwingLow->price : dragonLow;
            double dragonSL = dragonLow - (m_slBufferPips * point);
            double swingSL = swingLow - (m_slBufferPips * point);
            
            m_lastSignalInfo.StopLoss = MathMin(dragonSL, swingSL);
            
            // Enhanced TP: Consider Dragon width for dynamic targets
            double dragonWidth = dragonHigh - dragonLow;
            double riskPips = (currentPrice - m_lastSignalInfo.StopLoss) / point;
            double baseRewardPips = riskPips * m_riskRewardRatio;
            
            // Adjust TP based on Dragon width (wider Dragon = higher targets)
            double widthMultiplier = MathMax(1.0, dragonWidth / (100 * point)); // Normalize width
            double adjustedRewardPips = baseRewardPips * MathMin(widthMultiplier, 2.0); // Cap at 2x
            
            m_lastSignalInfo.TakeProfit = currentPrice + (adjustedRewardPips * point);
            
            // Alternative TP at next Dragon resistance
            double dragonTP = dragonHigh + (dragonWidth * 0.5);
            if (dragonTP > m_lastSignalInfo.TakeProfit)
            {
                m_lastSignalInfo.TakeProfit = dragonTP;
            }
        }
        else if (signalType == SIGNAL_SELL)
        {
            // Enhanced SELL SL: Use the higher of swing high or Dragon high
            SSwingPoint* lastSwingHigh = m_pWaveAnalysis->GetLastSwing(SWING_HIGH);
            double swingHigh = (lastSwingHigh != NULL) ? lastSwingHigh->price : dragonHigh;
            double dragonSL = dragonHigh + (m_slBufferPips * point);
            double swingSL = swingHigh + (m_slBufferPips * point);
            
            m_lastSignalInfo.StopLoss = MathMax(dragonSL, swingSL);
            
            // Enhanced TP: Consider Dragon width for dynamic targets
            double dragonWidth = dragonHigh - dragonLow;
            double riskPips = (m_lastSignalInfo.StopLoss - currentPrice) / point;
            double baseRewardPips = riskPips * m_riskRewardRatio;
            
            // Adjust TP based on Dragon width
            double widthMultiplier = MathMax(1.0, dragonWidth / (100 * point));
            double adjustedRewardPips = baseRewardPips * MathMin(widthMultiplier, 2.0);
            
            m_lastSignalInfo.TakeProfit = currentPrice - (adjustedRewardPips * point);
            
            // Alternative TP at next Dragon support
            double dragonTP = dragonLow - (dragonWidth * 0.5);
            if (dragonTP < m_lastSignalInfo.TakeProfit)
            {
                m_lastSignalInfo.TakeProfit = dragonTP;
            }
        }
        
        // Ensure proper precision
        m_lastSignalInfo.StopLoss = NormalizeDouble(m_lastSignalInfo.StopLoss, digits);
        m_lastSignalInfo.TakeProfit = NormalizeDouble(m_lastSignalInfo.TakeProfit, digits);
        
        // Calculate final risk-reward ratio
        double risk = MathAbs(currentPrice - m_lastSignalInfo.StopLoss);
        double reward = MathAbs(m_lastSignalInfo.TakeProfit - currentPrice);
        double riskReward = (risk > 0) ? reward / risk : 0.0;
        
        LOG_DEBUG(StringFormat("Enhanced SL/TP: Entry=%.5f, SL=%.5f, TP=%.5f, RR=%.2f",
                 currentPrice, m_lastSignalInfo.StopLoss, m_lastSignalInfo.TakeProfit, riskReward));
    }
    
    ENUM_TIMEFRAMES GetHigherTimeframe()
    {
        ENUM_TIMEFRAMES currentTf = Period();
        
        switch(currentTf)
        {
            case PERIOD_M1:  return PERIOD_M5;
            case PERIOD_M5:  return PERIOD_M15;
            case PERIOD_M15: return PERIOD_H1;
            case PERIOD_H1:  return PERIOD_H4;
            case PERIOD_H4:  return PERIOD_D1;
            case PERIOD_D1:  return PERIOD_W1;
            case PERIOD_W1:  return PERIOD_MN1;
            default:         return PERIOD_CURRENT;
        }
    }
};

#endif // APEX_SIGNAL_SONICR_CLASSIC_STRATEGY_MQH_
