//+------------------------------------------------------------------+
//|                                Analysis_MarketAnalysisManager.mqh |
//|                      APEX Pullback EA v4 - Integration           |
//|                 Tác giả: Cáo Già & Đại Bàng                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Cáo Già & Đại Bàng"
#property link      "https://www.mql5.com"

#include "Core_Context.mqh"
#include "Analysis_SonicR_WavePattern.mqh"
#include "Analysis_SonicR_DragonBand.mqh"
#include "Analysis_SonicR_Oscillator.mqh"
#include "Analysis_SonicR_PVSRA.mqh"
#include "Analysis_SonicR_SupportResistance.mqh"
#include "Analysis_SMC.mqh"
#include "Analysis_MarketProfile.mqh"

// Forward declaration of analysis modules
class CSonicRWavePattern;
class CSonicRDragonBand;
class CSonicROscillator;
class CSonicRPVSRA;
class CSonicRSupportResistance;
class CAnalysisSMC;
class CAnalysisMarketProfile;

//+------------------------------------------------------------------+
//| Cấu trúc chứa toàn bộ bối cảnh thị trường đã được phân tích      |
//+------------------------------------------------------------------+
struct SMarketContext
{
    const OrderBlockArray*      order_blocks;      // Con trỏ tới danh sách Order Blocks
    const FVGArray*             fair_value_gaps;   // Con trỏ tới danh sách Fair Value Gaps
    const SWavePatternContext*  wave_pattern;      // Con trỏ tới dữ liệu Wave Pattern
    const SDragonBandContext*   dragon_band;       // Con trỏ tới dữ liệu Dragon Band
    const SOscillatorContext*   oscillator;        // Con trỏ tới dữ liệu Oscillator
    const SPVSRAContext*        pvsra;             // Con trỏ tới dữ liệu PVSRA
    const CAnalysisSMC*         smc_analysis;      // Con trỏ tới toàn bộ phân tích SMC
    const SSupportResistance*   support_resistance;// Con trỏ tới dữ liệu Support Resistance
    const CAnalysisMarketProfile* market_profile;    // Con trỏ tới Market Profile

    void Reset()
    {
        order_blocks = NULL;
        fair_value_gaps = NULL;
        wave_pattern = NULL;
        dragon_band = NULL;
        oscillator = NULL;
        pvsra = NULL;
        smc_analysis = NULL;
        support_resistance = NULL;
        market_profile = NULL;
    }
};

//+------------------------------------------------------------------+
//| Lớp quản lý và điều phối tất cả các module phân tích thị trường   |
//+------------------------------------------------------------------+
class CMarketAnalysisManager
{
private:
    CEaContext*                 m_context;           // Con trỏ tới EA Context
    CLogger*                    m_logger;            // Con trỏ tới Logger

    // --- Pointers to all analysis modules ---
    CSonicRWavePattern*         m_sonic_r_wave_pattern;
    CSonicRDragonBand*          m_sonic_r_dragon_band;
    CSonicROscillator*          m_sonic_r_oscillator;
    CSonicRPVSRA*               m_sonic_r_pvsra;
    CSonicRSupportResistance*   m_sonic_r_support_resistance;
    CAnalysisSMC*               m_smc_analysis;
    CAnalysisMarketProfile*     m_market_profile;

    SMarketContext              m_market_context;    // Dữ liệu phân tích tổng hợp
    datetime                    m_last_update_time;  // Thời gian cập nhật cuối cùng

public:
    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    CMarketAnalysisManager() : m_context(NULL),
                               m_logger(NULL),
                               m_sonic_r_wave_pattern(NULL),
                               m_sonic_r_dragon_band(NULL),
                               m_sonic_r_oscillator(NULL),
                               m_sonic_r_pvsra(NULL),
                               m_sonic_r_support_resistance(NULL),
                               m_smc_analysis(NULL),
                               m_market_profile(NULL),
                               m_last_update_time(0)
    {
    }

    //+------------------------------------------------------------------+
    //| Destructor                                                       |
    //+------------------------------------------------------------------+
    ~CMarketAnalysisManager()
    {
        // Deinitialization is handled by the main EA file
    }

