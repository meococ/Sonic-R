//+------------------------------------------------------------------+
//|                                                   MathHelper.mqh |
//|                         APEX Pullback EA v14.0 - Professional   |
//|                            Hàm toán học tiện ích cho EA         |
//|                          Copyright 2023-2024, APEX Forex        |
//+------------------------------------------------------------------+

#ifndef MATHHELPER_MQH_
#define MATHHELPER_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

//+------------------------------------------------------------------+
//| Các hằng số toán học                                             |
//+------------------------------------------------------------------+
#define PI                 3.14159265358979323846   // Số Pi
#define SQRT_2             1.41421356237309504880   // Căn bậc 2 của 2
#define EULER              2.71828182845904523536   // Số Euler
#define GOLDEN_RATIO       1.61803398874989484820   // Tỷ lệ vàng
#define EPSILON            1e-10                    // Epsilon (sai số chấp nhận được)

//+------------------------------------------------------------------+
//| Các hàm chuyển đổi đơn vị                                       |
//+------------------------------------------------------------------+

// Chuyển đổi điểm (points) sang pips - hỗ trợ đa tài sản
double PointsToPips(const double points, const string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy thông tin digits từ symbol
    int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
    
    // Tính factor chuyển đổi - tùy thuộc vào loại tài sản
    double factor = 1.0;
    
    // Forex thường có 4 hoặc 2 digits sau dấu thập phân (JPY pairs)
    // Forex 5 digits và 3 digits (JPY pairs)
    if (digits == 5 || digits == 3) {
        factor = 10.0;
    }
    
    // Chuyển đổi points sang pips
    return points / factor;
}

// Chuyển đổi pips sang điểm (points)
double PipsToPoints(const double pips, const string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy thông tin digits từ symbol
    int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
    
    // Tính factor chuyển đổi - tùy thuộc vào loại tài sản
    double factor = 1.0;
    
    // Forex thường có 4 hoặc 2 digits sau dấu thập phân (JPY pairs)
    // Forex 5 digits và 3 digits (JPY pairs)
    if (digits == 5 || digits == 3) {
        factor = 10.0;
    }
    
    // Chuyển đổi pips sang points
    return pips * factor;
}

// Chuyển đổi pips sang tiền tệ
double PipsToCurrency(const double pips, const double lotSize, const string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Giá trị 1 pip với lotSize đã cho
    double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
    
    // Nếu tick size là 0, sử dụng giá trị mặc định
    if (tickSize == 0) {
        tickSize = 0.0001;
    }
    
    double valuePerPip = tickValue * PipsToPoints(1.0, sym) / tickSize;
    
    // Tính giá trị tiền tệ
    return pips * valuePerPip * lotSize;
}

// Chuyển đổi tiền tệ sang pips
double CurrencyToPips(const double currency, const double lotSize, const string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Giá trị 1 pip với lotSize đã cho
    double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
    
    // Nếu tick size là 0, sử dụng giá trị mặc định
    if (tickSize == 0) {
        tickSize = 0.0001;
    }
    
    double valuePerPip = tickValue * PipsToPoints(1.0, sym) / tickSize;
    
    // Nếu lotSize hoặc valuePerPip là 0, trả về 0 để tránh lỗi chia cho 0
    if (lotSize == 0 || valuePerPip == 0) {
        return 0;
    }
    
    // Tính giá trị pips
    return currency / (valuePerPip * lotSize);
}

// Chuẩn hóa Lot Size theo quy tắc của sàn
double NormalizeLotSize(const double lotSize, const string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy thông tin min, max, step lot từ symbol
    double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
    
    // Nếu lotStep là 0, sử dụng giá trị mặc định
    if (lotStep == 0) {
        lotStep = 0.01;
    }
    
    // Làm tròn lot size theo lotStep
    double normalizedLot = MathFloor(lotSize / lotStep) * lotStep;
    
    // Đảm bảo lot size nằm trong khoảng [minLot, maxLot]
    normalizedLot = MathMax(minLot, MathMin(maxLot, normalizedLot));
    
    return normalizedLot;
}

