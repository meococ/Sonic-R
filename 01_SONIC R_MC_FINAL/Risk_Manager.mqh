//+------------------------------------------------------------------+
//|                   Risk_Manager.mqh - MVP STUB                    |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef APEX_RISKMANAGER_MQH_
#define APEX_RISKMANAGER_MQH_

#include "Core_Defines.mqh"
#include "Core_Context.mqh"

// Namespace has been removed.

//+------------------------------------------------------------------+
//| CRiskManager - ACTIVE Implementation with Real Risk Calculation  |
//+------------------------------------------------------------------+
class CRiskManager {
private:
    bool                    m_initialized;
    CEaContext*             m_pContext; // Pointer to the global EA context
    
    // Risk calculation parameters
    double                 m_minLotSize;
    double                 m_maxLotSize;
    double                 m_lotStep;
    double                 m_marginRequired;
    
    // Volatility-based position sizing
    double                 m_normalATR;
    double                 m_currentATR;
    double                 m_volatilityMultiplier;
    
    // Circuit breaker parameters
    int                    m_consecutiveLosses;
    double                 m_currentDrawdown;
    double                 m_maxDrawdownPercent;
    datetime               m_lastTradeTime;
    bool                   m_circuitBreakerActive;
    
    // Private methods for advanced risk management
    double CalculateVolatilityAdjustedSize(double baseLotSize);
    bool CheckCircuitBreaker();
    void UpdateDrawdownTracking();
    bool IsWithinDailyLimits();
    double GetVolatilityMultiplier();
    double CalculateNormalATR();
    
public:
    CRiskManager() : m_initialized(false), m_pContext(NULL),
                    m_minLotSize(0.01), m_maxLotSize(100.0), m_lotStep(0.01), m_marginRequired(0.0),
                    m_normalATR(0.0), m_currentATR(0.0), m_volatilityMultiplier(1.0),
                    m_consecutiveLosses(0), m_currentDrawdown(0.0), m_maxDrawdownPercent(MAX_DRAWDOWN_PERCENT),
                    m_lastTradeTime(0), m_circuitBreakerActive(false) {}
    
    ~
    CRiskManager() 
    {
        if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("CRiskManager deinitialized", __FUNCTION__);
    }
    
    bool Initialize(CEaContext* pContext)
    {
        m_pContext = pContext;
        if(!m_pContext || !m_pContext->pLogger || !m_pContext->pErrorHandler || !m_pContext->pSettings || !m_pContext->pSymbol || !m_pContext->pCircuitBreaker) {
             // Cannot proceed if context or its core components are invalid
            return false;
        }
        
        // Get symbol specifications
        m_minLotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        m_maxLotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        m_lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        
        if(m_minLotSize <= 0) m_minLotSize = 0.01;
        if(m_maxLotSize <= 0) m_maxLotSize = 100.0;
        if(m_lotStep <= 0) m_lotStep = 0.01;
        
        // Initialize volatility parameters
        m_currentATR = iATR(_Symbol, PERIOD_CURRENT, 14, 0);
        m_normalATR = CalculateNormalATR(); // Calculate 30-day average ATR
        m_volatilityMultiplier = GetVolatilityMultiplier();
        
        // Initialize circuit breaker
        m_maxDrawdownPercent = MAX_DRAWDOWN_PERCENT;
        UpdateDrawdownTracking();
        
        m_initialized = true;
        if(m_pContext->pLogger) m_pContext->pLogger->LogInfo(StringFormat("CRiskManager initialized - MinLot: %.2f, MaxLot: %.2f, Step: %.2f, ATR: %.5f, Vol Mult: %.2f",
                          m_minLotSize, m_maxLotSize, m_lotStep, m_currentATR, m_volatilityMultiplier), __FUNCTION__);
        return true;
    }
    
    void Deinitialize()
    {
        m_initialized = false;
    }
    
    // ACTIVE: Real risk calculation based on signal info and account equity
    bool CalculateTradeRisk(const SSignalInfo& signalInfo, SRiskInfo& riskInfo)
    {
        if(!m_initialized) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("CRiskManager not initialized", __FUNCTION__);
            return false;
        }

        // Validate signal info
        if(signalInfo.EntryPrice <= 0 || signalInfo.StopLoss <= 0)
        {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Invalid signal info provided to CalculateTradeRisk.", __FUNCTION__);
            return false;
        }
        
