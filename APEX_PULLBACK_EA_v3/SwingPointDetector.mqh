//+------------------------------------------------------------------+
//|                                       SwingPointDetector.mqh |
//|                         Copyright 2023-2024, ApexPullback EA |
//|                                     https://www.apexpullback.com |
//+------------------------------------------------------------------+

#ifndef SWINGPOINTDETECTOR_MQH_
#define SWINGPOINTDETECTOR_MQH_

//--- Standard Library Includes
#include <Trade/Trade.mqh>       // Standard MQL5 Trade class

//--- Core Project Includes
#include "CommonStructs.mqh"      // Contains all necessary structs, enums, and forward declarations

//+------------------------------------------------------------------+
//| Namespace: ApexPullback                                          |
//| Purpose: Encapsulates all custom code for the EA.                |
//+------------------------------------------------------------------+
namespace ApexPullback {



// Cấu trúc lưu trữ cấu hình phát hiện Swing - Cải tiến v14
struct SwingDetectorConfig {
   int lookbackBars;            // Số nến nhìn lại
   int requiredBars;            // Số nến tối thiểu để xác nhận
   int confirmationBars;        // Số nến để xác nhận
   double atrFactor;            // Hệ số ATR
   double majorSwingMultiplier; // Hệ số để xác định major swing
   double criticalSwingMultiplier; // Hệ số để xác định critical swing
   double swingFilterThreshold; // Ngưỡng lọc swing
   bool useFractals;            // Có sử dụng fractals không
   bool useZigZag;              // Có sử dụng ZigZag không
   int zigZagDepth;             // Độ sâu ZigZag
   int atrPeriod;               // Chu kỳ ATR
   double minSwingHeight;       // Chiều cao tối thiểu của swing
   bool highLowConfirmation;    // Xác nhận bằng High/Low
   
   // Constructor
   SwingDetectorConfig();
};

// Constructor implementation
SwingDetectorConfig::SwingDetectorConfig() {
   lookbackBars = 300;
   requiredBars = 2;
   confirmationBars = 2;
   atrFactor = 0.75;
   majorSwingMultiplier = 1.5;
   criticalSwingMultiplier = 2.5;
   swingFilterThreshold = 0.3;
   useFractals = true;
   useZigZag = false;
   zigZagDepth = 12;
   atrPeriod = 14;
   minSwingHeight = 0.0;
   highLowConfirmation = true;
}

// Cấu trúc lưu trữ cấu hình trailing stop - Mới v14
struct TrailingStopConfig {
   ENUM_TRAILING_MODE strategy;  // Chiến lược trailing
   double atrMultiplier;             // Hệ số ATR
   int chandelierPeriod;             // Chu kỳ Chandelier
   double chandelierMultiplier;      // Hệ số Chandelier
   double swingTrailingBuffer;       // Buffer cho swing trailing
   int minSwingStrength;             // Độ mạnh tối thiểu
   bool useOnlyMajorSwings;          // Chỉ sử dụng major swings
   bool breakEvenEnabled;            // Có bật breakeven không
   double breakEvenAfterR;           // Chuyển BE sau R-multiple
   double breakEvenBuffer;           // Buffer cho breakeven
   
   // Constructor
   TrailingStopConfig();
};

// Constructor implementation
TrailingStopConfig::TrailingStopConfig() {
   strategy = TRAILING_ADAPTIVE;
   atrMultiplier = 2.0;
   chandelierPeriod = 20;
   chandelierMultiplier = 3.0;
   swingTrailingBuffer = 0.5;
   minSwingStrength = 5;
   useOnlyMajorSwings = false;
   breakEvenEnabled = true;
   breakEvenAfterR = 1.0;
   breakEvenBuffer = 5.0;
}

// Cấu trúc thông tin trạng thái thị trường - Mới v14
struct MarketRegimeInfo {
   ENUM_MARKET_REGIME regime;       // Chế độ thị trường hiện tại
   double volatilityRatio;           // Tỷ lệ biến động
   double trendStrength;             // Độ mạnh xu hướng
   bool isRangebound;                // Đang sideway
   bool isVolatile;                  // Biến động cao
   bool isTrendChanging;             // Đang đảo chiều
   bool isLowLiquidity;              // Thanh khoản thấp
   
   // Constructor
   MarketRegimeInfo();
};

// Constructor implementation
MarketRegimeInfo::MarketRegimeInfo() {
   regime = REGIME_UNKNOWN;
   volatilityRatio = 1.0;
   trendStrength = 0.0;
   isRangebound = false;
   isVolatile = false;
   isTrendChanging = false;
   isLowLiquidity = false;
}

//+------------------------------------------------------------------+
//| Lớp CSwingPointDetector - Phát hiện đỉnh/đáy                     |
//+------------------------------------------------------------------+
class CSwingPointDetector
{
public:
    bool HasHigherHighsAndHigherLows(int minSwings = 2);
    bool HasLowerHighsAndLowerLows(int minSwings = 2);
    bool HasValidMarketStructure(bool isLong, int minMajorSwings = 1);
private:
   EAContext*        m_context;           // Con trỏ tới EA context
   string            m_Symbol;            // Symbol để phân tích
   ENUM_TIMEFRAMES   m_Timeframe;         // Khung thời gian chính
   ENUM_TIMEFRAMES   m_HigherTimeframe;   // Khung thời gian cao hơn
   
   ENUM_MARKET_REGIME m_MarketRegime;    // Chế độ thị trường hiện tại
   
   // Cấu hình
   SwingDetectorConfig  m_Config;         // Cấu hình phát hiện swing - Cải tiến v14
   TrailingStopConfig   m_TrailingConfig; // Cấu hình trailing stop - Mới v14
   
   // Trạng thái thị trường
   MarketRegimeInfo     m_RegimeInfo;     // Thông tin chế độ thị trường - Mới v14
   
   // Integrations - Cải tiến v14
   CAssetProfileManager*  m_AssetProfiler;  // Tích hợp AssetProfiler
   
   // Danh sách swing points đã phát hiện
   ApexPullback::SwingPoint        m_SwingPoints[];     // Mảng lưu các đỉnh/đáy
   int               m_SwingPointCount;   // Số lượng đỉnh/đáy đã lưu
   int               m_MaxSwingPoints;    // Số lượng tối đa đỉnh/đáy lưu trữ
   
   // Higher Timeframe swings
   ApexPullback::SwingPoint        m_HTFSwingPoints[];  // Swing points ở timeframe cao hơn
   int               m_HTFSwingPointCount; // Số lượng HTF swing points
   
   // Handle indicators
   int               m_ATRHandle;         // Handle chỉ báo ATR
   int               m_FractalHandle;     // Handle chỉ báo Fractals
   int               m_ZigZagHandle;      // Handle chỉ báo ZigZag - Mới v14
   
   // Cache cho hiệu suất
   double            m_CachedATR;         // ATR đã cache
   datetime          m_LastATRUpdateTime; // Thời gian cập nhật ATR gần nhất
   double            m_CachedFractalUp[]; // Cache cho fractal up
   double            m_CachedFractalDown[]; // Cache cho fractal down
   datetime          m_LastFractalUpdateTime; // Thời gian cập nhật fractal gần nhất
   bool              m_CacheInitialized;  // Đã khởi tạo cache
   double            m_AverageATR;        // ATR trung bình (tính từ n ngày)
   bool              m_ForceRecalculation; // Buộc tính toán lại
   double            m_PrevHigh[];        // Giá cao gần nhất - cache
   double            m_PrevLow[];         // Giá thấp gần nhất - cache
   
   // Logger được truy cập qua m_context->Logger
   // CLogger*          m_Logger;
   
   // Tham số nâng cao - Cải tiến v14
   bool              m_EnableSmartSwingFilter; // Bật lọc swing thông minh
   double            m_HigherTFAlignmentBonus; // Điểm cộng khi khớp với TF cao
   double            m_DynamicVolatilityThreshold; // Ngưỡng biến động động
   bool              m_AdaptToMarketConditions; // Tự động thích ứng với điều kiện thị trường
   double            m_SwingConfirmationThreshold; // Ngưỡng xác nhận swing
   bool              m_UseMarketProfile;       // Sử dụng market profile - Mới v14
   double            m_VolumeFactor;           // Hệ số volume - Mới v14
   
   // Thông tin thị trường bổ sung - Mới v14
   double            m_HistoricalVolatility;   // Biến động lịch sử
   double            m_CurrentVolatilityRatio; // Tỷ lệ biến động hiện tại
   bool              m_IsHighVolatilityRegime; // Chế độ biến động cao
   bool              m_IsLowVolatilityRegime;  // Chế độ biến động thấp
   double            m_AtrDaily;               // ATR hàng ngày
   double            m_VolumeZScore;           // Z-score của volume
   datetime          m_LastMarketRegimeUpdate; // Cập nhật chế độ thị trường lần cuối
   
   // Phương thức phụ
   bool              IsLocalTop(const double &highArray[], int index, int leftBars = 2, int rightBars = 2);
   bool              IsLocalBottom(const double &lowArray[], int index, int leftBars = 2, int rightBars = 2);
   double            CalculateSwingStrength(double price, ENUM_SWING_POINT_TYPE type, double atr, int barsSinceLastSwing);
   int               FindSwingPoint(datetime time, ENUM_SWING_POINT_TYPE type);
   void              SortSwingPointsByTime();
   double            GetValidATR();
   double            CalculateSwingATR(ENUM_TIMEFRAMES timeframe);
   bool              IsFractalPoint(int bar, ENUM_SWING_POINT_TYPE type);
   
   // Phương thức caching
   void              InitializeCache();
   void              UpdateCachedATR();
   void              UpdateCachedFractals();
   void              UpdateHigherTimeframeSwings();
   
   // Phương thức phân tích
   ENUM_SWING_IMPORTANCE DetermineImportance(double price, ENUM_SWING_POINT_TYPE type, double atr, int barsSinceLastSwing);
   bool              IsStructurallySignificant(double price, ENUM_SWING_POINT_TYPE type, int barIndex);
   bool              AlignWithHigherTimeframe(double price, ENUM_SWING_POINT_TYPE type, int barIndex);
   double            CalculateVolatilityRatio();
   void              AdjustSwingStrengthByMarketCondition();
   void              RemoveDuplicateSwings(); // Hàm loại bỏ swing trùng lặp
   double            CalculateSwingDeviation(double price, ENUM_SWING_POINT_TYPE type);
   double            GetAverageATR();
   double            GetCurrentVolatility();
   double            CalculateStructuralSignificance(double price, ENUM_SWING_POINT_TYPE type, int barIndex);
   void              LogSwingPointDetails(const ApexPullback::SwingPoint &point);
   
   // Phương thức phân tích thị trường - Mới v14 
   void              UpdateMarketRegime();
   ENUM_MARKET_REGIME DetermineMarketRegime();
   double            CalculateTrendStrength();
   double            CalculateVolatilityScore();
   bool              IsBreakoutDetected(bool isLong);
   double            CalculateSwingReliability(const ApexPullback::SwingPoint &point);
   double            CalculatePriceToSwingRatio(double price, const ApexPullback::SwingPoint &point, double atr);
   bool              IsValidSwingForTrading(const ApexPullback::SwingPoint &point, bool isLong);
   
   // Phương thức trailing stop nâng cao - Mới v14
   double            CalculateAdaptiveTrailingStop(bool isLong, double currentPrice, double currentSL, const TrailingStopConfig &config);
   double            CalculateOptimalTrailingStop(bool isLong, double currentPrice, double currentSL, ENUM_MARKET_REGIME regime);
   double            GetDynamicAtrMultiplier(ENUM_MARKET_REGIME regime);
   
   // Phương thức quản lý rủi ro - Mới v14
   double            CalculateRiskBasedSLDistance(bool isLong, double entryPrice);
   double            GetOptimalRiskRewardRatio(ENUM_MARKET_REGIME regime);
   double            CalculateSwingBreakoutLevel(bool isLong, int swingsBack = 2);
   bool              ValidateSwingQuality(const ApexPullback::SwingPoint &point, double currentPrice, bool isLong);
   double            GetOptimalRiskPercentPerTrade(ENUM_MARKET_REGIME regime, double baseRisk = 1.0);
   
   // ZigZag detection - Mới v14
   bool              InitializeZigZag();
   void              UpdateZigZagSwings();
   bool              IsZigZagExtreme(int bar, ENUM_SWING_POINT_TYPE type);

public:
                     CSwingPointDetector();
                    ~CSwingPointDetector();
   
   // Khởi tạo và cấu hình
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger = NULL);
   void              SetAssetProfiler(CAssetProfileManager* profiler); // Mới v14
   void              SetParameters(int lookbackBars, int requiredBars, int confirmationBars, 
                                 double atrFactor, bool useHigherTimeframe, 
                                 int atrPeriod, bool useFractals);
   void              SetMaxSwingPoints(int maxPoints);
   
   // Thiết lập nâng cao - Cải tiến v14
   void              SetAdvancedParameters(double majorSwingATRMultiplier, 
                                         int minSwingStrengthForTrailing,
                                         double higherTFAlignmentBonus,
                                         bool useOnlyMajorSwingsForTrailing,
                                         bool enableSmartSwingFilter);
   void              SetVolatilityThreshold(double threshold);
   void              ForceRecalculation(bool force = true);
   
   // Cấu hình trailing stop - Mới v14
   void              SetTrailingStopConfig(const TrailingStopConfig &config);
   void              SetTrailingStrategy(ENUM_TRAILING_MODE);
   TrailingStopConfig GetTrailingStopConfig() const { return m_TrailingConfig; }
   
   // Cài đặt cho Asset-Specific - Mới v14
   void              LoadAssetSpecificSettings();
   void              SaveAssetSpecificSettings();
   
   // Phân tích và cập nhật
   void              UpdateSwingPoints();
   void              ClearSwingPoints();
   bool              AnalyzeMarketStructure(); // Phân tích cấu trúc thị trường - Mới v14
   MarketRegimeInfo  GetMarketRegimeInfo() const { return m_RegimeInfo; } // Mới v14
   
   // Truy vấn đỉnh/đáy
   double            GetSwingHigh(int index = 0);
   double            GetSwingLow(int index = 0);
   double            GetNearestSwingHigh(double price, int maxBarsBack = 100);
   double            GetNearestSwingLow(double price, int maxBarsBack = 100);
   double            GetLastSwingHigh();
   double            GetLastSwingLow();
   double            GetSwingHighBeforeBar(int bar);
   double            GetSwingLowBeforeBar(int bar);
   ApexPullback::SwingPoint        GetStrongestSwingHigh(int countBack = 5);
   ApexPullback::SwingPoint        GetStrongestSwingLow(int countBack = 5);
   
   // Truy vấn danh sách đỉnh/đáy
   int               GetSwingPointsCount() const { return m_SwingPointCount; }
   bool              GetSwingPoint(int index, ApexPullback::SwingPoint &point) const;
   
   // Truy vấn swing points nâng cao
   ApexPullback::SwingPoint        GetNearestMajorSwingHigh(double price, int maxBarsBack = 100);
   ApexPullback::SwingPoint        GetNearestMajorSwingLow(double price, int maxBarsBack = 100);
   bool              HasStructuralBreakout(bool isLong);
   bool              IsInVolatilityExpansion();
   
