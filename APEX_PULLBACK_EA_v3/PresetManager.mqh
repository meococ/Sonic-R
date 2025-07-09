//+------------------------------------------------------------------+
//|                    PresetManager.mqh - APEX Pullback EA v14.0   |
//|                           Copyright 2023-2024, APEX Forex        |
//|                             https://www.apexpullback.com         |
//+------------------------------------------------------------------+
#ifndef PRESET_MANAGER_MQH_
#define PRESET_MANAGER_MQH_

// #include "CommonStructs.mqh" // Should be included ONLY by the main .mq5 file

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Cấu trúc chứa các thông số preset                               |
//+------------------------------------------------------------------+
struct PresetConfig {
    // Risk Management
    double RiskPercent;
    double MaxDailyDrawdown;
    double MaxTotalDrawdown;
    int MaxConcurrentTrades;
    int MaxConsecutiveLosses;
    
    // Entry Parameters
    double MinPullbackPercent;
    double MaxPullbackPercent;
    double MinADXLevel;
    double VolatilityThreshold;
    double MaxSpreadPips;
    
    // Stop Loss & Take Profit
    double StopLoss_ATR;
    double TakeProfit_RR;
    double BreakevenRR;
    
    // Trailing Stop
    ENUM_TRAILING_MODE TrailingMode;
    double TrailingATR;
    
    // Market Filters
    bool EnableMarketRegimeFilter;
    bool EnableVolatilityFilter;
    bool EnableSpreadFilter;
    
    // Session Filters
    bool EnableSessionFilter;
    ENUM_SESSION_FILTER SessionType;
    
    // News Filter
    bool EnableNewsFilter;
    int NewsMinutesBefore;
    int NewsMinutesAfter;
    
    // Constructor
    PresetConfig() {
        // Default values
        RiskPercent = 1.0;
        MaxDailyDrawdown = 5.0;
        MaxTotalDrawdown = 15.0;
        MaxConcurrentTrades = 3;
        MaxConsecutiveLosses = 5;
        
        MinPullbackPercent = 30.0;
        MaxPullbackPercent = 70.0;
        MinADXLevel = 25.0;
        VolatilityThreshold = 1.5;
        MaxSpreadPips = 2.0;
        
        StopLoss_ATR = 2.0;
        TakeProfit_RR = 2.0;
        BreakevenRR = 1.0;
        
        TrailingMode = TRAILING_ATR;
        TrailingATR = 1.5;
        
        EnableMarketRegimeFilter = true;
        EnableVolatilityFilter = true;
        EnableSpreadFilter = true;
        
        EnableSessionFilter = false;
        SessionType = FILTER_ALL_SESSIONS;
        
        EnableNewsFilter = true;
        NewsMinutesBefore = 30;
        NewsMinutesAfter = 30;
    }
};

//+------------------------------------------------------------------+
//| Lớp quản lý các preset configurations                           |
//+------------------------------------------------------------------+
class CPresetManager {
private:
    EAContext* m_context; // Pointer to the main EA context
    
public:
    CPresetManager();
    ~CPresetManager();
    
    void Initialize(EAContext* context);
    bool ApplyPreset(EAContext* context, ENUM_MARKET_PRESET preset);
    PresetConfig GetPresetConfig(ENUM_MARKET_PRESET preset);
    string GetPresetDescription(ENUM_MARKET_PRESET preset);
    ENUM_MARKET_PRESET DetectOptimalPreset(string symbol, ENUM_TIMEFRAMES timeframe);
    
private:
    PresetConfig GetConservativeConfig();
    PresetConfig GetBalancedConfig();
    PresetConfig GetAggressiveConfig();
    PresetConfig GetForexMajorConfig();
    PresetConfig GetGoldConfig();
    PresetConfig GetIndicesConfig();
    
    // Specific pair configurations
    PresetConfig GetEURUSDConfig(ENUM_TIMEFRAMES tf, string style);
    PresetConfig GetGBPUSDConfig(ENUM_TIMEFRAMES tf, string style);
    PresetConfig GetUSDJPYConfig(ENUM_TIMEFRAMES tf, string style);
    PresetConfig GetXAUUSDConfig(ENUM_TIMEFRAMES tf, string style);
    
