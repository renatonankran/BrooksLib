//+------------------------------------------------------------------+
//|                                               AssistantPanel.mqh |
//|                                                              RNM |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "RNM"
#property link      "https://www.mql5.com"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\RadioGroup.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh>
#include <Dev\Assistente\Coordinates.mqh>
#include <Dev\Brooks\Utils.mqh>
#include <Trade\Trade.mqh>
#include <Dev\Brooks\Features\FeaturesUtils.mqh>
OHLC _;
//+------------------------------------------------------------------+
//| Resources                                                        |
//+------------------------------------------------------------------+
#resource "\\Include\\Controls\\res\\RadioButtonOn.bmp"
#resource "\\Include\\Controls\\res\\RadioButtonOff.bmp"
#resource "\\Include\\Controls\\res\\CheckBoxOn.bmp"
#resource "\\Include\\Controls\\res\\CheckBoxOff.bmp"

//+------------------------------------------------------------------+
//| ENUMs                                                            |
//+------------------------------------------------------------------+
enum label_align
  {
   left = -1,
   right = 1,
   center = 0
  };

double tick_size;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAssistantPanel : public CAppDialog
  {

public:

#define  Y_STEP   (int)(ClientAreaHeight()/18/4)
#define  Y_WIDTH  (int)(ClientAreaHeight()/18)
#define  BORDER   (int)(ClientAreaHeight()/24)

   double            m_cur_lot,
                     m_min_alert,
                     m_max_alert,
                     m_order_entry_price,
                     m_order_sl,
                     m_edge_mark_price,
                     m_signal_mark_price,
                     m_stop_mark_price,
                     m_last_edge_min,
                     m_last_edge_max;

   datetime          m_stop_bar_time,
                     m_signal_bar_time,
                     m_edge_bar_time;

   int               m_stop_bar_offset,
                     m_signal_bar_offset,
                     m_stop_ticks,
                     m_entry_direction,
                     m_edge_bar_offset,
                     m_signal;

   bool              m_next_bar_flag,
                     m_trail_signal_bar,
                     m_nxt_bar_reset;

   CTrade            m_trade;

   CButton           m_nxt_bar_btn;
   CButton           m_cancel_btn;
   CButton           m_last_bar_btn;

   CChartObjectText  m_edge_mark;
   CChartObjectText  m_signal_bar_mark;
   CChartObjectText  m_stop_bar_mark;

   CChartObjectArrow  m_edge_arrow;
   CChartObjectArrow  m_signal_bar_arrow;
   CChartObjectArrow  m_stop_bar_arrow;

   CBmpButton        m_up_btn;
   CBmpButton        m_down_btn;
   CBmpButton        m_both_btn;

   CRadioGroup       m_direction_radio;

   CEdit             m_stop_bar_time_edit;
   CEdit             m_stop_bar_offset_edit;
   CEdit             m_signal_bar_time_edit;
   CEdit             m_signal_bar_offset_edit;
   CEdit             m_stop_ticks_edit;
   CEdit             m_lots_edit;
   CEdit             m_min_edit;
   CEdit             m_max_edit;

   CLabel            m_up_label;
   CLabel            m_down_label;
   CLabel            m_both_label;
   CLabel            m_neutral_label;
   CLabel            m_signal_bar_label;
   CLabel            m_signal_bar_n_label;
   CLabel            m_stop_bar_label;
   CLabel            m_stop_bar_n_label;
   CLabel            m_stop_ticks_label;
   CLabel            m_lots_label;
   CLabel            m_min_alert_label;
   CLabel            m_max_alert_label;
   CLabel            m_total_points_label;
   CLabel            m_num_stops_label;
   CLabel            m_num_gains_label;
   CLabel            m_max_stop_label;
   CLabel            m_nxt_bar_on_off_label;




   string            m_stop_bar_edit_name;

                     CAssistantPanel(): m_stop_ticks(1),
                     m_cur_lot(1),
                     m_next_bar_flag(false),
                     m_last_edge_min(999999),
                     m_last_edge_max(0),
                     m_signal(WRONG_VALUE) {}

                    ~CAssistantPanel() {}

   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   bool              CreateNxtBarBtn(void);
   bool              CreateStopBarEdit(void);

   bool              CreateLabel(const long chart, const int subwindow, CLabel &object, const string text, const uint x, const uint y, label_align align);
   bool              CreateButton(const long chart, const int subwindow, CButton &object, const string text, const uint x, const uint y, const uint x_size, const uint y_size);
   bool              CreateEdit(const long chart, const int subwindow, CEdit &object, const string text, const uint x, const uint y, const uint x_size, const uint y_size);
   bool              CreateBmpButton(const long chart, const int subwindow, CBmpButton &object, const uint x, const uint y, string BmpON, string BmpOFF, bool lock);
   bool              CreateRadioGroup(const long chart, const int subwindow, CRadioGroup &object, const string &text[], const uint x, const uint y, const uint x_size, const uint y_size);
   bool              CreateObjText(const long chart, const int subwindow, CChartObjectText &object, CChartObjectArrow &object_arrow, string text);


   void              LotsEndEdit(void);
   void              StopBarTimeEndEdit(void) {};
   void              StopBarOffsetEndEdit(void) {};
   void              SignalBarTimeEndEdit(void) {};
   void              SignalBarOffsetEndEdit(void) {};
   void              StopTicksEndEdit(void);
   void              MinAlertEndEdit(void) {};
   void              MaxAlertEndEdit(void) {};
   void              NxtBarBtnHandler(void);
   void              CancelBtnHandler(void);
   bool              EdgeDrag(string name);
   bool              SignalBarDrag(string name);
   bool              StopBarDrag(string name);

   void              UpdateMark(datetime time, double plus, CChartObjectText &object_t, CChartObjectArrow &object_a);
   bool              UpdateEditText(string text, CEdit &object);
   void              TrailSignalBar();
   void              TrailEntry(void);
   void              UpdateOffset();
   double            SL();
   double            TP();
   double            EntryPrice();
   double            BarSize(int stop, int signal, int direction);

   void              Minimize(void);
   void              OnTick();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CAssistantPanel)