// Tính toán lot size dựa trên risk (% vốn) và khoảng cách SL (pips)
double CalculateLotSize(double riskPercent, double slDistance, double accountValue = 0.0, string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Nếu không cung cấp accountValue, sử dụng Balance
    if (accountValue <= 0) {
        accountValue = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    
    // Tính risk amount (tiền tệ)
    double riskAmount = accountValue * riskPercent / 100.0;
    
    // Kiểm tra nếu SL distance bằng 0
    if (slDistance <= 0) {
        return 0; // Không thể tính toán lot size nếu SL distance bằng 0
    }
    
    // Chuyển đổi SL distance từ pips sang điểm
    double slPoints = PipsToPoints(slDistance, sym);
    
    // Nếu slPoints bằng 0, không thể tính toán lot size
    if (slPoints <= 0) {
        return 0;
    }
    
    // Tính giá trị tick
    double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
    double pointValue = tickValue * _Point / tickSize;
    
    // Tính lot size
    double calculatedLotSize = riskAmount / (slPoints * pointValue);
    
    // Chuẩn hóa lot size
    return NormalizeLotSize(calculatedLotSize, sym);
}

//+------------------------------------------------------------------+
//| Các hàm tiện ích thống kê                                        |
//+------------------------------------------------------------------+

// Tính giá trị trung bình của mảng
double Average(const double &array[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(array) - startPos;
    }
    
    if (count <= 0 || startPos < 0 || startPos + count > ArraySize(array)) {
        return 0;
    }
    
    // Tính tổng các phần tử
    double sum = 0;
    for (int i = startPos; i < startPos + count; i++) {
        sum += array[i];
    }
    
    // Trả về giá trị trung bình
    return sum / count;
}

// Tính giá trị trung vị của mảng
double Median(double &array[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(array) - startPos;
    }
    
    if (count <= 0 || startPos < 0 || startPos + count > ArraySize(array)) {
        return 0;
    }
    
    // Tạo bản sao của mảng để sắp xếp
    double tempArray[];
    ArrayResize(tempArray, count);
    for (int i = 0; i < count; i++) {
        tempArray[i] = array[startPos + i];
    }
    
    // Sắp xếp mảng tạm
    ArraySort(tempArray);
    
    // Tính giá trị trung vị
    if (count % 2 == 0) {
        // Số lượng phần tử chẵn, lấy trung bình của 2 phần tử giữa
        return (tempArray[count / 2 - 1] + tempArray[count / 2]) / 2.0;
    } else {
        // Số lượng phần tử lẻ, lấy phần tử giữa
        return tempArray[count / 2];
    }
}

// Tính độ lệch chuẩn của mảng
double StandardDeviation(const double &array[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(array) - startPos;
    }
    
    if (count <= 1 || startPos < 0 || startPos + count > ArraySize(array)) {
        return 0;
    }
    
    // Tính giá trị trung bình
    double avg = Average(array, startPos, count);
    
    // Tính tổng bình phương độ lệch
    double sumSquaredDeviations = 0;
    for (int i = startPos; i < startPos + count; i++) {
        sumSquaredDeviations += MathPow(array[i] - avg, 2);
    }
    
    // Trả về độ lệch chuẩn
    return MathSqrt(sumSquaredDeviations / count);
}

// Tính giá trị Z-score
double ZScore(double value, double mean, double stdDev) {
    // Tránh chia cho 0
    if (stdDev == 0) {
        return 0;
    }
    
    // Tính Z-score
    return (value - mean) / stdDev;
}

// Tính giá trị Z-score cho một mảng
void ZScoreArray(const double &inputArray[], double &outputArray[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(inputArray) - startPos;
    }
    
    if (count <= 0 || startPos < 0 || startPos + count > ArraySize(inputArray)) {
        return;
    }
    
    // Đảm bảo mảng output có kích thước đủ
    ArrayResize(outputArray, count);
    
    // Tính giá trị trung bình và độ lệch chuẩn
    double avg = Average(inputArray, startPos, count);
    double stdDev = StandardDeviation(inputArray, startPos, count);
    
    // Tránh chia cho 0
    if (stdDev == 0) {
        for (int i = 0; i < count; i++) {
            outputArray[i] = 0;
        }
        return;
    }
    
    // Tính Z-score cho từng phần tử
    for (int i = 0; i < count; i++) {
        outputArray[i] = (inputArray[startPos + i] - avg) / stdDev;
    }
}

// Tính hệ số tương quan Pearson giữa hai mảng
double PearsonCorrelation(const double &arrayX[], const double &arrayY[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = MathMin(ArraySize(arrayX) - startPos, ArraySize(arrayY) - startPos);
    }
    
    if (count <= 1 || startPos < 0 || startPos + count > ArraySize(arrayX) || startPos + count > ArraySize(arrayY)) {
        return 0;
    }
    
    // Tính giá trị trung bình của hai mảng
    double avgX = Average(arrayX, startPos, count);
    double avgY = Average(arrayY, startPos, count);
    
    // Tính tử số và mẫu số
    double numerator = 0;
    double denomX = 0;
    double denomY = 0;
    
    for (int i = startPos; i < startPos + count; i++) {
        double diffX = arrayX[i] - avgX;
        double diffY = arrayY[i] - avgY;
        
        numerator += diffX * diffY;
        denomX += diffX * diffX;
        denomY += diffY * diffY;
    }
    
    // Tránh chia cho 0
    if (denomX == 0 || denomY == 0) {
        return 0;
    }
    
    // Trả về hệ số tương quan
    return numerator / MathSqrt(denomX * denomY);
}

// Tính Linear Regression Slope (độ dốc hồi quy tuyến tính)
double LinearRegressionSlope(const double &arrayY[], const double &arrayX[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = MathMin(ArraySize(arrayX) - startPos, ArraySize(arrayY) - startPos);
    }
    
    if (count <= 1 || startPos < 0 || startPos + count > ArraySize(arrayX) || startPos + count > ArraySize(arrayY)) {
        return 0;
    }
    
    // Tính giá trị trung bình của hai mảng
    double avgX = Average(arrayX, startPos, count);
    double avgY = Average(arrayY, startPos, count);
    
    // Tính tử số và mẫu số
    double numerator = 0;
    double denominator = 0;
    
    for (int i = startPos; i < startPos + count; i++) {
        double diffX = arrayX[i] - avgX;
        
        numerator += diffX * (arrayY[i] - avgY);
        denominator += diffX * diffX;
    }
    
    // Tránh chia cho 0
    if (denominator == 0) {
        return 0;
    }
    
    // Trả về độ dốc
    return numerator / denominator;
}

// Tính độ dốc của n phần tử gần nhất trong mảng
double CalculateSlope(const double &array[], int period, int shift = 0) {
    // Kiểm tra tham số đầu vào
    if (period <= 1 || shift < 0 || shift + period > ArraySize(array)) {
        return 0;
    }
    
    // Tạo mảng X (chỉ số)
    double arrayX[];
    ArrayResize(arrayX, period);
    for (int i = 0; i < period; i++) {
        arrayX[i] = i;
    }
    
    // Tính độ dốc
    return LinearRegressionSlope(array, arrayX, shift, period);
}

//+------------------------------------------------------------------+
//| Các hàm nội suy và làm mịn dữ liệu                              |
//+------------------------------------------------------------------+

// Nội suy tuyến tính
double LinearInterpolation(double x, double x0, double y0, double x1, double y1) {
    // Tránh chia cho 0
    if (x1 == x0) {
        return (y0 + y1) / 2.0;
    }
    
    // Tính giá trị nội suy
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
}

// Đường trung bình động đơn giản (SMA)
void SimpleMovingAverage(const double &inputArray[], double &outputArray[], int period, int shift = 0) {
    // Kiểm tra tham số đầu vào
    int inputSize = ArraySize(inputArray);
    if (period <= 0 || shift < 0 || shift + period > inputSize) {
        ArrayResize(outputArray, 0);
        return;
    }
    
    // Tính kích thước mảng output
    int outputSize = inputSize - period - shift + 1;
    if (outputSize <= 0) {
        ArrayResize(outputArray, 0);
        return;
    }
    
    // Đảm bảo mảng output có kích thước đủ
    ArrayResize(outputArray, outputSize);
    
    // Tính SMA
    for (int i = 0; i < outputSize; i++) {
        outputArray[i] = Average(inputArray, i + shift, period);
    }
}

// Đường trung bình động có trọng số (EMA)
void ExponentialMovingAverage(const double &inputArray[], double &outputArray[], int period, int shift = 0) {
    // Kiểm tra tham số đầu vào
    int inputSize = ArraySize(inputArray);
    if (period <= 0 || shift < 0 || shift + period > inputSize) {
        ArrayResize(outputArray, 0);
        return;
    }
    
    // Tính kích thước mảng output
    int outputSize = inputSize - period - shift + 1;
    if (outputSize <= 0) {
        ArrayResize(outputArray, 0);
        return;
    }
    
    // Đảm bảo mảng output có kích thước đủ
    ArrayResize(outputArray, outputSize);
    
    // Tính hệ số alpha
    double alpha = 2.0 / (period + 1.0);
    
    // Tính SMA đầu tiên
    outputArray[0] = Average(inputArray, shift, period);
    
    // Tính EMA cho các phần tử còn lại
    for (int i = 1; i < outputSize; i++) {
        outputArray[i] = alpha * inputArray[i + shift + period - 1] + (1 - alpha) * outputArray[i - 1];
    }
}

//+------------------------------------------------------------------+
//| Các hàm xác suất và phân phối                                    |
//+------------------------------------------------------------------+

// Tính xác suất từ phân phối chuẩn (Z-score)
double NormalCDF(double z) {
    // Thuật toán xấp xỉ CDF của phân phối chuẩn
    // Nguồn: Abramowitz and Stegun approximation (độ chính xác 1.5×10^−7)
    
    // Xử lý z âm bằng cách sử dụng tính đối xứng
    if (z < 0) {
        return 1 - NormalCDF(-z);
    }
    
    // Hằng số
    const double b1 = 0.31938153;
    const double b2 = -0.356563782;
    const double b3 = 1.781477937;
    const double b4 = -1.821255978;
    const double b5 = 1.330274429;
    const double p = 0.2316419;
    
    // Tính giá trị xác suất
    double t = 1.0 / (1.0 + p * z);
    double result = 1.0 - (1.0 / SQRT_2 / PI) * MathExp(-0.5 * z * z) * 
                    (b1 * t + b2 * t * t + b3 * MathPow(t, 3) + b4 * MathPow(t, 4) + b5 * MathPow(t, 5));
    
    return result;
}

// Tính giá trị Z-score từ xác suất
double NormalInvCDF(double p) {
    // Thuật toán xấp xỉ Inverse CDF của phân phối chuẩn
    // Nguồn: Abramowitz and Stegun approximation
    
    // Kiểm tra tham số đầu vào
    if (p <= 0.0) return -DBL_MAX;
    if (p >= 1.0) return DBL_MAX;
    
    // Xử lý p > 0.5 bằng cách sử dụng tính đối xứng
    bool upperRegion = (p > 0.5);
    if (upperRegion) {
        p = 1.0 - p;
    }
    
    // Hằng số
    const double c0 = 2.515517;
    const double c1 = 0.802853;
    const double c2 = 0.010328;
    const double d1 = 1.432788;
    const double d2 = 0.189269;
    const double d3 = 0.001308;
    
    // Tính giá trị Z-score
    double t = MathSqrt(-2.0 * MathLog(p));
    double z = t - (c0 + c1 * t + c2 * t * t) / (1.0 + d1 * t + d2 * t * t + d3 * t * t * t);
    
    return upperRegion ? z : -z;
}

// Tính giá trị phân vị (percentile)
double Percentile(double &array[], double percentile, int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(array) - startPos;
    }
    
    if (count <= 0 || startPos < 0 || startPos + count > ArraySize(array) || percentile < 0 || percentile > 1) {
        return 0;
    }
    
    // Tạo bản sao của mảng để sắp xếp
    double tempArray[];
    ArrayResize(tempArray, count);
    for (int i = 0; i < count; i++) {
        tempArray[i] = array[startPos + i];
    }
    
    // Sắp xếp mảng tạm
    ArraySort(tempArray);
    
    // Tính chỉ số (không phải số nguyên)
    double index = (count - 1) * percentile;
    
    // Nội suy
    int lowerIndex = (int)MathFloor(index);
    int upperIndex = (int)MathCeil(index);
    
    if (lowerIndex == upperIndex) {
        return tempArray[lowerIndex];
    } else {
        double weight = index - lowerIndex;
        return tempArray[lowerIndex] * (1 - weight) + tempArray[upperIndex] * weight;
    }
}

