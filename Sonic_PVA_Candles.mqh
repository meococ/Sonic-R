//+------------------------------------------------------------------+
//|                                     Sonic_Trade_Levels.mqh       |
//+------------------------------------------------------------------+

// Lớp CSonicTradeLevels - Hiển thị mức giá TP, SL và Entry Points
class CSonicTradeLevels
{
private:
    // Các biến cho đường EP, TP, SL
    bool showOpenTrades;
    bool showClosedTrades;
    
    // Kiểu lot hiển thị: 1=micro, 2=mini, 3=standard
    int lotTypeDisplay;
    
    // Hiển thị cho giao dịch mở
    bool showEPLevelsLines;
    bool showEPLevelsLabels;
    bool showEPPriceDots;
    bool showEPPriceLabels;
    bool showEPPLLines;
    bool showSubordinateLines;
    double overrideTrialSL;
    double overrideTrialTP;
    
    // Hiển thị cho giao dịch đã đóng
    bool showClosedPriceDots;
    bool showClosedPriceLabels;
    bool showClosedPriceLines;
    bool showClosedSubordinateLines;
    bool showAllTradesAsOne;
    int plLabel1AdjustHeight;
    int plLabel2AdjustHeight;
    int plLabel3AdjustHeight;
    int simpleLookbackTimeSpan;
    string lookbackExactStartTime;
    string lookbackExactEndTime;
    
    // Hiển thị P/L
    bool showPLMonies;
    bool showPLAccountPercent;
    
    // Màu sắc và kích thước
    color epLevelLineColor;
    color avLevelLineColor;
    color slLevelLineColor;
    color tpLevelLineColor;
    int priceDotRingSize;
    int priceDotSize;
    int priceDotCenterSize;
    color priceDotCenterColor;
    color priceLabelDotLong;
    color priceLabelDotShort;
    color priceLabelDotClosed;
    color plLinePositive;
    color plLineNegative;
    color plLabelBackground;
    color plLabelTextPositive;
    color plLabelTextNegative;
    
    // Biến theo dõi Chart Scale
    int chartScale;
    datetime t0, t1, t2, t3;
    
    // Biến cho giao dịch mở
    int openEPs;
    int orderType;
    double openAvgPrice;
    double openMicroLots;
    double openSize;
    double openDistancePips;
    double openTotalPips;
    double openProfit;
    double tpPrice, slPrice;
    string lotStr, side;
    
    // Biến cho hỗ trợ kích thước điểm và định dạng giá
    double poin;
    string labelStyle;
    int labelSize;
    string labelStyle2;
    int labelSize2;
    int priceLabelSymbol;
    
    bool initialized;
    bool deinitialized;

public:
    // Constructor
    CSonicTradeLevels()
    {
        // Mặc định
        showOpenTrades = true;
        showClosedTrades = true;
        lotTypeDisplay = 1;
        showPLMonies = false;
        showPLAccountPercent = false;
        
        showEPLevelsLines = true;
        showEPLevelsLabels = true;
        showEPPriceDots = true;
        showEPPriceLabels = false;
        showEPPLLines = true;
        showSubordinateLines = false;
        overrideTrialSL = 0.0;
        overrideTrialTP = 0.0;
        
        showClosedPriceDots = true;
        showClosedPriceLabels = false;
        showClosedPriceLines = true;
        showClosedSubordinateLines = false;
        showAllTradesAsOne = false;
        plLabel1AdjustHeight = 30;
        plLabel2AdjustHeight = 30;
        plLabel3AdjustHeight = 30;
        simpleLookbackTimeSpan = 60;
        lookbackExactStartTime = "yyyy.mm.dd hh:mm";
        lookbackExactEndTime = "yyyy.mm.dd hh:mm";
        
        epLevelLineColor = clrMediumBlue;
        avLevelLineColor = clrDarkOrchid;
        slLevelLineColor = clrCrimson;
        tpLevelLineColor = clrForestGreen;
        priceDotRingSize = 14;
        priceDotSize = 10;
        priceDotCenterSize = 5;
        priceDotCenterColor = clrWhite;
        priceLabelDotLong = clrDodgerBlue;
        priceLabelDotShort = clrRed;
        priceLabelDotClosed = clrBlack;
        plLinePositive = clrCornflowerBlue;
        plLineNegative = clrSalmon;
        plLabelBackground = C'255,255,185';
        plLabelTextPositive = clrForestGreen;
        plLabelTextNegative = clrRed;
        
        chartScale = -1;
        priceLabelSymbol = 5;  // Mã wingdings cho hình chữ nhật
        labelStyle = "Arial Narrow";
        labelSize = 8;
        labelStyle2 = "Courier New";
        labelSize2 = 9;
        
        initialized = false;
        deinitialized = false;
    }
    
