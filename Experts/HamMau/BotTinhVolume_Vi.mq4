//+------------------------------------------------------------------+
//|                                                 TestHorizone.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property  indicator_chart_window
#include <Controls/Panel.mqh>
#include <Controls\Dialog.mqh>
enum ENUM_RUI_RO{
   RISK_MONEY =0,//THEO TIEN ($)
   RISK_PERCENTAGE=1,//THEO PHAN TRAM (%)
};
input ENUM_RUI_RO inpLoaiRuiRo=RISK_PERCENTAGE;// LOAI RUI RO LUA CHON:
input double inpSoTienChoMotLenh=30;// RUI RO THEO ($):
input double inpRuiRoChoMotLenh=0.5;//RUI RO THEO (%):
int accNumber=48309193;//10131566;
string accName="tran thi minh phuong";
CPanel myPanel;
CDialog myDialog;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double _TyLeRRMacDinh=2;
double _RuiRoMacDinh=30;//$
double _price=0;
int _LoaiLenhVao=-1;
double _GiaVaoLenh=0;
double _GiaSL=0;
double _GiaTP=0;
double _SoPipSL=0;
double _SoPipTP=0;
double _SoTienSL=0;
double _SoTienTP=0;
double _RiskReward=0;
double _KhoiLuong=0;


struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,3,3024};

int glbticket=-1;
int type_order=OP_BUY;
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
      //FunKiemTraHetHan();
      if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;

      if(IsDemo()==false)
      {
         MessageBox("Bot chi dung de thu nghiem tai khoan Demo. Lien he tac gia de cai dat tai khoan Real. SDT: 0971926248");
        /* string TenAcc=FunChuyenChuHoaSangChuThuong(AccountName());
         if(StringFind(TenAcc,accName,0)<0)
         {
            MessageBox("Tai khoan MT4 khong dung, Lien he tac gia de cai dat lai. SDT: 0971926248");
            return INIT_FAILED;
         }  
         */
      }
      
      if(inpLoaiRuiRo==RISK_MONEY)
      _RuiRoMacDinh=inpSoTienChoMotLenh;
      else _RuiRoMacDinh=inpRuiRoChoMotLenh;
      myPanel.Create(0,"Bang",0,0,70,159,475);
      myPanel.ColorBackground(clrDarkSlateGray);
      FunLabelCreate(0,"LableRisk",0,20,75,0,"QUAN TRI RUI RO","Arial",9,clrYellow);
      
     
      
      if(inpLoaiRuiRo==RISK_MONEY)
         FunLabelCreate(0,"lblRuiRo",0,4,110,0,"RUI RO($):","Arial",9,clrRed,0);
      else FunLabelCreate(0,"lblRuiRo",0,4,110,0,"RUI RO(%):","Arial",9,clrRed,0);
      
      FunEditCreate(0,"edtRuiRo",0,80,105,70,30,DoubleToString(_RuiRoMacDinh,2),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
      FunButtonCreate(0,"btnTinhSell",0,4,140,70,80,CORNER_LEFT_UPPER,"Tinh Sell","Arial",9,clrBlue,clrPink);
      FunButtonCreate(0,"btnTinhBuy",0,80,140,75,81,CORNER_LEFT_UPPER,"Tinh Buy","Arial",9,clrYellow,clrBlue);
      FunButtonCreate(0,"btnVaoLenh",0,4,225,150,50,CORNER_LEFT_UPPER,"LENH THI TRUONG","Arial",9,clrBlack,clrTurquoise);
      FunButtonCreate(0,"btnLenhCho",0,4,305,150,50,CORNER_LEFT_UPPER,"LENH CHO","Arial",9,clrBlack,clrYellow);

      FunButtonCreate(0,"btnGuiLenhCho",0,4,360,150,50,CORNER_LEFT_UPPER,"THUC HIEN LENH CHO","Arial",9,clrBlack,clrTurquoise);
      FunButtonCreate(0,"btnHuy",0,4,415,150,50,CORNER_LEFT_UPPER,"HUY","Arial",10,clrBlack,clrRed);
      
      if(_LoaiLenhVao>=0)
      {
        
            
         FunHLineCreate(0,"hLineGiaSL",0,_GiaSL,clrRed,STYLE_SOLID,1,true);
         FunTextCreate(0,"txtGiaSL",FunTextHienThiSL(),0,ObjectGet("hLineGiaSL", OBJPROP_PRICE1),clrGray);
           
         FunHLineCreate(0,"hLineGiaTP",0,_GiaTP,clrLimeGreen,STYLE_SOLID,1,true);
         FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrGray);
         if(_LoaiLenhVao>1)
         {
            FunHLineCreate(0,"hLineGiaVaoLenh",0,_GiaVaoLenh,clrBlue,STYLE_SOLID,1,true);
            FunTextCreate(0,"txtGiaVaoLenh",FunTextHienThiLenhCho(),0,ObjectGet("hLineGiaVaoLenh", OBJPROP_PRICE1),clrGray);
         }
      }
      
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---

     FunLabelDelete(0,"lblRuiRo");
     FunEditDelete(0,"edtRuiRo");
     FunButtonDelete(0,"btnTinhSell");
     FunButtonDelete(0,"btnTinhBuy");
     FunButtonDelete(0,"btnVaoLenh");
     FunButtonDelete(0,"btnLenhCho");
     FunButtonDelete(0,"btnGuiLenhCho");
     FunButtonDelete(0,"btnHuy");        
      FunHLineDelete(0,"hLineGiaSL");
      FunHLineDelete(0,"hLineGiaTP");
      FunHLineDelete(0,"hLineGiaVaoLenh");
      ObjectDelete(0,"txtGiaSL");
       ObjectDelete(0,"txtGiaTP");
        ObjectDelete(0,"txtGiaVaoLenh");
        ObjectDelete(0,"LableRisk");
       ObjectsDeleteAll(0);
        myPanel.Destroy();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   /*
   //Comment(ObjectGet("GiaCaoNhat",OBJPROP_PRICE1));
      if(IsTesting()|| IsDemo())
      {
         if(FunKiemTraSangNenMoiChua())
         {
            if(glbticket<=0)
            {
               if(FunKiemTraBuySell()==-1)
               {
                  glbticket=FunVaoLenh(OP_SELL);
               }
               else if(FunKiemTraBuySell()==1)
               {
                  glbticket=FunVaoLenh(OP_BUY);
               }
            }
         }
         if(glbticket>0)
         {
            if(OrderSelect(glbticket,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderCloseTime()>0) glbticket=-1;
            }
         }
      }
   */
  }
