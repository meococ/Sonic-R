//+------------------------------------------------------------------+
//|       Analysis_SonicR_PVSRA.mqh - Volume Price Swing Rhythm      |
//|                  APEX Pullback EA v4.6 - Refactored              |
//|      "Refactored for Flat Architecture and DSI Pattern"          |
//+------------------------------------------------------------------+

#ifndef APEX_ANALYSIS_SONICR_PVSRA_MQH_
#define APEX_ANALYSIS_SONICR_PVSRA_MQH_

#include "SonicR_CommonStructs.mqh"

namespace ApexSonicR {

//+------------------------------------------------------------------+
//| CSonicRPVSRA - Analyzes the rhythm between price and volume      |
//+------------------------------------------------------------------+
class CSonicRPVSRA
{
private:
    bool                    m_initialized;
    CLogger*                m_pLogger;
    CSymbolInfo*            m_pSymbolInfo;

    // Configuration
    int                     m_volumeAvgPeriod;
    double                  m_highVolFactor;
    double                  m_lowVolFactor;

    // Data Buffers
    long                    m_bufVolume[];

    // State
    SVPSRAInfo              m_currentRhythm;

public:
    CSonicRPVSRA() : 
        m_initialized(false), 
        m_pLogger(NULL), 
        m_pSymbolInfo(NULL),
        m_volumeAvgPeriod(20), 
        m_highVolFactor(1.8), 
        m_lowVolFactor(0.8)
    {
        ArraySetAsSeries(m_bufVolume, true);
    }

    ~CSonicRPVSRA() {}

    //+------------------------------------------------------------------+
    //| Initialize                                                       |
    //+------------------------------------------------------------------+
    bool Initialize(CLogger* pLogger, CSymbolInfo* pSymbolInfo)
    {
        if(!pLogger || !pSymbolInfo)
        {
            Print("ERROR: CSonicRPVSRA::Initialize - NULL pointers received");
            return false;
        }
        m_pLogger = pLogger;
        m_pSymbolInfo = pSymbolInfo;

        m_initialized = true;
        Print("CSonicRPVSRA initialized successfully.");
        return true;
    }

    //+------------------------------------------------------------------+
    //| Deinitialize                                                     |
    //+------------------------------------------------------------------+
    void Deinitialize()
    {
        m_initialized = false;
    }

    //+------------------------------------------------------------------+
    //| Main analysis method                                             |
    //+------------------------------------------------------------------+
    bool Update(const int shift)
    {
        return AnalyzeRhythm(shift);
    }

    // Data Access
    SVPSRAInfo GetContext() { return m_currentRhythm; }

private:
    bool AnalyzeRhythm(const int shift)
    {
        if(!m_initialized) return false;

        ZeroMemory(m_currentRhythm);

        // 1. Analyze Volume
        if(!AnalyzeVolume(shift))
            return false;

        // 2. Analyze Price Swing
        double swingStrength;
        bool isUpSwing;
        if(!AnalyzePriceSwing(swingStrength, isUpSwing))
            return false;

        // 3. Determine Rhythm State and Correlation
        DetermineRhythmState(swingStrength, isUpSwing);

        return true;
    }

private:
    //+------------------------------------------------------------------+
    //| 1. Analyze current and average volume                            |
    //+------------------------------------------------------------------+
    bool AnalyzeVolume(const int shift)
    {
        int barsToCopy = shift + m_volumeAvgPeriod + 1;
        if(CopyTickVolume(Symbol(), PERIOD_CURRENT, shift, barsToCopy, m_bufVolume) < barsToCopy)
        {
            Print("Could not copy volume data.");
            return false;
        }

        double volSum = 0;
        for(int i = 0; i < m_volumeAvgPeriod; i++)
        {
            volSum += m_bufVolume[i+1]; // Average of previous bars, not including current
        }
        double avgVolume = volSum / m_volumeAvgPeriod;
        if(avgVolume == 0) avgVolume = 1; // Avoid division by zero

        long currentVolume = m_bufVolume[shift];
        m_currentRhythm.isHighVolume = currentVolume > avgVolume * m_highVolFactor;
        m_currentRhythm.isLowVolume = currentVolume < avgVolume * m_lowVolFactor;
        m_currentRhythm.volumeStrength = currentVolume / avgVolume;

        return true;
    }

    //+------------------------------------------------------------------+
    //| 2. Analyze the most recent price swing                           |
    //+------------------------------------------------------------------+
    bool AnalyzePriceSwing(double& swingStrength, bool &isUpSwing)
    {
        // Simplified implementation
        swingStrength = 1.0;
        isUpSwing = true;
        return true;
    }

    //+------------------------------------------------------------------+
    //| 3. Determine the rhythm state by correlating price and volume    |
    //+------------------------------------------------------------------+
    void DetermineRhythmState(const double swingStrength, const bool isUpSwing)
    {
        m_currentRhythm.rhythmState = RHYTHM_UNKNOWN;
        m_currentRhythm.rhythmScore = 0.0;

        // Convergence (Trend continuation)
        if(m_currentRhythm.isHighVolume)
        {
            if(isUpSwing)
                m_currentRhythm.rhythmState = RHYTHM_CONVERGENCE_BULLISH;
            else
                m_currentRhythm.rhythmState = RHYTHM_CONVERGENCE_BEARISH;
            m_currentRhythm.rhythmScore = m_currentRhythm.volumeStrength * swingStrength;
        }
        // Divergence (Potential reversal)
        else if(m_currentRhythm.isLowVolume)
        {
            if(isUpSwing)
                m_currentRhythm.rhythmState = RHYTHM_DIVERGENCE_BEARISH; // Up-move on low volume is weak
            else
                m_currentRhythm.rhythmState = RHYTHM_DIVERGENCE_BULLISH; // Down-move on low volume is weak
            m_currentRhythm.rhythmScore = (1 / fmax(0.1, m_currentRhythm.volumeStrength)) * swingStrength;
        }
    }
};

} // namespace ApexSonicR

#endif // APEX_ANALYSIS_SONICR_PVSRA_MQH_


