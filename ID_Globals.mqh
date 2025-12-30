//+------------------------------------------------------------------+
//|                                                   ID_Globals.mqh |
//|                              機関投資家検出インジケーター        |
//|                              グローバル変数・バッファ定義        |
//+------------------------------------------------------------------+
#ifndef ID_GLOBALS_MQH
#define ID_GLOBALS_MQH

#include "ID_Defines.mqh"

//+------------------------------------------------------------------+
//| UIフォント設定                                                    |
//+------------------------------------------------------------------+
string FontName = "Segoe UI";
string JpFontName = "Yu Gothic UI";
string FontNameBold = "Segoe UI Semibold";
string JpFontNameBold = "Yu Gothic UI Semibold";

//+------------------------------------------------------------------+
//| インジケーターバッファ                                            |
//+------------------------------------------------------------------+
double VolumeBuffer[];        // ボリュームデータ
double VolumeZScoreBuffer[];  // Zスコア
double SignalBuffer[];        // シグナル（矢印）
double ThresholdBuffer[];     // 閾値ライン
double VolumeMABuffer[];      // 移動平均（計算用）
double VolumeStdBuffer[];     // 標準偏差（計算用）

//+------------------------------------------------------------------+
//| ランタイム状態変数                                                |
//+------------------------------------------------------------------+
datetime g_lastAlertTime = 0;       // 最後のアラート時刻
int      g_detectionCount = 0;      // 検出カウント
double   g_currentThreshold = 0.0;  // 現在の閾値

// 検出タイプのオン/オフ状態
bool g_detectAggressive = true;
bool g_detectAbsorption = true;
bool g_detectIceberg = true;

//+------------------------------------------------------------------+
//| パフォーマンス用キャッシュ                                        |
//+------------------------------------------------------------------+
bool     g_needFullRefresh = true;  // 全体再描画が必要
int      g_lastRatesTotal = 0;      // 前回のバー数
datetime g_lastDetectionTime = 0;   // 最終検出時刻（表示用）
bool     g_isProcessing = false;    // 処理中フラグ（二重処理防止）

//+------------------------------------------------------------------+
//| GUIコントロール名                                                 |
//+------------------------------------------------------------------+
// 閾値ライン
string g_thresholdLineName = THRESHOLD_LINE_NAME;

// ボタン
string g_btnApplyName = "BtnApply";
string g_btnResetName = "BtnReset";
string g_btnUpName = "BtnUp";
string g_btnDownName = "BtnDown";

// 入力フィールド
string g_editThresholdName = "EditThreshold";

// チェックボックス
string g_chkAggressiveName = "ChkAggressive";
string g_chkAbsorptionName = "ChkAbsorption";
string g_chkIcebergName = "ChkIceberg";

// ラベル
string g_lblThresholdName = "LblThreshold";
string g_lblDetectionName = "LblDetection";
string g_lblStatsName = "LblStats";
string g_lblCountName = "LblCount";
string g_lblLastName = "LblLast";

#endif // ID_GLOBALS_MQH
