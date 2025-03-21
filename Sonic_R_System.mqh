//+------------------------------------------------------------------+
//|                                          Sonic_R_System.mq5      |
//|                                         Dựa trên Sonic R System  |
//+------------------------------------------------------------------+
#property copyright "Sonic R System"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   15

// Include các thành phần
#include "Sonic_Dragon.mqh"
#include "Sonic_PVA_Candles.mqh"
#include "Sonic_PVA_Volumes.mqh"

// Tạo đối tượng cho mỗi thành phần
CSonicDragon Dragon;
CSonicPVACandles PVACandles;
CSonicPVAVolumes PVAVolumes;

// Các tham số đầu vào chung
input string GeneralSettings = "=== GENERAL SETTINGS ===";
input bool EnableDragon = true;
input bool EnablePVACandles = true; 
input bool EnablePVAVolumes = true;

// Các tham số cho Dragon
input string DragonSettings = "=== DRAGON SETTINGS ===";
input int DragonPeriod = 34;      // Dragon Period (EMA34)
input int TrendPeriod = 89;       // Trend Period (EMA89)
input int MAPeriod = 200;         // MA Period (SMA200)
input color DragonHighColor = clrRoyalBlue;   // Dragon High Color
input color DragonLowColor = clrRoyalBlue;    // Dragon Low Color
input color DragonMidColor = clrNavy;         // Dragon Mid Color
input color DragonFillColor = clrAliceBlue;   // Dragon Fill Color
input color TrendLineColor = clrMagenta;      // Trend Line Color

// Các tham số cho PVA Candles
input string PVACandlesSettings = "=== PVA CANDLES SETTINGS ===";
input int VolumePeriod = 10;               // Volume Averaging Period
input double ClimaxThreshold = 2.0;        // Climax Volume Threshold
input double RisingThreshold = 1.5;        // Rising Volume Threshold
input color NormalBullColor = clrLightGray; // Normal Bull Color
input color NormalBearColor = clrGray;      // Normal Bear Color
input color RisingBullColor = clrDodgerBlue; // Rising Bull Color
input color RisingBearColor = clrMediumPurple; // Rising Bear Color
input color ClimaxBullColor = clrLimeGreen;  // Climax Bull Color
input color ClimaxBearColor = clrCrimson;    // Climax Bear Color

// Các tham số cho PVA Volumes
input string PVAVolumesSettings = "=== PVA VOLUMES SETTINGS ===";
input bool ShowVolumeWindow = true;        // Show Volume Window
input color NormalVolumeColor = clrGray;   // Normal Volume Color
input color RisingBullVolumeColor = clrDodgerBlue; // Rising Bull Volume Color
input color RisingBearVolumeColor = clrMediumPurple; // Rising Bear Volume Color
input color ClimaxBullVolumeColor = clrLimeGreen; // Climax Bull Volume Color
input color ClimaxBearVolumeColor = clrCrimson; // Climax Bear Volume Color
input bool VolumeAlertOn = false;          // Volume Alert On

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Khởi tạo các thành phần
    int buffer_index = 0;
    
    // Khởi tạo Dragon
    if(EnableDragon) 
    {
        buffer_index = Dragon.Init(buffer_index, DragonPeriod, TrendPeriod, MAPeriod,
                                 DragonHighColor, DragonLowColor, DragonMidColor, 
                                 DragonFillColor, TrendLineColor);
    }
    
    // Khởi tạo PVA Candles
    if(EnablePVACandles) 
    {
        buffer_index = PVACandles.Init(buffer_index, VolumePeriod, ClimaxThreshold, RisingThreshold,
                                     NormalBullColor, NormalBearColor, RisingBullColor, 
                                     RisingBearColor, ClimaxBullColor, ClimaxBearColor);
    }
    
    // Khởi tạo PVA Volumes (trong cửa sổ con nếu được chọn)
    if(EnablePVAVolumes && ShowVolumeWindow) 
    {
        PVAVolumes.Init(VolumePeriod, ClimaxThreshold, RisingThreshold,
                        NormalVolumeColor, RisingBullVolumeColor, RisingBearVolumeColor,
                        ClimaxBullVolumeColor, ClimaxBearVolumeColor, VolumeAlertOn);
    }
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    if(rates_total <= 0) return 0;
    
    int limit = rates_total - prev_calculated;
    
    // Nếu là lần đầu tính toán hoặc có sự thay đổi dữ liệu lịch sử
    if(prev_calculated == 0 || limit > 1) 
    {
        limit = rates_total - 1; // Tính toán lại tất cả
    }
    
    // Tính toán các thành phần
    if(EnableDragon) 
    {
        Dragon.Calculate(rates_total, prev_calculated, limit, time, open, high, low, close);
    }
    
    if(EnablePVACandles) 
    {
        PVACandles.Calculate(rates_total, prev_calculated, limit, time, open, high, low, close, tick_volume);
    }
    
    if(EnablePVAVolumes && ShowVolumeWindow) 
    {
        PVAVolumes.Calculate(rates_total, prev_calculated, limit, tick_volume, high, low, close, open);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Xử lý sự kiện timer nếu cần
}

//+------------------------------------------------------------------+
//| ChartEvent handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
    // Xử lý sự kiện biểu đồ nếu cần
}

//+------------------------------------------------------------------+
//| DeInit function                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Dọn dẹp đối tượng
    ObjectsDeleteAll(0, "Sonic_R_");
}