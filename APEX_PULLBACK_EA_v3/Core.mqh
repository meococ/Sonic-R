//+------------------------------------------------------------------+
//|                                                        Core.mqh |
//|                   Copyright 2024, Mèo Cọc                       |
//|                                      https://www.yourwebsite.com |
//+------------------------------------------------------------------+

#ifndef CORE_MQH_
#define CORE_MQH_

// --- Foundational Include ---
// CommonStructs is the ONLY file that should be included here.
// It provides the EAContext definition and forward declarations for all module classes,
// which is all this class needs to know about.
#include "CommonStructs.mqh"


namespace ApexPullback
{
//+------------------------------------------------------------------+
//| CCore Class                                                      |
//| The central nervous system of the Expert Advisor.                |
//| Owns the context and all functional modules.                     |
//+------------------------------------------------------------------+
class CCore
  {
private:
   // The single, authoritative state of the EA
   EAContext             m_Context;

   // --- Pointers to all functional modules ---
   // Core Infrastructure
   CLogger*              m_Logger;
   CErrorHandler*        m_ErrorHandler;
   CParameterStore*      m_ParameterStore;
   CStateManager*      m_StateManager;

   // Market & Session Analysis
   CTimeManager*         m_TimeManager;
   CSymbolInfo*          m_SymbolInfo;
   CBrokerHealthMonitor* m_BrokerHealthMonitor;
   CSlippageMonitor*     m_SlippageMonitor;
   CAssetDNA*            m_AssetDNA;

   // Trading & Risk Management
   CIndicatorUtils*      m_IndicatorUtils;
   CMathHelper*          m_MathHelper;
   CSignalEngine*        m_SignalEngine;
   CRiskManager*         m_RiskManager;
   CRiskOptimizer*       m_RiskOptimizer; // Added for v14

   // Trade Execution & Management
   CTradeManager*        m_TradeManager;
   CPositionManager*     m_PositionManager;
   CCircuitBreaker*      m_CircuitBreaker;

   // Performance & UI
   CPerformanceAnalytics* m_PerformanceAnalytics;
   CDrawingUtils*        m_DrawingUtils;
   CDashboard*           m_Dashboard;

public:
                     CCore();
                    ~CCore();

   // --- Initialization & Deinitialization ---
   bool              Initialize(const SInputParameters &inputs);
   void              Deinitialize();

