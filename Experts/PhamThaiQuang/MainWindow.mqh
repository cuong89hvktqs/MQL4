//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <EasyAndFastGUI\Controls\Window.mqh>
#include <EasyAndFastGUI\Controls\Objects.mqh>
#define BUTTON_HIGH (25)
#define BUTTON_WITH (80)
#define HEADER_WITH (21)
#define GAP_OFFSET (5)
#define  FONT_TEXT_SIZE (10)
#define  FONT_TEXT_TYPE ("Tahoma Bold")
class CMainWindow: public CWindow
{
public:
   
   
   //CButton     btn1;
   CLabel     lbl_trang_thai_bot;
   CButton     btn_trang_thai_bot;
   
   CLabel      lbl_xu_huong_tay;
   CButton     btn_xu_huong_tay;
   
   CEdit       edt_tinh_dolla;
   CEdit       edt_tinh_lot;
   CEdit       edt_tinh_pip;
   
   CButton     btn_tinh_dolla;
   CButton     btn_tinh_lot;
   CButton     btn_tinh_pip;
   CLabel      lbl_thong_bao;
   
   CLabel      lbl_cat_lo_cham_band;
   CButton     btn_cat_lo_cham_band;
   
private:
   bool              Create_btn_trang_thai_bot(void);// btn Xu huong tay
   bool              Create_lbl_trang_thai_bot(void);
   bool              Create_lbl_xu_huong_tay(void);
   bool              Create_btn_xu_huong_tay(void);
   bool              Create_edt_tinh_dolla(void);
   bool              Create_edt_tinh_lot(void);
   bool              Create_edt_tinh_pip(void);
   bool              Create_btn_tinh_dolla(void);
   bool              Create_btn_tinh_lot(void);
   bool              Create_btn_tinh_pip(void);
   bool              Create_lbl_thong_bao(void);
   bool              Create_lbl_cat_lo_cham_band(void);
   bool              Create_btn_cat_lo_cham_band(void);
public:
                     CMainWindow(void);
                    ~CMainWindow(void);
                    
public:
   bool         CreatMainWindow(const long chart_id,const int window,const string caption_text,const int x,const int y);
   
   void        UpdateMainWindowXY(const int x,const int y);
public:   
    virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
   //--- Moving the control
   virtual void      Moving(const int x,const int y);
   //--- Showing, hiding, resetting, deleting
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- Setting, resetting priorities for the left mouse click
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- Initialization/uninitialization
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMainWindow::CMainWindow(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMainWindow::~CMainWindow(void)
  {
  }
//+------------------------------------------------------------------+
 void CMainWindow::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      int      x      =(int)lparam; // Coordinate of the X axis
      int      y      =(int)dparam; // Coordinate of the Y axis
      int      subwin =WRONG_VALUE; // Window number, in which the cursor is located
      datetime time   =NULL;        // Time corresponding to the X coordinate
      double   level  =0.0;         // Level (price) corresponding to the Y coordinate
      int      rel_y  =0;           // For identification of the relative Y coordinate
      //--- Get the cursor location
      if(!::ChartXYToTimePrice(m_chart_id,x,y,subwin,time,level))
         return;
      //--- Get the relative Y coordinate
      rel_y=YToRelative(y);
      //--- Verify and store the state of the mouse button
      CheckMouseButtonState(x,rel_y,sparam);
      //--- Verifying the mouse focus
      CheckMouseFocus(x,rel_y,subwin);
      //--- Set the chart state
      SetChartState(subwin);
      //--- If the management is delegated to the window, identify its location
      
      if(m_clamping_area_mouse==PRESSED_INSIDE_HEADER)
        {
         //--- Updating window coordinates
         UpdateMainWindowXY(x,rel_y);
        }
        
      //---
      return;
     }
//--- Handling event of clicking on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Close window
      CloseWindow(sparam);
      //--- Minimize/Maximize the window
      ChangeWindowState(sparam);
      if(sparam==btn_trang_thai_bot.Name())
      {
         if(btn_trang_thai_bot.GetString(OBJPROP_TEXT)=="ON")
         {
            btn_trang_thai_bot.SetString(OBJPROP_TEXT,"OFF");
            btn_trang_thai_bot.BackColor(clrRosyBrown);
            btn_trang_thai_bot.Color(clrYellow);
         }
         else
         {
             btn_trang_thai_bot.SetString(OBJPROP_TEXT,"ON");
             btn_trang_thai_bot.BackColor(clrDeepSkyBlue);
             btn_trang_thai_bot.Color(clrBlack);
         }
            
      }
      