    //+------------------------------------------------------------------+
    //| Khởi tạo Manager và tất cả các module con                      |
    //+------------------------------------------------------------------+
    bool Initialize(CEaContext* context)
    {
        m_context = context;
        if(CheckPointer(m_context) == POINTER_INVALID)
        {
            printf("Error: EA Context is null in CMarketAnalysisManager");
            return false;
        }
        m_logger = m_context->pLogger;

        // --- Create and Initialize all analysis modules ---
        m_sonic_r_wave_pattern = new CSonicRWavePattern();
        if(!m_sonic_r_wave_pattern || !m_sonic_r_wave_pattern.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CSonicRWavePattern"); return false; }

        m_sonic_r_dragon_band = new CSonicRDragonBand();
        if(!m_sonic_r_dragon_band || !m_sonic_r_dragon_band.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CSonicRDragonBand"); return false; }

        m_sonic_r_oscillator = new CSonicROscillator();
        if(!m_sonic_r_oscillator || !m_sonic_r_oscillator.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CSonicROscillator"); return false; }

        m_sonic_r_pvsra = new CSonicRPVSRA();
        if(!m_sonic_r_pvsra || !m_sonic_r_pvsra.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CSonicRPVSRA"); return false; }

                m_sonic_r_support_resistance = new CSonicRSupportResistance();
        if(!m_sonic_r_support_resistance || !m_sonic_r_support_resistance.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CSonicRSupportResistance"); return false; }

        // --- Initialize new SMC analysis coordinator ---
        m_smc_analysis = new CAnalysisSMC();
        if(!m_smc_analysis || !m_smc_analysis.Initialize(m_context)) { if(m_logger) m_logger.LogError("Failed to initialize CAnalysisSMC"); return false; }

        m_market_profile = new CAnalysisMarketProfile();
        if(!m_market_profile || !m_market_profile.Initialize(m_context, m_logger))
        {
            if(m_logger) m_logger.LogError("Failed to initialize CAnalysisMarketProfile");
            return false;
        }

        if(m_logger) m_logger.LogInfo("CMarketAnalysisManager and all sub-modules initialized successfully.");
        return true;
    }

    //+------------------------------------------------------------------+
    //| Hủy các module con                                               |
    //+------------------------------------------------------------------+
    void Deinitialize()
    {
        if(m_sonic_r_wave_pattern)    delete m_sonic_r_wave_pattern;
        if(m_sonic_r_dragon_band)     delete m_sonic_r_dragon_band;
        if(m_sonic_r_oscillator)      delete m_sonic_r_oscillator;
        if(m_sonic_r_pvsra)           delete m_sonic_r_pvsra;
        if(m_sonic_r_support_resistance) delete m_sonic_r_support_resistance;
        if(m_smc_analysis)            delete m_smc_analysis;
        if(m_market_profile)          delete m_market_profile;
    }

    //+------------------------------------------------------------------+
    //| Cập nhật tất cả các module phân tích (gọi mỗi New Bar)          |
    //+------------------------------------------------------------------+
    void Update()
    {
        if(!m_context || !m_context->pTimeManager->IsNewBar(m_last_update_time))
            return;

        // Update all analysis modules
        if(m_sonic_r_wave_pattern) m_sonic_r_wave_pattern.Update();
        if(m_sonic_r_dragon_band) m_sonic_r_dragon_band.Update();
        if(m_sonic_r_oscillator) m_sonic_r_oscillator.Update();
        if(m_sonic_r_pvsra) m_sonic_r_pvsra.Update();
        if(m_sonic_r_support_resistance) m_sonic_r_support_resistance.Update();
        if(m_smc_analysis) m_smc_analysis.Update();
        if(m_market_profile) m_market_profile.Update();

        // Consolidate results into m_market_context
        ConsolidateMarketContext();

        if(m_logger) m_logger.LogDebug("CMarketAnalysisManager updated all modules.");
    }

    //+------------------------------------------------------------------+
    //| Tổng hợp dữ liệu từ các module vào SMarketContext                |
    //+------------------------------------------------------------------+
    private: void ConsolidateMarketContext()
    {
        m_market_context.Reset();
        m_market_context.wave_pattern = m_sonic_r_wave_pattern ? m_sonic_r_wave_pattern.GetContext() : NULL;
        m_market_context.dragon_band = m_sonic_r_dragon_band ? m_sonic_r_dragon_band.GetContext() : NULL;
        m_market_context.oscillator = m_sonic_r_oscillator ? m_sonic_r_oscillator.GetContext() : NULL;
        m_market_context.pvsra = m_sonic_r_pvsra ? m_sonic_r_pvsra.GetContext() : NULL;
        m_market_context.support_resistance = m_sonic_r_support_resistance ? m_sonic_r_support_resistance.GetContext() : NULL;
        m_market_context.market_profile = m_market_profile;
        m_market_context.smc_analysis = m_smc_analysis;
    }

public:
    //+------------------------------------------------------------------+
    //| Lấy bối cảnh thị trường đã được phân tích                        |
    //+------------------------------------------------------------------+
    const SMarketContext* GetMarketContext() const { return &m_market_context; }

    //+------------------------------------------------------------------+
    //| Cung cấp quyền truy cập vào các module phân tích cụ thể          |
    //+------------------------------------------------------------------+
    CSonicRWavePattern*         GetWavePatternModule()          { return m_sonic_r_wave_pattern; }
    CSonicRDragonBand*          GetDragonBandModule()           { return m_sonic_r_dragon_band; }
    CSonicROscillator*          GetOscillatorModule()           { return m_sonic_r_oscillator; }
    CSonicRPVSRA*               GetPVSRAModule()                { return m_sonic_r_pvsra; }
    CAnalysisSMC*               GetSMCModule()                  { return m_smc_analysis; }
};