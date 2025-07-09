//+------------------------------------------------------------------+
//|                                           MonteCarloSimulator.mqh |
//|                                    APEX Pullback EA v14.0        |
//|                                    Phân tích Monte Carlo         |
//+------------------------------------------------------------------+
#property copyright "APEX Pullback EA v14.0"
#property version   "1.00"
#property strict

#include "CommonStructs.mqh"      // Core structures, enums, and inputs

namespace ApexPullback
{

//+------------------------------------------------------------------+
//| Enum cho các loại stress test                                   |
//+------------------------------------------------------------------+
enum ENUM_STRESS_SCENARIO
  {
   STRESS_NORMAL = 0,           // Kịch bản bình thường
   STRESS_HIGH_SLIPPAGE = 1,    // Trượt giá cao
   STRESS_HIGH_LATENCY = 2,     // Độ trễ cao
   STRESS_MARKET_CRASH = 3,     // Sụp đổ thị trường
   STRESS_LOW_LIQUIDITY = 4,    // Thanh khoản thấp
   STRESS_BROKER_ISSUES = 5,    // Vấn đề broker
   STRESS_EXTREME_VOLATILITY = 6 // Biến động cực đoan
  };

//+------------------------------------------------------------------+
//| Cấu trúc dữ liệu cho Monte Carlo Simulation                     |
//+------------------------------------------------------------------+
struct MonteCarloResult
  {
   double            ExpectedReturn;        // Lợi nhuận kỳ vọng
   double            StandardDeviation;     // Độ lệch chuẩn
   double            MaxDrawdown;           // Drawdown tối đa
   double            SharpeRatio;           // Tỷ lệ Sharpe
   double            VaR95;                 // Value at Risk 95%
   double            VaR99;                 // Value at Risk 99%
   double            CVaR95;                // Conditional VaR 95%
   double            CVaR99;                // Conditional VaR 99%
   double            ProbabilityOfProfit;   // Xác suất có lãi
   double            WorstCaseScenario;     // Kịch bản xấu nhất
   double            BestCaseScenario;      // Kịch bản tốt nhất
   double            MedianReturn;          // Lợi nhuận trung vị
   double            Skewness;              // Độ lệch (skewness)
   double            Kurtosis;              // Độ nhọn (kurtosis)
   double            MaxConsecutiveLoss;    // Thua lỗ liên tiếp tối đa
   double            RecoveryTime;          // Thời gian phục hồi ước tính
   int               TotalSimulations;      // Tổng số mô phỏng
   double            ConfidenceLevel;       // Mức độ tin cậy
   ENUM_STRESS_SCENARIO StressScenario;    // Loại stress test
   string            RiskAssessment;        // Đánh giá rủi ro
   string            ActionableInsights;    // Khuyến nghị hành động
  };

struct TradeScenario
  {
   double            WinRate;               // Tỷ lệ thắng
   double            AvgWin;                // Lãi trung bình
   double            AvgLoss;               // Lỗ trung bình
   double            MaxConsecutiveLosses;  // Số lệnh thua liên tiếp tối đa
   double            MaxConsecutiveWins;    // Số lệnh thắng liên tiếp tối đa
   int               TotalTrades;           // Tổng số lệnh
  };

//+------------------------------------------------------------------+
//| Lớp Monte Carlo Simulator                                        |
//+------------------------------------------------------------------+
class CMonteCarloSimulator
  {
private:
   EAContext*        m_Context;             // Con trỏ đến context
   int               m_SimulationCount;     // Số lượng mô phỏng
   double            m_InitialBalance;      // Số dư ban đầu
   TradeScenario     m_BaseScenario;        // Kịch bản cơ sở
   double            m_Results[];           // Mảng kết quả mô phỏng
   
