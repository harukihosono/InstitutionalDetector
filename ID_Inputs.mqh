//+------------------------------------------------------------------+
//|                                                    ID_Inputs.mqh |
//|                              Institutional Order Detector        |
//|                              Input Parameters                    |
//+------------------------------------------------------------------+
#ifndef ID_INPUTS_MQH
#define ID_INPUTS_MQH

#include "ID_Defines.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
#ifdef IS_MQL5
   input group "基本設定"
#else
   input string   Separator0 = "════════════════════════════════";  // ═══ 基本設定 ═══
#endif
input int      InpLookbackPeriod = 20;           // 参照期間
input double   InpVolumeThreshold = 2.0;         // ボリューム閾値（σ）
input double   InpPriceChangeThreshold = 0.0001; // 価格変動閾値

#ifdef IS_MQL5
   input group "検出設定"
#else
   input string   Separator1 = "════════════════════════════════";  // ═══ 検出設定 ═══
#endif
input bool     InpDetectAggressive = true;       // アグレッシブ注文検出
input bool     InpDetectAbsorption = true;       // 吸収注文検出
input bool     InpDetectIceberg = true;          // アイスバーグ注文検出

#ifdef IS_MQL5
   input group "アラート設定"
#else
   input string   Separator2 = "════════════════════════════════";  // ═══ アラート設定 ═══
#endif
input bool     InpShowAlerts = true;             // アラート表示
input bool     InpSendNotification = false;      // プッシュ通知
input bool     InpPlaySound = true;              // サウンド再生

#endif // ID_INPUTS_MQH
