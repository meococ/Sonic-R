//+------------------------------------------------------------------+
//|                                          Signal_Confirmation.mqh |
//|                        APEX Pullback EA v5 - Signal Confirmation |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"
#include <Indicators\Indicators.mqh>

//+------------------------------------------------------------------+
//| Signal Confirmation Class                                        |
//+------------------------------------------------------------------+
class CSignalConfirmation {
private:
    CLogger*            m_logger;
    string              m_symbol;
    ENUM_TIMEFRAMES     m_timeframe;
    
    // Indicator handles
    int                 m_rsiHandle;
    int                 m_macdHandle;
    int                 m_stochHandle;
    int                 m_atrHandle;
    int                 m_adxHandle;
    int                 m_cciHandle;
    
    // Confirmation settings
    bool                m_useRSI;
    bool                m_useMACD;
    bool                m_useStochastic;
    bool                m_useATR;
    bool                m_useADX;
    bool                m_useCCI;
    bool                m_useVolumeConfirmation;
    bool                m_useCandlePatterns;
    
    // RSI parameters
    int                 m_rsiPeriod;
    double              m_rsiOverbought;
    double              m_rsiOversold;
    
    // MACD parameters
    int                 m_macdFast;
    int                 m_macdSlow;
    int                 m_macdSignal;
    
    // Stochastic parameters
    int                 m_stochK;
    int                 m_stochD;
    int                 m_stochSlowing;
    double              m_stochOverbought;
    double              m_stochOversold;
    
    // ATR parameters
    int                 m_atrPeriod;
    double              m_atrMultiplier;
    
    // ADX parameters
    int                 m_adxPeriod;
    double              m_adxThreshold;
    
    // CCI parameters
    int                 m_cciPeriod;
    double              m_cciOverbought;
    double              m_cciOversold;
    
    // Volume parameters
    int                 m_volumePeriod;
    double              m_volumeMultiplier;
    
    bool                m_isInitialized;
    
public:
    // Constructor
    CSignalConfirmation() {
        m_logger = NULL;
        m_symbol = "";
        m_timeframe = PERIOD_CURRENT;
        
        // Initialize handles
        m_rsiHandle = INVALID_HANDLE;
        m_macdHandle = INVALID_HANDLE;
        m_stochHandle = INVALID_HANDLE;
        m_atrHandle = INVALID_HANDLE;
        m_adxHandle = INVALID_HANDLE;
        m_cciHandle = INVALID_HANDLE;
        
        // Default confirmation settings
        m_useRSI = true;
        m_useMACD = true;
        m_useStochastic = true;
        m_useATR = true;
        m_useADX = true;
        m_useCCI = false;
        m_useVolumeConfirmation = true;
        m_useCandlePatterns = true;
        
        // Default RSI parameters
        m_rsiPeriod = 14;
        m_rsiOverbought = 70.0;
        m_rsiOversold = 30.0;
        
        // Default MACD parameters
        m_macdFast = 12;
        m_macdSlow = 26;
        m_macdSignal = 9;
        
        // Default Stochastic parameters
        m_stochK = 5;
        m_stochD = 3;
        m_stochSlowing = 3;
        m_stochOverbought = 80.0;
        m_stochOversold = 20.0;
        
        // Default ATR parameters
        m_atrPeriod = 14;
        m_atrMultiplier = 2.0;
        
        // Default ADX parameters
        m_adxPeriod = 14;
        m_adxThreshold = 25.0;
        
        // Default CCI parameters
        m_cciPeriod = 14;
        m_cciOverbought = 100.0;
        m_cciOversold = -100.0;
        
        // Default Volume parameters
        m_volumePeriod = 20;
        m_volumeMultiplier = 1.5;
        
        m_isInitialized = false;
    }
    
    // Destructor
    ~CSignalConfirmation() {
        Deinitialize();
    }
    
