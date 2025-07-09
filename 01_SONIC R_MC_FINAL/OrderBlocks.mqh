//+------------------------------------------------------------------+
//|                                                  OrderBlocks.mqh |
//|                                     Sonic R EA - SMC Engine |
//|                                     https://www.manus-ai.com |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "SMC_Structures.mqh"
#include "MarketStructure.mqh"

//+------------------------------------------------------------------+
//| COrderBlocks Class                                               |
//| Responsible for detecting Order Blocks.                          |
//+------------------------------------------------------------------+
class COrderBlocks
{
private:
    // Configuration
    OrderBlockConfig    m_config;

    // Context
    string              m_symbol;
    ENUM_TIMEFRAMES     m_timeframe;
    CMarketStructure*   m_market_structure; // Reference to market structure module

    // Data
    CArrayObj*          m_order_blocks; // Array of OrderBlock

public:
    COrderBlocks(void);
   ~COrderBlocks(void);

    bool Initialize(const OrderBlockConfig &config, string symbol, ENUM_TIMEFRAMES timeframe, CMarketStructure* ms_module);
    void Update();
    
    // Getters
    int GetOrderBlocksCount() const { return m_order_blocks.Total(); }
    OrderBlock* GetOrderBlock(int index) const { return (OrderBlock*)m_order_blocks.At(index); }

private:
    void ScanForOrderBlocks();
    void AddOrderBlock(const MqlRates &rate, ORDER_BLOCK_TYPE type);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
COrderBlocks::COrderBlocks(void)
{
    m_order_blocks = new CArrayObj();
    m_market_structure = NULL;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
COrderBlocks::~COrderBlocks(void)
{
    if(CheckPointer(m_order_blocks) != POINTER_INVALID) delete m_order_blocks;
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool COrderBlocks::Initialize(const OrderBlockConfig &config, string symbol, ENUM_TIMEFRAMES timeframe, CMarketStructure* ms_module)
{
    m_config = config;
    m_symbol = symbol;
    m_timeframe = timeframe;
    m_market_structure = ms_module;

    if(CheckPointer(m_market_structure) == POINTER_INVALID)
    {
        printf("OrderBlocks: Market Structure module is not valid!");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void COrderBlocks::Update()
{
    // The main logic will be triggered by market structure changes,
    // so this might be called less frequently or when a new structure point is confirmed.
    ScanForOrderBlocks();
}

//+------------------------------------------------------------------+
//| ScanForOrderBlocks                                               |
//+------------------------------------------------------------------+
void COrderBlocks::ScanForOrderBlocks()
{
    if(CheckPointer(m_market_structure) == POINTER_INVALID) return;

    int last_structure_point_index = m_market_structure->GetStructurePointsCount() - 1;
    if(last_structure_point_index < 0) return;

    MarketStructurePoint* last_sp = m_market_structure->GetStructurePoint(last_structure_point_index);
    if(last_sp == NULL) return;

    // Check if we have already processed this structure point
    if(m_order_blocks.Total() > 0)
    {
        OrderBlock* last_ob = (OrderBlock*)m_order_blocks.At(m_order_blocks.Total() - 1);
        // A simple check to avoid re-processing. A more robust mechanism might be needed.
        if(last_ob.time_start >= last_sp.time) return;
    }

    MqlRates rates[];
    if(CopyRates(m_symbol, m_timeframe, last_sp.time, 1, rates) <= 0) return;
    int rate_index = 0; // The index of the break candle

    // Find the candle that created the structure break
    // We need to look back from the break point
    MqlRates history_rates[];
    if(CopyRates(m_symbol, m_timeframe, 0, rates[rate_index].time, 100, history_rates) <= 0) return;

    int break_candle_index = -1;
    for(int i = ArraySize(history_rates) - 1; i >= 0; i--)
    {
        if(history_rates[i].time == last_sp.time)
        {
            break_candle_index = i;
            break;
        }
    }

    if(break_candle_index <= 0) return;

    // Bullish OB: Last bearish candle before a bullish BOS/CHOCH
    if(last_sp.swing_type == SWING_HIGH) // Breakout was to the upside
    {
        for(int i = break_candle_index - 1; i >= 0; i--)
        {
            // Find the last down-candle before the up-move
            if(history_rates[i].close < history_rates[i].open)
            {
                AddOrderBlock(history_rates[i], ORDER_BLOCK_BULLISH);
                printf("Bullish Order Block found at %s", TimeToString(history_rates[i].time));
                return; // Found the OB, exit
            }
        }
    }
    // Bearish OB: Last bullish candle before a bearish BOS/CHOCH
    else if(last_sp.swing_type == SWING_LOW) // Breakout was to the downside
    {
        for(int i = break_candle_index - 1; i >= 0; i--)
        {
            // Find the last up-candle before the down-move
            if(history_rates[i].close > history_rates[i].open)
            {
                AddOrderBlock(history_rates[i], ORDER_BLOCK_BEARISH);
                printf("Bearish Order Block found at %s", TimeToString(history_rates[i].time));
                return; // Found the OB, exit
            }
        }
    }
}

//+------------------------------------------------------------------+
//| AddOrderBlock                                                    |
//+------------------------------------------------------------------+
void COrderBlocks::AddOrderBlock(const MqlRates &rate, ORDER_BLOCK_TYPE type)
{
    OrderBlock* ob = new OrderBlock();
    ob.type = type;
    ob.time_start = rate.time;
    ob.price_high = rate.high;
    ob.price_low = rate.low;
    ob.volume = rate.tick_volume;
    ob.is_mitigated = false;

    m_order_blocks.Add(ob);
}