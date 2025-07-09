//+------------------------------------------------------------------+
//|                                               FairValueGaps.mqh |
//|                                     Sonic R EA - SMC Engine |
//|                                     https://www.manus-ai.com |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "SMC_Structures.mqh"

//+------------------------------------------------------------------+
//| CFairValueGaps Class                                             |
//| Responsible for detecting Fair Value Gaps (FVG).                 |
//+------------------------------------------------------------------+
class CFairValueGaps
{
private:
    // Configuration
    FVGConfig           m_config;

    // Context
    string              m_symbol;
    ENUM_TIMEFRAMES     m_timeframe;

    // Data
    CArrayObj*          m_fvgs; // Array of FairValueGap

public:
    CFairValueGaps(void);
   ~CFairValueGaps(void);

    bool Initialize(const FVGConfig &config, string symbol, ENUM_TIMEFRAMES timeframe);
    void Update();
    
    // Getters
    int GetFVGsCount() const { return m_fvgs.Total(); }
    FairValueGap* GetFVG(int index) const { return (FairValueGap*)m_fvgs.At(index); }

private:
    void ScanForFVGs();
    void AddFVG(const MqlRates &candle1, const MqlRates &candle3, FVG_TYPE type);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFairValueGaps::CFairValueGaps(void)
{
    m_fvgs = new CArrayObj();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFairValueGaps::~CFairValueGaps(void)
{
    if(CheckPointer(m_fvgs) != POINTER_INVALID) delete m_fvgs;
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CFairValueGaps::Initialize(const FVGConfig &config, string symbol, ENUM_TIMEFRAMES timeframe)
{
    m_config = config;
    m_symbol = symbol;
    m_timeframe = timeframe;
    return true;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CFairValueGaps::Update()
{
    ScanForFVGs();
}

//+------------------------------------------------------------------+
//| ScanForFVGs                                                      |
//+------------------------------------------------------------------+
void CFairValueGaps::ScanForFVGs()
{
    MqlRates rates[];
    // Look back a reasonable number of candles to find FVGs
    if(CopyRates(m_symbol, m_timeframe, 0, m_config.LookbackPeriod, rates) <= 0)
    {
        printf("Failed to copy rates for FVG scan");
        return;
    }

    // Clear previous FVGs to avoid duplicates. A better approach might be to check for existing ones.
    m_fvgs.Clear();

    // We need at least 3 candles to identify an FVG.
    for(int i = ArraySize(rates) - 3; i >= 0; i--)
    {
        const MqlRates &candle1 = rates[i+2]; // Most recent candle in the pattern
        const MqlRates &candle2 = rates[i+1];
        const MqlRates &candle3 = rates[i];   // Oldest candle in the pattern

        // Bullish FVG (or BISI - Buyside Imbalance Sellside Inefficiency)
        // The low of candle 1 is higher than the high of candle 3.
        if(candle1.low > candle3.high)
        {
            // Check if the gap is large enough
            double gap_size = candle1.low - candle3.high;
            if(gap_size >= m_config.MinGapSizePoints * _Point)
            {
                 AddFVG(candle1, candle3, FVG_BULLISH);
                 printf("Bullish FVG found at %s", TimeToString(candle2.time));
            }
        }

        // Bearish FVG (or SIBI - Sellside Imbalance Buyside Inefficiency)
        // The high of candle 1 is lower than the low of candle 3.
        if(candle1.high < candle3.low)
        {
            // Check if the gap is large enough
            double gap_size = candle3.low - candle1.high;
            if(gap_size >= m_config.MinGapSizePoints * _Point)
            {
                AddFVG(candle1, candle3, FVG_BEARISH);
                printf("Bearish FVG found at %s", TimeToString(candle2.time));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| AddFVG                                                           |
//+------------------------------------------------------------------+
void CFairValueGaps::AddFVG(const MqlRates &candle1, const MqlRates &candle3, FVG_TYPE type)
{
    FairValueGap* fvg = new FairValueGap();
    fvg.type = type;
    fvg.time_start = candle1.time;
    fvg.time_end = candle3.time;
    fvg.price_high = (type == FVG_BULLISH) ? candle1.high : candle3.high;
    fvg.price_low = (type == FVG_BULLISH) ? candle3.low : candle1.low;
    fvg.is_filled = false;

    m_fvgs.Add(fvg);
}