//+------------------------------------------------------------------+
//|                                                 ID_Detection.mqh |
//|                              Institutional Order Detector        |
//|                              Detection Logic (Optimized)         |
//+------------------------------------------------------------------+
#ifndef ID_DETECTION_MQH
#define ID_DETECTION_MQH

#include "ID_Defines.mqh"
#include "ID_Globals.mqh"
#include "ID_Utils.mqh"
#include "ID_GUI.mqh"

//+------------------------------------------------------------------+
//| Create Threshold Line                                            |
//+------------------------------------------------------------------+
void CreateThresholdLine() {
   string indicatorName = INDICATOR_NAME + " (" + IntegerToString(InpLookbackPeriod) + ")";
   int subwindow = GetWindowFind(indicatorName);

   if(subwindow >= 0) {
      if(ObjectFind(0, g_thresholdLineName) < 0) {
         ObjectCreate(0, g_thresholdLineName, OBJ_HLINE, subwindow, 0, g_currentThreshold);
      }
      ObjectSetInteger(0, g_thresholdLineName, OBJPROP_COLOR, clrYellow);
      ObjectSetInteger(0, g_thresholdLineName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, g_thresholdLineName, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, g_thresholdLineName, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, g_thresholdLineName, OBJPROP_SELECTED, false);
      ObjectSetString(0, g_thresholdLineName, OBJPROP_TOOLTIP, "Drag to adjust threshold");
   }
}

//+------------------------------------------------------------------+
//| Apply Threshold (Fast)                                           |
//+------------------------------------------------------------------+
void ApplyThreshold() {
   if(g_isProcessing) return;
   g_isProcessing = true;

   if(ObjectFind(0, g_thresholdLineName) >= 0) {
      ObjectSetDouble(0, g_thresholdLineName, OBJPROP_PRICE, g_currentThreshold);
   } else {
      CreateThresholdLine();
   }

#ifdef IS_MQL5
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, g_currentThreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -g_currentThreshold);
#else
   SetLevelValue(0, g_currentThreshold);
   SetLevelValue(1, -g_currentThreshold);
#endif

   g_needFullRefresh = true;
   RefreshDetectionLines();

   g_isProcessing = false;
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Detect Order Type (AsSeries=true version)                        |
//| In AsSeries mode: index 0 = newest, larger index = older         |
//| So to look back (older bars), we add to index: i+k               |
//+------------------------------------------------------------------+
int DetectOrderTypeFast(int i, int maxIndex, double priceChange, double closePos,
                        string &orderType, string &orderDirection) {
   if(g_detectAggressive) {
      double threshold3x = InpPriceChangeThreshold * 3.0;
      if(priceChange > threshold3x) {
         orderType = DETECT_TYPE_AGGRESSIVE;
         orderDirection = ORDER_DIR_BUY;
         return 1;
      }
      if(priceChange < -threshold3x) {
         orderType = DETECT_TYPE_AGGRESSIVE;
         orderDirection = ORDER_DIR_SELL;
         return 1;
      }
   }

   if(g_detectAbsorption) {
      if(MathAbs(priceChange) < InpPriceChangeThreshold) {
         orderType = DETECT_TYPE_ABSORPTION;
         return 2;
      }
   }

   // In AsSeries mode: lookback means higher indices (older bars)
   if(g_detectIceberg && i + ICEBERG_LOOKBACK < maxIndex) {
      bool isIceberg = true;
      for(int k = 1; k <= ICEBERG_LOOKBACK; k++) {
         if(VolumeZScoreBuffer[i + k] < ICEBERG_MIN_ZSCORE) {
            isIceberg = false;
            break;
         }
      }
      if(isIceberg) {
         orderType = DETECT_TYPE_ICEBERG;
         orderDirection = closePos > ICEBERG_CLOSE_RATIO ? ORDER_DIR_BUY : ORDER_DIR_SELL;
         return 3;
      }
   }

   return 0;
}

