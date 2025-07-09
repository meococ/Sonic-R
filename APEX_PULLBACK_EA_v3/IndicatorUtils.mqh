//+------------------------------------------------------------------+
//| File: IndicatorUtils.mqh                                         |
//| Purpose: Centralizes all indicator calculations for the EA.      |
//| Version: 14.2 (Corrected)                                        |
//+------------------------------------------------------------------+

#ifndef INDICATORUTILS_MQH_
#define INDICATORUTILS_MQH_

#include "CommonStructs.mqh" // Included for EAContext and Enums

namespace ApexPullback {

// Struct to hold MA handle information, managed by CArrayObj
struct MAHandleInfo {
    int             period;
    ENUM_TIMEFRAMES timeframe;
    int             handle;

    MAHandleInfo(int p, ENUM_TIMEFRAMES tf, int h) : period(p), timeframe(tf), handle(h) {}
};

// CIndicatorUtils Class: A robust, centralized service for all indicator needs.
class CIndicatorUtils {
private:
    EAContext* m_pContext;      // Pointer to the single source of truth
    bool       m_initialized;   // Initialization status flag

    // --- Indicator Handles ---
    CArrayObj* m_ma_handles;    // Dynamically manages all MA handles

    // Main timeframe handles
    int m_adx_handle;
    int m_rsi_handle;
    int m_atr_handle;
    int m_macd_handle;
    int m_bb_handle;

    // Higher timeframe handles
    int m_htf_adx_handle;
    int m_htf_rsi_handle;
    int m_htf_atr_handle;

    // --- Buffers for Data Retrieval ---
    double m_SingleValueBuffer[]; // Reusable buffer for single value retrieval

    // --- Private Helper Functions ---
    void ReleaseAllHandles();
    int FindMAHandle(int period, ENUM_TIMEFRAMES timeframe);
    bool GetData(int handle, int buffer_num, int start_pos, int count, double &result_buffer[]);
    double GetSingleData(int handle, int buffer_num, int shift);

public:
    // --- Public Indicator Creation Methods ---
    int CreateMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const int ma_shift, const ENUM_MA_METHOD ma_method, const ENUM_APPLIED_PRICE applied_price);
    int CreateRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const ENUM_APPLIED_PRICE applied_price);
    // ... (add other creators like CreateADX, CreateBB etc. as needed)


