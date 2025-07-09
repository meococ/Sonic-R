#ifndef ASSET_DNA_MQH_
#define ASSET_DNA_MQH_

//+------------------------------------------------------------------+
//|                      AssetDNA.mqh                                |
//+------------------------------------------------------------------+ 

#include "CommonStructs.mqh" // Luôn include để đảm bảo sự độc lập

// class CTradeHistoryOptimizer; // Đã có trong CommonStructs.mqh qua EAContext


// BẮT ĐẦU NAMESPACE
namespace ApexPullback {


//+------------------------------------------------------------------+
//| Hàm chuyển đổi ENUM_STRATEGY_ID sang ENUM_TRADING_STRATEGY      |
//+------------------------------------------------------------------+
ENUM_TRADING_STRATEGY ConvertStrategyIDToTradingStrategy(ENUM_STRATEGY_ID strategyId) {
    switch(strategyId) {
        case STRATEGY_ID_PULLBACK:          return STRATEGY_PULLBACK_TREND;
        case STRATEGY_ID_MEAN_REVERSION:    return STRATEGY_MEAN_REVERSION;
        case STRATEGY_ID_BREAKOUT:          return STRATEGY_MOMENTUM_BREAKOUT;
        case STRATEGY_ID_SHALLOW_PULLBACK:  return STRATEGY_SHALLOW_PULLBACK; // Hoặc một giá trị phù hợp khác trong ENUM_TRADING_STRATEGY
        case STRATEGY_ID_RANGE_TRADING:     return STRATEGY_RANGE_TRADING;    // Hoặc một giá trị phù hợp khác
        // Thêm các case khác nếu cần
        default:                            return STRATEGY_UNDEFINED;
    }
}

//+------------------------------------------------------------------+
//| Cấu trúc lưu trữ một giao dịch đơn lẻ                             |
//+------------------------------------------------------------------+
class TradeRecord : public CObject {
public:
    long ticket;                // Số ticket của giao dịch
    datetime timeOpen;          // Thời gian mở lệnh
    datetime timeClose;         // Thời gian đóng lệnh
    ENUM_POSITION_TYPE type;    // Loại lệnh (buy/sell)
    double volume;              // Khối lượng giao dịch
    double priceOpen;           // Giá mở lệnh
    double priceClose;          // Giá đóng lệnh
    double profit;              // Lợi nhuận
    string symbol;              // Symbol giao dịch
    long magicNumber;           // Magic number
    string comment;             // Comment của lệnh
    ENUM_TRADING_STRATEGY scenario; // Kịch bản/chiến lược được sử dụng

    //--- Constructor
    TradeRecord() {
        Clear();
    }

    //--- Method to clear data
    void Clear() {
        ticket = 0;
        timeOpen = 0;
        timeClose = 0;
        type = (ENUM_POSITION_TYPE)-1; // Invalid type
        volume = 0.0;
        priceOpen = 0.0;
        priceClose = 0.0;
        profit = 0.0;
        symbol = "";
        magicNumber = 0;
        comment = "";
        scenario = STRATEGY_UNDEFINED;
    }
};

//--- Strategy Performance Struct
struct StrategyPerformance {
    ENUM_TRADING_STRATEGY strategy;
    int totalTrades;
    int winningTrades;
    double avgWinRate;   // Phần trăm
    double profitFactor;
    double expectancy;   // Kỳ vọng (có thể tính bằng R hoặc tiền tệ)
    double sharpeRatio;  // Tỷ lệ Sharpe
    // Thêm các chỉ số khác nếu cần: Max Drawdown, Avg Win/Loss Ratio