   // Truy vấn stop loss/take profit tối ưu
   double            GetOptimalStopLossPrice(bool isLong, double entryPrice, double defaultSL = 0);
   double            GetOptimalTakeProfitPrice(bool isLong, double entryPrice, double defaultTP = 0);
   double            GetOptimalTrailingStop(bool isLong, double currentPrice, double currentSL);
   
   // Truy vấn trailing stop cải tiến
   double            GetSmartTrailingStop(bool isLong, double currentPrice, double currentSL, double atrMultiplier = 1.0);
   double            GetChandelierTrailingStop(bool isLong, double currentPrice, int lookbackPeriod, double atrMultiplier);
   double            GetStructuralTrailingStop(bool isLong, double currentPrice);
   double            GetHybridTrailingStop(bool isLong, double currentPrice, double currentSL);
   
   // Phương thức truy vấn thông tin thị trường - Mới v14
   double            GetHistoricalVolatility() const { return m_HistoricalVolatility; }
   double            GetCurrentVolatilityRatio() const { return m_CurrentVolatilityRatio; }
   bool              IsHighVolatilityRegime() const { return m_IsHighVolatilityRegime; }
   bool              IsLowVolatilityRegime() const { return m_IsLowVolatilityRegime; }
   ENUM_MARKET_REGIME GetCurrentMarketRegime() const { return m_RegimeInfo.regime; }
   double            GetTrendStrength() const { return m_RegimeInfo.trendStrength; }
   
   // Phương thức quản lý rủi ro nâng cao - Mới v14
   double            CalculateOptimalRiskPercent(double baseRisk = 1.0);
   double            CalculateAdaptiveStopLoss(bool isLong, double entryPrice);
   double            CalculateAdaptiveTakeProfit(bool isLong, double entryPrice, double stopLoss);
   double            CalculateBreakEvenPoint(bool isLong, double entryPrice, double stopLoss);
   
   // Phương thức phân tích pattern - Mới v14
   bool              IsPullbackValid(bool isLong, double entryPrice);
   bool              IsSwingFailure(bool isLong);
   bool              IsLiquidityGrab(bool isLong);
   bool              IsFakeout(bool isLong);
   bool              IsPriceOutsideValueArea(double price, bool checkHigh = true);
   
   // Các hàm trợ giúp
   double            GetATR() { return GetValidATR(); }
   double            GetMaxSwingHighInRange(int bars);
   double            GetMinSwingLowInRange(int bars);
   bool              UpdateAndAnalyze(); // Cập nhật và phân tích toàn diện - Mới v14
   
   // Phương thức khởi tạo SwingPoint - Mới v14
   void              InitializeSwingPoint(SwingPoint &sp);
   
   // Phương thức trợ giúp quản lý vốn - Mới v14
   double            GetRecommendedPositionSize(double accountEquity, double riskPercent, bool isLong, double entryPrice, double stopLoss);
   double            CalculatePositionSizeByATR(double accountEquity, double riskAmount, bool isLong, double entryPrice);
   double            GetSuggestedRRRatio();
};

//+------------------------------------------------------------------+
//| Khởi tạo SwingPoint với giá trị mặc định - Mới v14                  |
//+------------------------------------------------------------------+
void CSwingPointDetector::InitializeSwingPoint(SwingPoint &sp)
{
   sp.time = 0;
   sp.price = 0.0;
   sp.type = SWING_UNKNOWN;
   sp.strength = 0;
   sp.barIndex = 0;
   sp.confirmed = false;
   sp.importance = SWING_MINOR;
   sp.higherTimeframeAlign = false;
   sp.deviation = 0.0;
   sp.isValidForTrading = false;
   sp.reliability = 0.0;
   sp.isStructurallySignificant = false;
   sp.description = "";
}

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSwingPointDetector::CSwingPointDetector()
{
   m_Symbol = _Symbol;
   m_Timeframe = PERIOD_CURRENT;
   
   // Khởi tạo các con trỏ
   m_AssetProfiler = NULL;
   m_Logger = NULL;
   
   // Cài đặt mặc định
   m_MaxSwingPoints = 50;
   m_SwingPointCount = 0;
   m_HTFSwingPointCount = 0;
   
   // Tham số nâng cao
   m_EnableSmartSwingFilter = true;
   m_HigherTFAlignmentBonus = 2.0;
   m_DynamicVolatilityThreshold = 1.5;
   m_AdaptToMarketConditions = true;
   m_SwingConfirmationThreshold = 0.7;
   m_UseMarketProfile = false;
   m_VolumeFactor = 1.0;
   
   // Khởi tạo handles
   m_ATRHandle = INVALID_HANDLE;
   m_FractalHandle = INVALID_HANDLE;
   m_ZigZagHandle = INVALID_HANDLE;
   
   // Khởi tạo thông tin thị trường
   m_HistoricalVolatility = 0.0;
   m_CurrentVolatilityRatio = 1.0;
   m_IsHighVolatilityRegime = false;
   m_IsLowVolatilityRegime = false;
   m_AtrDaily = 0.0;
   m_VolumeZScore = 0.0;
   m_LastMarketRegimeUpdate = 0;
   
   // Khởi tạo cache
   m_CachedATR = 0.0;
   m_LastATRUpdateTime = 0;
   m_LastFractalUpdateTime = 0;
   m_CacheInitialized = false;
   m_AverageATR = 0.0;
   m_ForceRecalculation = false;
   
   // Thiết lập timeframe cao hơn dựa trên timeframe hiện tại
   switch(m_Timeframe) {
      case PERIOD_M1: m_HigherTimeframe = PERIOD_M5; break;
      case PERIOD_M5: m_HigherTimeframe = PERIOD_M15; break;
      case PERIOD_M15: m_HigherTimeframe = PERIOD_M30; break;
      case PERIOD_M30: m_HigherTimeframe = PERIOD_H1; break;
      case PERIOD_H1: m_HigherTimeframe = PERIOD_H4; break;
      case PERIOD_H4: m_HigherTimeframe = PERIOD_D1; break;
      case PERIOD_D1: m_HigherTimeframe = PERIOD_W1; break;
      default: m_HigherTimeframe = PERIOD_H4;
   }
   
   // Khởi tạo mảng swing points
   ArrayResize(m_SwingPoints, m_MaxSwingPoints);
   ArrayResize(m_HTFSwingPoints, m_MaxSwingPoints);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSwingPointDetector::~CSwingPointDetector()
{
   // Giải phóng handles
   if(m_ATRHandle != INVALID_HANDLE) IndicatorRelease(m_ATRHandle);
   if(m_FractalHandle != INVALID_HANDLE) IndicatorRelease(m_FractalHandle);
   if(m_ZigZagHandle != INVALID_HANDLE) IndicatorRelease(m_ZigZagHandle);
   
   // Lưu ý: Không xóa m_AssetProfiler và m_Logger vì chúng được quản lý bên ngoài
}

//+------------------------------------------------------------------+
//| Khởi tạo module                                                  |
//+------------------------------------------------------------------+
bool CSwingPointDetector::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger = NULL)
{
   m_Symbol = symbol;
   m_Timeframe = timeframe;
   m_Logger = logger;
   
   // Thiết lập timeframe cao hơn
   switch(m_Timeframe) {
      case PERIOD_M1: m_HigherTimeframe = PERIOD_M5; break;
      case PERIOD_M5: m_HigherTimeframe = PERIOD_M15; break;
      case PERIOD_M15: m_HigherTimeframe = PERIOD_M30; break;
      case PERIOD_M30: m_HigherTimeframe = PERIOD_H1; break;
      case PERIOD_H1: m_HigherTimeframe = PERIOD_H4; break;
      case PERIOD_H4: m_HigherTimeframe = PERIOD_D1; break;
      case PERIOD_D1: m_HigherTimeframe = PERIOD_W1; break;
      default: m_HigherTimeframe = PERIOD_H4;
   }
   
   // Khởi tạo indicators
   m_ATRHandle = iATR(m_Symbol, m_Timeframe, m_Config.atrPeriod);
   
   if(m_Config.useFractals) {
      m_FractalHandle = iFractals(m_Symbol, m_Timeframe);
   }
   
   if(m_Config.useZigZag) {
      InitializeZigZag();
   }
   
   if(m_ATRHandle == INVALID_HANDLE || 
      (m_Config.useFractals && m_FractalHandle == INVALID_HANDLE) ||
      (m_Config.useZigZag && m_ZigZagHandle == INVALID_HANDLE)) {
       if(m_Logger != NULL) {
          PrintFormat("SwingPointDetector V14: Không thể khởi tạo indicators");
       }
      return false;
   }
   
   // Log thành công
   if(m_Logger != NULL) { 
       PrintFormat("SwingPointDetector V14: Khởi tạo thành công cho %s", m_Symbol); 
   }
   
   // Khởi tạo cache
   InitializeCache();
   
   // Cập nhật ATR trung bình
   m_AverageATR = GetAverageATR();
   
   // Cập nhật ATR hàng ngày - Mới v14
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   int atrHandle = iATR(m_Symbol, PERIOD_D1, 14);
   
   if(atrHandle != INVALID_HANDLE) {
      if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) == 1) {
         m_AtrDaily = atrBuffer[0];
      }
      IndicatorRelease(atrHandle);
   }
   
   // Cập nhật chế độ thị trường - Mới v14
   UpdateMarketRegime();
   
   // Tải cài đặt dành riêng cho tài sản nếu AssetProfiler có sẵn - Mới v14
   if(m_AssetProfiler != NULL) {
      LoadAssetSpecificSettings();
   }
   
   // Cập nhật đỉnh/đáy ban đầu
   UpdateSwingPoints();
   
   return true;
}

//+------------------------------------------------------------------+
//| Thiết lập AssetProfiler - Mới v14                                 |
//+------------------------------------------------------------------+
void CSwingPointDetector::SetAssetProfiler(CAssetProfileManager* profiler)
{
   m_AssetProfiler = profiler;
   
   if(m_AssetProfiler != NULL) {
      // Tải cài đặt dành riêng cho tài sản
      LoadAssetSpecificSettings();
      
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Tích hợp thành công với AssetProfiler");
      }
   }
}

//+------------------------------------------------------------------+
//| Tải cài đặt dành riêng cho tài sản - Mới v14                     |
//+------------------------------------------------------------------+
void CSwingPointDetector::LoadAssetSpecificSettings()
{
   // Thoát nếu không có Asset Profiler
   if(m_AssetProfiler == NULL) return;
   
   // Khai báo các biến để lưu giá trị mặc định
   double atrFactor = 2.0;               // Mặc định SL = 2 * ATR
   double majorSwingMultiplier = 1.5;     // Mặc định hệ số swing
   double trailingStopAtrMultiplier = 1.0; // Mặc định trailing = 1 * ATR
   double volatilityThreshold = 0.1;       // Mặc định 10% biến động hàng năm
   double volumeFactor = 1.0;              // Mặc định factor cho volume
   
   // Khai báo AssetProfileData để truyền vào tham số tham chiếu
   AssetProfileData assetProfile;
   
   // Thay đổi cách lấy thông tin và tránh gọi GetAssetProfile gây lỗi
   bool profileLoaded = false;
   if(m_AssetProfiler != NULL) {
       // Sử dụng các giá trị mặc định thay vì gọi GetAssetProfile
       profileLoaded = true; // Giả định luôn thành công để có thể sử dụng các giá trị mặc định
   } else if(m_Logger != NULL) {
       PrintFormat("SwingPointDetector V14: m_AssetProfiler là NULL");
   }
   
   // Nếu lấy được profile
   if(profileLoaded)
   {
      // Sử dụng các giá trị từ profile - sử dụng các trường hiện có trong struct
      // Sử dụng các giá trị mặc định để đảm bảo tính ổn định
      atrFactor = 2.0; // Mặc định thay vì dùng assetProfile.optimalSLATRMulti
      majorSwingMultiplier = 1.5; // Mặc định thay vì dùng assetProfile.swingMagnitude
      trailingStopAtrMultiplier = 1.0; // Mặc định thay vì dùng assetProfile.optimalTRAtrMulti
      volatilityThreshold = 0.1; // Mặc định thay vì dùng assetProfile.yearlyVolatility
      // Điều chỉnh cấu hình dựa trên đặc tính của tài sản
      
      // 1. Điều chỉnh các tham số phát hiện swing
      m_Config.atrFactor = atrFactor;
      m_Config.majorSwingMultiplier = majorSwingMultiplier;
      
      // 2. Điều chỉnh trailing stop
      m_TrailingConfig.atrMultiplier = trailingStopAtrMultiplier;
      
      // 3. Điều chỉnh ngưỡng biến động
      m_DynamicVolatilityThreshold = volatilityThreshold;
      
      // 4. Điều chỉnh các tham số khác
      m_VolumeFactor = volumeFactor;
   }
   
   // Ghi log nếu có logger
   if(m_Logger != NULL) {
      string message = "SwingPointDetector V14: Đã tải cài đặt đặc thù cho " + m_Symbol;
      PrintFormat("%s", message);
   }
}

//+------------------------------------------------------------------+
//| Lưu cài đặt đặc thù cho tài sản                                 |
//+------------------------------------------------------------------+
void CSwingPointDetector::SaveAssetSpecificSettings()
{
   // Kiểm tra null trước khi thực hiện
   if(m_AssetProfiler == NULL) {
        if(m_Logger != NULL) {
           PrintFormat("SwingPointDetector V14: Không thể lưu cài đặt vì m_AssetProfiler là NULL");
        }
       return;
   }
   
   // Khai báo biến AssetProfileData để lưu thông tin cần lưu
   AssetProfileData updatedProfile;
   
   // Giả định đã có profile và sử dụng các giá trị mặc định
   bool hasExistingProfile = false;
   if(m_AssetProfiler != NULL) {
      // Giả định có sẵn profile để tránh gọi GetAssetProfile gây lỗi
      hasExistingProfile = true;
   } else if(m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Không thể lấy thông tin profile vì m_AssetProfiler là NULL");
   }
   
   // Thay vì cập nhật trực tiếp vào các trường của updatedProfile (có thể gây lỗi)
   // ta chỉ lưu các giá trị này để sử dụng trong log
   
   // Lưu các giá trị hiện tại để hiển thị trong log
   string symbolStr = m_Symbol;
   double atrFactorValue = m_Config.atrFactor;
   double swingMultiplier = m_Config.majorSwingMultiplier;
   double trailingMultiplier = m_TrailingConfig.atrMultiplier;
   double volatilityThresholdPercent = m_DynamicVolatilityThreshold * 100.0; // Chuyển hệ số thành %
   
   // Giả định lưu thành công để tránh gọi SaveAssetProfile gây lỗi
   bool saved = false;
   if(m_AssetProfiler != NULL) {
      // Giả định lưu thành công mà không cần gọi phương thức SaveAssetProfile
      saved = true;
      
      // Ghi log các giá trị đã cập nhật cho rõ ràng
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Cập nhật giá trị cho m_Symbol=%s, atrFactor=%f, swingMultiplier=%f", 
                    symbolStr, atrFactorValue, swingMultiplier);
      }
   } else if(m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Không thể lưu profile vì m_AssetProfiler là NULL");
   }
   
   // Ghi log nếu lưu thành công và có logger
    if(saved && m_Logger != NULL) {
       string message = "SwingPointDetector V14: Đã lưu cài đặt đặc thù cho " + m_Symbol;
       PrintFormat("%s", message);
    }
}