//+------------------------------------------------------------------+
//| Các hàm phân tích tài chính                                      |
//+------------------------------------------------------------------+

// Tính Drawdown từ mảng dữ liệu equity
double CalculateDrawdown(const double &equityArray[], int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(equityArray) - startPos;
    }
    
    if (count <= 0 || startPos < 0 || startPos + count > ArraySize(equityArray)) {
        return 0;
    }
    
    // Tìm giá trị cao nhất (đỉnh)
    double peak = equityArray[startPos];
    double maxDrawdown = 0;
    
    for (int i = startPos; i < startPos + count; i++) {
        if (equityArray[i] > peak) {
            peak = equityArray[i]; // Cập nhật đỉnh mới
        } else {
            // Tính drawdown hiện tại
            double currentDrawdown = (peak - equityArray[i]) / peak * 100.0;
            
            // Cập nhật max drawdown
            if (currentDrawdown > maxDrawdown) {
                maxDrawdown = currentDrawdown;
            }
        }
    }
    
    return maxDrawdown;
}

// Tính Sharpe Ratio (tỷ lệ Sharpe)
double CalculateSharpeRatio(const double &returnsArray[], double riskFreeRate, int startPos = 0, int count = WHOLE_ARRAY) {
    // Kiểm tra tham số đầu vào
    if (count == WHOLE_ARRAY) {
        count = ArraySize(returnsArray) - startPos;
    }
    
    if (count <= 1 || startPos < 0 || startPos + count > ArraySize(returnsArray)) {
        return 0;
    }
    
    // Tính giá trị trung bình của lợi nhuận
    double avgReturn = Average(returnsArray, startPos, count);
    
    // Tính độ lệch chuẩn của lợi nhuận
    double stdDevReturn = StandardDeviation(returnsArray, startPos, count);
    
    // Tránh chia cho 0
    if (stdDevReturn == 0) {
        return 0;
    }
    
    // Trả về tỷ lệ Sharpe
    return (avgReturn - riskFreeRate) / stdDevReturn;
}