    void Clear() {
        strategy = STRATEGY_UNDEFINED;
        totalTrades = 0;
        winningTrades = 0;
        avgWinRate = 0.0;
        profitFactor = 0.0;
        expectancy = 0.0;
        sharpeRatio = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Lớp CAssetDNA - Phân tích và quản lý DNA của tài sản             |
//+------------------------------------------------------------------+
class CAssetDNA : public CObject {
private:
    ApexPullback::EAContext* m_context;             // Pointer to the central EAContext
    CTradeHistoryOptimizer* m_optimizer;        // Pointer to the trade history optimizer
    string m_symbol;                            // Symbol being analyzed
    ENUM_TIMEFRAMES m_timeframe;                // Main timeframe for analysis

    // Lưu trữ lịch sử giao dịch và hiệu suất
    CArrayObj* m_tradeHistory;                    // Mảng lưu trữ lịch sử giao dịch (TradeRecord objects)
    StrategyPerformance m_strategyStats[];          // Thống kê hiệu suất theo chiến lược

    // Các đặc tính tĩnh của tài sản
    ApexPullback::AssetProfileData m_assetProfile; // Thông tin cơ bản về tài sản
    
    // Các biến phân tích
    double m_volatilityScore;       // Điểm biến động
    double m_trendScore;            // Điểm xu hướng
    double m_momentumScore;         // Điểm động lượng
    double m_regimeScore;           // Điểm chế độ thị trường
    
    // --- Cross-Validation và Anti-Overfitting Structures ---
    struct CrossValidationResult {
        double avgWinRate;           // Win rate trung bình từ CV
        double avgProfitFactor;      // Profit factor trung bình từ CV
        double avgExpectancy;        // Expectancy trung bình từ CV
        double winRateVariance;      // Phương sai của win rate
        double profitFactorVariance; // Phương sai của profit factor
        double expectancyVariance;   // Phương sai của expectancy
        int validFolds;              // Số fold hợp lệ
        double stabilityIndex;       // Chỉ số ổn định (0-1)
        
        void Clear() {
            avgWinRate = 0.0;
            avgProfitFactor = 0.0;
            avgExpectancy = 0.0;
            winRateVariance = 0.0;
            profitFactorVariance = 0.0;
            expectancyVariance = 0.0;
            validFolds = 0;
            stabilityIndex = 0.0;
        }
    };
    
public:
//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CAssetDNA::CAssetDNA() : m_context(NULL), m_optimizer(NULL), m_tradeHistory(NULL) {
    // Constructor mặc định, không thực hiện logic phức tạp.
    // Việc khởi tạo sẽ được thực hiện trong hàm Initialize.
}
    
//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
~CAssetDNA() {
    if(m_context && m_context->pLogger != NULL) { // Check if logger exists before using it
        // m_context->pLogger->LogInfo("Destroying CAssetDNA for " + m_symbol); // Logging can be added if needed
    }
    // Safely delete the dynamic array
    if(m_tradeHistory != NULL)
    {
        delete m_tradeHistory;
        m_tradeHistory = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CAssetDNA::Initialize(EAContext* context) {
    m_context = context; // Lưu con trỏ context

    if(CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->pLogger) == POINTER_INVALID) {
        printf("CAssetDNA::Initialize - Context hoặc Logger không hợp lệ.");
        return false;
    }

    // Cấp phát bộ nhớ ở đây thay vì trong constructor
    if(CheckPointer(m_tradeHistory) == POINTER_INVALID) {
        m_tradeHistory = new CArrayObj();
        if(CheckPointer(m_tradeHistory) == POINTER_INVALID) {
            m_context->pLogger->LogError("Không thể cấp phát bộ nhớ cho m_tradeHistory", __FUNCTION__);
            return false;
        }
        m_tradeHistory->SetFreeObjects(true);
    }

    if(CheckPointer(m_context->pSymbolInfo) != POINTER_INVALID) m_symbol = m_context->pSymbolInfo->Symbol();
    if(CheckPointer(m_context->pTimeManager) != POINTER_INVALID) m_timeframe = m_context->pTimeManager->GetMainTimeframe();

    if(CheckPointer(m_context->pTradeHistoryOptimizer) != POINTER_INVALID) {
       m_optimizer = m_context->pTradeHistoryOptimizer;
    } else {
        m_context->pLogger->LogWarning("TradeHistoryOptimizer là NULL trong CAssetDNA::Initialize. Một số tính năng có thể không hoạt động.", __FUNCTION__);
    }

    int numStrategies = (int)STRATEGY_COUNT; // Sử dụng enum count
    ArrayResize(m_strategyStats, numStrategies);
    for(int i = 0; i < numStrategies; i++) {
        m_strategyStats[i].Clear();
        m_strategyStats[i].strategy = (ENUM_TRADING_STRATEGY)i;
    }

    m_context->pLogger->LogInfo("CAssetDNA đã được khởi tạo cho " + m_symbol, __FUNCTION__);
    return true;
}
    
//+------------------------------------------------------------------+
//| Thực hiện phân tích toàn diện                                      |
//+------------------------------------------------------------------+
bool FullAnalysis() {
    if(!m_context || m_context->pLogger == NULL) return false;
    
    m_context->pLogger->LogDebug("Starting full AssetDNA analysis for " + m_symbol);
    
    AnalyzeAssetCharacteristics();
    LoadTradeHistory();
    AnalyzeStrategyPerformance();
    PrintAnalysisSummary(); // Gọi hàm in tóm tắt
    
    m_context->pLogger->LogDebug("Phân tích toàn diện AssetDNA hoàn tất");
    return true;
}
    
    //+------------------------------------------------------------------+
    //| Phân tích đặc tính cơ bản của tài sản                            |
    //+------------------------------------------------------------------+
    void AnalyzeAssetCharacteristics() {
        // Phân tích biến động
        double atr = m_context->IndicatorUtils->GetATR(14);
        double atrPercent = (atr / SymbolInfoDouble(m_symbol, SYMBOL_BID)) * 100;
        
        // Phân tích xu hướng
        m_context->IndicatorUtils->RegisterMA(20);
        m_context->IndicatorUtils->RegisterMA(50);
        m_context->IndicatorUtils->RegisterMA(200);
        
        double ema20 = m_context->IndicatorUtils->GetMA(20);
        double ema50 = m_context->IndicatorUtils->GetMA(50);
        double ema200 = m_context->IndicatorUtils->GetMA(200);
        
        // Phân tích động lượng
        double rsi = m_context->IndicatorUtils->GetRSI();
        double macd = m_context->IndicatorUtils->GetMACDMain();
        
m_volatilityScore = CalculateVolatilityScore(atrPercent);
m_trendScore = CalculateTrendScore(ema20, ema50, ema200);
m_momentumScore = CalculateMomentumScore(rsi, macd);
        m_regimeScore = (m_trendScore + m_momentumScore) / 2;
        
        // Cập nhật thông tin vào profile
        m_assetProfile.averageATR = atr;
        m_assetProfile.yearlyVolatility = atrPercent * sqrt(252);
        m_assetProfile.isStrongTrending = (m_trendScore > 0.7);
        m_assetProfile.isMeanReverting = (m_regimeScore < 0.3);
    }
    
    //+------------------------------------------------------------------+
    //| Tải và phân tích lịch sử giao dịch                               |
    //+------------------------------------------------------------------+
    void LoadTradeHistory() {
        if(m_context->pLogger == NULL) return;
        m_context->pLogger->LogInfo("AssetDNA: Loading trade history...");
        
        m_tradeHistory->Clear(); // Use -> for pointer

        if(!HistorySelect(0, TimeCurrent())) {
            if(m_context->pLogger != NULL) m_context->pLogger->LogError("AssetDNA: HistorySelect failed. Error: " + IntegerToString(GetLastError()));
            return;
        }

        ulong ticket;
        long totalDeals = HistoryDealsTotal();
        if(m_context->pLogger != NULL) m_context->pLogger->LogInfo("AssetDNA: Total deals in history: " + IntegerToString(totalDeals));

        for(long i = 0; i < totalDeals; i++) {
            ticket = HistoryDealGetTicket(i);
            if(ticket > 0) {
                long dealMagic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
                string dealSymbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
                long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
                
                if ((dealEntry == DEAL_ENTRY_OUT || dealEntry == DEAL_ENTRY_INOUT) && 
                    (dealMagic == m_context->pMagicNumber || (dealMagic >= EA_MAGIC_NUMBER_BASE && dealMagic < EA_MAGIC_NUMBER_BASE + 1000)) &&
                    dealSymbol == m_symbol) {
                    
                    TradeRecord* trade = new TradeRecord();
                    if(trade == NULL) continue;

                    trade->ticket = ticket;
                    trade->timeClose = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
                    trade->priceClose = HistoryDealGetDouble(ticket, DEAL_PRICE);
                    trade->volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
                    trade->profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                    trade->symbol = dealSymbol;
                    trade->magicNumber = dealMagic;
                    trade->comment = HistoryDealGetString(ticket, DEAL_COMMENT);

                    long position_id = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
                    if(position_id > 0) {
                        if(HistorySelectByPosition(position_id)) {
                            ulong open_deal_ticket = HistoryDealGetTicket(0);
                            if(open_deal_ticket > 0) {
                                trade->timeOpen = (datetime)HistoryDealGetInteger(open_deal_ticket, DEAL_TIME);
                                trade->priceOpen = HistoryDealGetDouble(open_deal_ticket, DEAL_PRICE);
                                trade->type = (ENUM_POSITION_TYPE)HistoryDealGetInteger(open_deal_ticket, DEAL_TYPE);
                            }
                        }
                    }

                    ENUM_STRATEGY_ID decodedStrategyId = DecodeStrategyFromMagic((int)dealMagic);
                    trade->scenario = ConvertStrategyIDToTradingStrategy(decodedStrategyId);

                    m_tradeHistory->Add(trade); // Use -> for pointer
                }
            }
        }
        if(m_context->pLogger != NULL) m_context->pLogger->LogInfo("AssetDNA: Loaded " + IntegerToString(m_tradeHistory->Total()) + " relevant trade records for " + m_symbol);
    }

    //+------------------------------------------------------------------+
    //| Các hàm tính điểm (Helper functions)                             |
    //+------------------------------------------------------------------+
    double CalculateVolatilityScore(double atrPercent) {
        return MathHelper::Normalize(atrPercent, 0.1, 2.0);
    }

    double CalculateTrendScore(double ema20, double ema50, double ema200) {
        if (ema20 > ema50 && ema50 > ema200) return 1.0;
        if (ema20 < ema50 && ema50 < ema200) return 0.0;
        return 0.5;
    }

    double CalculateMomentumScore(double rsi, double macd) {
        double rsiScore = MathHelper::Normalize(rsi, 30, 70);
        return rsiScore;
    }

    //+------------------------------------------------------------------+
    //| Phân tích hiệu suất các chiến lược                               |
    //+------------------------------------------------------------------+
void AnalyzeStrategyPerformance() {
    if (m_context->pLogger != NULL && m_context->EnableMethodLogging) {
        m_context->pLogger->LogDebug("AssetDNA: Starting strategy performance analysis...");
    }

    for (int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        m_strategyStats[i].Clear();
        m_strategyStats[i].strategy = (ENUM_TRADING_STRATEGY)i;
    }

    if (m_tradeHistory->Total() == 0) { // Use -> for pointer
        if (m_context->pLogger != NULL && m_context->EnableMethodLogging) {
            m_context->pLogger->LogDebug("AssetDNA: No trade history found to analyze.");
        }
        return;
    }

    double weighted_total_profit[ENUM_TRADING_STRATEGY_COUNT];
    double weighted_total_loss[ENUM_TRADING_STRATEGY_COUNT];
    double weighted_wins[ENUM_TRADING_STRATEGY_COUNT];
    double weighted_losses[ENUM_TRADING_STRATEGY_COUNT];
    double weighted_total_trades[ENUM_TRADING_STRATEGY_COUNT];
    
    for(int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        weighted_total_profit[i] = 0.0;
        weighted_total_loss[i] = 0.0;
        weighted_wins[i] = 0.0;
        weighted_losses[i] = 0.0;
        weighted_total_trades[i] = 0.0;
    }

    datetime cutoffTime = 0;
    if (m_context->pHistoryAnalysisMonths > 0) {
        cutoffTime = TimeCurrent() - ((long)m_context->pHistoryAnalysisMonths * 30 * 24 * 3600);
    }

    for (int i = 0; i < m_tradeHistory->Total(); i++) { // Use -> for pointer
        TradeRecord* trade = (TradeRecord*)m_tradeHistory->At(i); // Use -> for pointer
        if (trade == NULL) continue;

        if (cutoffTime > 0 && trade->timeOpen < cutoffTime) continue;

        int strategyIdx = (int)trade->scenario;
        if (strategyIdx < 0 || strategyIdx >= ENUM_TRADING_STRATEGY_COUNT) {
            if (m_context->pLogger != NULL) m_context->pLogger->LogWarning(StringFormat("AssetDNA: Invalid strategy index %d for trade #%d", strategyIdx, trade->ticket));
            continue;
        }

        double decayWeight = CalculateTradeDecayWeight(trade->timeOpen);
        
        m_strategyStats[strategyIdx].totalTrades++;
        weighted_total_trades[strategyIdx] += decayWeight;

        if (trade->profit > 0) {
            weighted_total_profit[strategyIdx] += trade->profit * decayWeight;
            weighted_wins[strategyIdx] += decayWeight;
        } else {
            weighted_total_loss[strategyIdx] += fabs(trade->profit) * decayWeight;
            weighted_losses[strategyIdx] += decayWeight;
        }
    }

    for (int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        if (weighted_total_trades[i] > 0.01) {
            
            m_strategyStats[i].avgWinRate = (weighted_wins[i] / weighted_total_trades[i]) * 100.0;
            
            if (weighted_total_loss[i] > 0) {
                m_strategyStats[i].profitFactor = weighted_total_profit[i] / weighted_total_loss[i];
            } else if (weighted_total_profit[i] > 0) {
                m_strategyStats[i].profitFactor = 999.0; // Convention for infinite profit factor
            } else {
                m_strategyStats[i].profitFactor = 0.0;
            }

            m_strategyStats[i].expectancy = (weighted_total_profit[i] - weighted_total_loss[i]) / weighted_total_trades[i];

            if (m_context->pLogger != NULL && m_context->EnableStrategyPerformanceLogging) {
                m_context->pLogger->LogDebug(StringFormat("AssetDNA: Strategy '%s' Performance - Trades: %d, W/W-Rate: %.2f, W/PF: %.2f, W/Exp: %.2f",
                    EnumToString((ENUM_TRADING_STRATEGY)i),
                    m_strategyStats[i].totalTrades,
                    m_strategyStats[i].avgWinRate,
                    m_strategyStats[i].profitFactor,
                    m_strategyStats[i].expectancy));
            }
        }
    }
}

    //+------------------------------------------------------------------+
    //| In tóm tắt phân tích ra log                                      |
    //+------------------------------------------------------------------+
    void PrintAnalysisSummary() {
        if(m_context->pLogger == NULL || !m_context->EnableDNAPrinting) return;
        
        m_context->pLogger->LogInfo("--- Asset DNA Summary for " + m_symbol + " ---");
        m_context->pLogger->LogInfo(StringFormat("Volatility Score: %.2f (ATR: %.5f, ATR%%: %.2f%%)", 
                                    m_volatilityScore, 
                                    m_assetProfile.averageATR, 
                                    (m_assetProfile.averageATR / SymbolInfoDouble(m_symbol, SYMBOL_BID)) * 100));
        m_context->pLogger->LogInfo(StringFormat("Trend Score: %.2f (Trending: %s)", m_trendScore, m_assetProfile.isStrongTrending ? "Yes" : "No"));
        m_context->pLogger->LogInfo(StringFormat("Momentum Score: %.2f", m_momentumScore));
        m_context->pLogger->LogInfo(StringFormat("Market Regime Score: %.2f (Mean Reverting: %s)", m_regimeScore, m_assetProfile.isMeanReverting ? "Yes" : "No"));
        m_context->pLogger->LogInfo("--------------------------------------------------");
    }


    //+------------------------------------------------------------------+
    //| Tính trọng số giảm dần theo thời gian cho giao dịch               |
    //+------------------------------------------------------------------+
    double CalculateTradeDecayWeight(datetime tradeTime) {
        if (m_context->pDecayHalfLifeDays <= 0) {
            return 1.0; // No decay if not configured
        }

        long ageInSeconds = TimeCurrent() - tradeTime;
        double ageInDays = (double)ageInSeconds / (24.0 * 3600.0);

        // Exponential decay formula: weight = 2^(-age / half_life)
        double halfLife = m_context->pDecayHalfLifeDays;
        double weight = pow(2.0, -ageInDays / halfLife);

        return weight;
    }

    //+------------------------------------------------------------------+
    //| Giải mã chiến lược từ Magic Number                               |
    //+------------------------------------------------------------------+
    ENUM_STRATEGY_ID DecodeStrategyFromMagic(int magic) {
        if (magic >= EA_MAGIC_NUMBER_BASE && magic < EA_MAGIC_NUMBER_BASE + 1000) {
            int strategyPart = (magic - EA_MAGIC_NUMBER_BASE) % 100;
            return (ENUM_STRATEGY_ID)strategyPart;
        }
        return STRATEGY_ID_UNDEFINED;
    }

}; // END CLASS CAssetDNA

} // END NAMESPACE ApexPullback


