//+------------------------------------------------------------------+
//| Class CBackTest                                                  |
//+------------------------------------------------------------------+
class CBacktest
  {
private:
   MqlRates          rates[];

public:
   int               currentCandleIndex;
   int               candleCount;
                     CBacktest();
                     CBacktest(datetime startTime,datetime endTime);
   void              NextCandle();
   void              CreateArrowCurrentCandle(datetime time, double price);
   void              PrintTimestamp();
   int               Gap();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBacktest::CBacktest()
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBacktest::CBacktest(datetime startTime,datetime endTime)
  {
   candleCount = 0;
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,_Period,startTime,endTime,rates);
   currentCandleIndex = copied;
   if(copied < 0)
      Print("Rates copie error");

   NextCandle();
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBacktest::Gap()
  {
   if(candleCount>3)
     {
      if(rates[currentCandleIndex+1].high < rates[currentCandleIndex+3].low)
        {
         return POSITION_TYPE_SELL;
        }

      if(rates[currentCandleIndex+1].low > rates[currentCandleIndex+3].high)
        {
         return POSITION_TYPE_BUY;
        }
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBacktest::NextCandle()
  {
   currentCandleIndex--;
   candleCount++;
   CreateArrowCurrentCandle(rates[currentCandleIndex].time, rates[currentCandleIndex].low);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBacktest::CreateArrowCurrentCandle(datetime time,double price)
  {
   if(!ObjectCreate(0,"CurrentCandle",OBJ_ARROW_BUY,0,time,price-price*0.0001))
     {
      Print(__FUNCTION__,
            ": failed to create \"Buy\" sign! Error code = ",GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBacktest::PrintTimestamp()
  {
   Print("Timestamp: ", rates[currentCandleIndex].time);
  }
//+------------------------------------------------------------------+