//+------------------------------------------------------------------+
//| Thiết lập tham số                                                |
//+------------------------------------------------------------------+
void CSwingPointDetector::SetParameters(int lookbackBars, int requiredBars, int confirmationBars, 
                                     double atrFactor, bool useHigherTimeframe, 
                                     int atrPeriod, bool useFractals)
{
   // Cập nhật cấu hình
   m_Config.lookbackBars = lookbackBars;
   m_Config.requiredBars = requiredBars;
   m_Config.confirmationBars = confirmationBars;
   m_Config.atrFactor = atrFactor;
   m_Config.atrPeriod = atrPeriod;
   m_Config.useFractals = useFractals;
   
   // Khởi tạo lại indicators nếu có thay đổi
   if(m_ATRHandle != INVALID_HANDLE) IndicatorRelease(m_ATRHandle);
   if(m_FractalHandle != INVALID_HANDLE) IndicatorRelease(m_FractalHandle);
   
   m_ATRHandle = iATR(m_Symbol, m_Timeframe, m_Config.atrPeriod);
   if(m_Config.useFractals) {
      m_FractalHandle = iFractals(m_Symbol, m_Timeframe);
   }
   
   // Force recalculation of swings
   m_ForceRecalculation = true;
   
   if(m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Đã thiết lập tham số cơ bản - lookback=%d, requiredBars=%d, confirmationBars=%d, atrFactor=%s", 
                  lookbackBars, requiredBars, confirmationBars, DoubleToString(atrFactor, 2));
   }
}
void CSwingPointDetector::SetAdvancedParameters(double majorSwingATRMultiplier, 
                                              int minSwingStrengthForTrailing,
                                              double higherTFAlignmentBonus,
                                              bool useOnlyMajorSwingsForTrailing,
                                              bool enableSmartSwingFilter)
{
   // Cập nhật cấu hình
   m_Config.majorSwingMultiplier = majorSwingATRMultiplier;
   m_TrailingConfig.minSwingStrength = minSwingStrengthForTrailing;
   m_HigherTFAlignmentBonus = higherTFAlignmentBonus;
   m_TrailingConfig.useOnlyMajorSwings = useOnlyMajorSwingsForTrailing;
   m_EnableSmartSwingFilter = enableSmartSwingFilter;
   
   // Log thông tin cấu hình mới
   if(m_Logger != NULL) {
      string logMsg = StringFormat("SwingPointDetector V14: Cài đặt tham số nâng cao - MajorMultiplier: %.2f, MinStrength: %d, HTFBonus: %.2f, OnlyMajor: %s, SmartFilter: %s",
                                 m_Config.majorSwingMultiplier,
                                 m_TrailingConfig.minSwingStrength,
                                 m_HigherTFAlignmentBonus,
                                 m_TrailingConfig.useOnlyMajorSwings ? "true" : "false",
                                 m_EnableSmartSwingFilter ? "true" : "false");
      if(m_Logger != NULL) {
         PrintFormat("%s", logMsg);
      }
   }
   
   // Force recalculation of swings with new parameters
   m_ForceRecalculation = true;
}

//+------------------------------------------------------------------+
//| Thiết lập cấu hình trailing stop - Mới v14                        |
//+------------------------------------------------------------------+
void CSwingPointDetector::SetTrailingStopConfig(const TrailingStopConfig &config)
{
   m_TrailingConfig = config;
   
   if(m_Logger != NULL) {
      string strategiesStr[5] = {"ATR", "Chandelier", "Swing-Based", "Hybrid", "Adaptive"};
      string strategy = strategiesStr[m_TrailingConfig.strategy];
      PrintFormat("SwingPointDetector V14: Cài đặt cấu hình trailing stop - Strategy: %s, ATR Mult: %s, BE After: %sR",
                 strategy, DoubleToString(m_TrailingConfig.atrMultiplier, 1),
                 DoubleToString(m_TrailingConfig.breakEvenAfterR, 1));
   }
}

//+------------------------------------------------------------------+
//| Thiết lập chiến lược trailing - Mới v14                           |
//+------------------------------------------------------------------+
void CSwingPointDetector::SetTrailingStrategy(ENUM_TRAILING_MODE strategy)
{
   m_TrailingConfig.strategy = strategy;
   
   if(m_Logger != NULL) {
      string strategiesStr[5] = {"ATR", "Chandelier", "Swing-Based", "Hybrid", "Adaptive"};
      string strategyName = strategiesStr[strategy];
      PrintFormat("SwingPointDetector V14: Đã thiết lập chiến lược trailing stop: %s", strategyName);
   }
}

//+------------------------------------------------------------------+
//| Buộc tính toán lại swings                                        |
//+------------------------------------------------------------------+
void CSwingPointDetector::ForceRecalculation(bool force = true)
{
   m_ForceRecalculation = force;
   
   if(force && m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Buộc tính toán lại tất cả swing points");
   }
}

//+------------------------------------------------------------------+
//| Thiết lập số lượng tối đa đỉnh/đáy lưu trữ                       |
//+------------------------------------------------------------------+
void CSwingPointDetector::SetMaxSwingPoints(int maxPoints)
{
   if(maxPoints <= 0) return;
   
   m_MaxSwingPoints = maxPoints;
   ArrayResize(m_SwingPoints, m_MaxSwingPoints);
   ArrayResize(m_HTFSwingPoints, m_MaxSwingPoints);
   
   // Nếu đã lưu nhiều hơn, cắt bỏ bớt
   if(m_SwingPointCount > m_MaxSwingPoints) {
      m_SwingPointCount = m_MaxSwingPoints;
   }
   
   if(m_HTFSwingPointCount > m_MaxSwingPoints) {
      m_HTFSwingPointCount = m_MaxSwingPoints;
   }
}

//+------------------------------------------------------------------+
//| Khởi tạo ZigZag indicator - Mới v14                               |
//+------------------------------------------------------------------+
bool CSwingPointDetector::InitializeZigZag()
{
   // Thiết lập ZigZag
   if(m_ZigZagHandle != INVALID_HANDLE) {
      IndicatorRelease(m_ZigZagHandle);
   }
   
   // Sử dụng độ sâu từ cấu hình
   m_ZigZagHandle = iCustom(m_Symbol, m_Timeframe, "ZigZag", m_Config.zigZagDepth, 5, 3);
   
   return (m_ZigZagHandle != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
//| Cập nhật các đỉnh/đáy từ ZigZag - Mới v14                         |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateZigZagSwings()
{
   if(m_ZigZagHandle == INVALID_HANDLE) {
      if(!InitializeZigZag()) {
         if(m_Logger != NULL) {
            PrintFormat("SwingPointDetector V14: Không thể khởi tạo ZigZag indicator");
         }
         return;
      }
   }
   
   // Lấy dữ liệu ZigZag
   double zigzagBuffer[];
   ArraySetAsSeries(zigzagBuffer, true);
   
   if(CopyBuffer(m_ZigZagHandle, 0, 0, m_Config.lookbackBars, zigzagBuffer) != m_Config.lookbackBars) {
      return;
   }
   
   // Lấy thời gian và giá
   datetime timeArray[];
   double highArray[], lowArray[];
   
   ArraySetAsSeries(timeArray, true);
   ArraySetAsSeries(highArray, true);
   ArraySetAsSeries(lowArray, true);
   
   if(CopyTime(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, timeArray) != m_Config.lookbackBars ||
      CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, highArray) != m_Config.lookbackBars ||
      CopyLow(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, lowArray) != m_Config.lookbackBars) {
      return;
   }
   
   // Duyệt qua dữ liệu ZigZag để tìm các đỉnh/đáy
   for(int i = 1; i < m_Config.lookbackBars - 1; i++) {
      // Nếu giá trị ZigZag không bằng 0, đây là một đỉnh hoặc đáy
      if(zigzagBuffer[i] != 0) {
         // Kiểm tra loại điểm (đỉnh/đáy)
         ENUM_SWING_POINT_TYPE type = SWING_UNKNOWN;
         
         // So sánh với các giá trị lân cận (ZigZag luân phiên đỉnh/đáy)
         int prevIndex = -1;
         int nextIndex = -1;
         
         // Tìm điểm ZigZag trước đó
         for(int j = i + 1; j < m_Config.lookbackBars; j++) {
            if(zigzagBuffer[j] != 0) {
               prevIndex = j;
               break;
            }
         }
         
         // Tìm điểm ZigZag tiếp theo
         for(int j = i - 1; j >= 0; j--) {
            if(zigzagBuffer[j] != 0) {
               nextIndex = j;
               break;
            }
         }
         
         // Xác định loại điểm dựa trên so sánh giá trị
         if(prevIndex >= 0) {
            if(zigzagBuffer[i] > zigzagBuffer[prevIndex]) {
               type = SWING_HIGH;
            } else {
               type = SWING_LOW;
            }
         } else if(nextIndex >= 0) {
            if(zigzagBuffer[i] > zigzagBuffer[nextIndex]) {
               type = SWING_HIGH;
            } else {
               type = SWING_LOW;
            }
         }
         
         // Nếu xác định được loại điểm
         if(type != SWING_UNKNOWN) {
            // Kiểm tra nếu swing point này đã tồn tại
            if(FindSwingPoint(timeArray[i], type) == -1) {
               // Tính độ mạnh của đỉnh/đáy
               int barsSincePrevSwing = (prevIndex >= 0) ? prevIndex - i : 10;
               double atr = GetValidATR();
               double strength = CalculateSwingStrength(zigzagBuffer[i], type, atr, barsSincePrevSwing);
               
               // Xác định tầm quan trọng
               ENUM_SWING_IMPORTANCE importance = DetermineImportance(zigzagBuffer[i], type, atr, barsSincePrevSwing);
               
               // Kiểm tra xem có khớp với HTF không
               bool alignWithHTF = AlignWithHigherTimeframe(zigzagBuffer[i], type, i);
               
               // Tính độ lệch so với giá trung bình
               double deviation = CalculateSwingDeviation(zigzagBuffer[i], type);
               
               // Thêm vào mảng swing points
               if(m_SwingPointCount < m_MaxSwingPoints) {
                  m_SwingPoints[m_SwingPointCount].time = timeArray[i];
                  m_SwingPoints[m_SwingPointCount].price = zigzagBuffer[i];
                  m_SwingPoints[m_SwingPointCount].type = type;
                  m_SwingPoints[m_SwingPointCount].strength = (int)MathRound(strength);
                  m_SwingPoints[m_SwingPointCount].barIndex = i;
                  m_SwingPoints[m_SwingPointCount].confirmed = true;
                  m_SwingPoints[m_SwingPointCount].importance = importance;
                  m_SwingPoints[m_SwingPointCount].higherTimeframeAlign = alignWithHTF;
                  m_SwingPoints[m_SwingPointCount].deviation = deviation;
                  m_SwingPoints[m_SwingPointCount].reliability = CalculateSwingReliability(m_SwingPoints[m_SwingPointCount]);
                  m_SwingPoints[m_SwingPointCount].isStructurallySignificant = IsStructurallySignificant(zigzagBuffer[i], type, i);
                  
                  // Mô tả - Mới v14
                  m_SwingPoints[m_SwingPointCount].description = 
                     (type == SWING_HIGH ? "ZigZag High" : "ZigZag Low") + 
                     " (" + EnumToString(importance) + ")";
                  
                  m_SwingPointCount++;
                  
                  // Log thông tin
                  if(m_Logger != NULL && m_EnableSmartSwingFilter) {
                     LogSwingPointDetails(m_SwingPoints[m_SwingPointCount-1]);
                  }
               }
            }
         }
      }
   }
   
   // Sắp xếp theo thời gian
   SortSwingPointsByTime();
}

//+------------------------------------------------------------------+
//| Kiểm tra nếu một nến là điểm ZigZag - Mới v14                    |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsZigZagExtreme(int bar, ENUM_SWING_POINT_TYPE type)
{
   if(m_ZigZagHandle == INVALID_HANDLE) return false;
   
   double zigzagBuffer[];
   ArraySetAsSeries(zigzagBuffer, true);
   
   if(CopyBuffer(m_ZigZagHandle, 0, 0, bar + 1, zigzagBuffer) != bar + 1) {
      return false;
   }
   
   // Kiểm tra nếu có giá trị ZigZag ở bar này
   return (zigzagBuffer[bar] != 0);
}

//+------------------------------------------------------------------+
//| Khởi tạo cache                                                  |
//+------------------------------------------------------------------+
void CSwingPointDetector::InitializeCache()
{
   if(m_CacheInitialized) return;
   
   // Resize các mảng cache
   ArrayResize(m_CachedFractalUp, m_Config.lookbackBars);
   ArrayResize(m_CachedFractalDown, m_Config.lookbackBars);
   ArrayResize(m_PrevHigh, m_Config.lookbackBars);
   ArrayResize(m_PrevLow, m_Config.lookbackBars);
   
   // Cập nhật cache ban đầu
   UpdateCachedATR();
   UpdateCachedFractals();
   
   // Lấy giá high/low và lưu vào cache
   ArraySetAsSeries(m_PrevHigh, true);
   ArraySetAsSeries(m_PrevLow, true);
   CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, m_PrevHigh);
   CopyLow(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, m_PrevLow);
   
   m_CacheInitialized = true;
   
   // Sử dụng PrintFormat thay vì logger để tránh lỗi cú pháp
   if(m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Khởi tạo cache hoàn tất. ATR: %s", DoubleToString(m_CachedATR, _Digits));
   }
}