    //+------------------------------------------------------------------+
    //| Lấy chiến lược tối ưu dựa trên phân tích                        |
    //+------------------------------------------------------------------+
    ENUM_TRADING_STRATEGY GetOptimalStrategy(const MarketProfileDataStruct& currentProfile) {
        if(m_context->Logger != NULL) {
            m_context->Logger->LogDebug("AssetDNA: Determining optimal strategy...");
        }

        double highestScore = -1.0;
        ENUM_TRADING_STRATEGY bestStrategy = STRATEGY_UNDEFINED;

        // Iterate through all defined strategies
        for (int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
            ENUM_TRADING_STRATEGY currentStrategy = (ENUM_TRADING_STRATEGY)i;
            if (currentStrategy == STRATEGY_UNDEFINED) continue;

            double marketSuitability = CalculateMarketSuitability(currentStrategy, currentProfile);
            double pastPerformance = GetPastPerformanceScore(currentStrategy);

            // Combine scores with weighting
            double finalScore = (marketSuitability * m_context->MarketSuitabilityWeight) + (pastPerformance * m_context->PastPerformanceWeight);

            if (m_context->Logger != NULL && m_context->EnableDetailedScoreLogging) {
                m_context->Logger->LogDebug(StringFormat("AssetDNA: Strategy '%s' - Market: %.3f, Perf: %.3f, Final: %.3f",
                    EnumToString(currentStrategy), marketSuitability, pastPerformance, finalScore));
            }

            if (finalScore > highestScore) {
                highestScore = finalScore;
                bestStrategy = currentStrategy;
            }
        }

        if (m_context->Logger != NULL) {
            m_context->Logger->LogInfo(StringFormat("AssetDNA: Optimal strategy selected: %s (Score: %.3f)", EnumToString(bestStrategy), highestScore));
        }

        return bestStrategy;
    }

