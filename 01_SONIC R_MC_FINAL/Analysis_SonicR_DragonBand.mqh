//+------------------------------------------------------------------+
//|           Analysis_SonicR_DragonBand.mqh - Dragon Band Module    |
//|                  APEX Pullback EA v4.6 - Refactored              |
//|      "Refactored for Flat Architecture and DSI Pattern"          |
//+------------------------------------------------------------------+

#ifndef APEX_ANALYSIS_SONICR_DRAGONBAND_MQH_
#define APEX_ANALYSIS_SONICR_DRAGONBAND_MQH_

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"
#include "Analysis_Indicators.mqh" // Corrected path if needed

// Namespace removed for global scope compatibility

//+------------------------------------------------------------------+
//| CSonicRDragonBand - Refactored for Dependency Injection          |
//+------------------------------------------------------------------+
class CSonicRDragonBand
{
private:
    bool                    m_initialized;
    CLogger*                m_pLogger;
    CIndicators*            m_pIndicators; // Using the correct class name CIndicators
    
    // Configuration from Core_Inputs.mqh (passed via methods)
    int                     m_emaPeriod;
    int                     m_atrPeriod;
    double                  m_volatilityMultiplier;
    int                     m_anglePeriod;
    double                  m_minAngle;

    // Buffers for storing indicator data retrieved from CAppIndicators
    double                  m_bufEMAHigh[];
    double                  m_bufEMALow[];
    double                  m_bufEMAClose[];
    double                  m_bufATR[];

    // Internal state
    SDragonBandInfo         m_dragonBandInfo;

public:
    CSonicRDragonBand() : m_initialized(false), m_pLogger(NULL), m_pIndicators(NULL),
                          m_emaPeriod(34), m_atrPeriod(14), m_volatilityMultiplier(2.0),
                          m_anglePeriod(5), m_minAngle(1.5)
    {
        // Set buffers to be used as series arrays
        ArraySetAsSeries(m_bufEMAHigh, true);
        ArraySetAsSeries(m_bufEMALow, true);
        ArraySetAsSeries(m_bufEMAClose, true);
        ArraySetAsSeries(m_bufATR, true);
    }
    
    ~CSonicRDragonBand() {}
    
    //+------------------------------------------------------------------+
    //| Initialize with dependencies                                     |
    //+------------------------------------------------------------------+
    bool Initialize(CLogger* pLogger, CIndicators* pIndicators)
    {
        if(!pLogger || !pIndicators)
        {
            Print("ERROR: CSonicRDragonBand::Initialize - NULL pointers received");
            return false;
        }
        
        m_pLogger = pLogger;
        m_pIndicators = pIndicators;
        
        // Configuration can be set via a dedicated method after initialization
        
        m_initialized = true;
        LOG_INFO("CSonicRDragonBand initialized successfully");
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Set configuration parameters                                     |
    //+------------------------------------------------------------------+
    void SetConfig(int emaPeriod, int atrPeriod, double volMultiplier, int anglePeriod, double minAngle)
    {
        m_emaPeriod = emaPeriod;
        m_atrPeriod = atrPeriod;
        m_volatilityMultiplier = volMultiplier;
        m_anglePeriod = anglePeriod;
        m_minAngle = minAngle;
    }

    //+------------------------------------------------------------------+
    //| Main analysis method                                             |
    //+------------------------------------------------------------------+
    bool Update(const int shift)
    {
        return Analyze(shift, m_dragonBandInfo);
    }

    // Data Access
    SDragonBandInfo* GetContext() { return &m_dragonBandInfo; }

private:
    bool Analyze(const int shift, SDragonBandInfo& bandInfo)
    {
        if(!m_initialized || !m_pIndicators)
        {
            return false;
        }

        // 1. Get required data from the Indicators module
        // This part needs to be adapted to the actual methods available in CIndicators
        // For now, we assume direct access to buffers after CIndicators::OnTick() is called.
        m_pIndicators.RefreshData(); // Ensure data is fresh

        // We will use the getter methods from CIndicators
        bandInfo.upperBand = m_pIndicators.GetDragonHigh(shift);
        bandInfo.lowerBand = m_pIndicators.GetDragonLow(shift);
        bandInfo.middleBand = m_pIndicators.GetDragonClose(shift);
        // ATR is not part of the current CIndicators, this will need to be added or handled differently.
        // For now, we'll use a placeholder.
        bandInfo.currentVolatility = 0.0; // Placeholder


        // 2. Populate the core values
        bandInfo.upperBand = m_bufEMAHigh[shift];
        bandInfo.lowerBand = m_bufEMALow[shift];
        bandInfo.middleBand = m_bufEMAClose[shift];
        bandInfo.currentVolatility = m_bufATR[shift];
        bandInfo.bandWidth = bandInfo.upperBand - bandInfo.lowerBand;
        
        // 3. Update dynamic state (expansion/contraction)
        double prev_width = m_bufEMAHigh[shift+1] - m_bufEMALow[shift+1];
        if(prev_width > 0)
        {
            bandInfo.isExpanding = bandInfo.bandWidth > prev_width;
            bandInfo.isContracting = bandInfo.bandWidth < prev_width;
        }

        // 4. Analyze Trend Angle
        double current_price = m_bufEMAClose[shift];
        double past_price = m_bufEMAClose[shift + m_anglePeriod];
        if(current_price > 0 && past_price > 0)
        {
            double slope = (current_price - past_price) / m_anglePeriod;
            bandInfo.angle = MathArctan(slope / current_price * 10000) * 180 / M_PI;
        }

        if(bandInfo.angle > m_minAngle) bandInfo.trendState = DRAGON_TREND_UP;
        else if(bandInfo.angle < -m_minAngle) bandInfo.trendState = DRAGON_TREND_DOWN;
        else bandInfo.trendState = DRAGON_TREND_NONE;

        // 5. Detect Breakouts
        MqlRates rates[];
        if(CopyRates(Symbol(), Period(), shift, 2, rates) == 2)
        {
            if(rates[0].close > bandInfo.upperBand && rates[1].close <= m_bufEMAHigh[shift+1])
                bandInfo.breakoutState = DRAGON_BREAKOUT_UP;
            else if(rates[0].close < bandInfo.lowerBand && rates[1].close >= m_bufEMALow[shift+1])
                bandInfo.breakoutState = DRAGON_BREAKOUT_DOWN;
            else
                bandInfo.breakoutState = DRAGON_BREAKOUT_NONE;
        }

        return true;
    }
};

// End of removed namespace
#endif // APEX_ANALYSIS_SONICR_DRAGONBAND_MQH_