//+------------------------------------------------------------------+
//| Refresh Detection Lines (AsSeries=true version)                  |
//+------------------------------------------------------------------+
void RefreshDetectionLines() {
   if(g_isProcessing && !g_needFullRefresh) return;

   ObjectsDeleteAll(0, VLINE_PREFIX, -1, OBJ_VLINE);

   int rates_total = GetBarsCount();
   if(rates_total <= InpLookbackPeriod) return;

   int bufferSize = ArraySize(VolumeZScoreBuffer);
   if(bufferSize <= InpLookbackPeriod) return;

   datetime time[];
   double close[];
   double high[];
   double low[];

   int copyCount = MathMin(rates_total, bufferSize);

#ifdef IS_MQL5
   if(CopyTime(GetSymbol(), PERIOD_CURRENT, 0, copyCount, time) <= 0) return;
   if(CopyClose(GetSymbol(), PERIOD_CURRENT, 0, copyCount, close) <= 0) return;
   if(CopyHigh(GetSymbol(), PERIOD_CURRENT, 0, copyCount, high) <= 0) return;
   if(CopyLow(GetSymbol(), PERIOD_CURRENT, 0, copyCount, low) <= 0) return;
#else
   if(CopyTimeSeries(time, GetSymbol(), PERIOD_CURRENT) <= 0) return;
   if(CopyPriceSeries(close, MODE_CLOSE, GetSymbol(), PERIOD_CURRENT) <= 0) return;
   if(CopyPriceSeries(high, MODE_HIGH, GetSymbol(), PERIOD_CURRENT) <= 0) return;
   if(CopyPriceSeries(low, MODE_LOW, GetSymbol(), PERIOD_CURRENT) <= 0) return;
#endif

   // Match buffer direction: AsSeries=true (index 0 = newest)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   int detected_count = 0;
   datetime lastDetTime = 0;
   int lineIdx = 0;

   // Process from oldest to newest
   // VolumeZScoreBuffer is already fully calculated by OnCalculate
   int maxIdx = copyCount - InpLookbackPeriod - 1;
   if(maxIdx < 0) maxIdx = 0;

   for(int i = maxIdx; i >= 0; i--) {
      double zscore = VolumeZScoreBuffer[i];
      if(zscore <= g_currentThreshold) continue;

      // Need older bar for price change (i+1 is older in AsSeries mode)
      if(i + 1 >= copyCount) continue;

      double priceChange = (close[i] - close[i + 1]) / close[i + 1];
      double closePos = 0.5;
      if(high[i] - low[i] > 0) {
         closePos = (close[i] - low[i]) / (high[i] - low[i]);
      }

      string orderType = "";
      string orderDirection = "";

      int detectResult = DetectOrderTypeFast(i, copyCount, priceChange, closePos, orderType, orderDirection);
      if(detectResult == 0) continue;

      if(detectResult == 2) {
         orderDirection = ORDER_DIR_NEUTRAL;
      }

      // Color based on order type and direction
      color lineColor;
      if(orderType == DETECT_TYPE_ABSORPTION) {
         lineColor = clrOrange;
      } else if(orderDirection == ORDER_DIR_BUY) {
         lineColor = clrLime;
      } else {
         lineColor = clrRed;
      }
      string lineName = VLINE_PREFIX + IntegerToString(lineIdx++);

      ObjectCreate(0, lineName, OBJ_VLINE, 0, time[i], 0);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);

      string tooltip = StringFormat("%s %s\nZ-Score: %.2f\n%s",
                                    orderType, orderDirection, zscore,
                                    TimeToString(time[i], TIME_DATE|TIME_MINUTES));
      ObjectSetString(0, lineName, OBJPROP_TOOLTIP, tooltip);

      detected_count++;
      lastDetTime = time[i];
   }

   g_detectionCount = detected_count;
   g_lastDetectionTime = lastDetTime;
   g_needFullRefresh = false;

   UpdateStatsImmediate();
}

//+------------------------------------------------------------------+
//| Send Detection Alert                                             |
//+------------------------------------------------------------------+
void SendDetectionAlert(const string &orderType, const string &orderDirection,
                        double price, double zscore) {
   string message = StringFormat("Large Order Detected! %s %s @ %.5f (Z-Score: %.2f)",
                                 orderType, orderDirection, price, zscore);

   if(InpShowAlerts)
      Alert(message);

   if(InpSendNotification)
      SendNotification(message);

   if(InpPlaySound)
      PlaySound("alert2.wav");
}

#endif // ID_DETECTION_MQH