public:
    // Constructor and Destructor
    CIndicatorUtils();
    ~CIndicatorUtils();

    // === Initialization and Deinitialization ===
    bool Initialize(EAContext* pContext);
    void Deinitialize();
    bool IsInitialized() const { return m_initialized; }

    // === Public Handle Getters ===
    int GetAdxHandle(ENUM_TIMEFRAMES tf = WRONG_VALUE) const;
    int GetRsiHandle(ENUM_TIMEFRAMES tf = WRONG_VALUE) const;
    int GetAtrHandle(ENUM_TIMEFRAMES tf = WRONG_VALUE) const;
    int GetMacdHandle() const { return m_macd_handle; } // MACD is typically used on the main TF only
    int GetBbHandle() const { return m_bb_handle; }     // Bollinger Bands as well
    int GetEmaHandle(int period, ENUM_TIMEFRAMES tf = WRONG_VALUE);

    // === Moving Averages ===
    double GetMA(int period, int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);

    // === ADX and Components ===
    double GetADX(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);
    double GetADXPlus(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);
    double GetADXMinus(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);
    
    // === RSI ===
    double GetRSI(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);
    
    // === ATR ===
    double GetATR(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE);
    double GetATRRatio(int lookbackPeriods = 10);
    
    // === MACD ===
    double GetMACDMain(int shift = 0);
    double GetMACDSignal(int shift = 0);
    double GetMACDHistogram(int shift = 0);
    double GetMACDHistogramSlope(int periods = 3);
    
    // === Bollinger Bands ===
    double GetBBUpper(int shift = 0);
    double GetBBMiddle(int shift = 0);
    double GetBBLower(int shift = 0);
    double GetBBWidth(int shift = 0);
    
    // === Volume & Spread (Example implementations, require price data from context) ===
    double GetVolume(int shift = 0);
    double GetAverageVolume(int periods = 20);
    double GetCurrentSpread();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIndicatorUtils::CIndicatorUtils() : 
    m_pContext(NULL), 
    m_initialized(false),
    m_ma_handles(NULL),
    m_adx_handle(INVALID_HANDLE),
    m_rsi_handle(INVALID_HANDLE),
    m_atr_handle(INVALID_HANDLE),
    m_macd_handle(INVALID_HANDLE),
    m_bb_handle(INVALID_HANDLE),
    m_htf_adx_handle(INVALID_HANDLE),
    m_htf_rsi_handle(INVALID_HANDLE),
    m_htf_atr_handle(INVALID_HANDLE)
{
    m_ma_handles = new CArrayObj();
    ArraySetAsSeries(m_SingleValueBuffer, true);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIndicatorUtils::~CIndicatorUtils() 
{
    Deinitialize();
    if(m_ma_handles) {
        delete m_ma_handles; // Clean up the container itself
        m_ma_handles = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize All Indicators                                        |
//+------------------------------------------------------------------+
bool CIndicatorUtils::Initialize(EAContext* pContext)
{
    m_pContext = pContext;

    if (m_initialized) {
        if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("IndicatorUtils already initialized.");
        return true;
    }

    if (!m_pContext || !m_pContext->pErrorHandler) {
        Print("CRITICAL: CIndicatorUtils cannot initialize without a valid context and error handler.");
        return false;
    }
    
    if(m_pContext->pLogger) m_pContext->pLogger->LogDebug("Initializing IndicatorUtils service...");

    // Initialization is now lightweight. We just set the flag.
    // Indicators are created on-demand by other modules.
    m_initialized = true;
    if(m_pContext->pLogger) m_pContext->pLogger->LogInfo("IndicatorUtils service is ready.");

    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CIndicatorUtils::Deinitialize()
{
    if (m_pContext && m_pContext->pLogger) {
        m_pContext->pLogger->LogDebug("Deinitializing CIndicatorUtils...");
    }
    ReleaseAllHandles();
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| ReleaseAllHandles (Private Helper)                               |
//+------------------------------------------------------------------+
void CIndicatorUtils::ReleaseAllHandles()
{
    // Release standard indicators
    if(m_adx_handle != INVALID_HANDLE) { IndicatorRelease(m_adx_handle); m_adx_handle = INVALID_HANDLE; }
    if(m_rsi_handle != INVALID_HANDLE) { IndicatorRelease(m_rsi_handle); m_rsi_handle = INVALID_HANDLE; }
    if(m_atr_handle != INVALID_HANDLE) { IndicatorRelease(m_atr_handle); m_atr_handle = INVALID_HANDLE; }
    if(m_macd_handle != INVALID_HANDLE) { IndicatorRelease(m_macd_handle); m_macd_handle = INVALID_HANDLE; }
    if(m_bb_handle != INVALID_HANDLE) { IndicatorRelease(m_bb_handle); m_bb_handle = INVALID_HANDLE; }
    
    // Release HTF indicators
    if(m_htf_adx_handle != INVALID_HANDLE) { IndicatorRelease(m_htf_adx_handle); m_htf_adx_handle = INVALID_HANDLE; }
    if(m_htf_rsi_handle != INVALID_HANDLE) { IndicatorRelease(m_htf_rsi_handle); m_htf_rsi_handle = INVALID_HANDLE; }
    if(m_htf_atr_handle != INVALID_HANDLE) { IndicatorRelease(m_htf_atr_handle); m_htf_atr_handle = INVALID_HANDLE; }

    // Release all MA indicators from the dynamic array
    if (m_ma_handles) {
        for (int i = m_ma_handles->Total() - 1; i >= 0; i--) {
            MAHandleInfo* info = m_ma_handles->At(i);
            if (info) {
                if (info->handle != INVALID_HANDLE) {
                    IndicatorRelease(info->handle);
                }
                delete info; // Free the memory for the object itself
            }
        }
        m_ma_handles->Clear(); // Clear the array of pointers
    }
}

//+------------------------------------------------------------------+
//| FindMAHandle (Private Helper)                                    |
//+------------------------------------------------------------------+
bool CIndicatorUtils::CreateBaseIndicators()
{
    // Dependencies are checked in Initialize(), so we assume they are valid here.
    const string symbol = m_pContext->pSymbolInfo->Symbol();
    const ENUM_TIMEFRAMES main_tf = m_pContext->Inputs.MainTimeframe;

    if(m_pContext->pLogger) m_pContext->pLogger->LogDebug("Creating base indicators on " + EnumToString(main_tf) + "...");

    // --- EMAs ---
    for (int i = 0; i < m_pContext->Inputs.MA.NumEMAs; i++) {
        int period = m_pContext->Inputs.MA.EMAPeriods[i];
        if (period > 0) {
            int handle = iMA(symbol, main_tf, period, 0, m_pContext->Inputs.MA.EMAMethod, m_pContext->Inputs.MA.EMAAppliedPrice);
            if(handle == INVALID_HANDLE) {
                m_pContext->pErrorHandler->HandleError(ERR_INDICATOR_CREATE, "CreateBaseIndicators - Failed to create EMA(" + (string)period + ") on " + EnumToString(main_tf));
                return false;
            }
            MAHandleInfo* info = new MAHandleInfo(period, main_tf, handle);
            if(!m_ma_handles->Add(info)){
                 m_pContext->pErrorHandler->HandleError(ERR_CREATE_OBJECT, "CreateBaseIndicators - Failed to add EMA handle to array for period " + (string)period);
                 delete info;
                 return false;
            }
        }
    }

    // --- Other Indicators ---
    m_adx_handle = iADX(symbol, main_tf, m_pContext->Inputs.ADX.Period);
    m_rsi_handle = iRSI(symbol, main_tf, m_pContext->Inputs.RSI.Period, m_pContext->Inputs.RSI.AppliedPrice);
    m_atr_handle = iATR(symbol, main_tf, m_pContext->Inputs.ATR.Period);
    m_macd_handle = iMACD(symbol, main_tf, m_pContext->Inputs.MACD.FastEMA, m_pContext->Inputs.MACD.SlowEMA, m_pContext->Inputs.MACD.SignalSMA, m_pContext->Inputs.MACD.AppliedPrice);
    m_bb_handle = iBands(symbol, main_tf, m_pContext->Inputs.BB.Period, m_pContext->Inputs.BB.Shift, m_pContext->Inputs.BB.Deviation, m_pContext->Inputs.BB.AppliedPrice);

    if (m_adx_handle == INVALID_HANDLE || m_rsi_handle == INVALID_HANDLE || m_atr_handle == INVALID_HANDLE || m_macd_handle == INVALID_HANDLE || m_bb_handle == INVALID_HANDLE) {
        m_pContext->pErrorHandler->HandleError(ERR_INDICATOR_CREATE, "CreateBaseIndicators - Failed to create one or more base indicators on " + EnumToString(main_tf));
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| CreateMultiTimeframeIndicators (Private Helper)                  |
//+------------------------------------------------------------------+
bool CIndicatorUtils::CreateMultiTimeframeIndicators()
{
    if(!m_context || !m_context->Logger) return false;
    
    const SCoreStrategyConfig& strategy_config = m_context->Inputs.CoreStrategy;
    const ENUM_TIMEFRAMES htf = strategy_config.HigherTimeframe;

    m_context->Logger->LogInfo("Creating multi-timeframe indicators on " + EnumToString(htf) + "...", "IndicatorUtils");

    // --- EMAs ---
    for (int i = 0; i < m_context->Inputs.MA.NumEMAs; i++) {
        int period = m_context->Inputs.MA.EMAPeriods[i];
        if (period > 0) {
            int handle = iMA(m_context->Symbol, htf, period, 0, m_context->Inputs.MA.EMAMethod, m_context->Inputs.MA.EMAAppliedPrice);
            if (handle == INVALID_HANDLE) {
                m_context->Logger->LogError("Failed to create EMA(" + (string)period + ") on " + EnumToString(htf), "IndicatorUtils");
                return false;
            }
            MAHandleInfo* info = new MAHandleInfo(period, htf, handle);
            if(!m_ma_handles->Add(info)){
                 m_context->Logger->LogError("Failed to add HTF EMA handle to array for period " + (string)period, "IndicatorUtils");
                 delete info;
                 return false;
            }
        }
    }

    // --- Other Indicators ---
    m_htf_adx_handle = iADX(m_context->Symbol, htf, m_context->Inputs.ADX.Period);
    m_htf_rsi_handle = iRSI(m_context->Symbol, htf, m_context->Inputs.RSI.Period, m_context->Inputs.RSI.AppliedPrice);
    m_htf_atr_handle = iATR(m_context->Symbol, htf, m_context->Inputs.ATR.Period);

    if (m_htf_adx_handle == INVALID_HANDLE || m_htf_rsi_handle == INVALID_HANDLE || m_htf_atr_handle == INVALID_HANDLE) {
        m_context->Logger->LogError("Failed to create one or more HTF indicators on " + EnumToString(htf), "IndicatorUtils");
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| GetMAHandle (Private Helper)                                     |
//+------------------------------------------------------------------+
int CIndicatorUtils::FindMAHandle(int period, ENUM_TIMEFRAMES timeframe)
{
    if (!m_context || !m_ma_handles) return INVALID_HANDLE;
    if (timeframe == WRONG_VALUE) timeframe = m_context->Inputs.CoreStrategy.MainTimeframe;

    for (int i = 0; i < m_ma_handles->Total(); i++) {
        MAHandleInfo* info = m_ma_handles->At(i);
        if (info && info->period == period && info->timeframe == timeframe) {
            return info->handle;
        }
    }
    return INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| GetAdxHandle (Public)                                            |
//+------------------------------------------------------------------+
int CIndicatorUtils::GetAdxHandle(ENUM_TIMEFRAMES tf) const
{
    if (!m_context) return INVALID_HANDLE;
    const ENUM_TIMEFRAMES main_tf = m_context->Inputs.CoreStrategy.MainTimeframe;
    const ENUM_TIMEFRAMES htf = m_context->Inputs.CoreStrategy.HigherTimeframe;

    if (tf == WRONG_VALUE || tf == main_tf) {
        return m_adx_handle;
    }
    if (m_context->Inputs.CoreStrategy.UseMultiTimeframe && tf == htf) {
        return m_htf_adx_handle;
    }
    return INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| GetRsiHandle (Public)                                            |
//+------------------------------------------------------------------+
int CIndicatorUtils::GetRsiHandle(ENUM_TIMEFRAMES tf) const
{
    if (!m_context) return INVALID_HANDLE;
    const ENUM_TIMEFRAMES main_tf = m_context->Inputs.CoreStrategy.MainTimeframe;
    const ENUM_TIMEFRAMES htf = m_context->Inputs.CoreStrategy.HigherTimeframe;

    if (tf == WRONG_VALUE || tf == main_tf) {
        return m_rsi_handle;
    }
    if (m_context->Inputs.CoreStrategy.UseMultiTimeframe && tf == htf) {
        return m_htf_rsi_handle;
    }
    return INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| GetAtrHandle (Public)                                            |
//+------------------------------------------------------------------+
int CIndicatorUtils::GetAtrHandle(ENUM_TIMEFRAMES tf) const
{
    if (!m_context) return INVALID_HANDLE;
    const ENUM_TIMEFRAMES main_tf = m_context->Inputs.CoreStrategy.MainTimeframe;
    const ENUM_TIMEFRAMES htf = m_context->Inputs.CoreStrategy.HigherTimeframe;

    if (tf == WRONG_VALUE || tf == main_tf) {
        return m_atr_handle;
    }
    if (m_context->Inputs.CoreStrategy.UseMultiTimeframe && tf == htf) {
        return m_htf_atr_handle;
    }
    return INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| GetEmaHandle (Public)                                            |
//+------------------------------------------------------------------+
int CIndicatorUtils::GetEmaHandle(int period, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    return FindMAHandle(period, tf);
}

//+------------------------------------------------------------------+
//| CreateMA (Public, On-Demand)                                     |
//+------------------------------------------------------------------+
int CIndicatorUtils::CreateMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const int ma_shift, const ENUM_MA_METHOD ma_method, const ENUM_APPLIED_PRICE applied_price)
{
    if (!m_initialized) return INVALID_HANDLE;

    // First, check if we already have this exact handle
    int existing_handle = FindMAHandle(period, timeframe);
    if(existing_handle != INVALID_HANDLE) {
        return existing_handle;
    }

    // If not, create it
    int handle = iMA(symbol, timeframe, period, ma_shift, ma_method, applied_price);
    
    if (handle != INVALID_HANDLE) {
        // Store it for reuse
        MAHandleInfo* info = new MAHandleInfo(period, timeframe, handle);
        if(info && m_ma_handles) {
            m_ma_handles->Add(info);
        } else {
            // Memory allocation failed, release the created handle to prevent leaks
            IndicatorRelease(handle);
            if(m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_NOT_ENOUGH_MEMORY, "CIndicatorUtils::CreateMA", "Failed to allocate MAHandleInfo");
            return INVALID_HANDLE;
        }
    } else {
        if(m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CIndicatorUtils::CreateMA", "iMA failed for period " + (string)period);
    }
    
    return handle;
}

//+------------------------------------------------------------------+
//| CreateRSI (Public, On-Demand)                                    |
//+------------------------------------------------------------------+
int CIndicatorUtils::CreateRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const ENUM_APPLIED_PRICE applied_price)
{
    if (!m_initialized) return INVALID_HANDLE;

    // For simplicity, we'll manage one RSI handle per timeframe.
    // A more complex system could manage multiple RSI with different periods.
    if (timeframe == m_pContext->Inputs.Timeframe) {
        if (m_rsi_handle != INVALID_HANDLE) return m_rsi_handle;
        m_rsi_handle = iRSI(symbol, timeframe, period, applied_price);
        if(m_rsi_handle == INVALID_HANDLE && m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CIndicatorUtils::CreateRSI", "iRSI failed for main timeframe");
        return m_rsi_handle;
    } else if (m_pContext->Inputs.CoreStrategy.UseMultiTimeframe && timeframe == m_pContext->Inputs.CoreStrategy.MultiTimeframe) {
        if (m_htf_rsi_handle != INVALID_HANDLE) return m_htf_rsi_handle;
        m_htf_rsi_handle = iRSI(symbol, timeframe, period, applied_price);
        if(m_htf_rsi_handle == INVALID_HANDLE && m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CIndicatorUtils::CreateRSI", "iRSI failed for HTF");
        return m_htf_rsi_handle;
    }
    
    // If it's a non-standard timeframe, create a temporary handle (not recommended for frequent use)
    int handle = iRSI(symbol, timeframe, period, applied_price);
    if(handle == INVALID_HANDLE && m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CIndicatorUtils::CreateRSI", "iRSI failed for ad-hoc timeframe");
    return handle;
}

//+------------------------------------------------------------------+
//| GetMA (Public)                                                   |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetMA(int period, int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetMAHandle(period, tf);
    return GetSingleData(handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetADX (Public)                                                  |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetADX(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetAdxHandle(tf);
    return GetSingleData(handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetADXPlus (Public)                                              |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetADXPlus(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetAdxHandle(tf);
    return GetSingleData(handle, 1, shift);
}

//+------------------------------------------------------------------+
//| GetADXMinus (Public)                                             |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetADXMinus(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetAdxHandle(tf);
    return GetSingleData(handle, 2, shift);
}

//+------------------------------------------------------------------+
//| GetRSI (Public)                                                  |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetRSI(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetRsiHandle(tf);
    return GetSingleData(handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetATR (Public)                                                  |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetATR(int shift = 0, ENUM_TIMEFRAMES tf = WRONG_VALUE)
{
    int handle = GetAtrHandle(tf);
    return GetSingleData(handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetATRRatio                                                      |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetATRRatio(int lookbackPeriods = 10)
{
    if (!m_initialized || !m_context) return EMPTY_VALUE;
    double currentAtr = GetATR(0);
    double sum = 0;
    for (int i = 1; i <= lookbackPeriods; i++) {
        sum += GetATR(i);
    }
    double avgAtr = sum / lookbackPeriods;
    if (avgAtr == 0) return EMPTY_VALUE;
    return currentAtr / avgAtr;
}

//+------------------------------------------------------------------+
//| GetMACDMain                                                      |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetMACDMain(int shift = 0)
{
    return GetSingleData(m_macd_handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetMACDSignal                                                    |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetMACDSignal(int shift = 0)
{
    return GetSingleData(m_macd_handle, 1, shift);
}

//+------------------------------------------------------------------+
//| GetMACDHistogram                                                 |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetMACDHistogram(int shift = 0)
{
    return GetMACDMain(shift) - GetMACDSignal(shift);
}

//+------------------------------------------------------------------+
//| GetMACDHistogramSlope                                            |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetMACDHistogramSlope(int periods = 3)
{
    if (periods < 2) return 0.0;
    double currentHist = GetMACDHistogram(0);
    double previousHist = GetMACDHistogram(periods - 1);
    if(previousHist == EMPTY_VALUE || currentHist == EMPTY_VALUE) return 0.0;
    return (currentHist - previousHist);
}

//+------------------------------------------------------------------+
//| GetBBUpper                                                       |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetBBUpper(int shift = 0)
{
    return GetSingleData(m_bb_handle, 1, shift);
}

//+------------------------------------------------------------------+
//| GetBBMiddle                                                      |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetBBMiddle(int shift = 0)
{
    return GetSingleData(m_bb_handle, 0, shift);
}

//+------------------------------------------------------------------+
//| GetBBLower                                                       |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetBBLower(int shift = 0)
{
    return GetSingleData(m_bb_handle, 2, shift);
}

//+------------------------------------------------------------------+
//| GetBBWidth                                                       |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetBBWidth(int shift = 0)
{
    double upper = GetBBUpper(shift);
    double lower = GetBBLower(shift);
    double middle = GetBBMiddle(shift);
    if(upper == EMPTY_VALUE || lower == EMPTY_VALUE || middle == 0 || middle == EMPTY_VALUE) return EMPTY_VALUE;
    return (upper - lower) / middle;
}

//+------------------------------------------------------------------+
//| GetVolume                                                        |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetVolume(int shift = 0)
{
    if(!m_context) return EMPTY_VALUE;
    MqlRates rates[];
    if(CopyRates(m_context->Symbol, m_context->Inputs.CoreStrategy.MainTimeframe, shift, 1, rates) <= 0) return EMPTY_VALUE;
    return rates[0].tick_volume;
}

//+------------------------------------------------------------------+
//| GetAverageVolume                                                 |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetAverageVolume(int periods = 20)
{
    if(!m_context || periods <= 0) return EMPTY_VALUE;
    MqlRates rates[];
    if(CopyRates(m_context->Symbol, m_context->Inputs.CoreStrategy.MainTimeframe, 1, periods, rates) < periods) return EMPTY_VALUE;
    double sum = 0;
    for(int i=0; i<periods; i++){
        sum += rates[i].tick_volume;
    }
    return sum / periods;
}

//+------------------------------------------------------------------+
//| GetCurrentSpread                                                 |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetCurrentSpread()
{
    if(!m_context) return EMPTY_VALUE;
    MqlTick tick;
    if(!SymbolInfoTick(m_context->Symbol, tick)) return EMPTY_VALUE;
    return (tick.ask - tick.bid);
}

//+------------------------------------------------------------------+
//| GetData (Private Helper)                                         |
//+------------------------------------------------------------------+
bool CIndicatorUtils::GetData(int handle, int buffer_num, int start_pos, int count, double &result_buffer[])
{
    if (handle == INVALID_HANDLE) return false;
    if (CopyBuffer(handle, buffer_num, start_pos, count, result_buffer) != count) {
        // m_context->Logger->LogWarning("GetData: CopyBuffer failed for handle " + (string)handle);
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| GetSingleData (Private Helper)                                   |
//+------------------------------------------------------------------+
double CIndicatorUtils::GetSingleData(int handle, int buffer_num, int shift)
{
    if (GetData(handle, buffer_num, shift, 1, m_SingleValueBuffer)) {
        return m_SingleValueBuffer[0];
    }
    return EMPTY_VALUE;
}

} // END namespace ApexPullback
#endif // INDICATORUTILS_MQH_