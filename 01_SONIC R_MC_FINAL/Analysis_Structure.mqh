//+------------------------------------------------------------------+
//|                                    Analysis_Structure.mqh       |
//|                  APEX Pullback EA v4.6 - Structure Analysis     |
//|                              Đại Bàng - Clean Version           |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_STRUCTURE_MQH
#define ANALYSIS_STRUCTURE_MQH

#include "SonicR_CommonStructs.mqh"

namespace ApexSonicR {

//+------------------------------------------------------------------+
//| Structure Analysis States                                        |
//+------------------------------------------------------------------+
enum ENUM_STRUCTURE_STATE {
    STRUCTURE_UNDEFINED = 0,
    STRUCTURE_UPTREND = 1,
    STRUCTURE_DOWNTREND = 2,
    STRUCTURE_SIDEWAYS = 3,
    STRUCTURE_BULLISH_REVERSAL = 4,
    STRUCTURE_BEARISH_REVERSAL = 5
};

//+------------------------------------------------------------------+
//| Structure Analysis Information                                   |
//+------------------------------------------------------------------+
struct SStructureInfo {
    ENUM_STRUCTURE_STATE state;
    double               strength;
    datetime             lastUpdate;
    int                  trendDuration;
    bool                 isValid;
    
    SStructureInfo() : state(STRUCTURE_UNDEFINED), strength(0.0), lastUpdate(0), trendDuration(0), isValid(false) {}
};

//+------------------------------------------------------------------+
//| CStructureAnalysis - Market Structure Analysis                  |
//+------------------------------------------------------------------+
class CStructureAnalysis 
{
private:
    bool                m_initialized;
    CLogger*            m_logger;
    CSymbolInfo*        m_symbolInfo;
    
    SStructureInfo      m_currentStructure;
    double              m_highBuffer[];
    double              m_lowBuffer[];
    
public:
    CStructureAnalysis() : 
        m_initialized(false),
        m_logger(NULL),
        m_symbolInfo(NULL)
    {
        ArraySetAsSeries(m_highBuffer, true);
        ArraySetAsSeries(m_lowBuffer, true);
    }
    
    ~CStructureAnalysis() {}
    
    bool Initialize(CLogger* logger, CSymbolInfo* symbolInfo) {
        if (!logger || !symbolInfo) return false;
        
        m_logger = logger;
        m_symbolInfo = symbolInfo;
        m_initialized = true;
        
        return true;
    }
    
    void Deinitialize() {
        m_initialized = false;
    }
    
    bool IsInitialized() const { return m_initialized; }
    
    void OnTick() {
        if (!m_initialized) return;
        UpdateStructure();
    }
    
    // Public getters
    SStructureInfo GetStructureInfo() const { return m_currentStructure; }
    ENUM_STRUCTURE_STATE GetState() const { return m_currentStructure.state; }
    double GetStrength() const { return m_currentStructure.strength; }
    bool IsValid() const { return m_currentStructure.isValid; }
    
    // Structure checks
    bool IsUptrend() const { return m_currentStructure.state == STRUCTURE_UPTREND; }
    bool IsDowntrend() const { return m_currentStructure.state == STRUCTURE_DOWNTREND; }
    bool IsSideways() const { return m_currentStructure.state == STRUCTURE_SIDEWAYS; }
    bool IsReversal() const { 
        return m_currentStructure.state == STRUCTURE_BULLISH_REVERSAL || 
               m_currentStructure.state == STRUCTURE_BEARISH_REVERSAL; 
    }

private:
    void UpdateStructure() {
        // Copy price data
        if (CopyHigh(Symbol(), PERIOD_CURRENT, 0, 20, m_highBuffer) < 20) return;
        if (CopyLow(Symbol(), PERIOD_CURRENT, 0, 20, m_lowBuffer) < 20) return;
        
        // Simple structure analysis
        AnalyzeStructure();
        
        m_currentStructure.lastUpdate = TimeCurrent();
        m_currentStructure.isValid = true;
    }
    
    void AnalyzeStructure() {
        // Simple trend analysis based on recent highs and lows
        double recentHigh = m_highBuffer[0];
        double recentLow = m_lowBuffer[0];
        double previousHigh = m_highBuffer[5];
        double previousLow = m_lowBuffer[5];
        
        // Calculate trend strength
        double highDiff = recentHigh - previousHigh;
        double lowDiff = recentLow - previousLow;
        
        // Determine structure state
        if (highDiff > 0 && lowDiff > 0) {
            // Higher highs and higher lows
            m_currentStructure.state = STRUCTURE_UPTREND;
            m_currentStructure.strength = (highDiff + lowDiff) / 2;
        }
        else if (highDiff < 0 && lowDiff < 0) {
            // Lower highs and lower lows
            m_currentStructure.state = STRUCTURE_DOWNTREND;
            m_currentStructure.strength = -(highDiff + lowDiff) / 2;
        }
        else {
            // Mixed signals - sideways
            m_currentStructure.state = STRUCTURE_SIDEWAYS;
            m_currentStructure.strength = MathAbs(highDiff - lowDiff);
        }
        
        // Normalize strength
        double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
        m_currentStructure.strength = m_currentStructure.strength / point;
    }
};

} // namespace ApexSonicR

#endif // ANALYSIS_STRUCTURE_MQH 