    // Phương thức cập nhật Chart Scale
    void UpdateChartScale(int scale)
    {
        if(chartScale != scale)
        {
            chartScale = scale;
            ApplyChartScale();
        }
    }
    
    // Thiết lập tham số dựa trên Chart Scale
    void ApplyChartScale()
    {
        // T0 = điểm neo cho tất cả đường
        t0 = TimeCurrent();
        
        // Thiết lập các điểm dừng/bắt đầu cho các đường giao dịch
        // Với hiển thị EP Levels Lines & Labels
        // T1 = điểm dừng EP lines / điểm bắt đầu labels
        // T2 = điểm dừng TP/SL/AV lines / điểm bắt đầu labels (dịch sang phải)
        // Không hiển thị EP Levels Lines & Labels
        // T3 = điểm dừng TP/SL/AV lines / điểm bắt đầu labels (không dịch sang phải)
        
        switch(chartScale)
        {
            case 0:
                t1 = t0 + (PeriodSeconds() * 14);
                t2 = t0 + (PeriodSeconds() * 100);
                t3 = t0 + (PeriodSeconds() * 14);
                break;
            case 1:
                t1 = t0 + (PeriodSeconds() * 7);
                t2 = t0 + (PeriodSeconds() * 50);
                t3 = t0 + (PeriodSeconds() * 7);
                break;
            case 2:
                t1 = t0 + (PeriodSeconds() * 3);
                t2 = t0 + (PeriodSeconds() * 25);
                t3 = t0 + (PeriodSeconds() * 3);
                break;
            case 3:
                t1 = t0 + (PeriodSeconds() * 2);
                t2 = t0 + (PeriodSeconds() * 13);
                t3 = t0 + (PeriodSeconds() * 2);
                break;
            case 4:
                t1 = t0 + (PeriodSeconds() * 2);
                t2 = t0 + (PeriodSeconds() * 8);
                t3 = t0 + (PeriodSeconds() * 2);
                break;
            default:
                t1 = t0 + (PeriodSeconds() * 2);
                t2 = t0 + (PeriodSeconds() * 5);
                t3 = t0 + (PeriodSeconds() * 2);
                break;
        }
    }
    
