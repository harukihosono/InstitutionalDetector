//+------------------------------------------------------------------+
//|                                     InstitutionalDetector.mq4   |
//|                              Institutional Order Detector       |
//|                              MQL4 Native Version                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.15"
#property description "Detects institutional order patterns"
#property strict

#property indicator_separate_window
#property indicator_buffers 6

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include "ID_Defines.mqh"
#include "ID_Inputs.mqh"
#include "ID_Globals.mqh"
#include "ID_Utils.mqh"
#include "ID_GUI.mqh"
#include "ID_Detection.mqh"

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit() {
   // Set indicator buffers
   SetIndexBuffer(0, VolumeBuffer);
   SetIndexBuffer(1, VolumeZScoreBuffer);
   SetIndexBuffer(2, SignalBuffer);
   SetIndexBuffer(3, ThresholdBuffer);
   SetIndexBuffer(4, VolumeMABuffer);
   SetIndexBuffer(5, VolumeStdBuffer);

   // Set drawing styles
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrDimGray);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 3, clrAqua);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 4, clrYellow);
   SetIndexStyle(3, DRAW_LINE, STYLE_DASH, 2, clrOrange);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);

   // Set labels
   SetIndexLabel(0, "Volume");
   SetIndexLabel(1, "Volume Z-Score");
   SetIndexLabel(2, "Large Order Signal");
   SetIndexLabel(3, "Threshold");
   SetIndexLabel(4, NULL);
   SetIndexLabel(5, NULL);

   // Set draw begin
   SetIndexDrawBegin(0, InpLookbackPeriod);
   SetIndexDrawBegin(1, InpLookbackPeriod);
   SetIndexDrawBegin(2, InpLookbackPeriod);
   SetIndexDrawBegin(3, InpLookbackPeriod);

   // Arrow code and empty value
   SetIndexArrow(2, 159);
   SetIndexEmptyValue(2, EMPTY_VALUE);

   // Indicator name and levels
   IndicatorShortName(INDICATOR_NAME + " (" + IntegerToString(InpLookbackPeriod) + ")");
   SetLevelValue(0, InpVolumeThreshold);
   SetLevelValue(1, -InpVolumeThreshold);

   // Initialize state
   g_currentThreshold = InpVolumeThreshold;
   g_detectAggressive = InpDetectAggressive;
   g_detectAbsorption = InpDetectAbsorption;
   g_detectIceberg = InpDetectIceberg;

   g_needFullRefresh = true;
   g_lastRatesTotal = 0;
   g_detectionCount = 0;
   g_lastDetectionTime = 0;

   CreateThresholdLine();
   CreateSimpleGUI();
   ObjectsDeleteAll(0, VLINE_PREFIX, -1, OBJ_VLINE);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   DeleteGUI();
   ObjectsDeleteAll(0, VLINE_PREFIX, -1, OBJ_VLINE);
   ObjectDelete(0, g_thresholdLineName);
}

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   if(rates_total < InpLookbackPeriod + 1)
      return(0);

   // MQL4: Set all arrays to time-series mode (index 0 = newest bar)
   // This matches MT4's default buffer behavior
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);

   // Buffers are already AsSeries=true by default after SetIndexBuffer in MQL4

   // Calculate limit - how far back to calculate
   int limit;
   if(prev_calculated == 0 || g_needFullRefresh) {
      // First run or full refresh: calculate all bars
      limit = rates_total - InpLookbackPeriod - 1;
      g_needFullRefresh = false;
      g_detectionCount = 0;
   } else {
      // Incremental update: only new bars
      limit = rates_total - prev_calculated;
   }

   // Ensure limit doesn't exceed available data
   if(limit > rates_total - InpLookbackPeriod - 1)
      limit = rates_total - InpLookbackPeriod - 1;

   // Guard against negative limit
   if(limit < 0)
      limit = 0;

   int local_detection_count = g_detectionCount;
   datetime local_last_detection = g_lastDetectionTime;

   // PASS 1: Calculate all buffers first (from oldest to newest)
   // This ensures VolumeZScoreBuffer is fully populated before detection
   for(int i = limit; i >= 0 && !IsStopped(); i--) {
      VolumeBuffer[i] = (double)tick_volume[i];

      double sum = 0.0, sum2 = 0.0;
      for(int j = 0; j < InpLookbackPeriod; j++) {
         double vol = (double)tick_volume[i + j];
         sum += vol;
         sum2 += vol * vol;
      }

      VolumeMABuffer[i] = sum / InpLookbackPeriod;
      double variance = (sum2 / InpLookbackPeriod) - (VolumeMABuffer[i] * VolumeMABuffer[i]);
      VolumeStdBuffer[i] = variance > 0 ? MathSqrt(variance) : 0.0001;

      VolumeZScoreBuffer[i] = (VolumeBuffer[i] - VolumeMABuffer[i]) / VolumeStdBuffer[i];
      ThresholdBuffer[i] = g_currentThreshold;
      SignalBuffer[i] = EMPTY_VALUE;
   }

   // PASS 2: Detection logic (now all buffers are calculated)
   for(int i = limit; i >= 0 && !IsStopped(); i--) {
      if(VolumeZScoreBuffer[i] > g_currentThreshold) {
         string orderType = "";
         string orderDirection = "";
         bool detected = false;

         // Need previous bar for price change (i+1 is older bar in AsSeries mode)
         if(i < rates_total - 1) {
            double priceChange = (close[i] - close[i + 1]) / close[i + 1];

            if(g_detectAggressive && MathAbs(priceChange) > InpPriceChangeThreshold * 3) {
               orderType = DETECT_TYPE_AGGRESSIVE;
               orderDirection = priceChange > 0 ? ORDER_DIR_BUY : ORDER_DIR_SELL;
               detected = true;
            }
            else if(g_detectAbsorption && MathAbs(priceChange) < InpPriceChangeThreshold) {
               orderType = DETECT_TYPE_ABSORPTION;
               orderDirection = ORDER_DIR_NEUTRAL;
               detected = true;
            }
            else if(g_detectIceberg && i + ICEBERG_LOOKBACK < rates_total) {
               bool isIceberg = true;
               for(int k = 1; k <= ICEBERG_LOOKBACK; k++) {
                  if(VolumeZScoreBuffer[i + k] < ICEBERG_MIN_ZSCORE) {
                     isIceberg = false;
                     break;
                  }
               }

               if(isIceberg) {
                  orderType = DETECT_TYPE_ICEBERG;
                  double closePosition = (high[i] - low[i]) > 0 ?
                     (close[i] - low[i]) / (high[i] - low[i]) : 0.5;
                  orderDirection = closePosition > ICEBERG_CLOSE_RATIO ? ORDER_DIR_BUY : ORDER_DIR_SELL;
                  detected = true;
               }
            }

            if(detected) {
               SignalBuffer[i] = VolumeZScoreBuffer[i];
               string lineName = GenerateLineName(i, time[i]);

               if(ObjectFind(0, lineName) < 0) {
                  ObjectCreate(0, lineName, OBJ_VLINE, 0, time[i], 0);

                  color lineColor;
                  if(orderType == DETECT_TYPE_ABSORPTION) {
                     lineColor = clrOrange;
                  } else if(orderDirection == ORDER_DIR_BUY) {
                     lineColor = clrLime;
                  } else {
                     lineColor = clrRed;
                  }
                  ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
                  ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
                  ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, lineName, OBJPROP_SELECTED, false);

                  string tooltip = StringFormat("%s %s\nZ-Score: %.2f\n%s",
                                                orderType, orderDirection,
                                                VolumeZScoreBuffer[i],
                                                TimeToString(time[i], TIME_DATE|TIME_MINUTES));
                  ObjectSetString(0, lineName, OBJPROP_TOOLTIP, tooltip);
               }

               local_detection_count++;
               local_last_detection = time[i];

               // Alert only for the most recent bar (index 0)
               if(i == 0 && time[i] != g_lastAlertTime) {
                  g_lastAlertTime = time[i];
                  SendDetectionAlert(orderType, orderDirection, close[i], VolumeZScoreBuffer[i]);
               }
            }
         }
      }
   }

   g_detectionCount = local_detection_count;
   g_lastDetectionTime = local_last_detection;
   UpdateStatsImmediate();

   return(rates_total);
}