string FunChuyenChuHoaSangChuThuong(string name)
{
    string tam=name;
    StringToLower(tam);
    return tam;
}


//+------------------------------------------------------------------+ 
bool FunKiemDaHetHanChua(NgayThang &HanCanKiemTra)// False: Chua; True: Roi
{
   bool kt=false;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;
    }
    return kt;
}

//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+

bool FunHLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=true,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunHLineDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Get price horizontal line                                         |
//+------------------------------------------------------------------+
double FunHlineGetPrice(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)<0)
   {
      Print(__FUNCTION__,
            ": failed to finde horizontal line: ",name, " Error code = ",GetLastError());
            return false;
   }
   double price=ObjectGet(name,OBJPROP_PRICE1);
//--- successful execution
   return price;
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool FunHLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the text                                      |
//+------------------------------------------------------------------+
bool FunTextCreate( const int chart_ID=0,
               const string name="text",
               const string text="text",
               const int       sub_window=0,      // subwindow index
               double    price=0,           // price
               const color     clr=clrYellow)
{
    if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //--- reset the error value
      if(ObjectFind(chart_ID,name)>=0)
      {
         ObjectDelete(chart_ID,name);
      }
      ResetLastError();
      //--- create a text
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,Time[0],price))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());
      return(false);
     }
    ObjectSetText(name,text,10,NULL,clr);

    //ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_LEFT);    
    return true;  
}
//+------------------------------------------------------------------+
//| Move the text                                     |
//+------------------------------------------------------------------+
bool FunTextMove(const string name="Text", // object name
              datetime     time=0,      // anchor point time coordinate
              double       price=0)     // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunTextChange(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const string text="Text") // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the button                                      |
