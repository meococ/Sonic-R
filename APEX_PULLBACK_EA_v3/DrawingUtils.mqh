#ifndef DRAWINGUTILS_MQH_
#define DRAWINGUTILS_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CDrawingUtils {
public:
    CDrawingUtils() {}
    ~CDrawingUtils() {}

    void Initialize(EAContext* context) {}
    void DrawText(const string name, const string text, int x, int y) {}
    void DrawLabel(const string name, const string text, int x, int y) {}
};

} // namespace ApexPullback

#endif // DRAWINGUTILS_MQH_