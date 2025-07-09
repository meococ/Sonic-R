//+------------------------------------------------------------------+
//|                                            PortfolioManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Portfolio management enumerations                               |
//+------------------------------------------------------------------+
enum ENUM_PORTFOLIO_STATUS {
    PORTFOLIO_STATUS_ACTIVE,
    PORTFOLIO_STATUS_INACTIVE,
    PORTFOLIO_STATUS_SUSPENDED,
    PORTFOLIO_STATUS_LIQUIDATING,
    PORTFOLIO_STATUS_CLOSED
};

enum ENUM_POSITION_TYPE {
    POSITION_TYPE_LONG,
    POSITION_TYPE_SHORT,
    POSITION_TYPE_NEUTRAL
};

enum ENUM_RISK_LEVEL {
    RISK_LEVEL_CONSERVATIVE,
    RISK_LEVEL_MODERATE,
    RISK_LEVEL_AGGRESSIVE,
    RISK_LEVEL_SPECULATIVE
};

enum ENUM_ALLOCATION_METHOD {
    ALLOCATION_EQUAL_WEIGHT,
    ALLOCATION_RISK_PARITY,
    ALLOCATION_MARKET_CAP,
    ALLOCATION_VOLATILITY_TARGET,
    ALLOCATION_CUSTOM
};

enum ENUM_REBALANCE_TRIGGER {
    REBALANCE_TIME_BASED,
    REBALANCE_THRESHOLD_BASED,
    REBALANCE_VOLATILITY_BASED,
    REBALANCE_PERFORMANCE_BASED,
    REBALANCE_MANUAL
};

enum ENUM_CORRELATION_LEVEL {
    CORRELATION_VERY_LOW,     // < 0.2
    CORRELATION_LOW,          // 0.2 - 0.4
    CORRELATION_MODERATE,     // 0.4 - 0.6
    CORRELATION_HIGH,         // 0.6 - 0.8
    CORRELATION_VERY_HIGH     // > 0.8
};

//+------------------------------------------------------------------+
//| Portfolio management structures                                 |
//+------------------------------------------------------------------+
struct SPortfolioAsset {
    string Symbol;
    double TargetWeight;        // Target allocation percentage (0-100)
    double CurrentWeight;       // Current allocation percentage
    double CurrentValue;        // Current market value
    double AveragePrice;        // Average entry price
    double UnrealizedPnL;       // Unrealized profit/loss
    double RealizedPnL;         // Realized profit/loss
    double Volume;              // Total volume/lots
    ENUM_POSITION_TYPE PositionType;
    datetime LastUpdate;
    bool IsActive;
    double Beta;                // Beta coefficient
    double Volatility;          // Historical volatility
    double Sharpe;              // Sharpe ratio
    double MaxDrawdown;         // Maximum drawdown
};

struct SPortfolioMetrics {
    double TotalValue;          // Total portfolio value
    double TotalPnL;            // Total profit/loss
    double UnrealizedPnL;       // Total unrealized PnL
    double RealizedPnL;         // Total realized PnL
    double DailyReturn;         // Daily return percentage
    double WeeklyReturn;        // Weekly return percentage
    double MonthlyReturn;       // Monthly return percentage
    double YearlyReturn;        // Yearly return percentage
    double Volatility;          // Portfolio volatility
    double SharpeRatio;         // Sharpe ratio
    double SortinoRatio;        // Sortino ratio
    double MaxDrawdown;         // Maximum drawdown
    double CurrentDrawdown;     // Current drawdown
    double Beta;                // Portfolio beta
    double Alpha;               // Portfolio alpha
    double VaR95;               // Value at Risk (95%)
    double VaR99;               // Value at Risk (99%)
    double CVaR95;              // Conditional VaR (95%)
    datetime LastUpdate;
};

struct SCorrelationMatrix {
    string Symbols[20];
    int SymbolCount;
    double Matrix[20][20];      // Correlation coefficients
    datetime LastUpdate;
    double AverageCorrelation;
    double MaxCorrelation;
    double MinCorrelation;
};