// Tính Risk-to-Reward Ratio từ mảng dữ liệu lợi nhuận và thua lỗ
double CalculateRiskRewardRatio(const double &winsArray[], const double &lossesArray[]) {
    // Kiểm tra tham số đầu vào
    int winsCount = ArraySize(winsArray);
    int lossesCount = ArraySize(lossesArray);
    
    if (winsCount == 0 || lossesCount == 0) {
        return 0;
    }
    
    // Tính giá trị trung bình của lợi nhuận và thua lỗ
    double avgWin = Average(winsArray);
    double avgLoss = Average(lossesArray);
    
    // Tránh chia cho 0
    if (avgLoss == 0) {
        return 0;
    }
    
    // Trả về Risk-to-Reward Ratio
    return MathAbs(avgWin / avgLoss);
}

// Tính Profit Factor từ mảng dữ liệu lợi nhuận và thua lỗ
double CalculateProfitFactor(const double &winsArray[], const double &lossesArray[]) {
    // Kiểm tra tham số đầu vào
    int winsCount = ArraySize(winsArray);
    int lossesCount = ArraySize(lossesArray);
    
    if (winsCount == 0 || lossesCount == 0) {
        return 0;
    }
    
    // Tính tổng lợi nhuận và tổng thua lỗ
    double totalWin = 0;
    double totalLoss = 0;
    
    for (int i = 0; i < winsCount; i++) {
        totalWin += winsArray[i];
    }
    
    for (int i = 0; i < lossesCount; i++) {
        totalLoss += MathAbs(lossesArray[i]);
    }
    
    // Tránh chia cho 0
    if (totalLoss == 0) {
        return DBL_MAX; // Profit Factor vô cùng khi không có thua lỗ
    }
    
    // Trả về Profit Factor
    return totalWin / totalLoss;
}