   // Phương thức private
   double            GenerateRandomReturn();
   double            SimulateTradingSequence(const TradeScenario& scenario);
   void              CalculateStatistics(MonteCarloResult& result);
   double            CalculateVaR(double confidence_level);
   double            NormalDistribution(double mean, double std_dev);
   
public:
   // Constructor và Destructor
                     CMonteCarloSimulator();
                    ~CMonteCarloSimulator();
   
   // Phương thức khởi tạo
   bool              Initialize(EAContext* context);
   void              Cleanup();
   
   // Phương thức cấu hình
   void              SetSimulationCount(int count) { m_SimulationCount = count; }
   void              SetInitialBalance(double balance) { m_InitialBalance = balance; }
   void              SetBaseScenario(const TradeScenario& scenario);
   
   // Phương thức mô phỏng chính
   bool              RunSimulation(MonteCarloResult& result);
   bool              RunStressTest(MonteCarloResult& result, ENUM_STRESS_SCENARIO scenario = STRESS_BROKER_ISSUES);
   bool              RunOptimisticScenario(MonteCarloResult& result);
   bool              RunPessimisticScenario(MonteCarloResult& result);
   bool              RunBrokerHealthStressTest(MonteCarloResult& result, double health_score);
   
   // Phương thức phân tích nâng cao
   bool              AnalyzeRiskMetrics(MonteCarloResult& result);
   bool              ValidateStrategyRobustness(double min_sharpe = 1.0, double max_drawdown = 0.20);
   bool              CalculateAdvancedMetrics(MonteCarloResult& result);
   double            CalculateConditionalVaR(double confidence_level);
   double            CalculateSkewness();
   double            CalculateKurtosis();
   double            EstimateRecoveryTime(double max_drawdown);
   string            GenerateRiskAssessment(const MonteCarloResult& result);
   string            GenerateActionableInsights(const MonteCarloResult& result);
   