struct SRiskBudget {
    double TotalRiskBudget;     // Total risk budget (percentage)
    double UsedRiskBudget;      // Currently used risk budget
    double AvailableRiskBudget; // Available risk budget
    double RiskPerAsset[20];    // Risk allocation per asset
    double MaxRiskPerAsset;     // Maximum risk per single asset
    double ConcentrationLimit;  // Maximum concentration in single asset
    bool IsWithinLimits;
    datetime LastUpdate;
};

struct SRebalanceConfig {
    ENUM_REBALANCE_TRIGGER TriggerType;
    int RebalanceInterval;      // Hours for time-based
    double ThresholdPercent;    // Threshold for threshold-based
    double VolatilityThreshold; // Volatility threshold
    double PerformanceThreshold; // Performance threshold
    bool AutoRebalance;
    datetime LastRebalance;
    datetime NextRebalance;
    bool IsRebalanceNeeded;
};

struct SPortfolioConstraints {
    double MaxPositionSize;     // Maximum position size (percentage)
    double MaxSectorExposure;   // Maximum sector exposure
    double MaxCorrelation;      // Maximum allowed correlation
    double MinDiversification;  // Minimum diversification ratio
    double MaxLeverage;         // Maximum leverage
    double MaxDrawdownLimit;    // Maximum allowed drawdown
    double MinLiquidity;        // Minimum liquidity requirement
    int MaxPositions;           // Maximum number of positions
    bool EnforceConstraints;
};

struct SPortfolioConfiguration {
    string Name;
    string Description;
    ENUM_RISK_LEVEL RiskLevel;
    ENUM_ALLOCATION_METHOD AllocationMethod;
    SRebalanceConfig RebalanceConfig;
    SPortfolioConstraints Constraints;
    SRiskBudget RiskBudget;
    double TargetVolatility;    // Target portfolio volatility
    double TargetReturn;        // Target return
    bool EnableRiskManagement;
    bool EnableRebalancing;
    bool EnableCorrelationControl;
    datetime CreationTime;
    datetime LastModified;
};

struct SPortfolioStatistics {
    int TotalTrades;
    int WinningTrades;
    int LosingTrades;
    double WinRate;
    double AverageWin;
    double AverageLoss;
    double ProfitFactor;
    double RecoveryFactor;
    double CalmarRatio;
    double SterlingRatio;
    double InformationRatio;
    double TrackingError;
    int ConsecutiveWins;
    int ConsecutiveLosses;
    int MaxConsecutiveWins;
    int MaxConsecutiveLosses;
    datetime FirstTrade;
    datetime LastTrade;
    double TotalCommissions;
    double TotalSwaps;
};

//+------------------------------------------------------------------+
//| Portfolio Manager Class                                         |
//+------------------------------------------------------------------+
class CPortfolioManager {
private:
    EAContext* m_pContext;
    
    // Portfolio data
    SPortfolioAsset m_Assets[50];
    int m_AssetCount;
    
    // Portfolio metrics and statistics
    SPortfolioMetrics m_Metrics;
    SPortfolioStatistics m_Statistics;
    SCorrelationMatrix m_CorrelationMatrix;
    
    // Configuration
    SPortfolioConfiguration m_Config;
    
    // Internal state
    bool m_bInitialized;
    ENUM_PORTFOLIO_STATUS m_Status;
    datetime m_LastUpdate;
    datetime m_LastRebalance;
    
    // Historical data for calculations
    double m_HistoricalReturns[100][50];  // 100 periods, 50 assets max
    int m_HistoryDepth;
    