    //+------------------------------------------------------------------+
    //| Tính toán sự phù hợp của thị trường hiện tại cho một chiến lược  |
    //+------------------------------------------------------------------+
    double CalculateMarketSuitability(ENUM_TRADING_STRATEGY strategy, const MarketProfileDataStruct& profile) {
        double score = 0.0;
        switch (strategy) {
            case STRATEGY_PULLBACK_TREND:
                score = profile.TrendStrength * 0.5 + profile.MomentumScore * 0.3 + (1.0 - profile.VolatilityScore) * 0.2;
                break;
            case STRATEGY_MOMENTUM_BREAKOUT:
                score = profile.VolatilityScore * 0.5 + profile.MomentumScore * 0.4 + profile.VolumeScore * 0.1;
                break;
            case STRATEGY_MEAN_REVERSION:
                score = (1.0 - profile.TrendStrength) * 0.6 + profile.RSIReversionSignal * 0.4;
                break;
            case STRATEGY_SHALLOW_PULLBACK:
                 score = profile.TrendStrength * 0.6 + profile.MomentumScore * 0.4;
                 break;
            case STRATEGY_RANGE_TRADING:
                 score = (1.0 - profile.TrendStrength) * 0.7 + (1.0 - profile.VolatilityScore) * 0.3;
                 break;
        }
        return MathMax(0.0, MathMin(1.0, score)); // Normalize to 0-1
    }