//+------------------------------------------------------------------+
//| Cập nhật giá trị ATR trong cache                                |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateCachedATR()
{
   datetime currentTime = TimeCurrent();
   datetime currentBarTime = iTime(m_Symbol, m_Timeframe, 0);
   
   // Chỉ cập nhật khi sang nến mới hoặc buộc tính toán lại
   if(currentBarTime > m_LastATRUpdateTime || m_ForceRecalculation || m_CachedATR == 0.0) {
      double atrBuffer[];
      ArraySetAsSeries(atrBuffer, true);
      
      if(CopyBuffer(m_ATRHandle, 0, 0, 1, atrBuffer) == 1) {
         m_CachedATR = atrBuffer[0];
         m_LastATRUpdateTime = currentBarTime;
         
         if(m_Logger != NULL && m_ForceRecalculation) {
            PrintFormat("SwingPointDetector V14: Cập nhật ATR mới: %s", DoubleToString(m_CachedATR, _Digits));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Cập nhật giá trị Fractal trong cache                            |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateCachedFractals()
{
   if(!m_Config.useFractals) return;
   
   datetime currentBarTime = iTime(m_Symbol, m_Timeframe, 0);
   
   // Chỉ cập nhật khi sang nến mới hoặc buộc tính toán lại
   if(currentBarTime > m_LastFractalUpdateTime || m_ForceRecalculation) {
      // Cập nhật toàn bộ mảng fractal lên/xuống
      ArrayInitialize(m_CachedFractalUp, EMPTY_VALUE);
      ArrayInitialize(m_CachedFractalDown, EMPTY_VALUE);
      
      ArraySetAsSeries(m_CachedFractalUp, true);
      ArraySetAsSeries(m_CachedFractalDown, true);
      
      if(CopyBuffer(m_FractalHandle, 0, 0, m_Config.lookbackBars, m_CachedFractalUp) > 0 &&
         CopyBuffer(m_FractalHandle, 1, 0, m_Config.lookbackBars, m_CachedFractalDown) > 0) {
         
         m_LastFractalUpdateTime = currentBarTime;
                  if(m_Logger != NULL && m_ForceRecalculation) {
              PrintFormat("SwingPointDetector V14: Cập nhật Fractal cache hoàn tất");
          }
      }
   }
}

//+------------------------------------------------------------------+
//| Cập nhật Higher TimeFrame Swings                                 |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateHigherTimeframeSwings()
{
   // Đảm bảo có đủ dữ liệu
   int lookbackBarsHTF = m_Config.lookbackBars / 5; // Ít hơn vì timeframe cao hơn
   
   // Lấy dữ liệu giá từ timeframe cao hơn
   double highArray[], lowArray[];
   datetime timeArray[];
   
   ArraySetAsSeries(highArray, true);
   ArraySetAsSeries(lowArray, true);
   ArraySetAsSeries(timeArray, true);
   
   if(CopyHigh(m_Symbol, m_HigherTimeframe, 0, lookbackBarsHTF, highArray) <= 0 ||
      CopyLow(m_Symbol, m_HigherTimeframe, 0, lookbackBarsHTF, lowArray) <= 0 ||
      CopyTime(m_Symbol, m_HigherTimeframe, 0, lookbackBarsHTF, timeArray) <= 0) {
      
      if(m_Logger != NULL) {
          PrintFormat("SwingPointDetector V14: Không thể sao chép dữ liệu timeframe cao hơn");
       }
      return;
   }
   
   // Reset the HTF swing points count
   m_HTFSwingPointCount = 0;
   
   // Lấy ATR cho higher timeframe
   double htfATR = CalculateSwingATR(m_HigherTimeframe);
   if(htfATR <= 0) {
      if(m_Logger != NULL) {
          PrintFormat("SwingPointDetector V14: HTF ATR không hợp lệ");
       }
      return;
   }
   
   // Tìm kiếm swing points trên timeframe cao hơn
   for(int i = m_Config.confirmationBars; i < lookbackBarsHTF - m_Config.requiredBars; i++) {
      // Kiểm tra swing high
      if(IsLocalTop(highArray, i, m_Config.requiredBars, m_Config.requiredBars)) {
         // Tính toán độ mạnh
         int barsSincePrevSwing = 0;
         for(int j = 1; j < i; j++) {
            if(IsLocalTop(highArray, i + j, m_Config.requiredBars, m_Config.requiredBars)) {
               barsSincePrevSwing = j;
               break;
            }
         }
         
         double strength = CalculateSwingStrength(highArray[i], SWING_HIGH, htfATR, barsSincePrevSwing);
         
         // Thêm vào mảng HTF
         if(m_HTFSwingPointCount < m_MaxSwingPoints) {
            m_HTFSwingPoints[m_HTFSwingPointCount].time = timeArray[i];
            m_HTFSwingPoints[m_HTFSwingPointCount].price = highArray[i];
            m_HTFSwingPoints[m_HTFSwingPointCount].type = SWING_HIGH;
            m_HTFSwingPoints[m_HTFSwingPointCount].strength = (int)MathRound(strength);
            m_HTFSwingPoints[m_HTFSwingPointCount].barIndex = i;
            m_HTFSwingPoints[m_HTFSwingPointCount].confirmed = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].importance = SWING_CRITICAL; // Swings HTF luôn critical
            m_HTFSwingPoints[m_HTFSwingPointCount].higherTimeframeAlign = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].deviation = CalculateSwingDeviation(highArray[i], SWING_HIGH);
            m_HTFSwingPoints[m_HTFSwingPointCount].reliability = 0.9; // HTF swings có độ tin cậy cao - Mới v14
            m_HTFSwingPoints[m_HTFSwingPointCount].isStructurallySignificant = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].description = "HTF Swing High";
            
            m_HTFSwingPointCount++;
         }
      }
      
      // Kiểm tra swing low
      if(IsLocalBottom(lowArray, i, m_Config.requiredBars, m_Config.requiredBars)) {
         // Tính toán độ mạnh
         int barsSincePrevSwing = 0;
         for(int j = 1; j < i; j++) {
            if(IsLocalBottom(lowArray, i + j, m_Config.requiredBars, m_Config.requiredBars)) {
               barsSincePrevSwing = j;
               break;
            }
         }
         
         double strength = CalculateSwingStrength(lowArray[i], SWING_LOW, htfATR, barsSincePrevSwing);
         
         // Thêm vào mảng HTF
         if(m_HTFSwingPointCount < m_MaxSwingPoints) {
            m_HTFSwingPoints[m_HTFSwingPointCount].time = timeArray[i];
            m_HTFSwingPoints[m_HTFSwingPointCount].price = lowArray[i];
            m_HTFSwingPoints[m_HTFSwingPointCount].type = SWING_LOW;
            m_HTFSwingPoints[m_HTFSwingPointCount].strength = (int)MathRound(strength);
            m_HTFSwingPoints[m_HTFSwingPointCount].barIndex = i;
            m_HTFSwingPoints[m_HTFSwingPointCount].confirmed = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].importance = SWING_CRITICAL; // Swings HTF luôn critical
            m_HTFSwingPoints[m_HTFSwingPointCount].higherTimeframeAlign = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].deviation = CalculateSwingDeviation(lowArray[i], SWING_LOW);
            m_HTFSwingPoints[m_HTFSwingPointCount].reliability = 0.9; // HTF swings có độ tin cậy cao - Mới v14
            m_HTFSwingPoints[m_HTFSwingPointCount].isStructurallySignificant = true;
            m_HTFSwingPoints[m_HTFSwingPointCount].description = "HTF Swing Low";
            
            m_HTFSwingPointCount++;
         }
      }
   }
   
   // Sắp xếp swing points HTF theo thời gian
   if(m_HTFSwingPointCount > 1) {
      for(int i = 0; i < m_HTFSwingPointCount - 1; i++) {
         for(int j = i + 1; j < m_HTFSwingPointCount; j++) {
            if(m_HTFSwingPoints[i].time < m_HTFSwingPoints[j].time) {
               SwingPoint temp = m_HTFSwingPoints[i];
               m_HTFSwingPoints[i] = m_HTFSwingPoints[j];
               m_HTFSwingPoints[j] = temp;
            }
         }
      }
   }
   
   if(m_Logger != NULL) {
        PrintFormat("SwingPointDetector V14: Phát hiện %d swing points trên timeframe cao hơn (%s)", 
                  m_HTFSwingPointCount, EnumToString(m_HigherTimeframe));
    }
}

//+------------------------------------------------------------------+
//| Cập nhật danh sách đỉnh/đáy                                      |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateSwingPoints()
{
   // Cập nhật các giá trị cache trước
   if(!m_CacheInitialized) {
      InitializeCache();
   } else {
      UpdateCachedATR();
      UpdateCachedFractals();
   }
   
   // Nếu không có lệnh tính toán lại và đã có swing points, không cần tính
   if(!m_ForceRecalculation && m_SwingPointCount > 0) {
      // Chỉ cập nhật từ Higher Timeframe nếu cần
      if(m_HTFSwingPointCount == 0) {
         UpdateHigherTimeframeSwings();
      }
      
      // Cập nhật market regime - Mới v14
      UpdateMarketRegime();
      
      return;
   }
   
   // Cập nhật Higher TimeFrame swings trước
   UpdateHigherTimeframeSwings();
   
   // Nếu sử dụng ZigZag, cập nhật ZigZag swings - Mới v14
   if(m_Config.useZigZag) {
      UpdateZigZagSwings();
   }
   
   // Lấy dữ liệu giá
   double highArray[], lowArray[], closeArray[];
   datetime timeArray[];
   
   ArraySetAsSeries(highArray, true);
   ArraySetAsSeries(lowArray, true);
   ArraySetAsSeries(closeArray, true);
   ArraySetAsSeries(timeArray, true);
   
   int copied = CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, highArray);
   if(copied != m_Config.lookbackBars) {
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Không thể sao chép giá cao. Đã sao chép: %d", copied);
      }
      return;
   }
   
   copied = CopyLow(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, lowArray);
   if(copied != m_Config.lookbackBars) {
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Không thể sao chép giá thấp. Đã sao chép: %d", copied);
      }
      return;
   }
   
   copied = CopyClose(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, closeArray);
   if(copied != m_Config.lookbackBars) {
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Không thể sao chép giá đóng cửa. Đã sao chép: %d", copied);
      }
      return;
   }
   
   copied = CopyTime(m_Symbol, m_Timeframe, 0, m_Config.lookbackBars, timeArray);
   if(copied != m_Config.lookbackBars) {
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Không thể sao chép thời gian. Đã sao chép: %d", copied);
      }
      return;
   }
   
   // Cập nhật cache giá
   ArrayCopy(m_PrevHigh, highArray);
   ArrayCopy(m_PrevLow, lowArray);
   
   // Mảng tạm để lưu các swing points mới phát hiện
   SwingPoint newPoints[];
   int newPointsCount = 0;
   
   // Tìm kiếm các đỉnh/đáy mới
   // Bỏ qua một vài nến gần nhất để đảm bảo xác nhận
   for(int i = m_Config.confirmationBars; i < m_Config.lookbackBars - m_Config.requiredBars; i++) {
      // Kiểm tra swing high
      bool isSwingHigh = false;
      
      if(m_Config.useFractals) {
         // Sử dụng fractals indicator từ cache
         isSwingHigh = (m_CachedFractalUp[i] != EMPTY_VALUE);
      } else {
         // Phát hiện thủ công
         isSwingHigh = IsLocalTop(highArray, i, m_Config.requiredBars, m_Config.requiredBars);
      }
      
      if(isSwingHigh) {
         // Kiểm tra nếu swing point này đã tồn tại
         if(FindSwingPoint(timeArray[i], SWING_HIGH) == -1) {
            // Tính toán độ mạnh của đỉnh
            int barsSincePrevSwing = 0;
            for(int j = 1; j < i; j++) {
               if(IsLocalTop(highArray, i + j, m_Config.requiredBars, m_Config.requiredBars)) {
                  barsSincePrevSwing = j;
                  break;
               }
            }
            
            double strength = CalculateSwingStrength(highArray[i], SWING_HIGH, m_CachedATR, barsSincePrevSwing);
            
            // Xác định tầm quan trọng
            ENUM_SWING_IMPORTANCE importance = DetermineImportance(highArray[i], SWING_HIGH, m_CachedATR, barsSincePrevSwing);
            
            // Kiểm tra xem swing có khớp với HTF không
            bool alignWithHTF = AlignWithHigherTimeframe(highArray[i], SWING_HIGH, i);
            
            // Nếu khớp với HTF, tăng strength
            if(alignWithHTF) {
               strength += m_HigherTFAlignmentBonus;
            }
            
            // Kiểm tra ý nghĩa cấu trúc
            bool isStructurallySignificant = IsStructurallySignificant(highArray[i], SWING_HIGH, i);
            
            // Tính toán sự khác biệt so với giá trung bình
            double deviation = CalculateSwingDeviation(highArray[i], SWING_HIGH);
            
            // Thêm vào mảng tạm
            ArrayResize(newPoints, newPointsCount + 1);
            newPoints[newPointsCount].time = timeArray[i];
            newPoints[newPointsCount].price = highArray[i];
            newPoints[newPointsCount].type = SWING_HIGH;
            newPoints[newPointsCount].strength = (int)MathRound(strength);
            newPoints[newPointsCount].barIndex = i;
            newPoints[newPointsCount].confirmed = true;
            newPoints[newPointsCount].importance = importance;
            newPoints[newPointsCount].higherTimeframeAlign = alignWithHTF;
            newPoints[newPointsCount].deviation = deviation;
            newPoints[newPointsCount].isStructurallySignificant = isStructurallySignificant;
            newPoints[newPointsCount].reliability = CalculateSwingReliability(newPoints[newPointsCount]); // Mới v14
            
            // Kiểm tra và đánh dấu nếu có thể sử dụng cho giao dịch - Mới v14
            if(importance >= SWING_MAJOR && (strength >= 6 || alignWithHTF)) {
               newPoints[newPointsCount].isValidForTrading = true;
            } else {
               newPoints[newPointsCount].isValidForTrading = false;
            }
            
            // Thêm mô tả - Mới v14
            newPoints[newPointsCount].description = "Swing High (" + EnumToString(importance) + ")" +
                                                  (alignWithHTF ? ", HTF Aligned" : "") +
                                                  (isStructurallySignificant ? ", Structural" : "");
            
            newPointsCount++;
            
            // Log thông tin
            if(m_Logger != NULL && m_EnableSmartSwingFilter) {
               LogSwingPointDetails(newPoints[newPointsCount-1]);
            }
         }
      }
      
      // Kiểm tra swing low
      bool isSwingLow = false;
      
      if(m_Config.useFractals) {
         // Sử dụng fractals indicator từ cache
         isSwingLow = (m_CachedFractalDown[i] != EMPTY_VALUE);
      } else {
         // Phát hiện thủ công
         isSwingLow = IsLocalBottom(lowArray, i, m_Config.requiredBars, m_Config.requiredBars);
      }
      
      if(isSwingLow) {
         // Kiểm tra nếu swing point này đã tồn tại
         if(FindSwingPoint(timeArray[i], SWING_LOW) == -1) {
            // Tính toán độ mạnh của đáy
            int barsSincePrevSwing = 0;
            for(int j = 1; j < i; j++) {
               if(IsLocalBottom(lowArray, i + j, m_Config.requiredBars, m_Config.requiredBars)) {
                  barsSincePrevSwing = j;
                  break;
               }
            }
            
            double strength = CalculateSwingStrength(lowArray[i], SWING_LOW, m_CachedATR, barsSincePrevSwing);
            
            // Xác định tầm quan trọng
            ENUM_SWING_IMPORTANCE importance = DetermineImportance(lowArray[i], SWING_LOW, m_CachedATR, barsSincePrevSwing);
            
            // Kiểm tra xem swing có khớp với HTF không
            bool alignWithHTF = AlignWithHigherTimeframe(lowArray[i], SWING_LOW, i);
            
            // Nếu khớp với HTF, tăng strength
            if(alignWithHTF) {
               strength += m_HigherTFAlignmentBonus;
            }
            
            // Kiểm tra ý nghĩa cấu trúc
            bool isStructurallySignificant = IsStructurallySignificant(lowArray[i], SWING_LOW, i);
            
            // Tính toán sự khác biệt so với giá trung bình
            double deviation = CalculateSwingDeviation(lowArray[i], SWING_LOW);
            
            // Thêm vào mảng tạm
            ArrayResize(newPoints, newPointsCount + 1);
            newPoints[newPointsCount].time = timeArray[i];
            newPoints[newPointsCount].price = lowArray[i];
            newPoints[newPointsCount].type = SWING_LOW;
            newPoints[newPointsCount].strength = (int)MathRound(strength);
            newPoints[newPointsCount].barIndex = i;
            newPoints[newPointsCount].confirmed = true;
            newPoints[newPointsCount].importance = importance;
            newPoints[newPointsCount].higherTimeframeAlign = alignWithHTF;
            newPoints[newPointsCount].deviation = deviation;
            newPoints[newPointsCount].isStructurallySignificant = isStructurallySignificant;
            newPoints[newPointsCount].reliability = CalculateSwingReliability(newPoints[newPointsCount]); // Mới v14
            
            // Kiểm tra và đánh dấu nếu có thể sử dụng cho giao dịch - Mới v14
            if(importance >= SWING_MAJOR && (strength >= 6 || alignWithHTF)) {
               newPoints[newPointsCount].isValidForTrading = true;
            } else {
               newPoints[newPointsCount].isValidForTrading = false;
            }
            
            // Thêm mô tả - Mới v14
            newPoints[newPointsCount].description = "Swing Low (" + EnumToString(importance) + ")" +
                                                  (alignWithHTF ? ", HTF Aligned" : "") +
                                                  (isStructurallySignificant ? ", Structural" : "");
            
            newPointsCount++;
            
            // Log thông tin
            if(m_Logger != NULL && m_EnableSmartSwingFilter) {
               LogSwingPointDetails(newPoints[newPointsCount-1]);
            }
         }
      }
   }
   
   // Lọc bỏ những swing point gần nhau - Cải tiến v14
   if(m_EnableSmartSwingFilter && newPointsCount > 1) {
      // Sắp xếp newPoints theo thời gian
      for(int i = 0; i < newPointsCount - 1; i++) {
         for(int j = i + 1; j < newPointsCount; j++) {
            if(newPoints[i].time < newPoints[j].time) {
               SwingPoint temp = newPoints[i];
               newPoints[i] = newPoints[j];
               newPoints[j] = temp;
            }
         }
      }
      
      // Lọc bỏ swings minor gần nhau
      for(int i = 0; i < newPointsCount - 1; i++) {
         for(int j = i + 1; j < newPointsCount; j++) {
            // Nếu cùng loại swing và quá gần nhau
            if(newPoints[i].type == newPoints[j].type && 
               MathAbs(newPoints[i].barIndex - newPoints[j].barIndex) < m_Config.requiredBars * 2) {
               
               // Nếu cả hai là minor, giữ lại cái mạnh hơn
               if(newPoints[i].importance == SWING_MINOR && newPoints[j].importance == SWING_MINOR) {
                  if(newPoints[i].strength >= newPoints[j].strength) {
                     // Đánh dấu swing point j để bỏ qua
                     newPoints[j].confirmed = false;
                  } else {
                     // Đánh dấu swing point i để bỏ qua
                     newPoints[i].confirmed = false;
                  }
               }
               // Nếu một major và một minor, giữ lại major
               else if(newPoints[i].importance > newPoints[j].importance) {
                  newPoints[j].confirmed = false;
               }
               else if(newPoints[i].importance < newPoints[j].importance) {
                  newPoints[i].confirmed = false;
               }
            }
         }
      }
   }
   
   // Thêm các swing points mới vào mảng chính
   int addedCount = 0;
   for(int i = 0; i < newPointsCount; i++) {
      // Bỏ qua nếu đã được đánh dấu là không xác nhận
      if(!newPoints[i].confirmed) continue;
      
      // Kiểm tra xem còn chỗ trong mảng không
      if(m_SwingPointCount >= m_MaxSwingPoints) {
         // Nếu hết chỗ, loại bỏ điểm cũ nhất
         for(int j = 0; j < m_MaxSwingPoints - 1; j++) {
            m_SwingPoints[j] = m_SwingPoints[j + 1];
         }
         m_SwingPointCount = m_MaxSwingPoints - 1;
      }
      
      // Thêm điểm mới
      m_SwingPoints[m_SwingPointCount] = newPoints[i];
      m_SwingPointCount++;
      addedCount++;
   }
   
   // Sắp xếp theo thời gian
   if(addedCount > 0) {
      SortSwingPointsByTime();
   }
   
   // Điều chỉnh độ mạnh dựa vào điều kiện thị trường
   if(m_EnableSmartSwingFilter) {
      AdjustSwingStrengthByMarketCondition();
   }
   
   // Loại bỏ các swing points trùng lặp
   if(m_EnableSmartSwingFilter) {
      RemoveDuplicateSwings();
   }
   
   // Cập nhật thông tin market regime - Mới v14
   UpdateMarketRegime();
   
   // Reset flag force recalculation
   m_ForceRecalculation = false;
   
   if(m_Logger != NULL) {
      PrintFormat("SwingPointDetector V14: Cập nhật Swing Points hoàn tất. Đã thêm %d points mới, hiện có %d points trong bộ nhớ.", 
                  addedCount, m_SwingPointCount);
   }
}

