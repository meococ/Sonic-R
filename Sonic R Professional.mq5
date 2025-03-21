//+------------------------------------------------------------------+
//|                                             Sonic R Advanced EA |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Sonic R Advanced EA"
#property link      ""
#property version   "2.00"
#property strict

// Include Trade class for MQL5
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| COMPATIBILITY LAYER - MQL5                                   |
//+------------------------------------------------------------------+

// Operation types
#define OP_BUY 0
#define OP_SELL 1

// Symbol info properties
#define MODE_TICKVALUE SYMBOL_TRADE_TICK_VALUE
#define MODE_LOTSTEP SYMBOL_VOLUME_STEP
#define MODE_MINLOT SYMBOL_VOLUME_MIN
#define MODE_MAXLOT SYMBOL_VOLUME_MAX
#define MODE_SPREAD SYMBOL_SPREAD
#define MODE_POINT SYMBOL_POINT

// Order selection
#define MODE_TRADES 0
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1

// MA methods
#define MODE_SMA 0     // Simple moving average
#define MODE_EMA 1     // Exponential moving average
#define MODE_SMMA 2    // Smoothed moving average
#define MODE_LWMA 3    // Linear weighted moving average

// Series modes for iHighest/iLowest
#define MODE_OPEN ENUM_SERIESMODE::MODE_OPEN
#define MODE_HIGH ENUM_SERIESMODE::MODE_HIGH
#define MODE_LOW ENUM_SERIESMODE::MODE_LOW
#define MODE_CLOSE ENUM_SERIESMODE::MODE_CLOSE

// Price type enums
enum ENUM_MQL4_APPLIED_PRICE
{
   MQL4_PRICE_OPEN = 0,    // Open price
   MQL4_PRICE_CLOSE = 1,   // Close price
   MQL4_PRICE_HIGH = 2,    // High price
   MQL4_PRICE_LOW = 3,     // Low price
   MQL4_PRICE_MEDIAN = 4,  // Median price (high+low)/2
   MQL4_PRICE_TYPICAL = 5, // Typical price (high+low+close)/3
   MQL4_PRICE_WEIGHTED = 6 // Weighted price (high+low+close+close)/4
};

// Định nghĩa lại các hằng số để sử dụng giá trị enum mới
#define PRICE_OPEN ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_OPEN
#define PRICE_CLOSE ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_CLOSE
#define PRICE_HIGH ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_HIGH
#define PRICE_LOW ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_LOW  
#define PRICE_MEDIAN ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_MEDIAN
#define PRICE_TYPICAL ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_TYPICAL
#define PRICE_WEIGHTED ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_WEIGHTED

// Hằng số cho ánh xạ MQL4 -> MQL5 price types
#define SYS_PRICE_OPEN ENUM_APPLIED_PRICE::PRICE_OPEN
#define SYS_PRICE_CLOSE ENUM_APPLIED_PRICE::PRICE_CLOSE
#define SYS_PRICE_HIGH ENUM_APPLIED_PRICE::PRICE_HIGH
#define SYS_PRICE_LOW ENUM_APPLIED_PRICE::PRICE_LOW
#define SYS_PRICE_MEDIAN ENUM_APPLIED_PRICE::PRICE_MEDIAN
#define SYS_PRICE_TYPICAL ENUM_APPLIED_PRICE::PRICE_TYPICAL
#define SYS_PRICE_WEIGHTED ENUM_APPLIED_PRICE::PRICE_WEIGHTED

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - Organized by functionality                     |
//+------------------------------------------------------------------+

// Market data variables
double g_point = 0.0001;         // Point value adjusted for digits
double g_daily_high = 0;         // Daily high price
double g_daily_low = 0;          // Daily low price
double g_normal_spread = 0;      // Normal spread value for anomaly detection
double g_5min_high = 0;          // 5-minute high
double g_5min_low = 0;           // 5-minute low

// Technical indicators
double g_dragon_mid = 0;         // EMA Dragon middle value
double g_dragon_high = 0;        // EMA Dragon high value
double g_dragon_low = 0;         // EMA Dragon low value
double g_trend = 0;              // Trend indicator value
double g_ema89 = 0;              // EMA 89 value for trailing stop
double g_ma = 0;                 // MA value

// Account status
double g_session_start_balance = 0;  // Session start balance for drawdown calculation
double g_week_start_balance = 0;     // Weekly start balance for drawdown calculation
datetime g_day_start_time = 0;       // Day start time for daily stats

// Position tracking
int g_total_buy = 0;             // Total buy positions
int g_total_sell = 0;            // Total sell positions

// News and market anomaly data
bool g_news_active = false;      // Is news period active
int g_news_impact = 0;           // News impact level
datetime g_last_news_time = 0;   // Last news event time
bool g_market_anomaly_detected = false;  // Market anomaly detection flag
datetime g_last_anomaly_time = 0;        // Last anomaly detected time

// Scout position building
bool g_mm_bullish = false;        // MM (Market Makers) bullish flag
int g_scout_positions_count = 0;  // Count of Scout positions
double g_scout_tp_levels[3];      // Scout take profit levels
bool g_tp2_hit = false;           // TP2 hit flag

// Multi-timeframe analysis
datetime g_last_mtf_analysis = 0; // Last multi-timeframe analysis time
bool g_mtf_bullish_d1 = false;    // D1 timeframe bullish
bool g_mtf_bullish_h4 = false;    // H4 timeframe bullish
bool g_mtf_bullish_h1 = false;    // H1 timeframe bullish

// News event structures
struct NewsEvent
{
   string title;     // News title
   string currency;  // Currency affected
   datetime time;    // News time
   int impact;       // Impact level (1-3)
};

NewsEvent g_upcoming_news[];     // Array of upcoming news events
int g_news_count = 0;            // Count of news events loaded

// SECTION 5: Risk Management for News and Anomalies
input bool DetectMarketAnomalies = true;      // Enable market anomaly detection
input double MaxSpreadMultiplier = 3.0;       // Maximum acceptable spread multiplier
input double AbnormalVolatilityPips = 50.0;   // Abnormal volatility threshold in pips
input int PostNewsWaitTime = 15;              // Minutes to wait after news
input bool ReduceSizePostNews = true;         // Reduce position size after news
input double PostNewsSizePercent = 50.0;      // Position size after news (% of normal)
input bool UseExternalNewsCalendar = false;   // Use external news calendar
input string NewsCalendarFile = "news.csv";   // News calendar filename

// SECTION 6: Order Management with Tiered Take Profits
input bool UseScoutPositionBuilding = true;   // Use scout position building
input int MaxScoutPositions = 5;              // Maximum number of scout positions
input bool UseMultipleTPs = true;             // Use multiple take profit levels
input double TP1Percent = 30.0;               // First TP (percent of position)
input double TP1Ratio = 1.5;                  // Risk:Reward ratio for TP1
input double TP2Percent = 30.0;               // Second TP (percent of position)
input double TP2Ratio = 2.0;                  // Risk:Reward ratio for TP2
input double TP3Percent = 40.0;               // Third TP (percent of position)
input double TP3Ratio = 3.0;                  // Risk:Reward ratio for TP3
input bool UseEMA89TrailingStop = true;       // Use EMA 89 for trailing stop
input bool AdjustTPsOnVolume = true;          // Adjust TPs based on volume

// SECTION 7: Daily Trading Process
input bool UseMultiTimeframeAnalysis = true;  // Use multi-timeframe analysis
input bool LimitTradingHours = true;          // Limit trading hours
input int TradingStartHour = 8;               // Trading start hour (GMT)
input int TradingEndHour = 16;                // Trading end hour (GMT)
input bool OnlyTradeMainSessions = true;      // Only trade during main sessions
input int LondonOpenHour = 8;                 // London session open hour (GMT)
input int NewYorkOpenHour = 13;               // New York session open hour (GMT)
input int SessionOverlapHours = 3;            // Session overlap hours
input bool SaveTradingLog = true;             // Save trading log
input string LogFileName = "SonicR_Log.csv";  // Log filename
input bool DailyMarketAnalysis = true;        // Perform daily market analysis

//+------------------------------------------------------------------+
//| ScoutPositionManager Class                                       |
//+------------------------------------------------------------------+

class CScoutPositionManager
{
private:
    double BaseLotSize;          // Kích thước lệnh cơ bản cho Classical
    double ScoutLotDivisor;      // Hệ số giảm kích thước (mặc định 10)
    int MaxScoutPositions;       // Số lượng Scout tối đa
    double PyramidStepPips;      // Số pips giữa các lệnh pyramid
    double PyramidFactorInc;     // Hệ số tăng kích thước pyramid (>1.0)
    bool UseAdaptivePyramiding;  // Sử dụng pyramid thích ứng theo volatility
    double ProfitClosePercent;   // % đóng lệnh khi lời
    
    int TotalScoutPositions;     // Tổng số Scout positions
    ulong ScoutTickets[];        // Mảng lưu tickets của Scout
    double ScoutLevels[];        // Mảng lưu mức giá của Scout
    bool IsScoutBuy;             // Trạng thái Scout (true=buy, false=sell)
    
    double LastATR;              // ATR gần nhất để tính pyramid
    int ATRPeriod;               // Khoảng thời gian tính ATR (14)
    ENUM_TIMEFRAMES ATRTimeframe; // Khung thời gian tính ATR (PERIOD_H1)
    
    double CurrentPyramidTP;     // TP hiện tại cho pyramid
    double CurrentPyramidSL;     // SL hiện tại cho pyramid
    