//+------------------------------------------------------------------+
bool FunButtonCreate(const string name="text",
               const string text="text",
               const int       sub_window=0,      // subwindow index
               double    price=0,           // price
               const color     clr=clrYellow)
{
    if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //--- reset the error value
      ResetLastError();
      //--- create a text
   if(!ObjectCreate(name,OBJ_TEXT,sub_window,Time[0],price))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());
      return(false);
     }
    ObjectSetText(name,text,10,NULL,clr);
    return true;  
}               
//+------------------------------------------------------------------+
//| Delete a object                                         |
//+------------------------------------------------------------------+
bool FunObjectDelete(
                 const string name="TextGiaCaoNhat") //  name
  {
//--- reset the error value
   ResetLastError();
//--- delete a texy
   if(!ObjectDelete(name))
     {
      Print(__FUNCTION__,
            ": failed to delete a object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool FunButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunButtonDelete(chart_ID,name);
   }
//--- create the charbutton
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Change button text                                               |
//+------------------------------------------------------------------+
bool FunButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change button text                                               |
//+------------------------------------------------------------------+
bool FunButtonColorTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const color clr=clrBlack)   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the text color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the button                                                |
//+------------------------------------------------------------------+
bool FunButtonDelete(const long   chart_ID=0,    // chart's ID
                  const string name="Button") // button name
  {
//--- reset the error value
   ResetLastError();
//--- delete the button
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  //+------------------------------------------------------------------+
//| Create a bitmap in the chart window                              |
//+------------------------------------------------------------------+
bool FunBitmapCreate(const long            chart_ID=0,        // chart's ID
                  const string          name="Bitmap",     // bitmap name
                  const int             sub_window=0,      // subwindow index
                  datetime              time=0,            // anchor point time
                  double                price=0,           // anchor point price
                  const string          file="",           // bitmap file name
                  const int             width=10,          // visibility scope X coordinate
                  const int             height=10,         // visibility scope Y coordinate
                  const int             x_offset=0,        // visibility scope shift by X axis
                  const int             y_offset=0,        // visibility scope shift by Y axis
                  const color           clr=clrRed,        // border color when highlighted
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style when highlighted
                  const int             point_width=1,     // move point size
                  const bool            back=false,        // in the background
                  const bool            selection=false,   // highlight to move
                  const bool            hidden=true,       // hidden in the object list
                  const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeBitmapEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a bitmap
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create a bitmap in the chart window! Error code = ",GetLastError());
      return(false);
     }
//--- set the path to the image file
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,file))
     {
      Print(__FUNCTION__,
            ": failed to load the image! Error code = ",GetLastError());
      return(false);
     }
//--- set visibility scope for the image; if width or height values
//--- exceed the width and height (respectively) of a source image,
//--- it is not drawn; in the opposite case,
//--- only the part corresponding to these values is drawn
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the part of an image that is to be displayed in the visibility scope
//--- the default part is the upper left area of an image; the values allow
//--- performing a shift from this area displaying another part of the image
   ObjectSetInteger(chart_ID,name,OBJPROP_XOFFSET,x_offset);
   ObjectSetInteger(chart_ID,name,OBJPROP_YOFFSET,y_offset);
//--- set the border color when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a size of the anchor point for moving an object
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,point_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  //+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeBitmapEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
 //+------------------------------------------------------------------+
//| Delete the rectangle label                                       |
//+------------------------------------------------------------------+
bool FunRectLabelDelete(const long   chart_ID=0,       // chart's ID
                     const string name="RectLabel") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
  bool FunRectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunRectLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditCreate(const long             chart_ID=0,               // chart's ID
                const string           name="Edit",              // object name
                const int              sub_window=0,             // subwindow index
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE,       // border color
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunEditDelete(chart_ID,name);
   }
   ResetLastError();
//--- create edit field
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  //+------------------------------------------------------------------+
//| Return Edit object text                                          |
//+------------------------------------------------------------------+
bool FunEditTextGet(string      &text,        // text
                 const long   chart_ID=0,  // chart's ID
                 const string name="Edit") // object name
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditDelete(const long   chart_ID=0,  // chart's ID
                const string name="Edit") // object name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
/*******************************Đếm số thập phân sau dấu phẩy*********************************/
int FunCountDigitsNumber(double val)// Đếm sau dấu thập phân bao nhiêu chữ số
 {
   int digits=0;
   while(NormalizeDouble(val,digits)!=NormalizeDouble(val,10)) digits++;
   return digits;
 }
