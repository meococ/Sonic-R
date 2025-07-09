//+------------------------------------------------------------------+
//|        Signal_SonicR_ScoutEntry.mqh - Scout Entry System         |
//|                  APEX Pullback EA v4.6 - Refactored              |
//|      "Refactored for Flat Architecture and DSI Pattern"          |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNAL_SONICR_SCOUTENTRY_MQH_
#define APEX_SIGNAL_SONICR_SCOUTENTRY_MQH_

// Dependencies are managed by Includes.mqh

// Note: All relevant enums and structs (SScoutEntryConfig, SScoutEntryInfo, etc.)
// have been moved to Core_Defines.mqh for global access.

//+------------------------------------------------------------------+
//| CSonicRScoutEntry - Refactored Scout Entry System                |
//+------------------------------------------------------------------+
class CSonicRScoutEntry
{
private:
    bool                        m_initialized;
    CLogger*                    m_pLogger;
    CAppSymbolInfo*             m_pSymbolInfo;
    CSonicRDragonBand*          m_pDragonBand;
    CSonicRWavePattern*         m_pWavePattern;
    CSonicRPVSRA*               m_pPVSRA;
    
    SScoutEntryConfig           m_config;
    SScoutEntryInfo             m_activeScouts[];
    int                         m_maxScouts;
    
public:
    CSonicRScoutEntry() : m_initialized(false), m_pLogger(NULL), m_pSymbolInfo(NULL), 
                          m_pDragonBand(NULL), m_pWavePattern(NULL), m_pPVSRA(NULL),
                          m_maxScouts(10)
    {
        // Default config values will be set via SetConfig method
    }
    
    ~CSonicRScoutEntry() {}
    