//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {

   if(id == CHARTEVENT_OBJECT_CLICK) {

      if(sparam == g_btnUpName) {
         g_currentThreshold = ClampThreshold(g_currentThreshold + THRESHOLD_STEP);
         RefreshAllGUI();
         ObjectSetInteger(0, g_btnUpName, OBJPROP_STATE, false);
         ApplyThreshold();
      }

      else if(sparam == g_btnDownName) {
         g_currentThreshold = ClampThreshold(g_currentThreshold - THRESHOLD_STEP);
         RefreshAllGUI();
         ObjectSetInteger(0, g_btnDownName, OBJPROP_STATE, false);
         ApplyThreshold();
      }

      else if(sparam == g_btnApplyName) {
         string thresholdText = ObjectGetString(0, g_editThresholdName, OBJPROP_TEXT);
         double newThreshold = StringToDouble(thresholdText);
         g_currentThreshold = ClampThreshold(newThreshold);
         RefreshAllGUI();
         ApplyThreshold();
         ObjectSetInteger(0, g_btnApplyName, OBJPROP_STATE, false);
      }

      else if(sparam == g_btnResetName) {
         g_currentThreshold = InpVolumeThreshold;
         g_detectAggressive = InpDetectAggressive;
         g_detectAbsorption = InpDetectAbsorption;
         g_detectIceberg = InpDetectIceberg;
         RefreshAllGUI();
         ApplyThreshold();
         ObjectSetInteger(0, g_btnResetName, OBJPROP_STATE, false);
      }

      else if(sparam == g_chkAggressiveName) {
         g_detectAggressive = !g_detectAggressive;
         UpdateCheckboxes();
         ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_STATE, false);
         RefreshDetectionLines();
      }

      else if(sparam == g_chkAbsorptionName) {
         g_detectAbsorption = !g_detectAbsorption;
         UpdateCheckboxes();
         ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_STATE, false);
         RefreshDetectionLines();
      }

      else if(sparam == g_chkIcebergName) {
         g_detectIceberg = !g_detectIceberg;
         UpdateCheckboxes();
         ObjectSetInteger(0, g_chkIcebergName, OBJPROP_STATE, false);
         RefreshDetectionLines();
      }
   }

   if(id == CHARTEVENT_OBJECT_DRAG) {
      if(sparam == g_thresholdLineName) {
         g_currentThreshold = ObjectGetDouble(0, g_thresholdLineName, OBJPROP_PRICE, 0);
         g_currentThreshold = ClampThreshold(g_currentThreshold);
         RefreshAllGUI();
         ApplyThreshold();
      }
   }
}
//+------------------------------------------------------------------+
