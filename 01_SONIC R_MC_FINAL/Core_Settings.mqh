//+------------------------------------------------------------------+
//|                       Core_Settings.mqh                          |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+
#ifndef APEX_CORE_SETTINGS_MQH_
#define APEX_CORE_SETTINGS_MQH_

#include "SonicR_CommonStructs.mqh"   // For CEaContext and all dependencies

//+------------------------------------------------------------------+
//| CSettings - Loads and provides access to EA settings.            |
//+------------------------------------------------------------------+
namespace ApexSonicR {

class CSettings
{
public:
    CSettings() {}
    ~CSettings() {}

    bool Initialize();
    void Deinitialize();
    bool IsInitialized() const { return true; }
    void OnTick() {}
    
    // Settings getters (placeholder implementations)
    double GetLotSize() const { return 0.01; }
    int GetMagicNumber() const { return 12345; }
    string GetExpertName() const { return "SonicR_EA"; }
};

} // namespace ApexSonicR

#endif // APEX_CORE_SETTINGS_MQH_