      if(sparam==btn_xu_huong_tay.Name())
      {
         if(btn_xu_huong_tay.GetString(OBJPROP_TEXT)=="OFF")
         {
            btn_xu_huong_tay.SetString(OBJPROP_TEXT,"TANG");
            btn_xu_huong_tay.BackColor(clrGreen);
            btn_xu_huong_tay.Color(clrWhite);
            lbl_thong_bao.Description("XU HUONG HIEN TAI: TANG");
         }
         else if (btn_xu_huong_tay.GetString(OBJPROP_TEXT)=="TANG")
         {
             btn_xu_huong_tay.SetString(OBJPROP_TEXT,"GIAM");
             btn_xu_huong_tay.BackColor(clrRed);
             btn_xu_huong_tay.Color(clrWhite);
             lbl_thong_bao.Description("XU HUONG HIEN TAI: GIAM");
         }   
         else if(btn_xu_huong_tay.GetString(OBJPROP_TEXT)=="GIAM")
         {
             btn_xu_huong_tay.SetString(OBJPROP_TEXT,"SIDEWAY");
             btn_xu_huong_tay.BackColor(clrYellow);
             btn_xu_huong_tay.Color(clrBlack);
             lbl_thong_bao.Description("XU HUONG HIEN TAI: SIDEWAY");
         }
         else
         {
            btn_xu_huong_tay.SetString(OBJPROP_TEXT,"OFF");
            btn_xu_huong_tay.BackColor(clrGray);
            btn_xu_huong_tay.Color(clrBlue);
            lbl_thong_bao.Description("XU HUONG HIEN TAI: ");
         }
      }
      if(sparam==btn_cat_lo_cham_band.Name())
      {
         if(btn_cat_lo_cham_band.GetString(OBJPROP_TEXT)=="ON")
         {
            btn_cat_lo_cham_band.SetString(OBJPROP_TEXT,"OFF");
            btn_cat_lo_cham_band.BackColor(clrRosyBrown);
            btn_cat_lo_cham_band.Color(clrYellow);
         }
         else
         {
             btn_cat_lo_cham_band.SetString(OBJPROP_TEXT,"ON");
             btn_cat_lo_cham_band.BackColor(clrDeepSkyBlue);
             btn_cat_lo_cham_band.Color(clrBlack);
         }
      }
      return;
     }