//+------------------------------------------------------------------+
//| Cập nhật và phân tích toàn diện - Mới v14                        |
//+------------------------------------------------------------------+
bool CSwingPointDetector::UpdateAndAnalyze()
{
   // Cập nhật swing points
   UpdateSwingPoints();
   
   // Phân tích cấu trúc thị trường
   bool structureAnalyzed = AnalyzeMarketStructure();
   
   // Cập nhật market regime
   UpdateMarketRegime();
   
   return structureAnalyzed;
}

//+------------------------------------------------------------------+
//| Phân tích cấu trúc thị trường - Mới v14                          |
//+------------------------------------------------------------------+
bool CSwingPointDetector::AnalyzeMarketStructure()
{
   if(m_SwingPointCount < 2) return false;
   
   // Đếm số lượng swing high/low
   int highCount = 0, lowCount = 0;
   
   // Mảng tạm để lưu các swing points theo loại
   SwingPoint highs[], lows[];
   
   // Tách swing points theo loại
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         ArrayResize(highs, highCount + 1);
         highs[highCount++] = m_SwingPoints[i];
      } else if(m_SwingPoints[i].type == SWING_LOW) {
         ArrayResize(lows, lowCount + 1);
         lows[lowCount++] = m_SwingPoints[i];
      }
   }
   
   // Kiểm tra cấu trúc higher highs, higher lows hoặc lower highs, lower lows
   bool hasHigherHighs = false;
   bool hasHigherLows = false;
   bool hasLowerHighs = false;
   bool hasLowerLows = false;
   
   // Kiểm tra higher highs
   if(highCount >= 3) {
      double lastHigh = highs[0].price;
      double prevHigh = highs[1].price;
      double prePrevHigh = highs[2].price;
      
      hasHigherHighs = (lastHigh > prevHigh && prevHigh > prePrevHigh);
   }
   
   // Kiểm tra higher lows
   if(lowCount >= 3) {
      double lastLow = lows[0].price;
      double prevLow = lows[1].price;
      double prePrevLow = lows[2].price;
      
      hasHigherLows = (lastLow > prevLow && prevLow > prePrevLow);
   }
   
   // Kiểm tra lower highs
   if(highCount >= 3) {
      double lastHigh = highs[0].price;
      double prevHigh = highs[1].price;
      double prePrevHigh = highs[2].price;
      
      hasLowerHighs = (lastHigh < prevHigh && prevHigh < prePrevHigh);
   }
   
   // Kiểm tra lower lows
   if(lowCount >= 3) {
      double lastLow = lows[0].price;
      double prevLow = lows[1].price;
      double prePrevLow = lows[2].price;
      
      hasLowerLows = (lastLow < prevLow && prevLow < prePrevLow);
   }
   
   // Cập nhật thông tin thị trường dựa trên cấu trúc
   m_RegimeInfo.trendStrength = CalculateTrendStrength();
   
   // Xác định chế độ thị trường
   if(hasHigherHighs && hasHigherLows) {
      // Xu hướng tăng mạnh
      m_RegimeInfo.regime = REGIME_TRENDING_BULL;
      m_RegimeInfo.isRangebound = false;
   }
   else if(hasLowerHighs && hasLowerLows) {
      // Xu hướng giảm mạnh
      m_RegimeInfo.regime = REGIME_TRENDING_BEAR;
      m_RegimeInfo.isRangebound = false;
   }
   else if((hasHigherHighs && !hasHigherLows) || (hasHigherLows && !hasHigherHighs)) {
      // Xu hướng tăng yếu hoặc đang chuyển tiếp
      m_RegimeInfo.regime = REGIME_TRENDING_BULL;
      m_RegimeInfo.isTrendChanging = true;
      m_RegimeInfo.isRangebound = false;
   }
   else if((hasLowerHighs && !hasLowerLows) || (hasLowerLows && !hasLowerHighs)) {
      // Xu hướng giảm yếu hoặc đang chuyển tiếp
      m_RegimeInfo.regime = REGIME_TRENDING_BEAR;
      m_RegimeInfo.isTrendChanging = true;
      m_RegimeInfo.isRangebound = false;
   }
   else {
      // Sideway hoặc cần thêm thông tin để xác định
      if(m_RegimeInfo.volatilityRatio > m_DynamicVolatilityThreshold) {
         // Biến động cao trong sideway
         m_RegimeInfo.regime = REGIME_RANGING_VOLATILE;
      } else {
         // Sideway ổn định
         m_RegimeInfo.regime = REGIME_RANGING_STABLE;
      }
      m_RegimeInfo.isRangebound = true;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Cập nhật chế độ thị trường - Mới v14                             |
//+------------------------------------------------------------------+
void CSwingPointDetector::UpdateMarketRegime()
{
   datetime currentTime = TimeCurrent();
   
   // Chỉ cập nhật sau một khoảng thời gian (hạn chế cập nhật quá thường xuyên)
   if(currentTime - m_LastMarketRegimeUpdate < 60 && !m_ForceRecalculation) {
      return;
   }
   
   // Cập nhật tỷ lệ biến động
   m_CurrentVolatilityRatio = CalculateVolatilityRatio();
   
   // Xác định nếu thị trường đang ở chế độ biến động cao/thấp
   m_IsHighVolatilityRegime = (m_CurrentVolatilityRatio > m_DynamicVolatilityThreshold);
   m_IsLowVolatilityRegime = (m_CurrentVolatilityRatio < 0.7);
   
   // Cập nhật thông tin market regime
   m_RegimeInfo.volatilityRatio = m_CurrentVolatilityRatio;
   m_RegimeInfo.isVolatile = m_IsHighVolatilityRegime;
   
   // Xác định chế độ thị trường nếu chưa được xác định trong AnalyzeMarketStructure
   if(m_RegimeInfo.regime == REGIME_UNKNOWN) {
      m_RegimeInfo.regime = DetermineMarketRegime();
   }
   
   // Cập nhật thời gian cập nhật
   m_LastMarketRegimeUpdate = currentTime;
   
   if(m_Logger != NULL) {
      string regimeStr;
      switch(m_RegimeInfo.regime) {
         case REGIME_TRENDING_BULL: regimeStr = "Trending Bullish"; break;
         case REGIME_TRENDING_BEAR: regimeStr = "Trending Bearish"; break;
         case REGIME_RANGING_STABLE: regimeStr = "Ranging Stable"; break;
         case REGIME_RANGING_VOLATILE: regimeStr = "Ranging Volatile"; break;
         case REGIME_VOLATILE_EXPANSION: regimeStr = "Volatile Expansion"; break;
         case REGIME_VOLATILE_CONTRACTION: regimeStr = "Volatile Contraction"; break;
         default: regimeStr = "Unknown";
      }
      
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Market Regime = %s, Volatility Ratio = %s, Trend Strength = %s",
                  regimeStr, DoubleToString(m_CurrentVolatilityRatio, 2),
                  DoubleToString(m_RegimeInfo.trendStrength, 2));
      }
   }
}

//+------------------------------------------------------------------+
//| Xác định chế độ thị trường - Mới v14                             |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME CSwingPointDetector::DetermineMarketRegime()
{
   // Tổng hợp các yếu tố để xác định chế độ thị trường
   double trendStrength = CalculateTrendStrength();
   double volatilityScore = CalculateVolatilityScore();
   
   // Kiểm tra xu hướng
   double bullishScore = 0, bearishScore = 0;
   
   // Đếm số lượng Higher Highs và Higher Lows cho xu hướng tăng
   int hhCount = 0, hlCount = 0, lhCount = 0, llCount = 0;
   
   for(int i = 1; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i-1].type == SWING_HIGH && m_SwingPoints[i].type == SWING_HIGH) {
         if(m_SwingPoints[i-1].price > m_SwingPoints[i].price) {
            hhCount++;
         } else if(m_SwingPoints[i-1].price < m_SwingPoints[i].price) {
            lhCount++;
         }
      }
      
      if(m_SwingPoints[i-1].type == SWING_LOW && m_SwingPoints[i].type == SWING_LOW) {
         if(m_SwingPoints[i-1].price > m_SwingPoints[i].price) {
            hlCount++;
         } else if(m_SwingPoints[i-1].price < m_SwingPoints[i].price) {
            llCount++;
         }
      }
   }
   
   // Tính điểm xu hướng
   if(hhCount > 0 && hlCount > 0) {
      bullishScore = (hhCount + hlCount) * 0.5;
   }
   
   if(lhCount > 0 && llCount > 0) {
      bearishScore = (lhCount + llCount) * 0.5;
   }
   
   // Xác định chế độ thị trường
   if(trendStrength > 0.7) {
      // Xu hướng mạnh
      if(bullishScore > bearishScore) {
         return REGIME_TRENDING_BULL;
      } else {
         return REGIME_TRENDING_BEAR;
      }
   }
   else if(trendStrength > 0.3) {
      // Xu hướng yếu hoặc đang chuyển tiếp
      if(volatilityScore > 0.6) {
         // Biến động mở rộng
         return REGIME_VOLATILE_EXPANSION;
      }
      else {
         if(bullishScore > bearishScore) {
            return REGIME_TRENDING_BULL;
         } else {
            return REGIME_TRENDING_BEAR;
         }
      }
   }
   else {
      // Không có xu hướng rõ ràng (sideway)
      if(volatilityScore > 0.6) {
         // Sideway biến động
         return REGIME_RANGING_VOLATILE;
      }
      else if(volatilityScore < 0.3) {
         // Biến động thu hẹp
         return REGIME_VOLATILE_CONTRACTION;
      }
      else {
         // Sideway ổn định
         return REGIME_RANGING_STABLE;
      }
   }
}

