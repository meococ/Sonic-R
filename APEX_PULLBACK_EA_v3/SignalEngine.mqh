#ifndef APEX_SIGNALENGINE_MQH_
#define APEX_SIGNALENGINE_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CSignalEngine {
private:
    EAContext* m_pContext; 
    bool m_initialized;
    
    // Indicator Handles
    int m_hTrendEMA;       // Trend EMA (e.g., 200)
    int m_hPullbackEMA;    // Pullback EMA (e.g., 21)
    int m_hRSI;            // RSI for momentum confirmation

public:
    CSignalEngine() {
        m_pContext = NULL;
        m_initialized = false;
        m_hTrendEMA = INVALID_HANDLE;
        m_hPullbackEMA = INVALID_HANDLE;
        m_hRSI = INVALID_HANDLE;
    }

    ~CSignalEngine() {
        // Deinitialization is handled by Core to ensure proper order
    }

    bool Initialize(EAContext* pContext) {
        if (m_initialized) return true;
        m_pContext = pContext;

        if (!m_pContext || !m_pContext->pSymbolInfo || !m_pContext->pLogger || !m_pContext->pErrorHandler || !m_pContext->pIndicatorUtils) {
            if(m_pContext && m_pContext->pErrorHandler) m_pContext->pErrorHandler->HandleError(ERR_INVALID_POINTER, "CSignalEngine::Initialize", "Critical context pointer is NULL");
            return false;
        }

        m_pContext->pLogger->LogInfo("Initializing SignalEngine...");

        const SSignalSettings& settings = m_pContext->Inputs.Signal;
        string symbol = m_pContext->pSymbolInfo->Name();
        ENUM_TIMEFRAMES timeframe = m_pContext->Inputs.Timeframe;

        // --- Create Indicators using IndicatorUtils Service ---
        m_hTrendEMA = m_pContext->pIndicatorUtils->CreateMA(symbol, timeframe, settings.TrendEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
        if (m_hTrendEMA == INVALID_HANDLE) {
            m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CSignalEngine::Initialize", "Failed to create Trend EMA.");
            return false;
        }

        m_hPullbackEMA = m_pContext->pIndicatorUtils->CreateMA(symbol, timeframe, settings.PullbackEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
        if (m_hPullbackEMA == INVALID_HANDLE) {
            m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CSignalEngine::Initialize", "Failed to create Pullback EMA.");
            return false;
        }

        m_hRSI = m_pContext->pIndicatorUtils->CreateRSI(symbol, timeframe, settings.RsiPeriod, PRICE_CLOSE);
        if (m_hRSI == INVALID_HANDLE) {
            m_pContext->pErrorHandler->HandleError(ERR_INIT_INDICATOR_FAILED, "CSignalEngine::Initialize", "Failed to create RSI.");
            return false;
        }

        m_initialized = true;
        m_pContext->pLogger->LogInfo("SignalEngine initialized successfully.");
        return true;
    }

    void Deinitialize() {
        // The handles themselves are released by IndicatorUtils::Deinitialize.
        // This method just resets the state of this class.
        m_initialized = false;
        m_hTrendEMA = INVALID_HANDLE;
        m_hPullbackEMA = INVALID_HANDLE;
        m_hRSI = INVALID_HANDLE;
        if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("SignalEngine deinitialized.");
    }

    SignalType CheckForSignal() {
        if (!m_initialized || !m_pContext || !m_pContext->pMarketData || !m_pContext->pIndicatorUtils) {
            return SIGNAL_NONE;
        }

        // --- Get Indicator Values from the most recently closed bar (shift=1) ---
        double trendEmaValue = m_pContext->pIndicatorUtils->GetSingleData(m_hTrendEMA, 0, 1);
        double pullbackEmaValue = m_pContext->pIndicatorUtils->GetSingleData(m_hPullbackEMA, 0, 1);
        double rsiValue = m_pContext->pIndicatorUtils->GetSingleData(m_hRSI, 0, 1);

        if (trendEmaValue == EMPTY_VALUE || pullbackEmaValue == EMPTY_VALUE || rsiValue == EMPTY_VALUE) {
            return SIGNAL_NONE; // Not enough data or error
        }

        // --- Get Current Price ---
        double currentBid = m_pContext->pMarketData->Bid();
        double currentAsk = m_pContext->pMarketData->Ask();

        if (currentBid == 0 || currentAsk == 0) return SIGNAL_NONE;

        // --- Logging for Debugging ---
        if (m_pContext->Inputs.LogLevel >= LOG_LEVEL_DEBUG) {
            string log_msg = StringFormat("Signal Check: TrendEMA=%.5f, PullbackEMA=%.5f, RSI=%.2f, Bid=%.5f",
                                        trendEmaValue, pullbackEmaValue, rsiValue, currentBid);
            m_pContext->pLogger->LogDebug(log_msg);
        }

        // --- Simplified & Robust Signal Logic ---
        bool isUptrend = (pullbackEmaValue > trendEmaValue);
        bool isDowntrend = (pullbackEmaValue < trendEmaValue);

        // Buy Signal: In an uptrend, price is at or below the pullback EMA, and RSI is above the oversold level.
        if (isUptrend && currentBid <= pullbackEmaValue && rsiValue > m_pContext->Inputs.Signal.RsiOversold) {
            m_pContext->pLogger->LogInfo("BUY SIGNAL: Uptrend, Price at/below Pullback EMA, RSI valid.");
            return SIGNAL_BUY;
        }

        // Sell Signal: In a downtrend, price is at or above the pullback EMA, and RSI is below the overbought level.
        if (isDowntrend && currentAsk >= pullbackEmaValue && rsiValue < m_pContext->Inputs.Signal.RsiOverbought) {
            m_pContext->pLogger->LogInfo("SELL SIGNAL: Downtrend, Price at/above Pullback EMA, RSI valid.");
            return SIGNAL_SELL;
        }

        return SIGNAL_NONE;
    }
};

} // namespace ApexPullback

#endif // SIGNALENGINE_MQH_