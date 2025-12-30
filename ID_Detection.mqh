//+------------------------------------------------------------------+
//|                                                 ID_Detection.mqh |
//|                              機関投資家検出インジケーター        |
//|                              検出ロジック（最適化版）            |
//+------------------------------------------------------------------+
#ifndef ID_DETECTION_MQH
#define ID_DETECTION_MQH

#include "ID_Defines.mqh"
#include "ID_Globals.mqh"
#include "ID_Utils.mqh"
#include "ID_GUI.mqh"

//+------------------------------------------------------------------+
//| 操作可能な閾値ライン作成                                          |
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
      ObjectSetString(0, g_thresholdLineName, OBJPROP_TOOLTIP, "ドラッグして閾値を調整");
   }
}

//+------------------------------------------------------------------+
//| 閾値を即座に適用（高速版）                                        |
//+------------------------------------------------------------------+
void ApplyThreshold() {
   if(g_isProcessing) return;
   g_isProcessing = true;

   // 閾値ラインを更新
   if(ObjectFind(0, g_thresholdLineName) >= 0) {
      ObjectSetDouble(0, g_thresholdLineName, OBJPROP_PRICE, g_currentThreshold);
   } else {
      CreateThresholdLine();
   }

   // インジケーターレベルを更新
#ifdef IS_MQL5
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, g_currentThreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -g_currentThreshold);
#else
   SetLevelValue(0, g_currentThreshold);
   SetLevelValue(1, -g_currentThreshold);
#endif

   // 全体再描画フラグを立てる
   g_needFullRefresh = true;

   // 縦線の再スキャン
   RefreshDetectionLines();

   g_isProcessing = false;
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| 注文タイプを判定（インライン最適化）                              |
//+------------------------------------------------------------------+
int DetectOrderTypeFast(int i, double priceChange, double closePos,
                        string &orderType, string &orderDirection) {
   // アグレッシブ注文検出
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

   // 吸収注文検出
   if(g_detectAbsorption) {
      if(MathAbs(priceChange) < InpPriceChangeThreshold) {
         orderType = DETECT_TYPE_ABSORPTION;
         // 方向は後で決定（次の足を見る必要がある）
         return 2;
      }
   }

   // アイスバーグ注文検出
   if(g_detectIceberg && i >= ICEBERG_LOOKBACK) {
      bool isIceberg = true;
      for(int k = 1; k <= ICEBERG_LOOKBACK; k++) {
         if(i-k < 0 || VolumeZScoreBuffer[i-k] < ICEBERG_MIN_ZSCORE) {
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
//| 検出ラインを高速作成                                              |
//+------------------------------------------------------------------+
void CreateDetectionLineFast(datetime time, color clr, const string &tooltip) {
   static int lineIndex = 0;
   string lineName = VLINE_PREFIX + IntegerToString(lineIndex++);

   if(!ObjectCreate(0, lineName, OBJ_VLINE, 0, time, 0)) return;

   ObjectSetInteger(0, lineName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, lineName, OBJPROP_TOOLTIP, tooltip);
}

//+------------------------------------------------------------------+
//| 検出ラインの再スキャン（最適化版）                                |
//+------------------------------------------------------------------+
void RefreshDetectionLines() {
   if(g_isProcessing && !g_needFullRefresh) return;

   // 既存の縦線を一括削除
   ObjectsDeleteAll(0, VLINE_PREFIX, -1, OBJ_VLINE);

   int rates_total = GetBarsCount();
   if(rates_total <= InpLookbackPeriod) return;

   int bufferSize = ArraySize(VolumeZScoreBuffer);
   if(bufferSize <= InpLookbackPeriod) return;

   // 価格データを一度だけコピー
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

   // 配列を古い順に変換
   ArraySetAsSeries(time, false);
   ArraySetAsSeries(close, false);
   ArraySetAsSeries(high, false);
   ArraySetAsSeries(low, false);

   int detected_count = 0;
   datetime lastDetTime = 0;
   int lineIdx = 0;

   // 検出ループ（最適化）
   int startIdx = InpLookbackPeriod;
   int endIdx = MathMin(copyCount, bufferSize);

   for(int i = startIdx; i < endIdx; i++) {
      double zscore = VolumeZScoreBuffer[i];
      if(zscore <= g_currentThreshold) continue;

      if(i <= 0 || i >= ArraySize(close)) continue;

      double priceChange = (close[i] - close[i-1]) / close[i-1];
      double closePos = 0.5;
      if(high[i] - low[i] > 0) {
         closePos = (close[i] - low[i]) / (high[i] - low[i]);
      }

      string orderType = "";
      string orderDirection = "";

      int detectResult = DetectOrderTypeFast(i, priceChange, closePos, orderType, orderDirection);
      if(detectResult == 0) continue;

      // 吸収注文の方向を決定
      if(detectResult == 2) {
         if(i < ArraySize(close) - 1) {
            double nextChange = close[i+1] - close[i];
            orderDirection = nextChange > 0 ? ORDER_DIR_BUY : ORDER_DIR_SELL;
         } else {
            continue; // 次の足がない場合はスキップ
         }
      }

      // ライン作成
      color lineColor = (orderDirection == ORDER_DIR_BUY) ? clrLime : clrRed;
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

   // 統計を即座に更新
   g_detectionCount = detected_count;
   g_lastDetectionTime = lastDetTime;
   g_needFullRefresh = false;

   // GUI表示を更新
   UpdateStatsImmediate();
}

//+------------------------------------------------------------------+
//| アラート送信                                                      |
//+------------------------------------------------------------------+
void SendDetectionAlert(const string &orderType, const string &orderDirection,
                        double price, double zscore) {
   string message = StringFormat("大口注文検出！ %s %s @ %.5f (Z-Score: %.2f)",
                                 orderType, orderDirection, price, zscore);

   if(InpShowAlerts)
      Alert(message);

   if(InpSendNotification)
      SendNotification(message);

   if(InpPlaySound)
      PlaySound("alert2.wav");
}

#endif // ID_DETECTION_MQH