// Tính Expectancy từ Win Rate và Risk-to-Reward Ratio
double CalculateExpectancy(double winRate, double riskRewardRatio) {
    // Kiểm tra tham số đầu vào
    if (winRate < 0 || winRate > 1) {
        return 0;
    }
    
    // Tính Expectancy
    return (winRate * riskRewardRatio) - (1 - winRate);
}

// Tính Maximum Consecutive Wins hoặc Losses từ mảng kết quả giao dịch
int CalculateMaxConsecutive(const bool &tradesResultArray[], bool forWins) {
    // Kiểm tra tham số đầu vào
    int count = ArraySize(tradesResultArray);
    if (count == 0) {
        return 0;
    }
    
    int maxConsecutive = 0;
    int currentConsecutive = 0;
    
    for (int i = 0; i < count; i++) {
        if (tradesResultArray[i] == forWins) {
            currentConsecutive++;
            
            // Cập nhật maxConsecutive
            if (currentConsecutive > maxConsecutive) {
                maxConsecutive = currentConsecutive;
            }
        } else {
            currentConsecutive = 0;
        }
    }
    
    return maxConsecutive;
}

//+------------------------------------------------------------------+
//| Các hàm tính toán cho AssetProfiler                               |
//+------------------------------------------------------------------+

// Tạo ATR bình thường hóa theo timeframe và tài sản
double NormalizeATR(double atrValue, ENUM_TIMEFRAMES timeframe, string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy decimal places từ symbol
    int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
    
    // Hệ số chuyển đổi theo loại tài sản
    double assetFactor = 1.0;
    
    // Forex thường có 4-5 decimal places
    if (digits == 4 || digits == 5) {
        assetFactor = 10000.0;
    }
    // Pairs JPY hoặc CFD có 2-3 decimal places
    else if (digits == 2 || digits == 3) {
        assetFactor = 100.0;
    }
    // Gold, Silver, Indices, etc.
    else if (digits == 1) {
        assetFactor = 10.0;
    }
    
    // Hệ số timeframe (chuẩn hóa về H1)
    double timeframeFactor = 1.0;
    
    switch (timeframe) {
        case PERIOD_M1:  timeframeFactor = 1.0 / 60.0; break;
        case PERIOD_M5:  timeframeFactor = 1.0 / 12.0; break;
        case PERIOD_M15: timeframeFactor = 1.0 / 4.0; break;
        case PERIOD_M30: timeframeFactor = 1.0 / 2.0; break;
        case PERIOD_H1:  timeframeFactor = 1.0; break;
        case PERIOD_H4:  timeframeFactor = 4.0; break;
        case PERIOD_D1:  timeframeFactor = 24.0; break;
        case PERIOD_W1:  timeframeFactor = 24.0 * 7.0; break;
        case PERIOD_MN1: timeframeFactor = 24.0 * 30.0; break;
    }
    
    // Chuẩn hóa giá trị ATR
    double normalizedATR = atrValue * assetFactor * timeframeFactor;
    
    return normalizedATR;
}