/*******************************Tinh khoi Luong Giao Dich*********************************/
double FunTinhKhoiLuongGiaoDich(double GiaSL, double GiaVaoLenh,double RuiRoChoPhep=1)
{
  // RuiRoChoPhep=RuiRoChoPhep*AccountBalance()/100;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double KhoiLuongGiaoDich=RuiRoChoPhep/(nTickValue*MathAbs(GiaVaoLenh-GiaSL)/MarketInfo(Symbol(),MODE_POINT));
   int digits=FunCountDigitsNumber(MarketInfo(Symbol(), MODE_LOTSTEP));
   KhoiLuongGiaoDich=NormalizeDouble(KhoiLuongGiaoDich,digits);//
   Print("Trading volume: "+DoubleToString(KhoiLuongGiaoDich,digits));
   return KhoiLuongGiaoDich;
}

/*******************************Tinh khoi Luong Giao Dich*********************************/
double FunTinhSoTienLoiLo(double GiaTP,double GiaVaoLenh,double KhoiLuong)
{
   if(GiaTP==0 || GiaVaoLenh==0) return 0;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double SoTienLoiLo=KhoiLuong*(nTickValue*MathAbs(GiaVaoLenh-GiaTP)/MarketInfo(Symbol(),MODE_POINT));
   return SoTienLoiLo;
}
/*******************************Tinh khoi Luong Giao Dich*********************************/
int FunDatLenh(int LoaiLenh,double GiaVaoLenh,double GiaSL,double GiaTP,double KhoiLuong=0.01)
{
   int ticket=-1;
   GiaVaoLenh=NormalizeDouble(GiaVaoLenh,Digits);
   GiaSL=NormalizeDouble(GiaSL,Digits);
   GiaTP=NormalizeDouble(GiaTP,Digits);
   Comment("Khoi luong:"+DoubleToString(KhoiLuong,Digits)+"\nLoai lenh:"+FunTenLenhCho(LoaiLenh)+"\nGia:"+DoubleToString(GiaVaoLenh,Digits)+"\nGia SL:"+DoubleToString(GiaSL,Digits)+"\nGia TP:"+DoubleToString(GiaTP,Digits));
  // double KhoiLuong=FunTinhKhoiLuongGiaoDich(GiaSL,GiaVaoLenh,RuiRoChoPhep);
   if(LoaiLenh==OP_BUY||LoaiLenh==OP_BUYLIMIT||LoaiLenh==OP_BUYSTOP)
   {
      if(LoaiLenh==OP_BUY)GiaVaoLenh=Ask;
      if(GiaSL>=GiaVaoLenh) return -1;
      if(GiaTP>0 && GiaTP<=GiaVaoLenh) return -1;
   }
   else if(LoaiLenh==OP_SELL||LoaiLenh==OP_SELLLIMIT||LoaiLenh==OP_SELLSTOP)
   {
      if(LoaiLenh==OP_SELL) GiaVaoLenh=Bid;
      if(GiaSL<=GiaVaoLenh) return -1;
      if(GiaTP>0 && GiaTP>=GiaVaoLenh) return -1;
   }
   else return -1;
   if(_KhoiLuong<=0) return -1;
   switch (LoaiLenh)
   {
      case OP_BUY:
         ticket=OrderSend(Symbol(),OP_BUY,KhoiLuong,Ask,100,GiaSL,GiaTP,"Buy order",0,0,clrBlue);
         break;
      case OP_SELL:
         ticket=OrderSend(Symbol(),OP_SELL,KhoiLuong,Bid,100,GiaSL,GiaTP,"Sell order",0,0,clrRed);
         break;
      case OP_BUYLIMIT:
         ticket=OrderSend(Symbol(),OP_BUYLIMIT,KhoiLuong,GiaVaoLenh,100,GiaSL,GiaTP,"Buy order",0,0,NULL);
         break;
      case OP_SELLLIMIT:
         ticket=OrderSend(Symbol(),OP_SELLLIMIT,KhoiLuong,GiaVaoLenh,100,GiaSL,GiaTP,"Sell order",0,0,NULL);
         break;
      case OP_BUYSTOP:
         ticket=OrderSend(Symbol(),OP_BUYSTOP,KhoiLuong,GiaVaoLenh,100,GiaSL,GiaTP,"Buy order",0,0,NULL);
         break;
      case OP_SELLSTOP:
         
         ticket=OrderSend(Symbol(),OP_SELLSTOP,KhoiLuong,GiaVaoLenh,100,GiaSL,GiaTP,"Sell order",0,0,NULL);
         break;
      default: ticket=-1; 
   }
   return ticket;
}

