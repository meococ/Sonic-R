//+------------------------------------------------------------------+
//|                                                TimeManager.mqh |
//|                      APEX Pullback EA v14.0 (Build 1400)         |
//|                        (c) 2024, Apex Trading Systems            |
//+------------------------------------------------------------------+
#property copyright "(c) 2024, Apex Trading Systems"
#property link      "https://www.apextradingsystems.io"
#property version   "14.0"
#property strict

#ifndef APEX_TIME_MANAGER_MQH
#define APEX_TIME_MANAGER_MQH

#include "../../00_Core/Common/CommonStructs.mqh"

// Forward Declarations
class CLogger;

namespace ApexPullback {

//+------------------------------------------------------------------+
//| CTimeManager Class                                               |
//| Manages all time-related logic, including session times, weekend |
//| handling, and server time synchronization.                       |
//+------------------------------------------------------------------+
class CTimeManager {
private:
    EAContext* m_context;           // Pointer to the global EA context
    CLogger*   m_logger;            // Pointer to the logger
    bool       m_initialized;       // Initialization status

    // --- Time Settings ---
    datetime   m_server_time_utc;   // Last known server time in UTC
    long       m_server_utc_offset; // Server UTC offset in seconds
    datetime   m_last_tick_time;    // Time of the last received tick

    // --- Session Management ---
    bool       m_trading_allowed;   // Is trading currently allowed by time settings
    // ... more session parameters like StartHour, EndHour etc. can be added

    // Internal helper to get the logger from the context
    void GetLogger();

public:
    // --- Constructor / Destructor ---
    CTimeManager();
    ~CTimeManager();

    // --- Initialization / Deinitialization ---
    bool Initialize(EAContext &context);
    void Deinitialize();

    // --- Core Methods ---
    void Update(); // Called on each tick or timer event to update time state
    bool IsTradingAllowed() const; // Checks if current time is within allowed trading hours
    bool IsWeekend(datetime time) const; // Checks if the given time is a weekend

    // --- Time Getters ---
    datetime GetServerTime() const; // Gets the current server time
    datetime GetUTCTime() const;    // Gets the current UTC time
    long     GetServerUTCOffset() const { return m_server_utc_offset; }

    // --- State ---
    bool IsInitialized() const { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTimeManager::CTimeManager() : m_context(NULL),
                               m_logger(NULL),
                               m_initialized(false),
                               m_server_time_utc(0),
                               m_server_utc_offset(0),
                               m_last_tick_time(0),
                               m_trading_allowed(true)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTimeManager::~CTimeManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CTimeManager::Initialize(EAContext &context) {
    m_context = &context;
    GetLogger();

    if (m_logger) m_logger->LogInfo("Initializing TimeManager...", __FUNCTION__);

    m_server_utc_offset = SymbolInfoInteger(_Symbol, SYMBOL_TIME_GMT_OFFSET);
    Update();

    m_initialized = true;
    if (m_logger) m_logger->LogInfo(StringFormat("TimeManager Initialized. Server UTC Offset: %d hours.", (int)(m_server_utc_offset / 3600)), __FUNCTION__);
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CTimeManager::Deinitialize() {
    if (!m_initialized) return;

    if (m_logger) m_logger->LogInfo("Deinitializing TimeManager...", __FUNCTION__);
    
    m_context = NULL;
    m_logger = NULL;
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CTimeManager::Update() {
    if (!m_initialized || m_context == NULL) return;

    m_server_time_utc = m_context->MarketState.ServerTime;
    m_last_tick_time = m_server_time_utc;

    // Basic check to disallow trading on weekends
    if (IsWeekend(m_server_time_utc)) {
        if (m_trading_allowed) {
            if (m_logger) m_logger->LogInfo("Weekend detected. Trading disabled.", __FUNCTION__);
            m_trading_allowed = false;
        }
    } else {
        // Potentially re-enable trading if it was disabled for the weekend
        if (!m_trading_allowed) {
             if (m_logger) m_logger->LogInfo("Trading week started. Trading enabled.", __FUNCTION__);
             m_trading_allowed = true;
        }
    }
    // More complex session logic would go here
}

//+------------------------------------------------------------------+
//| IsTradingAllowed                                                 |
//+------------------------------------------------------------------+
bool CTimeManager::IsTradingAllowed() const {
    // This can be expanded with session times, news filters, etc.
    return m_trading_allowed;
}

//+------------------------------------------------------------------+
//| IsWeekend                                                        |
//+------------------------------------------------------------------+
bool CTimeManager::IsWeekend(datetime time) const {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    // Saturday = 6, Sunday = 0
    return (dt.day_of_week == 0 || dt.day_of_week == 6);
}

//+------------------------------------------------------------------+
//| GetServerTime                                                    |
//+------------------------------------------------------------------+
datetime CTimeManager::GetServerTime() const {
    return m_server_time_utc;
}

//+------------------------------------------------------------------+
//| GetUTCTime                                                       |
//+------------------------------------------------------------------+
datetime CTimeManager::GetUTCTime() const {
    return m_server_time_utc - m_server_utc_offset;
}

//+------------------------------------------------------------------+
//| GetLogger                                                        |
//+------------------------------------------------------------------+
void CTimeManager::GetLogger() {
    if (m_context != NULL && m_context->pLogger != NULL) {
        m_logger = m_context->pLogger;
    }
}

} // namespace ApexPullback

#endif // APEX_TIME_MANAGER_MQH