    // Helper methods
    bool UpdateAssetMetrics();
    bool CalculatePortfolioMetrics();
    bool UpdateCorrelationMatrix();
    bool CheckConstraints();
    bool CalculateRiskMetrics();
    bool UpdateStatistics();
    double CalculateAssetWeight(int assetIndex);
    double CalculatePortfolioVolatility();
    double CalculatePortfolioBeta();
    double CalculateSharpeRatio();
    double CalculateVaR(double confidence);
    double CalculateCorrelation(int asset1, int asset2);
    bool IsRebalanceNeeded();
    bool PerformRebalance();
    bool OptimizeAllocation();
    void LogError(const string message);
    void LogActivity(const string message);
    
public:
    // Constructor/Destructor
    CPortfolioManager();
    ~CPortfolioManager();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const SPortfolioConfiguration& config);
    
    // Portfolio management
    bool AddAsset(const string symbol, double targetWeight);
    bool RemoveAsset(const string symbol);
    bool UpdateAssetWeight(const string symbol, double newWeight);
    bool SetAssetTargetWeight(const string symbol, double targetWeight);
    
    // Position management
    bool OpenPosition(const string symbol, double volume, ENUM_POSITION_TYPE type);
    bool ClosePosition(const string symbol, double volume = 0.0);
    bool ModifyPosition(const string symbol, double newVolume);
    
    // Portfolio operations
    bool UpdatePortfolio();
    bool RebalancePortfolio();
    bool LiquidatePortfolio();
    bool SuspendPortfolio();
    bool ActivatePortfolio();
    
    // Risk management
    bool CheckRiskLimits();
    bool ApplyRiskControls();
    bool UpdateRiskBudget();
    bool CalculateRiskContribution(const string symbol, double& riskContrib);
    
    // Analysis and metrics
    bool GetPortfolioMetrics(SPortfolioMetrics& metrics);
    bool GetAssetMetrics(const string symbol, SPortfolioAsset& asset);
    bool GetCorrelationMatrix(SCorrelationMatrix& matrix);
    bool GetRiskBudget(SRiskBudget& budget);
    
    // Optimization
    bool OptimizeWeights(ENUM_ALLOCATION_METHOD method);
    bool MinimizeRisk();
    bool MaximizeReturn();
    bool TargetVolatility(double targetVol);
    
    // Rebalancing
    bool SetRebalanceConfig(const SRebalanceConfig& config);
    bool TriggerRebalance();
    bool GetRebalanceRecommendations(string& recommendations[]);
    
    // Constraints
    bool SetConstraints(const SPortfolioConstraints& constraints);
    bool ValidateConstraints();
    bool EnforceConstraints();
    
    // Reporting
    bool GeneratePerformanceReport(string& report);
    bool GenerateRiskReport(string& report);
    bool GenerateAllocationReport(string& report);
    bool ExportPortfolioData(const string filename);
    
    // Getters
    SPortfolioConfiguration GetConfiguration() const { return m_Config; }
    SPortfolioMetrics GetMetrics() const { return m_Metrics; }
    SPortfolioStatistics GetStatistics() const { return m_Statistics; }
    ENUM_PORTFOLIO_STATUS GetStatus() const { return m_Status; }
    int GetAssetCount() const { return m_AssetCount; }
    double GetTotalValue() const { return m_Metrics.TotalValue; }
    double GetTotalPnL() const { return m_Metrics.TotalPnL; }
    
    // Utility
    string GetStatusName(ENUM_PORTFOLIO_STATUS status);
    string GetRiskLevelName(ENUM_RISK_LEVEL level);
    string GetAllocationMethodName(ENUM_ALLOCATION_METHOD method);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    bool IsActive() const { return m_Status == PORTFOLIO_STATUS_ACTIVE; }
    datetime GetLastUpdate() const { return m_LastUpdate; }
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CPortfolioManager::CPortfolioManager() {
    m_pContext = NULL;
    m_AssetCount = 0;
    m_bInitialized = false;
    m_Status = PORTFOLIO_STATUS_INACTIVE;
    m_LastUpdate = 0;
    m_LastRebalance = 0;
    m_HistoryDepth = 0;
    
    ZeroMemory(m_Metrics);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_CorrelationMatrix);
    ZeroMemory(m_Config);
    
    // Set default configuration
    m_Config.Name = "Default Portfolio";
    m_Config.RiskLevel = RISK_LEVEL_MODERATE;
    m_Config.AllocationMethod = ALLOCATION_EQUAL_WEIGHT;
    m_Config.TargetVolatility = 15.0;  // 15% annual volatility
    m_Config.TargetReturn = 10.0;      // 10% annual return
    m_Config.EnableRiskManagement = true;
    m_Config.EnableRebalancing = true;
    m_Config.EnableCorrelationControl = true;
    
    // Set default constraints
    m_Config.Constraints.MaxPositionSize = 20.0;      // 20% max per position
    m_Config.Constraints.MaxSectorExposure = 30.0;    // 30% max per sector
    m_Config.Constraints.MaxCorrelation = 0.7;        // 70% max correlation
    m_Config.Constraints.MinDiversification = 0.5;    // 50% min diversification
    m_Config.Constraints.MaxLeverage = 2.0;           // 2x max leverage
    m_Config.Constraints.MaxDrawdownLimit = 15.0;     // 15% max drawdown
    m_Config.Constraints.MinLiquidity = 0.8;          // 80% min liquidity
    m_Config.Constraints.MaxPositions = 20;           // 20 max positions
    m_Config.Constraints.EnforceConstraints = true;
    
    // Set default rebalance config
    m_Config.RebalanceConfig.TriggerType = REBALANCE_THRESHOLD_BASED;
    m_Config.RebalanceConfig.RebalanceInterval = 168;  // Weekly
    m_Config.RebalanceConfig.ThresholdPercent = 5.0;   // 5% threshold
    m_Config.RebalanceConfig.AutoRebalance = true;
    
    // Set default risk budget
    m_Config.RiskBudget.TotalRiskBudget = 100.0;
    m_Config.RiskBudget.MaxRiskPerAsset = 25.0;        // 25% max risk per asset
    m_Config.RiskBudget.ConcentrationLimit = 30.0;     // 30% concentration limit
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CPortfolioManager::~CPortfolioManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize portfolio manager                                    |
//+------------------------------------------------------------------+
bool CPortfolioManager::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize correlation matrix
    m_CorrelationMatrix.SymbolCount = 0;
    m_CorrelationMatrix.LastUpdate = 0;
    
    // Initialize statistics
    m_Statistics.FirstTrade = 0;
    m_Statistics.LastTrade = 0;
    
    m_bInitialized = true;
    m_Status = PORTFOLIO_STATUS_ACTIVE;
    m_Config.CreationTime = TimeCurrent();
    
    LogActivity("Portfolio manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize portfolio manager                                  |
//+------------------------------------------------------------------+
bool CPortfolioManager::Deinitialize() {
    if (m_bInitialized) {
        m_bInitialized = false;
        m_Status = PORTFOLIO_STATUS_CLOSED;
        m_pContext = NULL;
        LogActivity("Portfolio manager deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure portfolio manager                                     |
//+------------------------------------------------------------------+
bool CPortfolioManager::Configure(const SPortfolioConfiguration& config) {
    m_Config = config;
    m_Config.LastModified = TimeCurrent();
    
    // Validate configuration
    if (m_Config.TargetVolatility < 1.0) m_Config.TargetVolatility = 1.0;
    if (m_Config.TargetVolatility > 100.0) m_Config.TargetVolatility = 100.0;
    if (m_Config.TargetReturn < -50.0) m_Config.TargetReturn = -50.0;
    if (m_Config.TargetReturn > 200.0) m_Config.TargetReturn = 200.0;
    
    LogActivity("Portfolio manager configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Add asset to portfolio                                          |
//+------------------------------------------------------------------+
bool CPortfolioManager::AddAsset(const string symbol, double targetWeight) {
    if (!m_bInitialized) {
        LogError("Portfolio manager not initialized");
        return false;
    }
    
    if (m_AssetCount >= ArraySize(m_Assets)) {
        LogError("Maximum number of assets reached");
        return false;
    }
    
    // Check if asset already exists
    for (int i = 0; i < m_AssetCount; i++) {
        if (m_Assets[i].Symbol == symbol) {
            LogError("Asset already exists in portfolio: " + symbol);
            return false;
        }
    }
    
    // Validate target weight
    if (targetWeight < 0.0 || targetWeight > 100.0) {
        LogError("Invalid target weight: " + DoubleToString(targetWeight, 2));
        return false;
    }
    
    // Add new asset
    SPortfolioAsset asset;
    ZeroMemory(asset);
    
    asset.Symbol = symbol;
    asset.TargetWeight = targetWeight;
    asset.CurrentWeight = 0.0;
    asset.CurrentValue = 0.0;
    asset.AveragePrice = 0.0;
    asset.UnrealizedPnL = 0.0;
    asset.RealizedPnL = 0.0;
    asset.Volume = 0.0;
    asset.PositionType = POSITION_TYPE_NEUTRAL;
    asset.LastUpdate = TimeCurrent();
    asset.IsActive = true;
    asset.Beta = 1.0;
    asset.Volatility = 0.0;
    asset.Sharpe = 0.0;
    asset.MaxDrawdown = 0.0;
    
    m_Assets[m_AssetCount] = asset;
    m_AssetCount++;
    
    LogActivity("Asset added to portfolio: " + symbol + " (Target: " + DoubleToString(targetWeight, 2) + "%)");
    return true;
}

//+------------------------------------------------------------------+
//| Remove asset from portfolio                                     |
//+------------------------------------------------------------------+
bool CPortfolioManager::RemoveAsset(const string symbol) {
    if (!m_bInitialized) {
        LogError("Portfolio manager not initialized");
        return false;
    }
    
    // Find asset
    int assetIndex = -1;
    for (int i = 0; i < m_AssetCount; i++) {
        if (m_Assets[i].Symbol == symbol) {
            assetIndex = i;
            break;
        }
    }
    
    if (assetIndex == -1) {
        LogError("Asset not found in portfolio: " + symbol);
        return false;
    }
    
    // Close any open positions first
    if (m_Assets[assetIndex].Volume != 0.0) {
        ClosePosition(symbol);
    }
    
    // Remove asset by shifting array
    for (int i = assetIndex; i < m_AssetCount - 1; i++) {
        m_Assets[i] = m_Assets[i + 1];
    }
    
    m_AssetCount--;
    
    LogActivity("Asset removed from portfolio: " + symbol);
    return true;
}

//+------------------------------------------------------------------+
//| Update asset weight                                             |
//+------------------------------------------------------------------+
bool CPortfolioManager::UpdateAssetWeight(const string symbol, double newWeight) {
    if (!m_bInitialized) {
        LogError("Portfolio manager not initialized");
        return false;
    }
    
    // Find asset
    int assetIndex = -1;
    for (int i = 0; i < m_AssetCount; i++) {
        if (m_Assets[i].Symbol == symbol) {
            assetIndex = i;
            break;
        }
    }
    
    if (assetIndex == -1) {
        LogError("Asset not found in portfolio: " + symbol);
        return false;
    }
    
    // Validate new weight
    if (newWeight < 0.0 || newWeight > 100.0) {
        LogError("Invalid weight: " + DoubleToString(newWeight, 2));
        return false;
    }
    
    double oldWeight = m_Assets[assetIndex].TargetWeight;
    m_Assets[assetIndex].TargetWeight = newWeight;
    m_Assets[assetIndex].LastUpdate = TimeCurrent();
    
    LogActivity("Asset weight updated: " + symbol + " (" + DoubleToString(oldWeight, 2) + "% -> " + DoubleToString(newWeight, 2) + "%)");
    return true;
}

//+------------------------------------------------------------------+
//| Update portfolio                                                |
//+------------------------------------------------------------------+
bool CPortfolioManager::UpdatePortfolio() {
    if (!m_bInitialized || m_Status != PORTFOLIO_STATUS_ACTIVE) {
        return false;
    }
    
    // Update asset metrics
    UpdateAssetMetrics();
    
    // Calculate portfolio metrics
    CalculatePortfolioMetrics();
    
    // Update correlation matrix
    UpdateCorrelationMatrix();
    
    // Calculate risk metrics
    CalculateRiskMetrics();
    
    // Check constraints
    if (m_Config.Constraints.EnforceConstraints) {
        CheckConstraints();
    }
    
    // Check if rebalancing is needed
    if (m_Config.EnableRebalancing && IsRebalanceNeeded()) {
        if (m_Config.RebalanceConfig.AutoRebalance) {
            PerformRebalance();
        }
    }
    
    // Update statistics
    UpdateStatistics();
    
    m_LastUpdate = TimeCurrent();
    m_Metrics.LastUpdate = m_LastUpdate;
    
    return true;
}

//+------------------------------------------------------------------+
//| Update asset metrics                                            |
//+------------------------------------------------------------------+
bool CPortfolioManager::UpdateAssetMetrics() {
    double totalValue = 0.0;
    
    for (int i = 0; i < m_AssetCount; i++) {
        if (!m_Assets[i].IsActive) continue;
        
        string symbol = m_Assets[i].Symbol;
        
        // Get current price
        double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
        if (currentPrice <= 0.0) {
            currentPrice = SymbolInfoDouble(symbol, SYMBOL_LAST);
        }
        
        if (currentPrice > 0.0) {
            // Calculate current value
            m_Assets[i].CurrentValue = m_Assets[i].Volume * currentPrice;
            totalValue += m_Assets[i].CurrentValue;
            
            // Calculate unrealized PnL
            if (m_Assets[i].AveragePrice > 0.0) {
                m_Assets[i].UnrealizedPnL = (currentPrice - m_Assets[i].AveragePrice) * m_Assets[i].Volume;
            }
            
            m_Assets[i].LastUpdate = TimeCurrent();
        }
    }
    
    // Calculate current weights
    if (totalValue > 0.0) {
        for (int i = 0; i < m_AssetCount; i++) {
            if (m_Assets[i].IsActive) {
                m_Assets[i].CurrentWeight = (m_Assets[i].CurrentValue / totalValue) * 100.0;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate portfolio metrics                                     |
//+------------------------------------------------------------------+
bool CPortfolioManager::CalculatePortfolioMetrics() {
    // Reset metrics
    m_Metrics.TotalValue = 0.0;
    m_Metrics.UnrealizedPnL = 0.0;
    m_Metrics.RealizedPnL = 0.0;
    
    // Sum up asset values and PnL
    for (int i = 0; i < m_AssetCount; i++) {
        if (m_Assets[i].IsActive) {
            m_Metrics.TotalValue += m_Assets[i].CurrentValue;
            m_Metrics.UnrealizedPnL += m_Assets[i].UnrealizedPnL;
            m_Metrics.RealizedPnL += m_Assets[i].RealizedPnL;
        }
    }
    
    m_Metrics.TotalPnL = m_Metrics.UnrealizedPnL + m_Metrics.RealizedPnL;
    
    // Calculate returns (simplified)
    static double previousValue = 0.0;
    if (previousValue > 0.0 && m_Metrics.TotalValue > 0.0) {
        m_Metrics.DailyReturn = ((m_Metrics.TotalValue - previousValue) / previousValue) * 100.0;
    }
    previousValue = m_Metrics.TotalValue;
    
    // Calculate portfolio volatility
    m_Metrics.Volatility = CalculatePortfolioVolatility();
    
    // Calculate Sharpe ratio
    m_Metrics.SharpeRatio = CalculateSharpeRatio();
    
    // Calculate VaR
    m_Metrics.VaR95 = CalculateVaR(0.95);
    m_Metrics.VaR99 = CalculateVaR(0.99);
    
    // Calculate portfolio beta
    m_Metrics.Beta = CalculatePortfolioBeta();
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate portfolio volatility                                  |
//+------------------------------------------------------------------+
double CPortfolioManager::CalculatePortfolioVolatility() {
    if (m_AssetCount == 0) return 0.0;
    
    double portfolioVariance = 0.0;
    
    // Calculate weighted variance
    for (int i = 0; i < m_AssetCount; i++) {
        if (!m_Assets[i].IsActive) continue;
        
        double weight_i = m_Assets[i].CurrentWeight / 100.0;
        double variance_i = m_Assets[i].Volatility * m_Assets[i].Volatility;
        
        portfolioVariance += weight_i * weight_i * variance_i;
        
        // Add covariance terms
        for (int j = i + 1; j < m_AssetCount; j++) {
            if (!m_Assets[j].IsActive) continue;
            
            double weight_j = m_Assets[j].CurrentWeight / 100.0;
            double correlation = CalculateCorrelation(i, j);
            double covariance = correlation * m_Assets[i].Volatility * m_Assets[j].Volatility;
            
            portfolioVariance += 2.0 * weight_i * weight_j * covariance;
        }
    }
    
    return MathSqrt(portfolioVariance);
}

//+------------------------------------------------------------------+
//| Calculate Sharpe ratio                                          |
//+------------------------------------------------------------------+
double CPortfolioManager::CalculateSharpeRatio() {
    if (m_Metrics.Volatility == 0.0) return 0.0;
    
    double riskFreeRate = 2.0;  // Assume 2% risk-free rate
    double excessReturn = m_Metrics.YearlyReturn - riskFreeRate;
    
    return excessReturn / m_Metrics.Volatility;
}

//+------------------------------------------------------------------+
//| Calculate Value at Risk                                         |
//+------------------------------------------------------------------+
double CPortfolioManager::CalculateVaR(double confidence) {
    if (m_Metrics.TotalValue == 0.0 || m_Metrics.Volatility == 0.0) return 0.0;
    
    // Use normal distribution approximation
    double z_score = (confidence == 0.95) ? 1.645 : 2.326;  // 95% or 99%
    
    double dailyVol = m_Metrics.Volatility / MathSqrt(252.0);  // Annualized to daily
    double var = m_Metrics.TotalValue * z_score * dailyVol;
    
    return var;
}

//+------------------------------------------------------------------+
//| Calculate correlation between two assets                        |
//+------------------------------------------------------------------+
double CPortfolioManager::CalculateCorrelation(int asset1, int asset2) {
    if (asset1 >= m_AssetCount || asset2 >= m_AssetCount || asset1 == asset2) {
        return 0.0;
    }
    
    // Simplified correlation calculation
    // In practice, this would use historical price data
    return 0.3;  // Placeholder value
}

//+------------------------------------------------------------------+
//| Check if rebalancing is needed                                  |
//+------------------------------------------------------------------+
bool CPortfolioManager::IsRebalanceNeeded() {
    if (!m_Config.EnableRebalancing) return false;
    
    datetime currentTime = TimeCurrent();
    
    switch (m_Config.RebalanceConfig.TriggerType) {
        case REBALANCE_TIME_BASED:
            return (currentTime - m_LastRebalance) >= (m_Config.RebalanceConfig.RebalanceInterval * 3600);
            
        case REBALANCE_THRESHOLD_BASED:
            {
                // Check if any asset deviates from target by threshold
                for (int i = 0; i < m_AssetCount; i++) {
                    if (m_Assets[i].IsActive) {
                        double deviation = MathAbs(m_Assets[i].CurrentWeight - m_Assets[i].TargetWeight);
                        if (deviation >= m_Config.RebalanceConfig.ThresholdPercent) {
                            return true;
                        }
                    }
                }
                return false;
            }
            
        case REBALANCE_VOLATILITY_BASED:
            return m_Metrics.Volatility > m_Config.RebalanceConfig.VolatilityThreshold;
            
        case REBALANCE_PERFORMANCE_BASED:
            return MathAbs(m_Metrics.DailyReturn) > m_Config.RebalanceConfig.PerformanceThreshold;
            
        default:
            return false;
    }
}

//+------------------------------------------------------------------+
//| Perform portfolio rebalancing                                   |
//+------------------------------------------------------------------+
bool CPortfolioManager::PerformRebalance() {
    if (!m_bInitialized || m_Status != PORTFOLIO_STATUS_ACTIVE) {
        return false;
    }
    
    LogActivity("Starting portfolio rebalancing");
    
    // Calculate target values based on current total value
    double totalValue = m_Metrics.TotalValue;
    if (totalValue <= 0.0) {
        LogError("Cannot rebalance: total portfolio value is zero");
        return false;
    }
    
    // Calculate required trades
    for (int i = 0; i < m_AssetCount; i++) {
        if (!m_Assets[i].IsActive) continue;
        
        double targetValue = (m_Assets[i].TargetWeight / 100.0) * totalValue;
        double currentValue = m_Assets[i].CurrentValue;
        double difference = targetValue - currentValue;
        
        if (MathAbs(difference) > (totalValue * 0.01)) {  // 1% minimum trade size
            // Calculate required volume change
            double currentPrice = SymbolInfoDouble(m_Assets[i].Symbol, SYMBOL_BID);
            if (currentPrice > 0.0) {
                double volumeChange = difference / currentPrice;
                
                // Execute trade (simplified)
                if (volumeChange > 0) {
                    // Buy more
                    LogActivity("Rebalance: Buy " + DoubleToString(volumeChange, 2) + " of " + m_Assets[i].Symbol);
                } else {
                    // Sell some
                    LogActivity("Rebalance: Sell " + DoubleToString(-volumeChange, 2) + " of " + m_Assets[i].Symbol);
                }
                
                // Update volume (in practice, this would be done after successful trade execution)
                m_Assets[i].Volume += volumeChange;
            }
        }
    }
    
    m_LastRebalance = TimeCurrent();
    m_Config.RebalanceConfig.LastRebalance = m_LastRebalance;
    
    LogActivity("Portfolio rebalancing completed");
    return true;
}

//+------------------------------------------------------------------+
//| Log error message                                               |
//+------------------------------------------------------------------+
void CPortfolioManager::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogError("PortfolioManager: " + message);
    } else {
        Print("PortfolioManager ERROR: ", message);
    }
}

//+------------------------------------------------------------------+
//| Log activity message                                            |
//+------------------------------------------------------------------+
void CPortfolioManager::LogActivity(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("PortfolioManager: " + message);
    } else {
        Print("PortfolioManager: ", message);
    }
}

//+------------------------------------------------------------------+
//| Get status name                                                 |
//+------------------------------------------------------------------+
string CPortfolioManager::GetStatusName(ENUM_PORTFOLIO_STATUS status) {
    switch (status) {
        case PORTFOLIO_STATUS_ACTIVE: return "Active";
        case PORTFOLIO_STATUS_INACTIVE: return "Inactive";
        case PORTFOLIO_STATUS_SUSPENDED: return "Suspended";
        case PORTFOLIO_STATUS_LIQUIDATING: return "Liquidating";
        case PORTFOLIO_STATUS_CLOSED: return "Closed";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get risk level name                                             |
//+------------------------------------------------------------------+
string CPortfolioManager::GetRiskLevelName(ENUM_RISK_LEVEL level) {
    switch (level) {
        case RISK_LEVEL_CONSERVATIVE: return "Conservative";
        case RISK_LEVEL_MODERATE: return "Moderate";
        case RISK_LEVEL_AGGRESSIVE: return "Aggressive";
        case RISK_LEVEL_SPECULATIVE: return "Speculative";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get allocation method name                                      |
//+------------------------------------------------------------------+
string CPortfolioManager::GetAllocationMethodName(ENUM_ALLOCATION_METHOD method) {
    switch (method) {
        case ALLOCATION_EQUAL_WEIGHT: return "Equal Weight";
        case ALLOCATION_RISK_PARITY: return "Risk Parity";
        case ALLOCATION_MARKET_CAP: return "Market Cap";
        case ALLOCATION_VOLATILITY_TARGET: return "Volatility Target";
        case ALLOCATION_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+