//+------------------------------------------------------------------+
//|                                     BanTuDong_Martingel_Tung.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//input double inpKhoiLuong=0.01;//Khoi luong vao lenh(lots):
input double inpTongLenh=5;//Tong lenh toi da:
input double inpHeSoNhanKhoiLuong=1;// He so nhan khoi luong:
input int inpKhoangCachNhoiLenh=100;//Khoang cach nhoi lenh (pips):
input double inpGiaSL=0;//Gia SL (=0: khong set SL):
input double inpGiaTP=0;//Gia TP (=0: Khong set TP);
input int inpSlippage=50;
input int inpMagicNumber=12345;
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,06,3023};

int glbLenhStop=-1;
int glbTapLenh[10];
int glbTongSoLenh=0;
int glbPointKhoangGia=0;
int glbLoaiLenhDangVao;
double glbKhoiLuong=0;
double glbGiaVaoLenhDauTien=0;
double glbGiaSL=0;
double glbGiaTP=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
    if(StringFind(Symbol(),"XAUUSD")>=0 || Digits()==3)
      glbPointKhoangGia=inpKhoangCachNhoiLenh*100;
    else  glbPointKhoangGia=inpKhoangCachNhoiLenh*10;
    if(glbTongSoLenh==0)
    {
       glbGiaSL=inpGiaSL;
       glbGiaTP=inpGiaTP;
       glbKhoiLuong=0.01;
    }   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ObjectsDeleteAll(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(glbTongSoLenh==0)
      {
         Comment("Doi lenh");
         ObjectsDeleteAll(0);
         if(glbLenhStop>0) {OrderDelete(glbLenhStop);glbLenhStop=-1;}
         
         FunTimLenhDauTien();
         
         if(glbTongSoLenh>0)
            FunVeDuongLine(glbGiaSL,glbGiaTP);
      }
      else
      {
         Comment("Tong so lenh dang co: ",glbTongSoLenh,"\nLenh cho stop: ",glbLenhStop);
         if(glbLenhStop>0)
         {
            if(OrderSelect(glbLenhStop,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==0||OrderType()==1)// Lenh da hit
               {
                  glbTapLenh[glbTongSoLenh]=OrderTicket();
                  glbTongSoLenh++;
                  glbLenhStop=-1;
                  FunCapNhatSLTP(glbGiaSL,glbGiaTP);
               }
               if(OrderCloseTime()>0) glbLenhStop=-1;
            }
         }
         else 
         {
            if(glbTongSoLenh<inpTongLenh)
               FunVaoLenhStop();
         }
         FunKiemTraDongLenhBangTay();
         FunKiemTraXoaLenhKhoiMang();
      }
  }
  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
    if(id==CHARTEVENT_OBJECT_DRAG )
   {
      
      if(sparam=="hLineGiaSL")
      {
         FunTextMove("txtGiaSL",Time[0],ObjectGet("hLineGiaSL",OBJPROP_PRICE1));
         FunTextChange(0,"txtGiaSL",FunTextHienThiSL());
         glbGiaSL=NormalizeDouble(FunHlineGetPrice(0,"hLineGiaSL"),Digits());
         Print("Dich SL: ",glbGiaSL);
         FunCapNhatSLTP(glbGiaSL,glbGiaTP);
      }
      if(sparam=="hLineGiaTP")
      {
         FunTextMove("txtGiaTP",Time[0],ObjectGet("hLineGiaTP",OBJPROP_PRICE1));
         FunTextChange(0,"txtGiaTP",FunTextHienThiTP());
         glbGiaTP=NormalizeDouble(FunHlineGetPrice(0,"hLineGiaTP"),Digits());
          Print("Dich TP: ", glbGiaTP);
         FunCapNhatSLTP(glbGiaSL,glbGiaTP);
      }
      ChartRedraw();
   }
}
//+------------------------------------------------------------------+  
void FunTimLenhDauTien()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()<=1 && OrderSymbol()==Symbol())
         {
            glbTapLenh[glbTongSoLenh]=OrderTicket();
            glbTongSoLenh++;
            glbLoaiLenhDangVao=OrderType();
            glbGiaVaoLenhDauTien=OrderOpenPrice();
            glbKhoiLuong=OrderLots();
            if(inpGiaTP==0)
            {
               if(OrderType()==OP_BUY)glbGiaTP=OrderOpenPrice()+(inpTongLenh+1)*glbPointKhoangGia*Point();
               else glbGiaTP=OrderOpenPrice()-(inpTongLenh+1)*glbPointKhoangGia*Point();
            }
            OrderModify(OrderTicket(),OrderOpenPrice(),glbGiaSL,glbGiaTP,0,clrNONE);
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
void FunVaoLenhStop()
{
   if(glbLenhStop>0) return;
   double GiaLenhStop=0;
   double KhoiLuong=glbKhoiLuong*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh+1);
   KhoiLuong=NormalizeDouble(KhoiLuong,FunPhanThapPhanKhoiLuong());
   if(glbLoaiLenhDangVao==OP_BUY)
   {
      GiaLenhStop=glbGiaVaoLenhDauTien+glbTongSoLenh*glbPointKhoangGia*Point();
      if(GiaLenhStop>glbGiaTP && glbGiaTP>0) return;
      glbLenhStop=FunVaoLenh(OP_BUYSTOP,GiaLenhStop,0,0,KhoiLuong);
   }
   else
   {
      GiaLenhStop=glbGiaVaoLenhDauTien-glbTongSoLenh*glbPointKhoangGia*Point();
      if(GiaLenhStop<glbGiaTP && glbGiaTP>0) return;
      glbLenhStop=FunVaoLenh(OP_SELLSTOP,GiaLenhStop,0,0,KhoiLuong);
   }
   
}
//+------------------------------------------------------------------+
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
//+------------------------------------------------------------------+
void FunCapNhatSLTP(double GiaSL, double GiaTP)
{
  
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
        //  Print("CAP NHAT SL< TP", GiaSL, "   ", GiaTP);
         if(OrderStopLoss()!=GiaSL || OrderTakeProfit()!=GiaTP)
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,GiaTP,0,clrNONE)==false)
            {
               Print("Loi cap nhat SL: "+DoubleToString(GiaSL,Digits())+"  TP: "+DoubleToString(GiaTP,Digits()));              
            }
           //else Print("Cap nhat SL,TP thanh cong");
         }
      }
   }
}
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongSoLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongSoLenh--;
         }
      }
   }
}

