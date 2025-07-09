//+------------------------------------------------------------------+
//|            CommonStructs.mqh - APEX Pullback EA v14.0            |
//|      Trái tim của hệ thống - Single Source of Truth Context      |
//+------------------------------------------------------------------+

#ifndef COMMON_STRUCTS_MQH_
#define COMMON_STRUCTS_MQH_

// Phụ thuộc hợp lệ DUY NHẤT của tệp này.
#include "Enums.mqh"



// BẮT ĐẦU NAMESPACE
namespace ApexPullback
{

// Khai báo chuyển tiếp cho chính struct context
struct EAContext;

// --- KHAI BÁO CHUYỂN TIẾP CHO TẤT CẢ CÁC CLASS ---
// Đây là bước cực kỳ quan trọng để ngăn chặn các phụ thuộc vòng (circular dependencies).
// Mỗi file .mqh của module sau đó sẽ #include file này.
// Thứ tự được sắp xếp theo nhóm logic.

// Core Infrastructure
class CLogger;
class CErrorHandler;
class CFunctionStack;
class CParameterStore;
class CStateManager;
class CSettings; // Lớp mới để quản lý cài đặt

// Market & Session Analysis
class CTimeManager;
class CSymbolInfo;
class CBrokerHealthMonitor;
class CSlippageMonitor;
class CAssetDNA;

// Trading & Risk Management
class CMarketProfile;
class CPositionManager;
class CRiskManager;
class CTradeManager;
class CSignalEngine;
class CCircuitBreaker;

// Performance & UI
class CPerformanceAnalytics;
class CDashboard;

class CDrawingUtils;

// Utilities
class CIndicatorUtils;
class CMathHelper;
// --- KẾT THÚC KHAI BÁO CHUYỂN TIẾP ---







//+------------------------------------------------------------------+
//| EAContext - TRÁI TIM CỦA HỆ THỐNG                                |
//| Chứa tất cả trạng thái, tham số và các đối tượng module.         |
//| Được truyền dưới dạng tham chiếu (&) cho tất cả các module.      |
//+------------------------------------------------------------------+
struct EAContext
{
    // --- Trạng thái và Thông tin Core ---
    long                  MagicNumber;          // Magic Number của EA
    string                EAVersion;            // Phiên bản EA
    ENUM_EA_STATE         CurrentState;         // Trạng thái hiện tại của EA
    bool                  IsBacktest;           // Đang chạy trong backtest?
    bool                  IsOptimization;       // Đang chạy trong optimization?
    MqlTick               LastTick;             // Dữ liệu tick cuối cùng
    bool                  IsNewBarEvent;        // Cờ = true nếu tick hiện tại là tick đầu tiên của một nến mới

    // --- Con trỏ tới các Module chính ---
    // Core Infrastructure
    CLogger*              pLogger;
    CErrorHandler*        pErrorHandler;
    CFunctionStack*       pFuncStack;
    CParameterStore*      pParamStore;
    CStateManager*        pStateMgr;

    // Market & Session Analysis
    CTimeManager*         pTimeMgr;
    CSymbolInfo*          pSymbolInfo;
    CBrokerHealthMonitor* pBrokerHealth;
    CSlippageMonitor*     pSlippageMon;
    CAssetDNA*            pAssetDNA;
    CMarketProfile*       pMarketProfile;

    // Trading & Risk Management
    CSignalEngine*        pSignalEngine;
    CRiskManager*         pRiskMgr;
    CTradeManager*        pTradeMgr;
    CPositionManager*     pPosMgr;
    CCircuitBreaker*      pCircuitBreaker;

    // Performance & UI
    CPerformanceAnalytics* pPerfAnalytics;
    CDashboard*           pDashboard;
    CDrawingUtils*        pDrawing;

    // Utilities
    CIndicatorUtils*      pIndicatorUtils;
    CMathHelper*          pMathHelper;

    // --- Struct chứa TẤT CẢ các tham số Input (sẽ được thay thế bởi CSettings) ---
    SInputParameters      Inputs; // Giữ lại để tương thích tạm thời, sẽ bị loại bỏ

    // Constructor: Khởi tạo giá trị mặc định
    EAContext() : 
        MagicNumber(0),
        EAVersion("14.0"),
        CurrentState(STATE_INIT),
        IsBacktest(false),
        IsOptimization(false),
        IsNewBarEvent(false),
        // Khởi tạo tất cả con trỏ là NULL
        pLogger(NULL),
        pErrorHandler(NULL),
        pFuncStack(NULL),
        pParamStore(NULL),
        pStateMgr(NULL),
        pTimeMgr(NULL),
        pSymbolInfo(NULL),
        pBrokerHealth(NULL),
        pSlippageMon(NULL),
        pAssetDNA(NULL),
        pMarketProfile(NULL),
        pSignalEngine(NULL),
        pRiskMgr(NULL),
        pTradeMgr(NULL),
        pPosMgr(NULL),
        pCircuitBreaker(NULL),
        pPerfAnalytics(NULL),
        pDashboard(NULL),
        pDrawing(NULL),
        pIndicatorUtils(NULL),
        pMathHelper(NULL)
    {
        // Các khởi tạo khác nếu cần
        ZeroMemory(LastTick);
    }
};



} // KẾT THÚC NAMESPACE ApexPullback

#endif // COMMON_STRUCTS_MQH_
