//+------------------------------------------------------------------+
//|                                           PVSRA_Analysis.mqh     |
//+------------------------------------------------------------------+

class CPVSRA_Analysis
{
private:
    // Các thông số phân tích PVSRA
    double ClimaxThreshold;       // Ngưỡng volume cho Climax (200%)
    double RisingThreshold;       // Ngưỡng volume cho Rising (150%)
    int VolumePeriod;             // Số nến cho tính trung bình volume
    
    // S&R levels tracking
    double LastWholeNumbers[10];  // Lưu trữ các whole numbers gần đây
    double LastHalfNumbers[10];   // Lưu trữ các half numbers gần đây 
    double LastQuarterNumbers[20]; // Lưu trữ các quarter numbers gần đây
    
    // Phân tích market phases
    enum ENUM_MARKET_PHASE {
        PHASE_ACCUMULATION,       // Tích lũy
        PHASE_MARKUP,             // Tăng giá
        PHASE_DISTRIBUTION,       // Phân phối
        PHASE_MARKDOWN,           // Giảm giá
        PHASE_UNKNOWN             // Chưa xác định
    };
    
    ENUM_MARKET_PHASE CurrentPhase;
    ENUM_MARKET_PHASE PreviousPhase;
    
    // Lưu trữ cache kết quả phân tích
    int LastBullBearResult;
    datetime LastBullBearTime;
    ENUM_TIMEFRAMES LastBullBearTimeframe;
    
    // Các biến phụ trợ khác
    double PointSize;
    double PipSize;
    int SRLevelCount;
    
    // Struct cho thông tin MM
    struct MM_Info {
        bool isBullish;
        double tradingLevel;
        double volumeRatio;
        datetime detectionTime;
        string detectionReason;
    };
    
    MM_Info RecentMMActivity[20]; // Lưu 20 hoạt động gần nhất của MM
    int MMActivityCount;
    
public:
    // Constructor
    CPVSRA_Analysis(double climaxThreshold = 2.0, double risingThreshold = 1.5, int volumePeriod = 10)
    {
        ClimaxThreshold = climaxThreshold;
        RisingThreshold = risingThreshold;
        VolumePeriod = volumePeriod;
        LastBullBearResult = 0;
        LastBullBearTime = 0;
        LastBullBearTimeframe = PERIOD_CURRENT;
        CurrentPhase = PHASE_UNKNOWN;
        PreviousPhase = PHASE_UNKNOWN;
        MMActivityCount = 0;
        
        // Khởi tạo Point và Pip size
        PointSize = Point();
        if(_Digits == 3 || _Digits == 5)
            PipSize = PointSize * 10.0;
        else
            PipSize = PointSize;
        
        // Xử lý đặc biệt cho các cặp tiền tệ có đặc tính khác
        if(StringSubstr(_Symbol, 0, 6) == "XAUUSD") PipSize = 1.0;
        else if(StringSubstr(_Symbol, 0, 6) == "USDTRY") PipSize = 0.01;
        
        // Khởi tạo các S&R levels
        SRLevelCount = 0;
        InitializeSRLevels();
    }
    
    // Khởi tạo các S&R levels dựa trên giá hiện tại
    void InitializeSRLevels()
    {
        double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double base_level = MathFloor(current_price);
        
        // Tính toán 5 whole numbers (2 dưới, hiện tại, 2 trên)
        for(int i = 0; i < 5; i++)
        {
            LastWholeNumbers[i] = base_level - 2 + i;
        }
        
        // Tính toán 5 half numbers 
        for(int i = 0; i < 5; i++)
        {
            LastHalfNumbers[i] = base_level - 2 + i + 0.5;
        }
        
        // Tính toán 10 quarter numbers
        for(int i = 0; i < 10; i++)
        {
            LastQuarterNumbers[i*2] = LastWholeNumbers[i % 5] + 0.25;
            LastQuarterNumbers[i*2+1] = LastWholeNumbers[i % 5] + 0.75;
        }
        
        SRLevelCount = 20; // 5 whole + 5 half + 10 quarter
    }
    