    // Tracking MM intention
    bool MMIsBullish;            // MM Bullish or Bearish
    
public:
    // Constructor
    CScoutPositionManager(double baseLotSize = 0.1, 
                          double scoutDivisor = 10.0, 
                          int maxPositions = 10, 
                          double stepPips = 30.0,
                          double pyramidFactor = 1.5,
                          bool adaptivePyramid = true,
                          double profitClosePercent = 33.3)
    {
        BaseLotSize = baseLotSize;
        ScoutLotDivisor = scoutDivisor;
        MaxScoutPositions = maxPositions;
        PyramidStepPips = stepPips;
        PyramidFactorInc = pyramidFactor;
        UseAdaptivePyramiding = adaptivePyramid;
        ProfitClosePercent = profitClosePercent;
        
        TotalScoutPositions = 0;
        ArrayResize(ScoutTickets, MaxScoutPositions);
        ArrayResize(ScoutLevels, MaxScoutPositions);
        
        ATRPeriod = 14;
        ATRTimeframe = PERIOD_H1;
        UpdateATR();
    }
    
    // Cập nhật ATR
    void UpdateATR()
    {
        int atr_handle = iATR(_Symbol, ATRTimeframe, ATRPeriod);
        if(atr_handle != INVALID_HANDLE)
        {
            double atr_buffer[1];
            if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
            {
                LastATR = atr_buffer[0];
            }
        }
    }
    