// Tính ngưỡng Spread chấp nhận được dựa trên biến động và loại tài sản
double CalculateAcceptableSpreadThreshold(double volatility, string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy thông tin symbol
    string symbolName = sym;
    int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
    double point = SymbolInfoDouble(sym, SYMBOL_POINT);
    double avgSpread = SymbolInfoInteger(sym, SYMBOL_SPREAD) * point;
    
    // Phân loại tài sản
    bool isForex = ((digits == 4 || digits == 5) || ((digits == 2 || digits == 3) && StringFind(symbolName, "JPY") >= 0));
    bool isGold = (StringFind(symbolName, "GOLD") >= 0 || StringFind(symbolName, "XAU") >= 0);
    bool isCrypto = (StringFind(symbolName, "BTC") >= 0 || StringFind(symbolName, "ETH") >= 0);
    bool isIndex = (StringFind(symbolName, "US30") >= 0 || StringFind(symbolName, "SPX") >= 0 || StringFind(symbolName, "NAS") >= 0);
    
    // Ngưỡng cơ sở dựa trên loại tài sản
    double baseThreshold = 0;
    
    if (isForex) {
        baseThreshold = 30; // Forex: 3.0 pips
    } else if (isGold) {
        baseThreshold = 50; // Gold: 5.0 pips
    } else if (isCrypto) {
        baseThreshold = 200; // Crypto: 20.0 pips
    } else if (isIndex) {
        baseThreshold = 80; // Indices: 8.0 pips
    } else {
        baseThreshold = 60; // Other assets: 6.0 pips
    }
    
    // Điều chỉnh ngưỡng dựa trên biến động
    double volatilityFactor = 1.0;
    
    if (volatility > 1.5) {
        volatilityFactor = 1.0 + (volatility - 1.5) * 0.2; // Tăng ngưỡng khi biến động cao
    } else if (volatility < 0.8) {
        volatilityFactor = 0.8; // Giảm ngưỡng khi biến động thấp
    }
    
    // Ngưỡng cuối cùng
    double finalThreshold = baseThreshold * volatilityFactor;
    
    // Đảm bảo ngưỡng không nhỏ hơn spread hiện tại
    finalThreshold = MathMax(finalThreshold, avgSpread * 1.5);
    
    return finalThreshold * point;
}

// Tính tương quan giữa các cặp tiền tệ (chỉ áp dụng cho Forex)
double CalculateSymbolCorrelation(string symbol1, string symbol2, int period) {
    // Kiểm tra period
    if (period <= 1) {
        return 0;
    }
    
    // Lấy dữ liệu giá đóng cửa
    double prices1[];
    double prices2[];
    
    ArrayResize(prices1, period);
    ArrayResize(prices2, period);
    
    // Copy giá đóng cửa
    for (int i = 0; i < period; i++) {
        prices1[i] = iClose(symbol1, PERIOD_H1, i);
        prices2[i] = iClose(symbol2, PERIOD_H1, i);
    }
    
    // Tính phần trăm thay đổi
    double changes1[];
    double changes2[];
    
    ArrayResize(changes1, period - 1);
    ArrayResize(changes2, period - 1);
    
    for (int i = 0; i < period - 1; i++) {
        changes1[i] = (prices1[i] - prices1[i+1]) / prices1[i+1] * 100.0;
        changes2[i] = (prices2[i] - prices2[i+1]) / prices2[i+1] * 100.0;
    }
    
    // Tính hệ số tương quan
    return PearsonCorrelation(changes1, changes2);
}