/*******************************Text hien thi SL*********************************/

string FunTextHienThiSL()
{
   string XauHienThi="";
   _GiaSL=FunHlineGetPrice(0,"hLineGiaSL");
   string RuiRoS="";
   double RuiRoD=0;
   
   if(_GiaSL<=0) return "Dich chuyen sai. Gia SL="+DoubleToString(_GiaSL,2);;
   if(_LoaiLenhVao==OP_SELL) _GiaVaoLenh=Bid;
   else if(_LoaiLenhVao==OP_BUY) _GiaVaoLenh=Ask;
   if(_LoaiLenhVao==OP_BUY||_LoaiLenhVao==OP_BUYLIMIT||_LoaiLenhVao==OP_BUYSTOP)
   {
      _SoPipSL=(_GiaVaoLenh-_GiaSL)/(10*Point);
      _SoPipSL=MathFloor(_SoPipSL*100)/100;
   }
   else
   {
      _SoPipSL=(_GiaSL-_GiaVaoLenh)/(10*Point);
      _SoPipSL=MathFloor(_SoPipSL*100)/100;
   }
   if(_SoPipSL<0)
   {
   
      //return "Dich chuyen sai";
      _SoPipSL=MathAbs(_SoPipSL);
      _SoPipTP=_TyLeRRMacDinh*_SoPipSL;
      if(_GiaSL < _GiaVaoLenh)
         _GiaTP=_GiaVaoLenh+_SoPipTP*10*Point;
      else 
         _GiaTP=_GiaVaoLenh-_SoPipTP*10*Point;
         _GiaTP =NormalizeDouble(_GiaTP,Digits);
       FunHLineCreate(0,"hLineGiaTP",0,_GiaTP,clrGreen,STYLE_SOLID,1);
       switch (_LoaiLenhVao)
      {
         case OP_BUY:
            _LoaiLenhVao=OP_SELL;           
         break;
         case OP_SELL:
             _LoaiLenhVao=OP_BUY;
         break;       
         default: 
            _LoaiLenhVao=FunKiemTraLenhCho();
            FunTextChange(0,"txtGiaVaoLenh","Lenh "+FunTenLenhCho(_LoaiLenhVao));
      }
      FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrYellow);
      
   }
   FunEditTextGet(RuiRoS,0,"edtRuiRo");
   RuiRoD=StringToDouble(RuiRoS);
   if(inpLoaiRuiRo==RISK_PERCENTAGE)
   {
      RuiRoD=RuiRoD*AccountBalance()/100;
   }
   _KhoiLuong=FunTinhKhoiLuongGiaoDich(_GiaSL,_GiaVaoLenh,RuiRoD);
   if(_KhoiLuong==0) return "Khoi luong bang 0";
   _SoTienSL=FunTinhSoTienLoiLo(_GiaSL,_GiaVaoLenh,_KhoiLuong);
   if(ObjectFind(0,"hLineGiaVaoLenh")>=0)
      XauHienThi=" Pips: "+DoubleToString(_SoPipSL,2)+" Loss($): "+DoubleToString(_SoTienSL,2)+"(-"+DoubleToString(_SoTienSL*100/AccountBalance(),2)+"%)"+" Volumes: "+DoubleToString(_KhoiLuong,2);
   else 
      XauHienThi=FunTenLenhCho(_LoaiLenhVao)+" Pips: "+DoubleToString(_SoPipSL,2)+" Loss($): "+DoubleToString(_SoTienSL,2)+"(-"+DoubleToString(_SoTienSL*100/AccountBalance(),2)+"%)"+" Volumes: "+DoubleToString(_KhoiLuong,2);
   return XauHienThi;
}