    // Mở lệnh Scout đầu tiên
    bool OpenInitialScout(bool is_buy, double price, double sl, double tp, 
                          CPVSRA_Analysis* pvsra = NULL)
    {
        // Reset trạng thái
        TotalScoutPositions = 0;
        ArrayFill(ScoutTickets, 0, MaxScoutPositions, 0);
        ArrayFill(ScoutLevels, 0, MaxScoutPositions, 0);
        IsScoutBuy = is_buy;
        
        // Cập nhật MM intention từ PVSRA
        if(pvsra != NULL)
        {
            bool mm_bullish;
            double mm_level, mm_ratio;
            string mm_reason;
            
            if(pvsra.GetRecentMMActivity(mm_bullish, mm_level, mm_ratio, mm_reason))
            {
                MMIsBullish = mm_bullish;
                
                // Nếu hướng Scout không khớp với hướng MM, giảm kích thước thêm
                if((is_buy && !mm_bullish) || (!is_buy && mm_bullish))
                {
                    Print("Warning: Scout direction opposite to MM intention. Reducing size further.");
                    ScoutLotDivisor *= 1.5; // Giảm thêm 50% kích thước
                }
            }
        }
        
        // Tính toán kích thước lệnh Scout
        double scout_lot = NormalizeDouble(BaseLotSize / ScoutLotDivisor, 2);
        if(scout_lot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
        {
            scout_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        }
        
        // Mở lệnh
        CTrade trade;
        trade.SetDeviationInPoints(10); // 1 pip deviation
        
        if(is_buy)
        {
            if(trade.Buy(scout_lot, _Symbol, price, sl, tp, "Scout Initial"))
            {
                // Lưu thông tin lệnh
                ScoutTickets[0] = trade.ResultOrder();
                ScoutLevels[0] = price;
                TotalScoutPositions = 1;
                
                // Lưu TP/SL
                CurrentPyramidTP = tp;
                CurrentPyramidSL = sl;
                
                return true;
            }
        }
        else
        {
            if(trade.Sell(scout_lot, _Symbol, price, sl, tp, "Scout Initial"))
            {
                // Lưu thông tin lệnh
                ScoutTickets[0] = trade.ResultOrder();
                ScoutLevels[0] = price;
                TotalScoutPositions = 1;
                
                // Lưu TP/SL
                CurrentPyramidTP = tp;
                CurrentPyramidSL = sl;
                
                return true;
            }
        }
        
        return false;
    }
    
    // Thêm lệnh pyramid
    bool AddPyramidPosition(double price = 0.0)
    {
        if(TotalScoutPositions >= MaxScoutPositions) return false;
        if(TotalScoutPositions == 0) return false;
        
        UpdateATR();
        
        // Xác định giá hiện tại nếu không được chỉ định
        if(price == 0.0)
        {
            price = IsScoutBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
        }
        
        // Tính step size dựa trên ATR nếu dùng adaptive pyramid
        double step_size = PyramidStepPips * _Point;
        if(UseAdaptivePyramiding && LastATR > 0)
        {
            // Điều chỉnh step size dựa trên ATR
            step_size = LastATR * 0.5; // 50% ATR
        }
        
        // Kiểm tra xem price có đủ xa so với lệnh trước không
        double last_level = ScoutLevels[TotalScoutPositions-1];
        bool valid_pyramid = false;
        
        if(IsScoutBuy)
        {
            // Buy pyramid: giá phải thấp hơn lệnh trước đủ step size
            if(last_level - price >= step_size)
            {
                valid_pyramid = true;
            }
        }
        else
        {
            // Sell pyramid: giá phải cao hơn lệnh trước đủ step size
            if(price - last_level >= step_size)
            {
                valid_pyramid = true;
            }
        }
        
        if(!valid_pyramid) return false;
        
        // Tính kích thước lệnh tăng dần
        double base_lot = NormalizeDouble(BaseLotSize / ScoutLotDivisor, 2);
        if(base_lot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
        {
            base_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        }
        
        double pyramid_lot = NormalizeDouble(base_lot * MathPow(PyramidFactorInc, TotalScoutPositions), 2);
        if(pyramid_lot > BaseLotSize) // Giới hạn không vượt quá BaseLotSize
        {
            pyramid_lot = BaseLotSize;
        }
        
        // Mở lệnh
        CTrade trade;
        trade.SetDeviationInPoints(10); // 1 pip deviation
        
        if(IsScoutBuy)
        {
            if(trade.Buy(pyramid_lot, _Symbol, price, CurrentPyramidSL, CurrentPyramidTP, "Scout Pyramid"))
            {
                // Lưu thông tin lệnh
                ScoutTickets[TotalScoutPositions] = trade.ResultOrder();
                ScoutLevels[TotalScoutPositions] = price;
                TotalScoutPositions++;
                
                return true;
            }
        }
        else
        {
            if(trade.Sell(pyramid_lot, _Symbol, price, CurrentPyramidSL, CurrentPyramidTP, "Scout Pyramid"))
            {
                // Lưu thông tin lệnh
                ScoutTickets[TotalScoutPositions] = trade.ResultOrder();
                ScoutLevels[TotalScoutPositions] = price;
                TotalScoutPositions++;
                
                return true;
            }
        }
        
        return false;
    }
    
    // Kiểm tra và thêm lệnh pyramid tự động dựa trên giá hiện tại
    bool CheckAndAddPyramid()
    {
        // Xác định giá hiện tại
        double current_price = IsScoutBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        // Chỉ xem xét thêm pyramid nếu giá đang di chuyển trái với vị thế
        bool price_moving_against = false;
        
        if(IsScoutBuy && current_price < ScoutLevels[0])
        {
            price_moving_against = true;
        }
        else if(!IsScoutBuy && current_price > ScoutLevels[0])
        {
            price_moving_against = true;
        }
        
        if(!price_moving_against) return false;
        
        // Thử thêm pyramid
        return AddPyramidPosition(current_price);
    }
    
    // Update TP/SL for all positions
    bool UpdateAllPositionsTPSL(double tp, double sl)
    {
        if(TotalScoutPositions == 0) return false;
        
        CurrentPyramidTP = tp;
        CurrentPyramidSL = sl;
        
        CTrade trade;
        bool all_updated = true;
        
        for(int i = 0; i < TotalScoutPositions; i++)
        {
            if(OrderSelect(ScoutTickets[i]))
            {
                if(!trade.OrderModify(ScoutTickets[i], OrderOpenPrice(), sl, tp, 0, 0))
                {
                    Print("Failed to update TP/SL for ticket ", ScoutTickets[i], ". Error: ", GetLastError());
                    all_updated = false;
                }
            }
        }
        
        return all_updated;
    }
    
    // Đóng tất cả Scout positions
    bool CloseAllScoutPositions()
    {
        if(TotalScoutPositions == 0) return true;
        
        CTrade trade;
        bool all_closed = true;
        
        for(int i = 0; i < TotalScoutPositions; i++)
        {
            if(OrderSelect(ScoutTickets[i]))
            {
                if(!trade.OrderClose(ScoutTickets[i], OrderLots(), 0, 10, NULL))
                {
                    Print("Failed to close ticket ", ScoutTickets[i], ". Error: ", GetLastError());
                    all_closed = false;
                }
            }
        }
        
        if(all_closed)
        {
            // Reset trạng thái
            TotalScoutPositions = 0;
            ArrayFill(ScoutTickets, 0, MaxScoutPositions, 0);
            ArrayFill(ScoutLevels, 0, MaxScoutPositions, 0);
        }
        
        return all_closed;
    }
    
    // Đóng một phần Scout positions khi đạt profit target
    bool PartialCloseOnProfit()
    {
        if(TotalScoutPositions == 0) return false;
        
        // Tính tổng lợi nhuận hiện tại (pips)
        double total_profit_pips = CalculateTotalProfitInPips();
        
        // Nếu tổng lợi nhuận đạt ngưỡng
        if(total_profit_pips > PyramidStepPips * 2)
        {
            // Đóng phần trăm đã cấu hình
            return ClosePartialPositions(ProfitClosePercent);
        }
        
        return false;
    }
    
    // Tính tổng lợi nhuận hiện tại (pips)
    double CalculateTotalProfitInPips()
    {
        if(TotalScoutPositions == 0) return 0.0;
        
        double total_profit_pips = 0.0;
        double current_price = IsScoutBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        
        for(int i = 0; i < TotalScoutPositions; i++)
        {
            if(OrderSelect(ScoutTickets[i]))
            {
                double open_price = OrderOpenPrice();
                
                if(IsScoutBuy)
                {
                    total_profit_pips += (current_price - open_price) / _Point;
                }
                else
                {
                    total_profit_pips += (open_price - current_price) / _Point;
                }
            }
        }
        
        return total_profit_pips;
    }
    
    // Đóng phần trăm lệnh (từ cũ đến mới)
    bool ClosePartialPositions(double percent)
    {
        if(TotalScoutPositions == 0) return false;
        if(percent <= 0 || percent > 100) return false;
        
        int positions_to_close = (int)MathCeil(TotalScoutPositions * percent / 100.0);
        if(positions_to_close == 0) positions_to_close = 1;
        
        CTrade trade;
        int closed_count = 0;
        
        // Đóng từ lệnh cũ nhất
        for(int i = 0; i < positions_to_close && i < TotalScoutPositions; i++)
        {
            if(OrderSelect(ScoutTickets[i]))
            {
                if(trade.OrderClose(ScoutTickets[i], OrderLots(), 0, 10, NULL))
                {
                    closed_count++;
                }
            }
        }
        
        // Cập nhật mảng nếu có lệnh đã đóng
        if(closed_count > 0)
        {
            // Dịch các lệnh còn lại lên đầu mảng
            for(int i = 0; i < TotalScoutPositions - closed_count; i++)
            {
                ScoutTickets[i] = ScoutTickets[i + closed_count];
                ScoutLevels[i] = ScoutLevels[i + closed_count];
            }
            
            // Cập nhật số lượng lệnh còn lại
            TotalScoutPositions -= closed_count;
            
            return true;
        }
        
        return false;
    }
    
    // Các hàm getter
    int GetTotalScoutPositions() { return TotalScoutPositions; }
    bool GetIsScoutBuy() { return IsScoutBuy; }
    double GetScoutBaseLot() { return BaseLotSize / ScoutLotDivisor; }
};

// ... existing code ...

//+------------------------------------------------------------------+
//| Wrapper function for MQL4 iMA function                           |
//+------------------------------------------------------------------+
double iMA_MQL4(string symbol, ENUM_TIMEFRAMES timeframe, int period, int ma_shift, 
               int ma_method, ENUM_MQL4_APPLIED_PRICE applied_price, int shift_index)
{
   // Map MQL4 price type to MQL5 ENUM_APPLIED_PRICE
   static ENUM_APPLIED_PRICE price_map[] = {
      SYS_PRICE_OPEN,      // MQL4_PRICE_OPEN
      SYS_PRICE_CLOSE,     // MQL4_PRICE_CLOSE
      SYS_PRICE_HIGH,      // MQL4_PRICE_HIGH
      SYS_PRICE_LOW,       // MQL4_PRICE_LOW
      SYS_PRICE_MEDIAN,    // MQL4_PRICE_MEDIAN
      SYS_PRICE_TYPICAL,   // MQL4_PRICE_TYPICAL
      SYS_PRICE_WEIGHTED   // MQL4_PRICE_WEIGHTED
   };
   
   // Validate applied_price index to prevent array out-of-bounds
   int price_index = (int)applied_price;
   if(price_index < 0 || price_index > 6) {
      Print("iMA_MQL4: Invalid applied_price value: ", applied_price, ", using PRICE_CLOSE");
      price_index = (int)MQL4_PRICE_CLOSE;
   }
   
   // Create indicator handle
   int handle = ::iMA(symbol, timeframe, period, ma_shift, (ENUM_MA_METHOD)ma_method, price_map[price_index]);
   if(handle == INVALID_HANDLE) {
      Print("Error creating MA indicator: ", GetLastError());
      return 0;
   }
   
   // Copy indicator data
   double ma[];
   if(CopyBuffer(handle, 0, shift_index, 1, ma) <= 0) {
      Print("Error copying MA data: ", GetLastError());
      return 0;
   }
   
   return ma[0];
}

//+------------------------------------------------------------------+
//| Wrapper function for MQL4 iHighest function                      |
//+------------------------------------------------------------------+
int iHighest_MQL4(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MQL4_APPLIED_PRICE price_type, int count, int start)
{
   // Map MQL4 price type to MQL5 ENUM_SERIESMODE
   static ENUM_SERIESMODE mode_map[] = {
      MODE_OPEN,    // MQL4_PRICE_OPEN
      MODE_CLOSE,   // MQL4_PRICE_CLOSE
      MODE_HIGH,    // MQL4_PRICE_HIGH
      MODE_LOW,     // MQL4_PRICE_LOW
      MODE_OPEN,    // MQL4_PRICE_MEDIAN (fallback)
      MODE_OPEN,    // MQL4_PRICE_TYPICAL (fallback)
      MODE_OPEN     // MQL4_PRICE_WEIGHTED (fallback)
   };
   
   // Validate price_type index to prevent array out-of-bounds
   int mode_index = (int)price_type;
   if(mode_index < 0 || mode_index > 6) {
      Print("iHighest_MQL4: Invalid price_type value: ", price_type, ", using MODE_HIGH");
      return iHighest(symbol, timeframe, MODE_HIGH, count, start);
   }
   
   // Handle special price types that don't have direct mapping
   if(mode_index >= 4) {
      Print("iHighest_MQL4: Complex price types not directly supported, using MODE_HIGH");
      return iHighest(symbol, timeframe, MODE_HIGH, count, start);
   }
   
   return iHighest(symbol, timeframe, mode_map[mode_index], count, start);
}

//+------------------------------------------------------------------+
//| Wrapper function for MQL4 iLowest function                       |
//+------------------------------------------------------------------+
int iLowest_MQL4(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MQL4_APPLIED_PRICE price_type, int count, int start)
{
   // Map MQL4 price type to MQL5 ENUM_SERIESMODE
   static ENUM_SERIESMODE mode_map[] = {
      MODE_OPEN,    // MQL4_PRICE_OPEN
      MODE_CLOSE,   // MQL4_PRICE_CLOSE
      MODE_HIGH,    // MQL4_PRICE_HIGH
      MODE_LOW,     // MQL4_PRICE_LOW
      MODE_OPEN,    // MQL4_PRICE_MEDIAN (fallback)
      MODE_OPEN,    // MQL4_PRICE_TYPICAL (fallback)
      MODE_OPEN     // MQL4_PRICE_WEIGHTED (fallback)
   };
   
   // Validate price_type index to prevent array out-of-bounds
   int mode_index = (int)price_type;
   if(mode_index < 0 || mode_index > 6) {
      Print("iLowest_MQL4: Invalid price_type value: ", price_type, ", using MODE_LOW");
      return iLowest(symbol, timeframe, MODE_LOW, count, start);
   }
   
   // Handle special price types that don't have direct mapping
   if(mode_index >= 4) {
      Print("iLowest_MQL4: Complex price types not directly supported, using MODE_LOW");
      return iLowest(symbol, timeframe, MODE_LOW, count, start);
   }
   
   return iLowest(symbol, timeframe, mode_map[mode_index], count, start);
}

// ... existing code ...

//+------------------------------------------------------------------+
//| Improved PVSRA Analysis with caching and performance optimizations |
//+------------------------------------------------------------------+
int AnalyzePVSRA(ENUM_TIMEFRAMES timeframe)
{
   if(!UsePVSRA) return 0; // 0 = Neutral, 1 = Bulls, -1 = Bears
   
   // Cache results for better performance
   static int last_result = 0;
   static datetime last_update_time = 0;
   static ENUM_TIMEFRAMES last_timeframe = PERIOD_CURRENT;
   
   // Only update PVSRA analysis on new bar or different timeframe request
   datetime current_bar_time = iTime(Symbol(), timeframe, 0);
   if(last_timeframe == timeframe && last_update_time == current_bar_time && last_update_time != 0)
   {
      return last_result;
   }
   
   // Update cache tracking
   last_update_time = current_bar_time;
   last_timeframe = timeframe;
   
   // Optimize volume data retrieval by using a single array access
   double volumes[10];
   double closes[10];
   double avg_volume = 0;
   
   // Optimization: Get all volumes in one go with CopyTickVolume
   if(CopyTickVolume(Symbol(), timeframe, 0, 10, volumes) <= 0)
   {
      Print("Error getting volume data: ", GetLastError());
      return 0; // Return neutral on error
   }
   
   // Get price data in one go for better performance
   if(CopyClose(Symbol(), timeframe, 0, 10, closes) <= 0)
   {
      Print("Error getting price data: ", GetLastError());
      return 0; // Return neutral on error
   }
   
   // Calculate average volume efficiently
   for(int i = 0; i < 10; i++)
   {
      avg_volume += volumes[i];
   }
   avg_volume /= 10.0;
   
   // Current price metrics
   double current_price = closes[0];
   double prev_price = closes[1];
   double volume_ratio = volumes[0] / (avg_volume > 0 ? avg_volume : 1); // Avoid divide by zero
   
   // Calculate support/resistance levels
   double whole_number = MathFloor(current_price);
   double half_number = whole_number + 0.5;
   
   // Distance to nearest SR level
   double dist_to_whole = MathAbs(current_price - whole_number);
   double dist_to_half = MathAbs(current_price - half_number);
   
   // Determine the nearest SR level
   double sr_threshold = 0.0020;
   bool near_sr_level = (dist_to_whole < sr_threshold || dist_to_half < sr_threshold);
   
   // Calculate price volatility for comparison
   double high_3 = iHigh(Symbol(), timeframe, ArrayMaximum(closes, 0, 3));
   double low_3 = iLow(Symbol(), timeframe, ArrayMinimum(closes, 0, 3));
   double volatility = high_3 - low_3;
   
   int result = 0; // Default neutral
   
   // Enhanced detection logic with volatility context
   if(near_sr_level)
   {
      // Volume climax at support with price moving up = bulls
      if(volume_ratio > RisingThreshold && current_price > prev_price && 
         (dist_to_whole < dist_to_half && current_price > whole_number))
      {
         result = 1; // Bulls - accumulation at support
      }
      // Volume climax at resistance with price moving down = bears
      else if(volume_ratio > RisingThreshold && current_price < prev_price &&
              (dist_to_half < dist_to_whole && current_price < half_number))
      {
         result = -1; // Bears - distribution at resistance
      }
      // Extremely high volume with SR test = smart money interest
      else if(volume_ratio > ClimaxThreshold)
      {
         // Determine direction based on price action after volume spike
         if(current_price > prev_price) result = 1; // Bulls
         else if(current_price < prev_price) result = -1; // Bears
      }
   }
   
   // Detection for areas away from SR levels based on volatility
   if(result == 0 && volatility > 0)
   {
      // High volume relative to volatility suggests strong interest
      double vol_to_range_ratio = volumes[0] / (volatility * 10000.0);
      
      if(vol_to_range_ratio > 5.0) // Significant volume relative to range
      {
         if(current_price > prev_price) result = 1; // Bulls
         else if(current_price < prev_price) result = -1; // Bears
      }
   }
   
   // Cache result
   last_result = result;
   return result;
}

//+------------------------------------------------------------------+
//| Optimized Position Management with Trailing Stop and Breakeven    |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   // Optimize: Use static CTrade instead of creating new objects
   static CTrade trade;
   
   // Pre-declare variables for better performance
   ulong ticket;
   double open_price, current_price, stop_loss, take_profit;
   double profit_pips, new_sl;
   ENUM_POSITION_TYPE position_type;
   
   // Get symbol information once for all calculations
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   string current_symbol = Symbol();
   
   // Process all positions in a single loop
   for(int i = 0; i < PositionsTotal(); i++)
   {
      // Get position ticket
      ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      
      // Only manage positions for current symbol
      if(PositionGetString(POSITION_SYMBOL) != current_symbol) continue;
      
      // Get position details
      position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
      stop_loss = PositionGetDouble(POSITION_SL);
      take_profit = PositionGetDouble(POSITION_TP);
      
      // Calculate profit in pips
      profit_pips = position_type == POSITION_TYPE_BUY ? 
                   (current_price - open_price) / g_point : 
                   (open_price - current_price) / g_point;
      
      // Break Even Logic
      if(BreakEvenEnabled && profit_pips >= BreakEvenProfit)
      {
         // Set breakeven stop
         new_sl = position_type == POSITION_TYPE_BUY ?
                 open_price + BreakEvenPips * g_point :
                 open_price - BreakEvenPips * g_point;
         
         // Only modify if the new SL is better than current
         bool need_modify = (position_type == POSITION_TYPE_BUY && (stop_loss < new_sl || stop_loss == 0)) ||
                           (position_type == POSITION_TYPE_SELL && (stop_loss > new_sl || stop_loss == 0));
         
         if(need_modify)
         {
            trade.PositionModify(ticket, new_sl, take_profit);
            Print("Breakeven: Ticket ", ticket, ", New SL: ", 
                  DoubleToString(new_sl, _Digits));
         }
      }
      
      // Trailing Stop Logic
      if(UseTrailingStop && profit_pips >= TrailingStart)
      {
         // Calculate appropriate trailing stop
         new_sl = position_type == POSITION_TYPE_BUY ?
                 current_price - TrailingStep * g_point :
                 current_price + TrailingStep * g_point;
         
         // Only modify if the trail is meaningful
         bool need_trail = (position_type == POSITION_TYPE_BUY && stop_loss < new_sl - g_point) ||
                          (position_type == POSITION_TYPE_SELL && (stop_loss > new_sl + g_point || stop_loss == 0));
         
         if(need_trail)
         {
            trade.PositionModify(ticket, new_sl, take_profit);
            Print("Trailing: Ticket ", ticket, ", New SL: ", 
                  DoubleToString(new_sl, _Digits));
         }
      }
      
      // Advanced trailing using EMA89
      if(UseEMA89TrailingStop && g_ema89 > 0)
      {
         if(position_type == POSITION_TYPE_BUY && current_price > g_ema89 && profit_pips > 0)
         {
            // Use EMA89 as trailing stop for buy positions
            new_sl = g_ema89 - 5 * g_point; // 5 pip buffer below EMA
            
            if(stop_loss < new_sl - g_point) // Only trail if improving
            {
               trade.PositionModify(ticket, new_sl, take_profit);
               Print("EMA Trail: Ticket ", ticket, ", New SL: ", 
                     DoubleToString(new_sl, _Digits));
            }
         }
         else if(position_type == POSITION_TYPE_SELL && current_price < g_ema89 && profit_pips > 0)
         {
            // Use EMA89 as trailing stop for sell positions
            new_sl = g_ema89 + 5 * g_point; // 5 pip buffer above EMA
            
            if(stop_loss > new_sl + g_point || stop_loss == 0) // Only trail if improving
            {
               trade.PositionModify(ticket, new_sl, take_profit);
               Print("EMA Trail: Ticket ", ticket, ", New SL: ", 
                     DoubleToString(new_sl, _Digits));
            }
         }
      }
      
      // Manage Scout positions with multiple take profits
      if(UseMultipleTPs && IsScoutPosition((int)ticket))
      {
         int type = position_type == POSITION_TYPE_BUY ? OP_BUY : OP_SELL;
         CheckPartialClose((int)ticket, type, open_price, profit_pips);
      }
   }
}

//+------------------------------------------------------------------+
//| Enhanced Market Anomaly Detection System                          |
//+------------------------------------------------------------------+
bool DetectMarketAnomaly()
{
   if(!DetectMarketAnomalies) return false;

   // Only check every N seconds to save resources
   static datetime last_check = 0;
   datetime current_time = TimeCurrent();
   
   // Throttle checks to once every 5 seconds
   if(current_time - last_check < 5 && g_market_anomaly_detected == false) 
      return g_market_anomaly_detected;
   
   last_check = current_time;
   
   // If already in anomaly state, check if it has expired
   if(g_market_anomaly_detected && current_time - g_last_anomaly_time > 1800) // 30 minutes
   {
      Print("Market conditions returned to normal after anomaly");
      g_market_anomaly_detected = false;
      return false;
   }
   
   // Check for abnormal spread conditions
   double current_spread = (double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * Point();
   if(current_spread > g_normal_spread * MaxSpreadMultiplier)
   {
      Print("Abnormal spread detected: ", DoubleToString(current_spread / Point(), 1), 
            " pips (normal: ", DoubleToString(g_normal_spread / Point(), 1), " pips)");
      g_market_anomaly_detected = true;
      g_last_anomaly_time = current_time;
      return true;
   }
   
   // Optimize volatility check by using cached price data when possible
   static double last_high = 0, last_low = 0;
   static datetime last_high_low_update = 0;
   
   // Only update high/low every minute to save resources
   if(current_time - last_high_low_update > 60 || last_high == 0 || last_low == 0)
   {
      int highest_idx = iHighest_MQL4(Symbol(), PERIOD_M5, ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_HIGH, 12, 0);
      int lowest_idx = iLowest_MQL4(Symbol(), PERIOD_M5, ENUM_MQL4_APPLIED_PRICE::MQL4_PRICE_LOW, 12, 0);
      
      last_high = iHigh(Symbol(), PERIOD_M5, highest_idx);
      last_low = iLow(Symbol(), PERIOD_M5, lowest_idx);
      last_high_low_update = current_time;
   }
   
   // Calculate range in pips
   double range_5min = (last_high - last_low) / g_point;
   
   // Check for abnormal volatility
   if(range_5min > AbnormalVolatilityPips)
   {
      Print("Abnormal volatility detected: ", DoubleToString(range_5min, 1), 
            " pips in last 5 minutes");
      g_market_anomaly_detected = true;
      g_last_anomaly_time = current_time;
      return true;
   }
   
   // Additional check: unusual tick volume
   double last_volume = iVolume(Symbol(), PERIOD_M1, 0);
   static double avg_volume = 0;
   
   // Initialize or update average volume
   if(avg_volume == 0)
   {
      double volumes[10];
      if(CopyTickVolume(Symbol(), PERIOD_M1, 1, 10, volumes) > 0)
      {
         double sum = 0;
         for(int i = 0; i < 10; i++) sum += volumes[i];
         avg_volume = sum / 10.0;
      }
   }
   else
   {
      // Continuously update the average (10% new value, 90% old value)
      avg_volume = 0.9 * avg_volume + 0.1 * last_volume;
   }
   
   // Check for volume spike
   if(avg_volume > 0 && last_volume > avg_volume * 5.0)
   {
      Print("Abnormal volume spike detected: ", DoubleToString(last_volume, 0), 
            " (avg: ", DoubleToString(avg_volume, 0), ")");
      g_market_anomaly_detected = true;
      g_last_anomaly_time = current_time;
      return true;
   }
   
   return g_market_anomaly_detected;
}

//+------------------------------------------------------------------+
//| Manage market anomaly response                                    |
//+------------------------------------------------------------------+
void ManageAnomalyResponse()
{
   if(!g_market_anomaly_detected || !DetectMarketAnomalies) return;

   Print("Managing response to market anomaly");
   
   // Use static CTrade instead of creating new objects
   static CTrade trade;
   
   // Pre-declare variables for better performance
   ulong ticket;
   double open_price, current_price, stop_loss, take_profit;
   double profit_pips;
   ENUM_POSITION_TYPE position_type;
   
   // Get symbol information once for all calculations
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   string current_symbol = Symbol();
   
   // Process all positions in a single loop
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      // Get position ticket
      ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      
      // Only manage positions for current symbol
      if(PositionGetString(POSITION_SYMBOL) != current_symbol) continue;
      
      // Get position details
      position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
      stop_loss = PositionGetDouble(POSITION_SL);
      
      // Calculate profit in pips
      profit_pips = position_type == POSITION_TYPE_BUY ? 
                   (current_price - open_price) / g_point : 
                   (open_price - current_price) / g_point;
      
      // Close positions with large losses
      if(profit_pips < -20.0)
      {
         Print("Anomaly response: Closing position with large loss: ", ticket);
         trade.PositionClose(ticket);
         continue;
      }
      
      // Move stop loss to breakeven for profitable positions
      if(profit_pips > 5.0 && ((position_type == POSITION_TYPE_BUY && stop_loss < open_price) || 
                              (position_type == POSITION_TYPE_SELL && (stop_loss > open_price || stop_loss == 0))))
      {
         double new_sl = open_price;
         take_profit = PositionGetDouble(POSITION_TP);
         
         Print("Anomaly response: Moving SL to breakeven for position: ", ticket);
         trade.PositionModify(ticket, new_sl, take_profit);
      }
   }
   
   // Pause new trade entries for 30 minutes
   datetime current_time = TimeCurrent();
   g_last_anomaly_time = current_time;
   
   // Log the anomaly event
   if(SaveTradingLog)
   {
      string log_message = TimeToString(current_time) + ",Market Anomaly Detected,No Trade Zone,30 Minutes";
      int file_handle = FileOpen(LogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(file_handle != INVALID_HANDLE)
      {
         FileWrite(file_handle, log_message);
         FileClose(file_handle);
      }
   }
}

//+------------------------------------------------------------------+
//| Improved Trading Hours Check with Cached Calculations             |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
   if(!LimitTradingHours) return true;
   
   // Cache result to minimize DateTime operations
   static bool last_result = false;
   static datetime last_check_time = 0;
   static int check_interval = 300; // Check every 5 minutes
   
   datetime current_time = TimeCurrent();
   
   // Return cached result if still valid
   if(current_time - last_check_time < check_interval)
      return last_result;
   
   // Update cache time
   last_check_time = current_time;
   
   // Get current hour with timezone consideration
   MqlDateTime dt;
   TimeToStruct(current_time, dt);
   int current_hour = dt.hour;
   
   // Allow trading only during specified hours
   last_result = (current_hour >= TradingStartHour && current_hour < TradingEndHour);
   
   // Additional filters for specific days if needed
   if(last_result && dt.day_of_week == 5) // Friday
   {
      // Maybe limit trading hours on Friday
      if(current_hour >= 16) // After 4 PM on Friday
         last_result = false;
   }
   
   // Check for known high-volume sessions
   bool major_session = false;
   
   // London session (8-16 GMT)
   if(current_hour >= LondonOpenHour && current_hour < LondonOpenHour + SessionOverlapHours)
      major_session = true;
      
   // New York session (13-21 GMT)
   if(current_hour >= NewYorkOpenHour && current_hour < NewYorkOpenHour + SessionOverlapHours)
      major_session = true;
      
   // High-priority override: Always allow during major session overlaps
   if(OnlyTradeMainSessions && !major_session)
      last_result = false;
   
   return last_result;
}

//+------------------------------------------------------------------+
//| Optimized Indicator Update System with Caching                    |
//+------------------------------------------------------------------+
void UpdateIndicators()
{
   static datetime last_update_time = 0;
   static int update_frequency = 2; // Update every 2 seconds
   
   datetime current_time = TimeCurrent();
   
   // Only update when necessary to improve performance
   if(current_time - last_update_time < update_frequency)
      return;
   
   // Calculate price-based EMAs
   
   // Cache indicator handles to avoid repeatedly creating them
   static int dragon_mid_handle = -1;
   static int dragon_high_handle = -1;
   static int dragon_low_handle = -1;
   static int trend_handle = -1;
   static int ma_handle = -1;
   
   // Initialize handles if needed
   if(dragon_mid_handle == -1)
      dragon_mid_handle = iMA(Symbol(), PERIOD_CURRENT, DragonPeriod, 0, MODE_EMA, SYS_PRICE_CLOSE);
   
   if(dragon_high_handle == -1)
      dragon_high_handle = iMA(Symbol(), PERIOD_CURRENT, DragonPeriod, 0, MODE_EMA, SYS_PRICE_HIGH);
   
   if(dragon_low_handle == -1)
      dragon_low_handle = iMA(Symbol(), PERIOD_CURRENT, DragonPeriod, 0, MODE_EMA, SYS_PRICE_LOW);
   
   if(trend_handle == -1)
      trend_handle = iMA(Symbol(), PERIOD_CURRENT, TrendPeriod, 0, MODE_EMA, SYS_PRICE_CLOSE);
   
   if(ma_handle == -1)
      ma_handle = iMA(Symbol(), PERIOD_CURRENT, MAPeriod, 0, MODE_SMA, SYS_PRICE_CLOSE);
   
   // Get data from indicators
   double buffer[1];
   
   if(CopyBuffer(dragon_mid_handle, 0, 0, 1, buffer) > 0)
      g_dragon_mid = buffer[0];
   
   if(CopyBuffer(dragon_high_handle, 0, 0, 1, buffer) > 0)
      g_dragon_high = buffer[0];
   
   if(CopyBuffer(dragon_low_handle, 0, 0, 1, buffer) > 0)
      g_dragon_low = buffer[0];
   
   if(CopyBuffer(trend_handle, 0, 0, 1, buffer) > 0) {
      g_trend = buffer[0];
      g_ema89 = g_trend; // Use the same value for EMA89
   }
   
   if(CopyBuffer(ma_handle, 0, 0, 1, buffer) > 0)
      g_ma = buffer[0];
   
   // Update timestamp
   last_update_time = current_time;
   
   // Count positions (should be done on every tick)
   CountOpenPositions();
}

//+------------------------------------------------------------------+
//| Enhanced Lot Size Calculator with Smart Risk Management           |
//+------------------------------------------------------------------+
double CalculateLotSize(int type)
{
   // Use fixed lot size if auto calculation is disabled
   if(!AutoLotSize)
      return FixedLotSize;
   
   // Calculate risk-based lot size
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amount = balance * RiskPercent / 100.0;
   
   // Get symbol properties (use cache if available)
   static double tick_value = 0;
   static double tick_size = 0;
   static double min_lot = 0;
   static double max_lot = 0;
   static double lot_step = 0;
   static string last_symbol = "";
   
   // Only update if symbol changes (rare) or first run
   string current_symbol = Symbol();
   if(current_symbol != last_symbol || tick_value == 0)
   {
      tick_value = SymbolInfoDouble(current_symbol, SYMBOL_TRADE_TICK_VALUE);
      tick_size = SymbolInfoDouble(current_symbol, SYMBOL_TRADE_TICK_SIZE);
      min_lot = SymbolInfoDouble(current_symbol, SYMBOL_VOLUME_MIN);
      max_lot = SymbolInfoDouble(current_symbol, SYMBOL_VOLUME_MAX);
      lot_step = SymbolInfoDouble(current_symbol, SYMBOL_VOLUME_STEP);
      last_symbol = current_symbol;
   }
   
   // Pip value in account currency
   double pip_value = tick_value * g_point / tick_size;
   
   // Calculate potential loss in pips
   double potential_loss_pips = StopLoss;
   
   // Account for current market volatility
   static double avg_atr = 0;
   if(avg_atr == 0)
   {
      // Initialize ATR for volatility awareness
      int atr_handle = iATR(current_symbol, PERIOD_CURRENT, 14);
      if(atr_handle != INVALID_HANDLE)
      {
         double atr_buffer[1];
         if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
            avg_atr = atr_buffer[0] / g_point;
      }
   }
   
   // Adjust risk based on volatility if ATR is available
   if(avg_atr > 0)
   {
      double volatility_ratio = StopLoss / avg_atr;
      
      // Reduce risk in high volatility conditions
      if(volatility_ratio < 0.8) // Tight stop relative to volatility
         risk_amount *= 0.8; // Reduce risk by 20%
      else if(volatility_ratio > 1.5) // Wide stop relative to volatility
         risk_amount *= 1.1; // Increase risk by 10%
   }
   
   // Calculate risk-based position size
   double lots = risk_amount / (potential_loss_pips * pip_value);
   
   // Round to nearest lot step
   lots = MathFloor(lots / lot_step) * lot_step;
   
   // Apply position sizing modifiers based on market conditions
   
   // 1. Reduce size during news periods
   if(NewsFilter && g_news_active && ReduceSizePostNews)
   {
      lots = lots * PostNewsSizePercent / 100.0;
   }
   
   // 2. Adjust size based on win/loss streak (optional enhancement)
   static int consecutive_wins = 0;
   static int consecutive_losses = 0;
   
   // Increase size slightly on win streaks, decrease on loss streaks
   if(consecutive_wins > 2)
      lots *= 1.1; // 10% increase after 3 consecutive wins
   else if(consecutive_losses > 1)
      lots *= 0.8; // 20% decrease after 2 consecutive losses
   
   // 3. Prop firm risk controls
   if(PropFirmMode)
   {
      // Calculate exposure percentage
      double current_exposure = 0;
      
      // Iterate through open positions to calculate exposure
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket != 0 && PositionSelectByTicket(ticket))
         {
            if(PositionGetString(POSITION_SYMBOL) == current_symbol)
            {
               double position_lots = PositionGetDouble(POSITION_VOLUME);
               current_exposure += position_lots * potential_loss_pips * pip_value / balance * 100.0;
            }
         }
      }
      