    // Kiểm tra xem giá có gần S&R level không
    bool IsPriceNearSRLevel(double price, double &level, double &distance)
    {
        double min_distance = 100000;
        double closest_level = 0;
        
        // Kiểm tra whole numbers (ưu tiên cao nhất)
        for(int i = 0; i < 5; i++)
        {
            double dist = MathAbs(price - LastWholeNumbers[i]);
            if(dist < min_distance)
            {
                min_distance = dist;
                closest_level = LastWholeNumbers[i];
            }
        }
        
        // Kiểm tra half numbers (ưu tiên trung bình)
        for(int i = 0; i < 5; i++)
        {
            double dist = MathAbs(price - LastHalfNumbers[i]);
            if(dist < min_distance)
            {
                min_distance = dist;
                closest_level = LastHalfNumbers[i];
            }
        }
        
        // Kiểm tra quarter numbers (ưu tiên thấp nhất)
        for(int i = 0; i < 10; i++)
        {
            double dist = MathAbs(price - LastQuarterNumbers[i]);
            if(dist * 0.8 < min_distance) // Nhân 0.8 để giảm ưu tiên so với whole & half
            {
                min_distance = dist * 0.8;
                closest_level = LastQuarterNumbers[i];
            }
        }
        
        // Kết quả
        level = closest_level;
        distance = min_distance;
        
        // Chỉ coi là gần khi cách S&R level không quá 20 pip
        return (min_distance < 20 * PipSize);
    }
    