/*******************************Text hien thi TP*********************************/
string FunTextHienThiTP()
{
   string XauHienThi="";
   _GiaTP=FunHlineGetPrice(0,"hLineGiaTP");
   
   if(_GiaTP<=0) return "Dich chuyen sai. Gia TP="+DoubleToString(_GiaTP,2);;
   if(_LoaiLenhVao==OP_SELL) _GiaVaoLenh=Bid;
   else if(_LoaiLenhVao==OP_BUY) _GiaVaoLenh=Ask;

   if(_LoaiLenhVao==OP_BUY||_LoaiLenhVao==OP_BUYLIMIT||_LoaiLenhVao==OP_BUYSTOP)
   {
      _SoPipTP=(_GiaTP-_GiaVaoLenh)/(10*Point);
      _SoPipTP=MathFloor(_SoPipTP*100)/100;
   }
   else
   {
      _SoPipTP=(_GiaVaoLenh-_GiaTP)/(10*Point);
      _SoPipTP=MathFloor(_SoPipTP*100)/100;
   }
   if(_SoPipTP<=0)return "Dich chuyen sai.";
   _SoTienTP=FunTinhSoTienLoiLo(_GiaTP,_GiaVaoLenh,_KhoiLuong);
   XauHienThi="Pips: "+DoubleToString(_SoPipTP,2)+" Profits($): "+DoubleToString(_SoTienTP,2)+"(+"+DoubleToString(_SoTienTP*100/AccountBalance(),2)+"%)"+" RR: "+DoubleToString(_SoTienTP/_SoTienSL,2);
   return XauHienThi;
}
/*******************************Text hien thi lenh cho*********************************/
string FunTextHienThiLenhCho()
{
   _LoaiLenhVao=FunKiemTraLenhCho();
   return FunTenLenhCho(_LoaiLenhVao);
}

/*******************************Text hien thi Khoang cach vao lenh voiw gia hien tai*********************************/
string DunHienThiKhoangCachVaGia()
{
   return "";
}