      // Limit new position size if near max exposure
      if(current_exposure + (lots * potential_loss_pips * pip_value / balance * 100.0) > MaxOpenRisk)
      {
         double max_lots = (MaxOpenRisk - current_exposure) * balance / (100.0 * potential_loss_pips * pip_value);
         max_lots = MathFloor(max_lots / lot_step) * lot_step;
         
         if(max_lots < lots)
            lots = max_lots;
      }
   }
   
   // Apply limits
   if(lots < min_lot) lots = min_lot;
   if(lots > max_lot) lots = max_lot;
   
   // Special adjustment for Scout positions
   if(UseScoutPositionBuilding && g_scout_positions_count > 0)
   {
      // Reduce first position size to allow for scaling in
      if(g_scout_positions_count == 0)
         lots *= 0.7; // Start with 70% for first position
   }
   
   return lots;
}

//+------------------------------------------------------------------+
//| Load news calendar from external file                             |
//+------------------------------------------------------------------+
bool LoadNewsCalendar()
{
   if(!UseExternalNewsCalendar) return false;
   
   string file_path = NewsCalendarFile;
   
   // Reset news array
   g_news_count = 0;
   ArrayFree(g_upcoming_news);
   
   // Try to open the news file
   int file_handle = FileOpen(file_path, FILE_READ|FILE_CSV|FILE_ANSI, ',');
   if(file_handle == INVALID_HANDLE)
   {
      Print("Failed to open news calendar file: ", file_path, ", Error: ", GetLastError());
      return false;
   }
   
   // Read header line
   if(FileIsEnding(file_handle))
   {
      FileClose(file_handle);
      Print("News calendar file is empty");
      return false;
   }
   
   string header = FileReadString(file_handle);
   
   // Read news events
   while(!FileIsEnding(file_handle))
   {
      string line = FileReadString(file_handle);
      string parts[];
      int parts_count = StringSplit(line, ',', parts);
      
      if(parts_count >= 4)
      {
         // Resize the news array
         g_news_count++;
         ArrayResize(g_upcoming_news, g_news_count);
         
         // Parse news event data
         g_upcoming_news[g_news_count-1].title = parts[0];
         g_upcoming_news[g_news_count-1].currency = parts[1];
         g_upcoming_news[g_news_count-1].time = StringToTime(parts[2]);
         g_upcoming_news[g_news_count-1].impact = (int)StringToInteger(parts[3]);
         
         Print("Loaded news event: ", parts[0], ", Impact: ", parts[3], ", Time: ", parts[2]);
      }
   }
   
   FileClose(file_handle);
   Print("Loaded ", g_news_count, " news events from calendar");
   return g_news_count > 0;
}

