//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\RadioGroup.mqh>
#include <Dev\Brooks\Backtest.mqh>
#include <Dev\Brooks\AlwaysInEnum.mqh>
#include <Dev\Brooks\Directions.mqh>
#include <Dev\Brooks\DirectionStruct.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CButton           m_button1,m_button2;
   CRadioGroup       m_radio_group;
   CDirections       m_directions;
   string            m_line_name;
   datetime          m_start_time, m_end_time;
public:
                     CControlsDialog(datetime start_time, datetime end_time);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   bool              CreateButtons(void);
   bool              CreateAlwaysInRadios(void);
   void              OnClickSaveDirection(void);
   void              OnClickWriteFile(void);
   void              OnChangeRadioGroup(void);
   void              WriteDirectionToFile(void);
   string            CreateVLine(datetime time);
   datetime          GetCurrentCandleTime(void);
  };

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,m_button1,OnClickSaveDirection)
ON_EVENT(ON_CLICK,m_button2,OnClickWriteFile)
ON_EVENT(ON_CHANGE,m_radio_group,OnChangeRadioGroup)
EVENT_MAP_END(CAppDialog)

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(datetime start_time, datetime end_time)
  {
   m_start_time = start_time;
   m_end_time = end_time;
   m_line_name = CreateVLine(start_time);
   m_directions = CDirections();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButtons())
      return(false);
   if(!CreateAlwaysInRadios())
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtons(void)
  {
//--- coordinates
   int b1x1=INDENT_LEFT;
   int b1y1=INDENT_TOP+(CONTROLS_GAP_Y);
   int b1x2=b1x1+BUTTON_WIDTH;
   int b1y2=b1y1+BUTTON_HEIGHT;
   int b2x1=b1x1+BUTTON_WIDTH+CONTROLS_GAP_X;
   int b2y1=INDENT_TOP+(CONTROLS_GAP_Y);
   int b2x2=b1x2+BUTTON_WIDTH;
   int b2y2=b2y1+BUTTON_HEIGHT;
//--- create
   if(!m_button1.Create(m_chart_id,m_name+"Save Direction",m_subwin,b1x1,b1y1,b1x2,b1y2))
      return(false);
   if(!m_button1.Text("Save Direction"))
      return(false);
   if(!Add(m_button1))
      return(false);
   if(!m_button2.Create(m_chart_id,m_name+"Write File",m_subwin,b2x1,b2y1,b2x2,b2y2))
      return(false);
   if(!m_button2.Text("Write File"))
      return(false);
   if(!Add(m_button2))
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateAlwaysInRadios(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(EDIT_HEIGHT+CONTROLS_GAP_Y+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT+BUTTON_HEIGHT+BUTTON_HEIGHT;
   string names[3] = {"AIL", "AIS", "AIR"};
//--- create
//--- create
   if(!m_radio_group.Create(m_chart_id,"RadioGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_radio_group))
      return(false);
//--- fill out with strings
   for(int i=0; i<3; i++)
      if(!m_radio_group.AddItem(names[i],i))
         return(false);
   m_radio_group.Value(0);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeRadioGroup(void)
  {
  }
//+------------------------------------------------------------------+
void CControlsDialog::OnClickSaveDirection(void)
  {
   datetime time = GetCurrentCandleTime();
   int direction = m_radio_group.Value();
   m_directions.Append(direction,time);
   m_directions.PrintArray();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickWriteFile()
  {
   int h=FileOpen("win"+TimeToString(m_start_time,TIME_DATE)+"-"+TimeToString(m_end_time,TIME_DATE), FILE_WRITE|FILE_CSV|FILE_ANSI,",");
   ResetLastError();
   if(h==INVALID_HANDLE)
     {
      Alert("Error opening file");
      return;
     }
   FileSeek(h,0,SEEK_END);
   m_directions.Trim();
   for(int i=0; i<m_directions.GetSize(); i++)
     {
      s_Directions tmp = m_directions.GetItem(i);
      FileWrite(h,tmp.timestamp,tmp.direction);
     }
   FileClose(h);
  }
//+------------------------------------------------------------------+
string CControlsDialog::CreateVLine(datetime time)
  {
   if(!ObjectCreate(0,"MarkerTimeLine",OBJ_VLINE,0,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create Vertical Line! Error code = ",GetLastError());
     }
   ObjectSetInteger(0,"MarkerTimeLine",OBJPROP_SELECTABLE,true);
   return "MarkerTimeLine";
  }
//+------------------------------------------------------------------+
datetime CControlsDialog::GetCurrentCandleTime(void)
  {
   return ObjectGetInteger(0,"MarkerTimeLine",OBJPROP_TIME,0);
  }
//+------------------------------------------------------------------+
