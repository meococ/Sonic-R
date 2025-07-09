//+------------------------------------------------------------------+
//|                                              ConfigManager.mqh |
//|                      APEX Pullback EA v14.0 (Build 1400)         |
//|                        (c) 2024, Apex Trading Systems            |
//+------------------------------------------------------------------+
#property copyright "(c) 2024, Apex Trading Systems"
#property link      "https://www.apextradingsystems.io"
#property version   "14.0"
#property strict

#ifndef APEX_CONFIG_MANAGER_MQH
#define APEX_CONFIG_MANAGER_MQH

#include "../../00_Core/Common/CommonStructs.mqh"

// Forward Declarations
class CLogger;

namespace ApexPullback {

//+------------------------------------------------------------------+
//| CConfigManager Class                                             |
//| Manages all EA input parameters and configuration settings.      |
//+------------------------------------------------------------------+
class CConfigManager {
private:
    EAContext* m_context;           // Pointer to the global EA context
    CLogger*   m_logger;            // Pointer to the logger
    bool       m_initialized;       // Initialization status

    // --- Input Parameters ---
    // All input parameters will be stored here after being read from the EA's inputs.
    // This provides a single, clean interface for the rest of the EA to access them.

    // Example Parameter:
    string     s_MagicNumber;       // Magic Number for trades
    double     d_LotSize;           // Fixed lot size
    // ... other parameters will be added here

    // Internal helper to get the logger from the context
    void GetLogger();

public:
    // --- Constructor / Destructor ---
    CConfigManager();
    ~CConfigManager();

    // --- Initialization / Deinitialization ---
    bool Initialize(EAContext &context);
    void Deinitialize();

    // --- Core Methods ---
    void LoadFromInputs(); // Load all parameters from the EA's input settings
    void LogConfiguration(); // Print the current configuration to the log

    // --- Parameter Getters ---
    // Provides safe, read-only access to configuration values.
    string GetMagicNumber() const { return s_MagicNumber; }
    double GetLotSize()     const { return d_LotSize; }
    // ... other getters will be added here

    // --- State ---
    bool IsInitialized() const { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CConfigManager::CConfigManager() : m_context(NULL),
                                   m_logger(NULL),
                                   m_initialized(false),
                                   s_MagicNumber("APEX_PB_14"),
                                   d_LotSize(0.01)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CConfigManager::~CConfigManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CConfigManager::Initialize(EAContext &context) {
    m_context = &context;
    GetLogger();

    if (m_logger) m_logger->LogInfo("Initializing ConfigManager...", __FUNCTION__);

    LoadFromInputs();
    LogConfiguration();

    m_initialized = true;
    if (m_logger) m_logger->LogInfo("ConfigManager Initialized Successfully.", __FUNCTION__);
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CConfigManager::Deinitialize() {
    if (!m_initialized) return;

    if (m_logger) m_logger->LogInfo("Deinitializing ConfigManager...", __FUNCTION__);
    
    m_context = NULL;
    m_logger = NULL;
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| LoadFromInputs                                                   |
//+------------------------------------------------------------------+
void CConfigManager::LoadFromInputs() {
    // In MQL5, input variables are global. This function's purpose is to centralize
    // the *reading* of those global inputs into this class's members.
    // This decouples the rest of the system from global variables.

    // Example of reading from global input variables (these must be defined in the main .mq5 file)
    // extern string InpMagicNumber;
    // extern double InpLotSize;
    
    // s_MagicNumber = InpMagicNumber;
    // d_LotSize = InpLotSize;

    // For now, we use default values as the inputs aren't defined yet.
    if (m_logger) m_logger->LogDebug("Loading parameters from EA inputs (currently using defaults).", __FUNCTION__);
}

//+------------------------------------------------------------------+
//| LogConfiguration                                                 |
//+------------------------------------------------------------------+
void CConfigManager::LogConfiguration() {
    if (!m_logger) return;

    m_logger->LogInfo("--- EA Configuration ---", __FUNCTION__);
    m_logger->LogInfo(StringFormat("Magic Number: %s", s_MagicNumber), __FUNCTION__);
    m_logger->LogInfo(StringFormat("Lot Size: %.2f", d_LotSize), __FUNCTION__);
    m_logger->LogInfo("------------------------", __FUNCTION__);
}

//+------------------------------------------------------------------+
//| GetLogger                                                        |
//+------------------------------------------------------------------+
void CConfigManager::GetLogger() {
    if (m_context != NULL && m_context->pLogger != NULL) {
        m_logger = m_context->pLogger;
    }
}

} // namespace ApexPullback

#endif // APEX_CONFIG_MANAGER_MQH