//+------------------------------------------------------------------+
//| Check for news impact based on current time                       |
//+------------------------------------------------------------------+
bool CheckNewsImpact()
{
   if(!NewsFilter) return false; // NewsFilter should be one of the existing input parameters
   
   datetime current_time = TimeCurrent();
   string current_symbol = Symbol();
   string base_currency = StringSubstr(current_symbol, 0, 3);
   string quote_currency = StringSubstr(current_symbol, 3, 3);
   
   // Initialize as not in news period
   g_news_active = false;
   g_news_impact = 0;
   g_last_news_time = 0;
   
   // Load news calendar if needed and using external calendar
   static datetime last_calendar_load = 0;
   if(UseExternalNewsCalendar && (current_time - last_calendar_load > 3600 || g_news_count == 0))
   {
      LoadNewsCalendar();
      last_calendar_load = current_time;
   }
   
   // Check upcoming news from external calendar
   if(UseExternalNewsCalendar && g_news_count > 0)
   {
      for(int i = 0; i < g_news_count; i++)
      {
         // Check if news affects our currency pair
         if(g_upcoming_news[i].currency == base_currency || g_upcoming_news[i].currency == quote_currency)
         {
            // Calculate time difference to news in minutes
            int minutes_to_news = (int)((g_upcoming_news[i].time - current_time) / 60);
            int minutes_after_news = (int)((current_time - g_upcoming_news[i].time) / 60);
            
            // Check if within news impact window
            if(minutes_to_news >= 0 && minutes_to_news <= MinutesBeforeNews)
            {
               // Upcoming news
               g_news_active = true;
               g_news_impact = MathMax(g_news_impact, g_upcoming_news[i].impact);
               g_last_news_time = g_upcoming_news[i].time;
               
               Print("News alert: ", g_upcoming_news[i].title, 
                     " (Impact: ", g_news_impact, ") in ", 
                     minutes_to_news, " minutes");
               break;
            }
            else if(minutes_after_news >= 0 && minutes_after_news <= PostNewsWaitTime)
            {
               // Recent news
               g_news_active = true;
               g_news_impact = MathMax(g_news_impact, g_upcoming_news[i].impact);
               g_last_news_time = g_upcoming_news[i].time;
               
               Print("Post-news period: ", g_upcoming_news[i].title, 
                     " (Impact: ", g_news_impact, ") ", 
                     minutes_after_news, " minutes ago");
               break;
            }
         }
      }
   }
   else
   {
      // Simple built-in news filter - just check if we're in post-news period
      if(g_last_news_time > 0 && (current_time - g_last_news_time) / 60 <= PostNewsWaitTime)
      {
         g_news_active = true;
         Print("In post-news waiting period (", (int)((current_time - g_last_news_time) / 60), 
               " of ", PostNewsWaitTime, " minutes)");
      }
   }
   
   return g_news_active;
}