    //+------------------------------------------------------------------+
    //| Lấy điểm hiệu suất trong quá khứ của một chiến lược              |
    //+------------------------------------------------------------------+
    double GetPastPerformanceScore(ENUM_TRADING_STRATEGY strategy) {
        const StrategyPerformance* perf = GetStrategyPerformance(strategy);
        if (perf == NULL || perf->totalTrades < m_context->MinTradesForPerformance) {
            return m_context->DefaultPerformanceScore; // Return a neutral default score
        }

        // Perform cross-validation to get robust metrics
        CrossValidationResult cvResult = PerformEnhancedCrossValidation(strategy, perf);

        if (cvResult.validFolds > 0) {
            // Regularization: Shrink metrics towards the mean if data is sparse
            double tradeCountFactor = 1.0 - exp(-(double)perf->totalTrades / 50.0); // Factor approaches 1 as trades increase
            double adjustedWinRate = (cvResult.avgWinRate * tradeCountFactor) + (50.0 * (1.0 - tradeCountFactor));
            double adjustedProfitFactor = (cvResult.avgProfitFactor * tradeCountFactor) + (1.0 * (1.0 - tradeCountFactor));
            double adjustedExpectancy = (cvResult.avgExpectancy * tradeCountFactor) + (0.0 * (1.0 - tradeCountFactor));

            double score = 0.0;
            double winRateScore = 0.0, profitFactorScore = 0.0, expectancyScore = 0.0, stabilityScore = 0.0;

            if(adjustedWinRate >= 60.0) winRateScore = 0.3;
            else if(adjustedWinRate >= 50.0) winRateScore = 0.2;
            else if(adjustedWinRate >= 40.0) winRateScore = 0.1;
            else if(adjustedWinRate >= 25.0) winRateScore = 0.05;
            
            if(adjustedProfitFactor >= 1.8) profitFactorScore = 0.3;
            else if(adjustedProfitFactor >= 1.4) profitFactorScore = 0.25;
            else if(adjustedProfitFactor >= 1.15) profitFactorScore = 0.15;
            else if(adjustedProfitFactor >= 1.0) profitFactorScore = 0.05;
            
            if(adjustedExpectancy >= 0.15) expectancyScore = 0.2;
            else if(adjustedExpectancy >= 0.08) expectancyScore = 0.15;
            else if(adjustedExpectancy >= 0.03) expectancyScore = 0.1;
            else if(adjustedExpectancy >= 0.0) expectancyScore = 0.05;
            
            stabilityScore = CalculateStabilityScore(cvResult);
            
            score = winRateScore + profitFactorScore + expectancyScore + stabilityScore;
            
            double overfittingPenalty = CalculateOverfittingPenalty(cvResult);
            score = MathMax(0.0, score - overfittingPenalty);
            
            if(m_context->Logger && m_context->EnableStrategyPerformanceLogging) {
                m_context->Logger->LogDebug(StringFormat("AssetDNA: %s Performance (CV) - WR: %.1f%% (%.1f%%), PF: %.2f (%.2f), Exp: %.3f (%.3f), Stability: %.3f, Trades: %d",
                                 EnumToString(strategy), adjustedWinRate, perf->avgWinRate, adjustedProfitFactor, perf->profitFactor, 
                                 adjustedExpectancy, perf->expectancy, stabilityScore, perf->totalTrades));
            }
            
            if(m_context->Logger && m_context->EnableDetailedScoreLogging) {
                m_context->Logger->LogDebug(StringFormat("AssetDNA: %s Score Breakdown - WR: %.3f, PF: %.3f, Exp: %.3f, Stability: %.3f, Penalty: %.3f, Total: %.3f",
                                 EnumToString(strategy), winRateScore, profitFactorScore, expectancyScore, 
                                 stabilityScore, overfittingPenalty, score));
            }
        } else {
            if(m_context->Logger && m_context->EnableColdStartLogging) {
                m_context->Logger->LogWarning(StringFormat("AssetDNA: %s - Không đủ dữ liệu lịch sử (Trades: %d < %d). Sử dụng điểm mặc định: %.3f",
                                   EnumToString(strategy), perf ? perf->totalTrades : 0, 
                                   m_context->MinTradesForPerformance, m_context->DefaultPerformanceScore));
            }
        }
        
        return MathMax(0.0, MathMin(1.0, score));
    }

