//+------------------------------------------------------------------+
//|                                     APEX Pullback EA v5.mq5      |
//|                          Tác giả: Cáo Già & Đại Bàng             |
//|                      ARCH: Sonic R Integration                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Cáo Già & Đại Bàng"
#property link      "https://www.mql5.com"
#property version   "5.0"

#include "Includes.mqh"

//+------------------------------------------------------------------+
//| Global EA Context                                                |
//+------------------------------------------------------------------+
CEaContext g_Context; // The single source of truth for the EA

//--- Central Analysis & Signal Modules ---
CMarketAnalysisManager*   g_MarketAnalysisManager = NULL;
CSonicRScoutEntry*        g_SonicRScoutEntry = NULL;
CSonicRIntegration*       g_SonicRIntegration = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // --- Create Core Services ---
    g_Context.pLogger = new CLogger();
    if(!g_Context.pLogger)
    {
        printf("Critical Error: Could not create Logger.");
        return INIT_FAILED;
    }
    
    // Load all input parameters into the context
    LoadInputParameters(g_Context.Inputs);
    
    // Initialize the logger with the loaded inputs
    if(!g_Context.pLogger.Initialize(g_Context.Inputs))
    {
        printf("Critical Error: Could not initialize Logger.");
        return INIT_FAILED;
    }

    g_Context.pLogger.LogInfo("OnInit: EA Initializing...");

    g_Context.pErrorHandler = new CErrorHandler();
    g_Context.pTimeManager = new CTimeManager(g_Context.pLogger);
    g_Context.pSymbolInfo = new CSymbolInfo(g_Context.pLogger, _Symbol);
    g_Context.pSessionManager = new CSessionManager(g_Context.pLogger);

    // --- Create Core Managers ---
    g_Context.pIndicators = new CIndicators();
    g_Context.pTradeManager = new CTradeManager();
    g_Context.pRiskManager = new CRiskManager();
    g_Context.pSignalEngine = new CSignalEngine();
    g_Context.pPerformanceTracker = new CPerformanceTracker();

    // --- Create instances of strategy-specific modules ---
    g_MarketAnalysisManager = new CMarketAnalysisManager();
    g_SonicRScoutEntry = new CSonicRScoutEntry();
    g_SonicRIntegration = new CSonicRIntegration();

    // --- Initialize all modules with the context ---
    if (!InitializeModules(&g_Context))
    {
        LOG_FATAL("Module initialization failed. EA will be deinitialized.");
        return INIT_FAILED;
    }

    LOG_INFO("OnInit: EA Initialized Successfully.");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Initialize all EA modules                                        |
//+------------------------------------------------------------------+
bool InitializeModules(CEaContext* context)
{
    if (!context->pErrorHandler->Initialize(context)) return false;
    if (!context->pSymbolInfo->Initialize(context)) return false;
    if (!context->pTimeManager->Initialize(context)) return false;
    if (!context->pTradeManager->Initialize(context)) return false;
    if (!context->pRiskManager->Initialize(context)) return false;
    if (!context->pPerformanceTracker->Initialize(context)) return false;
    if (!context->pIndicators->Initialize(context)) return false;

    // Initialize Market Analysis Manager
    if (!g_MarketAnalysisManager->Initialize(context))
    {
        context->pLogger->LogError("Failed to initialize Market Analysis Manager.");
        return false;
    }



    // Initialize Sonic R Signal Modules
    if (!g_SonicRScoutEntry->Initialize(context, g_MarketAnalysisManager))
    {
        context->pLogger->LogError("Failed to initialize Scout Entry module.");
        return false;
    }

    // Initialize Sonic R Integration Layer
    if (!g_SonicRIntegration->Initialize(context, g_MarketAnalysisManager, g_SonicRScoutEntry))
    {
        context->pLogger.LogError("Failed to initialize SonicR Integration layer.");
        return false;
    }
    g_SonicRIntegration->SetMinConfidence(context->Inputs.SonicRConfidenceThreshold);

    // Signal Engine
    if (!context->pSignalEngine->Initialize(context)) return false;
    context->pSignalEngine->RegisterStrategy(g_SonicRIntegration);
    context->pSignalEngine->SelectStrategy("SonicR_Unified");

    return true;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if(g_Context.pLogger != NULL) g_Context.pLogger->LogInfo("Deinitializing EA...");

    // Delete strategy-specific modules first
    delete g_SonicRIntegration;
    delete g_SonicRScoutEntry;
    delete g_MarketAnalysisManager; // This deletes all analysis modules

    // Delete core services and managers from the context
    delete g_Context.pPerformanceTracker;
    delete g_Context.pSignalEngine;
    delete g_Context.pRiskManager;
    delete g_Context.pTradeManager;
    delete g_Context.pIndicators;
    delete g_Context.pSessionManager;
    delete g_Context.pSymbolInfo;
    delete g_Context.pTimeManager;
    delete g_Context.pErrorHandler;
    delete g_Context.pLogger; // Logger is last
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // On a new bar, run the main trading logic
    if (g_Context.pTimeManager->IsNewBar())
    {
        // 1. Update all market analysis for the new bar
        g_MarketAnalysisManager->Update();

        // 2. Run Signal Engine to check for trading signals
        if (g_Context.pSignalEngine->CheckForSignal() != SIGNAL_TYPE_NONE)
        {
            SSignalInfo signalInfo;
            if (g_Context.pSignalEngine->GetSignalInfo(signalInfo))
            {
                // 3. Calculate Risk for the potential trade
                double lotSize = g_Context.pRiskManager->CalculatePositionSize(signalInfo.stopLossPrice, signalInfo.entryPrice);

                // 4. Execute Trade if risk is acceptable
                if (lotSize > 0)
                {
                    g_Context.pTradeManager->ExecuteTrade(signalInfo, lotSize);
                }
            }
        }

        // 5. Manage open positions
        g_Context.pTradeManager->ManageOpenPositions();
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Handle timer-based events if any
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
    // Handle trade events if any
}

//+------------------------------------------------------------------+
//| Chart event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Handle chart events if any
}
//+------------------------------------------------------------------+