    void Init(
        // Tham số chung
        bool showOpen = true,
        bool showClosed = true,
        int lotType = 1,
        bool plMoney = false,
        bool plPercent = false,
        
        // Tham số giao dịch mở
        bool epLines = true,
        bool epLabels = true,
        bool epDots = true,
        bool epLabelsP = false,
        bool epPLLines = true,
        bool subLines = false,
        double trialSL = 0.0,
        double trialTP = 0.0,
        
        // Tham số giao dịch đã đóng
        bool closedDots = true,
        bool closedLabels = false,
        bool closedLines = true,
        bool closedSubLines = false,
        bool allTradesAsOne = false,
        int label1Height = 30,
        int label2Height = 30,
        int label3Height = 30,
        int lookbackSpan = 60,
        string startTime = "yyyy.mm.dd hh:mm",
        string endTime = "yyyy.mm.dd hh:mm",
        
        // Màu sắc và kích thước
        color epLineColor = clrMediumBlue,
        color avLineColor = clrDarkOrchid,
        color slLineColor = clrCrimson,
        color tpLineColor = clrForestGreen,
        int dotRingSize = 14,
        int dotSize = 10,
        int dotCenterSize = 5,
        color dotCenterColor = clrWhite,
        color labelDotLong = clrDodgerBlue,
        color labelDotShort = clrRed,
        color labelDotClosed = clrBlack,
        color linePositive = clrCornflowerBlue,
        color lineNegative = clrSalmon,
        color labelBackground = C'255,255,185',
        color labelTextPositive = clrForestGreen,
        color labelTextNegative = clrRed
    )
    {
        // Thiết lập tham số chung
        showOpenTrades = showOpen;
        showClosedTrades = showClosed;
        lotTypeDisplay = lotType;
        showPLMonies = plMoney;
        showPLAccountPercent = plPercent;
        
        // Thiết lập tham số giao dịch mở
        showEPLevelsLines = epLines;
        showEPLevelsLabels = epLabels;
        showEPPriceDots = epDots;
        showEPPriceLabels = epLabelsP;
        showEPPLLines = epPLLines;
        showSubordinateLines = subLines;
        overrideTrialSL = trialSL;
        overrideTrialTP = trialTP;
        
        // Thiết lập tham số giao dịch đã đóng
        showClosedPriceDots = closedDots;
        showClosedPriceLabels = closedLabels;
        showClosedPriceLines = closedLines;
        showClosedSubordinateLines = closedSubLines;
        showAllTradesAsOne = allTradesAsOne;
        plLabel1AdjustHeight = label1Height;
        plLabel2AdjustHeight = label2Height;
        plLabel3AdjustHeight = label3Height;
        simpleLookbackTimeSpan = lookbackSpan;
        lookbackExactStartTime = startTime;
        lookbackExactEndTime = endTime;
        
        // Thiết lập màu sắc và kích thước
        epLevelLineColor = epLineColor;
        avLevelLineColor = avLineColor;
        slLevelLineColor = slLineColor;
        tpLevelLineColor = tpLineColor;
        priceDotRingSize = dotRingSize;
        priceDotSize = dotSize;
        priceDotCenterSize = dotCenterSize;
        priceDotCenterColor = dotCenterColor;
        priceLabelDotLong = labelDotLong;
        priceLabelDotShort = labelDotShort;
        priceLabelDotClosed = labelDotClosed;
        plLinePositive = linePositive;
        plLineNegative = lineNegative;
        plLabelBackground = labelBackground;
        plLabelTextPositive = labelTextPositive;
        plLabelTextNegative = labelTextNegative;
        
        // Khởi tạo Chart Scale nếu chưa có
        if(chartScale == -1)
        {
            long chartScaleValue;
            if(ChartGetInteger(0, CHART_SCALE, 0, chartScaleValue))
                chartScale = (int)chartScaleValue;
            else
                chartScale = 3; // Giá trị mặc định
                
            ApplyChartScale();
        }
        
        // Xác định "Poin" để tính đúng giá trị tính theo pip
        if(_Digits == 5 || _Digits == 3)
            poin = _Point * 10.0;
        else
            poin = _Point;
            
        // Xử lý đặc biệt cho XAUUSD và một số cặp tiền tệ Mexico/Czech
        if(StringSubstr(_Symbol, 0, 6) == "XAUUSD") poin = 1.0;
        else if(StringSubstr(_Symbol, 0, 6) == "USDMXN") poin = 0.001;
        else if(StringSubstr(_Symbol, 0, 6) == "USDCZK") poin = 0.001;
        
        initialized = true;
    }
    
    // Phương thức chính để vẽ các đường mức giá
    void Calculate(const int rates_total, const int prev_calculated)
    {
        if(!initialized) return;
        
        // Xóa tất cả các đối tượng cũ
        DeleteAllObjects();
        
        // Cập nhật giá trị t0 (điểm hiện tại)
        t0 = TimeCurrent();
        
        // Tính toán và vẽ giao dịch mở nếu được kích hoạt
        if(showOpenTrades)
        {
            if(SelectOpenFirstOrder())
            {
                ApplyChartScale();
                DrawOpenTradeEPs();
                DrawOpenTradeTPSL();
                DrawOpenTradeAV();
                DrawOpenTradePL();
            }
        }
        
        // Tính toán và vẽ giao dịch đã đóng nếu được kích hoạt
        if(showClosedTrades)
        {
            DrawClosedTradeEPs();
        }
    }
    
    // Xóa tất cả các đối tượng Trade Levels
    void DeleteAllObjects()
    {
        int totalObjects = ObjectsTotal(0);
        for(int i = totalObjects - 1; i >= 0; i--)
        {
            string name = ObjectName(0, i);
            if(StringSubstr(name, 0, 7) == "[Trade]")
            {
                ObjectDelete(0, name);
            }
        }
    }
    