    //+------------------------------------------------------------------+
    //| Tính toán chỉ số ổn định từ kết quả Cross-Validation             |
    //+------------------------------------------------------------------+
    double CalculateStabilityScore(const CrossValidationResult& cvResult) {
        if (cvResult.validFolds == 0) return 0.0;

        // Normalize variances before combining them
        // Lower variance is better. We want a score where 1 is best (zero variance).
        double normalizedWinRateVariance = 1.0 - MathMin(1.0, cvResult.winRateVariance / 100.0); // e.g., 10% std dev (100 variance) is bad
        double normalizedProfitFactorVariance = 1.0 - MathMin(1.0, cvResult.profitFactorVariance / 1.0); // e.g., 1.0 std dev is bad
        double normalizedExpectancyVariance = 1.0 - MathMin(1.0, cvResult.expectancyVariance / 0.25); // e.g., 0.5R std dev is bad

        // Combine the normalized stability scores
        double stabilityIndex = (normalizedWinRateVariance + normalizedProfitFactorVariance + normalizedExpectancyVariance) / 3.0;

        return MathMax(0.0, MathMin(1.0, stabilityIndex));
    }

    //+------------------------------------------------------------------+
    //| Tính toán hình phạt cho Overfitting                              |
    //+------------------------------------------------------------------+
    double CalculateOverfittingPenalty(const CrossValidationResult& cvResult) {
        if (cvResult.validFolds == 0) return 0.0;

        // A simple penalty based on the variance of the profit factor
        double penalty = cvResult.profitFactorVariance * 0.2; // Higher variance = higher penalty
        return MathMin(0.5, penalty); // Cap the penalty
    }

