//+------------------------------------------------------------------+
//|                                                  ITradeEngine.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef ITRADEENGINE_MQH_
#define ITRADEENGINE_MQH_

#include "../../00_Core/CommonStructs.mqh"
#include "../PositionManagement/PositionManager.mqh"



//+------------------------------------------------------------------+
//| Trade Engine Interface                                           |
//+------------------------------------------------------------------+
interface ITradeEngine
{
    // Core Initialization
    bool Initialize(EAContext* context);
    void Deinitialize();
    bool IsInitialized();
    
    // Trade Execution
    bool OpenPosition(ENUM_ORDER_TYPE order_type, double volume, double sl_price, double tp_price, const string comment = "");
    SExecutionResult OpenPositionAdvanced(const STradeRequest &request);
    bool ClosePosition(long ticket, const string reason, double volume_to_close = 0.0);
    bool CloseAllPositions(const string reason);
    bool ModifyPosition(long ticket, double new_sl_price, double new_tp_price);
    
    // Position Management
    int GetOpenPositionsCount(ENUM_ORDER_TYPE order_type = WRONG_VALUE);
    double GetTotalExposure();
    double GetTotalUnrealizedPnL();
    bool IsPositionOpen(long ticket);
    
    // Risk Management
    bool ValidateTradeRequest(ENUM_ORDER_TYPE order_type, double volume);
    bool CanOpenNewPosition(double risk_amount, double volume);
    double CalculateOptimalLotSize(double risk_percent, double sl_pips);
    bool CheckRiskLimits(double volume);
    
    // Execution Quality
    STradeExecutionMetrics GetExecutionMetrics();
    double GetExecutionQualityScore();
    bool IsExecutionQualityAcceptable();
    
    // Market Analysis
    double GetCurrentSpread();
    bool IsMarketLiquid();
    bool IsVolatilityHigh();
    
    // Event Handling
    void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);
    void OnPositionOpened(long ticket);
    void OnPositionClosed(long ticket);
    void OnPositionModified(long ticket);
};

//+------------------------------------------------------------------+
//| Trade Event Handler Interface                                    |
//+------------------------------------------------------------------+
interface ITradeEventHandler
{
    void OnTradeExecuted(long ticket, bool success, double slippage, double latency);
    void OnPositionOpened(long ticket, ENUM_ORDER_TYPE type, double volume, double price);
    void OnPositionClosed(long ticket, double profit, const string reason);
    void OnPositionModified(long ticket, double new_sl, double new_tp);
    void OnExecutionQualityAlert(ENUM_EXECUTION_QUALITY_ALERT alert_type, const string message);
    void OnRiskLimitExceeded(ENUM_RISK_LIMIT_TYPE limit_type, double current_value, double limit_value);
};

//+------------------------------------------------------------------+
//| Portfolio Manager Interface                                      |
//+------------------------------------------------------------------+
interface IPortfolioManager
{
    // Core Management
    bool Initialize(EAContext* context);
    void Update();
    
    // Position Tracking
    bool AddPosition(long ticket, const string strategy_id, const string pattern_id, double confidence = 0.0);
    bool RemovePosition(long ticket);
    SPositionInfo* GetPosition(long ticket);
    bool IsPositionTracked(long ticket);
    
    // Portfolio Analytics
    SPortfolioMetrics GetPortfolioMetrics();
    double GetPortfolioVaR(double confidence_level = 0.95);
    double GetPortfolioSharpeRatio();
    bool IsPortfolioBalanced();
    
    // Risk Assessment
    bool CanOpenNewPosition(double risk_amount, double volume);
    double GetAvailableRiskBudget();
    double GetPortfolioRiskScore();
    
    // Reporting
    string GeneratePortfolioReport();
    string GenerateRiskReport();
};

//+------------------------------------------------------------------+
//| Execution Quality Alert Types                                   |
//+------------------------------------------------------------------+
enum ENUM_EXECUTION_QUALITY_ALERT
{
    EXEC_ALERT_HIGH_SLIPPAGE,
    EXEC_ALERT_HIGH_LATENCY,
    EXEC_ALERT_POOR_FILL_RATE,
    EXEC_ALERT_EXECUTION_FAILURE,
    EXEC_ALERT_QUALITY_DEGRADED,
    EXEC_ALERT_BROKER_ISSUES
};

//+------------------------------------------------------------------+
//| Trade Configuration Interface                                    |
//+------------------------------------------------------------------+
interface ITradeConfiguration
{
    // Basic Settings
    void SetMagicNumber(long magic);
    void SetSymbol(const string symbol);
    void SetSlippage(int slippage_points);
    void SetMaxSpread(int max_spread_points);
    
    // Risk Management
    void SetMaxLotSize(double max_lots);
    void SetMaxPositions(int max_positions);
    void SetMaxTotalRisk(double max_risk_percent);
    void SetMaxSingleRisk(double max_single_risk_percent);
    
    // Execution Quality
    void SetSlippageTolerance(double tolerance_points);
    void SetMaxRetries(int max_retries);
    void SetExecutionTimeout(double timeout_seconds);
    void SetAllowPartialFills(bool allow);
    