        // Get account information
        double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double accountFreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        
        if(accountEquity <= 0) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Invalid account equity", __FUNCTION__);
            return false;
        }
        
        // Calculate risk amount based on percentage
        double riskPercent = InpRiskPercent;
        double maxRiskAmount = accountEquity * (riskPercent / 100.0);
        
        // --- DYNAMIC SL CALCULATION ---
        // Calculate SL distance in points based on the signal's dynamic SL
        double slDistance = MathAbs(signalInfo.EntryPrice - signalInfo.StopLoss);

        if(slDistance <= 0)
        {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Stop Loss distance is zero or negative.", __FUNCTION__);
            return false;
        }
        
        // Calculate lot size based on risk
        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        
        if(tickValue <= 0 || tickSize <= 0) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Invalid symbol tick specifications", __FUNCTION__);
            return false;
        }
        
        // Calculate base lot size: Risk Amount / (SL Distance in points * Tick Value)
        double slDistanceInPoints = slDistance / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
        double baseLotSize = maxRiskAmount / (slDistanceInPoints * tickValue);
        
        // Apply volatility-based adjustment
        double calculatedLotSize = CalculateVolatilityAdjustedSize(baseLotSize);
        
        // Check circuit breaker before proceeding
        if(!CheckCircuitBreaker()) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogWarning("Circuit breaker active - reducing position size by 50%", __FUNCTION__);
            calculatedLotSize *= 0.5;
        }
        
        // Normalize lot size to symbol specifications
        calculatedLotSize = NormalizeLotSize(calculatedLotSize);
        
        // Check margin requirements
        double marginRequired = 0;
        if(!OrderCalcMargin((signalInfo.Type == SIGNAL_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL), 
                             _Symbol, calculatedLotSize, signalInfo.EntryPrice, marginRequired)) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Failed to calculate margin requirements", __FUNCTION__);
            return false;
        }
        
        // Check if we have enough free margin
        bool isTradeAllowed = (marginRequired <= accountFreeMargin * 0.8); // Use 80% of free margin
        
        if(!isTradeAllowed) {
            calculatedLotSize = CalculateMaxAffordableLotSize(signalInfo.EntryPrice, accountFreeMargin);
            isTradeAllowed = (calculatedLotSize >= m_minLotSize);
        }
        
        // Fill risk info structure
        riskInfo.LotSize = calculatedLotSize;
        riskInfo.RiskPercent = riskPercent;
        riskInfo.MaxLoss = maxRiskAmount;
        riskInfo.RiskReward = (signalInfo.TakeProfit > 0 && slDistance > 0) ? MathAbs(signalInfo.TakeProfit - signalInfo.EntryPrice) / slDistance : 0.0;
        riskInfo.IsValid = isTradeAllowed;
        
        // Log the calculation
        if(m_pContext && m_pContext->pLogger) {
            m_pContext->pLogger->LogInfo(StringFormat("Risk Calculated - Equity: $%.2f, Risk: %.1f%%, SL Distance: %.5f, Lot: %.2f, R:R: %.2f, Allowed: %s",
                              accountEquity, riskPercent, slDistance, calculatedLotSize, riskInfo.RiskReward,
                              isTradeAllowed ? "YES" : "NO"));
        }
        
        return true;
    }
    
    // Normalize lot size according to symbol specifications
    double NormalizeLotSize(double lotSize)
    {
        if(lotSize < m_minLotSize) return m_minLotSize;
        if(lotSize > m_maxLotSize) return m_maxLotSize;
        
        // Round to nearest step
        double normalizedLot = MathRound(lotSize / m_lotStep) * m_lotStep;
        
        // Ensure it's within bounds
        if(normalizedLot < m_minLotSize) normalizedLot = m_minLotSize;
        if(normalizedLot > m_maxLotSize) normalizedLot = m_maxLotSize;
        
        return normalizedLot;
    }
    
    // Calculate maximum affordable lot size based on available margin
    double CalculateMaxAffordableLotSize(double price, double availableMargin)
    {
        double maxLot = m_minLotSize;
        double marginRequired = 0;
        
        for(double testLot = m_minLotSize; testLot <= m_maxLotSize; testLot += m_lotStep) {
            if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, testLot, price, marginRequired)) {
                if(marginRequired <= availableMargin * 0.8) {
                    maxLot = testLot;
                } else {
                    break;
                }
            }
        }
        
        return maxLot;
    }
    
    // MVP: Basic risk validation stubs
    bool ValidateAccountSettings()
    {
        if(m_pLogger) LOG_INFO("Account validation passed");
        return true;
    }
    
    bool CanOpenNewPosition()
    {
        if(!m_initialized) return false;
        
        // Check circuit breaker
        if(!CheckCircuitBreaker()) {
            if(m_pLogger) LOG_WARNING("New position blocked by circuit breaker");
            return false;
        }
        
        // Check daily limits
        if(!IsWithinDailyLimits()) {
            if(m_pLogger) LOG_WARNING("Daily trading limits reached");
            return false;
        }
        
        return true;
    }
    
    bool ValidateTradeRequest(const STradeRequest& request)
    {
        if(!m_initialized) return false;
        
        // Enhanced validation with circuit breaker
        if(!CheckCircuitBreaker()) {
            if(m_pLogger) LOG_WARNING("Trade request rejected by circuit breaker");
            return false;
        }
        
        if(m_pLogger) LOG_INFO("Trade request validation passed");
        return true;
    }
    
    // Enhanced event handlers
    void OnTimer() 
    { 
        if(m_initialized) {
            UpdateDrawdownTracking();
            m_currentATR = iATR(_Symbol, PERIOD_CURRENT, 14, 0);
            m_volatilityMultiplier = GetVolatilityMultiplier();
        }
    }
    
    void OnTrade() 
    { 
        if(m_initialized) {
            UpdateDrawdownTracking();
            m_lastTradeTime = TimeCurrent();
        }
    }
    
    // New methods for advanced risk management
    void ResetCircuitBreaker() 
    {
        m_circuitBreakerActive = false;
        m_consecutiveLosses = 0;
        if(m_pLogger) LOG_INFO("Circuit breaker reset");
    }
    
    double GetCurrentVolatilityMultiplier() const { return m_volatilityMultiplier; }
    bool IsCircuitBreakerActive() const { return m_circuitBreakerActive; }
    double GetCurrentDrawdown() const { return m_currentDrawdown; }
    
    // Getters
    bool IsInitialized() const { return m_initialized; }
    double GetMinLotSize() const { return m_minLotSize; }
    double GetMaxLotSize() const { return m_maxLotSize; }
    double GetLotStep() const { return m_lotStep; }
};