    //+------------------------------------------------------------------+
    //| Thực hiện Cross-Validation nâng cao                             |
    //+------------------------------------------------------------------+
    CrossValidationResult PerformEnhancedCrossValidation(ENUM_TRADING_STRATEGY strategy, const StrategyPerformance* perf, int folds = 5) {
        CrossValidationResult result;
        result.Clear();
        
        if(perf == NULL || perf->totalTrades < 10) {
            return result;
        }
        
        if (m_tradeHistory == NULL) return result;

        CArrayObj tradesForStrategy;
        for(int i = 0; i < m_tradeHistory->Total(); i++) {
            TradeRecord* trade = (TradeRecord*)m_tradeHistory->At(i);
            if(trade != NULL && trade->scenario == strategy) {
                tradesForStrategy.Add(trade);
            }
        }
        
        if(tradesForStrategy.Total() < 10) {
            return result;
        }
        
        double winRates[];
        double profitFactors[];
        double expectancies[];
        ArrayResize(winRates, folds);
        ArrayResize(profitFactors, folds);
        ArrayResize(expectancies, folds);
        
        int tradesPerFold = tradesForStrategy.Total() / folds;
        int validFolds = 0;
        
        for(int fold = 0; fold < folds; fold++) {
            int startIdx = fold * tradesPerFold;
            int endIdx = (fold == folds - 1) ? tradesForStrategy.Total() - 1 : (fold + 1) * tradesPerFold - 1;
            
            if(endIdx - startIdx < 5) continue;
            
            int wins = 0;
            double totalProfit = 0.0;
            double totalLoss = 0.0;
            int totalTradesInFold = endIdx - startIdx + 1;
            
            for(int i = startIdx; i <= endIdx; i++) {
                TradeRecord* trade = (TradeRecord*)tradesForStrategy.At(i);
                if(trade != NULL) {
                    if(trade->profit > 0) {
                        wins++;
                        totalProfit += trade->profit;
                    } else {
                        totalLoss += MathAbs(trade->profit);
                    }
                }
            }
            
            winRates[validFolds] = (double)wins / totalTradesInFold * 100.0;
            profitFactors[validFolds] = (totalLoss > 0) ? totalProfit / totalLoss : (totalProfit > 0 ? 999.0 : 0.0);
            expectancies[validFolds] = (totalProfit - totalLoss) / totalTradesInFold;
            validFolds++;
        }
        
        if(validFolds == 0) {
            return result;
        }
        
        result.validFolds = validFolds;
        
        for(int i = 0; i < validFolds; i++) {
            result.avgWinRate += winRates[i];
            result.avgProfitFactor += profitFactors[i];
            result.avgExpectancy += expectancies[i];
        }
        result.avgWinRate /= validFolds;
        result.avgProfitFactor /= validFolds;
        result.avgExpectancy /= validFolds;
        
        for(int i = 0; i < validFolds; i++) {
            double wrDiff = winRates[i] - result.avgWinRate;
            double pfDiff = profitFactors[i] - result.avgProfitFactor;
            double expDiff = expectancies[i] - result.avgExpectancy;
            
            result.winRateVariance += wrDiff * wrDiff;
            result.profitFactorVariance += pfDiff * pfDiff;
            result.expectancyVariance += expDiff * expDiff;
        }
        result.winRateVariance /= validFolds;
        result.profitFactorVariance /= validFolds;
        result.expectancyVariance /= validFolds;
        
        result.stabilityIndex = CalculateStabilityScore(result);
        
        return result;
    }

}; // END CLASS CAssetDNA

} // end namespace ApexPullback

#endif // ASSETDNA_MQH_