//+------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double GiaSL, double GiaTP, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=GiaSL,TakeProfit=GiaTP;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
 void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");   
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");  
               }
               else 
               {  
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;   
              }
            }
         }
      }
   }
   
  
   OrderDelete(glbLenhStop);
   glbLenhStop=-1;       
   
    
}
//+------------------------------------------------------------------+
 //+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            FunDongTatCaCacLenh();
         }
      }
   }
}

//+------------------------------------------------------------------+
bool FunKiemTraHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
{
   bool kt=true;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;
    }
    return kt;
}
//+------------------------------------------------------------------+
void FunVeDuongLine(double GiaSL, double GiaTP)
{               
   if(GiaSL>0)
   {
         FunHLineCreate(0,"hLineGiaSL",0,GiaSL,clrPurple,STYLE_SOLID,3,true);
         FunTextCreate(0,"txtGiaSL",FunTextHienThiSL(),0,ObjectGet("hLineGiaSL", OBJPROP_PRICE1),clrYellow);
   }
   if(GiaTP>0)        
   {
         FunHLineCreate(0,"hLineGiaTP",0,GiaTP,clrGreenYellow,STYLE_SOLID,3,true);
         FunTextCreate(0,"txtGiaTP",FunTextHienThiTP(),0,ObjectGet("hLineGiaTP", OBJPROP_PRICE1),clrYellow);
   }
}



/*******************************Text hien thi TP*********************************/
string FunTextHienThiTP()
{
   string XauHienThi="";
   double GiaTP=FunHlineGetPrice(0,"hLineGiaTP");
   XauHienThi=DoubleToString(GiaTP,Digits());
   return XauHienThi;
}
string FunTextHienThiSL()
{
   string XauHienThi="";
   double GiaSL=FunHlineGetPrice(0,"hLineGiaSL");
   XauHienThi=DoubleToString(GiaSL,Digits());
   return XauHienThi;
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
                 const int             width=4,           // line width
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