    // Phân tích PVSRA chính
    int AnalyzeBullBear(ENUM_TIMEFRAMES timeframe, bool force_update = false)
    {
        // Kiểm tra cache nếu cần
        datetime current_bar_time = iTime(_Symbol, timeframe, 0);
        if(!force_update && LastBullBearTimeframe == timeframe && LastBullBearTime == current_bar_time)
        {
            return LastBullBearResult;
        }
        
        // Lấy dữ liệu
        double volumes[100];
        double closes[100];
        double highs[100];
        double lows[100];
        double opens[100];
        
        // Lấy dữ liệu - sử dụng ít nhất 50 nến để phân tích pattern
        int data_count = 50;
        if(CopyTickVolume(_Symbol, timeframe, 0, data_count, volumes) <= 0) return 0;
        if(CopyClose(_Symbol, timeframe, 0, data_count, closes) <= 0) return 0;
        if(CopyHigh(_Symbol, timeframe, 0, data_count, highs) <= 0) return 0;
        if(CopyLow(_Symbol, timeframe, 0, data_count, lows) <= 0) return 0;
        if(CopyOpen(_Symbol, timeframe, 0, data_count, opens) <= 0) return 0;
        
        // Tính volume trung bình gần đây
        double avg_volume = 0;
        for(int i = 1; i <= VolumePeriod; i++)
        {
            avg_volume += volumes[i];
        }
        avg_volume /= VolumePeriod;
        
        // Tính toán các S&R Levels gần nhất
        double price = closes[0];
        double closest_sr_level;
        double distance_to_sr;
        bool near_sr = IsPriceNearSRLevel(price, closest_sr_level, distance_to_sr);
        
        // Phân tích thông tin MM
        int result = 0; // Neutral
        string reason = "";
        
        // Phân tích giai đoạn thị trường sử dụng 50 nến
        ENUM_MARKET_PHASE phase = IdentifyMarketPhase(closes, highs, lows, volumes, data_count);
        PreviousPhase = CurrentPhase;
        CurrentPhase = phase;
        
        // ==== 1. Phân tích MM tại các S&R levels ====
        
        if(near_sr)
        {
            double volume_ratio = volumes[0] / (avg_volume > 0 ? avg_volume : 1);
            
            // Ở DƯỚI whole/half number với volume cao = BULLS (MM đang mua ở vùng hỗ trợ)
            if(price < closest_sr_level && volume_ratio > RisingThreshold)
            {
                // Kiểm tra thêm pattern giá
                if(closes[0] > opens[0]) // Nến tăng
                {
                    result = 1; // Bulls
                    reason = "High volume below SR with bullish candle";
                }
                else if((lows[0] < lows[1] || lows[0] < lows[2]) && closes[0] > lows[0] + (highs[0] - lows[0])*0.5)
                {
                    // Kiểm tra mẫu hình rejection (giá có dấu hiệu từ chối vùng giá thấp)
                    result = 1; // Bulls
                    reason = "Rejection pattern below SR";
                }
            }
            
            // Ở TRÊN whole/half number với volume cao = BEARS (MM đang bán ở vùng kháng cự)
            else if(price > closest_sr_level && volume_ratio > RisingThreshold)
            {
                // Kiểm tra thêm pattern giá
                if(closes[0] < opens[0]) // Nến giảm
                {
                    result = -1; // Bears
                    reason = "High volume above SR with bearish candle";
                }
                else if((highs[0] > highs[1] || highs[0] > highs[2]) && closes[0] < highs[0] - (highs[0] - lows[0])*0.5)
                {
                    // Kiểm tra mẫu hình rejection (giá có dấu hiệu từ chối vùng giá cao)
                    result = -1; // Bears
                    reason = "Rejection pattern above SR";
                }
            }
        }
        
        // ==== 2. Phân tích Climax Volume ====
        
        if(result == 0) // Nếu chưa xác định được từ S&R
        {
            double volume_ratio = volumes[0] / (avg_volume > 0 ? avg_volume : 1);
            
            if(volume_ratio >= ClimaxThreshold)
            {
                // Kiểm tra climax ở đỉnh hay đáy
                bool is_local_high = true;
                bool is_local_low = true;
                
                for(int i = 1; i <= 3; i++)
                {
                    if(highs[0] <= highs[i]) is_local_high = false;
                    if(lows[0] >= lows[i]) is_local_low = false;
                }
                
                // Climax tại đỉnh thường là Bears (MM selling)
                if(is_local_high)
                {
                    result = -1; // Bears
                    reason = "Climax volume at price high";
                }
                
                // Climax tại đáy thường là Bulls (MM buying)
                else if(is_local_low)
                {
                    result = 1; // Bulls
                    reason = "Climax volume at price low";
                }
            }
        }
        
        // ==== 3. Phân tích dựa trên Market Phase ====
        
        if(result == 0) // Nếu vẫn chưa xác định được
        {
            switch(CurrentPhase)
            {
                case PHASE_ACCUMULATION:
                    result = 1; // Bulls - MM accumulating
                    reason = "Accumulation phase detected";
                    break;
                    
                case PHASE_MARKUP:
                    // Trong giai đoạn markup, giá xác nhận xu hướng tăng
                    // Nhưng cần phân biệt markup thật với bull trap
                    if(volumes[0] < avg_volume * 0.8 && closes[0] > opens[0])
                    {
                        // Volume thấp khi giá tăng trong markup có thể là bull trap
                        result = -1; // Có thể là bear trap
                        reason = "Potential bull trap in markup phase (low volume)";
                    }
                    else
                    {
                        result = 1; // Xác nhận bulls
                        reason = "Confirmed markup phase";
                    }
                    break;
                    
                case PHASE_DISTRIBUTION:
                    result = -1; // Bears - MM distributing
                    reason = "Distribution phase detected";
                    break;
                    
                case PHASE_MARKDOWN:
                    // Trong giai đoạn markdown, giá xác nhận xu hướng giảm
                    // Nhưng cần phân biệt markdown thật với bear trap
                    if(volumes[0] < avg_volume * 0.8 && closes[0] < opens[0])
                    {
                        // Volume thấp khi giá giảm trong markdown có thể là bear trap
                        result = 1; // Có thể là bull trap
                        reason = "Potential bear trap in markdown phase (low volume)";
                    }
                    else
                    {
                        result = -1; // Xác nhận bears
                        reason = "Confirmed markdown phase";
                    }
                    break;
                    
                default:
                    // Không xác định được phase
                    result = 0;
                    reason = "Market phase unclear";
                    break;
            }
        }
        
        // Lưu kết quả vào cache
        LastBullBearResult = result;
        LastBullBearTime = current_bar_time;
        LastBullBearTimeframe = timeframe;
        
        // Lưu hoạt động MM gần đây
        if(result != 0)
        {
            // Shift mảng để lưu kết quả mới
            for(int i = MMActivityCount; i > 0; i--)
            {
                if(i >= 20) continue; // Giới hạn 20 bản ghi
                RecentMMActivity[i] = RecentMMActivity[i-1];
            }
            
            // Lưu kết quả mới
            MM_Info newActivity;
            newActivity.isBullish = (result > 0);
            newActivity.tradingLevel = closest_sr_level;
            newActivity.volumeRatio = volumes[0] / avg_volume;
            newActivity.detectionTime = current_bar_time;
            newActivity.detectionReason = reason;
            
            RecentMMActivity[0] = newActivity;
            if(MMActivityCount < 20) MMActivityCount++;
        }
        
        return result;
    }
    
