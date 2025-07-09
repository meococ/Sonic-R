#ifndef CORE_CORE_MQH
#define CORE_CORE_MQH

#include "Core_Context.mqh"

namespace ApexSonicR 
{

//+------------------------------------------------------------------+
//| CCore                                                            |
//| The main engine of the EA. Manages the lifecycle of all          |
//| services and orchestrates the main event handlers.               |
//+------------------------------------------------------------------+
class CCore
{
private:
    CEaContext m_Context; // The single source of truth

public:
    CCore() {}
    ~CCore() {}

    bool Initialize();
    void Deinitialize();
    void OnTick();
    void OnTimer();
    void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

    // Getter for the context, allows external components to access services
    CEaContext* GetContext() { return &m_Context; }
};

bool CCore::Initialize()
{
    //--- 1. Instantiate Services ---
    m_Context.pLogger       = new CLogger();
    m_Context.pErrorHandler = new CErrorHandler();
    m_Context.pSymbolInfo   = new CSymbolInfo();
    m_Context.pTimeManager  = new CTimeManager();

    //--- 2. Initialize Services (in dependency order) ---
    // Logger and ErrorHandler have no dependencies on other services, but need the context itself.
    if(!m_Context.pLogger->Initialize(&m_Context)) return false;
    if(!m_Context.pErrorHandler->Initialize(&m_Context)) return false;

    m_Context.pLogger->Log(LOG_INFO, "Core services instantiated. Initializing...");

    // SymbolInfo and TimeManager depend on the context.
    if(!m_Context.pSymbolInfo->Initialize(&m_Context))
    {
        m_Context.pErrorHandler->HandleError(0, "CCore::Initialize", "Failed to initialize SymbolInfo");
        return false;
    }
    if(!m_Context.pTimeManager->Initialize(&m_Context))
    {
        m_Context.pErrorHandler->HandleError(0, "CCore::Initialize", "Failed to initialize TimeManager");
        return false;
    }

    m_Context.pLogger->Log(LOG_INFO, "All core services initialized successfully.");
    return true;
}

void CCore::Deinitialize()
{
    // Deinitialize in reverse order of initialization
    if(m_Context.pTimeManager)  { m_Context.pTimeManager->Deinitialize();  delete m_Context.pTimeManager;  }
    if(m_Context.pSymbolInfo)   { m_Context.pSymbolInfo->Deinitialize();   delete m_Context.pSymbolInfo;   }
    if(m_Context.pErrorHandler) { m_Context.pErrorHandler->Deinitialize(); delete m_Context.pErrorHandler; }
    if(m_Context.pLogger)       { m_Context.pLogger->Deinitialize();       delete m_Context.pLogger;       }
    
    Print("Core services deinitialized.");
}

void CCore::OnTick()
{
    // Update services that need tick-by-tick data
    if(m_Context.pSymbolInfo) m_Context.pSymbolInfo->OnTick();
    if(m_Context.pTimeManager) m_Context.pTimeManager->OnTick();

    // --- Main EA Logic would be triggered from here ---
    // Example:
    // if(m_Context.IsNewBarEvent)
    // {
    //     m_Context.pSignalEngine->Run();
    // }
}

void CCore::OnTimer()
{
    // Handle timer events, e.g., for UI updates
}

void CCore::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Handle chart events
}

} // namespace ApexSonicR

#endif // CORE_CORE_MQH