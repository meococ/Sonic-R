#ifndef CORE_SYMBOLINFO_MQH
#define CORE_SYMBOLINFO_MQH

#include "SonicR_CommonStructs.mqh"

namespace ApexSonicR {

class CSymbolInfo 
{
private:
    bool         m_IsInitialized;
    string       m_symbol_name;
    MqlTick      m_latest_tick;

public:
    CSymbolInfo() : m_IsInitialized(false), m_symbol_name("") {}
    ~CSymbolInfo() {}

    bool Initialize() {
        m_symbol_name = Symbol();
        m_IsInitialized = true;
        return true;
    }
    
    void Deinitialize() {
        m_IsInitialized = false;
    }
    
    bool IsInitialized() const { return m_IsInitialized; }
    
    void OnTick() {
        if (!m_IsInitialized) return;
        SymbolInfoTick(m_symbol_name, m_latest_tick);
    }

    // --- Getters for Symbol Properties ---
    string   Symbol() const { return m_symbol_name; }
    double   PipSize() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_POINT); }
    double   TickValue() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_TRADE_TICK_VALUE); }
    int      Digits() const { return (int)SymbolInfoInteger(m_symbol_name, SYMBOL_DIGITS); }
    double   Point() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_POINT); }
    double   Spread() const { return SymbolInfoInteger(m_symbol_name, SYMBOL_SPREAD) * Point(); }
    double   Ask() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_ASK); }
    double   Bid() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_BID); }
    double   Last() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_LAST); }
    long     Volume() const { return SymbolInfoInteger(m_symbol_name, SYMBOL_VOLUME); }
    double   VolumeReal() const { return SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_REAL); }
    
    // --- Latest Tick Information ---
    datetime TickTime() const { return m_latest_tick.time; }
    double   TickAsk() const { return m_latest_tick.ask; }
    double   TickBid() const { return m_latest_tick.bid; }
    double   TickLast() const { return m_latest_tick.last; }
    ulong    TickVolume() const { return m_latest_tick.volume; }
    long     TickVolumeReal() const { return m_latest_tick.volume_real; }
    uint     TickFlags() const { return m_latest_tick.flags; }
    
    // --- Helper Methods ---
    bool IsTradeAllowed() const { 
        return (bool)SymbolInfoInteger(m_symbol_name, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED; 
    }
    
    double NormalizePrice(double price) const {
        return NormalizeDouble(price, Digits());
    }
    
    double NormalizeLot(double lot) const {
        double minLot = SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_MAX);
        double stepLot = SymbolInfoDouble(m_symbol_name, SYMBOL_VOLUME_STEP);
        
        lot = MathMax(lot, minLot);
        lot = MathMin(lot, maxLot);
        lot = NormalizeDouble(lot / stepLot, 0) * stepLot;
        
        return lot;
    }
};

} // namespace ApexSonicR

#endif // CORE_SYMBOLINFO_MQH