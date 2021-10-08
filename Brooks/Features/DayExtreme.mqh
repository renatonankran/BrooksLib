//+------------------------------------------------------------------+
//|                                                   DayExtreme.mqh |
//|                                                              RNM |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "RNM"
#property link      "https://www.mql5.com"
#include <Dev\Brooks\Features\Structs\DayExtremeStruc.mqh>
#include <Trade\Trade.mqh>
OHLC ohlc;
double cur_lot = 1;
double tick_size;
int num_ticks = 1;
int num_positions = 0;
int num_candles = 1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDayExtreme
  {

public:
   int               m_signal_bar, m_stop_bar;
   bool              m_first_seam, m_seam;

   DayExtremeStruc   m_today_extreme;
   DayExtremeStruc   m_yest_extreme;

   CTrade            m_trade;

   void              CDayExtreme() {};
   void              Seam(int index, HILO hilo);
   void              SeamSide(bool seam);
   void              LastSidePosOpen();
   void              LastSideNoEntry();
   void              CancelOpenOrders();
   void              TrailEntry();
   double            EntryPrice();
   double            SL();
   double            TP();
   double            StopSize();
   void              PrintCl();

   void              OnTick();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::OnTick(void)
  {

   LastSidePosOpen();
   Seam(1, m_today_extreme.last_side);
   CancelOpenOrders();
   LastSideNoEntry();
   HILO last_side = m_today_extreme.last_side;

//Print("Orders: ", OrdersTotal());
//m_today_extreme.PrintStruc();

   if(candleCount > num_candles && new_candle)
     {
      if(m_seam || PositionsTotal() || OrdersTotal())
         m_today_extreme.StopFindingSide();
      else
         m_today_extreme.StopFindingSide(false);

      TrailEntry();


      if(m_seam && last_side == HIGH && !OrdersTotal() && !PositionsTotal())
        {
         m_trade.BuyStop(cur_lot, EntryPrice(), _Symbol, SL(), TP(),ORDER_TIME_GTC,0);
        }
      if(m_seam && last_side == LOW && !OrdersTotal() && !PositionsTotal())
        {
         m_trade.SellStop(cur_lot, EntryPrice(), _Symbol, SL(), TP(),ORDER_TIME_GTC,0);
        }
     }

   m_today_extreme.Load();
   //PrintCl();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::CancelOpenOrders(void)
  {
   if(OrdersTotal() > 0 && m_seam == false && m_first_seam == true)
      m_trade.OrderDelete(OrderGetTicket(0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::LastSideNoEntry(void)
  {
   if(!PositionsTotal() && OrdersTotal() && m_seam == false && m_first_seam == true)
     {
      m_first_seam = false;
      if(m_today_extreme.last_side == HIGH)
        {
         m_today_extreme.last_side = LOW;
         return;
        }

      if(m_today_extreme.last_side == LOW)
         m_today_extreme.last_side = HIGH;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::LastSidePosOpen()
  {
   int tmp = PositionsTotal();
   if(tmp > num_positions)
     {
      num_positions = tmp;
      m_first_seam = false;
      if(m_today_extreme.last_side == HIGH)
        {
         m_today_extreme.last_side = LOW;
         return;
        }

      if(m_today_extreme.last_side == LOW)
         m_today_extreme.last_side = HIGH;
     }
   if(tmp < num_positions)
     {
      num_positions = tmp;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayExtreme::StopSize()
  {
   if(m_today_extreme.last_side == HIGH)
     {
      return MathAbs(ohlc.iH(m_signal_bar) - m_today_extreme.GetDayMinBarLow());
     }
   if(m_today_extreme.last_side == LOW)
     {
      return MathAbs(ohlc.iL(m_signal_bar) - m_today_extreme.GetDayMaxBarHigh());
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayExtreme::TP()
  {
   if(m_today_extreme.last_side == HIGH)
     {
      return ohlc.iH(m_signal_bar) + StopSize();
     }
   if(m_today_extreme.last_side == LOW)
     {
      return ohlc.iL(m_signal_bar) - StopSize();
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayExtreme::SL()
  {
   if(m_today_extreme.last_side == HIGH)
     {
      return m_today_extreme.GetDayMinBarLow() - num_ticks * tick_size;
     }
   if(m_today_extreme.last_side == LOW)
     {
      return m_today_extreme.GetDayMaxBarHigh() + num_ticks * tick_size;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayExtreme::EntryPrice()
  {
   if(m_today_extreme.last_side == HIGH)
     {
      return iHigh(_Symbol, _Period, m_signal_bar) + tick_size;
     }
   if(m_today_extreme.last_side ==  LOW)
     {
      return iLow(_Symbol, _Period, m_signal_bar) - tick_size;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::TrailEntry(void)
  {
   if(OrdersTotal() > 0 && m_today_extreme.last_side == HIGH && LowerHigh(m_signal_bar))
     {
      m_trade.OrderModify(OrderGetTicket(0), EntryPrice(), SL(), TP(), ORDER_TIME_DAY, 0, TP());
     }
   if(OrdersTotal() > 0 && m_today_extreme.last_side == LOW && HigherLow(m_signal_bar))
     {
      m_trade.OrderModify(OrderGetTicket(0), EntryPrice(), SL(), TP(), ORDER_TIME_DAY, 0, TP());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::SeamSide(bool seam)
  {
   if(seam == true)
     {
      if(m_today_extreme.last_side == HIGH)
        {
         m_today_extreme.last_side = LOW;
         return;
        }

      if(m_today_extreme.last_side == LOW)
         m_today_extreme.last_side = HIGH;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::Seam(int index, HILO hilo)
  {
   if(hilo == LOW)
     {
      if(ohlc.iH(index) < m_today_extreme.highest_close && ohlc.iL(index) < m_today_extreme.highest_close)
        {
         m_signal_bar = -1;
         m_seam = false;
         return;
        }
      if(ohlc.iH(index) > m_today_extreme.GetDayMaxBarHigh() && ohlc.iL(index) > m_today_extreme.GetDayMaxBarHigh())
        {
         m_signal_bar = -1;
         m_seam =  false;
         return;
        }
      m_signal_bar = index;
      m_first_seam = true;
      m_seam =  true;
      return;
     }
   if(hilo == HIGH)
     {
      if(ohlc.iH(index) < m_today_extreme.GetDayMinBarLow() && ohlc.iL(index) < m_today_extreme.GetDayMinBarLow())
        {
         m_signal_bar = -1;
         m_seam =  false;
         return;
        }
      if(ohlc.iH(index) > m_today_extreme.lowest_close && ohlc.iL(index) > m_today_extreme.lowest_close)
        {
         m_signal_bar = -1;
         m_seam =  false;
         return;
        }
      m_signal_bar = index;
      m_first_seam = true;
      m_seam =  true;
      return;
     }
   m_signal_bar = -1;
   m_seam =  false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayExtreme::PrintCl(void)
  {
   Print("___________BEGIN____________");
   Print("m_seam: ", m_seam);
   Print("m_signal_bar: ", m_signal_bar);
   Print("m_stop_bar: ", m_stop_bar);
   m_today_extreme.PrintStruc();
  }
//+------------------------------------------------------------------+
