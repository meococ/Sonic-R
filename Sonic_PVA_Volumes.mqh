//+------------------------------------------------------------------+
//|                                       Sonic_PVA_Volumes.mqh      |
//+------------------------------------------------------------------+

class CSonicPVAVolumes
{
private:
    // Hiển thị trong cửa sổ riêng
    int indicatorHandle;
    
    int volumePeriod;
    double climaxThreshold;
    double risingThreshold;
    color normalColor;
    color risingBullColor;
    color risingBearColor;
    color climaxBullColor;
    color climaxBearColor;
    bool alertOn;
    
    // Thêm biến cho Alert cải tiến
    string brokerName;
    bool alertAllowed;
    datetime lastAlertTime;
    int chartScale;
    int barWidth;
    
    string indicatorName;

public:
    CSonicPVAVolumes()
    {
        indicatorHandle = INVALID_HANDLE;
        lastAlertTime = 0;
        indicatorName = "Sonic_PVA_Volumes";
        alertAllowed = true;
        chartScale = -1;
        barWidth = 2;
    }
    
    // Phương thức cập nhật Chart Scale
    void UpdateChartScale(int scale)
    {
        if(chartScale != scale)
        {
            chartScale = scale;
            
            // Thiết lập bar width dựa trên Chart Scale
            switch(chartScale)
            {
                case 0: barWidth = 1; break;
                case 1: 
                case 2: barWidth = 2; break;
                case 3: barWidth = 3; break;
                case 4: barWidth = 6; break;
                default: barWidth = 13; break;
            }
        }
    }
    
    void Init(int volPeriod, double climaxThr, double risingThr,
             color normalCol, color risingBullCol, color risingBearCol,
             color climaxBullCol, color climaxBearCol, bool alert, string broker = "")
    {
        volumePeriod = volPeriod;
        climaxThreshold = climaxThr;
        risingThreshold = risingThr;
        normalColor = normalCol;
        risingBullColor = risingBullCol;
        risingBearColor = risingBearCol;
        climaxBullColor = climaxBullCol;
        climaxBearColor = climaxBearCol;
        alertOn = alert;
        brokerName = broker;
        
        // Khởi tạo Chart Scale nếu chưa có
        if(chartScale == -1)
        {
            long chartScaleValue;
            if(ChartGetInteger(0, CHART_SCALE, 0, chartScaleValue))
                chartScale = (int)chartScaleValue;
            else
                chartScale = 3; // Giá trị mặc định
                
            // Cập nhật Bar Width dựa trên Chart Scale
            UpdateChartScale(chartScale);
        }
        
        // Reset alert status
        alertAllowed = alertOn;
        
        // Tạo tên chỉ báo với thông tin Chart Scale
        string shortName = "Sonic PVA (" + IntegerToString(chartScale) + ")";
        if(alertOn) shortName += " Alert On";
        
        // Tạo chỉ báo con
        indicatorHandle = iCustom(Symbol(), 0, indicatorName, 
                                 volumePeriod, climaxThreshold, risingThreshold,
                                 normalColor, risingBullColor, risingBearColor,
                                 climaxBullColor, climaxBearColor, alertOn, brokerName);
    }
    
    void Calculate(const int rates_total, const int prev_calculated, const int limit,
                  const long& tick_volume[], const double& high[], const double& low[], 
                  const double& close[], const double& open[])
    {
        if(indicatorHandle == INVALID_HANDLE)
            return;
            
        // Xử lý cảnh báo khối lượng nếu cần
        if(alertOn && rates_total > 1)
        {
            // Tính trung bình khối lượng
            double avgVolume = 0;
            for(int i = 1; i <= volumePeriod && i < rates_total; i++)
            {
                avgVolume += tick_volume[i];
            }
            avgVolume /= volumePeriod;
            
            // Kiểm tra khối lượng đột biến
            double volumeRatio = tick_volume[0] / avgVolume;
            double currentProduct = (high[0] - low[0]) * tick_volume[0];
            
            // Tìm sản phẩm cao nhất
            double highestProduct = 0;
            for(int i = 1; i <= volumePeriod && i < rates_total; i++)
            {
                double product = (high[i] - low[i]) * tick_volume[i];
                if(product > highestProduct) highestProduct = product;
            }
            
            // Kiểm tra điều kiện cảnh báo
            bool isClimaxVolume = (volumeRatio >= climaxThreshold || currentProduct >= highestProduct);
            
            if(isClimaxVolume && alertAllowed && TimeCurrent() - lastAlertTime > 300) // 5 phút giữa các cảnh báo
            {
                string direction = (close[0] > open[0]) ? "Bullish" : "Bearish";
                string brokerInfo = (brokerName != "") ? brokerName + ": " : "";
                string message = brokerInfo + Symbol() + " " + EnumToString((ENUM_TIMEFRAMES)Period()) + 
                               " Volume Climax " + direction + " detected!";
                
                Alert(message);
                lastAlertTime = TimeCurrent();
                alertAllowed = false; // Chặn cảnh báo đến khi có một thanh mới
            }
        }
    }
    
    // Cho phép cảnh báo mới khi có thanh mới
    void ResetAlert()
    {
        if(alertOn)
            alertAllowed = true;
    }
};