   // --- MQL5 Event Handlers ---
   void              OnTick();
   void              OnTimer();
   void              OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   void              OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result);

private:
    bool InitializeModule(void* &pModule, const string className);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCore::CCore() : // Initialize all pointers to NULL
   m_Logger(NULL),
   m_ErrorHandler(NULL),
   m_ParameterStore(NULL),
   m_StateManager(NULL),
   m_TimeManager(NULL),
   m_SymbolInfo(NULL),
   m_BrokerHealthMonitor(NULL),
   m_SlippageMonitor(NULL),
   m_AssetDNA(NULL),
   m_IndicatorUtils(NULL),
   m_MathHelper(NULL),
   m_SignalEngine(NULL),
   m_RiskManager(NULL),
   m_RiskOptimizer(NULL),
   m_TradeManager(NULL),
   m_PositionManager(NULL),
   m_CircuitBreaker(NULL),
   m_PerformanceAnalytics(NULL),
   m_DrawingUtils(NULL),
   m_Dashboard(NULL)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCore::~CCore()
  {
   // Deinitialization is handled in the Deinitialize() method to
   // ensure a controlled shutdown sequence.
  }

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CCore::Initialize(const SInputParameters &inputs)
  {
    // --- Stage 0: Critical Initialization Order ---
    // The order here is paramount. ErrorHandler and Logger must be first.

    // 0a. Copy user inputs into the context.
    m_Context.Inputs = inputs;
    // m_Context.pCore = this; // Tạm thời vô hiệu hóa - Cần định nghĩa pCore trong EAContext nếu muốn sử dụng

    // 0b. Initialize ErrorHandler. It has no dependencies.
    m_ErrorHandler = new CErrorHandler();
    if (!m_ErrorHandler || !m_ErrorHandler->Initialize(&m_Context))
    {
        // If ErrorHandler fails, we have no choice but to use Print.
        Print("CRITICAL PANIC: Failed to create or initialize CErrorHandler!");
        return false;
    }
    m_Context.pErrorHandler = m_ErrorHandler; // Assign to context immediately.

    // 0c. Initialize Logger. It depends on ErrorHandler.
    m_Logger = new CLogger();
    if (!m_Logger)
    {
        m_ErrorHandler->HandleError(ERR_NOT_ENOUGH_MEMORY, "CCore::Initialize", "Failed to allocate memory for CLogger");
        return false;
    }
    m_Context.pLogger = m_Logger; // Assign to context before initializing it.
    if (!m_Logger->Initialize(inputs))
    {
        // The logger might have failed, but the error handler should still work.
        m_ErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize", "Failed to initialize CLogger");
        return false;
    }
    
     // ParameterStore
     m_ParameterStore = new CParameterStore();
     if (!m_ParameterStore || !m_ParameterStore->Initialize(m_Context))
     {
         m_Context.pErrorHandler->HandleError(ERR_LOGIC_ERROR, "CCore::Initialize", "Failed to initialize ParameterStore");
         return false;
     }
     m_Context.pParameterStore = m_ParameterStore;

    // StateManager
    m_StateManager = new CStateManager();
    if (!m_StateManager || !m_StateManager->Initialize(m_Context))
    {
        m_Context.pErrorHandler->HandleError(ERR_LOGIC_ERROR, "CCore::Initialize", "Failed to initialize StateManager");
        return false;
    }
    m_Context.pStateManager = m_StateManager;

    // SymbolInfo (foundational for market data)
    m_SymbolInfo = new CSymbolInfo();
    if (!m_SymbolInfo || !m_SymbolInfo->Initialize(m_Context)) { m_Context.pErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize - Failed to initialize SymbolInfo"); return false; }
    m_Context.pSymbolInfo = m_SymbolInfo;

    // TimeManager (depends on SymbolInfo)
    m_TimeManager = new CTimeManager();
    if (!m_TimeManager || !m_TimeManager->Initialize(m_Context)) { m_Context.pErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize - Failed to initialize TimeManager"); return false; }
    m_Context.pTimeManager = m_TimeManager;

    // MathHelper
    m_MathHelper = new CMathHelper();
    if (!m_MathHelper || !m_MathHelper->Initialize(&m_Context)) { m_ErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize", "Failed to initialize CMathHelper"); return false; }
    m_Context.pMathHelper = m_MathHelper;

    // BrokerHealthMonitor
    m_BrokerHealthMonitor = new CBrokerHealthMonitor();
    if (!m_BrokerHealthMonitor || !m_BrokerHealthMonitor->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CBrokerHealthMonitor"); return false; }
    m_Context.pBrokerHealthMonitor = m_BrokerHealthMonitor;

    // SlippageMonitor
    m_SlippageMonitor = new CSlippageMonitor();
    if (!m_SlippageMonitor || !m_SlippageMonitor->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CSlippageMonitor"); return false; }
    m_Context.pSlippageMonitor = m_SlippageMonitor;

    // AssetDNA
    m_AssetDNA = new CAssetDNA();
    if (!m_AssetDNA || !m_AssetDNA->Initialize(&m_Context)) { m_ErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize", "Failed to initialize CAssetDNA"); return false; }
    m_Context.pAssetDNA = m_AssetDNA;

    // IndicatorUtils
    m_IndicatorUtils = new CIndicatorUtils();
    if (!m_IndicatorUtils || !m_IndicatorUtils->Initialize(&m_Context)) { m_ErrorHandler->HandleError(ERR_INIT_FAILED, "CCore::Initialize", "Failed to initialize CIndicatorUtils"); return false; }
    m_Context.pIndicatorUtils = m_IndicatorUtils;

    // SignalEngine
    m_SignalEngine = new CSignalEngine();
    if (!m_SignalEngine || !m_SignalEngine->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CSignalEngine"); return false; }
    m_Context.pSignalEngine = m_SignalEngine;

    // RiskManager
    m_RiskManager = new CRiskManager();
    if (!m_RiskManager || !m_RiskManager->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CRiskManager"); return false; }
    m_Context.pRiskManager = m_RiskManager;

    // RiskOptimizer (Optional Module)
    // if (m_Context.Inputs.EnableRiskOptimizer) // Tạm thời vô hiệu hóa cho đến khi CRiskOptimizer được sửa
    // {
    //     m_RiskOptimizer = new CRiskOptimizer(m_Context);
    //     if (!m_RiskOptimizer) // Check if 'new' failed
    //     {
            m_Logger->LogError("Critical Error: Failed to allocate memory for CRiskOptimizer");
            return false;
        }
        // No separate Initialize() call needed if constructor handles it all
        m_Context.pRiskOptimizer = m_RiskOptimizer;
        m_Logger->LogInfo("Risk Optimizer module enabled and initialized.");
    }

    // TradeManager
    m_TradeManager = new CTradeManager();
    if (!m_TradeManager || !m_TradeManager->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CTradeManager"); return false; }
    m_Context.pTradeManager = m_TradeManager;

    // PositionManager
    m_PositionManager = new CPositionManager();
    if (!m_PositionManager || !m_PositionManager->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CPositionManager"); return false; }
    m_Context.pPositionManager = m_PositionManager;

    // CircuitBreaker
    m_CircuitBreaker = new CCircuitBreaker();
    if (!m_CircuitBreaker || !m_CircuitBreaker->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CCircuitBreaker"); return false; }
    m_Context.pCircuitBreaker = m_CircuitBreaker;

    // PerformanceAnalytics
    m_PerformanceAnalytics = new CPerformanceAnalytics();
    if (!m_PerformanceAnalytics || !m_PerformanceAnalytics->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CPerformanceAnalytics"); return false; }
    m_Context.pPerformanceAnalytics = m_PerformanceAnalytics;

    // DrawingUtils
    m_DrawingUtils = new CDrawingUtils();
    if (!m_DrawingUtils || !m_DrawingUtils->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CDrawingUtils"); return false; }
    m_Context.pDrawingUtils = m_DrawingUtils;

    // Dashboard
    m_Dashboard = new CDashboard();
    if (!m_Dashboard || !m_Dashboard->Initialize(m_Context)) { m_Logger->LogError("Critical Error: Failed to create or initialize CDashboard"); return false; }
    m_Context.pDashboard = m_Dashboard;

    m_Logger->LogInfo("All modules initialized successfully.");

    // Final state transition to signal readiness
    m_StateManager->SetState(EA_STATE_IDLE, "Core initialization complete.");

    return true;
  }

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CCore::Deinitialize()
  {
    // Deinitialize in the reverse order of initialization to prevent dependency issues.
    // The logger should be one of the last to go so we can log any deinitialization errors.

    if(m_Logger) m_Logger->LogInfo("EA Deinitialization started.");

    // --- Delete modules ---
    if(m_TradeManager)       { delete m_TradeManager;       m_TradeManager = NULL;       }
    if(m_RiskManager)        { delete m_RiskManager;        m_RiskManager = NULL;        }
    if(m_SignalEngine)       { delete m_SignalEngine;       m_SignalEngine = NULL;       }
    if(m_IndicatorUtils)     { delete m_IndicatorUtils;     m_IndicatorUtils = NULL;     }
    if(m_AssetDNA)           { delete m_AssetDNA;           m_AssetDNA = NULL;           }
    if(m_SlippageMonitor)    { delete m_SlippageMonitor;    m_SlippageMonitor = NULL;    }
    if(m_BrokerHealthMonitor){ delete m_BrokerHealthMonitor;m_BrokerHealthMonitor = NULL;}
    if(m_TimeManager)        { delete m_TimeManager;        m_TimeManager = NULL;        }
    if(m_SymbolInfo)         { delete m_SymbolInfo;         m_SymbolInfo = NULL;         }
    if(m_StateManager)       { delete m_StateManager;       m_StateManager = NULL;       }
    if(m_ParameterStore)     { delete m_ParameterStore;     m_ParameterStore = NULL;     }
    if(m_MathHelper)         { delete m_MathHelper;         m_MathHelper = NULL;         }

    // --- Foundational modules last ---
    if(m_Logger)             { delete m_Logger;             m_Logger = NULL;             }
    if(m_ErrorHandler)       { delete m_ErrorHandler;       m_ErrorHandler = NULL;       }

    // Final log to terminal before EA exits
    Print("APEX Pullback EA Deinitialized successfully.");
  }

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void CCore::OnTick()
{
    // 1. Always run time-critical tasks every tick
    if (m_TimeManager) m_TimeManager->OnTick(); // Must run first to set IsNewBarEvent flag
    if (m_SymbolInfo) m_SymbolInfo->OnTick(); // Then refresh symbol data
    if (m_BrokerHealthMonitor) m_BrokerHealthMonitor->OnTick();
    if (m_PositionManager) m_PositionManager->OnTick(); // Manages existing positions, trailing stops etc.
    if (m_Dashboard) m_Dashboard->Update(); // Update real-time data like price, P/L

    // 2. Check for the new bar event flag
    if (m_Context.IsNewBarEvent)
    {
        // Reset the flag immediately to prevent re-processing
        m_Context.IsNewBarEvent = false;

        if(m_Logger) m_Logger->LogDebug("New bar event. Running analysis modules.");

        // Run all logic that only needs to execute on a new bar
        // if (m_MarketProfile) m_MarketProfile->Update(); // Example
        if (m_SignalEngine) m_SignalEngine->OnTick(); // Check for new trading signals
        if (m_AssetDNA) m_AssetDNA->OnTick(); // Re-evaluate asset characteristics
        // ... call other modules that need updating per bar ...
    }
}

//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void CCore::OnTimer()
  {
    // Delegate to relevant modules
    if(m_Dashboard) m_Dashboard->OnTimer();
  }

//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void CCore::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
    // Delegate to relevant modules
    if(m_Dashboard) m_Dashboard->OnChartEvent(id, lparam, dparam, sparam);
  }

//+------------------------------------------------------------------+
//| OnTradeTransaction                                               |
//+------------------------------------------------------------------+
void CCore::OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
    // Delegate the transaction event to the TradeManager
    if(m_TradeManager != NULL)
    {
        m_TradeManager->OnTradeTransaction(trans, request, result);
    }

    // Future: Could also delegate to PerformanceAnalytics or other modules if needed
    // if(m_PerformanceAnalytics != NULL)
    // {
    //     m_PerformanceAnalytics->OnTradeTransaction(trans, request, result);
    // }
}

} // END NAMESPACE ApexPullback

#endif // CORE_MQH_