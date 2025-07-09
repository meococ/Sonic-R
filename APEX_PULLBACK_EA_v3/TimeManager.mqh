#ifndef TIMEMANAGER_MQH_
#define TIMEMANAGER_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CTimeManager {
private:
    EAContext*      m_pContext;         // Pointer to the global EA context
    bool            m_IsInitialized;    // Flag to indicate if the manager is initialized
    datetime        m_last_bar_time;    // Time of the last known bar
    ENUM_TIMEFRAMES m_main_timeframe;   // The primary timeframe the EA operates on

public:
    CTimeManager() : m_pContext(NULL),
                     m_IsInitialized(false),
                     m_last_bar_time(0),
                     m_main_timeframe(PERIOD_CURRENT) {
    }

    ~CTimeManager() {}

    bool Initialize(EAContext* pContext) {
        m_pContext = pContext;
        if (m_pContext == NULL) {
            // This is a critical failure, but ErrorHandler might not be available yet.
            // We rely on the caller (CCore) to log this.
            return false;
        }

        if (m_pContext->pSymbolInfo == NULL || !m_pContext->pSymbolInfo->IsInitialized()) {
            if(m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_CRITICAL_STATE, "TimeManager::Initialize - SymbolInfo is not initialized.");
            return false;
        }

        m_main_timeframe = m_pContext->Inputs.MainTimeframe;

        // Initialize with the current bar time to avoid a false new bar on the first tick
        m_last_bar_time = (datetime)SeriesInfoInteger(m_pContext->pSymbolInfo->Symbol(), m_main_timeframe, SERIES_LASTBAR_DATE);
        if (m_last_bar_time == 0) {
            if(m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_HISTORY_NOT_FOUND, "TimeManager::Initialize - Could not retrieve last bar date for " + m_pContext->pSymbolInfo->Symbol() + ". Is chart history available?");
            return false;
        }

        m_IsInitialized = true;
        return true;
    }

    void OnTick() {
        if (!m_IsInitialized || m_pContext == NULL) return;

        // Default to resetting the flag each tick
        m_pContext->IsNewBarEvent = false;

        datetime current_bar_time = (datetime)SeriesInfoInteger(m_pContext->pSymbolInfo->Symbol(), m_main_timeframe, SERIES_LASTBAR_DATE);
        
        if (current_bar_time > m_last_bar_time) {
            m_last_bar_time = current_bar_time;
            m_pContext->IsNewBarEvent = true; // Set the flag for the entire system
            
            if (m_pContext->pLogger != NULL && m_pContext->Inputs.LoggerConfig.LogLevel >= LOG_LEVEL_DEBUG) {
                m_pContext->pLogger->LogDebug("New bar detected on timeframe: " + EnumToString(m_main_timeframe));
            }
        }
    }

    // This function is deprecated for primary logic, as OnTick now manages the state.
    // It can be kept for specific, ad-hoc checks if necessary, but its use is discouraged.
    bool IsNewBar(ENUM_TIMEFRAMES timeframe) {
        if (!m_IsInitialized || m_pContext == NULL) return false;
        
        // This check is independent of the main new bar event flag.
        static datetime last_check_time[100]; // Static array to track different timeframes, assuming timeframe enum values are within range
        if(timeframe >= 100) return false; // Safety check

        datetime current_bar_time = (datetime)SeriesInfoInteger(m_pContext->pSymbolInfo->Symbol(), timeframe, SERIES_LASTBAR_DATE);
        if (current_bar_time > last_check_time[timeframe]) {
            last_check_time[timeframe] = current_bar_time;
            return true;
        }
        return false;
    }

    datetime GetCurrentServerTime() const { return ::TimeCurrent(); }
    datetime GetCurrentLocalTime() const { return ::TimeLocal(); }
    datetime GetCurrentGMTTime() const { return ::TimeGMT(); }

    ENUM_TIMEFRAMES GetMainTimeframe() const { return m_main_timeframe; }

    // Basic session detection placeholders
    bool IsLondonSession() const { return false; } // To be implemented
    bool IsNewYorkSession() const { return false; } // To be implemented
    bool IsTokyoSession() const { return false; }   // To be implemented
};

} // namespace ApexPullback

#endif // TIMEMANAGER_MQH_