//--- Event of changing the chart properties

   if(id==CHARTEVENT_CHART_CHANGE)
     {
      //--- If the button is released
      if(m_clamping_area_mouse==NOT_PRESSED)
        {
         //--- Get the chart window size
         SetWindowProperties();
         //--- Adjustment of coordinates
         UpdateWindowXY(m_x,m_y);
        }
      return;
     }
  }
  // DIch chuyen bang
 void CMainWindow::Moving(const int x,const int y)
{
   //--- Storing coordinates in variables
   
   m_bg.X(x);
   m_bg.Y(y);
   m_caption_bg.X(x);
   m_caption_bg.Y(y);
   m_icon.X(x+m_icon.XGap());
   m_icon.Y(y+m_icon.YGap());
   m_label.X(x+m_label.XGap());
   m_label.Y(y+m_label.YGap());
   m_button_close.X(x+m_button_close.XGap());
   m_button_close.Y(y+m_button_close.YGap());
   m_button_unroll.X(x+m_button_unroll.XGap());
   m_button_unroll.Y(y+m_button_unroll.YGap());
   m_button_rollup.X(x+m_button_rollup.XGap());
   m_button_rollup.Y(y+m_button_rollup.YGap());
   m_button_tooltip.X(x+m_button_tooltip.XGap());
   m_button_tooltip.Y(y+m_button_tooltip.YGap());
//--- Updating coordinates of graphical objects
   m_bg.X_Distance(m_bg.X());
   m_bg.Y_Distance(m_bg.Y());
   m_caption_bg.X_Distance(m_caption_bg.X());
   m_caption_bg.Y_Distance(m_caption_bg.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_button_close.X_Distance(m_button_close.X());
   m_button_close.Y_Distance(m_button_close.Y());
   m_button_unroll.X_Distance(m_button_unroll.X());
   m_button_unroll.Y_Distance(m_button_unroll.Y());
   m_button_rollup.X_Distance(m_button_rollup.X());
   m_button_rollup.Y_Distance(m_button_rollup.Y());
   m_button_tooltip.X_Distance(m_button_tooltip.X());
   m_button_tooltip.Y_Distance(m_button_tooltip.Y());
   
   // Dich chuyen btn1 toi vi tri moi
   btn_trang_thai_bot.X(x+btn_trang_thai_bot.XGap());
   btn_trang_thai_bot.Y(y+btn_trang_thai_bot.YGap());
   btn_trang_thai_bot.X_Distance(btn_trang_thai_bot.X());
   btn_trang_thai_bot.Y_Distance(btn_trang_thai_bot.Y());
   
   lbl_trang_thai_bot.X(x+lbl_trang_thai_bot.XGap());
   lbl_trang_thai_bot.Y(y+lbl_trang_thai_bot.YGap());
   lbl_trang_thai_bot.X_Distance(lbl_trang_thai_bot.X());
   lbl_trang_thai_bot.Y_Distance(lbl_trang_thai_bot.Y());
   
   lbl_xu_huong_tay.X(x+lbl_xu_huong_tay.XGap());
   lbl_xu_huong_tay.Y(y+lbl_xu_huong_tay.YGap());
   lbl_xu_huong_tay.X_Distance(lbl_xu_huong_tay.X());
   lbl_xu_huong_tay.Y_Distance(lbl_xu_huong_tay.Y());
   
   btn_xu_huong_tay.X(x+btn_xu_huong_tay.XGap());
   btn_xu_huong_tay.Y(y+btn_xu_huong_tay.YGap());
   btn_xu_huong_tay.X_Distance(btn_xu_huong_tay.X());
   btn_xu_huong_tay.Y_Distance(btn_xu_huong_tay.Y());
   
   edt_tinh_dolla.X(x+edt_tinh_dolla.XGap());
   edt_tinh_dolla.Y(y+edt_tinh_dolla.YGap());
   edt_tinh_dolla.X_Distance(edt_tinh_dolla.X());
   edt_tinh_dolla.Y_Distance(edt_tinh_dolla.Y());
   
   edt_tinh_lot.X(x+edt_tinh_lot.XGap());
   edt_tinh_lot.Y(y+edt_tinh_lot.YGap());
   edt_tinh_lot.X_Distance(edt_tinh_lot.X());
   edt_tinh_lot.Y_Distance(edt_tinh_lot.Y());
   
   edt_tinh_pip.X(x+edt_tinh_pip.XGap());
   edt_tinh_pip.Y(y+edt_tinh_pip.YGap());
   edt_tinh_pip.X_Distance(edt_tinh_pip.X());
   edt_tinh_pip.Y_Distance(edt_tinh_pip.Y());
   
   btn_tinh_dolla.X(x+btn_tinh_dolla.XGap());
   btn_tinh_dolla.Y(y+btn_tinh_dolla.YGap());
   btn_tinh_dolla.X_Distance(btn_tinh_dolla.X());
   btn_tinh_dolla.Y_Distance(btn_tinh_dolla.Y());
   
   
   btn_tinh_lot.X(x+btn_tinh_lot.XGap());
   btn_tinh_lot.Y(y+btn_tinh_lot.YGap());
   btn_tinh_lot.X_Distance(btn_tinh_lot.X());
   btn_tinh_lot.Y_Distance(btn_tinh_lot.Y());
   
   btn_tinh_pip.X(x+btn_tinh_pip.XGap());
   btn_tinh_pip.Y(y+btn_tinh_pip.YGap());
   btn_tinh_pip.X_Distance(btn_tinh_pip.X());
   btn_tinh_pip.Y_Distance(btn_tinh_pip.Y());
   
   lbl_thong_bao.X(x+lbl_thong_bao.XGap());
   lbl_thong_bao.Y(y+lbl_thong_bao.YGap());
   lbl_thong_bao.X_Distance(lbl_thong_bao.X());
   lbl_thong_bao.Y_Distance(lbl_thong_bao.Y());  
   
   lbl_cat_lo_cham_band.X(x+lbl_cat_lo_cham_band.XGap());
   lbl_cat_lo_cham_band.Y(y+lbl_cat_lo_cham_band.YGap());
   lbl_cat_lo_cham_band.X_Distance(lbl_cat_lo_cham_band.X());
   lbl_cat_lo_cham_band.Y_Distance(lbl_cat_lo_cham_band.Y());  
   
   btn_cat_lo_cham_band.X(x+btn_cat_lo_cham_band.XGap());
   btn_cat_lo_cham_band.Y(y+btn_cat_lo_cham_band.YGap());
   btn_cat_lo_cham_band.X_Distance(btn_cat_lo_cham_band.X());
   btn_cat_lo_cham_band.Y_Distance(btn_cat_lo_cham_band.Y());  
}
  



void CMainWindow::UpdateMainWindowXY(int x,int y)
{
   if(!m_movable)// Khong cho phep di duyen
      return;
   //---  
   int new_x_point =0; // New X coordinate
   int new_y_point =0; // New Y coordinate
//--- Limits
   int limit_top    =0;
   int limit_left   =0;
   int limit_bottom =0;
   int limit_right  =0;
   //--- If the mouse button is pressed
   if((bool)m_clamping_area_mouse)
     {
      //--- Store current XY coordinates of the cursor
      if(m_prev_y==0 || m_prev_x==0)
        {
         m_prev_y=y;
         m_prev_x=x;
        }
      //--- Store the distance from the edge point of the form to the cursor
      if(m_size_fixing_y==0 || m_size_fixing_x==0)
        {
         m_size_fixing_y=m_y-m_prev_y;
         m_size_fixing_x=m_x-m_prev_x;
        }
     }
//--- Set limits
   limit_top    =y-::fabs(m_size_fixing_y);
   limit_left   =x-::fabs(m_size_fixing_x);
   limit_bottom =m_y+m_caption_height;
   limit_right  =m_x+m_x_size;
//--- If the boundaries of the chart are not exceeded downwards/upwards/right/left
   if(limit_bottom<m_chart_height && limit_top>=0 && 
      limit_right<m_chart_width && limit_left>=0)
     {
      new_y_point =y+m_size_fixing_y;
      new_x_point =x+m_size_fixing_x;
     }
//--- If the boundaries of the chart were exceeded
   else
     {
      if(limit_bottom>m_chart_height) // > downwards
        {
         new_y_point =m_chart_height-m_caption_height;
         new_x_point =x+m_size_fixing_x;
        }
      if(limit_top<0) // > upwards
        {
         new_y_point =0;
         new_x_point =x+m_size_fixing_x;
        }
      if(limit_right>m_chart_width) // > right
        {
         new_x_point =m_chart_width-m_x_size;
         new_y_point =y+m_size_fixing_y;
        }
      if(limit_left<0) // > left
        {
         new_x_point =0;
         new_y_point =y+m_size_fixing_y;
        }
     }
//--- Update coordinates, if there was a displacement
   if(new_x_point>0 || new_y_point>0)
     {
      //--- Adjust the form coordinates
      m_x =(new_x_point<=0)? 1 : new_x_point;
      m_y =(new_y_point<=0)? 1 : new_y_point;
      //---
      if(new_x_point>0)
         m_x=(m_x>m_chart_width-m_x_size-1) ? m_chart_width-m_x_size-1 : m_x;
      if(new_y_point>0)
         m_y=(m_y>m_chart_height-m_caption_height-1) ? m_chart_height-m_caption_height-2 : m_y;
      //--- Zero the fixed points
      m_prev_x=0;
      m_prev_y=0;
     }
}

//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
void CMainWindow::Delete(void)
  {
//--- Zeroing variables
   m_right_limit=0;
//--- Deleting objects
   // Tong dang co 7 object
   for(int i=0; i<ObjectsElementTotal(); i++)
      Object(i).Delete();
//--- Emptying the object array
   CElement::FreeObjectsArray();
//--- Zeroing the control focus
   CElement::MouseFocus(false);
  }

//+------------------------------------------------------------------+
//| Hides window                                                     |
//+------------------------------------------------------------------+
void CMainWindow::Hide(void)
  {
//--- Hide all objects
   for(int i=0; i<ObjectsElementTotal(); i++)
      Object(i).Timeframes(OBJ_NO_PERIODS);
  
//--- Visible state
   CElement::IsVisible(false);
  }
 //+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CMainWindow::OnEventTimer(void)
  {
//--- Changing the color of the form objects
   ChangeObjectsColor();
  }
  //+------------------------------------------------------------------+
//| Creat Main Window                                                            |
//+------------------------------------------------------------------+ 
  
 bool CMainWindow::CreatMainWindow(const long chart_id,const int window,const string caption_text,const int x,const int y)
{
   CreateWindow(chart_id,window,caption_text,x,y);
   if(!Create_lbl_trang_thai_bot())
      return false;  
   if(!Create_btn_trang_thai_bot())
      return false;
   if(!Create_lbl_xu_huong_tay())
      return false;
   if(!Create_btn_xu_huong_tay())
      return false;
   if(!Create_edt_tinh_dolla())
      return false;
    if(!Create_edt_tinh_lot())
      return false;
   if(!Create_edt_tinh_pip())
      return false;
   if(!Create_btn_tinh_dolla())
      return false;
   if(!Create_btn_tinh_lot())
      return false;
   if(!Create_btn_tinh_pip())
      return false;
   if(!Create_lbl_thong_bao())
      return false;
      
   if(!Create_lbl_cat_lo_cham_band())
      return false;
   if(!Create_btn_cat_lo_cham_band())
      return false;
   return true;
   
} 
//////////////////////////// KHOI TAO CAC DOI TUONG TRONG BANG////////////////////////////
//+------------------------------------------------------------------+  
bool CMainWindow::Create_lbl_trang_thai_bot(void)
{
   string name=CElement::ProgramName()+"_lbl_trang_thai_bot_"+(string)CElement::Id();
   int x=m_x +2;
   int y=m_y+HEADER_WITH+GAP_OFFSET;
   
   if(!lbl_trang_thai_bot.Create(m_chart_id,name,m_subwin,x,y))
   {
      return false;
   }
   //--- Set properties
   lbl_trang_thai_bot.Description("TRANG THAI CUA BOT");
   lbl_trang_thai_bot.Font(FONT_TEXT_TYPE);
   lbl_trang_thai_bot.FontSize(FONT_TEXT_SIZE);
   lbl_trang_thai_bot.Color(clrYellow);
   lbl_trang_thai_bot.Selectable(false);
   lbl_trang_thai_bot.Z_Order(m_button_zorder);
   lbl_trang_thai_bot.Tooltip("\n");
//--- Store coordinates
   lbl_trang_thai_bot.X(x);
   lbl_trang_thai_bot.Y(y);
//--- Margins from the edge point
   lbl_trang_thai_bot.XGap(x-m_x);
   lbl_trang_thai_bot.YGap(y-m_y);
//--- Store the size
   lbl_trang_thai_bot.XSize(lbl_trang_thai_bot.X_Size());
   lbl_trang_thai_bot.YSize(lbl_trang_thai_bot.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(lbl_trang_thai_bot);
   return(true);
}

//+------------------------------------------------------------------+  
bool CMainWindow::Create_btn_trang_thai_bot(void)
{
   string name=CElement::ProgramName()+"_btn_trang_thai_bot_"+(string)CElement::Id();
   int x=m_x+158;
   int y=m_y+HEADER_WITH;
   
   if(!btn_trang_thai_bot.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH,BUTTON_HIGH))
      return false;
   btn_trang_thai_bot.SetString(OBJPROP_TEXT,"ON");
   btn_trang_thai_bot.Color(clrBlack);
   btn_trang_thai_bot.BackColor(clrDeepSkyBlue);
   btn_trang_thai_bot.Corner(m_corner);
   btn_trang_thai_bot.Selectable(false);
   btn_trang_thai_bot.Z_Order(2);
   btn_trang_thai_bot.Tooltip("Trang Thai cua bot");
   btn_trang_thai_bot.X(x);
   btn_trang_thai_bot.Y(y);
   btn_trang_thai_bot.XGap(x-m_x);
   btn_trang_thai_bot.YGap(y-m_y);
   btn_trang_thai_bot.XSize(btn_trang_thai_bot.X_Size());
   btn_trang_thai_bot.YSize(btn_trang_thai_bot.Y_Size());
   CElement::AddToArray(btn_trang_thai_bot);
   return true;
}

//+------------------------------------------------------------------+  
bool CMainWindow::Create_lbl_xu_huong_tay(void)
{
   string name=CElement::ProgramName()+"_lbl_xu_huong_tay_"+(string)CElement::Id();
   int x=m_x +2;
   int y=m_y+HEADER_WITH+GAP_OFFSET+BUTTON_HIGH+2;
   
   if(!lbl_xu_huong_tay.Create(m_chart_id,name,m_subwin,x,y))
   {
      return false;
   }
   //--- Set properties
   lbl_xu_huong_tay.Description("XU HUONG LENH TAY");
   lbl_xu_huong_tay.Font(FONT_TEXT_TYPE);
   lbl_xu_huong_tay.FontSize(FONT_TEXT_SIZE);
   lbl_xu_huong_tay.Color(clrYellow);
   lbl_xu_huong_tay.Corner(m_corner);
   lbl_xu_huong_tay.Selectable(false);
   lbl_xu_huong_tay.Z_Order(m_button_zorder);
   lbl_xu_huong_tay.Tooltip("\n");
//--- Store coordinates
   lbl_xu_huong_tay.X(x);
   lbl_xu_huong_tay.Y(y);
//--- Margins from the edge point
   lbl_xu_huong_tay.XGap(x-m_x);
   lbl_xu_huong_tay.YGap(y-m_y);
//--- Store the size
   lbl_xu_huong_tay.XSize(lbl_xu_huong_tay.X_Size());
   lbl_xu_huong_tay.YSize(lbl_xu_huong_tay.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(lbl_xu_huong_tay);
   return(true);
   
}


//+------------------------------------------------------------------+  
bool CMainWindow::Create_btn_xu_huong_tay(void)
{
   string name=CElement::ProgramName()+"_btn_xu_huong_tay_"+(string)CElement::Id();
   int x=m_x+158;
   int y=m_y+HEADER_WITH+GAP_OFFSET+BUTTON_HIGH-3;
   
   if(!btn_xu_huong_tay.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH,BUTTON_HIGH))
      return false;
   btn_xu_huong_tay.SetString(OBJPROP_TEXT,"OFF");
   btn_xu_huong_tay.Color(clrBlue);
   btn_xu_huong_tay.BackColor(clrGray);
   btn_xu_huong_tay.Corner(m_corner);
   btn_xu_huong_tay.Selectable(false);
   btn_xu_huong_tay.Z_Order(2);
   btn_xu_huong_tay.Tooltip("Chon Xu huong thu cong");
   btn_xu_huong_tay.X(x);
   btn_xu_huong_tay.Y(y);
   btn_xu_huong_tay.XGap(x-m_x);
   btn_xu_huong_tay.YGap(y-m_y);
   btn_xu_huong_tay.XSize(btn_xu_huong_tay.X_Size());
   btn_xu_huong_tay.YSize(btn_xu_huong_tay.Y_Size());
   CElement::AddToArray(btn_xu_huong_tay);
   return true;
}

//+------------------------------------------------------------------+  
bool CMainWindow::Create_edt_tinh_dolla(void)
{
   string name=CElement::ProgramName()+"_edt_tinh_dolla_"+(string)CElement::Id();
   int x=m_x+2;
   int y=m_y+HEADER_WITH+GAP_OFFSET+2*BUTTON_HIGH;
   if(!edt_tinh_dolla.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   edt_tinh_dolla.SetString(OBJPROP_TEXT,DoubleToString(0,2));
   edt_tinh_dolla.Color(clrBlack);
   edt_tinh_dolla.BackColor(clrWhite);
   edt_tinh_dolla.Corner(m_corner);
   edt_tinh_dolla.Selectable(false);
   edt_tinh_dolla.Z_Order(2);
   edt_tinh_dolla.Tooltip("Nhap so tien can tinh");
   edt_tinh_dolla.X(x);
   edt_tinh_dolla.Y(y);
   edt_tinh_dolla.XGap(x-m_x);
   edt_tinh_dolla.YGap(y-m_y);
   edt_tinh_dolla.XSize(edt_tinh_dolla.X_Size());
   edt_tinh_dolla.YSize(edt_tinh_dolla.Y_Size());
   CElement::AddToArray(edt_tinh_dolla);
   return true;
}
//+------------------------------------------------------------------+  
bool CMainWindow::Create_edt_tinh_lot(void)
{
   string name=CElement::ProgramName()+"_edt_tinh_lot_"+(string)CElement::Id();
   int x=m_x+2+BUTTON_WITH;
   int y=m_y+HEADER_WITH+GAP_OFFSET+2*BUTTON_HIGH;
   if(!edt_tinh_lot.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   int lotdecimal=0;
   double lot_step=::MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) lotdecimal= 2;
   if(lot_step==0.05) lotdecimal= 2;
   if(lot_step==0.1) lotdecimal= 1;  
   
   edt_tinh_lot.SetString(OBJPROP_TEXT,DoubleToString(0,lotdecimal));
   edt_tinh_lot.Color(clrBlack);
   edt_tinh_lot.BackColor(clrWhite);
   edt_tinh_lot.Corner(m_corner);
   edt_tinh_lot.Selectable(false);
   edt_tinh_lot.Z_Order(2);
   edt_tinh_lot.Tooltip("Nhap so lot can tinh");
   edt_tinh_lot.X(x);
   edt_tinh_lot.Y(y);
   edt_tinh_lot.XGap(x-m_x);
   edt_tinh_lot.YGap(y-m_y);
   edt_tinh_lot.XSize(edt_tinh_lot.X_Size());
   edt_tinh_lot.YSize(edt_tinh_lot.Y_Size());
   CElement::AddToArray(edt_tinh_lot);
   return true;
}
//+------------------------------------------------------------------+  
bool CMainWindow::Create_edt_tinh_pip(void)
{
   string name=CElement::ProgramName()+"_edt_tinh_pip_"+(string)CElement::Id();
   int x=m_x+2+2*BUTTON_WITH;
   int y=m_y+HEADER_WITH+GAP_OFFSET+2*BUTTON_HIGH;
   if(!edt_tinh_pip.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   edt_tinh_pip.SetString(OBJPROP_TEXT,IntegerToString(0));
   edt_tinh_pip.Color(clrBlack);
   edt_tinh_pip.BackColor(clrWhite);
   edt_tinh_pip.Corner(m_corner);
   edt_tinh_pip.Selectable(false);
   edt_tinh_pip.Z_Order(2);
   edt_tinh_pip.Tooltip("Nhap so pip can tinh");
   edt_tinh_pip.X(x);
   edt_tinh_pip.Y(y);
   edt_tinh_pip.XGap(x-m_x);
   edt_tinh_pip.YGap(y-m_y);
   edt_tinh_pip.XSize(edt_tinh_pip.X_Size());
   edt_tinh_pip.YSize(edt_tinh_pip.Y_Size());
   CElement::AddToArray(edt_tinh_pip);
   return true;
}

//+------------------------------------------------------------------+  
bool CMainWindow::Create_btn_tinh_dolla(void)
{
   string name=CElement::ProgramName()+"_btn_tinh_dolla_"+(string)CElement::Id();
   int x=m_x+2;
   int y=m_y+HEADER_WITH+2*GAP_OFFSET+3*BUTTON_HIGH;
   if(!btn_tinh_dolla.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   btn_tinh_dolla.SetString(OBJPROP_TEXT,"TINH $");
   btn_tinh_dolla.Color(clrWhite);
   btn_tinh_dolla.BackColor(clrGreen);
   btn_tinh_dolla.Corner(m_corner);
   btn_tinh_dolla.Selectable(false);
   btn_tinh_dolla.Z_Order(2);
   btn_tinh_dolla.Tooltip("Thuc hien tinh theo Dolla");
   btn_tinh_dolla.X(x);
   btn_tinh_dolla.Y(y);
   btn_tinh_dolla.XGap(x-m_x);
   btn_tinh_dolla.YGap(y-m_y);
   btn_tinh_dolla.XSize(btn_tinh_dolla.X_Size());
   btn_tinh_dolla.YSize(btn_tinh_dolla.Y_Size());
   CElement::AddToArray(btn_tinh_dolla);
   return true;
}

bool CMainWindow::Create_btn_tinh_lot(void)
{
   string name=CElement::ProgramName()+"_btn_tinh_lot_"+(string)CElement::Id();
   int x=m_x+2+BUTTON_WITH;
   int y=m_y+HEADER_WITH+2*GAP_OFFSET+3*BUTTON_HIGH;
   if(!btn_tinh_lot.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   btn_tinh_lot.SetString(OBJPROP_TEXT,"TINH LOTS");
   btn_tinh_lot.Color(clrWhite);
   btn_tinh_lot.BackColor(clrGreen);
   btn_tinh_lot.Corner(m_corner);
   btn_tinh_lot.Selectable(false);
   btn_tinh_lot.Z_Order(2);
   btn_tinh_lot.Tooltip("Thuc hien tinh so Lot");
   btn_tinh_lot.X(x);
   btn_tinh_lot.Y(y);
   btn_tinh_lot.XGap(x-m_x);
   btn_tinh_lot.YGap(y-m_y);
   btn_tinh_lot.XSize(btn_tinh_lot.X_Size());
   btn_tinh_lot.YSize(btn_tinh_lot.Y_Size());
   CElement::AddToArray(btn_tinh_lot);
   return true;
}

bool CMainWindow::Create_btn_tinh_pip(void)
{
   string name=CElement::ProgramName()+"_btn_tinh_pip_"+(string)CElement::Id();
   int x=m_x+2+2*BUTTON_WITH;
   int y=m_y+HEADER_WITH+2*GAP_OFFSET+3*BUTTON_HIGH;
   if(!btn_tinh_pip.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   btn_tinh_pip.SetString(OBJPROP_TEXT,"TINH PIPS");
   btn_tinh_pip.Color(clrWhite);
   btn_tinh_pip.BackColor(clrGreen);
   btn_tinh_pip.Corner(m_corner);
   btn_tinh_pip.Selectable(false);
   btn_tinh_pip.Z_Order(2);
   btn_tinh_pip.Tooltip("Thuc hien tinh so Pips");
   btn_tinh_pip.X(x);
   btn_tinh_pip.Y(y);
   btn_tinh_pip.XGap(x-m_x);
   btn_tinh_pip.YGap(y-m_y);
   btn_tinh_pip.XSize(btn_tinh_pip.X_Size());
   btn_tinh_pip.YSize(btn_tinh_pip.Y_Size());
   CElement::AddToArray(btn_tinh_pip);
   return true;
}
bool CMainWindow::Create_lbl_thong_bao(void)
{
   string name=CElement::ProgramName()+"_lbl_thong_bao_"+(string)CElement::Id();
   int x=m_x +2;
   int y=m_y+HEADER_WITH+3*GAP_OFFSET+5*BUTTON_HIGH+10;
   
   if(!lbl_thong_bao.Create(m_chart_id,name,m_subwin,x,y))
   {
      return false;
   }
   //--- Set properties
   lbl_thong_bao.Description("XU HUONG HIEN TAI:");
   lbl_thong_bao.Font(FONT_TEXT_TYPE);
   lbl_thong_bao.FontSize(FONT_TEXT_SIZE);
   lbl_thong_bao.Color(clrYellow);
   lbl_thong_bao.Corner(m_corner);
   lbl_thong_bao.Selectable(false);
   lbl_thong_bao.Z_Order(m_button_zorder);
   lbl_thong_bao.Tooltip("\n");
//--- Store coordinates
   lbl_thong_bao.X(x);
   lbl_thong_bao.Y(y);
//--- Margins from the edge point
   lbl_thong_bao.XGap(x-m_x);
   lbl_thong_bao.YGap(y-m_y);
//--- Store the size
   lbl_thong_bao.XSize(lbl_thong_bao.X_Size());
   lbl_thong_bao.YSize(lbl_thong_bao.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(lbl_thong_bao);
   return(true);
}

bool CMainWindow::Create_lbl_cat_lo_cham_band(void)
{
   string name=CElement::ProgramName()+"_lbl_cat_lo_cham_band_"+(string)CElement::Id();
   int x=m_x +2;
   int y=m_y+HEADER_WITH+2*GAP_OFFSET+4*BUTTON_HIGH+10;
   
   if(!lbl_cat_lo_cham_band.Create(m_chart_id,name,m_subwin,x,y))
   {
      return false;
   }
   //--- Set properties
   lbl_cat_lo_cham_band.Description("CAT LO KHI CHAM BAND");
   lbl_cat_lo_cham_band.Font(FONT_TEXT_TYPE);
   lbl_cat_lo_cham_band.FontSize(FONT_TEXT_SIZE);
   lbl_cat_lo_cham_band.Color(clrYellow);
   lbl_cat_lo_cham_band.Corner(m_corner);
   lbl_cat_lo_cham_band.Selectable(false);
   lbl_cat_lo_cham_band.Z_Order(m_button_zorder);
   lbl_cat_lo_cham_band.Tooltip("\n");
//--- Store coordinates
   lbl_cat_lo_cham_band.X(x);
   lbl_cat_lo_cham_band.Y(y);
//--- Margins from the edge point
   lbl_cat_lo_cham_band.XGap(x-m_x);
   lbl_cat_lo_cham_band.YGap(y-m_y);
//--- Store the size
   lbl_cat_lo_cham_band.XSize(lbl_cat_lo_cham_band.X_Size());
   lbl_cat_lo_cham_band.YSize(lbl_cat_lo_cham_band.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(lbl_cat_lo_cham_band);
   return true;
}
//+------------------------------------------------------------------+  
bool CMainWindow::Create_btn_cat_lo_cham_band(void)
{
   string name=CElement::ProgramName()+"_btn_cat_lo_cham_band_"+(string)CElement::Id();
   int x=m_x+2+2*BUTTON_WITH;
   int y=m_y+HEADER_WITH+2*GAP_OFFSET+4*BUTTON_HIGH+5;;
   
   if(!btn_cat_lo_cham_band.Create(m_chart_id,name,m_subwin,x,y,BUTTON_WITH-5,BUTTON_HIGH))
      return false;
   btn_cat_lo_cham_band.SetString(OBJPROP_TEXT,"ON");
   btn_cat_lo_cham_band.Color(clrBlack);
   btn_cat_lo_cham_band.BackColor(clrDeepSkyBlue);
   btn_cat_lo_cham_band.Corner(m_corner);
   btn_cat_lo_cham_band.Selectable(false);
   btn_cat_lo_cham_band.Z_Order(2);
   btn_cat_lo_cham_band.Tooltip("Trang Thai cua bot");
   btn_cat_lo_cham_band.X(x);
   btn_cat_lo_cham_band.Y(y);
   btn_cat_lo_cham_band.XGap(x-m_x);
   btn_cat_lo_cham_band.YGap(y-m_y);
   btn_cat_lo_cham_band.XSize(btn_cat_lo_cham_band.X_Size());
   btn_cat_lo_cham_band.YSize(btn_cat_lo_cham_band.Y_Size());
   CElement::AddToArray(btn_cat_lo_cham_band);
   return true;
}
