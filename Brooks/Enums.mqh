//+------------------------------------------------------------------+
//|                                                 AlwaysInEnum.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
enum ALWAYS_IN
  {
   ALWAYS_IN_LONG=0,
   ALWAYS_IN_SHORT,
   ALWAYS_IN_RANGE
  };

enum MICRO_CHANNEL {
   BULL_MC=0,
   BEAR_MC,
   NO_CHANNEL
};

enum PULLBACK {
   BEAR_PB = 0,
   BULL_PB,
   NO_PB
};

enum HIGHCOUNT {
H_1 = 1,
   H_2,
   H_3,
   H_4,
   H_5
};
enum LOWCOUNT {
   L_1=1,
   L_2,
   L_3,
   L_4,
   L_5
};

enum MINMAX {
   MIN,
   MAX
};