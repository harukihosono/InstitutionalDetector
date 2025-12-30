//+------------------------------------------------------------------+
//|                                                   ID_Defines.mqh |
//|                              機関投資家検出インジケーター        |
//|                              プラットフォーム互換性定義          |
//+------------------------------------------------------------------+
#ifndef ID_DEFINES_MQH
#define ID_DEFINES_MQH

//+------------------------------------------------------------------+
//| プラットフォーム判定                                              |
//+------------------------------------------------------------------+
#ifdef __MQL5__
   #define IS_MQL5
#else
   #define IS_MQL4
#endif

//+------------------------------------------------------------------+
//| 共通定数                                                          |
//+------------------------------------------------------------------+
#define INDICATOR_NAME       "Institutional Detector"
#define VERSION             "1.10"

// 検出タイプ
#define DETECT_TYPE_AGGRESSIVE   "AGGRESSIVE"
#define DETECT_TYPE_ABSORPTION   "ABSORPTION"
#define DETECT_TYPE_ICEBERG      "ICEBERG"

// 注文方向
#define ORDER_DIR_BUY       "BUY"
#define ORDER_DIR_SELL      "SELL"
#define ORDER_DIR_NEUTRAL   "NEUTRAL"

// オブジェクト名プレフィックス
#define OBJ_PREFIX          "Institutional"
#define VLINE_PREFIX        "InstitutionalVLine_"
#define THRESHOLD_LINE_NAME "ThresholdControlLine"

// 閾値の範囲
#define THRESHOLD_MIN       0.5
#define THRESHOLD_MAX       5.0
#define THRESHOLD_STEP      0.1

// アイスバーグ検出用
#define ICEBERG_LOOKBACK    3
#define ICEBERG_MIN_ZSCORE  1.5
#define ICEBERG_CLOSE_RATIO 0.6

#endif // ID_DEFINES_MQH
