//+------------------------------------------------------------------+
//|                                               FunctionStack.mqh |
//|      APEX Pullback EA v14.0 - Hệ thống theo dõi ngăn xếp hàm      |
//+------------------------------------------------------------------+

#ifndef FUNCTION_STACK_MQH_
#define FUNCTION_STACK_MQH_

#include <Arrays\ArrayString.mqh>
#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

// Các hằng số cho FunctionStack
#define MAX_STACK_DEPTH      50    // Giới hạn độ sâu tối đa của stack
#define STACK_WARNING_LEVEL  45    // Mức cảnh báo khi stack gần đạt giới hạn

//+------------------------------------------------------------------+
//| Lớp CFunctionStack - Mô phỏng Stack Trace để gỡ lỗi             |
//+------------------------------------------------------------------+
class CFunctionStack {
private:
   EAContext*     m_context;   // Pointer to the central context
   CArrayString*  m_stack;
   int            m_max_size;
   bool           m_is_initialized;

public:
   // Constructor and Destructor
   CFunctionStack(); 
   ~CFunctionStack();

   // Initialization
   bool Initialize(EAContext* pContext, int max_size = MAX_STACK_DEPTH);

   // Phương thức chính
   void  Push(const string function_name);
   void  Pop();
   void  Clear();
   string GetTraceAsString(const string separator = " -> ") const;
   int   GetSize() const;
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CFunctionStack::CFunctionStack() {
   m_context = NULL;
   m_stack = NULL;
   m_max_size = MAX_STACK_DEPTH;
   m_is_initialized = false;
}

bool CFunctionStack::Initialize(EAContext* pContext, int max_size = MAX_STACK_DEPTH) {
    if (!pContext) {
        Print("CRITICAL: Invalid context passed to FunctionStack::Initialize");
        return false;
    }
    
    m_context = pContext;
    m_max_size = max_size;
    
    m_stack = new CArrayString();
    if (CheckPointer(m_stack) == POINTER_INVALID) {
        // Logger might not be fully available yet, but we can try.
        if(m_context->pLogger != NULL) m_context->pLogger->LogError("Failed to allocate memory for Function Stack.");
        else Print("CRITICAL: Failed to allocate memory for Function Stack.");
        return false;
    }
    m_is_initialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CFunctionStack::~CFunctionStack() {
   if(CheckPointer(m_stack) == POINTER_DYNAMIC) {
      delete m_stack;
   }
}

//+------------------------------------------------------------------+
//| Thêm một hàm vào đỉnh của ngăn xếp
//+------------------------------------------------------------------+
void CFunctionStack::Push(const string function_name) {
   if(!m_is_initialized || CheckPointer(m_stack) == POINTER_INVALID)
      return;

   int current_size = m_stack->Total();

   // Kiểm tra và cảnh báo khi gần đạt giới hạn
   if(current_size >= STACK_WARNING_LEVEL && current_size < m_max_size) {
      if(m_context && m_context->pLogger != NULL) {
         m_context->pLogger->LogWarning(StringFormat("Stack depth warning: %d/%d functions",
                                   current_size, m_max_size));
      }
   }

   // Kiểm tra giới hạn stack
   if(current_size >= m_max_size) {
      if(m_context && m_context->pLogger != NULL) {
         m_context->pLogger->LogError(StringFormat("Stack overflow prevented! Depth: %d/%d. Trace: %s",
                                 current_size, m_max_size, GetTraceAsString()));
      }


      return; // Ngăn chặn tràn stack
   }

   m_stack->Add(function_name);
}

//+------------------------------------------------------------------+
//| Xóa một hàm khỏi đỉnh của ngăn xếp
//+------------------------------------------------------------------+
void CFunctionStack::Pop() {
   if(CheckPointer(m_stack) == POINTER_INVALID || m_stack->Total() == 0)
      return;
   m_stack->Delete(m_stack->Total() - 1);
}

//+------------------------------------------------------------------+
//| Xóa toàn bộ ngăn xếp
//+------------------------------------------------------------------+
void CFunctionStack::Clear() {
   if(CheckPointer(m_stack) == POINTER_INVALID)
      return;
   m_stack->Clear();
}

//+------------------------------------------------------------------+
//| Lấy toàn bộ dấu vết ngăn xếp dưới dạng một chuỗi
//+------------------------------------------------------------------+
string CFunctionStack::GetTraceAsString(const string separator = " -> ") const {
   if(CheckPointer(m_stack) == POINTER_INVALID || m_stack->Total() == 0)
      return "";

   string trace = "";
   for(int i = 0; i < m_stack->Total(); i++) {
      if(i > 0)
         trace += separator;
      trace += m_stack->At(i);
   }
   return trace;
}

//+------------------------------------------------------------------+
//| Lấy kích thước hiện tại của ngăn xếp
//+------------------------------------------------------------------+
int CFunctionStack::GetSize() const {
    if(CheckPointer(m_stack) == POINTER_INVALID) return 0;
    return m_stack->Total();
}

} // end namespace ApexPullback
#endif // FUNCTION_STACK_MQH_