// Tính thời gian tối ưu trong ngày cho giao dịch (Session Analyzer)
bool GetOptimalTradingHours(string symbol, int &startHour, int &endHour, double &confidence) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Lấy thông tin symbol
    string symbolName = sym;
    
    // Phân loại tài sản để xác định phiên tối ưu
    bool isForex = (StringFind(symbolName, "USD") >= 0 || StringFind(symbolName, "EUR") >= 0 || 
                  StringFind(symbolName, "GBP") >= 0 || StringFind(symbolName, "JPY") >= 0);
    bool isEuropean = (StringFind(symbolName, "EUR") >= 0 || StringFind(symbolName, "GBP") >= 0 || 
                     StringFind(symbolName, "CHF") >= 0);
    bool isAsian = (StringFind(symbolName, "JPY") >= 0 || StringFind(symbolName, "AUD") >= 0 || 
                  StringFind(symbolName, "NZD") >= 0);
    bool isUS = (StringFind(symbolName, "USD") >= 0);
    bool isGold = (StringFind(symbolName, "GOLD") >= 0 || StringFind(symbolName, "XAU") >= 0);
    bool isIndex = (StringFind(symbolName, "US30") >= 0 || StringFind(symbolName, "SPX") >= 0);
    
    // Xác định phiên giao dịch tối ưu (giờ GMT)
    if (isForex) {
        if (isEuropean && isUS) {
            // Pairs EUR/USD, GBP/USD: London-New York overlap
            startHour = 13; // 13:00 GMT
            endHour = 16;   // 16:00 GMT
            confidence = 0.9;
        }
        else if (isEuropean) {
            // Pairs EUR/GBP, EUR/CHF: London session
            startHour = 8;  // 8:00 GMT
            endHour = 12;   // 12:00 GMT
            confidence = 0.85;
        }
        else if (isAsian && isUS) {
            // Pairs USD/JPY, AUD/USD: Asian-New York overlap
            startHour = 23; // 23:00 GMT (previous day)
            endHour = 1;    // 1:00 GMT
            confidence = 0.8;
        }
        else if (isAsian) {
            // Pairs AUD/JPY, NZD/JPY: Asian session
            startHour = 0;  // 0:00 GMT
            endHour = 3;    // 3:00 GMT
            confidence = 0.75;
        }
        else {
            // Default Forex
            startHour = 13; // 13:00 GMT
            endHour = 16;   // 16:00 GMT
            confidence = 0.7;
        }
    }
    else if (isGold) {
        // Gold: NY session
        startHour = 14; // 14:00 GMT
        endHour = 19;   // 19:00 GMT
        confidence = 0.85;
    }
    else if (isIndex) {
        // US Indices: NY session
        startHour = 14; // 14:00 GMT
        endHour = 20;   // 20:00 GMT
        confidence = 0.9;
    }
    else {
        // Default for other assets
        startHour = 13; // 13:00 GMT
        endHour = 16;   // 16:00 GMT
        confidence = 0.6;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Các hàm tiện ích khác                                            |
//+------------------------------------------------------------------+

// Chuyển đổi timeframe thành string
string TimeframeToString(ENUM_TIMEFRAMES timeframe) {
    switch (timeframe) {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN";
        default:         return "Unknown";
    }
}

// Làm tròn số theo số chữ số thập phân
double RoundToDigits(double value, int digits) {
    double factor = MathPow(10, digits);
    return MathRound(value * factor) / factor;
}

// Format số theo định dạng cụ thể (phân cách hàng nghìn và phần thập phân)
string FormatNumber(double value, int digits = 2, string thousandsSep = " ", string decimalSep = ".") {
    // Làm tròn giá trị theo số chữ số thập phân
    value = RoundToDigits(value, digits);
    
    // Chuyển đổi giá trị thành chuỗi
    string strValue = DoubleToString(value, digits);
    
    // Thay thế dấu thập phân
    StringReplace(strValue, ".", decimalSep);
    
    // Nếu không cần phân cách hàng nghìn, trả về kết quả
    if (thousandsSep == "") {
        return strValue;
    }
    
    // Tìm vị trí dấu thập phân
    int decimalPos = StringFind(strValue, decimalSep);
    
    // Nếu không có dấu thập phân, sử dụng độ dài chuỗi
    if (decimalPos < 0) {
        decimalPos = StringLen(strValue);
    }
    
    // Chèn dấu phân cách hàng nghìn
    for (int i = decimalPos - 3; i > 0; i -= 3) {
        strValue = StringSubstr(strValue, 0, i) + thousandsSep + StringSubstr(strValue, i);
    }
    
    return strValue;
}

// Tính toán khoảng cách theo R-multiple từ entry và SL
double CalculateRMultiple(double currentPrice, double entryPrice, double stopLossPrice) {
    if (MathAbs(entryPrice - stopLossPrice) < EPSILON) {
        return 0;
    }
    
    double riskDistance = MathAbs(entryPrice - stopLossPrice);
    double profitDistance = MathAbs(currentPrice - entryPrice);
    
    return (currentPrice - entryPrice) * (entryPrice - stopLossPrice) > 0 ? 
           profitDistance / riskDistance : 
           -profitDistance / riskDistance;
}

// Lấy tên ngày trong tuần từ datetime
string GetDayOfWeekName(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    string days[] = {"Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"};
    
    if (dt.day_of_week >= 0 && dt.day_of_week < 7) {
        return days[dt.day_of_week];
    } else {
        return "Không xác định";
    }
}

// Kiểm tra nếu là nến bất thường (gap lớn, spread cao bất thường, v.v.)
bool IsAbnormalCandle(int shift = 0, double deviationFactor = 3.0, string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Kiểm tra tham số đầu vào
    if (shift < 0) {
        return false;
    }
    
    // Lấy thông tin về nến
    double high = iHigh(sym, PERIOD_CURRENT, shift);
    double low = iLow(sym, PERIOD_CURRENT, shift);
    double open = iOpen(sym, PERIOD_CURRENT, shift);
    double close = iClose(sym, PERIOD_CURRENT, shift);
    
    // Tính chiều cao của nến
    double candleSize = high - low;
    
    // Lấy ATR trong 14 nến
    double atr = 0;
    for (int i = shift; i < shift + 14; i++) {
        double highI = iHigh(sym, PERIOD_CURRENT, i);
        double lowI = iLow(sym, PERIOD_CURRENT, i);
        atr += (highI - lowI);
    }
    atr /= 14;
    
    // Nếu kích thước nến lớn hơn deviationFactor lần ATR
    if (candleSize > atr * deviationFactor) {
        return true;
    }
    
    // Kiểm tra gap
    if (shift > 0) {
        double prevClose = iClose(sym, PERIOD_CURRENT, shift + 1);
        double gap = MathAbs(open - prevClose);
        
        if (gap > atr * deviationFactor / 2) {
            return true;
        }
    }
    
    return false;
}

// Tìm mức hỗ trợ kháng cự nhanh dựa trên phân tích mức giá
void FindQuickSupportResistance(double &supportLevels[], double &resistanceLevels[], int lookbackPeriod = 50, int maxLevels = 3, string symbol = NULL) {
    string sym = (symbol == NULL) ? _Symbol : symbol;
    
    // Khởi tạo mảng
    ArrayResize(supportLevels, 0);
    ArrayResize(resistanceLevels, 0);
    
    // Mảng giá thấp và cao
    double lows[];
    double highs[];
    
    ArrayResize(lows, lookbackPeriod);
    ArrayResize(highs, lookbackPeriod);
    
    // Lấy dữ liệu giá
    for (int i = 0; i < lookbackPeriod; i++) {
        lows[i] = iLow(sym, PERIOD_CURRENT, i);
        highs[i] = iHigh(sym, PERIOD_CURRENT, i);
    }
    
    // Tìm mức hỗ trợ (lows)
    double lowClusters[];
    FindPriceClusters(lows, lowClusters, maxLevels);
    
    // Tìm mức kháng cự (highs)
    double highClusters[];
    FindPriceClusters(highs, highClusters, maxLevels);
    
    // Gán kết quả
    ArrayResize(supportLevels, ArraySize(lowClusters));
    ArrayResize(resistanceLevels, ArraySize(highClusters));
    
    for (int i = 0; i < ArraySize(lowClusters); i++) {
        supportLevels[i] = lowClusters[i];
    }
    
    for (int i = 0; i < ArraySize(highClusters); i++) {
        resistanceLevels[i] = highClusters[i];
    }
}

// Hàm hỗ trợ để tìm các cụm giá
void FindPriceClusters(const double &prices[], double &clusters[], int maxClusters) {
    int pricesCount = ArraySize(prices);
    
    if (pricesCount == 0) {
        ArrayResize(clusters, 0);
        return;
    }
    
    // Sắp xếp các giá trị
    double sortedPrices[];
    ArrayResize(sortedPrices, pricesCount);
    ArrayCopy(sortedPrices, prices);
    ArraySort(sortedPrices);
    
    // Tìm ngưỡng khoảng cách
    double range = sortedPrices[pricesCount - 1] - sortedPrices[0];
    double clusterThreshold = range * 0.01; // 1% của khoảng giá
    
    // Mảng tạm để lưu các cluster
    double tempClusters[];
    int clusterCounts[];
    int currentClusterCount = 0;
    
    // Tìm các cluster
    double currentCluster = sortedPrices[0];
    int count = 1;
    
    for (int i = 1; i < pricesCount; i++) {
        if (sortedPrices[i] - currentCluster < clusterThreshold) {
            count++;
        } else {
            // Lưu cluster hiện tại
            ArrayResize(tempClusters, currentClusterCount + 1);
            ArrayResize(clusterCounts, currentClusterCount + 1);
            
            tempClusters[currentClusterCount] = currentCluster;
            clusterCounts[currentClusterCount] = count;
            
            currentClusterCount++;
            
            // Bắt đầu một cluster mới
            currentCluster = sortedPrices[i];
            count = 1;
        }
    }
    
    // Lưu cluster cuối cùng
    if (count > 0) {
        ArrayResize(tempClusters, currentClusterCount + 1);
        ArrayResize(clusterCounts, currentClusterCount + 1);
        
        tempClusters[currentClusterCount] = currentCluster;
        clusterCounts[currentClusterCount] = count;
        
        currentClusterCount++;
    }
    
    // Sắp xếp các cluster theo số lần xuất hiện
    int indices[];
    ArrayResize(indices, currentClusterCount);
    for (int i = 0; i < currentClusterCount; i++) {
        indices[i] = i;
    }
    
    // Thuật toán sắp xếp bubble sort đơn giản
    for (int i = 0; i < currentClusterCount - 1; i++) {
        for (int j = 0; j < currentClusterCount - i - 1; j++) {
            if (clusterCounts[indices[j]] < clusterCounts[indices[j + 1]]) {
                int temp = indices[j];
                indices[j] = indices[j + 1];
                indices[j + 1] = temp;
            }
        }
    }
    
    // Lấy tối đa maxClusters cluster có nhiều điểm nhất
    int resultCount = MathMin(maxClusters, currentClusterCount);
    ArrayResize(clusters, resultCount);
    
    for (int i = 0; i < resultCount; i++) {
        clusters[i] = tempClusters[indices[i]];
    }
}

} // END NAMESPACE ApexPullback

#endif // MATHHELPER_MQH_