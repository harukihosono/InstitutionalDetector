//+------------------------------------------------------------------+
//|                                                       ID_GUI.mqh |
//|                              機関投資家検出インジケーター        |
//|                              GUI関連関数                         |
//+------------------------------------------------------------------+
#ifndef ID_GUI_MQH
#define ID_GUI_MQH

#include "ID_Defines.mqh"
#include "ID_Globals.mqh"

//+------------------------------------------------------------------+
//| シンプルGUIパネル作成                                             |
//+------------------------------------------------------------------+
void CreateSimpleGUI() {
   int x = 10;
   int y = 30;

   // 閾値ラベル
   ObjectCreate(0, g_lblThresholdName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblThresholdName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_lblThresholdName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, g_lblThresholdName, OBJPROP_TEXT, "閾値設定:");
   ObjectSetString(0, g_lblThresholdName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_lblThresholdName, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, g_lblThresholdName, OBJPROP_COLOR, clrWhite);

   // 閾値エディット
   y += 25;
   ObjectCreate(0, g_editThresholdName, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_XSIZE, 60);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, g_editThresholdName, OBJPROP_TEXT, DoubleToString(g_currentThreshold, 1));
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetString(0, g_editThresholdName, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, g_editThresholdName, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, g_editThresholdName, OBJPROP_TOOLTIP, "検出用の閾値を直接入力\n標準偏差の倍率（推奨：1.5-3.0）");

   // 上ボタン
   ObjectCreate(0, g_btnUpName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_XDISTANCE, x + 65);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_XSIZE, 22);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_YSIZE, 11);
   ObjectSetString(0, g_btnUpName, OBJPROP_TEXT, "▲");
   ObjectSetInteger(0, g_btnUpName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_BGCOLOR, clrSilver);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetString(0, g_btnUpName, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, g_btnUpName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, g_btnUpName, OBJPROP_TOOLTIP, "閾値を0.1上げる");

   // 下ボタン
   ObjectCreate(0, g_btnDownName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_XDISTANCE, x + 65);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_YDISTANCE, y + 11);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_XSIZE, 22);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_YSIZE, 11);
   ObjectSetString(0, g_btnDownName, OBJPROP_TEXT, "▼");
   ObjectSetInteger(0, g_btnDownName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_BGCOLOR, clrSilver);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetString(0, g_btnDownName, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, g_btnDownName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, g_btnDownName, OBJPROP_TOOLTIP, "閾値を0.1下げる");

   // 適用ボタン
   ObjectCreate(0, g_btnApplyName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_XDISTANCE, x + 92);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, g_btnApplyName, OBJPROP_TEXT, "適用");
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_BGCOLOR, clrLime);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_BORDER_COLOR, clrGreen);
   ObjectSetString(0, g_btnApplyName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_btnApplyName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_btnApplyName, OBJPROP_TOOLTIP, "入力した閾値を適用する");

   // リセットボタン
   ObjectCreate(0, g_btnResetName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_XDISTANCE, x + 147);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_XSIZE, 55);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, g_btnResetName, OBJPROP_TEXT, "リセット");
   ObjectSetInteger(0, g_btnResetName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_BGCOLOR, clrRed);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_BORDER_COLOR, clrDarkRed);
   ObjectSetString(0, g_btnResetName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_btnResetName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_btnResetName, OBJPROP_TOOLTIP, "すべての設定をデフォルト値に戻す");

   // 検出タイプラベル
   y += 35;
   ObjectCreate(0, g_lblDetectionName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblDetectionName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_lblDetectionName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, g_lblDetectionName, OBJPROP_TEXT, "検出タイプ:");
   ObjectSetString(0, g_lblDetectionName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_lblDetectionName, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, g_lblDetectionName, OBJPROP_COLOR, clrWhite);

   // チェックボックス（アグレッシブ）
   y += 25;
   ObjectCreate(0, g_chkAggressiveName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_XSIZE, 160);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_YSIZE, 22);
#ifdef IS_MQL5
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_TEXT, (g_detectAggressive ? "☑" : "☐") + " アグレッシブ注文");
#else
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_TEXT, (g_detectAggressive ? "[X]" : "[ ]") + " アグレッシブ注文");
#endif
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_BGCOLOR, g_detectAggressive ? clrLightGreen : clrLightGray);
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_TOOLTIP, "価格変動を伴う大きなボリュームを検出\n市場に大きな影響を与える注文タイプ");

   // チェックボックス（吸収）
   y += 25;
   ObjectCreate(0, g_chkAbsorptionName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_XSIZE, 160);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_YSIZE, 22);
#ifdef IS_MQL5
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_TEXT, (g_detectAbsorption ? "☑" : "☐") + " 吸収注文");
#else
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_TEXT, (g_detectAbsorption ? "[X]" : "[ ]") + " 吸収注文");
#endif
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_BGCOLOR, g_detectAbsorption ? clrLightGreen : clrLightGray);
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_TOOLTIP, "価格変動を抑える大きなボリュームを検出\n売り圧力を吸収する受動的な注文タイプ");

   // チェックボックス（アイスバーグ）
   y += 25;
   ObjectCreate(0, g_chkIcebergName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_XSIZE, 160);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_YSIZE, 22);
#ifdef IS_MQL5
   ObjectSetString(0, g_chkIcebergName, OBJPROP_TEXT, (g_detectIceberg ? "☑" : "☐") + " アイスバーグ注文");
#else
   ObjectSetString(0, g_chkIcebergName, OBJPROP_TEXT, (g_detectIceberg ? "[X]" : "[ ]") + " アイスバーグ注文");