    // Lựa chọn order đầu tiên cho biểu đồ hiện tại
    bool SelectOpenFirstOrder()
    {
        bool selected = false;
        
        // Tìm order đầu tiên trên biểu đồ hiện tại
        for(int i = 0; i < OrdersTotal(); i++)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_Symbol == OrderSymbol() && (OrderType() == ORDER_TYPE_BUY || OrderType() == ORDER_TYPE_SELL)
                    && OrderCloseTime() == 0)
                {
                    selected = true;
                    tpPrice = OrderTakeProfit();
                    slPrice = OrderStopLoss();
                    orderType = OrderType();
                    break;
                }
            }
        }
        
        return selected;
    }
    
    // Vẽ điểm vào lệnh (Entry Points) cho giao dịch mở
    void DrawOpenTradeEPs()
    {
        openEPs = 0;
        string epStr;
        int epNum = 1;
        
        for(int i = 0; i < OrdersTotal(); i++)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_Symbol == OrderSymbol() && (OrderType() == ORDER_TYPE_BUY || OrderType() == ORDER_TYPE_SELL))
                {
                    // Xác định văn bản dựa trên loại lệnh
                    if(OrderType() == ORDER_TYPE_BUY) side = " Long ";
                    else side = " Short";
                    
                    // Xử lý kích thước lệnh
                    double lots = 100 * OrderLots();
                    string size;
                    
                    switch(lotTypeDisplay)
                    {
                        case 1: // Micro lot
                            size = DoubleToString(lots, 2);
                            break;
                        case 2: // Mini lot
                            size = DoubleToString(lots / 10, 2);
                            break;
                        case 3: // Standard lot
                            size = DoubleToString(lots / 100, 2);
                            break;
                        default:
                            size = DoubleToString(lots, 2);
                    }
                    
                    if(StringLen(size) < 5) size = "0" + size;
                    
                    double openPrice = OrderOpenPrice();
                    string zeroPad = (epNum < 10) ? "0" : "";
                    
                    // Vẽ EP Levels Lines
                    if(showEPLevelsLines)
                    {
                        string epLine = "[Trade] EP " + zeroPad + IntegerToString(epNum) + " Level Line";
                        ObjectCreate(0, epLine, OBJ_TREND, 0, t1, openPrice, t0, openPrice);
                        ObjectSetInteger(0, epLine, OBJPROP_COLOR, epLevelLineColor);
                        ObjectSetInteger(0, epLine, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSetInteger(0, epLine, OBJPROP_WIDTH, 1);
                        ObjectSetInteger(0, epLine, OBJPROP_RAY_RIGHT, false);
                        ObjectSetInteger(0, epLine, OBJPROP_BACK, false);
                    }
                    
                    // Vẽ EP Levels Labels
                    if(showEPLevelsLabels)
                    {
                        string epLabel = "[Trade] EP " + zeroPad + IntegerToString(epNum) + " Level Label";
                        epStr = DoubleToString(openPrice, _Digits);
                        if(StringLen(epStr) == 6) epStr = "0" + epStr;
                        epStr = zeroPad + IntegerToString(epNum) + ": " + epStr + ",  " + size;
                        epStr = StringRepeat(" ", 29) + epStr + StringRepeat(" ", 18 - StringLen(epStr));
                        
                        ObjectCreate(0, epLabel, OBJ_TEXT, 0, t1, openPrice);
                        ObjectSetString(0, epLabel, OBJPROP_TEXT, epStr);
                        ObjectSetString(0, epLabel, OBJPROP_FONT, labelStyle);
                        ObjectSetInteger(0, epLabel, OBJPROP_FONTSIZE, labelSize);
                        ObjectSetInteger(0, epLabel, OBJPROP_COLOR, epLevelLineColor);
                        ObjectSetInteger(0, epLabel, OBJPROP_BACK, false);
                    }
                    
                    // Vẽ EP PL Lines
                    if(showEPPLLines)
                    {
                        string epTargetLine = "[Trade] EP " + IntegerToString(epNum) + " line from " + DoubleToString(openPrice, _Digits);
                        double closePrice = OrderClosePrice();
                        
                        ObjectCreate(0, epTargetLine, OBJ_TREND, 0, OrderOpenTime(), openPrice, t0, closePrice);
                        ObjectSetInteger(0, epTargetLine, OBJPROP_COLOR, OrderProfit() < 0 ? plLineNegative : plLinePositive);
                        ObjectSetInteger(0, epTargetLine, OBJPROP_STYLE, STYLE_DOT);
                        ObjectSetInteger(0, epTargetLine, OBJPROP_BACK, showSubordinateLines);
                        ObjectSetInteger(0, epTargetLine, OBJPROP_RAY_RIGHT, false);
                    }
                    
                    // Vẽ EP Price Dots
                    if(showEPPriceDots)
                    {
                        // Vòng ngoài của dots
                        string epPriceDot1 = "[Trade] EP " + IntegerToString(epNum) + " dot";
                        ObjectCreate(0, epPriceDot1, OBJ_TREND, 0, OrderOpenTime(), openPrice, OrderOpenTime(), openPrice);
                        ObjectSetInteger(0, epPriceDot1, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSetInteger(0, epPriceDot1, OBJPROP_COLOR, OrderType() == ORDER_TYPE_BUY ? priceLabelDotLong : priceLabelDotShort);
                        ObjectSetInteger(0, epPriceDot1, OBJPROP_WIDTH, priceDotSize);
                        
                        // Tâm của dots
                        string epPriceDot2 = "[Trade] EP " + IntegerToString(epNum) + " center";
                        ObjectCreate(0, epPriceDot2, OBJ_TREND, 0, OrderOpenTime(), openPrice, OrderOpenTime(), openPrice);
                        ObjectSetInteger(0, epPriceDot2, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSetInteger(0, epPriceDot2, OBJPROP_WIDTH, priceDotCenterSize);
                        ObjectSetInteger(0, epPriceDot2, OBJPROP_COLOR, priceDotCenterColor);
                    }
                    
                    // Vẽ EP Price Labels
                    if(showEPPriceLabels)
                    {
                        string epPriceLabel = "[Trade] EP " + IntegerToString(epNum) + " Label";
                        ObjectCreate(0, epPriceLabel, OBJ_ARROW, 0, OrderOpenTime(), openPrice);
                        ObjectSetInteger(0, epPriceLabel, OBJPROP_ARROWCODE, priceLabelSymbol);
                        ObjectSetInteger(0, epPriceLabel, OBJPROP_COLOR, OrderType() == ORDER_TYPE_BUY ? priceLabelDotLong : priceLabelDotShort);
                    }
                    
                    // Cập nhật bộ đếm
                    epNum++;
                    openEPs++;
                }
            }
        }
    }
    
    // Vẽ TP và SL cho giao dịch mở
    void DrawOpenTradeTPSL()
    {
        // Vẽ TP
        double tpPips;
        string tpStr1, tpStr2, tpStr3;
        string tpLine = "[Trade] TP Level";
        string tpLabel = "[Trade] TP Label";
        
        if(overrideTrialTP != 0.0) tpPrice = overrideTrialTP;
        
        if(tpPrice > 0.0)
        {
            tpPips = ((GetAvgPriceOfOpenOrders() - tpPrice) / poin) * openSize;
            tpPips = (orderType == ORDER_TYPE_BUY) ? -tpPips : tpPips;
            
            // Vẽ đường TP
            if(showEPLevelsLabels)
            {
                ObjectCreate(0, tpLine, OBJ_TREND, 0, t2, tpPrice, t0, tpPrice);
                ObjectSetInteger(0, tpLine, OBJPROP_COLOR, tpLevelLineColor);
            }
            else
            {
                ObjectCreate(0, tpLine, OBJ_TREND, 0, t3, tpPrice, t0, tpPrice);
                ObjectSetInteger(0, tpLine, OBJPROP_COLOR, tpLevelLineColor);
            }
            
            // Vẽ nhãn TP
            tpStr1 = DoubleToString(tpPrice, _Digits);
            if(StringLen(tpStr1) == 6) tpStr1 = "0" + tpStr1;
            tpStr2 = DoubleToString(tpPips, 0);
            if(tpPips >= 0) tpStr2 = "+" + tpStr2;
            
            if(showEPLevelsLabels)
            {
                ObjectCreate(0, tpLabel, OBJ_TEXT, 0, t2, tpPrice);
                tpStr3 = "TP: " + tpStr1 + ", p" + tpStr2;
                tpStr3 = StringRepeat(" ", 28) + tpStr3 + StringRepeat(" ", 27 - StringLen(tpStr3));
                ObjectSetString(0, tpLabel, OBJPROP_TEXT, tpStr3);
                ObjectSetString(0, tpLabel, OBJPROP_FONT, labelStyle2);
                ObjectSetInteger(0, tpLabel, OBJPROP_FONTSIZE, labelSize2);
                ObjectSetInteger(0, tpLabel, OBJPROP_COLOR, tpLevelLineColor);
            }
            else
            {
                ObjectCreate(0, tpLabel, OBJ_TEXT, 0, t3, tpPrice);
                tpStr3 = "TP: " + tpStr1 + ", p" + tpStr2;
                tpStr3 = StringRepeat(" ", 28) + tpStr3 + StringRepeat(" ", 27 - StringLen(tpStr3));
                ObjectSetString(0, tpLabel, OBJPROP_TEXT, tpStr3);
                ObjectSetString(0, tpLabel, OBJPROP_FONT, labelStyle2);
                ObjectSetInteger(0, tpLabel, OBJPROP_FONTSIZE, labelSize2);
                ObjectSetInteger(0, tpLabel, OBJPROP_COLOR, tpLevelLineColor);
            }
        }
        
        // Vẽ SL
        double slPips;
        string slStr1, slStr2, slStr3;
        string slLine = "[Trade] SL Level";
        string slLabel = "[Trade] SL Label";
        
        if(overrideTrialSL != 0.0) slPrice = overrideTrialSL;
        
        if(slPrice > 0.0)
        {
            slPips = ((GetAvgPriceOfOpenOrders() - slPrice) / poin) * openSize;
            slPips = (orderType == ORDER_TYPE_BUY) ? -slPips : slPips;
            
            // Vẽ đường SL
            if(showEPLevelsLabels)
            {
                ObjectCreate(0, slLine, OBJ_TREND, 0, t2, slPrice, t0, slPrice);
                ObjectSetInteger(0, slLine, OBJPROP_COLOR, slLevelLineColor);
            }
            else
            {
                ObjectCreate(0, slLine, OBJ_TREND, 0, t3, slPrice, t0, slPrice);
                ObjectSetInteger(0, slLine, OBJPROP_COLOR, slLevelLineColor);
            }
            
            // Vẽ nhãn SL
            slStr1 = DoubleToString(slPrice, _Digits);
            if(StringLen(slStr1) == 6) slStr1 = "0" + slStr1;
            slStr2 = DoubleToString(slPips, 0);
            
            if(showEPLevelsLabels)
            {
                ObjectCreate(0, slLabel, OBJ_TEXT, 0, t2, slPrice);
                slStr3 = "SL: " + slStr1 + ", p" + slStr2;
                slStr3 = StringRepeat(" ", 28) + slStr3 + StringRepeat(" ", 27 - StringLen(slStr3));
                ObjectSetString(0, slLabel, OBJPROP_TEXT, slStr3);
                ObjectSetString(0, slLabel, OBJPROP_FONT, labelStyle2);
                ObjectSetInteger(0, slLabel, OBJPROP_FONTSIZE, labelSize2);
                ObjectSetInteger(0, slLabel, OBJPROP_COLOR, slLevelLineColor);
            }
            else
            {
                ObjectCreate(0, slLabel, OBJ_TEXT, 0, t3, slPrice);
                slStr3 = "SL: " + slStr1 + ", p" + slStr2;
                slStr3 = StringRepeat(" ", 28) + slStr3 + StringRepeat(" ", 27 - StringLen(slStr3));
                ObjectSetString(0, slLabel, OBJPROP_TEXT, slStr3);
                ObjectSetString(0, slLabel, OBJPROP_FONT, labelStyle2);
                ObjectSetInteger(0, slLabel, OBJPROP_FONTSIZE, labelSize2);
                ObjectSetInteger(0, slLabel, OBJPROP_COLOR, slLevelLineColor);
            }
        }
    }
    
    // Vẽ đường trung bình (AV) cho các điểm vào lệnh
    void DrawOpenTradeAV()
    {
        string avStr1, avStr2, avStr3;
        double avgPrice = GetAvgPriceOfOpenOrders();
        string avLine = "[Trade] Av Level";
        string avLabel = "[Trade] Av Label";
        string fix = ", ";
        
        // Vẽ đường AV
        if(showEPLevelsLabels)
        {
            ObjectCreate(0, avLine, OBJ_TREND, 0, t2, avgPrice, t0, avgPrice);
            ObjectSetInteger(0, avLine, OBJPROP_COLOR, avLevelLineColor);
        }
        else
        {
            ObjectCreate(0, avLine, OBJ_TREND, 0, t3, avgPrice, t0, avgPrice);
            ObjectSetInteger(0, avLine, OBJPROP_COLOR, avLevelLineColor);
        }
        
        // Vẽ nhãn AV
        avStr1 = DoubleToString(avgPrice, _Digits);
        avStr1 = StringRepeat("0", 7 - StringLen(avStr1)) + avStr1;
        avStr2 = IntegerToString(openEPs) + "<" + lotStr;
        
        if(showEPLevelsLabels)
        {
            ObjectCreate(0, avLabel, OBJ_TEXT, 0, t2, avgPrice);
            avStr3 = "AV: " + avStr1 + fix + IntegerToString(openEPs) + "<" + lotStr + side;
            avStr3 = StringRepeat(" ", 28) + avStr3 + StringRepeat(" ", 27 - StringLen(avStr3));
            ObjectSetString(0, avLabel, OBJPROP_TEXT, avStr3);
            ObjectSetString(0, avLabel, OBJPROP_FONT, labelStyle2);
            ObjectSetInteger(0, avLabel, OBJPROP_FONTSIZE, labelSize2);
            ObjectSetInteger(0, avLabel, OBJPROP_COLOR, avLevelLineColor);
        }
        else
        {
            ObjectCreate(0, avLabel, OBJ_TEXT, 0, t3, avgPrice);
            avStr3 = "AV: " + avStr1 + fix + IntegerToString(openEPs) + "<" + lotStr + side;
            avStr3 = StringRepeat(" ", 28) + avStr3 + StringRepeat(" ", 27 - StringLen(avStr3));
            ObjectSetString(0, avLabel, OBJPROP_TEXT, avStr3);
            ObjectSetString(0, avLabel, OBJPROP_FONT, labelStyle2);
            ObjectSetInteger(0, avLabel, OBJPROP_FONTSIZE, labelSize2);
            ObjectSetInteger(0, avLabel, OBJPROP_COLOR, avLevelLineColor);
        }
    }
    
    // Vẽ nhãn PL cho giao dịch mở
    void DrawOpenTradePL()
    {
        // Tránh lỗi chia cho 0 nếu không có số dư tài khoản
        if(AccountBalance() == 0) return;
        
        string pd = DoubleToString(openDistancePips, 1);
        string pt = DoubleToString(openTotalPips, 1);
        string plStr;
        
        if(!showPLMonies && !showPLAccountPercent)
        {
            // Hiển thị số EPs, số lot, "Distance" pips, & P/L pips
            plStr = StringFormat("PL: %d<%s @ %s = p%s", openEPs, lotStr, DoubleToString(openDistancePips, 1), pt);
        }
        else
        {
            string a = StringFormat("PL: p%s", DoubleToString(openTotalPips, 1));
            string b = StringFormat(", $%s", DoubleToString(openProfit, 2));
            string c;
            double pct = (openProfit / AccountBalance()) * 100;
            
            if(pct < 10) c = StringFormat(", %s%%", DoubleToString(pct, 2));
            else c = StringFormat(", %s%%", DoubleToString(pct, 1));
            
            if(showPLMonies && !showPLAccountPercent) plStr = a + b;
            else if(!showPLMonies && showPLAccountPercent) plStr = a + c;
            else if(showPLMonies && showPLAccountPercent) plStr = a + b + c;
        }
        
        // Hiển thị nền cho nhãn P/L
        string openBG = "[Trade] Open PL Label";
        datetime firstBarTime = iTime(_Symbol, PERIOD_CURRENT, WindowFirstVisibleBar());
        
        ObjectCreate(0, openBG, OBJ_TEXT, 0, firstBarTime, SymbolInfoDouble(_Symbol, SYMBOL_BID));
        ObjectSetString(0, openBG, OBJPROP_TEXT, StringRepeat("g", StringLen(plStr)));
        ObjectSetString(0, openBG, OBJPROP_