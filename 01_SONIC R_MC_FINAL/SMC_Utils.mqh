//+------------------------------------------------------------------+
//|                                                    SMC_Utils.mqh |
//|                                    Smart Money Concepts Indicator |
//|                                                  Utility Functions |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "SMC_Structures.mqh"

//+------------------------------------------------------------------+
//| Utility Functions Class                                          |
//+------------------------------------------------------------------+
class CSMCUtils
{
private:
    static double m_point_value;
    static int    m_digits;
    static string m_symbol;
    
public:
    //+------------------------------------------------------------------+
    //| Initialization                                                   |
    //+------------------------------------------------------------------+
    static void Initialize(string symbol = "")
    {
        if(symbol == "")
            m_symbol = Symbol();
        else
            m_symbol = symbol;
            
        m_point_value = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
        m_digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
    }
    
    //+------------------------------------------------------------------+
    //| Price Conversion Functions                                       |
    //+------------------------------------------------------------------+
    static double PipsToPoints(double pips)
    {
        if(m_digits == 5 || m_digits == 3)
            return pips * 10 * m_point_value;
        else
            return pips * m_point_value;
    }
    
    static double PointsToPips(double points)
    {
        if(m_digits == 5 || m_digits == 3)
            return points / (10 * m_point_value);
        else
            return points / m_point_value;
    }
    
    static double NormalizePrice(double price)
    {
        return NormalizeDouble(price, m_digits);
    }
    
    static double GetSpread()
    {
        return SymbolInfoInteger(m_symbol, SYMBOL_SPREAD) * m_point_value;
    }
    
    //+------------------------------------------------------------------+
    //| Time Functions                                                   |
    //+------------------------------------------------------------------+
    static bool IsNewBar(datetime &last_bar_time)
    {
        datetime current_bar_time = iTime(m_symbol, PERIOD_CURRENT, 0);
        if(current_bar_time != last_bar_time)
        {
            last_bar_time = current_bar_time;
            return true;
        }
        return false;
    }
    
    static int GetBarIndex(datetime time)
    {
        return iBarShift(m_symbol, PERIOD_CURRENT, time);
    }
    
    static datetime GetBarTime(int index)
    {
        return iTime(m_symbol, PERIOD_CURRENT, index);
    }
    
    static bool IsMarketOpen()
    {
        return SymbolInfoInteger(m_symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
    }
    
    //+------------------------------------------------------------------+
    //| Price Data Functions                                             |
    //+------------------------------------------------------------------+
    static double GetHigh(int index)
    {
        return iHigh(m_symbol, PERIOD_CURRENT, index);
    }
    
    static double GetLow(int index)
    {
        return iLow(m_symbol, PERIOD_CURRENT, index);
    }
    
    static double GetOpen(int index)
    {
        return iOpen(m_symbol, PERIOD_CURRENT, index);
    }
    
    static double GetClose(int index)
    {
        return iClose(m_symbol, PERIOD_CURRENT, index);
    }
    
    static long GetVolume(int index)
    {
        return iVolume(m_symbol, PERIOD_CURRENT, index);
    }
    
    static double GetTypicalPrice(int index)
    {
        return (GetHigh(index) + GetLow(index) + GetClose(index)) / 3.0;
    }
    
    static double GetRange(int index)
    {
        return GetHigh(index) - GetLow(index);
    }
    
    static bool IsBullishCandle(int index)
    {
        return GetClose(index) > GetOpen(index);
    }
    
    static bool IsBearishCandle(int index)
    {
        return GetClose(index) < GetOpen(index);
    }
    
    static bool IsDojiCandle(int index, double doji_threshold = 0.1)
    {
        double body_size = MathAbs(GetClose(index) - GetOpen(index));
        double range = GetRange(index);
        return (range > 0) ? (body_size / range) < doji_threshold : false;
    }
    
    //+------------------------------------------------------------------+
    //| Volume Analysis Functions                                        |
    //+------------------------------------------------------------------+
    static double GetAverageVolume(int period, int start_index = 1)
    {
        if(period <= 0) return 0.0;
        
        double total_volume = 0.0;
        for(int i = start_index; i < start_index + period; i++)
        {
            total_volume += (double)GetVolume(i);
        }
        return total_volume / period;
    }
    
    static bool IsHighVolume(int index, double multiplier = 1.5, int avg_period = 20)
    {
        double current_volume = (double)GetVolume(index);
        double average_volume = GetAverageVolume(avg_period, index + 1);
        return current_volume > (average_volume * multiplier);
    }
    
    static bool IsLowVolume(int index, double multiplier = 0.7, int avg_period = 20)
    {
        double current_volume = (double)GetVolume(index);
        double average_volume = GetAverageVolume(avg_period, index + 1);
        return current_volume < (average_volume * multiplier);
    }
    
    static double GetVolumeRatio(int index, int avg_period = 20)
    {
        double current_volume = (double)GetVolume(index);
        double average_volume = GetAverageVolume(avg_period, index + 1);
        return (average_volume > 0) ? current_volume / average_volume : 0.0;
    }
    
    //+------------------------------------------------------------------+
    //| Swing Point Detection                                            |
    //+------------------------------------------------------------------+
    static bool IsSwingHigh(int index, int strength = 5)
    {
        if(index < strength || index >= Bars(Symbol(), PERIOD_CURRENT) - strength)
            return false;
            
        double center_high = GetHigh(index);
        
        // Check left side
        for(int i = 1; i <= strength; i++)
        {
            if(GetHigh(index + i) >= center_high)
                return false;
        }
        
        // Check right side
        for(int i = 1; i <= strength; i++)
        {
            if(GetHigh(index - i) > center_high)
                return false;
        }
        
        return true;
    }
    
    static bool IsSwingLow(int index, int strength = 5)
    {
        if(index < strength || index >= Bars(Symbol(), PERIOD_CURRENT) - strength)
            return false;
            
        double center_low = GetLow(index);
        
        // Check left side
        for(int i = 1; i <= strength; i++)
        {
            if(GetLow(index + i) <= center_low)
                return false;
        }
        
        // Check right side
        for(int i = 1; i <= strength; i++)
        {
            if(GetLow(index - i) < center_low)
                return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Impulse Detection                                                |
    //+------------------------------------------------------------------+
    static bool DetectImpulse(int start_index, int end_index, double min_pips, int max_candles, bool &is_bullish)
    {
        if(start_index <= end_index || start_index - end_index > max_candles)
            return false;
            
        double start_price = GetClose(start_index);
        double end_price = GetClose(end_index);
        double move_pips = PointsToPips(MathAbs(start_price - end_price));
        
        if(move_pips < min_pips)
            return false;
            
        is_bullish = end_price > start_price;
        
        // Optional: Check for momentum (e.g., no significant counter-moves)
        // ...
        
        return true;
    }
};