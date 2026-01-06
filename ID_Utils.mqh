//+------------------------------------------------------------------+
//|                                                     ID_Utils.mqh |
//|                              Institutional Order Detector        |
//|                              Utility Functions                   |
//+------------------------------------------------------------------+
#ifndef ID_UTILS_MQH
#define ID_UTILS_MQH

#include "ID_Defines.mqh"

//+------------------------------------------------------------------+
//| Platform Compatible Functions                                    |
//+------------------------------------------------------------------+

double GetCurrentPrice(bool isBid) {
#ifdef IS_MQL5
   return isBid ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
#else
   return isBid ? MarketInfo(Symbol(), MODE_BID) : MarketInfo(Symbol(), MODE_ASK);
#endif
}

int GetDigits() {
#ifdef IS_MQL5
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
#else
   return Digits;
#endif
}

double GetPoint() {
#ifdef IS_MQL5
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
#else
   return Point;
#endif
}

string GetSymbol() {
#ifdef IS_MQL5
   return _Symbol;
#else
   return Symbol();
#endif
}

datetime GetCurrentTime() {
#ifdef IS_MQL5
   return TimeCurrent();
#else
   return TimeCurrent();
#endif
}

int GetBarsCount() {
#ifdef IS_MQL5
   return Bars(GetSymbol(), PERIOD_CURRENT);
#else
   return Bars;
#endif
}

int GetWindowFind(string name) {
#ifdef IS_MQL5
   return ChartWindowFind(0, name);
#else
   return WindowFind(name);
#endif
}

//+------------------------------------------------------------------+
//| MQL4 Compatible Array Copy Functions                             |
//| Returns arrays in AsSeries=true format (index 0 = newest bar)    |
//+------------------------------------------------------------------+
#ifndef IS_MQL5

int CopyPriceSeries(double &dest[], int series_index, string symbol, int timeframe) {
   int bars = Bars;
   if(ArrayResize(dest, bars) != bars) return 0;

   // Return in time-series order (0=newest) - matches iOpen/iClose/etc
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

   // Return in time-series order (0=newest) - matches iTime
   for(int i = 0; i < bars; i++) {
      dest[i] = iTime(symbol, timeframe, i);
   }
   return bars;
}

#endif // !IS_MQL5

//+------------------------------------------------------------------+
//| Japanese Character Detection                                     |
//+------------------------------------------------------------------+
bool HasJapanese(string text) {
   for(int i = 0; i < StringLen(text); i++) {
      int charCode = StringGetCharacter(text, i);
      if((charCode >= 0x3040 && charCode <= 0x309F) ||
         (charCode >= 0x30A0 && charCode <= 0x30FF) ||
         (charCode >= 0x4E00 && charCode <= 0x9FAF)) {
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Threshold Range Check                                            |
//+------------------------------------------------------------------+
double ClampThreshold(double value) {
   if(value < THRESHOLD_MIN) return THRESHOLD_MIN;
   if(value > THRESHOLD_MAX) return THRESHOLD_MAX;
   return value;
}

//+------------------------------------------------------------------+
//| Generate Line Name                                               |
//| Note: Uses time only (not index) because index shifts in AsSeries|
//+------------------------------------------------------------------+
string GenerateLineName(int index, datetime time) {
   // Use time only - index shifts when new bars are added in AsSeries mode
   return VLINE_PREFIX + TimeToString(time, TIME_DATE|TIME_MINUTES);
}

#endif // ID_UTILS_MQH