ON_EVENT(ON_CLICK, m_nxt_bar_btn, NxtBarBtnHandler)
ON_EVENT(ON_CLICK, m_cancel_btn, CancelBtnHandler)
ON_EVENT(ON_END_EDIT, m_stop_bar_time_edit, StopBarTimeEndEdit)
ON_EVENT(ON_END_EDIT, m_stop_bar_offset_edit, StopBarOffsetEndEdit)
ON_EVENT(ON_END_EDIT, m_signal_bar_time_edit, SignalBarTimeEndEdit)
ON_EVENT(ON_END_EDIT, m_signal_bar_offset_edit, SignalBarOffsetEndEdit)
ON_EVENT(ON_END_EDIT, m_stop_ticks_edit, StopTicksEndEdit)
ON_EVENT(ON_END_EDIT, m_lots_edit, LotsEndEdit)
ON_EVENT(ON_END_EDIT, m_min_edit, MinAlertEndEdit)
ON_EVENT(ON_END_EDIT, m_max_edit, MaxAlertEndEdit)
EVENT_MAP_END(CAppDialog)


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::OnTick(void)
  {
   if(m_next_bar_flag && m_nxt_bar_reset)
     {
      m_nxt_bar_reset = false;
      m_signal = WRONG_VALUE;
      m_signal_bar_offset = 1;
      m_stop_bar_offset = 1;
      m_signal_bar_time = _.iT(1);
      m_stop_bar_time = _.iT(1);
     }

   if(m_signal == WRONG_VALUE && m_entry_direction == 1 && _.iH(0) > m_last_edge_max)
     {
      m_last_edge_max = _.iH(0);
      m_edge_bar_time = _.iT(0);
      m_edge_bar_offset = 0;
      UpdateMark(m_edge_bar_time, 0, m_edge_mark, m_edge_arrow);
     }
   if(m_signal == WRONG_VALUE && m_entry_direction == 2 && _.iL(0) < m_last_edge_min)
     {
      m_last_edge_min = _.iL(0);
      m_edge_bar_time = _.iT(0);
      m_edge_bar_offset = 0;
      UpdateMark(m_edge_bar_time, 0, m_edge_mark, m_edge_arrow);
     }

   if(new_candle)
     {
      //TrailSignalBar();
      //UpdateOffset();


      if((m_entry_direction == 1 && LowerHigh(1)) || (m_entry_direction == 2 && HigherLow(1)))
        {
         m_signal_bar_offset = 1;
         m_stop_bar_offset = 1;
         m_signal_bar_time = _.iT(1);
         m_stop_bar_time = _.iT(1);
        }
      
      else
        {
         m_signal_bar_offset = 1;
         m_stop_bar_offset = 1;
         m_signal_bar_time = _.iT(1);
         m_stop_bar_time = _.iT(1);
        }

     }



   if(m_entry_direction == 1 && m_signal_bar_time > -1)
     {
      m_stop_bar_offset = iLowest(_Symbol, _Period, MODE_LOW, _.iB(m_signal_bar_time) + 1, 0);
      m_stop_bar_time = _.iT(m_stop_bar_offset);
     }
   if(m_entry_direction == 2 && m_signal_bar_time > -1)
     {
      m_stop_bar_offset = iHighest(_Symbol, _Period, MODE_HIGH, _.iB(m_signal_bar_time) + 1, 0);
      m_stop_bar_time = _.iT(m_stop_bar_offset);
     }

   if(OrdersTotal() > 0 && (EntryPrice() != m_order_entry_price || SL() != m_order_sl))
     {
      m_order_entry_price = EntryPrice();
      m_order_sl = SL();
      TrailEntry();
     }


   if(m_next_bar_flag && new_candle)
     {

      if(m_entry_direction == 1 && LowerHigh(1))
        {
         m_signal_bar_offset = 1;
         m_stop_bar_offset = 1;
         m_signal_bar_time = _.iT(1);
         m_stop_bar_time = _.iT(1);
         m_signal = POSITION_TYPE_BUY;
        }
      if(m_entry_direction == 2 && HigherLow(1))
        {
         m_signal_bar_offset = 1;
         m_stop_bar_offset = 1;
         m_signal_bar_time = _.iT(1);
         m_stop_bar_time = _.iT(1);
         m_signal = POSITION_TYPE_SELL;
        }





      if(!PositionsTotal() && m_entry_direction == 1 && m_signal == POSITION_TYPE_BUY)
        {
         m_next_bar_flag = false;
         m_nxt_bar_on_off_label.Text("Off");
         m_trade.BuyStop(NormalizeDouble(m_cur_lot, 0), EntryPrice(), _Symbol, SL(), TP(), ORDER_TIME_DAY, 0, NULL);
        }
      if(!PositionsTotal() && m_entry_direction == 2 && m_signal == POSITION_TYPE_SELL)
        {
         m_next_bar_flag = false;
         m_nxt_bar_on_off_label.Text("Off");
         m_trade.SellStop(NormalizeDouble(m_cur_lot, 0), EntryPrice(), _Symbol, SL(), TP(), ORDER_TIME_DAY, 0, NULL);
        }
     }

   UpdateMark(m_signal_bar_time, 0, m_signal_bar_mark, m_signal_bar_arrow);
   UpdateMark(m_stop_bar_time, 12 * tick_size, m_stop_bar_mark, m_stop_bar_arrow);
   UpdateEditText((string)m_signal_bar_offset, m_signal_bar_offset_edit);
   UpdateEditText((string)m_stop_bar_offset, m_stop_bar_offset_edit);
   UpdateEditText(TimeToString(m_signal_bar_time, TIME_MINUTES), m_signal_bar_time_edit);
   UpdateEditText(TimeToString(m_stop_bar_time, TIME_MINUTES), m_stop_bar_time_edit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::UpdateEditText(string text, CEdit &object)
  {
   if(!object.Text(text))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::TrailSignalBar(void)
  {

   if(m_entry_direction == 1 && LowerHigh(m_signal_bar_offset + 1))
     {
      m_signal_bar_offset -= 1;
      m_signal_bar_time = _.iT(m_signal_bar_offset);
      //UpdateMark(m_signal_bar_time, m_signal_bar_mark, m_signal_bar_arrow);
     }
   if(m_entry_direction == 2 && HigherLow(m_signal_bar_offset + 1))
     {
      m_signal_bar_offset -= 1;
      m_signal_bar_time = _.iT(m_signal_bar_offset);
      //UpdateMark(m_signal_bar_time, m_signal_bar_mark, m_signal_bar_arrow);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::UpdateMark(datetime time, double plus, CChartObjectText & object_t, CChartObjectArrow & object_a)
  {
   if(time == -1)
      return;

   object_t.Time(0, time);
   object_a.Time(0, time);

   if(m_entry_direction == 1)
     {
      object_t.Price(0, _.iH(_.iB(time)) + plus + 15 * tick_size);
      object_a.Price(0, _.iH(_.iB(time)) + 11 * tick_size);
      object_t.Angle(90);
     }

   if(m_entry_direction == 2)
     {
      object_t.Price(0, _.iL(_.iB(time)) - plus - 10 * tick_size);
      object_a.Price(0, _.iL(_.iB(time)) - 6 * tick_size);
      object_t.Angle(270);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::TrailEntry(void)
  {
   if(OrdersTotal() > 0)
     {
      m_trade.OrderModify(OrderGetTicket(0), EntryPrice(), SL(), TP(), ORDER_TIME_DAY, 0, TP());
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::UpdateOffset(void)
  {
   m_stop_bar_offset = iBarShift(_Symbol, PERIOD_CURRENT, m_stop_bar_time, true);
   m_signal_bar_offset = iBarShift(_Symbol, PERIOD_CURRENT, m_signal_bar_time, true);
   m_signal_bar_offset_edit.Text((string)m_signal_bar_offset);
   m_stop_bar_offset_edit.Text((string)m_stop_bar_offset);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::NxtBarBtnHandler(void)
  {
   Print("SL(): ", SL());
   m_nxt_bar_on_off_label.Text("On");
   m_next_bar_flag = true;
   m_nxt_bar_reset = true;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::CancelBtnHandler(void)
  {
   m_nxt_bar_on_off_label.Text("Off");
   m_next_bar_flag = false;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::StopTicksEndEdit(void)
  {
   m_stop_ticks = (int)(m_stop_ticks_edit.Text());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAssistantPanel::BarSize(int stop, int signal, int direction)
  {
   if(direction == 1)
     {
      return MathAbs(iHigh(_Symbol, _Period, signal) - iLow(_Symbol, _Period, stop));
     }
   if(direction == 2)
     {
      return MathAbs(iHigh(_Symbol, _Period, stop) - iLow(_Symbol, _Period, signal));
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAssistantPanel::EntryPrice(void)
  {
   if(m_entry_direction == 1)
     {
      return iHigh(_Symbol, _Period, m_signal_bar_offset) + tick_size;
     }
   if(m_entry_direction == 2)
     {
      return iLow(_Symbol, _Period, m_signal_bar_offset) - tick_size;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAssistantPanel::TP(void)
  {
   if(m_entry_direction == 1)
     {
      double stop_size = BarSize(m_stop_bar_offset, m_signal_bar_offset, 1);
      return iHigh(_Symbol, _Period, m_signal_bar_offset) + stop_size;
     }
   if(m_entry_direction == 2)
     {
      double stop_size = BarSize(m_stop_bar_offset, m_signal_bar_offset, 2);
      return iLow(_Symbol, _Period, m_signal_bar_offset) - stop_size;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAssistantPanel::SL(void)
  {
   if(m_entry_direction == 1)
     {
      return iLow(_Symbol, _Period, m_stop_bar_offset) - m_stop_ticks * tick_size;
     }
   if(m_entry_direction == 2)
     {
      return iHigh(_Symbol, _Period, m_stop_bar_offset) + m_stop_ticks * tick_size;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::EdgeDrag(string name)
  {
   if(name == m_edge_mark.Name())
     {
      m_edge_mark_price = m_edge_mark.Price(0);
      m_signal_mark_price = m_edge_mark_price;
      m_edge_bar_time = (datetime)m_edge_mark.GetInteger(OBJPROP_TIME, -1);
      m_edge_bar_offset = iBarShift(_Symbol, _Period, m_edge_bar_time);

      if(m_edge_mark_price <= _.iL(m_edge_bar_offset))
        {
         m_entry_direction = 2;
         m_edge_mark_price = _.iL(m_edge_bar_offset) - 11 * tick_size;
         m_signal_mark_price = m_edge_mark_price;
         m_stop_mark_price = m_edge_mark_price - 10 * tick_size;
         m_last_edge_min = _.iL(m_edge_bar_offset);
         if(!m_edge_arrow.Time(0, m_edge_bar_time))
            return false;
         if(!m_edge_arrow.Price(0, _.iL(m_edge_bar_offset) - 6 * tick_size))
            return false;
         if(!m_edge_mark.Angle(270))
            return false;
         if(!m_edge_mark.Price(0, m_edge_mark_price))
            return false;
        }

      if(m_edge_mark_price >= _.iH(m_edge_bar_offset))
        {
         m_entry_direction = 1;
         m_edge_mark_price = _.iH(m_edge_bar_offset) + 16 * tick_size;
         m_signal_mark_price = m_edge_mark_price;
         m_stop_mark_price = m_edge_mark_price + 10 * tick_size;
         m_last_edge_max = _.iH(m_edge_bar_offset);
         if(!m_edge_arrow.Time(0, m_edge_bar_time))
            return false;
         if(!m_edge_arrow.Price(0, _.iH(m_edge_bar_offset) + 11 * tick_size))
            return false;
         if(!m_edge_mark.Angle(90))
            return false;
         if(!m_edge_mark.Price(0, m_edge_mark_price))
            return false;
        }



      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::StopBarDrag(string name)
  {
   if(name == m_stop_bar_mark.Name())
     {
      m_stop_mark_price = m_stop_bar_mark.Price(0);
      m_stop_bar_time = (datetime)m_stop_bar_mark.GetInteger(OBJPROP_TIME, -1);
      m_stop_bar_offset = iBarShift(_Symbol, _Period, m_stop_bar_time);
      m_stop_bar_offset_edit.Text((string)m_stop_bar_offset);
      MqlDateTime time_stru;
      TimeToStruct(m_stop_bar_time, time_stru);
      m_stop_bar_time_edit.Text((string)time_stru.hour + ":" + (string)time_stru.min);
      double price_add = 50;
      if(!m_stop_bar_arrow.Time(0, m_stop_bar_mark.GetInteger(OBJPROP_TIME, -1)))
         return false;
      if(!m_stop_bar_arrow.Price(0, iHigh(_Symbol, _Period, m_stop_bar_offset) + price_add))
         return false;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::SignalBarDrag(string name)
  {
   if(name == m_signal_bar_mark.Name())
     {
      m_signal_mark_price = m_signal_bar_mark.Price(0);
      m_signal_bar_time = (datetime)m_signal_bar_mark.GetInteger(OBJPROP_TIME, -1);
      m_signal_bar_offset = iBarShift(_Symbol, _Period, m_signal_bar_time);
      m_signal_bar_offset_edit.Text((string)m_signal_bar_offset);
      MqlDateTime time_stru;
      TimeToStruct(m_signal_bar_time, time_stru);
      m_signal_bar_time_edit.Text((string)time_stru.hour + ":" + (string)time_stru.min);

      double price_add = 50;
      if(!m_signal_bar_arrow.Time(0, m_signal_bar_mark.GetInteger(OBJPROP_TIME, -1)))
         return false;
      if(!m_signal_bar_arrow.Price(0, iHigh(_Symbol, _Period, m_signal_bar_offset) + price_add))
         return false;

      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
  {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
      return(false);

   int b_x = BORDER;
   int b_y = BORDER;
//int x_size = (int)((ClientAreaWidth() - 40) / 3 - 5);

   if(!CreateObjText(chart, subwin, m_edge_mark, m_edge_arrow, "Ponta"))
     {
      return false;
     }
   if(!CreateObjText(chart, subwin, m_signal_bar_mark, m_signal_bar_arrow, "Signal"))
     {
      return false;
     }
   if(!CreateObjText(chart, subwin, m_stop_bar_mark, m_stop_bar_arrow, "Stop"))
     {
      return false;
     }

   if(!CreateButton(chart, subwin, m_nxt_bar_btn, "Nxt bar", b_x, b_y, 80, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   b_y = (int)(b_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateButton(chart, subwin, m_last_bar_btn, "Last bar", b_x, b_y, 80, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   b_y = (int)(b_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateButton(chart, subwin, m_cancel_btn, "Cancel", b_x, b_y, 80, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   int l_y = BORDER;
   b_x += 130;
   if(!CreateLabel(chart, subwin, m_signal_bar_label, "Signal bar", b_x, l_y, left))
     {
      return false;
     }
   int l_x = b_x + BORDER + 55;
   if(!CreateLabel(chart, subwin, m_signal_bar_n_label, "Offset", l_x, l_y, left))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateEdit(chart, subwin, m_signal_bar_time_edit, "00:00", b_x, l_y, 60, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   if(!CreateEdit(chart, subwin, m_signal_bar_offset_edit, "0", l_x, l_y, 25, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateLabel(chart, subwin, m_stop_bar_label, "SL bar", b_x, l_y, left))
     {
      return false;
     }
   if(!CreateLabel(chart, subwin, m_stop_bar_n_label, "Offset", l_x, l_y, left))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateEdit(chart, subwin, m_stop_bar_time_edit, "00:00", b_x, l_y, 60, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   if(!CreateEdit(chart, subwin, m_stop_bar_offset_edit, "0", l_x, l_y, 25, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateLabel(chart, subwin, m_stop_ticks_label, "SL ticks", b_x, l_y, left))
     {
      return false;
     }
   if(!CreateLabel(chart, subwin, m_max_alert_label, "Max", l_x, l_y, left))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateEdit(chart, subwin, m_stop_ticks_edit, "1", b_x, l_y, 50, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   if(!CreateEdit(chart, subwin, m_max_edit, "empty", l_x, l_y, 70, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateLabel(chart, subwin, m_lots_label, "Lots", b_x, l_y, left))
     {
      return false;
     }
   if(!CreateLabel(chart, subwin, m_min_alert_label, "Min", l_x, l_y, left))
     {
      return false;
     }
   l_y = (int)(l_y + CONTROLS_BUTTON_SIZE * 1.5);
   if(!CreateEdit(chart, subwin, m_lots_edit, "1", b_x, l_y, 50, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   if(!CreateEdit(chart, subwin, m_min_edit, "empty", l_x, l_y, 70, CONTROLS_BUTTON_SIZE))
     {
      return false;
     }
   l_y = BORDER;
   l_x = BORDER + 90;
   if(!CreateLabel(chart, subwin, m_nxt_bar_on_off_label, "Off", l_x, l_y, left))
     {
      return false;
     }

//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::LotsEndEdit(void)
  {
//--- Read and normalize lot value
//m_cur_lot = NormalizeLots(StringToDouble(Lots.Text()));
//--- Output lot value to panel
//Lots.Text(DoubleToString(cur_lot, 2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAssistantPanel::Minimize(void)
  {
//--- a variable for checking the one-click trading panel
   long one_click_visible = -1; // 0 - there is no one-click trading panel
   if(!ChartGetInteger(m_chart_id, CHART_SHOW_ONE_CLICK, 0, one_click_visible))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
     }
//--- the minimum indent for a minimized panel
   int min_y_indent = 28;
   if(one_click_visible)
      min_y_indent = 100; // use this indent if there is a one-click trading panel in the chart
//--- getting the current indent for the minimized panel
   int current_y_top = m_min_rect.top;
   int current_y_bottom = m_min_rect.bottom;
   int height = current_y_bottom - current_y_top;
//--- сalculating the minimum indent from top for a minimized panel of the application
   if(m_min_rect.top != min_y_indent)
     {
      m_min_rect.top = min_y_indent;
      //--- shifting the lower border of the minimized icon
      m_min_rect.bottom = m_min_rect.top + height;
     }
//--- Now we can call the method of the base class
   CAppDialog::Minimize();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateStopBarEdit(void)
  {
//--- coordinates
   int x1 = INDENT_LEFT;
   int y1 = SECOND_LINE;
   int x2 = 50;
   int y2 = y1 + EDIT_HEIGHT;

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateNxtBarBtn(void)
  {
//--- coordinates
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP;
   int x2 = x1 + 80;
   int y2 = y1 + BTN_HEIGHT;
//--- create
   if(!m_nxt_bar_btn.Create(0, "CreateNxtBarBtn", 0, x1, y1, x2, y2))
      return(false);
   if(!m_nxt_bar_btn.Text("Nxt Bar"))
      return(false);
   if(!Add(m_nxt_bar_btn))
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateObjText(const long chart, const int subwindow, CChartObjectText & object, CChartObjectArrow & object_arrow, string text)
  {
//--- coordinates
   string name = m_name + text + (string)ObjectsTotal(chart, -1, OBJ_LABEL);
//--- create
   if(!object.Create(0, name, 0, iTime(_Symbol, _Period, 0), iHigh(_Symbol, _Period, 0)))
      return(false);
   if(!object.Description(text))
      return(false);
   if(!object.Selectable(true))
      return(false);
   if(!object.Angle(90))
      return(false);
   name = m_name + "Arrow" + text + (string)ObjectsTotal(chart, -1, OBJ_LABEL);
   if(!object_arrow.Create(0, name, 0, iTime(_Symbol, _Period, 0), iHigh(_Symbol, _Period, 0), 115))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateLabel(const long chart, const int subwindow, CLabel & object, const string text, const uint x, const uint y, label_align align)
  {
// All objects must to have separate name
   string name = m_name + "Label" + (string)ObjectsTotal(chart, -1, OBJ_LABEL);
//--- Call Create function
   if(!object.Create(chart, name, subwindow, x, y, 0, 0))
     {
      return false;
     }
//--- Addjust text
   if(!object.Text(text))
     {
      return false;
     }
//--- Aling text to Dialog box's grid
   ObjectSetInteger(chart, object.Name(), OBJPROP_ANCHOR, (align == left ? ANCHOR_LEFT_UPPER : (align == right ? ANCHOR_RIGHT_UPPER : ANCHOR_UPPER)));
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateButton(const long chart, const int subwindow, CButton & object, const string text, const uint x, const uint y, const uint x_size, const uint y_size)
  {
// All objects must to have separate name
   string name = m_name + "Button" + (string)ObjectsTotal(chart, -1, OBJ_BUTTON);
//--- Call Create function
   if(!object.Create(chart, name, subwindow, x, y, x + x_size, y + y_size))
     {
      return false;
     }

//--- Addjust text
   if(!object.Text(text))
     {
      return false;
     }
//--- set button flag to unlock
   object.Locking(false);
//--- set button flag to unpressed
   if(!object.Pressed(false))
     {
      return false;
     }
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateRadioGroup(const long chart, const int subwindow, CRadioGroup & object, const string & text[], const uint x, const uint y, const uint x_size, const uint y_size)
  {
// All objects must to have separate name
   string name = m_name + "RadioGroup" + (string)ObjectsTotal(chart, -1, OBJ_LABEL);
//--- Call Create function
   if(!object.Create(chart, name, subwindow, x, y, x + x_size, y + y_size))
     {
      return false;
     }
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }

//--- fill out with strings
   for(int i = 0; i < ArraySize(text); i++)
      if(!object.AddItem(text[i], 1 << i))
         return(false);
   object.Value(1 << 2);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateEdit(const long chart, const int subwindow, CEdit & object, const string text, const uint x, const uint y, const uint x_size, const uint y_size)
  {
// All objects must to have separate name
   string name = m_name + "Edit" + (string)ObjectsTotal(chart, -1, OBJ_EDIT);
//--- Call Create function
   if(!object.Create(chart, name, subwindow, x, y, x + x_size, y + y_size))
     {
      return false;
     }
//--- Addjust text
   if(!object.Text(text))
     {
      return false;
     }
//--- Align text in Edit box
   if(!object.TextAlign(ALIGN_CENTER))
     {
      return false;
     }
//--- set Read only flag to false
   if(!object.ReadOnly(false))
     {
      return false;
     }
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAssistantPanel::CreateBmpButton(const long chart, const int subwindow, CBmpButton & object, const uint x, const uint y, string BmpON, string BmpOFF, bool lock)
  {
// All objects must to have separate name
   string name = m_name + "BmpButton" + (string)ObjectsTotal(chart, -1, OBJ_BITMAP_LABEL);
//--- Calculate coordinates
   uint y1 = (uint)(y - (Y_STEP - CONTROLS_BUTTON_SIZE) / 2);
   uint y2 = y1 + CONTROLS_BUTTON_SIZE;
//--- Call Create function
   if(!object.Create(m_chart_id, name, m_subwin, x - CONTROLS_BUTTON_SIZE, y1, x, y2))
      return(false);
//--- Assign BMP pictures to button status
   if(!object.BmpNames(BmpOFF, BmpON))
      return(false);
//--- Add object to controls
   if(!Add(object))
      return(false);
//--- set Lock flag to true
   object.Locking(lock);
//--- succeeded
   return(true);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