   // Phương thức báo cáo
   string            GenerateReport(const MonteCarloResult& result);
   bool              SaveResultsToFile(const MonteCarloResult& result, string filename = "");
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMonteCarloSimulator::CMonteCarloSimulator()
  {
   m_Context = NULL;
   m_SimulationCount = 10000;  // Mặc định 10,000 mô phỏng
   m_InitialBalance = 10000.0; // Mặc định $10,000
   
   // Khởi tạo kịch bản cơ sở với giá trị mặc định
   m_BaseScenario.WinRate = 0.55;
   m_BaseScenario.AvgWin = 100.0;
   m_BaseScenario.AvgLoss = -80.0;
   m_BaseScenario.MaxConsecutiveLosses = 8;
   m_BaseScenario.MaxConsecutiveWins = 12;
   m_BaseScenario.TotalTrades = 1000;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMonteCarloSimulator::~CMonteCarloSimulator()
  {
   Cleanup();
  }

//+------------------------------------------------------------------+
//| Khởi tạo Monte Carlo Simulator                                  |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::Initialize(EAContext* context)
  {
   if(context == NULL)
     {
      Print("MonteCarloSimulator: Context is NULL");
      return false;
     }
   
   m_Context = context;
   
   // Cấu hình dựa trên context
   m_InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(m_InitialBalance <= 0)
      m_InitialBalance = 10000.0; // Fallback
   
   // Resize mảng kết quả
   ArrayResize(m_Results, m_SimulationCount);
   ArrayInitialize(m_Results, 0.0);
   
   if(m_Context->Logger != NULL)
     {
      m_Context->Logger->LogInfo("Monte Carlo Simulator đã được khởi tạo với " + 
                                IntegerToString(m_SimulationCount) + " mô phỏng.");
     }
   
   return true;
  }

//+------------------------------------------------------------------+
//| Dọn dẹp tài nguyên                                              |
//+------------------------------------------------------------------+
void CMonteCarloSimulator::Cleanup()
  {
   ArrayFree(m_Results);
   m_Context = NULL;
  }

//+------------------------------------------------------------------+
//| Thiết lập kịch bản cơ sở                                        |
//+------------------------------------------------------------------+
void CMonteCarloSimulator::SetBaseScenario(const TradeScenario& scenario)
  {
   m_BaseScenario = scenario;
   
   if(m_Context != NULL && m_Context->Logger != NULL)
     {
      m_Context->Logger->LogDebug("Kịch bản cơ sở đã được cập nhật: WinRate=" + 
                                 DoubleToString(scenario.WinRate, 3) + 
                                 ", AvgWin=" + DoubleToString(scenario.AvgWin, 2) +
                                 ", AvgLoss=" + DoubleToString(scenario.AvgLoss, 2));
     }
  }

//+------------------------------------------------------------------+
//| Tạo số ngẫu nhiên theo phân phối chuẩn                          |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::NormalDistribution(double mean, double std_dev)
  {
   static bool has_spare = false;
   static double spare;
   
   if(has_spare)
     {
      has_spare = false;
      return spare * std_dev + mean;
     }
   
   has_spare = true;
   
   double u = (double)MathRand() / 32767.0;
   double v = (double)MathRand() / 32767.0;
   
   double mag = std_dev * MathSqrt(-2.0 * MathLog(u));
   spare = mag * MathCos(2.0 * M_PI * v);
   
   return mag * MathSin(2.0 * M_PI * v) + mean;
  }

//+------------------------------------------------------------------+
//| Tạo lợi nhuận ngẫu nhiên                                        |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::GenerateRandomReturn()
  {
   double random_val = (double)MathRand() / 32767.0;
   
   if(random_val <= m_BaseScenario.WinRate)
     {
      // Lệnh thắng - sử dụng phân phối chuẩn quanh AvgWin
      return NormalDistribution(m_BaseScenario.AvgWin, m_BaseScenario.AvgWin * 0.3);
     }
   else
     {
      // Lệnh thua - sử dụng phân phối chuẩn quanh AvgLoss
      return NormalDistribution(m_BaseScenario.AvgLoss, MathAbs(m_BaseScenario.AvgLoss) * 0.3);
     }
  }

//+------------------------------------------------------------------+
//| Mô phỏng chuỗi giao dịch                                        |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::SimulateTradingSequence(const TradeScenario& scenario)
  {
   double balance = m_InitialBalance;
   double peak_balance = balance;
   double max_drawdown = 0.0;
   
   int consecutive_wins = 0;
   int consecutive_losses = 0;
   
   for(int i = 0; i < scenario.TotalTrades; i++)
     {
      double trade_result = GenerateRandomReturn();
      
      // Áp dụng giới hạn chuỗi thắng/thua liên tiếp
      if(trade_result > 0)
        {
         consecutive_wins++;
         consecutive_losses = 0;
         
         // Giới hạn chuỗi thắng
         if(consecutive_wins > scenario.MaxConsecutiveWins)
           {
            trade_result = NormalDistribution(scenario.AvgLoss, MathAbs(scenario.AvgLoss) * 0.2);
            consecutive_wins = 0;
            consecutive_losses = 1;
           }
        }
      else
        {
         consecutive_losses++;
         consecutive_wins = 0;
         
         // Giới hạn chuỗi thua
         if(consecutive_losses > scenario.MaxConsecutiveLosses)
           {
            trade_result = NormalDistribution(scenario.AvgWin, scenario.AvgWin * 0.2);
            consecutive_losses = 0;
            consecutive_wins = 1;
           }
        }
      
      balance += trade_result;
      
      // Cập nhật peak và drawdown
      if(balance > peak_balance)
        {
         peak_balance = balance;
        }
      else
        {
         double current_drawdown = (peak_balance - balance) / peak_balance;
         if(current_drawdown > max_drawdown)
            max_drawdown = current_drawdown;
        }
      
      // Kiểm tra margin call (mất 80% tài khoản)
      if(balance <= m_InitialBalance * 0.2)
        {
         return balance - m_InitialBalance; // Trả về loss
        }
     }
   
   return balance - m_InitialBalance; // Trả về P&L
  }

//+------------------------------------------------------------------+
//| Chạy mô phỏng Monte Carlo chính                                 |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::RunSimulation(MonteCarloResult& result)
  {
   if(m_Context == NULL)
     {
      Print("MonteCarloSimulator: Context is NULL");
      return false;
     }
   
   if(m_Context->Logger != NULL)
     {
      m_Context->Logger->LogInfo("Bắt đầu mô phỏng Monte Carlo với " + 
                                IntegerToString(m_SimulationCount) + " kịch bản...");
     }
   
   // Chạy mô phỏng
   for(int i = 0; i < m_SimulationCount; i++)
     {
      m_Results[i] = SimulateTradingSequence(m_BaseScenario);
      
      // Log tiến độ mỗi 1000 mô phỏng
      if(m_Context->Logger != NULL && (i + 1) % 1000 == 0)
        {
         m_Context->Logger->LogDebug("Hoàn thành " + IntegerToString(i + 1) + "/" + 
                                    IntegerToString(m_SimulationCount) + " mô phỏng.");
        }
     }
   
   // Tính toán thống kê
   CalculateStatistics(result);
   
   if(m_Context->Logger != NULL)
     {
      m_Context->Logger->LogInfo("Hoàn thành mô phỏng Monte Carlo. Expected Return: " + 
                                DoubleToString(result.ExpectedReturn, 2) + 
                                ", Sharpe Ratio: " + DoubleToString(result.SharpeRatio, 3));
     }
   
   return true;
  }

//+------------------------------------------------------------------+
//| Tính toán thống kê từ kết quả mô phỏng                          |
//+------------------------------------------------------------------+
void CMonteCarloSimulator::CalculateStatistics(MonteCarloResult& result)
  {
   // Sắp xếp kết quả để tính VaR
   ArraySort(m_Results);
   
   // Tính toán các thống kê cơ bản
   double sum = 0.0;
   double sum_squares = 0.0;
   int profitable_count = 0;
   
   for(int i = 0; i < m_SimulationCount; i++)
     {
      sum += m_Results[i];
      sum_squares += m_Results[i] * m_Results[i];
      
      if(m_Results[i] > 0)
         profitable_count++;
     }
   
   result.ExpectedReturn = sum / m_SimulationCount;
   result.StandardDeviation = MathSqrt((sum_squares / m_SimulationCount) - (result.ExpectedReturn * result.ExpectedReturn));
   result.ProbabilityOfProfit = (double)profitable_count / m_SimulationCount;
   
   // VaR calculations
   result.VaR95 = CalculateVaR(0.95);
   result.VaR99 = CalculateVaR(0.99);
   
   // Conditional VaR (Expected Shortfall)
   result.CVaR95 = CalculateConditionalVaR(0.95);
   result.CVaR99 = CalculateConditionalVaR(0.99);
   
   // Median return
   int median_index = m_SimulationCount / 2;
   result.MedianReturn = m_Results[median_index];
   
   // Sharpe Ratio (giả sử risk-free rate = 0)
   if(result.StandardDeviation > 0)
      result.SharpeRatio = result.ExpectedReturn / result.StandardDeviation;
   else
      result.SharpeRatio = 0.0;
   
   // Worst và Best case
   result.WorstCaseScenario = m_Results[0];
   result.BestCaseScenario = m_Results[m_SimulationCount - 1];
   
   // Max Drawdown (ước tính từ worst case)
   result.MaxDrawdown = MathAbs(result.WorstCaseScenario) / m_InitialBalance;
   
   // Advanced metrics
   result.Skewness = CalculateSkewness();
   result.Kurtosis = CalculateKurtosis();
   result.RecoveryTime = EstimateRecoveryTime(result.MaxDrawdown);
   
   // Calculate max consecutive loss
   result.MaxConsecutiveLoss = 0.0;
   double current_loss = 0.0;
   for(int i = 0; i < m_SimulationCount; i++)
     {
      if(m_Results[i] < 0)
        {
         current_loss += MathAbs(m_Results[i]);
         if(current_loss > result.MaxConsecutiveLoss)
            result.MaxConsecutiveLoss = current_loss;
        }
      else
        {
         current_loss = 0.0;
        }
     }
   
   result.TotalSimulations = m_SimulationCount;
   result.ConfidenceLevel = 0.95;
   result.StressScenario = STRESS_NORMAL;
   
   // Generate assessments
   result.RiskAssessment = GenerateRiskAssessment(result);
   result.ActionableInsights = GenerateActionableInsights(result);
  }

//+------------------------------------------------------------------+
//| Tính toán Value at Risk                                         |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::CalculateVaR(double confidence_level)
  {
   int index = (int)((1.0 - confidence_level) * m_SimulationCount);
   if(index >= m_SimulationCount) index = m_SimulationCount - 1;
   if(index < 0) index = 0;
   
   return m_Results[index];
  }

//+------------------------------------------------------------------+
//| Kiểm tra độ bền vững của chiến lược                             |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::ValidateStrategyRobustness(double min_sharpe, double max_drawdown)
  {
   MonteCarloResult result;
   if(!RunSimulation(result))
      return false;
   
   bool is_robust = true;
   string validation_msg = "Kiểm tra độ bền vững chiến lược:\n";
   
   // Kiểm tra Sharpe Ratio
   if(result.SharpeRatio < min_sharpe)
     {
      is_robust = false;
      validation_msg += "- THẤT BẠI: Sharpe Ratio (" + DoubleToString(result.SharpeRatio, 3) + 
                       ") < Yêu cầu (" + DoubleToString(min_sharpe, 3) + ")\n";
     }
   else
     {
      validation_msg += "- THÀNH CÔNG: Sharpe Ratio (" + DoubleToString(result.SharpeRatio, 3) + ")\n";
     }
   
   // Kiểm tra Max Drawdown
   if(result.MaxDrawdown > max_drawdown)
     {
      is_robust = false;
      validation_msg += "- THẤT BẠI: Max Drawdown (" + DoubleToString(result.MaxDrawdown * 100, 2) + 
                       "%) > Yêu cầu (" + DoubleToString(max_drawdown * 100, 2) + "%)\n";
     }
   else
     {
      validation_msg += "- THÀNH CÔNG: Max Drawdown (" + DoubleToString(result.MaxDrawdown * 100, 2) + "%)\n";
     }
   
   // Kiểm tra xác suất có lãi
   if(result.ProbabilityOfProfit < 0.5)
     {
      is_robust = false;
      validation_msg += "- CẢNH BÁO: Xác suất có lãi thấp (" + DoubleToString(result.ProbabilityOfProfit * 100, 1) + "%)\n";
     }
   
   if(m_Context != NULL && m_Context->Logger != NULL)
     {
      if(is_robust)
         m_Context->Logger->LogInfo("Chiến lược ĐẠT yêu cầu độ bền vững.\n" + validation_msg);
      else
         m_Context->Logger->LogWarning("Chiến lược KHÔNG ĐẠT yêu cầu độ bền vững.\n" + validation_msg);
     }
   
   return is_robust;
  }

//+------------------------------------------------------------------+
//| Tạo báo cáo Monte Carlo                                         |
//+------------------------------------------------------------------+
string CMonteCarloSimulator::GenerateReport(const MonteCarloResult& result)
  {
   string report = "\n=== BÁO CÁO MONTE CARLO SIMULATION ===\n";
   report += "Tổng số mô phỏng: " + IntegerToString(result.TotalSimulations) + "\n";
   report += "Mức độ tin cậy: " + DoubleToString(result.ConfidenceLevel * 100, 1) + "%\n\n";
   
   report += "KẾT QUẢ THỐNG KÊ:\n";
   report += "- Lợi nhuận kỳ vọng: $" + DoubleToString(result.ExpectedReturn, 2) + "\n";
   report += "- Độ lệch chuẩn: $" + DoubleToString(result.StandardDeviation, 2) + "\n";
   report += "- Tỷ lệ Sharpe: " + DoubleToString(result.SharpeRatio, 3) + "\n";
   report += "- Xác suất có lãi: " + DoubleToString(result.ProbabilityOfProfit * 100, 1) + "%\n\n";
   
   report += "PHÂN TÍCH RỦI RO:\n";
   report += "- Max Drawdown: " + DoubleToString(result.MaxDrawdown * 100, 2) + "%\n";
   report += "- VaR 95%: $" + DoubleToString(result.VaR95, 2) + "\n";
   report += "- VaR 99%: $" + DoubleToString(result.VaR99, 2) + "\n\n";
   
   report += "KỊCH BẢN GIỚI HẠN:\n";
   report += "- Kịch bản tốt nhất: $" + DoubleToString(result.BestCaseScenario, 2) + "\n";
   report += "- Kịch bản xấu nhất: $" + DoubleToString(result.WorstCaseScenario, 2) + "\n";
   
   // Đánh giá tổng thể
   report += "\nĐÁNH GIÁ TỔNG THỂ:\n";
   if(result.SharpeRatio > 1.0 && result.MaxDrawdown < 0.2 && result.ProbabilityOfProfit > 0.55)
     {
      report += "✅ Chiến lược có tiềm năng tốt\n";
     }
   else if(result.SharpeRatio > 0.5 && result.MaxDrawdown < 0.3)
     {
      report += "⚠️ Chiến lược cần cải thiện\n";
     }
   else
     {
      report += "❌ Chiến lược có rủi ro cao\n";
     }
   
   return report;
  }

//+------------------------------------------------------------------+
//| Lưu kết quả vào file                                            |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::SaveResultsToFile(const MonteCarloResult& result, string filename)
  {
   if(filename == "")
     {
      filename = "MonteCarlo_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + ".txt";
      StringReplace(filename, ":", "-");
      StringReplace(filename, " ", "_");
     }
   
   string full_path = MONTE_CARLO_REPORTS_PATH + filename;
   
   int file_handle = FileOpen(full_path, FILE_WRITE|FILE_TXT);
   if(file_handle == INVALID_HANDLE)
     {
      if(m_Context != NULL && m_Context->Logger != NULL)
         m_Context->Logger->LogError("Không thể tạo file báo cáo Monte Carlo: " + full_path);
      return false;
     }
   
   string report = GenerateReport(result);
   FileWriteString(file_handle, report);
   
   // Ghi thêm dữ liệu raw cho phân tích
   FileWriteString(file_handle, "\n\n=== DỮ LIỆU RAW ===\n");
   for(int i = 0; i < MathMin(100, ArraySize(m_Results)); i++) // Chỉ ghi 100 kết quả đầu
     {
      FileWriteString(file_handle, DoubleToString(m_Results[i], 2) + "\n");
     }
   
   FileClose(file_handle);
   
   if(m_Context != NULL && m_Context->Logger != NULL)
     {
      m_Context->Logger->LogInfo("Báo cáo Monte Carlo đã được lưu: " + full_path);
     }
   
   return true;
  }

//+------------------------------------------------------------------+
//| Chạy stress test với broker health integration                  |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::RunBrokerHealthStressTest(MonteCarloResult& result, double health_score)
  {
   if(m_Context == NULL)
     {
      Print("MonteCarloSimulator: Context is NULL");
      return false;
     }
   
   // Điều chỉnh kịch bản dựa trên health score
   TradeScenario stress_scenario = m_BaseScenario;
   
   // Health score thấp = điều kiện giao dịch xấu hơn
   double health_factor = health_score / 100.0; // 0.0 - 1.0
   
   // Tăng slippage và giảm win rate dựa trên health score
   stress_scenario.AvgLoss *= (2.0 - health_factor);  // Loss lớn hơn khi health thấp
   stress_scenario.WinRate *= health_factor;           // Win rate thấp hơn khi health thấp
   stress_scenario.MaxConsecutiveLosses = (int)(stress_scenario.MaxConsecutiveLosses * (2.0 - health_factor));
   
   if(m_Context->Logger != NULL)
     {
      m_Context->Logger->LogInfo("Chạy Broker Health Stress Test với Health Score: " + 
                                DoubleToString(health_score, 1) + "%");
     }
   
   // Chạy mô phỏng với kịch bản stress
   for(int i = 0; i < m_SimulationCount; i++)
     {
      m_Results[i] = SimulateTradingSequence(stress_scenario);
     }
   
   // Tính toán thống kê
   CalculateStatistics(result);
   result.StressScenario = STRESS_BROKER_ISSUES;
   
   return true;
  }

//+------------------------------------------------------------------+
//| Tính toán Conditional VaR (Expected Shortfall)                  |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::CalculateConditionalVaR(double confidence_level)
  {
   int var_index = (int)((1.0 - confidence_level) * m_SimulationCount);
   if(var_index >= m_SimulationCount) var_index = m_SimulationCount - 1;
   if(var_index < 0) var_index = 0;
   
   // Tính trung bình của các kết quả tệ hơn VaR
   double sum = 0.0;
   int count = 0;
   
   for(int i = 0; i <= var_index; i++)
     {
      sum += m_Results[i];
      count++;
     }
   
   return (count > 0) ? sum / count : 0.0;
  }

//+------------------------------------------------------------------+
//| Tính toán Skewness                                              |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::CalculateSkewness()
  {
   if(m_SimulationCount < 3) return 0.0;
   
   // Tính mean
   double sum = 0.0;
   for(int i = 0; i < m_SimulationCount; i++)
     {
      sum += m_Results[i];
     }
   double mean = sum / m_SimulationCount;
   
   // Tính variance và skewness
   double sum_squared_diff = 0.0;
   double sum_cubed_diff = 0.0;
   
   for(int i = 0; i < m_SimulationCount; i++)
     {
      double diff = m_Results[i] - mean;
      sum_squared_diff += diff * diff;
      sum_cubed_diff += diff * diff * diff;
     }
   
   double variance = sum_squared_diff / (m_SimulationCount - 1);
   double std_dev = MathSqrt(variance);
   
   if(std_dev == 0.0) return 0.0;
   
   double skewness = (sum_cubed_diff / m_SimulationCount) / MathPow(std_dev, 3);
   return skewness;
  }

//+------------------------------------------------------------------+
//| Tính toán Kurtosis                                              |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::CalculateKurtosis()
  {
   if(m_SimulationCount < 4) return 0.0;
   
   // Tính mean
   double sum = 0.0;
   for(int i = 0; i < m_SimulationCount; i++)
     {
      sum += m_Results[i];
     }
   double mean = sum / m_SimulationCount;
   
   // Tính variance và kurtosis
   double sum_squared_diff = 0.0;
   double sum_fourth_diff = 0.0;
   
   for(int i = 0; i < m_SimulationCount; i++)
     {
      double diff = m_Results[i] - mean;
      sum_squared_diff += diff * diff;
      sum_fourth_diff += MathPow(diff, 4);
     }
   
   double variance = sum_squared_diff / (m_SimulationCount - 1);
   
   if(variance == 0.0) return 0.0;
   
   double kurtosis = (sum_fourth_diff / m_SimulationCount) / MathPow(variance, 2) - 3.0;
   return kurtosis;
  }

//+------------------------------------------------------------------+
//| Ước tính thời gian phục hồi                                     |
//+------------------------------------------------------------------+
double CMonteCarloSimulator::EstimateRecoveryTime(double max_drawdown)
  {
   if(max_drawdown <= 0 || m_BaseScenario.AvgWin <= 0) return 0.0;
   
   // Ước tính số lệnh cần thiết để phục hồi
   double loss_amount = max_drawdown * m_InitialBalance;
   double expected_profit_per_trade = (m_BaseScenario.WinRate * m_BaseScenario.AvgWin) + 
                                     ((1.0 - m_BaseScenario.WinRate) * m_BaseScenario.AvgLoss);
   
   if(expected_profit_per_trade <= 0) return -1.0; // Không thể phục hồi
   
   double trades_needed = loss_amount / expected_profit_per_trade;
   
   // Giả sử 1 lệnh/ngày, trả về số ngày
   return trades_needed;
  }

//+------------------------------------------------------------------+
//| Tạo đánh giá rủi ro                                             |
//+------------------------------------------------------------------+
string CMonteCarloSimulator::GenerateRiskAssessment(const MonteCarloResult& result)
  {
   string assessment = "";
   
   // Đánh giá dựa trên Sharpe Ratio
   if(result.SharpeRatio > 2.0)
      assessment += "XUẤT SẮC: ";
   else if(result.SharpeRatio > 1.0)
      assessment += "TỐT: ";
   else if(result.SharpeRatio > 0.5)
      assessment += "TRUNG BÌNH: ";
   else
      assessment += "KÉM: ";
   
   // Đánh giá VaR
   double var_percent = MathAbs(result.VaR95) / m_InitialBalance * 100;
   if(var_percent > 20)
      assessment += "Rủi ro rất cao (VaR95: " + DoubleToString(var_percent, 1) + "%). ";
   else if(var_percent > 10)
      assessment += "Rủi ro cao (VaR95: " + DoubleToString(var_percent, 1) + "%). ";
   else if(var_percent > 5)
      assessment += "Rủi ro trung bình (VaR95: " + DoubleToString(var_percent, 1) + "%). ";
   else
      assessment += "Rủi ro thấp (VaR95: " + DoubleToString(var_percent, 1) + "%). ";
   
   // Đánh giá xác suất có lãi
   if(result.ProbabilityOfProfit > 0.6)
      assessment += "Xác suất thành công cao.";
   else if(result.ProbabilityOfProfit > 0.5)
      assessment += "Xác suất thành công trung bình.";
   else
      assessment += "Xác suất thành công thấp.";
   
   return assessment;
  }

//+------------------------------------------------------------------+
//| Tạo khuyến nghị hành động                                       |
//+------------------------------------------------------------------+
string CMonteCarloSimulator::GenerateActionableInsights(const MonteCarloResult& result)
  {
   string insights = "KHUYẾN NGHỊ: ";
   
   // Khuyến nghị dựa trên kết quả
   if(result.SharpeRatio < 0.5)
     {
      insights += "Giảm 50% risk per trade. ";
     }
   else if(result.SharpeRatio < 1.0)
     {
      insights += "Giảm 25% risk per trade. ";
     }
   
   if(result.MaxDrawdown > 0.2)
     {
      insights += "Kích hoạt Circuit Breaker khi DD > 15%. ";
     }
   
   if(result.ProbabilityOfProfit < 0.55)
     {
      insights += "Tối ưu lại tham số entry. ";
     }
   
   if(result.Skewness < -1.0)
     {
      insights += "Cải thiện Stop Loss để giảm tail risk. ";
     }
   
   if(result.RecoveryTime > 30)
     {
      insights += "Thời gian phục hồi quá dài, cần tăng position size hoặc cải thiện win rate. ";
     }
   
   // Khuyến nghị dựa trên stress scenario
   if(result.StressScenario == STRESS_BROKER_ISSUES)
     {
      insights += "Theo dõi chặt chẽ broker health score. ";
     }
   
   if(insights == "KHUYẾN NGHỊ: ")
     {
      insights += "Chiến lược hoạt động tốt, duy trì tham số hiện tại.";
     }
   
   return insights;
  }

} // namespace ApexPullback