/*******************************Kiem Tra lenh cho*********************************/
int FunKiemTraLenhCho()
{
   _GiaSL= FunHlineGetPrice(0,"hLineGiaSL");
   _GiaTP=FunHlineGetPrice(0,"hLineGiaTP");
   _GiaVaoLenh=FunHlineGetPrice(0,"hLineGiaVaoLenh");
   int LoaiLenhVao=-1;
   if(_GiaVaoLenh<Bid)
   {
        if(_GiaSL>_GiaVaoLenh) LoaiLenhVao=OP_SELLSTOP;
        else LoaiLenhVao=OP_BUYLIMIT;
   }
   else
   {
      if(_GiaSL<_GiaVaoLenh) LoaiLenhVao=OP_BUYSTOP;
      else LoaiLenhVao=OP_SELLLIMIT;
   }
   return LoaiLenhVao;
}
/*******************************Kiem Tra lenh cho*********************************/
string FunTenLenhCho(int LoaiLenhVao)
{
   switch(LoaiLenhVao)
   {
      case OP_BUY:
        return "LENH BUY";
        //return "BUY ORDER";
      case OP_SELL:
         return "LENH SELL";
         //return "SELL ORDER";
      case OP_BUYLIMIT:
         return "LENH BUYLIMIT";
         //return "BUY LIMIT";
      case OP_SELLLIMIT:
          return "LENH SELLLIMIT";
          //return "SELL LIMIT";
      case OP_BUYSTOP:
         return "LENH BUYSTOP";
         //return "BUY STOP";
      case OP_SELLSTOP:       
          return "LENH SELLSTOP";
          //return "SELL STOP";
   }
   return "ERROR";
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(FunKiemDaHetHanChua(NgayHetHan)==true) return;
   if(id==CHARTEVENT_OBJECT_DRAG )
   {
      
      if(sparam=="hLineGiaSL")
      {
         FunTextMove("txtGiaSL",Time[0],ObjectGet("hLineGiaSL",OBJPROP_PRICE1));
         FunTextChange(0,"txtGiaSL",FunTextHienThiSL());
         FunTextChange(0,"txtGiaTP",FunTextHienThiTP());
      }
      if(sparam=="hLineGiaTP")
      {
         FunTextMove("txtGiaTP",Time[0],ObjectGet("hLineGiaTP",OBJPROP_PRICE1));
         FunTextChange(0,"txtGiaTP",FunTextHienThiTP());
      }
      if(sparam=="hLineGiaVaoLenh")
      {
         FunTextMove("txtGiaVaoLenh",Time[0],ObjectGet("hLineGiaVaoLenh",OBJPROP_PRICE1));
         FunTextChange(0,"txtGiaVaoLenh",FunTextHienThiLenhCho());
         FunTextChange(0,"txtGiaSL",FunTextHienThiSL());
         FunTextChange(0,"txtGiaTP",FunTextHienThiTP());
         
      }
      
   //   ObjectMove("LableGiaCaoNhat",0,Time[0],ObjectGet("GiaCaoNhat",OBJPROP_PRICE1));
   
      ChartRedraw();
   }
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="btnTinhSell")
      {
         _LoaiLenhVao=OP_SELL;
         FunHLineCreate(0,"hLineGiaSL",0,Bid+150*Point,clrRed,STYLE_SOLID,1);
         FunTextCreate(0,"txtGiaSL",FunTextHienThiSL(),0,ObjectGet("hLineGiaSL", OBJPROP_PRICE1),clrGray);
         FunHLineCreate(0,"hLineGiaTP",0,Bid-300*Point,clrLimeGreen,STYLE_SOLID,1);
         FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrGray);
      }
       if(sparam=="btnTinhBuy")
      {
         _LoaiLenhVao=OP_BUY;
         FunHLineCreate(0,"hLineGiaSL",0,Bid-150*Point,clrRed,STYLE_SOLID,1);
         FunTextCreate(0,"txtGiaSL",FunTextHienThiSL(),0,ObjectGet("hLineGiaSL", OBJPROP_PRICE1),clrGray);
         FunHLineCreate(0,"hLineGiaTP",0,Bid+300*Point,clrLimeGreen,STYLE_SOLID,1);
         FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrGray);
      }
       if(sparam=="btnLenhCho")
      {
         _GiaVaoLenh=Bid-100*Point;
         _GiaSL=Bid-150*Point;
         _GiaTP=Bid+300*Point;
         _LoaiLenhVao=OP_BUYLIMIT;
         FunHLineCreate(0,"hLineGiaVaoLenh",0,Bid-100*Point,clrBlue,STYLE_SOLID,1);
         FunHLineCreate(0,"hLineGiaSL",0,Bid-150*Point,clrRed,STYLE_SOLID,1);
         FunHLineCreate(0,"hLineGiaTP",0,Bid+300*Point,clrLimeGreen,STYLE_SOLID,1);
         
         Print("a");
         FunTextCreate(0,"txtGiaSL",FunTextHienThiSL(),0,ObjectGet("hLineGiaSL", OBJPROP_PRICE1),clrGray);
        
        
         Print("b");
         FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrGray);
         
         Print("c");
         FunTextCreate(0,"txtGiaVaoLenh",FunTextHienThiLenhCho(),0,ObjectGet("hLineGiaVaoLenh", OBJPROP_PRICE1),clrGray);
      }
      if(sparam=="btnVaoLenh")
      {
         if(_LoaiLenhVao==OP_BUY||_LoaiLenhVao==OP_SELL)
         {
            if(FunDatLenh(_LoaiLenhVao,_GiaVaoLenh,_GiaSL,_GiaTP,_KhoiLuong)<=0)
            {
               //MessageBox("LOI DAT LENH. DO SAI SL,TP HOAC KHOI LUONG VAO LENH BANG 0");
               MessageBox("Loi thuc hien lenh. Do sai SL, TP hoac Volume bang 0");
            }
            else
            {
               //MessageBox("DAT LENH THANH CONG");
               _LoaiLenhVao=-1;
               _SoPipSL=0;
               _SoPipTP=0;
               _SoTienSL=0;
               _SoTienTP=0;
               _GiaSL=0;
               _GiaTP=0;
               _GiaVaoLenh=0;
               FunHLineDelete(0,"hLineGiaTP");
               FunHLineDelete(0,"hLineGiaSL");
               FunHLineDelete(0,"hLineGiaVaoLenh");
               ObjectDelete(0,"txtGiaSL");
               ObjectDelete(0,"txtGiaTP");
               ObjectDelete(0,"txtGiaVaoLenh");
            }
           
         }
         else if(_LoaiLenhVao==-1)
         {
            MessageBox("CHUA CAI SL, TP");
           //MessageBox("Loi. Chua cai dat SL, TP");
         }
         else 
         {
            MessageBox("CHUC NANG NAY CHI THUC HIEN CAC LENH THI TRUONG BUY SELL");
             //MessageBox("This function executes only market orders");
         }
      }
      if(sparam=="btnGuiLenhCho")
      {
          if(_LoaiLenhVao==OP_BUY||_LoaiLenhVao==OP_SELL)
         {
            MessageBox("CHUC NANG NAY CHI THUC HIEN CAC LENH CHO");
            //MessageBox("This function only executes pending orders");
         }
         else if(_LoaiLenhVao==-1)
         {
            MessageBox("CHUA CAI SL, TP");
            // MessageBox("Error. Not set SL, TP");
         }
         else 
         {
            if(FunDatLenh(_LoaiLenhVao,_GiaVaoLenh,_GiaSL,_GiaTP,_KhoiLuong)<=0)
            {
               
               MessageBox("LOI DAT LENH. DO SAI SL,TP HOAC KHOI LUONG VAO LENH BANG 0");
                //MessageBox("Order error. Due to wrong SL, TP or Volume is 0");
            }
            else
            {
              // MessageBox("DAT LENH THANH CONG");
               _LoaiLenhVao=-1;
               _SoPipSL=0;
               _SoPipTP=0;
               _SoTienSL=0;
               _SoTienTP=0;
               _GiaSL=0;
               _GiaTP=0;
               _GiaVaoLenh=0;
               FunHLineDelete(0,"hLineGiaTP");
               FunHLineDelete(0,"hLineGiaSL");
               FunHLineDelete(0,"hLineGiaVaoLenh");
               ObjectDelete(0,"txtGiaSL");
               ObjectDelete(0,"txtGiaTP");
               ObjectDelete(0,"txtGiaVaoLenh");
            }
         }
      }
      if(sparam=="btnHuy")  
      {
         _LoaiLenhVao=-1;
         _SoPipSL=0;
         _SoPipTP=0;
         _SoTienSL=0;
         _SoTienTP=0;
         _GiaSL=0;
         _GiaTP=0;
         _GiaVaoLenh=0;
         FunHLineDelete(0,"hLineGiaTP");
         FunHLineDelete(0,"hLineGiaSL");
         FunHLineDelete(0,"hLineGiaVaoLenh");
         ObjectDelete(0,"txtGiaSL");
         ObjectDelete(0,"txtGiaTP");
         ObjectDelete(0,"txtGiaVaoLenh");
      }
   }
}

