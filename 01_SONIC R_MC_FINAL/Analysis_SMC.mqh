//+------------------------------------------------------------------+
//|                                                 Analysis_SMC.mqh |
//|                                     Sonic R EA - Market Analysis |
//|                                     Smart Money Concepts Integrator |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "SMC_Config.mqh"
#include "MarketStructure.mqh"
#include "OrderBlocks.mqh"
#include "FairValueGaps.mqh"
#include "Core_Context.mqh"

//+------------------------------------------------------------------+
//| SMC Analysis Coordinator Class                                   |
//+------------------------------------------------------------------+
class CAnalysisSMC
{
private:
    CEaContext*          m_Context;             // EA Context Pointer
    CMarketStructure*    m_MarketStructure;
    COrderBlocks*        m_OrderBlocks;
    CFairValueGaps*      m_FairValueGaps;


    // Configuration structs for the modules
    MSConfig             m_ms_config;
    OBConfig             m_ob_config;
    FVGConfig            m_fvg_config;


public:
    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    CAnalysisSMC(void)
    {
        m_Context = NULL;
        m_MarketStructure = NULL;
        m_OrderBlocks = NULL;
        m_FairValueGaps = NULL;

    }

    //+------------------------------------------------------------------+
    //| Destructor                                                       |
    //+------------------------------------------------------------------+
   ~CAnalysisSMC(void)
    {
        Deinitialize();
    }

    //+------------------------------------------------------------------+
    //| Initialization                                                   |
    //+------------------------------------------------------------------+
    bool Initialize(CEaContext* context)
    {
        m_Context = context;
        if(CheckPointer(m_Context) == POINTER_INVALID)
        {
            printf("CAnalysisSMC::Initialize - EA Context is null");
            return false;
        }

        // Load configurations from settings or use defaults
        LoadConfigurations();

        // Initialize analysis modules
        m_MarketStructure = new CMarketStructure();
        if(!m_MarketStructure.Initialize(m_ms_config, m_Context.Symbol.Name(), m_Context.TimeManager.Timeframe()))
        {
            m_Context.ErrorHandler.HandleError(__FUNCTION__, "Failed to initialize Market Structure module", ERR_INIT_FAILED, SEVERITY_CRITICAL);
            return false;
        }

        m_OrderBlocks = new COrderBlocks();
        if(!m_OrderBlocks.Initialize(m_ob_config, m_Context.Symbol.Name(), m_Context.TimeManager.Timeframe(), GetPointer(m_MarketStructure)))
        {
            m_Context.ErrorHandler.HandleError(__FUNCTION__, "Failed to initialize Order Blocks module", ERR_INIT_FAILED, SEVERITY_CRITICAL);
            return false;
        }

        m_FairValueGaps = new CFairValueGaps();
        if(!m_FairValueGaps.Initialize(m_fvg_config, m_Context.Symbol.Name(), m_Context.TimeManager.Timeframe()))
        {
            m_Context.ErrorHandler.HandleError(__FUNCTION__, "Failed to initialize Fair Value Gaps module", ERR_INIT_FAILED, SEVERITY_CRITICAL);
            return false;
        }

        m_Context.pLogger.LogInfo(__FUNCTION__, "SMC Analysis modules initialized successfully.");
        return true;
    }

    //+------------------------------------------------------------------+
    //| Deinitialization                                                 |
    //+------------------------------------------------------------------+
    void Deinitialize()
    {
        if(CheckPointer(m_MarketStructure) != POINTER_INVALID) delete m_MarketStructure;
        if(CheckPointer(m_OrderBlocks) != POINTER_INVALID) delete m_OrderBlocks;
        if(CheckPointer(m_FairValueGaps) != POINTER_INVALID) delete m_FairValueGaps;

    }

    //+------------------------------------------------------------------+
    //| Update all SMC analysis modules                                  |
    //+------------------------------------------------------------------+
    void Update()
    {
        if(CheckPointer(m_Context) == POINTER_INVALID) return;

        // The order of updates is critical for SMC analysis.
        // 1. Analyze the foundational market structure.
        if(!AnalyzeMarketStructure())
            return; // Stop if structure analysis fails

        // 2. Scan for Order Blocks within the current structure.
        ScanForOrderBlocks();

        // 3. Detect Fair Value Gaps.
        DetectFairValueGaps();


    }

    //+------------------------------------------------------------------+
    //| Market Structure Analysis Engine                                 |
    //+------------------------------------------------------------------+
    bool AnalyzeMarketStructure()
    {
        if(CheckPointer(m_MarketStructure) == POINTER_INVALID) return false;
        m_MarketStructure.Update();
        return true;
    }

    //+------------------------------------------------------------------+
    //| Order Block Detection System                                     |
    //+------------------------------------------------------------------+
    void ScanForOrderBlocks()
    {
        if(CheckPointer(m_OrderBlocks) == POINTER_INVALID) return;
        m_OrderBlocks.Update();
    }

    //+------------------------------------------------------------------+
    //| Fair Value Gap Analysis Module                                   |
    //+------------------------------------------------------------------+
    void DetectFairValueGaps()
    {
        if(CheckPointer(m_FairValueGaps) == POINTER_INVALID) return;
        m_FairValueGaps.Update();
    }



private:
    //+------------------------------------------------------------------+
    //| Load Configurations                                              |
    //+------------------------------------------------------------------+
    void LoadConfigurations()
    {
        // TODO: Load these settings from the EA's input parameters or a config file
        // For now, we use default values.
        m_ms_config.SetDefaults();
        m_ob_config.SetDefaults();
        m_fvg_config.SetDefaults();

    }
};
//+------------------------------------------------------------------+