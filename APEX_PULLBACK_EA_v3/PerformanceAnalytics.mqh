#ifndef PERFORMANCEANALYTICS_MQH_
#define PERFORMANCEANALYTICS_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CPerformanceAnalytics {
public:
    CPerformanceAnalytics() {}
    ~CPerformanceAnalytics() {}

    bool Initialize(EAContext* context) { return true; }
    void Analyze() {}
};

} // namespace ApexPullback

#endif // PERFORMANCEANALYTICS_MQH_