    // Xác định giai đoạn thị trường (Accumulation, Distribution, Markup, Markdown)
    ENUM_MARKET_PHASE IdentifyMarketPhase(const double &closes[], const double &highs[], 
                                         const double &lows[], const double &volumes[], int count)
    {
        if(count < 20) return PHASE_UNKNOWN; // Cần ít nhất 20 nến
        
        // Tính ATR để đánh giá volatility
        double atr = 0;
        for(int i = 1; i < 14; i++)
        {
            atr += MathMax(highs[i], closes[i-1]) - MathMin(lows[i], closes[i-1]);
        }
        atr /= 14;
        
        // Tính các thông số chính
        double range_percent = 0;  // Phần trăm biến động
        int direction_changes = 0; // Số lần thay đổi hướng
        double volume_trend = 0;   // Xu hướng volume
        
        // Tính range và direction changes
        double highest = closes[0];
        double lowest = closes[0];
        int last_direction = 0; // 0=unknown, 1=up, -1=down
        
        for(int i = 0; i < 20; i++)
        {
            // Tìm highest/lowest
            if(highs[i] > highest) highest = highs[i];
            if(lows[i] < lowest) lowest = lows[i];
            
            // Đếm thay đổi hướng
            if(i > 0)
            {
                int current_direction = 0;
                if(closes[i] > closes[i-1]) current_direction = 1;
                else if(closes[i] < closes[i-1]) current_direction = -1;
                
                if(last_direction != 0 && current_direction != 0 && current_direction != last_direction)
                {
                    direction_changes++;
                }
                
                if(current_direction != 0) last_direction = current_direction;
            }
        }
        
        range_percent = (highest - lowest) / lowest * 100.0;
        
        // Phân tích volume trend
        double early_volume_avg = 0;
        double recent_volume_avg = 0;
        
        for(int i = 10; i < 20; i++) early_volume_avg += volumes[i];
        for(int i = 0; i < 10; i++) recent_volume_avg += volumes[i];
        
        early_volume_avg /= 10;
        recent_volume_avg /= 10;
        
        volume_trend = recent_volume_avg / early_volume_avg;
        
        // Xác định phase dựa trên các thông số
        
        // Giai đoạn ACCUMULATION: Range nhỏ, nhiều lần đổi hướng
        if(range_percent < 1.0 && direction_changes >= 8)
        {
            return PHASE_ACCUMULATION;
        }
        
        // Giai đoạn DISTRIBUTION: Range nhỏ, nhiều lần đổi hướng, ở mức giá cao
        // Tính xem 20 nến gần đây có ở gần high của 50 nến không
        double highest_50 = highs[0];
        double lowest_50 = lows[0];
        
        for(int i = 0; i < count; i++)
        {
            if(highs[i] > highest_50) highest_50 = highs[i];
            if(lows[i] < lowest_50) lowest_50 = lows[i];
        }
        
        double current_position = (closes[0] - lowest_50) / (highest_50 - lowest_50);
        
        if(range_percent < 1.0 && direction_changes >= 8 && current_position > 0.7)
        {
            return PHASE_DISTRIBUTION;
        }
        
        // Giai đoạn MARKUP: Trend tăng rõ ràng, volume tăng
        bool uptrend = true;
        for(int i = 0; i < 5; i++)
        {
            if(closes[i] < closes[i+5]) // Giá hiện tại thấp hơn giá 5 nến trước
            {
                uptrend = false;
                break;
            }
        }
        
        if(uptrend && volume_trend > 1.2) // Volume tăng 20%
        {
            return PHASE_MARKUP;
        }
        
        // Giai đoạn MARKDOWN: Trend giảm rõ ràng, volume tăng
        bool downtrend = true;
        for(int i = 0; i < 5; i++)
        {
            if(closes[i] > closes[i+5]) // Giá hiện tại cao hơn giá 5 nến trước
            {
                downtrend = false;
                break;
            }
        }
        
        if(downtrend && volume_trend > 1.2) // Volume tăng 20%
        {
            return PHASE_MARKDOWN;
        }
        
        // Không xác định được
        return PHASE_UNKNOWN;
    }
    
