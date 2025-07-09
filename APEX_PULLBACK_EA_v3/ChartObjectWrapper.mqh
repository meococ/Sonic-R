//+------------------------------------------------------------------+
//|                                           ChartObjectWrapper.mqh |
//|                        Copyright 2023, PhucThinh. All rights reserved. |
//|                                      https://www.mql5.com/en/users/phucthinh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, PhucThinh. All rights reserved."
#property link      "https://www.mql5.com/en/users/phucthinh"
#property version   "1.00"

#ifndef CHARTOBJECTWRAPPER_MQH_
#define CHARTOBJECTWRAPPER_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback
{
//+------------------------------------------------------------------+
//| Class CChartObjectWrapper                                        |
//| Description: A base wrapper for chart objects to simplify creation |
//| and modification.                                                |
//+------------------------------------------------------------------+
class CChartObjectWrapper : public CObject
  {
protected:
   EAContext         *m_context;
   CLogger           *m_logger;
   long              m_chart_id;
   int               m_sub_window;
   string            m_name;
   ENUM_OBJECT       m_type;

public:
                     CChartObjectWrapper(void);
                    ~CChartObjectWrapper(void);

   virtual bool      Create(long chart_id, const string name, int sub_window, datetime time1, double price1);
   virtual void      Delete(void);

   //--- Property setters
   void              SetString(ENUM_OBJECT_PROPERTY_STRING prop, const string value);
   void              SetInteger(ENUM_OBJECT_PROPERTY_INTEGER prop, long value);
   void              SetDouble(ENUM_OBJECT_PROPERTY_DOUBLE prop, double value);
   void              SetColor(color new_color) { SetInteger(OBJPROP_COLOR, new_color); }
   void              SetStyle(int style)       { SetInteger(OBJPROP_STYLE, style); }
   void              SetWidth(int width)       { SetInteger(OBJPROP_WIDTH, width); }

   string            Name(void) const { return m_name; }
  };

//+------------------------------------------------------------------+
//| Class CChartLabel - Wrapper for OBJ_LABEL                        |
//+------------------------------------------------------------------+
class CChartLabel : public CChartObjectWrapper
  {
public:
                     CChartLabel(void);
                    ~CChartLabel(void);

   bool              Create(long chart_id, const string name, int sub_window, int x, int y, const string text);
   void              SetText(const string text);
   void              SetPosition(int x, int y);
   void              SetFont(const string font_name, int font_size);
  };

//+------------------------------------------------------------------+
//| CChartObjectWrapper Implementation                               |
//+------------------------------------------------------------------+
CChartObjectWrapper::CChartObjectWrapper(void) : m_context(NULL),
                                                 m_logger(NULL),
                                                 m_chart_id(0),
                                                 m_sub_window(0),
                                                 m_name(""),
                                                 m_type(OBJ_EMPTY)
  {
  }

CChartObjectWrapper::~CChartObjectWrapper(void)
  {
   // Object deletion should be handled explicitly by calling Delete()
  }

bool CChartObjectWrapper::Create(long chart_id, const string name, int sub_window, datetime time1, double price1)
  {
   m_chart_id = chart_id;
   m_name = name;
   m_sub_window = sub_window;

   // Overridden by derived classes
   return false;
  }

void CChartObjectWrapper::Delete(void)
  {
   if(m_name != "")
     {
      ObjectDelete(m_chart_id, m_name);
     }
  }

void CChartObjectWrapper::SetString(ENUM_OBJECT_PROPERTY_STRING prop, const string value)
  {
   ObjectSetString(m_chart_id, m_name, prop, value);
  }

void CChartObjectWrapper::SetInteger(ENUM_OBJECT_PROPERTY_INTEGER prop, long value)
  {
   ObjectSetInteger(m_chart_id, m_name, prop, value);
  }

void CChartObjectWrapper::SetDouble(ENUM_OBJECT_PROPERTY_DOUBLE prop, double value)
  {
   ObjectSetDouble(m_chart_id, m_name, prop, value);
  }

//+------------------------------------------------------------------+
//| CChartLabel Implementation                                         |
//+------------------------------------------------------------------+
CChartLabel::CChartLabel(void)
  {
   m_type = OBJ_LABEL;
  }

CChartLabel::~CChartLabel(void) {}

bool CChartLabel::Create(long chart_id, const string name, int sub_window, int x, int y, const string text)
  {
   m_chart_id = chart_id;
   m_name = name;
   m_sub_window = sub_window;

   if(ObjectCreate(m_chart_id, m_name, m_type, m_sub_window, 0, 0))
     {
      SetPosition(x, y);
      SetText(text);
      return true;
     }
   return false;
  }

void CChartLabel::SetText(const string text)
  {
   SetString(OBJPROP_TEXT, text);
  }

void CChartLabel::SetPosition(int x, int y)
  {
   SetInteger(OBJPROP_XDISTANCE, x);
   SetInteger(OBJPROP_YDISTANCE, y);
  }

void CChartLabel::SetFont(const string font_name, int font_size)
  {
   SetString(OBJPROP_FONT, font_name);
   SetInteger(OBJPROP_FONTSIZE, font_size);
  }

} // namespace ApexPullback
#endif // CHARTOBJECTWRAPPER_MQH_