/*
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChua()
 {
   static datetime _LastBar=Time[0];
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   datetime currBar=Time[0];//iTime(OrderSymbol(),0,0);
   if(_LastBar!=currBar)
   {
      _LastBar=currBar;
      return true;
   }
   else return false;
 }
 //+------------------------------------------------------------------+
 double FunTinhGiaTriBB(int ModeUpOrLow, int shift)
 {
   return iBands(Symbol(),0,20,1.5,0,PRICE_CLOSE,ModeUpOrLow,shift);
 }
 //+------------------------------------------------------------------+
 double FunTinhGiaTriRSI(int shift)
 {
   return iRSI(Symbol(),0,14,PRICE_CLOSE,shift);
 }
int FunKiemTraBuySell()//-1: tin hieu Sell, 1: Tin hieu Buy
{
   // Kiem tra buy
      
      double _RSI1=FunTinhGiaTriRSI(1);
      double _RSI2=FunTinhGiaTriRSI(2);
      
      
      if(_RSI2<30 && _RSI1>30)
      {
         double _BBThap=FunTinhGiaTriBB(MODE_LOWER,1);
         if(Close[1]<_BBThap && Open[1]<_BBThap) return 1;
      }
      if(_RSI2>70 && _RSI1<70)
      {
         double _BBCao=FunTinhGiaTriBB(MODE_UPPER,1);
         if(Close[1]>_BBCao && Open[1]>_BBCao) return -1;
      }
      return 0;
   // kiem tra sell
}
//+------------------------------------------------------------------+

int FunVaoLenh(int LoaiLenh)
{
   int _ticket=-1;
   double _KhoiLuongVaoLenh=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN); 
   if(LoaiLenh==OP_BUY)
   {
      _ticket= OrderSend(Symbol(),OP_BUY,0.01,Ask,50,Ask-500*Point,Ask+500*Point,"AutoBuy",0,0,clrBlue);
   }
   else if(LoaiLenh==OP_SELL)
   {
      _ticket= OrderSend(Symbol(),OP_SELL,0.01,Bid,50,Bid+500*Point,Bid-500*Point,"AutoSell",0,0,clrRed);
   }
   if(_ticket==-1) Print("Error order");
   return _ticket;
   
}
*/