    // Truy xuất thông tin MM gần đây
    bool GetRecentMMActivity(bool &isBullish, double &tradingLevel, double &volumeRatio, string &reason)
    {
        if(MMActivityCount == 0) return false;
        
        isBullish = RecentMMActivity[0].isBullish;
        tradingLevel = RecentMMActivity[0].tradingLevel;
        volumeRatio = RecentMMActivity[0].volumeRatio;
        reason = RecentMMActivity[0].detectionReason;
        
        return true;
    }
    
    // Kiểm tra xem MM đã thay đổi dự định chưa (chuyển từ bull sang bear hoặc ngược lại)
    bool HasMMIntentionChanged()
    {
        if(MMActivityCount < 2) return false;
        
        // Nếu hai hoạt động MM gần nhất trái ngược nhau
        return RecentMMActivity[0].isBullish != RecentMMActivity[1].isBullish;
    }
    
    // Lấy giai đoạn thị trường hiện tại
    ENUM_MARKET_PHASE GetCurrentMarketPhase()
    {
        return CurrentPhase;
    }
    
    // Kiểm tra xem có sự thay đổi giai đoạn thị trường không
    bool HasMarketPhaseChanged()
    {
        return (CurrentPhase != PreviousPhase && PreviousPhase != PHASE_UNKNOWN);
    }
    
    // Xác định xem có nên dùng phương pháp Entry nào
    string GetRecommendedEntryMethod()
    {
        if(MMActivityCount == 0) return "NO ENTRY - Insufficient MM data";
        
        bool mm_is_bullish = RecentMMActivity[0].isBullish;
        
        switch(CurrentPhase)
        {
            case PHASE_ACCUMULATION:
                if(mm_is_bullish) 
                    return "SCOUT LONG - MM accumulating";
                else
                    return "NO ENTRY - Conflicting signal in accumulation";
                break;
                
            case PHASE_MARKUP:
                if(mm_is_bullish)
                    return "CLASSIC LONG - Confirmed markup phase";
                else
                    return "SCOUT SHORT - Potential reversal in markup";
                break;
                
            case PHASE_DISTRIBUTION:
                if(!mm_is_bullish)
                    return "SCOUT SHORT - MM distributing";
                else
                    return "NO ENTRY - Conflicting signal in distribution";
                break;
                
            case PHASE_MARKDOWN:
                if(!mm_is_bullish)
                    return "CLASSIC SHORT - Confirmed markdown phase";
                else
                    return "SCOUT LONG - Potential reversal in markdown";
                break;
                
            default:
                return "NO CLEAR ENTRY - Unknown market phase";
        }
    }
};