    // Initialize signal confirmation
    bool Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger = NULL) {
        m_symbol = symbol;
        m_timeframe = timeframe;
        m_logger = logger;
        
        // Initialize RSI
        if(m_useRSI) {
            m_rsiHandle = iRSI(m_symbol, m_timeframe, m_rsiPeriod, PRICE_CLOSE);
            if(m_rsiHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create RSI indicator");
                return false;
            }
        }
        
        // Initialize MACD
        if(m_useMACD) {
            m_macdHandle = iMACD(m_symbol, m_timeframe, m_macdFast, m_macdSlow, m_macdSignal, PRICE_CLOSE);
            if(m_macdHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create MACD indicator");
                return false;
            }
        }
        
        // Initialize Stochastic
        if(m_useStochastic) {
            m_stochHandle = iStochastic(m_symbol, m_timeframe, m_stochK, m_stochD, m_stochSlowing, MODE_SMA, STO_LOWHIGH);
            if(m_stochHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create Stochastic indicator");
                return false;
            }
        }
        
        // Initialize ATR
        if(m_useATR) {
            m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
            if(m_atrHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create ATR indicator");
                return false;
            }
        }
        
        // Initialize ADX
        if(m_useADX) {
            m_adxHandle = iADX(m_symbol, m_timeframe, m_adxPeriod);
            if(m_adxHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create ADX indicator");
                return false;
            }
        }
        
        // Initialize CCI
        if(m_useCCI) {
            m_cciHandle = iCCI(m_symbol, m_timeframe, m_cciPeriod, PRICE_TYPICAL);
            if(m_cciHandle == INVALID_HANDLE) {
                LOG_ERROR("Failed to create CCI indicator");
                return false;
            }
        }
        
        m_isInitialized = true;
        
        if(m_logger) {
            m_logger.LogInfo("Signal Confirmation initialized for " + m_symbol);
            m_logger.LogInfo("Timeframe: " + EnumToString(m_timeframe), __FUNCTION__);
        }
        
        return true;
    }
    
    // Deinitialize
    void Deinitialize() {
        if(m_rsiHandle != INVALID_HANDLE) {
            IndicatorRelease(m_rsiHandle);
            m_rsiHandle = INVALID_HANDLE;
        }
        
        if(m_macdHandle != INVALID_HANDLE) {
            IndicatorRelease(m_macdHandle);
            m_macdHandle = INVALID_HANDLE;
        }
        
        if(m_stochHandle != INVALID_HANDLE) {
            IndicatorRelease(m_stochHandle);
            m_stochHandle = INVALID_HANDLE;
        }
        
        if(m_atrHandle != INVALID_HANDLE) {
            IndicatorRelease(m_atrHandle);
            m_atrHandle = INVALID_HANDLE;
        }
        
        if(m_adxHandle != INVALID_HANDLE) {
            IndicatorRelease(m_adxHandle);
            m_adxHandle = INVALID_HANDLE;
        }
        
        if(m_cciHandle != INVALID_HANDLE) {
            IndicatorRelease(m_cciHandle);
            m_cciHandle = INVALID_HANDLE;
        }
        
        m_isInitialized = false;
        
        if(m_logger) {
            m_logger.LogInfo("Signal Confirmation deinitialized", __FUNCTION__);
        }
    }
    
    // Confirm buy signal
    bool ConfirmBuySignal(double& confidence) {
        if(!m_isInitialized) {
            confidence = 0.0;
            return false;
        }
        
        int confirmations = 0;
        int totalChecks = 0;
        confidence = 0.0;
        
        // RSI confirmation
        if(m_useRSI && IsRSIBullish()) {
            confirmations++;
            confidence += 20.0;
        }
        if(m_useRSI) totalChecks++;
        
        // MACD confirmation
        if(m_useMACD && IsMACDBullish()) {
            confirmations++;
            confidence += 20.0;
        }
        if(m_useMACD) totalChecks++;
        
        // Stochastic confirmation
        if(m_useStochastic && IsStochasticBullish()) {
            confirmations++;
            confidence += 15.0;
        }
        if(m_useStochastic) totalChecks++;
        
        // ADX confirmation (trend strength)
        if(m_useADX && IsADXStrong()) {
            confirmations++;
            confidence += 15.0;
        }
        if(m_useADX) totalChecks++;
        
        // CCI confirmation
        if(m_useCCI && IsCCIBullish()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useCCI) totalChecks++;
        
        // Volume confirmation
        if(m_useVolumeConfirmation && IsVolumeConfirming()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useVolumeConfirmation) totalChecks++;
        
        // Candle pattern confirmation
        if(m_useCandlePatterns && IsBullishCandlePattern()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useCandlePatterns) totalChecks++;
        
        // Calculate final confidence
        if(totalChecks > 0) {
            confidence = MathMin(confidence, 100.0);
        }
        
        // Require at least 60% of indicators to confirm
        bool confirmed = (totalChecks > 0) && ((double)confirmations / totalChecks >= 0.6);
        
        if(m_logger && confirmed) {
            m_logger.LogDebug("Buy signal confirmed. Confirmations: " + IntegerToString(confirmations) + 
                            "/" + IntegerToString(totalChecks) + 
                            ", Confidence: " + DoubleToString(confidence, 1) + "%", __FUNCTION__);
        }
        
        return confirmed;
    }
    
    // Confirm sell signal
    bool ConfirmSellSignal(double& confidence) {
        if(!m_isInitialized) {
            confidence = 0.0;
            return false;
        }
        
        int confirmations = 0;
        int totalChecks = 0;
        confidence = 0.0;
        
        // RSI confirmation
        if(m_useRSI && IsRSIBearish()) {
            confirmations++;
            confidence += 20.0;
        }
        if(m_useRSI) totalChecks++;
        
        // MACD confirmation
        if(m_useMACD && IsMACDBearish()) {
            confirmations++;
            confidence += 20.0;
        }
        if(m_useMACD) totalChecks++;
        
        // Stochastic confirmation
        if(m_useStochastic && IsStochasticBearish()) {
            confirmations++;
            confidence += 15.0;
        }
        if(m_useStochastic) totalChecks++;
        
        // ADX confirmation (trend strength)
        if(m_useADX && IsADXStrong()) {
            confirmations++;
            confidence += 15.0;
        }
        if(m_useADX) totalChecks++;
        
        // CCI confirmation
        if(m_useCCI && IsCCIBearish()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useCCI) totalChecks++;
        
        // Volume confirmation
        if(m_useVolumeConfirmation && IsVolumeConfirming()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useVolumeConfirmation) totalChecks++;
        
        // Candle pattern confirmation
        if(m_useCandlePatterns && IsBearishCandlePattern()) {
            confirmations++;
            confidence += 10.0;
        }
        if(m_useCandlePatterns) totalChecks++;
        
        // Calculate final confidence
        if(totalChecks > 0) {
            confidence = MathMin(confidence, 100.0);
        }
        
        // Require at least 60% of indicators to confirm
        bool confirmed = (totalChecks > 0) && ((double)confirmations / totalChecks >= 0.6);
        
        if(m_logger && confirmed) {
            m_logger.LogDebug("Sell signal confirmed. Confirmations: " + IntegerToString(confirmations) + 
                            "/" + IntegerToString(totalChecks) + 
                            ", Confidence: " + DoubleToString(confidence, 1) + "%", __FUNCTION__);
        }
        
        return confirmed;
    }
    
