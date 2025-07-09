//+------------------------------------------------------------------+
//|                                                  Namespace.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef NAMESPACE_MQH
#define NAMESPACE_MQH

#include "Enums.mqh"
#include "CommonStructs.mqh"


// Sử dụng các giá trị mặc định từ Constants.mqh
#include "CommonStructs.mqh"      // Core structures, enums, and inputs

// Định nghĩa namespace ApexPullback
namespace ApexPullback {
    // Forward declarations cho tất cả các class trong namespace
    class CMarketProfile;
    class CSwingPointDetector;
    class CLogger;
    class CSafeDataProvider;
    class CNewsFilter;
    class CAssetProfiler;
    class CRiskOptimizer;
    class CRiskDataProvider;
    class CRiskManager;
    class CTradeManager;
    class CPatternDetector;
    class CPositionManager;
    class CSessionManager;
    class CPerformanceTracker;
    class CDashboard;
    class CIndicatorUtils;
    class CAssetProfileManager;
    
    // Forward declarations cho các struct trong namespace
    struct SRiskOptimizerConfig;
    struct PullbackSignal;
    struct PartialCloseConfig;
    struct NewsFilterConfig;
    struct PerformanceMetrics;
    struct ScenarioStats;
    struct IndicatorHandles;
    
    // Khai báo các biến toàn cục trong namespace
    // extern bool g_EnableDetailedLogs; // Đã chuyển vào Logger hoặc EAContext
    // extern bool g_AlertsEnabled; // Sẽ chuyển vào EAContext hoặc NotificationManager
    // extern bool g_SendNotifications; // Sẽ chuyển vào EAContext hoặc NotificationManager
    // extern bool g_EnableTelegramNotify; // Sẽ chuyển vào EAContext hoặc NotificationManager
    // extern bool g_TelegramImportantOnly; // Sẽ chuyển vào EAContext hoặc NotificationManager
    // extern bool g_DisplayDashboard; // Đã chuyển vào EAContext
    // extern bool g_EnableIndicatorCache; // Sẽ chuyển vào CIndicatorUtils hoặc EAContext
    // extern bool g_AllowNewTrades; // Đã chuyển vào EAContext
    // extern bool g_SendEmailAlerts; // Sẽ chuyển vào EAContext hoặc NotificationManager
    // extern int g_MaxTradesPerDay; // Sẽ chuyển vào EAContext hoặc TradeManager/RiskManager
    // extern int g_DayTrades; // Sẽ được quản lý bởi TradeManager hoặc một bộ đếm trong EAContext
    // extern int g_IndicatorCount; // Không còn cần thiết, CIndicatorUtils quản lý các chỉ báo
    // extern double g_MaxSpreadPoints; // Sẽ chuyển vào EAContext hoặc RiskManager
    // extern double g_MinPullbackPct; // Sẽ chuyển vào EAContext hoặc PatternDetector/TradeManager
    // extern double g_MaxPullbackPct; // Sẽ chuyển vào EAContext hoặc PatternDetector/TradeManager
    // extern double g_VolatilityThreshold; // Sẽ chuyển vào EAContext hoặc MarketProfile/RiskManager
    // extern double g_CurrentDrawdownPct; // Sẽ được quản lý bởi PerformanceTracker hoặc RiskManager
    // extern double g_MaxDrawdown; // Sẽ chuyển vào EAContext hoặc RiskManager
    // extern double g_AverageATR; // Sẽ được quản lý bởi CIndicatorUtils hoặc MarketProfile
    
    // Khai báo extern cho các objects (Sẽ được truy cập qua g_EAContext)
    // extern ApexPullback::CLogger* g_Logger;
    // extern CDashboard* g_Dashboard;
    // extern CRiskManager* g_RiskManager;
    // extern CSessionManager* g_SessionManager;
    // extern CNewsFilter* g_NewsFilter;
    // extern CAssetProfileManager* g_AssetProfileManager;
    // extern CMarketProfile* g_MarketProfile;
    // extern CSwingPointDetector* g_SwingDetector;
    // extern CPositionManager* g_PositionManager;
    // extern CTradeManager* g_TradeManager;
    // extern CPatternDetector* g_PatternDetector;
    // extern CPerformanceTracker* g_PerformanceTracker;
    // extern CIndicatorUtils* g_IndicatorUtils;
    // extern CAssetProfiler* g_AssetProfiler;
    
    // Các biến global cho handle của các chỉ báo (đã được quản lý bởi CIndicatorUtils)
    // extern IndicatorHandles g_IndicatorHandles[]; // Đã loại bỏ
    
    // Khai báo MarketProfileData trực tiếp, không dùng con trỏ (Sẽ được quản lý trong EAContext)
    // extern MarketProfileData g_CurrentProfileData;
    
    // Các hàm được triển khai trong các file khác
    // Không khai báo ở đây để tránh lỗi #import
    // Mỗi hàm sẽ được khai báo và triển khai trong file cụ thể
    
} // end namespace ApexPullback

#endif // NAMESPACE_MQH