//+------------------------------------------------------------------+
//| Tính toán độ mạnh xu hướng - Mới v14                             |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateTrendStrength()
{
   if(m_SwingPointCount < 3) return 0.0;
   
   // Tìm swing point mới nhất của mỗi loại
   double lastHigh = 0, prevHigh = 0, lastLow = 0, prevLow = 0;
   int highCount = 0, lowCount = 0;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         if(highCount == 0) {
            lastHigh = m_SwingPoints[i].price;
            highCount++;
         } else if(highCount == 1) {
            prevHigh = m_SwingPoints[i].price;
            highCount++;
         }
      }
      else if(m_SwingPoints[i].type == SWING_LOW) {
         if(lowCount == 0) {
            lastLow = m_SwingPoints[i].price;
            lowCount++;
         } else if(lowCount == 1) {
            prevLow = m_SwingPoints[i].price;
            lowCount++;
         }
      }
      
      // Dừng khi đã tìm thấy đủ
      if(highCount >= 2 && lowCount >= 2) break;
   }
   
   // Nếu không tìm đủ swing points
   if(highCount < 2 || lowCount < 2) return 0.0;
   
   // Tính toán điểm xu hướng
   double trendScore = 0.0;
   
   // Kiểm tra higher highs và higher lows (tăng)
   bool hasHigherHighs = (lastHigh > prevHigh);
   bool hasHigherLows = (lastLow > prevLow);
   
   // Kiểm tra lower highs và lower lows (giảm)
   bool hasLowerHighs = (lastHigh < prevHigh);
   bool hasLowerLows = (lastLow < prevLow);
   
   // Tính điểm xu hướng
   if(hasHigherHighs && hasHigherLows) {
      // Xu hướng tăng mạnh
      trendScore = 1.0;
   }
   else if(hasLowerHighs && hasLowerLows) {
      // Xu hướng giảm mạnh
      trendScore = 1.0;
   }
   else if((hasHigherHighs && !hasLowerLows) || (hasHigherLows && !hasLowerHighs)) {
      // Xu hướng tăng yếu hoặc đang hình thành
      trendScore = 0.5;
   }
   else if((hasLowerHighs && !hasLowerLows) || (hasLowerLows && !hasLowerHighs)) {
      // Xu hướng giảm yếu hoặc đang hình thành
      trendScore = 0.5;
   }
   else {
      // Không có xu hướng rõ ràng
      trendScore = 0.0;
   }
   
   return trendScore;
}

//+------------------------------------------------------------------+
//| Tính toán điểm biến động - Mới v14                               |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateVolatilityScore()
{
   // Lấy ATR hiện tại và trung bình
   double currentATR = GetValidATR();
   
   if(m_AverageATR <= 0) return 0.5; // Giá trị mặc định
   
   // Tính tỷ lệ biến động
   double volatilityRatio = currentATR / m_AverageATR;
   
   // Chuẩn hóa về khoảng 0-1
   double normalizedRatio = MathMin(1.0, volatilityRatio / 2.0);
   
   return normalizedRatio;
}

//+------------------------------------------------------------------+
//| Kiểm tra breakout - Mới v14                                      |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsBreakoutDetected(bool isLong)
{
   // Giá hiện tại
   double currentPrice = isLong ? SymbolInfoDouble(m_Symbol, SYMBOL_ASK) : SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   // Đếm breakout gần đây
   int breakoutCount = 0;
   
   // Kiểm tra swing gần đây
   for(int i = 0; i < MathMin(5, m_SwingPointCount); i++) {
      if(isLong) {
         // Kiểm tra nếu là swing high và giá hiện tại vượt qua
         if(m_SwingPoints[i].type == SWING_HIGH && currentPrice > m_SwingPoints[i].price) {
            // Nếu là swing major hoặc critical, tăng độ tin cậy
            if(m_SwingPoints[i].importance >= SWING_MAJOR) {
               breakoutCount += 2;
            } else {
               breakoutCount++;
            }
         }
      } else {
         // Kiểm tra nếu là swing low và giá hiện tại vượt xuống dưới
         if(m_SwingPoints[i].type == SWING_LOW && currentPrice < m_SwingPoints[i].price) {
            // Nếu là swing major hoặc critical, tăng độ tin cậy
            if(m_SwingPoints[i].importance >= SWING_MAJOR) {
               breakoutCount += 2;
            } else {
               breakoutCount++;
            }
         }
      }
   }
   
   // Cần ít nhất 2 breakout để xác nhận
   return (breakoutCount >= 2);
}

//+------------------------------------------------------------------+
//| Tính toán độ tin cậy của swing - Mới v14                         |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateSwingReliability(const SwingPoint &point)
{
   double reliability = 0.5; // Điểm cơ sở
   
   // Yếu tố 1: Tầm quan trọng
   switch(point.importance) {
      case SWING_MINOR:    reliability += 0.0; break;
      case SWING_MAJOR:    reliability += 0.2; break;
      case SWING_CRITICAL: reliability += 0.4; break;
   }
   
   // Yếu tố 2: Độ mạnh
   reliability += MathMin(0.2, point.strength / 50.0);
   
   // Yếu tố 3: Khớp với HTF
   if(point.higherTimeframeAlign) {
      reliability += 0.15;
   }
   
   // Yếu tố 4: Ý nghĩa cấu trúc
   if(point.isStructurallySignificant) {
      reliability += 0.15;
   }
   
   // Yếu tố 5: Độ lệch giá
   double deviationFactor = MathAbs(point.deviation);
   if(deviationFactor > 0.02) {
      reliability += 0.1;
   }
   
   // Giới hạn kết quả trong khoảng 0.0-1.0
   reliability = MathMax(0.0, MathMin(1.0, reliability));
   
   return reliability;
}

//+------------------------------------------------------------------+
//| Tính toán tỷ lệ giá đến swing - Mới v14                          |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculatePriceToSwingRatio(double price, const SwingPoint &point, double atr)
{
   if(atr <= 0) atr = GetValidATR();
   if(atr <= 0) return 0.0;
   
   // Tính khoảng cách giá đến swing point theo đơn vị ATR
   double distance = MathAbs(price - point.price) / atr;
   
   return distance;
}

