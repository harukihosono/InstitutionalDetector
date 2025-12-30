//+------------------------------------------------------------------+
//|                                                   ID_Globals.mqh |
//|                              Institutional Order Detector        |
//|                              Global Variables and Buffers        |
//+------------------------------------------------------------------+
#ifndef ID_GLOBALS_MQH
#define ID_GLOBALS_MQH

#include "ID_Defines.mqh"

//+------------------------------------------------------------------+
//| UI Font Settings                                                 |
//+------------------------------------------------------------------+
string FontName = "Segoe UI";
string JpFontName = "Yu Gothic UI";
string FontNameBold = "Segoe UI Semibold";
string JpFontNameBold = "Yu Gothic UI Semibold";

//+------------------------------------------------------------------+
//| Indicator Buffers                                                |
//+------------------------------------------------------------------+
double VolumeBuffer[];
double VolumeZScoreBuffer[];
double SignalBuffer[];
double ThresholdBuffer[];
double VolumeMABuffer[];
double VolumeStdBuffer[];

//+------------------------------------------------------------------+
//| Runtime State Variables                                          |
//+------------------------------------------------------------------+
datetime g_lastAlertTime = 0;
int      g_detectionCount = 0;
double   g_currentThreshold = 0.0;

// Detection Type On/Off
bool g_detectAggressive = true;
bool g_detectAbsorption = true;
bool g_detectIceberg = true;

//+------------------------------------------------------------------+
//| Performance Cache                                                |
//+------------------------------------------------------------------+
bool     g_needFullRefresh = true;
int      g_lastRatesTotal = 0;
datetime g_lastDetectionTime = 0;
bool     g_isProcessing = false;

//+------------------------------------------------------------------+
//| GUI Control Names                                                |
//+------------------------------------------------------------------+
string g_thresholdLineName = THRESHOLD_LINE_NAME;

// Buttons
string g_btnApplyName = "BtnApply";
string g_btnResetName = "BtnReset";
string g_btnUpName = "BtnUp";
string g_btnDownName = "BtnDown";

// Edit Field
string g_editThresholdName = "EditThreshold";

// Checkboxes
string g_chkAggressiveName = "ChkAggressive";
string g_chkAbsorptionName = "ChkAbsorption";
string g_chkIcebergName = "ChkIceberg";

// Labels
string g_lblThresholdName = "LblThreshold";
string g_lblDetectionName = "LblDetection";
string g_lblStatsName = "LblStats";
string g_lblCountName = "LblCount";
string g_lblLastName = "LblLast";

#endif // ID_GLOBALS_MQH