private:
    // RSI analysis
    bool IsRSIBullish() {
        if(m_rsiHandle == INVALID_HANDLE) return false;
        
        double rsi[2];
        if(CopyBuffer(m_rsiHandle, 0, 0, 2, rsi) != 2) return false;
        
        // RSI is bullish if it's above oversold and rising
        return (rsi[0] > m_rsiOversold && rsi[0] > rsi[1] && rsi[0] < m_rsiOverbought);
    }
    
    bool IsRSIBearish() {
        if(m_rsiHandle == INVALID_HANDLE) return false;
        
        double rsi[2];
        if(CopyBuffer(m_rsiHandle, 0, 0, 2, rsi) != 2) return false;
        
        // RSI is bearish if it's below overbought and falling
        return (rsi[0] < m_rsiOverbought && rsi[0] < rsi[1] && rsi[0] > m_rsiOversold);
    }
    
    // MACD analysis
    bool IsMACDBullish() {
        if(m_macdHandle == INVALID_HANDLE) return false;
        
        double macdMain[2], macdSignal[2];
        if(CopyBuffer(m_macdHandle, 0, 0, 2, macdMain) != 2) return false;
        if(CopyBuffer(m_macdHandle, 1, 0, 2, macdSignal) != 2) return false;
        
        // MACD is bullish if main line crosses above signal line
        return (macdMain[0] > macdSignal[0] && macdMain[1] <= macdSignal[1]);
    }
    
    bool IsMACDBearish() {
        if(m_macdHandle == INVALID_HANDLE) return false;
        
        double macdMain[2], macdSignal[2];
        if(CopyBuffer(m_macdHandle, 0, 0, 2, macdMain) != 2) return false;
        if(CopyBuffer(m_macdHandle, 1, 0, 2, macdSignal) != 2) return false;
        
        // MACD is bearish if main line crosses below signal line
        return (macdMain[0] < macdSignal[0] && macdMain[1] >= macdSignal[1]);
    }
    
    // Stochastic analysis
    bool IsStochasticBullish() {
        if(m_stochHandle == INVALID_HANDLE) return false;
        
        double stochMain[2], stochSignal[2];
        if(CopyBuffer(m_stochHandle, 0, 0, 2, stochMain) != 2) return false;
        if(CopyBuffer(m_stochHandle, 1, 0, 2, stochSignal) != 2) return false;
        
        // Stochastic is bullish if %K crosses above %D in oversold area
        return (stochMain[0] > stochSignal[0] && stochMain[1] <= stochSignal[1] && 
                stochMain[0] < m_stochOverbought);
    }
    
    bool IsStochasticBearish() {
        if(m_stochHandle == INVALID_HANDLE) return false;
        
        double stochMain[2], stochSignal[2];
        if(CopyBuffer(m_stochHandle, 0, 0, 2, stochMain) != 2) return false;
        if(CopyBuffer(m_stochHandle, 1, 0, 2, stochSignal) != 2) return false;
        
        // Stochastic is bearish if %K crosses below %D in overbought area
        return (stochMain[0] < stochSignal[0] && stochMain[1] >= stochSignal[1] && 
                stochMain[0] > m_stochOversold);
    }
    
    // ADX analysis
    bool IsADXStrong() {
        if(m_adxHandle == INVALID_HANDLE) return false;
        
        double adx[1];
        if(CopyBuffer(m_adxHandle, 0, 0, 1, adx) != 1) return false;
        
        // ADX indicates strong trend if above threshold
        return (adx[0] > m_adxThreshold);
    }
    
    // CCI analysis
    bool IsCCIBullish() {
        if(m_cciHandle == INVALID_HANDLE) return false;
        
        double cci[2];
        if(CopyBuffer(m_cciHandle, 0, 0, 2, cci) != 2) return false;
        
        // CCI is bullish if rising from oversold
        return (cci[0] > m_cciOversold && cci[0] > cci[1]);
    }
    
    bool IsCCIBearish() {
        if(m_cciHandle == INVALID_HANDLE) return false;
        
        double cci[2];
        if(CopyBuffer(m_cciHandle, 0, 0, 2, cci) != 2) return false;
        
        // CCI is bearish if falling from overbought
        return (cci[0] < m_cciOverbought && cci[0] < cci[1]);
    }
    
    // Volume analysis
    bool IsVolumeConfirming() {
        long volume[2];
        if(CopyTickVolume(m_symbol, m_timeframe, 0, 2, volume) != 2) return false;
        
        // Calculate average volume
        long avgVolume[20];
        if(CopyTickVolume(m_symbol, m_timeframe, 0, m_volumePeriod, avgVolume) != m_volumePeriod) return false;
        
        long totalVolume = 0;
        for(int i = 0; i < m_volumePeriod; i++) {
            totalVolume += avgVolume[i];
        }
        long averageVolume = totalVolume / m_volumePeriod;
        
        // Volume is confirming if current volume is above average
        return (volume[0] > averageVolume * m_volumeMultiplier);
    }
    
    // Candle pattern analysis
    bool IsBullishCandlePattern() {
        double open[3], high[3], low[3], close[3];
        
        if(CopyOpen(m_symbol, m_timeframe, 0, 3, open) != 3) return false;
        if(CopyHigh(m_symbol, m_timeframe, 0, 3, high) != 3) return false;
        if(CopyLow(m_symbol, m_timeframe, 0, 3, low) != 3) return false;
        if(CopyClose(m_symbol, m_timeframe, 0, 3, close) != 3) return false;
        
        // Check for bullish engulfing pattern
        if(IsBullishEngulfing(open, high, low, close)) return true;
        
        // Check for hammer pattern
        if(IsHammer(open, high, low, close)) return true;
        
        // Check for doji at support
        if(IsDoji(open, high, low, close)) return true;
        
        return false;
    }
    
    bool IsBearishCandlePattern() {
        double open[3], high[3], low[3], close[3];
        
        if(CopyOpen(m_symbol, m_timeframe, 0, 3, open) != 3) return false;
        if(CopyHigh(m_symbol, m_timeframe, 0, 3, high) != 3) return false;
        if(CopyLow(m_symbol, m_timeframe, 0, 3, low) != 3) return false;
        if(CopyClose(m_symbol, m_timeframe, 0, 3, close) != 3) return false;
        
        // Check for bearish engulfing pattern
        if(IsBearishEngulfing(open, high, low, close)) return true;
        
        // Check for shooting star pattern
        if(IsShootingStar(open, high, low, close)) return true;
        
        // Check for doji at resistance
        if(IsDoji(open, high, low, close)) return true;
        
        return false;
    }
    
    // Candlestick pattern helpers
    bool IsBullishEngulfing(const double& open[], const double& high[], const double& low[], const double& close[]) {
        // Previous candle is bearish, current candle is bullish and engulfs previous
        return (close[1] < open[1] && // Previous bearish
                close[0] > open[0] && // Current bullish
                open[0] < close[1] && // Current opens below previous close
                close[0] > open[1]);  // Current closes above previous open
    }
    
    bool IsBearishEngulfing(const double& open[], const double& high[], const double& low[], const double& close[]) {
        // Previous candle is bullish, current candle is bearish and engulfs previous
        return (close[1] > open[1] && // Previous bullish
                close[0] < open[0] && // Current bearish
                open[0] > close[1] && // Current opens above previous close
                close[0] < open[1]);  // Current closes below previous open
    }
    
    bool IsHammer(const double& open[], const double& high[], const double& low[], const double& close[]) {
        double body = MathAbs(close[0] - open[0]);
        double lowerShadow = MathMin(open[0], close[0]) - low[0];
        double upperShadow = high[0] - MathMax(open[0], close[0]);
        
        // Hammer: small body, long lower shadow, small upper shadow
        return (lowerShadow > body * 2 && upperShadow < body * 0.5);
    }
    
    bool IsShootingStar(const double& open[], const double& high[], const double& low[], const double& close[]) {
        double body = MathAbs(close[0] - open[0]);
        double lowerShadow = MathMin(open[0], close[0]) - low[0];
        double upperShadow = high[0] - MathMax(open[0], close[0]);
        
        // Shooting star: small body, long upper shadow, small lower shadow
        return (upperShadow > body * 2 && lowerShadow < body * 0.5);
    }
    
    bool IsDoji(const double& open[], const double& high[], const double& low[], const double& close[]) {
        double body = MathAbs(close[0] - open[0]);
        double totalRange = high[0] - low[0];
        
        // Doji: very small body relative to total range
        return (totalRange > 0 && body / totalRange < 0.1);
    }
    
