//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Dev\Brooks\Directions.mqh>
#include <Dev\Brooks\Enums.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCheckDirection
  {

public:
   CDirections       m_directions;
   int               m_current_index;
   datetime          m_start_time, m_end_time;
                     CCheckDirection(void);
                     CCheckDirection(datetime start_time, datetime end_time);
                    ~CCheckDirection(void);
   ALWAYS_IN         Direction(datetime currentCandle);
   void              LoadFile(string asset_prefix);
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::CCheckDirection(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::CCheckDirection(datetime p_start_time, datetime p_end_time)
  {
   m_start_time = p_start_time;
   m_end_time = p_end_time;
   m_directions = CDirections();
   m_current_index = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::~CCheckDirection(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ALWAYS_IN CCheckDirection::Direction(datetime currentCandle)
  {
   if(currentCandle >= m_directions.GetItem(m_current_index+1).timestamp)
     {
      m_current_index++;
     }
   return m_directions.GetItem(m_current_index).direction;
  }
//+------------------------------------------------------------------+
void CCheckDirection::LoadFile(string asset_prefix)
  {
   int h = FileOpen(asset_prefix+TimeToString(m_start_time, TIME_DATE)+"-"+TimeToString(m_end_time, TIME_DATE)+".csv", FILE_READ|FILE_CSV|FILE_ANSI, ",");
   if(h==INVALID_HANDLE)
     {
      Print("Error opening file");
      Print("Error code ",GetLastError());
      FileClose(h);
      return;
     }

   while(!FileIsEnding(h))
     {
      datetime time = StringToTime(FileReadString(h));
      int direction = (int)FileReadString(h);
      m_directions.Append(direction,time);
     }
   m_directions.PrintArray();
   FileClose(h);
  }
//+------------------------------------------------------------------+