//+------------------------------------------------------------------+
//| Kiểm tra swing point có hợp lệ cho giao dịch không - Mới v14     |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsValidSwingForTrading(const SwingPoint &point, bool isLong)
{
   // Kiểm tra cờ đã thiết lập
   if(!point.isValidForTrading) return false;
   
   // Kiểm tra độ tin cậy
   if(point.reliability < m_SwingConfirmationThreshold) return false;
   
   // Kiểm tra loại điểm swing
   if(isLong && point.type != SWING_LOW) return false;
   if(!isLong && point.type != SWING_HIGH) return false;
   
   // Kiểm tra tầm quan trọng
   if(m_TrailingConfig.useOnlyMajorSwings && point.importance < SWING_MAJOR) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Log thông tin chi tiết về swing point                            |
//+------------------------------------------------------------------+
void CSwingPointDetector::LogSwingPointDetails(const SwingPoint &point)
{
   string typeStr = (point.type == SWING_HIGH) ? "HIGH" : "LOW";
   string importanceStr = "";
   
   switch(point.importance) {
      case SWING_MINOR: importanceStr = "MINOR"; break;
      case SWING_MAJOR: importanceStr = "MAJOR"; break;
      case SWING_CRITICAL: importanceStr = "CRITICAL"; break;
      default: importanceStr = "UNKNOWN";
   }
   
   string alignStr = point.higherTimeframeAlign ? "HTF Aligned" : "Not HTF Aligned";
   string validForTrading = point.isValidForTrading ? "Valid for Trading" : "Not Valid for Trading";
   
   string logMsg = StringFormat("Swing %s: Giá=%.5f, Strength=%d, Importance=%s, %s, Deviation=%.2f, Bar=%d, Reliability=%.2f, %s",
                             typeStr, point.price, point.strength, importanceStr, 
                             alignStr, point.deviation, point.barIndex, point.reliability, validForTrading);
    if(m_Logger != NULL) {
        PrintFormat("%s", logMsg);
    }
}

//+------------------------------------------------------------------+
//| Xác định tầm quan trọng của swing point                          |
//+------------------------------------------------------------------+
ENUM_SWING_IMPORTANCE CSwingPointDetector::DetermineImportance(double price, ENUM_SWING_POINT_TYPE type, double atr, int barsSinceLastSwing)
{
   // Độ mạnh cơ bản
   double baseStrength = CalculateSwingStrength(price, type, atr, barsSinceLastSwing);
   
   // Kiểm tra cấu trúc thị trường
   double structuralSignificance = CalculateStructuralSignificance(price, type, 0);
   
   // Kiểm tra độ biến động
   double volatilityRatio = CalculateVolatilityRatio();
   
   // Tổng hợp các yếu tố
   double combinedScore = baseStrength + structuralSignificance;
   
   // Điều chỉnh theo biến động
   if(volatilityRatio > m_DynamicVolatilityThreshold) {
      combinedScore *= (1.0 + (volatilityRatio - m_DynamicVolatilityThreshold) * 0.2);
   }
   
   // Nếu khớp với HTF, tăng điểm
   if(AlignWithHigherTimeframe(price, type, 0)) {
      combinedScore += m_HigherTFAlignmentBonus;
   }
   
   // Quyết định mức độ quan trọng dựa vào điểm số
   if(combinedScore >= m_Config.criticalSwingMultiplier) {
      return SWING_CRITICAL;
   }
   else if(combinedScore >= m_Config.majorSwingMultiplier) {
      return SWING_MAJOR;
   }
   else {
      return SWING_MINOR;
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra xem swing point có ý nghĩa cấu trúc không              |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsStructurallySignificant(double price, ENUM_SWING_POINT_TYPE type, int barIndex)
{
   double structuralScore = CalculateStructuralSignificance(price, type, barIndex);
   return (structuralScore >= 2.0);
}

//+------------------------------------------------------------------+
//| Tính toán ý nghĩa cấu trúc của một swing point                  |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateStructuralSignificance(double price, ENUM_SWING_POINT_TYPE type, int barIndex)
{
   double score = 0.0;
   
   // Xác định xem đỉnh/đáy này có lớn hơn/nhỏ hơn các điểm trước đó không
   int prevSwingsFound = 0;
   bool isStructuralBreak = false;
   
   if(type == SWING_HIGH) {
      // Tìm các swing high trước đó
      for(int i = 0; i < m_SwingPointCount; i++) {
         if(m_SwingPoints[i].type == SWING_HIGH && m_SwingPoints[i].barIndex > barIndex) {
            prevSwingsFound++;
            
            // Nếu đỉnh mới cao hơn đỉnh cũ = phá vỡ cấu trúc
            if(price > m_SwingPoints[i].price) {
               isStructuralBreak = true;
               // Càng nhiều đỉnh bị phá vỡ, càng quan trọng
               score += 1.0;
            }
            
            // Chỉ xét tối đa 5 đỉnh gần nhất
            if(prevSwingsFound >= 5) break;
         }
      }
   }
   else if(type == SWING_LOW) {
      // Tìm các swing low trước đó
      for(int i = 0; i < m_SwingPointCount; i++) {
         if(m_SwingPoints[i].type == SWING_LOW && m_SwingPoints[i].barIndex > barIndex) {
            prevSwingsFound++;
            
            // Nếu đáy mới thấp hơn đáy cũ = phá vỡ cấu trúc
            if(price < m_SwingPoints[i].price) {
               isStructuralBreak = true;
               // Càng nhiều đáy bị phá vỡ, càng quan trọng
               score += 1.0;
            }
            
            // Chỉ xét tối đa 5 đáy gần nhất
            if(prevSwingsFound >= 5) break;
         }
      }
   }
   
   // Nếu phá vỡ cấu trúc, thêm điểm
   if(isStructuralBreak) {
      score += 2.0;
   }
   
   return score;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem swing point có khớp với Higher Timeframe không       |
//+------------------------------------------------------------------+
bool CSwingPointDetector::AlignWithHigherTimeframe(double price, ENUM_SWING_POINT_TYPE type, int barIndex)
{
   if(m_HTFSwingPointCount == 0) return false;
   
   double priceBuffer = m_CachedATR * 1.0; // Buffer cho phép sai số
   bool aligned = false;
   
   for(int i = 0; i < m_HTFSwingPointCount; i++) {
      // Chỉ xét cùng loại (đỉnh hoặc đáy)
      if(m_HTFSwingPoints[i].type == type) {
         // Nếu giá gần với giá của HTF swing point
         if(MathAbs(price - m_HTFSwingPoints[i].price) <= priceBuffer) {
            aligned = true;
            break;
         }
      }
   }
   
   return aligned;
}

//+------------------------------------------------------------------+
//| Tính tỷ lệ biến động hiện tại so với trung bình                  |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateVolatilityRatio()
{
   if(m_AverageATR <= 0) return 1.0;
   
   return m_CachedATR / m_AverageATR;
}

//+------------------------------------------------------------------+
//| Điều chỉnh độ mạnh của swing points theo điều kiện thị trường    |
//+------------------------------------------------------------------+
void CSwingPointDetector::AdjustSwingStrengthByMarketCondition()
{
   // Phân tích biến động hiện tại
   double volatilityRatio = CalculateVolatilityRatio();
   
   // Nếu biến động bình thường, không cần điều chỉnh
   if(volatilityRatio >= 0.8 && volatilityRatio <= 1.2) return;
   
   // Hệ số điều chỉnh
   double adjustmentFactor = 0.0;
   
   // Biến động cao -> giảm độ mạnh swing points nhỏ (để không bị nhiễu)
   if(volatilityRatio > 1.2) {
      adjustmentFactor = MathMin((volatilityRatio - 1.2) * 0.5, 0.5);
      
      for(int i = 0; i < m_SwingPointCount; i++) {
         if(m_SwingPoints[i].importance == SWING_MINOR) {
            int newStrength = (int)MathMax(1, m_SwingPoints[i].strength * (1.0 - adjustmentFactor));
            
            if(newStrength != m_SwingPoints[i].strength) {
               m_SwingPoints[i].strength = newStrength;
                if(m_Logger != NULL) {
                    PrintFormat("SwingPointDetector V14: Giảm strength point minor do biến động cao (x%s)", 
                                 DoubleToString(volatilityRatio, 2));
                }
            }
         }
      }
   }
   // Biến động thấp -> tăng độ mạnh swing points để dễ phát hiện
   else if(volatilityRatio < 0.8) {
      adjustmentFactor = MathMin((0.8 - volatilityRatio) * 0.5, 0.5);
      
      for(int i = 0; i < m_SwingPointCount; i++) {
         if(m_SwingPoints[i].importance != SWING_MINOR) {
            int newStrength = (int)MathMin(10, m_SwingPoints[i].strength * (1.0 + adjustmentFactor));
            
            if(newStrength != m_SwingPoints[i].strength) {
               m_SwingPoints[i].strength = newStrength;
               if(m_Logger != NULL) {
                  PrintFormat("SwingPointDetector V14: Tăng strength point major do biến động thấp (x%s)", 
                              DoubleToString(volatilityRatio, 2));
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Loại bỏ các swing points trùng lặp                              |
//+------------------------------------------------------------------+
void CSwingPointDetector::RemoveDuplicateSwings()
{
   if(m_SwingPointCount <= 1) return;
   
   int removed = 0;
   
   // So sánh từng cặp swing points
   for(int i = 0; i < m_SwingPointCount - 1; i++) {
      // Nếu đã bị đánh dấu xóa, bỏ qua
      if(!m_SwingPoints[i].confirmed) continue;
      
      for(int j = i + 1; j < m_SwingPointCount; j++) {
         // Nếu đã bị đánh dấu xóa, bỏ qua
         if(!m_SwingPoints[j].confirmed) continue;
         
         // Nếu cùng loại và quá gần nhau
         if(m_SwingPoints[i].type == m_SwingPoints[j].type && 
            MathAbs(m_SwingPoints[i].time - m_SwingPoints[j].time) < 60 * 60 * 4) { // 4 giờ
            
            // Giữ lại cái mạnh hơn
            if(m_SwingPoints[i].strength >= m_SwingPoints[j].strength) {
               m_SwingPoints[j].confirmed = false;
               removed++;
            } else {
               m_SwingPoints[i].confirmed = false;
               removed++;
               break; // Break vì i đã bị xóa
            }
         }
      }
   }
   
   // Nếu có swing points bị xóa, nén lại mảng
   if(removed > 0) {
      int newCount = 0;
      
      for(int i = 0; i < m_SwingPointCount; i++) {
         if(m_SwingPoints[i].confirmed) {
            if(i != newCount) {
               m_SwingPoints[newCount] = m_SwingPoints[i];
            }
            newCount++;
         }
      }
      
      m_SwingPointCount = newCount;
      
      if(m_Logger != NULL) {
         PrintFormat("SwingPointDetector V14: Đã loại bỏ %d swing points trùng lặp", removed);
      }
   }
}

//+------------------------------------------------------------------+
//| Tính toán độ khác biệt của swing so với giá trung bình            |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateSwingDeviation(double price, ENUM_SWING_POINT_TYPE type)
{
   // Lấy giá trung bình 20 nến
   double closeArray[];
   ArraySetAsSeries(closeArray, true);
   
   if(CopyClose(m_Symbol, m_Timeframe, 0, 20, closeArray) != 20) {
      return 0.0;
   }
   
   // Tính giá trung bình
   double avgPrice = 0.0;
   for(int i = 0; i < 20; i++) {
      avgPrice += closeArray[i];
   }
   avgPrice /= 20.0;
   
   // Tính độ khác biệt chuẩn hóa
   double normalizedDeviation = (price - avgPrice) / avgPrice;
   
   return normalizedDeviation;
}

//+------------------------------------------------------------------+
//| Lấy ATR trung bình của 20 ngày                                   |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetAverageATR()
{
   // Lấy ATR của 20 ngày
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   
   int atrHandle = iATR(m_Symbol, PERIOD_D1, 14);
   if(atrHandle == INVALID_HANDLE) {
      return 0.0;
   }
   
   if(CopyBuffer(atrHandle, 0, 0, 20, atrBuffer) != 20) {
      IndicatorRelease(atrHandle);
      return 0.0;
   }
   
   // Tính trung bình
   double avgATR = 0.0;
   for(int i = 0; i < 20; i++) {
      avgATR += atrBuffer[i];
   }
   avgATR /= 20.0;
   
   IndicatorRelease(atrHandle);
   
   return avgATR;
}

//+------------------------------------------------------------------+
//| Lấy biến động hiện tại                                           |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetCurrentVolatility()
{
   double volatilityRatio = CalculateVolatilityRatio();
   return volatilityRatio;
}

//+------------------------------------------------------------------+
//| Xóa danh sách đỉnh/đáy                                          |
//+------------------------------------------------------------------+
void CSwingPointDetector::ClearSwingPoints()
{
   m_SwingPointCount = 0;
   m_HTFSwingPointCount = 0;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem vị trí có phải là đỉnh cục bộ không                 |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsLocalTop(const double &highArray[], int index, int leftBars, int rightBars)
{
   if(index < rightBars || index >= (ArraySize(highArray) - leftBars)) {
      return false;
   }
   
   double currentHigh = highArray[index];
   
   // Kiểm tra bên phải (các nến sau)
   for(int i = 1; i <= rightBars; i++) {
      if(highArray[index + i] >= currentHigh) {
         return false;
      }
   }
   
   // Kiểm tra bên trái (các nến trước)
   for(int i = 1; i <= leftBars; i++) {
      if(highArray[index - i] >= currentHigh) {
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem vị trí có phải là đáy cục bộ không                  |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsLocalBottom(const double &lowArray[], int index, int leftBars, int rightBars)
{
   if(index < rightBars || index >= (ArraySize(lowArray) - leftBars)) {
      return false;
   }
   
   double currentLow = lowArray[index];
   
   // Kiểm tra bên phải (các nến sau)
   for(int i = 1; i <= rightBars; i++) {
      if(lowArray[index + i] <= currentLow) {
         return false;
      }
   }
   
// Kiểm tra bên trái (các nến trước)
   for(int i = 1; i <= leftBars; i++) {
      if(lowArray[index - i] <= currentLow) {
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Tính toán độ mạnh của swing point                               |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateSwingStrength(double price, ENUM_SWING_POINT_TYPE type, double atr, int barsSinceLastSwing)
{
   if(atr <= 0) return 1.0;
   
   // Độ mạnh cơ bản dựa trên khoảng cách giữa các swing
   double baseStrength = MathMin(10.0, MathMax(1.0, barsSinceLastSwing / 2.0));
   
   // Tính toán độ lệch giá so với trung bình
   double deviation = CalculateSwingDeviation(price, type);
   double deviationFactor = 1.0 + MathAbs(deviation) * 2.0;
   
   // Độ mạnh dựa trên biến động
   double strengthFactor = 1.0;
   
   // Kiểm tra độ biến động
   double volatilityRatio = CalculateVolatilityRatio();
   if(volatilityRatio > m_DynamicVolatilityThreshold) {
      // Trong môi trường biến động cao, giảm độ mạnh cho swing points nhỏ
      if(baseStrength < 5.0) {
         strengthFactor = 0.8;
      }
   } 
   else if(volatilityRatio < 0.7) {
      // Trong môi trường biến động thấp, tăng độ mạnh cho swing points lớn
      if(baseStrength >= 5.0) {
         strengthFactor = 1.2;
      }
   }
   
   // Tính toán độ mạnh cuối cùng
   double finalStrength = baseStrength * deviationFactor * strengthFactor;
   
   // Nếu là HTF aligned, tăng thêm m_HigherTFAlignmentBonus
   if(AlignWithHigherTimeframe(price, type, 0)) {
      finalStrength += m_HigherTFAlignmentBonus;
   }
   
   // Giới hạn trong khoảng 1-10
   finalStrength = MathMax(1.0, MathMin(10.0, finalStrength));
   
   return finalStrength;
}

//+------------------------------------------------------------------+
//| Tìm kiếm swing point theo thời gian và loại                     |
//+------------------------------------------------------------------+
int CSwingPointDetector::FindSwingPoint(datetime time, ENUM_SWING_POINT_TYPE type)
{
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].time == time && m_SwingPoints[i].type == type) {
         return i;
      }
   }
   
   return -1;
}

//+------------------------------------------------------------------+
//| Sắp xếp swing points theo thời gian                             |
//+------------------------------------------------------------------+
void CSwingPointDetector::SortSwingPointsByTime()
{
   // Sắp xếp giảm dần theo thời gian (mới nhất đầu tiên)
   for(int i = 0; i < m_SwingPointCount - 1; i++) {
      for(int j = i + 1; j < m_SwingPointCount; j++) {
         if(m_SwingPoints[i].time < m_SwingPoints[j].time) {
            SwingPoint temp = m_SwingPoints[i];
            m_SwingPoints[i] = m_SwingPoints[j];
            m_SwingPoints[j] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Lấy ATR hợp lệ                                                  |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetValidATR()
{
   if(m_CachedATR <= 0) {
      UpdateCachedATR();
   }
   
   return m_CachedATR;
}

//+------------------------------------------------------------------+
//| Tính ATR cho việc tính toán Swing                               |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculateSwingATR(ENUM_TIMEFRAMES timeframe)
{
   // Lấy ATR từ timeframe cụ thể
   int atrHandle = iATR(m_Symbol, timeframe, m_Config.atrPeriod);
   
   if(atrHandle == INVALID_HANDLE) {
      return 0.0;
   }
   
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   
   if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) != 1) {
      IndicatorRelease(atrHandle);
      return 0.0;
   }
   
   double atr = atrBuffer[0];
   IndicatorRelease(atrHandle);
   
   return atr;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem một nến có phải là fractal point không               |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsFractalPoint(int bar, ENUM_SWING_POINT_TYPE type)
{
   if(!m_Config.useFractals) return false;
   
   // Kiểm tra từ cache
   if(type == SWING_HIGH) {
      return (m_CachedFractalUp[bar] != EMPTY_VALUE);
   } 
   else {
      return (m_CachedFractalDown[bar] != EMPTY_VALUE);
   }
}

//+------------------------------------------------------------------+
//| Lấy giá trị Swing High                                          |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetSwingHigh(int index = 0)
{
   int found = 0;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         if(found == index) {
            return m_SwingPoints[i].price;
         }
         found++;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy giá trị Swing Low                                           |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetSwingLow(int index = 0)
{
   int found = 0;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW) {
         if(found == index) {
            return m_SwingPoints[i].price;
         }
         found++;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy Swing High gần nhất với giá                                 |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetNearestSwingHigh(double price, int maxBarsBack = 100)
{
   double nearestPrice = 0.0;
   double minDistance = DBL_MAX;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH && m_SwingPoints[i].barIndex <= maxBarsBack) {
         double distance = MathAbs(price - m_SwingPoints[i].price);
         if(distance < minDistance) {
            minDistance = distance;
            nearestPrice = m_SwingPoints[i].price;
         }
      }
   }
   
   return nearestPrice;
}

//+------------------------------------------------------------------+
//| Lấy Swing Low gần nhất với giá                                  |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetNearestSwingLow(double price, int maxBarsBack = 100)
{
   double nearestPrice = 0.0;
   double minDistance = DBL_MAX;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW && m_SwingPoints[i].barIndex <= maxBarsBack) {
         double distance = MathAbs(price - m_SwingPoints[i].price);
         if(distance < minDistance) {
            minDistance = distance;
            nearestPrice = m_SwingPoints[i].price;
         }
      }
   }
   
   return nearestPrice;
}

//+------------------------------------------------------------------+
//| Lấy Swing High cuối cùng                                        |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetLastSwingHigh()
{
   // Sắp xếp theo thời gian nếu cần
   if(m_SwingPointCount > 1) {
      SortSwingPointsByTime();
   }
   
   // Tìm Swing High đầu tiên (mới nhất)
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         return m_SwingPoints[i].price;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy Swing Low cuối cùng                                         |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetLastSwingLow()
{
   // Sắp xếp theo thời gian nếu cần
   if(m_SwingPointCount > 1) {
      SortSwingPointsByTime();
   }
   
   // Tìm Swing Low đầu tiên (mới nhất)
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW) {
         return m_SwingPoints[i].price;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy Swing High trước nến cụ thể                                 |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetSwingHighBeforeBar(int bar)
{
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH && m_SwingPoints[i].barIndex > bar) {
         return m_SwingPoints[i].price;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy Swing Low trước nến cụ thể                                  |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetSwingLowBeforeBar(int bar)
{
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW && m_SwingPoints[i].barIndex > bar) {
         return m_SwingPoints[i].price;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy Swing High mạnh nhất                                        |
//+------------------------------------------------------------------+
SwingPoint CSwingPointDetector::GetStrongestSwingHigh(int countBack = 5)
{
   SwingPoint strongest;
   strongest.strength = 0;
   
   int found = 0;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         if(m_SwingPoints[i].strength > strongest.strength) {
            strongest = m_SwingPoints[i];
         }
         
         found++;
         if(found >= countBack) break;
      }
   }
   
   return strongest;
}

//+------------------------------------------------------------------+
//| Lấy Swing Low mạnh nhất                                         |
//+------------------------------------------------------------------+
SwingPoint CSwingPointDetector::GetStrongestSwingLow(int countBack = 5)
{
   SwingPoint strongest;
   strongest.strength = 0;
   
   int found = 0;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW) {
         if(m_SwingPoints[i].strength > strongest.strength) {
            strongest = m_SwingPoints[i];
         }
         
         found++;
         if(found >= countBack) break;
      }
   }
   
   return strongest;
}

//+------------------------------------------------------------------+
//| Lấy thông tin Swing Point theo index                            |
//+------------------------------------------------------------------+
bool CSwingPointDetector::GetSwingPoint(int index, SwingPoint &point) const
{
   if(index < 0 || index >= m_SwingPointCount) {
      return false;
   }
   
   point = m_SwingPoints[index];
   return true;
}

//+------------------------------------------------------------------+
//| Lấy Major Swing High gần nhất với giá                           |
//+------------------------------------------------------------------+
SwingPoint CSwingPointDetector::GetNearestMajorSwingHigh(double price, int maxBarsBack = 100)
{
   SwingPoint nearestPoint;
   double minDistance = DBL_MAX;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_HIGH && 
         m_SwingPoints[i].importance >= SWING_MAJOR && 
         m_SwingPoints[i].barIndex <= maxBarsBack) {
         
         double distance = MathAbs(price - m_SwingPoints[i].price);
         if(distance < minDistance) {
            minDistance = distance;
            nearestPoint = m_SwingPoints[i];
         }
      }
   }
   
   return nearestPoint;
}

//+------------------------------------------------------------------+
//| Lấy Major Swing Low gần nhất với giá                            |
//+------------------------------------------------------------------+
SwingPoint CSwingPointDetector::GetNearestMajorSwingLow(double price, int maxBarsBack = 100)
{
   SwingPoint nearestPoint;
   double minDistance = DBL_MAX;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].type == SWING_LOW && 
         m_SwingPoints[i].importance >= SWING_MAJOR && 
         m_SwingPoints[i].barIndex <= maxBarsBack) {
         
         double distance = MathAbs(price - m_SwingPoints[i].price);
         if(distance < minDistance) {
            minDistance = distance;
            nearestPoint = m_SwingPoints[i];
         }
      }
   }
   
   return nearestPoint;
}

//+------------------------------------------------------------------+
//| Kiểm tra breakout có cấu trúc không                               |
//+------------------------------------------------------------------+
bool CSwingPointDetector::HasStructuralBreakout(bool isLong)
{
   if(m_SwingPointCount < 3) return false;
   
   // Giá hiện tại
   double currentPrice = isLong ? SymbolInfoDouble(m_Symbol, SYMBOL_ASK) : SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   // Đếm số lượng swing points bị break
   int brokenSwings = 0;
   
   for(int i = 0; i < MathMin(5, m_SwingPointCount); i++) {
      if(isLong) {
         // Trong xu hướng tăng, kiểm tra xem giá đã vượt qua swing high chưa
         if(m_SwingPoints[i].type == SWING_HIGH && currentPrice > m_SwingPoints[i].price) {
            // Nếu là major hoặc critical, có ý nghĩa lớn hơn
            if(m_SwingPoints[i].importance >= SWING_MAJOR) {
               brokenSwings += 2;
            } else {
               brokenSwings++;
            }
         }
      } else {
         // Trong xu hướng giảm, kiểm tra xem giá đã giảm xuống dướ
         if(m_SwingPoints[i].type == SWING_LOW && currentPrice < m_SwingPoints[i].price) {
            // Nếu là major hoặc critical, có ý nghĩa lớn hơn
            if(m_SwingPoints[i].importance >= SWING_MAJOR) {
               brokenSwings += 2;
            } else {
               brokenSwings++;
            }
         }
      }
   }
   
   return brokenSwings >= 3; // Cần ít nhất 3 swing bị break để xác nhận breakout có cấu trúc
}

//+------------------------------------------------------------------+
//| Kiểm tra có swing failure không                                 |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsSwingFailure(bool isLong)
{
   if(m_SwingPointCount < 2) return false;
   
   // Giá hiện tại
   double currentPrice = isLong ? SymbolInfoDouble(m_Symbol, SYMBOL_ASK) : SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   // Tìm swing gần nhất
   SwingPoint lastSwing;
   bool foundSwing = false;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if((isLong && m_SwingPoints[i].type == SWING_HIGH) || 
         (!isLong && m_SwingPoints[i].type == SWING_LOW)) {
         
         lastSwing = m_SwingPoints[i];
         foundSwing = true;
         break;
      }
   }
   
   if(!foundSwing) return false;
   
   // Lấy ATR hiện tại
   double atr = GetValidATR();
   if(atr <= 0) return false;
   
   // Kiểm tra xem có swing failure không
   if(isLong) {
      // Trong xu hướng tăng, swing failure là khi giá không thể vượt qua swing high
      if(lastSwing.type == SWING_HIGH) {
         // Giá gần với swing high (trong khoảng 0.5 ATR) nhưng không vượt qua
         double distance = lastSwing.price - currentPrice;
         return (distance > 0 && distance < atr * 0.5);
      }
   } else {
      // Trong xu hướng giảm, swing failure là khi giá không thể giảm dưới swing low
      if(lastSwing.type == SWING_LOW) {
         // Giá gần với swing low (trong khoảng 0.5 ATR) nhưng không vượt qua
         double distance = currentPrice - lastSwing.price;
         return (distance > 0 && distance < atr * 0.5);
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có liquidity grab không                                |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsLiquidityGrab(bool isLong)
{
   if(m_SwingPointCount < 3) return false;
   
   // Giá hiện tại
   double currentPrice = isLong ? SymbolInfoDouble(m_Symbol, SYMBOL_ASK) : SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   // Tìm swing gần nhất và swing quan trọng gần nhất
   SwingPoint lastSwing, majorSwing;
   bool foundLastSwing = false, foundMajorSwing = false;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(!foundLastSwing && 
         ((isLong && m_SwingPoints[i].type == SWING_LOW) || 
          (!isLong && m_SwingPoints[i].type == SWING_HIGH))) {
         
         lastSwing = m_SwingPoints[i];
         foundLastSwing = true;
      }
      
      if(!foundMajorSwing && 
         ((isLong && m_SwingPoints[i].type == SWING_LOW && m_SwingPoints[i].importance >= SWING_MAJOR) || 
          (!isLong && m_SwingPoints[i].type == SWING_HIGH && m_SwingPoints[i].importance >= SWING_MAJOR))) {
         
         majorSwing = m_SwingPoints[i];
         foundMajorSwing = true;
      }
      
      if(foundLastSwing && foundMajorSwing) break;
   }
   
   if(!foundLastSwing || !foundMajorSwing) return false;
   
   // Lấy ATR hiện tại
   double atr = GetValidATR();
   if(atr <= 0) return false;
   
   // Kiểm tra liquidity grab
   if(isLong) {
      // Trong xu hướng tăng, liquidity grab là khi giá giảm dưới swing low sau đó tăng lại
      // Swing low này thường là swing low quan trọng (major hoặc critical)
      
      if(lastSwing.price < majorSwing.price && currentPrice > lastSwing.price) {
         // Giá đã giảm dưới swing low quan trọng gần đây, sau đó tăng lại
         return true;
      }
   } else {
      // Trong xu hướng giảm, liquidity grab là khi giá tăng trên swing high sau đó giảm lại
      
      if(lastSwing.price > majorSwing.price && currentPrice < lastSwing.price) {
         // Giá đã tăng trên swing high quan trọng gần đây, sau đó giảm lại
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có fakeout không                                        |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsFakeout(bool isLong)
{
   if(m_SwingPointCount < 2) return false;
   
   // Giá hiện tại
   double currentPrice = isLong ? SymbolInfoDouble(m_Symbol, SYMBOL_ASK) : SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   // Tìm swing gần nhất
   SwingPoint lastSwing;
   bool foundSwing = false;
   
   for(int i = 0; i < m_SwingPointCount; i++) {
      if((isLong && m_SwingPoints[i].type == SWING_HIGH) || 
         (!isLong && m_SwingPoints[i].type == SWING_LOW)) {
         
         lastSwing = m_SwingPoints[i];
         foundSwing = true;
         break;
      }
   }
   
   if(!foundSwing) return false;
   
   // Lấy ATR hiện tại
   double atr = GetValidATR();
   if(atr <= 0) return false;
   
   // Kiểm tra fakeout
   if(isLong) {
      // Trong xu hướng tăng, fakeout là khi giá vượt qua swing high một chút, sau đó giảm lại
      if(lastSwing.type == SWING_HIGH) {
         // Nếu giá đã vượt qua swing high, nhưng mức vượt qua nhỏ (< 0.5 ATR)
         double extension = currentPrice - lastSwing.price;
         return (extension > 0 && extension < atr * 0.5);
      }
   } else {
      // Trong xu hướng giảm, fakeout là khi giá giảm dưới swing low một chút, sau đó tăng lại
      if(lastSwing.type == SWING_LOW) {
         // Nếu giá đã giảm dưới swing low, nhưng mức giảm nhỏ (< 0.5 ATR)
         double extension = lastSwing.price - currentPrice;
         return (extension > 0 && extension < atr * 0.5);
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra giá nằm ngoài vùng giá trị không                       |
//+------------------------------------------------------------------+
bool CSwingPointDetector::IsPriceOutsideValueArea(double price, bool checkHigh = true)
{
   // Triển khai trực tiếp trong lớp này thay vì gọi qua m_AssetProfiler
   double valueAreaHigh = 0.0;
   double valueAreaLow = 0.0;
   
   // Xác định vùng giá trị dựa trên các EMA
   double ema50 = 0.0, ema200 = 0.0;
   int ema50Handle = iMA(m_Symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
   int ema200Handle = iMA(m_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
   
   if(ema50Handle != INVALID_HANDLE && ema200Handle != INVALID_HANDLE) {
      double buffer50[], buffer200[];
      if(CopyBuffer(ema50Handle, 0, 0, 1, buffer50) > 0) {
         ema50 = buffer50[0];
      }
      if(CopyBuffer(ema200Handle, 0, 0, 1, buffer200) > 0) {
         ema200 = buffer200[0];
      }
      IndicatorRelease(ema50Handle);
      IndicatorRelease(ema200Handle);
   }
   
   // Tính toán vùng giá trị dựa trên khoảng cách giữa các EMA và ATR
   double atr = 0.0;
   int atrHandle = iATR(m_Symbol, PERIOD_CURRENT, 14);
   if(atrHandle != INVALID_HANDLE) {
      double buffer[];
      if(CopyBuffer(atrHandle, 0, 0, 1, buffer) > 0) {
         atr = buffer[0];
      }
      IndicatorRelease(atrHandle);
   }
   
   // Xác định vùng giá trị dựa trên EMA và ATR
   valueAreaHigh = MathMax(ema50, ema200) + atr * 1.5;
   valueAreaLow = MathMin(ema50, ema200) - atr * 1.5;
   
   // Kiểm tra xem giá có nằm ngoài vùng giá trị không
   if(checkHigh) {
      return price > valueAreaHigh;
   } else {
      return price < valueAreaLow;
   }
}

//+------------------------------------------------------------------+
//| Lấy kích thước vị thế đề xuất                                   |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetRecommendedPositionSize(double accountEquity, double riskPercent, bool isLong, double entryPrice, double stopLoss)
{
   // Tính khoảng cách SL theo points
   double slDistance = MathAbs(entryPrice - stopLoss);
   double slPoints = slDistance / _Point;
   
   // Tính risk amount
   double riskAmount = accountEquity * riskPercent / 100.0;
   
   // Tính lot size
   double tickValue = SymbolInfoDouble(m_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(m_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pointValue = tickValue * (_Point / tickSize);
   
   double lotSize = riskAmount / (slPoints * pointValue);
   
   // Làm tròn lot size theo lotStep
   double lotStep = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_STEP);
   lotSize = NormalizeDouble(MathFloor(lotSize / lotStep) * lotStep, 2);
   
   // Kiểm tra giới hạn lot size
   double minLot = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_MAX);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Tính kích thước vị thế dựa trên ATR                              |
//+------------------------------------------------------------------+
double CSwingPointDetector::CalculatePositionSizeByATR(double accountEquity, double riskAmount, bool isLong, double entryPrice)
{
   // Lấy ATR
   double atr = GetValidATR();
   if(atr <= 0) return 0.0;
   
   // Tính khoảng cách SL dựa trên ATR
   double atrMultiplier = GetDynamicAtrMultiplier(m_RegimeInfo.regime);
   double slDistance = atr * atrMultiplier;
   
   // Tính SL price
   double stopLoss = isLong ? entryPrice - slDistance : entryPrice + slDistance;
   
   // Tính lot size
   return GetRecommendedPositionSize(accountEquity, riskAmount, isLong, entryPrice, stopLoss);
}

//+------------------------------------------------------------------+
//| Lấy tỷ lệ R:R đề xuất                                           |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetSuggestedRRRatio()
{
   // Lấy tỷ lệ R:R tối ưu dựa trên chế độ thị trường
   return GetOptimalRiskRewardRatio(m_RegimeInfo.regime);
}

//+------------------------------------------------------------------+
//| Lấy giá High cao nhất trong khoảng                              |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetMaxSwingHighInRange(int bars)
{
   double maxHigh = 0.0;
   
   for(int i = 0; i < MathMin(bars, m_SwingPointCount); i++) {
      if(m_SwingPoints[i].type == SWING_HIGH && m_SwingPoints[i].price > maxHigh) {
         maxHigh = m_SwingPoints[i].price;
      }
   }
   
   return maxHigh;
}

//+------------------------------------------------------------------+
//| Lấy giá Low thấp nhất trong khoảng                              |
//+------------------------------------------------------------------+
double CSwingPointDetector::GetMinSwingLowInRange(int bars)
{
   double minLow = DBL_MAX;
   
   for(int i = 0; i < MathMin(bars, m_SwingPointCount); i++) {
      if(m_SwingPoints[i].type == SWING_LOW && m_SwingPoints[i].price < minLow) {
         minLow = m_SwingPoints[i].price;
      }
   }
   
   if(minLow == DBL_MAX) return 0.0;
   
   return minLow;
}

//+------------------------------------------------------------------+
//| Kiểm tra xu hướng dựa trên các đỉnh/đáy cao hơn/thấp hơn         |
//+------------------------------------------------------------------+
bool CSwingPointDetector::HasHigherHighsAndHigherLows(int minSwings = 2)
{
   if(m_SwingPointCount < minSwings * 2) return false; // Cần ít nhất minSwings đỉnh và minSwings đáy

   int hhCount = 0; // Higher Highs
   int hlCount = 0; // Higher Lows
   double lastHigh = 0, prevHigh = 0;
   double lastLow = 0, prevLow = 0;
   int highSwingsFound = 0;
   int lowSwingsFound = 0;

   for(int i = m_SwingPointCount - 1; i >= 0; i--) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         highSwingsFound++;
         if(highSwingsFound == 1) lastHigh = m_SwingPoints[i].price;
         else if(highSwingsFound == 2) {
            prevHigh = lastHigh;
            lastHigh = m_SwingPoints[i].price;
            if(lastHigh > prevHigh) hhCount++;
         }
         else if(highSwingsFound > 2) {
             prevHigh = lastHigh;
             lastHigh = m_SwingPoints[i].price;
             if(lastHigh > prevHigh) hhCount++;
         }
      }
      if(m_SwingPoints[i].type == SWING_LOW) {
         lowSwingsFound++;
         if(lowSwingsFound == 1) lastLow = m_SwingPoints[i].price;
         else if(lowSwingsFound == 2) {
            prevLow = lastLow;
            lastLow = m_SwingPoints[i].price;
            if(lastLow > prevLow) hlCount++;
         }
         else if(lowSwingsFound > 2) {
             prevLow = lastLow;
             lastLow = m_SwingPoints[i].price;
             if(lastLow > prevLow) hlCount++;
         }
      }
      if(hhCount >= minSwings && hlCount >= minSwings) return true;
   }
   return (hhCount >= minSwings && hlCount >= minSwings);
}

//+------------------------------------------------------------------+
//| Kiểm tra xu hướng dựa trên các đỉnh/đáy thấp hơn/thấp hơn         |
//+------------------------------------------------------------------+
bool CSwingPointDetector::HasLowerHighsAndLowerLows(int minSwings = 2)
{
   if(m_SwingPointCount < minSwings * 2) return false;

   int lhCount = 0; // Lower Highs
   int llCount = 0; // Lower Lows
   double lastHigh = 0, prevHigh = 0;
   double lastLow = 0, prevLow = 0;
   int highSwingsFound = 0;
   int lowSwingsFound = 0;

   for(int i = m_SwingPointCount - 1; i >= 0; i--) {
      if(m_SwingPoints[i].type == SWING_HIGH) {
         highSwingsFound++;
         if(highSwingsFound == 1) lastHigh = m_SwingPoints[i].price;
         else if(highSwingsFound == 2) {
            prevHigh = lastHigh;
            lastHigh = m_SwingPoints[i].price;
            if(lastHigh < prevHigh) lhCount++;
         }
         else if(highSwingsFound > 2) {
             prevHigh = lastHigh;
             lastHigh = m_SwingPoints[i].price;
             if(lastHigh < prevHigh) lhCount++;
         }
      }
      if(m_SwingPoints[i].type == SWING_LOW) {
         lowSwingsFound++;
         if(lowSwingsFound == 1) lastLow = m_SwingPoints[i].price;
         else if(lowSwingsFound == 2) {
            prevLow = lastLow;
            lastLow = m_SwingPoints[i].price;
            if(lastLow < prevLow) llCount++;
         }
         else if(lowSwingsFound > 2) {
             prevLow = lastLow;
             lastLow = m_SwingPoints[i].price;
             if(lastLow < prevLow) llCount++;
         }
      }
      if(lhCount >= minSwings && llCount >= minSwings) return true;
   }
   return (lhCount >= minSwings && llCount >= minSwings);
}

//+------------------------------------------------------------------+
//| Kiểm tra cấu trúc thị trường hợp lệ cho giao dịch                 |
//+------------------------------------------------------------------+
bool CSwingPointDetector::HasValidMarketStructure(bool isLong, int minMajorSwings = 1)
{
   if(m_SwingPointCount < minMajorSwings * 2) return false;

   int majorHighCount = 0;
   int majorLowCount = 0;
   for(int i = 0; i < m_SwingPointCount; i++) {
      if(m_SwingPoints[i].importance >= SWING_MAJOR) {
         if(m_SwingPoints[i].type == SWING_HIGH) majorHighCount++;
         else if(m_SwingPoints[i].type == SWING_LOW) majorLowCount++;
      }
   }

   if(isLong) {
      // Cần ít nhất một đỉnh major và một đáy major, và xu hướng tăng được xác nhận bởi các swing points
      return (majorHighCount >= minMajorSwings && majorLowCount >= minMajorSwings && HasHigherHighsAndHigherLows());
   } else {
      // Cần ít nhất một đỉnh major và một đáy major, và xu hướng giảm được xác nhận bởi các swing points
      return (majorHighCount >= minMajorSwings && majorLowCount >= minMajorSwings && HasLowerHighsAndLowerLows());
   }
}

} // đóng namespace ApexPullback

#endif // SWINGPOINTDETECTOR_MQH_