    //+------------------------------------------------------------------+
    //| Initialize Scout Entry System                                    |
    //+------------------------------------------------------------------+
    bool Initialize(CEaContext* context, CMarketAnalysisManager* pManager)
    {
        if(!context || !pManager)
        {
            printf("Error: Null context or manager in ScoutEntry Initialize");
            return false;
        }

        m_pLogger = context->pLogger;
        m_pSymbolInfo = context->pSymbolInfo;

        if(!m_pLogger || !m_pSymbolInfo)
        {
            printf("Error: Failed to get Logger or SymbolInfo from context");
            return false;
        }

        // Get analysis modules from the central manager
        m_pDragonBand = pManager->GetDragonBandModule();
        m_pWavePattern = pManager->GetWavePatternModule();
        m_pPVSRA = pManager->GetPVSRAModule();

        if(!m_pDragonBand || !m_pWavePattern || !m_pPVSRA)
        {
            m_pLogger->LogError("Failed to get one or more analysis modules from MarketAnalysisManager in ScoutEntry");
            return false;
        }
        
        m_initialized = true;
        m_pLogger->Log(LOG_INFO, "CSonicRScoutEntry initialized successfully.");
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Set configuration                                                |
    //+------------------------------------------------------------------+
    void SetConfig(const SScoutEntryConfig& config)
    {
        m_config = config;
    }

    //+------------------------------------------------------------------+
    //| Main analysis method - Scan for scout entries                   |
    //+------------------------------------------------------------------+
    bool ScanForScoutEntries(SScoutEntryInfo &foundScout)
    {
        if(!m_initialized) return false;

        // Reset the output struct
        foundScout.Reset();

        // 1. Scan for "Scout Before Classic" (High-risk, counter-trend)
        if(m_config.enableScoutBeforeClassic)
        {
            if(ScanForScoutBeforeClassic(foundScout))
            {
                return ValidateScoutEntry(foundScout.direction, foundScout);
            }
        }

        // 2. Scan for "Scout During Classic" (Lower-risk, trend-following addition)
        if(m_config.enableScoutDuringClassic)
        {
            if(ScanForScoutDuringClassic(foundScout))
            {
                return ValidateScoutEntry(foundScout.direction, foundScout);
            }
        }

        return false;
    }

private:
    //+------------------------------------------------------------------+
    //| Scan for "Scout Before Classic" opportunities                   |
    //+------------------------------------------------------------------+
    bool ScanForScoutBeforeClassic(SScoutEntryInfo &scout)
    {
        // This is a high-risk, counter-trend entry based on volume at S/R.
        // Requires strong PVSRA confirmation.
        SVPSRAInfo pvsraInfo;
        if(!m_pPVSRA->AnalyzeRhythm(0, pvsraInfo)) return false;

        // Look for signs of a trend ending with high volume (Climax)
        if(pvsraInfo.volumeType == VOLUME_TYPE_CLIMAX_UP)
        {
            // Potential short setup (reversal)
            scout.direction = DIRECTION_SELL;
            scout.patternDescription = "Scout Before Classic: Up Climax Volume at Resistance";
            return true;
        }
        
        if(pvsraInfo.volumeType == VOLUME_TYPE_CLIMAX_DOWN)
        {
            // Potential long setup (reversal)
            scout.direction = DIRECTION_BUY;
            scout.patternDescription = "Scout Before Classic: Down Climax Volume at Support";
            return true;
        }

        return false;
    }

    //+------------------------------------------------------------------+
    //| Scan for "Scout During Classic" opportunities                   |
    //+------------------------------------------------------------------+
    bool ScanForScoutDuringClassic(SScoutEntryInfo &scout)
    {
        // This is an addition to an existing, profitable Classic trade.
        // It looks for pullbacks to the Dragon band.
        SDragonBandInfo bandInfo;
        if(!m_pDragonBand->Analyze(0, bandInfo)) return false;

        // Check for pullbacks during a confirmed trend
        if(bandInfo.trendState == DRAGON_TREND_UP && bandInfo.priceLocation == PRICE_LOCATION_IN_BAND)
        {
            // Potential long entry on pullback
            scout.direction = DIRECTION_BUY;
            scout.patternDescription = "Scout During Classic: Pullback to Dragon Band in Uptrend";
            return true;
        }
        
        if(bandInfo.trendState == DRAGON_TREND_DOWN && bandInfo.priceLocation == PRICE_LOCATION_IN_BAND)
        {
            // Potential short entry on pullback
            scout.direction = DIRECTION_SELL;
            scout.patternDescription = "Scout During Classic: Pullback to Dragon Band in Downtrend";
            return true;
        }

        return false;
    }

    //+------------------------------------------------------------------+
    //| Validate a potential scout entry                                 |
    //+------------------------------------------------------------------+
    bool ValidateScoutEntry(ENUM_SIGNAL_DIRECTION direction, SScoutEntryInfo &scout)
    {
        // The scout struct is already partially populated by the Scan methods.
        // This function adds final validation checks.
        bool isDragonValid = true;
        bool isPvsraValid = true;
        bool isWaveValid = true;

        // --- Get latest analysis data ---
        SDragonBandInfo bandInfo;
        if(!m_pDragonBand->Analyze(0, bandInfo)) return false;
        
        SVPSRAInfo pvsraInfo;
        if(!m_pPVSRA->AnalyzeRhythm(0, pvsraInfo)) return false;

        // --- Apply Validation Rules ---
        if(m_config.useDragonBandFilter)
        {
            // For 'During Classic', trend must align. For 'Before Classic', this is a counter-trend check.
            if(scout.patternDescription.Find("During Classic") != -1) {
                if(direction == DIRECTION_BUY && bandInfo.trendState != DRAGON_TREND_UP) isDragonValid = false;
                if(direction == DIRECTION_SELL && bandInfo.trendState != DRAGON_TREND_DOWN) isDragonValid = false;
            }
        }
        scout.dragonBandConfirmed = isDragonValid;

        if(m_config.usePVSRAConfirmation)
        {
            // 'Before Classic' relies heavily on PVSRA climax signals.
            if(scout.patternDescription.Find("Before Classic") != -1) {
                 if(direction == DIRECTION_BUY && pvsraInfo.volumeType != VOLUME_TYPE_CLIMAX_DOWN) isPvsraValid = false;
                 if(direction == DIRECTION_SELL && pvsraInfo.volumeType != VOLUME_TYPE_CLIMAX_UP) isPvsraValid = false;
            }
            // 'During Classic' looks for convergence.
            else {
                if(direction == DIRECTION_BUY && pvsraInfo.rhythmState != RHYTHM_CONVERGENCE_BULLISH) isPvsraValid = false;
                if(direction == DIRECTION_SELL && pvsraInfo.rhythmState != RHYTHM_CONVERGENCE_BEARISH) isPvsraValid = false;
            }
        }
        scout.pvsraConfirmed = isPvsraValid;

        // Wave confirmation is complex and will be a future enhancement.
        // For now, we assume it's valid if other conditions are met.
        scout.wavePatternConfirmed = isWaveValid; 
        scout.volumeConfirmed = isPvsraValid; // Volume confirmation is part of PVSRA

        bool finalValidation = isDragonValid && isPvsraValid && isWaveValid;

        if(finalValidation)
        {
             // Populate the rest of the scout info
            scout.state = SCOUT_STATE_CONFIRMED;
            scout.entryQuality = CalculateEntryQuality(scout); // Calculate quality based on confirmations
        }

        return finalValidation;
    }

    //+------------------------------------------------------------------+
    //| Calculate the quality of the scout entry                         |
    //+------------------------------------------------------------------+
    double CalculateEntryQuality(const SScoutEntryInfo &scout)
    {
        double quality = 0.0;
        if(scout.dragonBandConfirmed) quality += 33.3;
        if(scout.pvsraConfirmed) quality += 33.4;
        if(scout.wavePatternConfirmed) quality += 33.3;
        
        // Add bonus for specific strong patterns
        if(scout.patternDescription.Find("Climax") != -1) {
            quality += 10.0; // Climax patterns are strong indicators
        }

        return MathMin(quality, 100.0); // Cap at 100
    }
};

#endif // APEX_SIGNAL_SONICR_SCOUTENTRY_MQH_
