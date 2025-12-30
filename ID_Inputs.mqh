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
   input string   Separator0 = "--------------------------------";  // === Basic Settings ===
#endif
input int      InpLookbackPeriod = 20;           // Lookback Period
input double   InpVolumeThreshold = 2.0;         // Volume Threshold (sigma)
input double   InpPriceChangeThreshold = 0.0001; // Price Change Threshold

#ifdef IS_MQL5
   input group "検出設定"
#else
   input string   Separator1 = "--------------------------------";  // === Detection Settings ===
#endif
input bool     InpDetectAggressive = true;       // Detect Aggressive Orders
input bool     InpDetectAbsorption = true;       // Detect Absorption Orders
input bool     InpDetectIceberg = true;          // Detect Iceberg Orders

#ifdef IS_MQL5
   input group "アラート設定"
#else
   input string   Separator2 = "--------------------------------";  // === Alert Settings ===
#endif
input bool     InpShowAlerts = true;             // Show Alerts
input bool     InpSendNotification = false;      // Push Notification
input bool     InpPlaySound = true;              // Play Sound

#endif // ID_INPUTS_MQH
