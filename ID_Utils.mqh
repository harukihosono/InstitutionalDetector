//+------------------------------------------------------------------+
//|                                                     ID_Utils.mqh |
//|                              機関投資家検出インジケーター        |
//|                              ユーティリティ関数                  |
//+------------------------------------------------------------------+
#ifndef ID_UTILS_MQH
#define ID_UTILS_MQH

#include "ID_Defines.mqh"

//+------------------------------------------------------------------+
//| プラットフォーム互換関数                                          |
//+------------------------------------------------------------------+

// 現在価格取得
double GetCurrentPrice(bool isBid) {
#ifdef IS_MQL5
   return isBid ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
#else
   return isBid ? MarketInfo(Symbol(), MODE_BID) : MarketInfo(Symbol(), MODE_ASK);
#endif
}

// 小数点桁数取得
int GetDigits() {
#ifdef IS_MQL5
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
#else
   return Digits;
#endif
}

// ポイント値取得
double GetPoint() {
#ifdef IS_MQL5
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
#else
   return Point;
#endif
}

// シンボル名取得
string GetSymbol() {
#ifdef IS_MQL5
   return _Symbol;
#else
   return Symbol();
#endif
}

// 現在時刻取得
datetime GetCurrentTime() {
#ifdef IS_MQL5
   return TimeCurrent();
#else
   return TimeCurrent();
#endif
}

// バー数取得
int GetBarsCount() {
#ifdef IS_MQL5
   return Bars(GetSymbol(), PERIOD_CURRENT);
#else
   return Bars;
#endif
}

// サブウィンドウ検索
int GetWindowFind(string name) {
#ifdef IS_MQL5
   return ChartWindowFind(0, name);
#else
   return WindowFind(name);
#endif
}

//+------------------------------------------------------------------+
//| MQL4互換のための配列コピー関数                                    |
//+------------------------------------------------------------------+
#ifndef IS_MQL5

int CopyPriceSeries(double &dest[], int series_index, string symbol, int timeframe) {
   int bars = Bars;
   if(ArrayResize(dest, bars) != bars) return 0;

   for(int i = 0; i < bars; i++) {
      switch(series_index) {
         case MODE_OPEN:
            dest[i] = iOpen(symbol, timeframe, i);
            break;
         case MODE_HIGH:
            dest[i] = iHigh(symbol, timeframe, i);
            break;
         case MODE_LOW:
            dest[i] = iLow(symbol, timeframe, i);
            break;
         case MODE_CLOSE:
            dest[i] = iClose(symbol, timeframe, i);
            break;
         default:
            return 0;
      }
   }
   return bars;
}

int CopyTimeSeries(datetime &dest[], string symbol, int timeframe) {
   int bars = Bars;
   if(ArrayResize(dest, bars) != bars) return 0;

   for(int i = 0; i < bars; i++) {
      dest[i] = iTime(symbol, timeframe, i);
   }
   return bars;
}

#endif // !IS_MQL5

//+------------------------------------------------------------------+
//| 日本語判定関数                                                    |
//+------------------------------------------------------------------+
bool HasJapanese(string text) {
   for(int i = 0; i < StringLen(text); i++) {
      int charCode = StringGetCharacter(text, i);
      if((charCode >= 0x3040 && charCode <= 0x309F) ||  // ひらがな
         (charCode >= 0x30A0 && charCode <= 0x30FF) ||  // カタカナ
         (charCode >= 0x4E00 && charCode <= 0x9FAF)) {   // 漢字
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| 閾値の範囲チェック                                                |
//+------------------------------------------------------------------+
double ClampThreshold(double value) {
   if(value < THRESHOLD_MIN) return THRESHOLD_MIN;
   if(value > THRESHOLD_MAX) return THRESHOLD_MAX;
   return value;
}

//+------------------------------------------------------------------+
//| ライン名生成                                                      |
//+------------------------------------------------------------------+
string GenerateLineName(int index, datetime time) {
   return VLINE_PREFIX + IntegerToString(index) + "_" + TimeToString(time);
}

#endif // ID_UTILS_MQH