    void ApplyConfigToContext(EAContext* context, const PresetConfig& config);
    bool IsForexMajor(string symbol);
    bool IsGold(string symbol);
    bool IsIndex(string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPresetManager::CPresetManager() : m_context(NULL) {
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPresetManager::~CPresetManager() {
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Khởi tạo PresetManager                                          |
//+------------------------------------------------------------------+
void CPresetManager::Initialize(EAContext* context) {
    m_context = context;
    if (m_context && m_context->Logger) {
        m_context->Logger->LogInfo("PresetManager initialized successfully");
    }
}

//+------------------------------------------------------------------+
//| Áp dụng preset cho EA context                                   |
//+------------------------------------------------------------------+
bool CPresetManager::ApplyPreset(EAContext* context, ENUM_MARKET_PRESET preset) {
    if (!context) {
        if (m_context && m_context->Logger) m_context->Logger->LogError("Invalid context in ApplyPreset");
        return false;
    }
    
    PresetConfig config = GetPresetConfig(preset);
    ApplyConfigToContext(context, config);
    
    if (m_context && m_context->Logger) {
        m_context->Logger->LogInfo(StringFormat("Applied preset: %s (%s)", 
            EnumToString(preset), GetPresetDescription(preset)));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Lấy cấu hình preset                                             |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetPresetConfig(ENUM_MARKET_PRESET preset) {
    switch(preset) {
        case PRESET_CONSERVATIVE:
            return GetConservativeConfig();
            
        case PRESET_BALANCED:
            return GetBalancedConfig();
            
        case PRESET_AGGRESSIVE:
            return GetAggressiveConfig();
            
        case PRESET_FOREX:
            return GetForexMajorConfig();
            
        case PRESET_METALS:
            return GetGoldConfig();
            
        case PRESET_INDICES:
            return GetIndicesConfig();
            
        // EURUSD Presets
        case PRESET_EURUSD_H1_CONSERVATIVE:
            return GetEURUSDConfig(PERIOD_H1, "conservative");
        case PRESET_EURUSD_H1_STANDARD:
            return GetEURUSDConfig(PERIOD_H1, "standard");
        case PRESET_EURUSD_H1_AGGRESSIVE:
            return GetEURUSDConfig(PERIOD_H1, "aggressive");
        case PRESET_EURUSD_H4_CONSERVATIVE:
            return GetEURUSDConfig(PERIOD_H4, "conservative");
        case PRESET_EURUSD_H4_STANDARD:
            return GetEURUSDConfig(PERIOD_H4, "standard");
        case PRESET_EURUSD_H4_AGGRESSIVE:
            return GetEURUSDConfig(PERIOD_H4, "aggressive");
            
        // GBPUSD Presets
        case PRESET_GBPUSD_H1_CONSERVATIVE:
            return GetGBPUSDConfig(PERIOD_H1, "conservative");
        case PRESET_GBPUSD_H1_STANDARD:
            return GetGBPUSDConfig(PERIOD_H1, "standard");
        case PRESET_GBPUSD_H1_AGGRESSIVE:
            return GetGBPUSDConfig(PERIOD_H1, "aggressive");
        case PRESET_GBPUSD_H4_CONSERVATIVE:
            return GetGBPUSDConfig(PERIOD_H4, "conservative");
        case PRESET_GBPUSD_H4_STANDARD:
            return GetGBPUSDConfig(PERIOD_H4, "standard");
        case PRESET_GBPUSD_H4_AGGRESSIVE:
            return GetGBPUSDConfig(PERIOD_H4, "aggressive");
            
        // USDJPY Presets
        case PRESET_USDJPY_H1_CONSERVATIVE:
            return GetUSDJPYConfig(PERIOD_H1, "conservative");
        case PRESET_USDJPY_H1_STANDARD:
            return GetUSDJPYConfig(PERIOD_H1, "standard");
        case PRESET_USDJPY_H1_AGGRESSIVE:
            return GetUSDJPYConfig(PERIOD_H1, "aggressive");
        case PRESET_USDJPY_H4_CONSERVATIVE:
            return GetUSDJPYConfig(PERIOD_H4, "conservative");
        case PRESET_USDJPY_H4_STANDARD:
            return GetUSDJPYConfig(PERIOD_H4, "standard");
        case PRESET_USDJPY_H4_AGGRESSIVE:
            return GetUSDJPYConfig(PERIOD_H4, "aggressive");
            
        // XAUUSD Presets
        case PRESET_XAUUSD_M15_CONSERVATIVE:
            return GetXAUUSDConfig(PERIOD_M15, "conservative");
        case PRESET_XAUUSD_M15_STANDARD:
            return GetXAUUSDConfig(PERIOD_M15, "standard");
        case PRESET_XAUUSD_M15_AGGRESSIVE:
            return GetXAUUSDConfig(PERIOD_M15, "aggressive");
        case PRESET_XAUUSD_H1_CONSERVATIVE:
            return GetXAUUSDConfig(PERIOD_H1, "conservative");
        case PRESET_XAUUSD_H1_STANDARD:
            return GetXAUUSDConfig(PERIOD_H1, "standard");
        case PRESET_XAUUSD_H1_AGGRESSIVE:
            return GetXAUUSDConfig(PERIOD_H1, "aggressive");
            
        default:
            return GetBalancedConfig(); // Default fallback
    }
}

//+------------------------------------------------------------------+
//| Lấy mô tả preset                                                |
//+------------------------------------------------------------------+
string CPresetManager::GetPresetDescription(ENUM_MARKET_PRESET preset) {
    switch(preset) {
        case PRESET_AUTO: return "Tự động nhận diện";
        case PRESET_CONSERVATIVE: return "Bảo thủ - Ít tín hiệu, chất lượng cao";
        case PRESET_BALANCED: return "Cân bằng - Tối ưu risk/reward";
        case PRESET_AGGRESSIVE: return "Tích cực - Nhiều cơ hội giao dịch";
        case PRESET_FOREX: return "Forex majors - Tối ưu cho các cặp chính";
        case PRESET_METALS: return "Kim loại - Tối ưu cho Gold/Silver";
        case PRESET_INDICES: return "Chỉ số - Tối ưu cho US30/SPX500/NAS100";
        
        case PRESET_EURUSD_H1_CONSERVATIVE: return "EURUSD H1 - Bảo thủ";
        case PRESET_EURUSD_H1_STANDARD: return "EURUSD H1 - Chuẩn";
        case PRESET_EURUSD_H1_AGGRESSIVE: return "EURUSD H1 - Tích cực";
        
        case PRESET_XAUUSD_M15_STANDARD: return "XAUUSD M15 - Chuẩn";
        case PRESET_XAUUSD_H1_STANDARD: return "XAUUSD H1 - Chuẩn";
        
        default: return "Preset không xác định";
    }
}

//+------------------------------------------------------------------+
//| Tự động phát hiện preset tối ưu                                 |
//+------------------------------------------------------------------+
ENUM_MARKET_PRESET CPresetManager::DetectOptimalPreset(string symbol, ENUM_TIMEFRAMES timeframe) {
    string sym = StringToUpper(symbol);
    
    // EURUSD
    if (StringFind(sym, "EURUSD") >= 0) {
        if (timeframe == PERIOD_H1) return PRESET_EURUSD_H1_STANDARD;
        if (timeframe == PERIOD_H4) return PRESET_EURUSD_H4_STANDARD;
    }
    
    // GBPUSD
    if (StringFind(sym, "GBPUSD") >= 0) {
        if (timeframe == PERIOD_H1) return PRESET_GBPUSD_H1_STANDARD;
        if (timeframe == PERIOD_H4) return PRESET_GBPUSD_H4_STANDARD;
    }
    
    // USDJPY
    if (StringFind(sym, "USDJPY") >= 0) {
        if (timeframe == PERIOD_H1) return PRESET_USDJPY_H1_STANDARD;
        if (timeframe == PERIOD_H4) return PRESET_USDJPY_H4_STANDARD;
    }
    
    // Gold
    if (StringFind(sym, "XAUUSD") >= 0 || StringFind(sym, "GOLD") >= 0) {
        if (timeframe == PERIOD_M15) return PRESET_XAUUSD_M15_STANDARD;
        if (timeframe == PERIOD_H1) return PRESET_XAUUSD_H1_STANDARD;
    }
    
    // Fallback based on asset type
    if (IsForexMajor(sym)) return PRESET_FOREX;
    if (IsGold(sym)) return PRESET_METALS;
    if (IsIndex(sym)) return PRESET_INDICES;
    
    return PRESET_BALANCED; // Default
}

//+------------------------------------------------------------------+
//| Cấu hình Conservative                                           |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetConservativeConfig() {
    PresetConfig config;
    
    // Risk Management - Rất bảo thủ
    config.RiskPercent = 0.5;
    config.MaxDailyDrawdown = 3.0;
    config.MaxTotalDrawdown = 10.0;
    config.MaxConcurrentTrades = 2;
    config.MaxConsecutiveLosses = 3;
    
    // Entry - Chỉ tín hiệu chất lượng cao
    config.MinPullbackPercent = 40.0;
    config.MaxPullbackPercent = 60.0;
    config.MinADXLevel = 30.0;
    config.VolatilityThreshold = 1.2;
    config.MaxSpreadPips = 1.5;
    
    // SL/TP - Bảo thủ
    config.StopLoss_ATR = 2.5;
    config.TakeProfit_RR = 2.5;
    config.BreakevenRR = 1.2;
    
    // Trailing
    config.TrailingMode = TRAILING_ATR;
    config.TrailingATR = 2.0;
    
    // Filters - Tất cả bật
    config.EnableMarketRegimeFilter = true;
    config.EnableVolatilityFilter = true;
    config.EnableSpreadFilter = true;
    config.EnableSessionFilter = true;
    config.SessionType = FILTER_MAJOR_SESSIONS_ONLY;
    config.EnableNewsFilter = true;
    config.NewsMinutesBefore = 60;
    config.NewsMinutesAfter = 60;
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình Balanced                                               |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetBalancedConfig() {
    PresetConfig config;
    
    // Risk Management - Cân bằng
    config.RiskPercent = 1.0;
    config.MaxDailyDrawdown = 5.0;
    config.MaxTotalDrawdown = 15.0;
    config.MaxConcurrentTrades = 3;
    config.MaxConsecutiveLosses = 5;
    
    // Entry - Cân bằng
    config.MinPullbackPercent = 30.0;
    config.MaxPullbackPercent = 70.0;
    config.MinADXLevel = 25.0;
    config.VolatilityThreshold = 1.5;
    config.MaxSpreadPips = 2.0;
    
    // SL/TP - Cân bằng
    config.StopLoss_ATR = 2.0;
    config.TakeProfit_RR = 2.0;
    config.BreakevenRR = 1.0;
    
    // Trailing
    config.TrailingMode = TRAILING_ATR;
    config.TrailingATR = 1.5;
    
    // Filters - Cơ bản
    config.EnableMarketRegimeFilter = true;
    config.EnableVolatilityFilter = true;
    config.EnableSpreadFilter = true;
    config.EnableSessionFilter = false;
    config.SessionType = FILTER_ALL_SESSIONS;
    config.EnableNewsFilter = true;
    config.NewsMinutesBefore = 30;
    config.NewsMinutesAfter = 30;
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình Aggressive                                             |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetAggressiveConfig() {
    PresetConfig config;
    
    // Risk Management - Tích cực hơn
    config.RiskPercent = 1.5;
    config.MaxDailyDrawdown = 7.0;
    config.MaxTotalDrawdown = 20.0;
    config.MaxConcurrentTrades = 5;
    config.MaxConsecutiveLosses = 7;
    
    // Entry - Nhiều cơ hội hơn
    config.MinPullbackPercent = 20.0;
    config.MaxPullbackPercent = 80.0;
    config.MinADXLevel = 20.0;
    config.VolatilityThreshold = 2.0;
    config.MaxSpreadPips = 3.0;
    
    // SL/TP - Tích cực
    config.StopLoss_ATR = 1.5;
    config.TakeProfit_RR = 1.5;
    config.BreakevenRR = 0.8;
    
    // Trailing
    config.TrailingMode = TRAILING_ATR;
    config.TrailingATR = 1.0;
    
    // Filters - Ít hạn chế
    config.EnableMarketRegimeFilter = false;
    config.EnableVolatilityFilter = false;
    config.EnableSpreadFilter = true;
    config.EnableSessionFilter = false;
    config.SessionType = FILTER_ALL_SESSIONS;
    config.EnableNewsFilter = false;
    config.NewsMinutesBefore = 15;
    config.NewsMinutesAfter = 15;
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình cho Forex Major                                        |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetForexMajorConfig() {
    PresetConfig config = GetBalancedConfig();
    
    // Điều chỉnh cho Forex majors
    config.MaxSpreadPips = 1.5;
    config.VolatilityThreshold = 1.3;
    config.EnableSessionFilter = true;
    config.SessionType = FILTER_MAJOR_SESSIONS_ONLY;
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình cho Gold                                               |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetGoldConfig() {
    PresetConfig config = GetBalancedConfig();
    
    // Điều chỉnh cho Gold
    config.RiskPercent = 0.8; // Giảm risk do volatility cao
    config.MaxSpreadPips = 5.0; // Gold có spread cao hơn
    config.VolatilityThreshold = 2.5;
    config.StopLoss_ATR = 2.5;
    config.TakeProfit_RR = 1.8;
    config.EnableNewsFilter = true;
    config.NewsMinutesBefore = 45;
    config.NewsMinutesAfter = 45;
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình cho Indices                                            |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetIndicesConfig() {
    PresetConfig config = GetBalancedConfig();
    
    // Điều chỉnh cho Indices
    config.RiskPercent = 1.2;
    config.MaxSpreadPips = 3.0;
    config.VolatilityThreshold = 2.0;
    config.EnableSessionFilter = true;
    config.SessionType = FILTER_AMERICAN; // US session cho indices
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình EURUSD                                                 |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetEURUSDConfig(ENUM_TIMEFRAMES tf, string style) {
    PresetConfig config;
    
    if (style == "conservative") {
        config = GetConservativeConfig();
    } else if (style == "aggressive") {
        config = GetAggressiveConfig();
    } else {
        config = GetBalancedConfig();
    }
    
    // Điều chỉnh cho EURUSD
    config.MaxSpreadPips = 1.2;
    config.VolatilityThreshold = 1.2;
    
    if (tf == PERIOD_H1) {
        config.MinADXLevel = 22.0;
        config.StopLoss_ATR = 1.8;
    } else if (tf == PERIOD_H4) {
        config.MinADXLevel = 25.0;
        config.StopLoss_ATR = 2.2;
        config.TakeProfit_RR = 2.5;
    }
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình GBPUSD                                                 |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetGBPUSDConfig(ENUM_TIMEFRAMES tf, string style) {
    PresetConfig config;
    
    if (style == "conservative") {
        config = GetConservativeConfig();
    } else if (style == "aggressive") {
        config = GetAggressiveConfig();
    } else {
        config = GetBalancedConfig();
    }
    
    // Điều chỉnh cho GBPUSD (volatility cao hơn EURUSD)
    config.MaxSpreadPips = 1.8;
    config.VolatilityThreshold = 1.8;
    config.RiskPercent *= 0.9; // Giảm risk 10%
    
    if (tf == PERIOD_H1) {
        config.MinADXLevel = 25.0;
        config.StopLoss_ATR = 2.0;
    } else if (tf == PERIOD_H4) {
        config.MinADXLevel = 28.0;
        config.StopLoss_ATR = 2.5;
    }
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình USDJPY                                                 |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetUSDJPYConfig(ENUM_TIMEFRAMES tf, string style) {
    PresetConfig config;
    
    if (style == "conservative") {
        config = GetConservativeConfig();
    } else if (style == "aggressive") {
        config = GetAggressiveConfig();
    } else {
        config = GetBalancedConfig();
    }
    
    // Điều chỉnh cho USDJPY
    config.MaxSpreadPips = 1.5;
    config.VolatilityThreshold = 1.4;
    
    if (tf == PERIOD_H1) {
        config.MinADXLevel = 23.0;
        config.StopLoss_ATR = 1.9;
    } else if (tf == PERIOD_H4) {
        config.MinADXLevel = 26.0;
        config.StopLoss_ATR = 2.3;
    }
    
    return config;
}

//+------------------------------------------------------------------+
//| Cấu hình XAUUSD                                                 |
//+------------------------------------------------------------------+
PresetConfig CPresetManager::GetXAUUSDConfig(ENUM_TIMEFRAMES tf, string style) {
    PresetConfig config;
    
    if (style == "conservative") {
        config = GetConservativeConfig();
    } else if (style == "aggressive") {
        config = GetAggressiveConfig();
    } else {
        config = GetBalancedConfig();
    }
    
    // Điều chỉnh cho XAUUSD (Gold)
    config.RiskPercent *= 0.8; // Giảm risk do volatility rất cao
    config.MaxSpreadPips = 8.0;
    config.VolatilityThreshold = 3.0;
    config.StopLoss_ATR = 2.8;
    config.TakeProfit_RR = 1.8;
    config.EnableNewsFilter = true;
    config.NewsMinutesBefore = 60;
    config.NewsMinutesAfter = 60;
    
    if (tf == PERIOD_M15) {
        config.MinADXLevel = 20.0;
        config.StopLoss_ATR = 2.5;
        config.MaxConcurrentTrades = 2;
    } else if (tf == PERIOD_H1) {
        config.MinADXLevel = 25.0;
        config.StopLoss_ATR = 3.0;
    }
    
    return config;
}

//+------------------------------------------------------------------+
//| Áp dụng config vào context                                      |
//+------------------------------------------------------------------+
void CPresetManager::ApplyConfigToContext(EAContext* context, const PresetConfig& config) {
    if (!context) return;
    
    // Risk Management
    context->RiskPercent = config.RiskPercent;
    context->MaxDailyDrawdown = config.MaxDailyDrawdown;
    context->MaxTotalDrawdown = config.MaxTotalDrawdown;
    context->MaxConcurrentTrades = config.MaxConcurrentTrades;
    context->MaxConsecutiveLosses = config.MaxConsecutiveLosses;
    
    // Entry Parameters
    context->MinPullbackPercent = config.MinPullbackPercent;
    context->MaxPullbackPercent = config.MaxPullbackPercent;
    context->ADX_MinLevel = config.MinADXLevel;
    context->VolatilityThreshold = config.VolatilityThreshold;
    context->MaxSpreadPips = config.MaxSpreadPips;
    
    // Stop Loss & Take Profit
    context->StopLoss_ATR = config.StopLoss_ATR;
    context->TakeProfit_RR = config.TakeProfit_RR;
    context->BreakevenRR = config.BreakevenRR;
    
    // Trailing Stop
    context->TrailingMode = config.TrailingMode;
    context->TrailingATR = config.TrailingATR;
    
    // Market Filters
    context->EnableMarketRegimeFilter = config.EnableMarketRegimeFilter;
    context->EnableVolatilityFilter = config.EnableVolatilityFilter;
    context->EnableSpreadFilter = config.EnableSpreadFilter;
    
    // Session Filters
    context->EnableSessionFilter = config.EnableSessionFilter;
    context->SessionType = config.SessionType;
    
    // News Filter
    context->EnableNewsFilter = config.EnableNewsFilter;
    context->NewsMinutesBefore = config.NewsMinutesBefore;
    context->NewsMinutesAfter = config.NewsMinutesAfter;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có phải Forex major không                         |
//+------------------------------------------------------------------+
bool CPresetManager::IsForexMajor(string symbol) {
    string majors[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};
    string sym = StringToUpper(symbol);
    
    for (int i = 0; i < ArraySize(majors); i++) {
        if (StringFind(sym, majors[i]) >= 0) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có phải Gold không                                 |
//+------------------------------------------------------------------+
bool CPresetManager::IsGold(string symbol) {
    string sym = StringToUpper(symbol);
    return (StringFind(sym, "XAUUSD") >= 0 || StringFind(sym, "GOLD") >= 0);
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có phải Index không                                |
//+------------------------------------------------------------------+
bool CPresetManager::IsIndex(string symbol) {
    string indices[] = {"US30", "SPX500", "NAS100", "GER40", "UK100", "FRA40", "JPN225"};
    string sym = StringToUpper(symbol);
    
    for (int i = 0; i < ArraySize(indices); i++) {
        if (StringFind(sym, indices[i]) >= 0) {
            return true;
        }
    }
    return false;
}

} // namespace ApexPullback
#endif // PRESET_MANAGER_MQH_