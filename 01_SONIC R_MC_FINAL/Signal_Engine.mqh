//+------------------------------------------------------------------+
//|                 Signal_Engine.mqh - Strategy Orchestrator        |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNAL_ENGINE_MQH_
#define APEX_SIGNAL_ENGINE_MQH_

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"
#include "Analysis_Indicators.mqh"
#include "Signal_Strategy.mqh"
#include "Signal_SonicR_Integration.mqh" // Sonic R Integration Layer

// Logging Macros - to reduce dependency visibility
#define LOG_INFO(message) if(m_pLogger) m_pLogger->LogInfo(message)
#define LOG_ERROR(message) if(m_pLogger) m_pLogger->LogError(message)

// Helper to convert ENUM_STRATEGY_TYPE to string
string EnumToString(ENUM_STRATEGY_TYPE type)
{
    switch(type)
    {
        case STRATEGY_SONICR_CLASSIC: return "STRATEGY_SONICR_CLASSIC";
        case STRATEGY_SONICR_ADVANCED: return "STRATEGY_SONICR_ADVANCED";
        default: return "UNKNOWN_STRATEGY";
    }
}

// Namespace has been removed.

//+------------------------------------------------------------------+
//| CSignalEngine - ACTIVE Implementation with Real Signal Logic     |
//+------------------------------------------------------------------+
class CSignalEngine {
private:
    bool                    m_initialized;
    CLogger*                m_pLogger;
    
    // Strategy Management
    ISignalStrategy*        m_strategies[10]; // Array to hold strategy pointers
    int                     m_strategyCount;
    ISignalStrategy*        m_pCurrentStrategy; // Pointer to the active strategy
    
    // Sonic R Specific
    CSonicRIntegration*     m_pSonicRIntegration; // Direct pointer to the integration module
    SSonicRUnifiedSignal    m_lastSonicRSignal;   // Stores the last detailed signal from Sonic R
    bool                    m_isLastSignalFromSonicR; // Flag to indicate the source of the last signal
    
public:
    CSignalEngine() : m_initialized(false), m_pLogger(NULL), m_strategyCount(0), 
                      m_pCurrentStrategy(NULL), m_pSonicRIntegration(NULL), m_isLastSignalFromSonicR(false)
    {
        m_lastSonicRSignal.Reset();
        for(int i = 0; i < 10; i++) m_strategies[i] = NULL;
    }
    
    ~CSignalEngine() 
    {
        Deinitialize();
    }
    
    // The engine is initialized with dependencies
    bool Initialize(CLogger* pLogger, CSonicRIntegration* pSonicRIntegration)
    {
        if(!pLogger || !pSonicRIntegration)
        {
            LOG_ERROR("NULL pointer received.");
            return false;
        }
        
        m_pLogger = pLogger;
        m_pSonicRIntegration = pSonicRIntegration; // Store the Sonic R integration module
        
        m_initialized = true;
        LOG_INFO("CSignalEngine initialized successfully.");
        return true;
    }
    
    void Deinitialize()
    {
        if(m_pLogger) LOG_INFO("Deinitializing Signal Engine...");
        for(int i = 0; i < m_strategyCount; i++)
        {
            // We only delete strategies that were created with 'new' inside the EA
            // Strategies are managed globally, so we don't delete them here.
        // We just clear the pointers.
        m_strategies[i] = NULL;
        }
        m_strategyCount = 0;
        m_pCurrentStrategy = NULL;
        m_pSonicRIntegration = NULL; // Just nullify the pointer, don't delete
        m_initialized = false;
    }
    
    ENUM_SIGNAL_TYPE CheckForSignal()
    {
        if(!m_initialized || m_pCurrentStrategy == NULL) 
        {
            return SIGNAL_TYPE_NONE;
        }

        m_isLastSignalFromSonicR = false; // Reset flag

        // The current strategy handles all logic, including Sonic R if it's the active one.
        ENUM_SIGNAL_TYPE signalType = m_pCurrentStrategy->CheckForSignal();

        // If the active strategy is the Sonic R integration, we need to capture its detailed signal.
        if (m_pCurrentStrategy == m_pSonicRIntegration && signalType != SIGNAL_TYPE_NONE)
        { 
            // The integration module should have a way to provide the last signal.
            if(m_pSonicRIntegration->GetLastSignal(m_lastSonicRSignal))
            {
                m_isLastSignalFromSonicR = true;
            }
        }

        return signalType;
    }
    
    bool GetSignalInfo(SSignalInfo& signalInfo)
    {
        if(!m_initialized || m_pCurrentStrategy == NULL) {
            return false;
        }

        // If the last signal was from Sonic R, provide detailed Sonic R signal info
        if(m_isLastSignalFromSonicR) {
            signalInfo.Reset();
            signalInfo.IsValid = true;
            signalInfo.Direction = m_lastSonicRSignal.signalType;
            signalInfo.Timestamp = m_lastSonicRSignal.timestamp;
            signalInfo.sonicConfidenceScore = m_lastSonicRSignal.confidenceScore;
            signalInfo.sonicReason = m_lastSonicRSignal.reason;
            signalInfo.Comment = StringFormat("SonicR Signal (Score: %.1f)", m_lastSonicRSignal.confidenceScore);
            return true;
        }

        // Otherwise, let the current strategy provide the signal info
        return m_pCurrentStrategy->GetSignalInfo(signalInfo);
    }
    
    // Getters
    bool IsInitialized() const { return m_initialized; }
    
    string GetCurrentStrategyName() const
    {
        if(m_pCurrentStrategy != NULL)
            return m_pCurrentStrategy->GetStrategyName();
        return "None";
    }

    // --- Strategy Management ---
    bool RegisterStrategy(ENUM_STRATEGY_TYPE type, ISignalStrategy* strategy)
    {
        if (m_strategyCount >= 10 || strategy == NULL)
        {
            LOG_ERROR("Failed to register strategy: Limit reached or NULL pointer.");
            return false;
        }
        strategy->SetStrategyType(type);
        m_strategies[m_strategyCount++] = strategy;
        LOG_INFO("Strategy '" + strategy->GetStrategyName() + "' registered.");
        return true;
    }

    bool SetStrategy(ENUM_STRATEGY_TYPE type)
    {
        for(int i = 0; i < m_strategyCount; i++)
        {
            if(m_strategies[i]->GetStrategyType() == type)
            {
                m_pCurrentStrategy = m_strategies[i];
                LOG_INFO("Active strategy set to: " + m_pCurrentStrategy->GetStrategyName());
                return true;
            }
        }
        LOG_ERROR("Could not find strategy of type " + EnumToString(type));
        return false;
    }
};

// End of namespace removal

#endif