#endif
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_BGCOLOR, g_detectIceberg ? clrLightGreen : clrLightGray);
   ObjectSetString(0, g_chkIcebergName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, g_chkIcebergName, OBJPROP_TOOLTIP, "連続する大きなボリュームのパターンを検出\n大口注文を分割して執行する隠密タイプ");

   // 統計情報ラベル
   y += 35;
   ObjectCreate(0, g_lblStatsName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblStatsName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_lblStatsName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, g_lblStatsName, OBJPROP_TEXT, "統計情報:");
   ObjectSetString(0, g_lblStatsName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_lblStatsName, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, g_lblStatsName, OBJPROP_COLOR, clrWhite);

   // 検出数
   y += 25;
   ObjectCreate(0, g_lblCountName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblCountName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_lblCountName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, g_lblCountName, OBJPROP_TEXT, "検出数: 0");
   ObjectSetString(0, g_lblCountName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_lblCountName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, g_lblCountName, OBJPROP_COLOR, clrAqua);

   // 最終検出
   y += 20;
   ObjectCreate(0, g_lblLastName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblLastName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_lblLastName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, g_lblLastName, OBJPROP_TEXT, "最終検出: -");
   ObjectSetString(0, g_lblLastName, OBJPROP_FONT, JpFontName);
   ObjectSetInteger(0, g_lblLastName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, g_lblLastName, OBJPROP_COLOR, clrAqua);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| GUI削除                                                           |
//+------------------------------------------------------------------+
void DeleteGUI() {
   ObjectDelete(0, g_btnApplyName);
   ObjectDelete(0, g_btnResetName);
   ObjectDelete(0, g_btnUpName);
   ObjectDelete(0, g_btnDownName);
   ObjectDelete(0, g_editThresholdName);
   ObjectDelete(0, g_chkAggressiveName);
   ObjectDelete(0, g_chkAbsorptionName);
   ObjectDelete(0, g_chkIcebergName);
   ObjectDelete(0, g_lblThresholdName);
   ObjectDelete(0, g_lblDetectionName);
   ObjectDelete(0, g_lblStatsName);
   ObjectDelete(0, g_lblCountName);
   ObjectDelete(0, g_lblLastName);
}

//+------------------------------------------------------------------+
//| チェックボックスの表示更新                                        |
//+------------------------------------------------------------------+
void UpdateCheckboxes() {
   // アグレッシブ
#ifdef IS_MQL5
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_TEXT, (g_detectAggressive ? "☑" : "☐") + " アグレッシブ注文");
#else
   ObjectSetString(0, g_chkAggressiveName, OBJPROP_TEXT, (g_detectAggressive ? "[X]" : "[ ]") + " アグレッシブ注文");
#endif
   ObjectSetInteger(0, g_chkAggressiveName, OBJPROP_BGCOLOR, g_detectAggressive ? clrLightGreen : clrLightGray);

   // 吸収
#ifdef IS_MQL5
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_TEXT, (g_detectAbsorption ? "☑" : "☐") + " 吸収注文");
#else
   ObjectSetString(0, g_chkAbsorptionName, OBJPROP_TEXT, (g_detectAbsorption ? "[X]" : "[ ]") + " 吸収注文");
#endif
   ObjectSetInteger(0, g_chkAbsorptionName, OBJPROP_BGCOLOR, g_detectAbsorption ? clrLightGreen : clrLightGray);

   // アイスバーグ
#ifdef IS_MQL5
   ObjectSetString(0, g_chkIcebergName, OBJPROP_TEXT, (g_detectIceberg ? "☑" : "☐") + " アイスバーグ注文");
#else
   ObjectSetString(0, g_chkIcebergName, OBJPROP_TEXT, (g_detectIceberg ? "[X]" : "[ ]") + " アイスバーグ注文");
#endif
   ObjectSetInteger(0, g_chkIcebergName, OBJPROP_BGCOLOR, g_detectIceberg ? clrLightGreen : clrLightGray);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| 統計更新                                                          |
//+------------------------------------------------------------------+
void UpdateStats() {
   ObjectSetString(0, g_lblCountName, OBJPROP_TEXT, "検出数: " + IntegerToString(g_detectionCount));

   string lastTime = g_lastAlertTime > 0 ? TimeToString(g_lastAlertTime, TIME_MINUTES) : "-";
   ObjectSetString(0, g_lblLastName, OBJPROP_TEXT, "最終検出: " + lastTime);
}

//+------------------------------------------------------------------+
//| 統計を即座に更新（高速版・ChartRedraw付き）                       |
//+------------------------------------------------------------------+
void UpdateStatsImmediate() {
   // 検出数を更新
   string countText = "検出数: " + IntegerToString(g_detectionCount);
   ObjectSetString(0, g_lblCountName, OBJPROP_TEXT, countText);

   // 最終検出時刻を更新（g_lastDetectionTimeを使用）
   string lastTime = "-";
   if(g_lastDetectionTime > 0) {
      lastTime = TimeToString(g_lastDetectionTime, TIME_MINUTES);
      g_lastAlertTime = g_lastDetectionTime; // 同期
   } else if(g_lastAlertTime > 0) {
      lastTime = TimeToString(g_lastAlertTime, TIME_MINUTES);
   }
   ObjectSetString(0, g_lblLastName, OBJPROP_TEXT, "最終検出: " + lastTime);

   // 即座に画面更新
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| 閾値入力フィールドを更新                                          |
//+------------------------------------------------------------------+
void UpdateThresholdEdit() {
   ObjectSetString(0, g_editThresholdName, OBJPROP_TEXT, DoubleToString(g_currentThreshold, 1));
}

//+------------------------------------------------------------------+
//| 全GUI要素を即座に更新                                             |
//+------------------------------------------------------------------+
void RefreshAllGUI() {
   UpdateThresholdEdit();
   UpdateCheckboxes();
   UpdateStatsImmediate();
}

#endif // ID_GUI_MQH
