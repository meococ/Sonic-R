//+------------------------------------------------------------------+
//|                  Analysis_Indicators.mqh - v5.0                  |
//|            APEX Pullback EA - Universal Indicator Manager        |
//|      "A centralized hub for all technical indicator needs"       |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_INDICATORS_MQH
#define ANALYSIS_INDICATORS_MQH

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"
#include "Core_SymbolInfo.mqh"
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| CAppIndicators - Universal Indicator Manager                     |
//+------------------------------------------------------------------+
class CAppIndicators : public CObject
{
private:
    CLogger*                m_pLogger;
    CSymbolInfo*            m_pSymbolInfo;
    
    // Dynamic handle management
    CArrayObj*              m_indicatorList; // Stores SIndicatorHandle objects
    
    struct SIndicatorHandle : public CObject
    {
        string      unique_id;
        int         handle;
    };

    int      GetIndicatorHandle(const string unique_id, const MqlIndicator &indicator_def);
    string   GenerateUniqueID(const MqlIndicator &indicator_def);

public:
    CAppIndicators();
    ~CAppIndicators();

    bool     Initialize(CLogger* pLogger, CAppSymbolInfo* pSymbolInfo);
    void     Deinitialize();
    
    // --- Public Indicator Accessors ---
    int      GetMA(ENUM_APPLIED_PRICE applied_price, int period, int ma_shift, int ma_method, const int shift, double &result_buffer[]);
    int      GetATR(int period, const int shift, double &result_buffer[]);
    int      GetEMAOnArray(const double &in_array[], const int total, const int period, const int shift, double &out_array[]);
    int      FindHighestValue(const double &buffer[], int start_bar, int range, double &value, int &index);
    int      FindLowestValue(const double &buffer[], int start_bar, int range, double &value, int &index);
};

//+------------------------------------------------------------------+
//| Implementation                                                   |
//+------------------------------------------------------------------+
CAppIndicators::CAppIndicators()
{
    m_indicatorList = new CArrayObj();
}

CAppIndicators::~CAppIndicators()
{
    if(CheckPointer(m_indicatorList) == POINTER_VALID)
    {
        m_indicatorList->FreeMode(true);
        delete m_indicatorList;
    }
}

bool CAppIndicators::Initialize(CLogger* pLogger, CSymbolInfo* pSymbolInfo)
{
    if(!pLogger || !pSymbolInfo) return false;
    m_pLogger = pLogger;
    m_pSymbolInfo = pSymbolInfo;
    m_indicatorList->FreeMode(true);
    m_indicatorList->Clear();
    return true;
}

void CAppIndicators::Deinitialize()
{
    if(CheckPointer(m_indicatorList) == POINTER_VALID)
    {
        for(int i = m_indicatorList->Total() - 1; i >= 0; i--)
        {
            SIndicatorHandle* ind_handle = m_indicatorList->At(i);
            if(CheckPointer(ind_handle) == POINTER_VALID)
            {
                IndicatorRelease(ind_handle->handle);
            }
        }
        m_indicatorList->Clear();
    }
}

string CAppIndicators::GenerateUniqueID(const MqlIndicator &indicator_def)
{
    string id = indicator_def.name;
    for(uint i = 0; i < indicator_def.num_parameters; i++)
    {
        id += "|" + (string)indicator_def.parameters[i].integer_value;
    }
    return id;
}

int CAppIndicators::GetIndicatorHandle(const string unique_id, const MqlIndicator &indicator_def)
{
    for(int i = 0; i < m_indicatorList->Total(); i++)
    {
        SIndicatorHandle* ind_handle = m_indicatorList->At(i);
        if(ind_handle->unique_id == unique_id)
        {
            return ind_handle->handle;
        }
    }

    int new_handle = iCustom(m_pSymbolInfo->Symbol(), m_pSymbolInfo->Timeframe(), indicator_def.name, indicator_def.parameters);
    if(new_handle != INVALID_HANDLE)
    {
        SIndicatorHandle* new_ind_handle = new SIndicatorHandle();
        new_ind_handle->unique_id = unique_id;
        new_ind_handle->handle = new_handle;
        m_indicatorList->Add(new_ind_handle);
        return new_handle;
    }
    return INVALID_HANDLE;
}

int CAppIndicators::GetMA(ENUM_APPLIED_PRICE applied_price, int period, int ma_shift, int ma_method, const int shift, double &result_buffer[])
{
    MqlIndicator id = {};
    id.name = "Moving Average";
    id.num_parameters = 4;
    id.parameters[0].integer_value = period;
    id.parameters[1].integer_value = ma_shift;
    id.parameters[2].integer_value = ma_method;
    id.parameters[3].integer_value = applied_price;
    
    string unique_id = GenerateUniqueID(id);
    int handle = GetIndicatorHandle(unique_id, id);
    if(handle == INVALID_HANDLE) return -1;
    
    return CopyBuffer(handle, 0, shift, ArraySize(result_buffer), result_buffer);
}

int CAppIndicators::GetATR(int period, const int shift, double &result_buffer[])
{
    MqlIndicator id = {};
    id.name = "ATR";
    id.num_parameters = 1;
    id.parameters[0].integer_value = period;
    
    string unique_id = GenerateUniqueID(id);
    int handle = GetIndicatorHandle(unique_id, id);
    if(handle == INVALID_HANDLE) return -1;
    
    return CopyBuffer(handle, 0, shift, ArraySize(result_buffer), result_buffer);
}

int CAppIndicators::GetEMAOnArray(const double &in_array[], const int total, const int period, const int shift, double &out_array[])
{
    // iMAOnArray doesn't need a handle, it's a direct calculation
    return iMAOnArray(in_array, total, period, 0, MODE_EMA, out_array);
}

int CAppIndicators::FindHighestValue(const double &buffer[], int start_bar, int range, double &value, int &index)
{
    if(start_bar < 0 || range <= 0 || start_bar + range > ArraySize(buffer)) return -1;
    
    int max_idx = -1;
    double max_val = -DBL_MAX;
    
    for(int i = start_bar; i < start_bar + range; i++)
    {
        if(buffer[i] > max_val)
        {
            max_val = buffer[i];
            max_idx = i;
        }
    }
    value = max_val;
    index = max_idx;
    return max_idx;
}

int CAppIndicators::FindLowestValue(const double &buffer[], int start_bar, int range, double &value, int &index)
{
    if(start_bar < 0 || range <= 0 || start_bar + range > ArraySize(buffer)) return -1;

    int min_idx = -1;
    double min_val = DBL_MAX;

    for(int i = start_bar; i < start_bar + range; i++)
    {
        if(buffer[i] < min_val)
        {
            min_val = buffer[i];
            min_idx = i;
        }
    }
    value = min_val;
    index = min_idx;
    return min_idx;
}

#endif // ANALYSIS_INDICATORS_MQH