    // Market Conditions
    void SetTradingHours(int start_hour, int end_hour);
    void SetNewsFilter(bool enable, int minutes_before, int minutes_after);
    void SetVolatilityFilter(bool enable, double max_atr_multiple);
    
    // Portfolio Settings
    void SetMaxExposure(double max_exposure_percent);
    void SetCorrelationLimit(double max_correlation);
    void SetRebalanceFrequency(int minutes);
    
    // Getters
    long GetMagicNumber();
    string GetSymbol();
    int GetSlippage();
    // ... other getters
};

//+------------------------------------------------------------------+
//| Trade Analytics Interface                                        |
//+------------------------------------------------------------------+
interface ITradeAnalytics
{
    // Execution Analysis
    double CalculateAverageSlippage(int lookback_trades = 100);
    double CalculateAverageLatency(int lookback_trades = 100);
    double CalculateExecutionSuccessRate(int lookback_trades = 100);
    
    // Performance Analysis
    double CalculateWinRate(int lookback_trades = 100);
    double CalculateProfitFactor(int lookback_trades = 100);
    double CalculateMaxDrawdown(int lookback_days = 30);
    double CalculateSharpeRatio(int lookback_days = 30);
    
    // Risk Analysis
    double CalculateVaR(double confidence_level = 0.95, int lookback_days = 30);
    double CalculateExpectedShortfall(double confidence_level = 0.95, int lookback_days = 30);
    double CalculateMaximumDrawdownProbability(int lookback_days = 30);
    
    // Market Impact Analysis
    double CalculateMarketImpact(double volume);
    double EstimateOptimalExecutionTime(double volume);
    double CalculateLiquidityScore();
    
    // Correlation Analysis
    double CalculatePortfolioCorrelation();
    double CalculateMarketBeta();
    double CalculateVolatilityRatio();
};

//+------------------------------------------------------------------+
//| Trade Monitoring Interface                                       |
//+------------------------------------------------------------------+
interface ITradeMonitor
{
    // Real-time Monitoring
    void StartMonitoring();
    void StopMonitoring();
    bool IsMonitoring();
    
    // Alert Management
    void EnableAlert(ENUM_EXECUTION_QUALITY_ALERT alert_type, bool enabled);
    void SetAlertThreshold(ENUM_EXECUTION_QUALITY_ALERT alert_type, double threshold);
    void CheckAlerts();
    
    // Performance Monitoring
    void MonitorExecutionQuality();
    void MonitorRiskLimits();
    void MonitorPortfolioHealth();
    void MonitorMarketConditions();
    
    // Reporting
    void GenerateExecutionReport();
    void GenerateRiskReport();
    void GeneratePerformanceReport();
    void ExportTradeData(const string filename);
};

//+------------------------------------------------------------------+
//| Liquidity Provider Interface                                     |
//+------------------------------------------------------------------+
interface ILiquidityProvider
{
    // Liquidity Assessment
    double GetCurrentLiquidity();
    double GetExpectedSlippage(double volume);
    bool IsLiquidityAdequate(double volume);
    
    // Market Depth Analysis
    double GetBidDepth(int levels = 5);
    double GetAskDepth(int levels = 5);
    double GetSpreadDepth();
    
    // Timing Optimization
    bool IsOptimalExecutionTime();
    int GetRecommendedDelay(double volume);
    double GetMarketImpactScore(double volume);
};

//+------------------------------------------------------------------+
//| Order Management Interface                                       |
//+------------------------------------------------------------------+
interface IOrderManager
{
    // Order Lifecycle
    bool PlaceOrder(const STradeRequest &request);
    bool ModifyOrder(long ticket, double price, double sl, double tp);
    bool CancelOrder(long ticket);
    
    // Order Tracking
    bool IsOrderPending(long ticket);
    double GetOrderFillPrice(long ticket);
    double GetOrderSlippage(long ticket);
    
    // Advanced Orders
    bool PlaceStopOrder(ENUM_ORDER_TYPE type, double volume, double price, double sl, double tp);
    bool PlaceLimitOrder(ENUM_ORDER_TYPE type, double volume, double price, double sl, double tp);
    bool PlaceTrailingStop(long position_ticket, double trail_distance);
    
    // Order Analysis
    int GetPendingOrdersCount();
    double GetTotalPendingVolume();
    string GetOrderStatus(long ticket);
};

//+------------------------------------------------------------------+
//| Trailing Stop Interface                                          |
//+------------------------------------------------------------------+
interface ITrailingStopManager
{
    // Trailing Configuration
    bool EnableTrailing(long position_ticket, double trail_distance, double min_profit = 0.0);
    bool DisableTrailing(long position_ticket);
    bool IsTrailingEnabled(long position_ticket);
    
    // Trailing Logic
    void UpdateTrailingStops();
    bool UpdatePositionTrailingStop(long position_ticket);
    
    // Advanced Trailing
    bool SetBreakevenStop(long position_ticket, double min_profit);
    bool SetStepTrailing(long position_ticket, double step_size, double trail_distance);
    bool SetATRTrailing(long position_ticket, double atr_multiple);
};



#endif // ITRADEENGINE_MQH_