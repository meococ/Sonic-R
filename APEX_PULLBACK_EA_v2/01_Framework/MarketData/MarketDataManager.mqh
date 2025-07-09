//+------------------------------------------------------------------+
//|                                           MarketDataManager.mqh |
//|                      APEX Pullback EA v14.0 (Build 1400)         |
//|                        (c) 2024, Apex Trading Systems            |
//+------------------------------------------------------------------+
#property copyright "(c) 2024, Apex Trading Systems"
#property link      "https://www.apextradingsystems.io"
#property version   "14.0"
#property strict

#ifndef APEX_MARKET_DATA_MANAGER_MQH
#define APEX_MARKET_DATA_MANAGER_MQH

#include "../../00_Core/Common/CommonStructs.mqh"

// Forward Declarations
class CLogger;

namespace ApexPullback {

//+------------------------------------------------------------------+
//| CMarketDataManager Class                                         |
//| Manages all market data, including prices, indicators, and       |
//| historical data.                                                 |
//+------------------------------------------------------------------+
class CMarketDataManager {
private:
    EAContext* m_context;       // Pointer to the global EA context
    CLogger*   m_logger;        // Pointer to the logger
    bool       m_initialized;   // Initialization status

    // Internal helper to get the logger from the context
    void GetLogger();

public:
    // --- Constructor / Destructor ---
    CMarketDataManager();
    ~CMarketDataManager();

    // --- Initialization / Deinitialization ---
    bool Initialize(EAContext &context);
    void Deinitialize();

    // --- Core Methods ---
    void Update(); // Called on each tick to update all market data

    // --- Data Access ---
    const MarketState& GetMarketState() const; // Provides read-only access to the current market state

    // --- State ---
    bool IsInitialized() const { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketDataManager::CMarketDataManager() : m_context(NULL),
                                           m_logger(NULL),
                                           m_initialized(false)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketDataManager::~CMarketDataManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMarketDataManager::Initialize(EAContext &context) {
    m_context = &context;
    GetLogger();

    if (m_logger) m_logger->LogInfo("Initializing MarketDataManager...", __FUNCTION__);

    // Initialization of indicators or other data sources would go here.

    m_initialized = true;
    if (m_logger) m_logger->LogInfo("MarketDataManager Initialized.", __FUNCTION__);
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CMarketDataManager::Deinitialize() {
    if (!m_initialized) return;

    if (m_logger) m_logger->LogInfo("Deinitializing MarketDataManager...", __FUNCTION__);
    
    // Deinitialization of indicators, etc.
    
    m_context = NULL;
    m_logger = NULL;
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CMarketDataManager::Update() {
    if (!m_initialized || m_context == NULL) return;

    // This is the central point for updating all market data.
    // The main EA file will call this, and this function will update the context's MarketState.
    // For now, the logic is in the main file's UpdateMarketState function.
    // In a future step, that logic will be moved here.
}

//+------------------------------------------------------------------+
//| GetMarketState                                                   |
//+------------------------------------------------------------------+
const MarketState& CMarketDataManager::GetMarketState() const {
    // This provides safe, read-only access to the market state for other components.
    return m_context->MarketState;
}

//+------------------------------------------------------------------+
//| GetLogger                                                        |
//+------------------------------------------------------------------+
void CMarketDataManager::GetLogger() {
    if (m_context != NULL && m_context->pLogger != NULL) {
        m_logger = m_context->pLogger;
    }
}

} // namespace ApexPullback

#endif // APEX_MARKET_DATA_MANAGER_MQH