public:
    // Getters and setters
    bool IsInitialized() const { return m_isInitialized; }
    
    // Configuration methods
    void SetRSIParameters(int period, double overbought, double oversold) {
        m_rsiPeriod = period;
        m_rsiOverbought = overbought;
        m_rsiOversold = oversold;
    }
    
    void SetMACDParameters(int fast, int slow, int signal) {
        m_macdFast = fast;
        m_macdSlow = slow;
        m_macdSignal = signal;
    }
    
    void SetStochasticParameters(int k, int d, int slowing, double overbought, double oversold) {
        m_stochK = k;
        m_stochD = d;
        m_stochSlowing = slowing;
        m_stochOverbought = overbought;
        m_stochOversold = oversold;
    }
    
    void SetADXParameters(int period, double threshold) {
        m_adxPeriod = period;
        m_adxThreshold = threshold;
    }
    
    void SetConfirmationFlags(bool rsi, bool macd, bool stoch, bool atr, bool adx, bool cci, bool volume, bool candles) {
        m_useRSI = rsi;
        m_useMACD = macd;
        m_useStochastic = stoch;
        m_useATR = atr;
        m_useADX = adx;
        m_useCCI = cci;
        m_useVolumeConfirmation = volume;
        m_useCandlePatterns = candles;
    }
};

//+------------------------------------------------------------------+
//| Signal Confirmation Utility Functions                           |
//+------------------------------------------------------------------+

// Quick signal strength assessment
double GetSignalStrength(ENUM_SIGNAL_DIRECTION direction, string symbol, ENUM_TIMEFRAMES timeframe) {
    CSignalConfirmation confirmation;
    
    if(!confirmation.Initialize(symbol, timeframe)) {
        return 0.0;
    }
    
    double confidence = 0.0;
    bool confirmed = false;
    
    if(direction == SIGNAL_BUY) {
        confirmed = confirmation.ConfirmBuySignal(confidence);
    } else if(direction == SIGNAL_SELL) {
        confirmed = confirmation.ConfirmSellSignal(confidence);
    }
    
    return confirmed ? confidence : 0.0;
}

//+------------------------------------------------------------------+

