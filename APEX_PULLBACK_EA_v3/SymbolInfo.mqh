#ifndef SYMBOLINFO_MQH_
#define SYMBOLINFO_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CSymbolInfo 
{
private:
    EAContext*   m_pContext;      // Pointer to the global context
    bool         m_IsInitialized;
    string       m_symbol_name;
    MqlTick      m_latest_tick;
    MqlRates     m_rates[1];      // For fetching latest price

public:
    CSymbolInfo() : m_pContext(NULL), m_IsInitialized(false), m_symbol_name("") {}
    ~CSymbolInfo() {}

    bool Initialize(EAContext* pContext);
    bool IsInitialized() const { return m_IsInitialized; }
    void OnTick();

    // --- Getters for Symbol Properties ---
    string   Symbol() const { return m_symbol_name; }
    double   PipSize() const;
    double   TickValue() const;
    int      Digits() const;
    double   Point() const;
    double   Spread() const;
    double   StopLevel() const;
    double   LotSizeMin() const;
    double   LotSizeMax() const;
    double   LotStep() const;

    // --- Getters for Market Data ---
    double   Bid() const { return m_latest_tick.bid; }
    double   Ask() const { return m_latest_tick.ask; }
    double   Last() const { return m_latest_tick.last; }
    datetime Time() const { return m_latest_tick.time; }

};

bool CSymbolInfo::Initialize(EAContext* pContext) 
{
    m_pContext = pContext;
    if (m_pContext == NULL)
    {
        Print("FATAL: CSymbolInfo received a NULL context during initialization.");
        return false;
    }

    m_symbol_name = m_pContext->Inputs.Symbol; 
    if (m_symbol_name == "" || m_symbol_name == "_current_") 
    {
        m_symbol_name = ::Symbol();
    }

    if (!::SymbolSelect(m_symbol_name, true)) 
    {
        string msg = "Failed to select symbol: " + m_symbol_name;
        if(m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_MARKET_UNKNOWN_SYMBOL, "CSymbolInfo::Initialize", msg);
        else Print(msg);
        return false;
    }
    
    OnTick(); // Initial refresh
    
    if (m_pContext->pLogger) m_pContext->pLogger->Log(LOG_INFO, "CSymbolInfo initialized for symbol: " + m_symbol_name);
    m_IsInitialized = true;
    return true;
}

void CSymbolInfo::OnTick() 
{
    if(!m_IsInitialized) return;
    ::SymbolInfoTick(m_symbol_name, m_latest_tick);
}

double CSymbolInfo::PipSize() const 
{
    // A pip is 10 points for most symbols.
    // For 3 and 5 digit brokers, Point() is 0.001 and 0.00001 respectively.
    // PipSize would be 0.01 and 0.0001.
    int digits = Digits();
    if (digits == 3 || digits == 5)
        return 10 * Point();
    // For 2 and 4 digit brokers, Point() is 0.01 and 0.0001, which is the pip size.
    return Point();
}

double CSymbolInfo::TickValue() const {
    return ::SymbolInfoDouble(m_symbol_name, SYMBOL_TRADE_TICK_VALUE);
}

int CSymbolInfo::Digits() const {
    return (int)::SymbolInfoInteger(m_symbol_name, SYMBOL_DIGITS);
}

double CSymbolInfo::Point() const {
    return ::SymbolInfoDouble(m_symbol_name, SYMBOL_POINT);
}

double CSymbolInfo::Spread() const {
    return ::SymbolInfoInteger(m_symbol_name, SYMBOL_SPREAD) * Point();
}

double CSymbolInfo::StopLevel() const {
    return ::SymbolInfoInteger(m_symbol_name, SYMBOL_TRADE_STOPS_LEVEL) * Point();
}

double CSymbolInfo::LotSizeMin() const {
    return ::SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_MIN);
}

double CSymbolInfo::LotSizeMax() const {
    return ::SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_MAX);
}

double CSymbolInfo::LotStep() const {
    return ::SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_STEP);
}

} // namespace ApexPullback

#endif // SYMBOLINFO_MQH_