//+------------------------------------------------------------------+
//| Private Methods Implementation - Advanced Risk Management        |
//+------------------------------------------------------------------+

// Calculate volatility-adjusted position size
double CRiskManager::CalculateVolatilityAdjustedSize(double baseLotSize)
{
    if(m_normalATR <= 0 || m_currentATR <= 0) return baseLotSize;
    
    // Calculate volatility ratio
    double volatilityRatio = m_currentATR / m_normalATR;
    
    // Adjust position size inversely to volatility
    // Higher volatility = smaller position, Lower volatility = larger position
    double adjustedSize = baseLotSize / volatilityRatio;
    
    // Apply limits (don't go below 50% or above 150% of base size)
    adjustedSize = MathMax(adjustedSize, baseLotSize * 0.5);
    adjustedSize = MathMin(adjustedSize, baseLotSize * 1.5);
    
    if(m_pLogger) {
        LOG_DEBUG(StringFormat("Volatility adjustment: Base=%.2f, ATR Ratio=%.2f, Adjusted=%.2f", 
                  baseLotSize, volatilityRatio, adjustedSize));
    }
    
    return adjustedSize;
}

// Check circuit breaker conditions
bool CRiskManager::CheckCircuitBreaker()
{
    // Check consecutive losses
    if(m_consecutiveLosses >= MAX_CONSECUTIVE_LOSSES) {
        m_circuitBreakerActive = true;
        if(m_pLogger) {
            LOG_WARNING(StringFormat("Circuit breaker: %d consecutive losses (Max: %d)", 
                        m_consecutiveLosses, MAX_CONSECUTIVE_LOSSES));
        }
        return false;
    }
    
    // Check drawdown
    if(m_currentDrawdown >= m_maxDrawdownPercent) {
        m_circuitBreakerActive = true;
        if(m_pLogger) {
            LOG_WARNING(StringFormat("Circuit breaker: %.2f%% drawdown (Max: %.2f%%)", 
                        m_currentDrawdown, m_maxDrawdownPercent));
        }
        return false;
    }
    
    return true;
}

// Update drawdown tracking
void CRiskManager::UpdateDrawdownTracking()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    if(accountBalance > 0) {
        m_currentDrawdown = ((accountBalance - currentEquity) / accountBalance) * 100.0;
        
        // Reset consecutive losses if equity is recovering
        if(m_currentDrawdown < (m_maxDrawdownPercent * 0.5)) {
            if(m_consecutiveLosses > 0) {
                m_consecutiveLosses = MathMax(0, m_consecutiveLosses - 1);
            }
            m_circuitBreakerActive = false;
        }
    }
}

// Check daily trading limits
bool CRiskManager::IsWithinDailyLimits()
{
    // Simple implementation: allow trading if last trade was more than 1 hour ago
    // In full version, this would track daily trade count and volume
    datetime currentTime = TimeCurrent();
    return (currentTime - m_lastTradeTime) > 3600; // 1 hour
}

// Calculate volatility multiplier
double CRiskManager::GetVolatilityMultiplier()
{
    if(m_normalATR <= 0 || m_currentATR <= 0) return 1.0;
    
    double ratio = m_currentATR / m_normalATR;
    
    // Return inverse ratio (high volatility = low multiplier)
    return 1.0 / ratio;
}

// Calculate normal ATR (30-day average)
double CRiskManager::CalculateNormalATR()
{
    double totalATR = 0;
    int validBars = 0;
    
    // Calculate average ATR over 30 days (assuming H1 timeframe)
    for(int i = 0; i < 720; i++) { // 30 days * 24 hours
        double atr = iATR(_Symbol, PERIOD_H1, 14, i);
        if(atr > 0) {
            totalATR += atr;
            validBars++;
        }
    }
    
    return (validBars > 0) ? (totalATR / validBars) : iATR(_Symbol, PERIOD_CURRENT, 14, 0);
}

// End of namespace removal

#endif
