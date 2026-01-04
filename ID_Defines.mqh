//+------------------------------------------------------------------+
//|                                                   ID_Defines.mqh |
//|                              Institutional Order Detector        |
//|                              Platform Compatibility Defines      |
//+------------------------------------------------------------------+
#ifndef ID_DEFINES_MQH
#define ID_DEFINES_MQH

//+------------------------------------------------------------------+
//| Platform Detection                                               |
//+------------------------------------------------------------------+
#ifdef __MQL5__
   #define IS_MQL5
#else
   #define IS_MQL4
#endif

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define INDICATOR_NAME       "Institutional Detector"
#define VERSION             "1.12"

// Detection Types
#define DETECT_TYPE_AGGRESSIVE   "AGGRESSIVE"
#define DETECT_TYPE_ABSORPTION   "ABSORPTION"
#define DETECT_TYPE_ICEBERG      "ICEBERG"

// Order Direction
#define ORDER_DIR_BUY       "BUY"
#define ORDER_DIR_SELL      "SELL"
#define ORDER_DIR_NEUTRAL   "NEUTRAL"

// Object Name Prefix
#define OBJ_PREFIX          "Institutional"
#define VLINE_PREFIX        "InstitutionalVLine_"
#define THRESHOLD_LINE_NAME "ThresholdControlLine"

// Threshold Range
#define THRESHOLD_MIN       0.5
#define THRESHOLD_MAX       5.0
#define THRESHOLD_STEP      0.1

// Iceberg Detection
#define ICEBERG_LOOKBACK    3
#define ICEBERG_MIN_ZSCORE  1.5
#define ICEBERG_CLOSE_RATIO 0.6

#endif // ID_DEFINES_MQH