//+------------------------------------------------------------------+
//| Check if a position is a Scout position                           |
//+------------------------------------------------------------------+
bool IsScoutPosition(int ticket)
{
   // Check position comment to see if it's a Scout position
   if(!PositionSelectByTicket(ticket)) return false;
   
   string comment = PositionGetString(POSITION_COMMENT);
   return StringFind(comment, "Scout") >= 0;
}

//+------------------------------------------------------------------+
//| Execute Scout Position Building                                   |
//+------------------------------------------------------------------+
bool ExecuteScoutPositionBuilding(int signal_type)
{
   if(!UseScoutPositionBuilding) return false;
   if(g_scout_positions_count >= MaxScoutPositions) return false;
   
   // Don't build positions during anomalies or news
   if(g_market_anomaly_detected || g_news_active) return false;
   
   // Use static objects for better performance
   static CTrade trade;
   string current_symbol = Symbol();
   
   // Check current trend and market makers direction
   bool bullish_condition = signal_type == OP_BUY && g_mm_bullish;
   bool bearish_condition = signal_type == OP_SELL && !g_mm_bullish;
   
   // Ensure we're trading in the direction of market makers
   if(!bullish_condition && !bearish_condition) return false;
   
   // Get price info
   double ask = SymbolInfoDouble(current_symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(current_symbol, SYMBOL_BID);
   
   // Calculate support/resistance levels
   double support = 0, resistance = 0;
   
   // For simplicity, use dragon bands as support/resistance
   if(g_dragon_high > 0 && g_dragon_low > 0)
   {
      support = g_dragon_low;
      resistance = g_dragon_high;
   }
   
   // Calculate stop loss
   double stop_loss = 0;
   if(signal_type == OP_BUY)
   {
      stop_loss = support - StopLoss * g_point;
   }
   else
   {
      stop_loss = resistance + StopLoss * g_point;
   }
   
   // Calculate take profit levels based on R:R ratio
   double take_profit = 0;
   double risk = 0;
   
   if(signal_type == OP_BUY)
   {
      risk = ask - stop_loss;
      
      // Store TP levels for partial closing
      g_scout_tp_levels[0] = ask + risk * TP1Ratio; // TP1
      g_scout_tp_levels[1] = ask + risk * TP2Ratio; // TP2
      g_scout_tp_levels[2] = ask + risk * TP3Ratio; // TP3
      
      // Set the final TP level as position TP
      take_profit = g_scout_tp_levels[2];
   }
   else
   {
      risk = stop_loss - bid;
      
      // Store TP levels for partial closing
      g_scout_tp_levels[0] = bid - risk * TP1Ratio; // TP1
      g_scout_tp_levels[1] = bid - risk * TP2Ratio; // TP2
      g_scout_tp_levels[2] = bid - risk * TP3Ratio; // TP3
      
      // Set the final TP level as position TP
      take_profit = g_scout_tp_levels[2];
   }
   
   // Adjust lot size based on position count
   double lot_size = CalculateLotSize(signal_type);
   
   // Scale up positions
   if(g_scout_positions_count > 0)
   {
      lot_size *= (1.0 + 0.2 * g_scout_positions_count); // Increase by 20% for each additional position
   }
   
   // Execute the trade
   bool result = false;
   
   trade.SetExpertMagicNumber(123456); // Use a consistent magic number
   
   if(signal_type == OP_BUY)
   {
      result = trade.Buy(lot_size, current_symbol, 0, stop_loss, take_profit, "Scout_" + IntegerToString(g_scout_positions_count + 1));
   }
   else
   {
      result = trade.Sell(lot_size, current_symbol, 0, stop_loss, take_profit, "Scout_" + IntegerToString(g_scout_positions_count + 1));
   }
   
   if(result)
   {
      g_scout_positions_count++;
      g_tp2_hit = false;
      Print("Scout position #", g_scout_positions_count, " opened. TP1: ", 
            DoubleToString(g_scout_tp_levels[0], _Digits), 
            ", TP2: ", DoubleToString(g_scout_tp_levels[1], _Digits),
            ", TP3: ", DoubleToString(g_scout_tp_levels[2], _Digits));
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Check partial close conditions for Scout positions                |
//+------------------------------------------------------------------+
void CheckPartialClose(int ticket, int type, double open_price, double profit_pips)
{
   if(!UseMultipleTPs) return;
   if(!PositionSelectByTicket(ticket)) return;
   
   double current_volume = PositionGetDouble(POSITION_VOLUME);
   double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
   string symbol = PositionGetString(POSITION_SYMBOL);
   
   // Calculate volumes for each TP level
   double tp1_volume = current_volume * TP1Percent / 100.0;
   double tp2_volume = current_volume * TP2Percent / 100.0;
   
   // Minimum volume check
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   if(tp1_volume < min_lot || tp2_volume < min_lot) return;
   
   static CTrade trade;
   
   // Check if price has reached TP1 level
   bool tp1_reached = false;
   bool tp2_reached = false;
   
   if(type == OP_BUY)
   {
      tp1_reached = current_price >= g_scout_tp_levels[0];
      tp2_reached = current_price >= g_scout_tp_levels[1];
   }
   else
   {
      tp1_reached = current_price <= g_scout_tp_levels[0];
      tp2_reached = current_price <= g_scout_tp_levels[1];
   }
   
   // TP1: Close first portion and move SL to breakeven
   if(tp1_reached)
   {
      // Partial close at TP1
      if(trade.PositionClosePartial(ticket, tp1_volume))
      {
         Print("TP1 reached for ticket ", ticket, ". Closed ", DoubleToString(tp1_volume, 2), " lots");
         
         // Move stop loss to breakeven
         double new_sl = open_price;
         double take_profit = PositionGetDouble(POSITION_TP);
         
         trade.PositionModify(ticket, new_sl, take_profit);
         Print("Stop loss moved to breakeven for ticket ", ticket);
      }
   }
   
   // TP2: Close second portion and activate trailing stop
   if(tp2_reached && !g_tp2_hit)
   {
      // Partial close at TP2
      if(trade.PositionClosePartial(ticket, tp2_volume))
      {
         Print("TP2 reached for ticket ", ticket, ". Closed ", DoubleToString(tp2_volume, 2), " lots");
         
         // Activate trailing stop for remainder
         g_tp2_hit = true;
         
         // Let the trailing stop function handle the rest
      }
   }
}

//+------------------------------------------------------------------+
//| Adjust take profit levels based on PVSRA signals                  |
//+------------------------------------------------------------------+
void AdjustTakeProfitOnPVSRA(int ticket)
{
   if(!AdjustTPsOnVolume) return;
   if(!PositionSelectByTicket(ticket)) return;
   
   // Get position details
   ENUM_POSITION_TYPE position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double stop_loss = PositionGetDouble(POSITION_SL);
   double take_profit = PositionGetDouble(POSITION_TP);
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   
   // Get PVSRA analysis result
   int pvsra_result = AnalyzePVSRA(PERIOD_CURRENT);
   
   // Only adjust if we have a clear signal
   if(pvsra_result == 0) return;
   
   // Validate our position direction against PVSRA signal
   bool adjust_needed = (position_type == POSITION_TYPE_BUY && pvsra_result > 0) || 
                       (position_type == POSITION_TYPE_SELL && pvsra_result < 0);
   
   if(!adjust_needed) return;
   
   // Calculate risk in price
   double risk = position_type == POSITION_TYPE_BUY ? 
               (open_price - stop_loss) : 
               (stop_loss - open_price);
   
   // Only proceed if we have a valid risk value
   if(risk <= 0) return;
   
   // Increase TP targets on strong volume
   double new_tp = 0;
   
   if(position_type == POSITION_TYPE_BUY)
   {
      // Extend TP3 by 20% for bullish PVSRA signal
      new_tp = open_price + (risk * TP3Ratio * 1.2);
      
      // Update the stored TP levels
      g_scout_tp_levels[2] = new_tp;
   }
   else
   {
      // Extend TP3 by 20% for bearish PVSRA signal
      new_tp = open_price - (risk * TP3Ratio * 1.2);
      
      // Update the stored TP levels
      g_scout_tp_levels[2] = new_tp;
   }
   
   // Only modify if the new TP is better than current
   bool should_modify = (position_type == POSITION_TYPE_BUY && new_tp > take_profit) ||
                      (position_type == POSITION_TYPE_SELL && new_tp < take_profit);
   
   if(should_modify)
   {
      static CTrade trade;
      trade.PositionModify(ticket, stop_loss, new_tp);
      Print("Adjusted TP on PVSRA signal for ticket ", ticket, ". New TP: ", DoubleToString(new_tp, _Digits));
   }
}

//+------------------------------------------------------------------+
//| Multi-timeframe analysis function                                 |
//+------------------------------------------------------------------+
void PerformMultiTimeframeAnalysis()
{
   if(!UseMultiTimeframeAnalysis) return;
   
   // Only update periodically to save resources
   datetime current_time = TimeCurrent();
   
   // Update MTF analysis once every hour
   if(current_time - g_last_mtf_analysis < 3600) return;
   
   g_last_mtf_analysis = current_time;
   Print("Performing multi-timeframe analysis...");
   
   // Analyze D1 timeframe
   g_mtf_bullish_d1 = AnalyzeTimeframe(PERIOD_D1);
   
   // Analyze H4 timeframe
   g_mtf_bullish_h4 = AnalyzeTimeframe(PERIOD_H4);
   
   // Analyze H1 timeframe
   g_mtf_bullish_h1 = AnalyzeTimeframe(PERIOD_H1);
   
   // Log results
   string log_message = TimeToString(current_time) + 
                        ",MTF Analysis,D1:" + (g_mtf_bullish_d1 ? "Bullish" : "Bearish") + 
                        ",H4:" + (g_mtf_bullish_h4 ? "Bullish" : "Bearish") + 
                        ",H1:" + (g_mtf_bullish_h1 ? "Bullish" : "Bearish");
   
   Print("MTF Analysis: D1=" + (g_mtf_bullish_d1 ? "Bullish" : "Bearish") + 
         ", H4=" + (g_mtf_bullish_h4 ? "Bullish" : "Bearish") + 
         ", H1=" + (g_mtf_bullish_h1 ? "Bullish" : "Bearish"));
   
   // Save to log file
   if(SaveTradingLog)
   {
      int file_handle = FileOpen(LogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(file_handle != INVALID_HANDLE)
      {
         FileWrite(file_handle, log_message);
         FileClose(file_handle);
      }
   }
}

//+------------------------------------------------------------------+
//| Analyze trend direction for a specific timeframe                  |
//+------------------------------------------------------------------+
bool AnalyzeTimeframe(ENUM_TIMEFRAMES timeframe)
{
   // Initialize handles for technical indicators
   int ma_fast_handle = iMA(Symbol(), timeframe, 20, 0, MODE_EMA, SYS_PRICE_CLOSE);
   int ma_slow_handle = iMA(Symbol(), timeframe, 50, 0, MODE_EMA, SYS_PRICE_CLOSE);
   
   if(ma_fast_handle == INVALID_HANDLE || ma_slow_handle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles: ", GetLastError());
      return false;
   }
   
   // Fetch indicator values
   double ma_fast[3] = {0};
   double ma_slow[3] = {0};
   
   if(CopyBuffer(ma_fast_handle, 0, 0, 3, ma_fast) <= 0 ||
      CopyBuffer(ma_slow_handle, 0, 0, 3, ma_slow) <= 0)
   {
      Print("Error copying indicator data: ", GetLastError());
      return false;
   }
   
   // Release handles after use
   IndicatorRelease(ma_fast_handle);
   IndicatorRelease(ma_slow_handle);
   
   // Analyze trend based on moving averages
   bool ma_bullish = ma_fast[0] > ma_slow[0]; // Fast MA above slow MA
   bool ma_rising = ma_fast[0] > ma_fast[1];  // Fast MA rising
   
   // Get additional price action data
   double close[3];
   double high[3];
   double low[3];
   
   if(CopyClose(Symbol(), timeframe, 0, 3, close) <= 0 ||
      CopyHigh(Symbol(), timeframe, 0, 3, high) <= 0 ||
      CopyLow(Symbol(), timeframe, 0, 3, low) <= 0)
   {
      Print("Error copying price data: ", GetLastError());
      return false;
   }
   
   // Check for higher highs and higher lows (bullish)
   bool higher_highs = high[0] > high[1] && high[1] > high[2];
   bool higher_lows = low[0] > low[1] && low[1] > low[2];
   
   // Alternatively, check for lower highs and lower lows (bearish)
   bool lower_highs = high[0] < high[1] && high[1] < high[2];
   bool lower_lows = low[0] < low[1] && low[1] < low[2];
   
   // Combine all signals
   bool bullish = ma_bullish && ma_rising && (higher_highs || higher_lows);
   bool bearish = !ma_bullish && !ma_rising && (lower_highs || lower_lows);
   
   // If signals are conflicting, prioritize MA direction
   if(!bullish && !bearish)
   {
      bullish = ma_bullish;
   }
   
   return bullish;
}

//+------------------------------------------------------------------+
//| Daily market analysis                                             |
//+------------------------------------------------------------------+
void PerformDailyAnalysis()
{
   if(!DailyMarketAnalysis) return;
   
   // Check if a new day has started
   datetime current_time = TimeCurrent();
   MqlDateTime time_struct;
   TimeToStruct(current_time, time_struct);
   
   // New day has begun
   if(g_day_start_time == 0 || (current_time - g_day_start_time) > 86400) // 24 hours
   {
      g_day_start_time = current_time;
      
      // Reset daily high/low
      double high[1], low[1];
      CopyHigh(Symbol(), PERIOD_D1, 0, 1, high);
      CopyLow(Symbol(), PERIOD_D1, 0, 1, low);
      
      g_daily_high = high[0];
      g_daily_low = low[0];
      
      // Calculate normal spread (for anomaly detection)
      int count = 10;
      double spread_sum = 0;
      for(int i = 0; i < count; i++)
      {
         spread_sum += (double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * Point();
         Sleep(200); // Wait 200ms between readings
      }
      g_normal_spread = spread_sum / count;
      
      // Log the start of a new trading day
      string log_message = TimeToString(current_time) + 
                          ",Daily Analysis,Day: " + IntegerToString(time_struct.day) +
                          ",StartBalance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
      
      // Update the session start balance
      g_session_start_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      // Update week start balance if Monday
      if(time_struct.day_of_week == 1) // Monday
      {
         g_week_start_balance = g_session_start_balance;
      }
      
      Print("New trading day started: ", TimeToString(current_time));
      
      // Save to log file
      if(SaveTradingLog)
      {
         int file_handle = FileOpen(LogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
         if(file_handle != INVALID_HANDLE)
         {
            FileWrite(file_handle, log_message);
            FileClose(file_handle);
         }
      }
      
      // Also perform MTF analysis at the start of the day
      PerformMultiTimeframeAnalysis();
   }
}

//+------------------------------------------------------------------+
//| Update trading log with performance metrics                       |
//+------------------------------------------------------------------+
void UpdateTradingLog()
{
   if(!SaveTradingLog) return;
   
   static datetime last_log_update = 0;
   datetime current_time = TimeCurrent();
   
   // Update log every hour
   if(current_time - last_log_update < 3600) return;
   
   last_log_update = current_time;
   
   // Calculate performance metrics
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double daily_pnl = current_balance - g_session_start_balance;
   double weekly_pnl = current_balance - g_week_start_balance;
   
   // Count current open positions
   int total_positions = PositionsTotal();
   g_total_buy = 0;
   g_total_sell = 0;
   
   for(int i = 0; i < total_positions; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == Symbol())
      {
         ENUM_POSITION_TYPE position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(position_type == POSITION_TYPE_BUY)
            g_total_buy++;
         else
            g_total_sell++;
      }
   }
   
   // Prepare log message
   string log_message = TimeToString(current_time) + 
                      ",Performance,Daily P/L: " + DoubleToString(daily_pnl, 2) +
                      ",Weekly P/L: " + DoubleToString(weekly_pnl, 2) +
                      ",Buy Positions: " + IntegerToString(g_total_buy) +
                      ",Sell Positions: " + IntegerToString(g_total_sell);
   
   // Save to log file
   int file_handle = FileOpen(LogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(file_handle != INVALID_HANDLE)
   {
      FileWrite(file_handle, log_message);
      FileClose(file_handle);
   }
}

//+------------------------------------------------------------------+
//| OnTick function - Main EA logic                                   |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update technical indicators
   UpdateIndicators();
   
   // Perform daily analysis (will only execute once per day)
   PerformDailyAnalysis();
   
   // Check for market anomalies
   if(DetectMarketAnomaly())
   {
      ManageAnomalyResponse();
      return; // Skip trading logic during anomalies
   }
   
   // Check for news impact
   if(CheckNewsImpact())
   {
      Print("News impact detected - trading with caution");
      // Trading continues but with reduced size
   }
   
   // Check if within allowed trading hours
   if(!IsWithinTradingHours())
   {
      return; // Skip trading outside of allowed hours
   }
   
   // Periodically update multi-timeframe analysis
   PerformMultiTimeframeAnalysis();
   
   // Log trading performance periodically
   UpdateTradingLog();
   
   // Manage existing positions
   ManageOpenPositions();
   
   // Generate trading signals
   int signal = GenerateSignal();
   
   // Execute trades based on signal
   if(signal == OP_BUY)
   {
      // Check for multi-timeframe confirmation
      if(g_mtf_bullish_h1 && g_mtf_bullish_h4)
      {
         // For regular trades
         ExecuteOrder(OP_BUY);
         
         // For scout position building
         ExecuteScoutPositionBuilding(OP_BUY);
      }
   }
   else if(signal == OP_SELL)
   {
      // Check for multi-timeframe confirmation
      if(!g_mtf_bullish_h1 && !g_mtf_bullish_h4)
      {
         // For regular trades
         ExecuteOrder(OP_SELL);
         
         // For scout position building
         ExecuteScoutPositionBuilding(OP_SELL);
      }
   }
   
   // Process existing scout positions with PVSRA
   ProcessScoutPositions();
}

//+------------------------------------------------------------------+
//| Process existing scout positions with volume analysis             |
//+------------------------------------------------------------------+
void ProcessScoutPositions()
{
   if(!UseScoutPositionBuilding) return;
   
   // Check MM direction for possibly closing positions
   int pvsra_signal = AnalyzePVSRA(PERIOD_CURRENT);
   
   // MM direction changed - consider closing scout positions
   if((pvsra_signal > 0 && !g_mm_bullish) || (pvsra_signal < 0 && g_mm_bullish))
   {
      // Update MM direction
      g_mm_bullish = pvsra_signal > 0;
      Print("Market Makers direction changed to: ", g_mm_bullish ? "Bullish" : "Bearish");
      
      // Consider closing scout positions that are against new MM direction
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket != 0 && PositionSelectByTicket(ticket))
         {
            if(IsScoutPosition((int)ticket))
            {
               ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               
               // Close positions against new MM direction
               if((pos_type == POSITION_TYPE_BUY && !g_mm_bullish) || 
                  (pos_type == POSITION_TYPE_SELL && g_mm_bullish))
               {
                  static CTrade trade;
                  trade.PositionClose(ticket);
                  Print("Closed scout position due to MM direction change: ", ticket);
               }
               else
               {
                  // For positions in new MM direction, adjust TP based on volume
                  AdjustTakeProfitOnPVSRA((int)ticket);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Initialize variables and settings                                 |
//+------------------------------------------------------------------+
void InitializeVariables()
{
   // Initialize global variables
   g_point = Point();
   g_normal_spread = (double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * Point();
   g_market_anomaly_detected = false;
   g_last_anomaly_time = 0;
   g_news_active = false;
   g_news_impact = 0;
   g_last_news_time = 0;
   g_session_start_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_week_start_balance = g_session_start_balance;
   g_day_start_time = 0;
   g_last_mtf_analysis = 0;
   g_mm_bullish = false;
   g_scout_positions_count = 0;
   g_tp2_hit = false;
   
   // Initialize arrays
   ArrayResize(g_scout_tp_levels, 3);
   ArrayInitialize(g_scout_tp_levels, 0);
   
   // Initialize multi-timeframe flags
   g_mtf_bullish_d1 = false;
   g_mtf_bullish_h4 = false;
   g_mtf_bullish_h1 = false;
   
   Print("Variables initialized");
}

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize variables
   InitializeVariables();
   
   // Load news calendar if using external source
   if(UseExternalNewsCalendar)
   {
      LoadNewsCalendar();
   }
   
   // Perform initial daily analysis
   PerformDailyAnalysis();
   
   // Perform initial multi-timeframe analysis
   if(UseMultiTimeframeAnalysis)
   {
      PerformMultiTimeframeAnalysis();
   }
   
   // Count open positions
   CountOpenPositions();
   
   Print("Sonic R Professional Expert Advisor initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Count open positions for the current symbol                       |
//+------------------------------------------------------------------+
void CountOpenPositions()
{
   g_total_buy = 0;
   g_total_sell = 0;
   g_scout_positions_count = 0;
   
   string current_symbol = Symbol();
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == current_symbol)
      {
         ENUM_POSITION_TYPE position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         
         if(position_type == POSITION_TYPE_BUY)
            g_total_buy++;
         else
            g_total_sell++;
         
         // Count scout positions
         if(IsScoutPosition((int)ticket))
            g_scout_positions_count++;
      }
   }
}

//+------------------------------------------------------------------+
//| Generate trading signal based on indicators and market conditions |
//+------------------------------------------------------------------+
int GenerateSignal()
{
   // If we already have too many positions, don't generate new signals
   if(g_total_buy + g_total_sell >= MaxOpenPositions) return -1;
   
   // Default is no signal
   int signal = -1;
   
   // Check Dragon indicator for trends
   bool dragon_bullish = g_dragon_mid > g_dragon_mid && g_trend > 0;
   bool dragon_bearish = g_dragon_mid < g_dragon_mid && g_trend < 0;
   
   // Check price action
   double close = iClose(Symbol(), PERIOD_CURRENT, 0);
   double prev_close = iClose(Symbol(), PERIOD_CURRENT, 1);
   
   // Check PVSRA signal
   int pvsra_signal = AnalyzePVSRA(PERIOD_CURRENT);
   
   // Generate buy signal
   if(dragon_bullish && close > prev_close && pvsra_signal > 0)
   {
      signal = OP_BUY;
   }
   // Generate sell signal
   else if(dragon_bearish && close < prev_close && pvsra_signal < 0)
   {
      signal = OP_SELL;
   }
   
   // Apply multi-timeframe filter if enabled
   if(UseMultiTimeframeAnalysis && signal != -1)
   {
      // For buy signals, confirm with higher timeframes
      if(signal == OP_BUY && (!g_mtf_bullish_h1 || !g_mtf_bullish_h4))
      {
         signal = -1; // Cancel signal if higher timeframes are not aligned
      }
      // For sell signals, confirm with higher timeframes
      else if(signal == OP_SELL && (g_mtf_bullish_h1 || g_mtf_bullish_h4))
      {
         signal = -1; // Cancel signal if higher timeframes are not aligned
      }
   }
   
   // Do not trade during news or market anomalies
   if(g_news_active || g_market_anomaly_detected)
   {
      signal = -1;
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| Execute order based on signal type                                |
//+------------------------------------------------------------------+
bool ExecuteOrder(int signal_type)
{
   string current_symbol = Symbol();
   static CTrade trade;
   
   // Calculate lot size based on risk parameters
   double lot_size = CalculateLotSize(signal_type);
   
   // Reduce lot size if in post-news period
   if(g_news_active && ReduceSizePostNews)
   {
      lot_size = lot_size * PostNewsSizePercent / 100.0;
   }
   
   // Check account margin before placing trade
   if(!CheckFreeMargin(lot_size, signal_type))
   {
      Print("Insufficient margin for trade execution");
      return false;
   }
   
   // Get price levels
   double ask = SymbolInfoDouble(current_symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(current_symbol, SYMBOL_BID);
   
   // Calculate stop loss and take profit levels
   double stop_loss = 0, take_profit = 0;
   
   if(signal_type == OP_BUY)
   {
      stop_loss = ask - StopLoss * g_point;
      take_profit = ask + TakeProfit * g_point;
   }
   else
   {
      stop_loss = bid + StopLoss * g_point;
      take_profit = bid - TakeProfit * g_point;
   }
   
   // Execute the trade
   bool result = false;
   
   if(signal_type == OP_BUY)
   {
      result = trade.Buy(lot_size, current_symbol, 0, stop_loss, take_profit, "Sonic_R_Pro");
   }
   else
   {
      result = trade.Sell(lot_size, current_symbol, 0, stop_loss, take_profit, "Sonic_R_Pro");
   }
   
   if(result)
   {
      Print("Order executed: ", signal_type == OP_BUY ? "BUY" : "SELL", 
            ", Lot Size: ", DoubleToString(lot_size, 2),
            ", SL: ", DoubleToString(stop_loss, _Digits),
            ", TP: ", DoubleToString(take_profit, _Digits));
   }
   else
   {
      Print("Order execution failed: ", GetLastError());
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Check if there is enough free margin for the trade                |
//+------------------------------------------------------------------+
bool CheckFreeMargin(double lot_size, int type)
{
   double margin_required = 0;
   if(!OrderCalcMargin((ENUM_ORDER_TYPE)type, Symbol(), lot_size, 
                      SymbolInfoDouble(Symbol(), type == OP_BUY ? SYMBOL_ASK : SYMBOL_BID), 
                      margin_required))
   {
      Print("Error calculating margin: ", GetLastError());
      return false;
   }
   
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   return (free_margin >= margin_required * 1.2); // 20% buffer
}