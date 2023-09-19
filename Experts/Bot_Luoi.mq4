//+------------------------------------------------------------------+
//|                                                     Bot_Luoi.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang glbNgayHetHan={30,05,3023};
enum Enm_LoaiLenh
{
    ENUM_BUY_ALL,//ALL BUY
    ENUM_SELL_ALL,//ALL SELL
    ENUM_BUY_LIMIT,//BUY LIMIT
    ENUM_SELL_LIMIT,//SELL LIMIT
    ENUM_BUY_STOP,//BUY STOP
    ENUM_SELL_STOP//SELL STOP
};

input Enm_LoaiLenh inpLoaiLenh=ENUM_BUY_ALL;//Loai lenh vao:
input double inpGiaTran=1.098;//Gia Tran:
input double inpGiaSan=1.090;// Gia San:
input int inpTongSoLuoi=10;//Tong so luoi:
input double inpKhoiLuong=0.01;//Khoi luong vao lenh (lots):
input double inpGiaSL=1.089; //Gia SL Toan bo lenh:
input int inpSlippage=50;
input int inpMagicNumber=12345;
int glbTapLenh[100]={0};
double glbKhoangNhayGia=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      glbKhoangNhayGia=NormalizeDouble((inpGiaTran-inpGiaSan)/inpTongSoLuoi,Digits);
      if(inpGiaTran==0||inpGiaSan==0||inpGiaTran<=inpGiaSan||inpTongSoLuoi==0)
      {
         MessageBox("KHOI TAO THAM SO SAI");
         Print("KHOI TAO THAM SO SAI");
         return INIT_FAILED;
      }
       if(FunKiemDaHetHanChua(glbNgayHetHan)==true)return INIT_FAILED;
       FunButtonCreate(0,"btnExit",0,75,20,70,40,CORNER_RIGHT_UPPER,"EXIT EA","Arial",9,clrBlue,clrPink);
      
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
      /*
      if(Bid>inpGiaTran|| Bid<inpGiaSan)
      {
          FunDongTatCaCacLenh();
          MessageBox("Gia nam ngoai vung gia san, gia tran");
          Print("Gia nam ngoai vung gia san, gia tran");
          ExpertRemove();
          return;
      }
      */
      if(inpGiaSL>0)
      {
         if( (inpLoaiLenh%2==0&& Bid<inpGiaSL) || (inpLoaiLenh%2==1&& Bid>inpGiaSL))
         {
             FunDongTatCaCacLenh();
             MessageBox("Gia nam ngoai vung gia SL");
             Print("Gia nam ngoai vung gia SL");
             ExpertRemove();
             return;
         }
      }
      FunXoaLenhDaTPSL();
      if(inpLoaiLenh%2==0)
         FunVaoLenhLuoiKieuBuy();
      else FunVaoLenhLuoiKieuSell();
      
  }
  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK )
   {
      
      if(sparam=="btnExit")
      {
         FunXoaCacLenhLimitStop();
         ExpertRemove();
         FunButtonDelete(0,"btnExit");
      }
   }
  
}
//+------------------------------------------------------------------+

int FunXacDinhViTriCuaGiaHienTaiTrongLuoi()
{
   if(Bid>inpGiaTran ||Bid<inpGiaSan) ExpertRemove();
   int vt=1;
   while(inpGiaSan+vt*glbKhoangNhayGia<Bid)
   {
      vt++;
   }
   return vt;
}
//+------------------------------------------------------------------+
void FunXoaCacLenhLimitStop()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()>1 && OrderSymbol()==Symbol())
            OrderDelete(OrderTicket());
      }
   }
}
//+------------------------------------------------------------------+
void FunVaoLenhLuoiKieuBuy()
{
   int vitriLuoiGiaHienTai=FunXacDinhViTriCuaGiaHienTaiTrongLuoi();
   if(vitriLuoiGiaHienTai<=0) return;
  // Print("Vi tri gia trong luoi:",vitriLuoiGiaHienTai);
   // Neu dang o vung gia so 4: vao lenh buy stop: 5,6,7; vao lenh sell limit o 1,2
   double GiaVaoLenh=0;
   double GiaSL=0;
   double GiaTP=0;
   for(int i=1;i<=vitriLuoiGiaHienTai-2;i++)
   {
      if(glbTapLenh[i]<=0)
      {
         Print("vi tri gia trong luoi: ",vitriLuoiGiaHienTai," vitri cua i:",i);
         GiaVaoLenh=inpGiaSan+glbKhoangNhayGia*i;
         GiaTP=inpGiaSan+glbKhoangNhayGia*(i+1);
         GiaSL=inpGiaSL;
         if(inpGiaSL<GiaVaoLenh && (inpLoaiLenh==ENUM_BUY_ALL||inpLoaiLenh==ENUM_BUY_LIMIT))
            glbTapLenh[i]=FunVaoLenh(OP_BUYLIMIT,GiaVaoLenh,GiaSL,GiaTP,inpKhoiLuong);
      }
   }
   for(int i=vitriLuoiGiaHienTai+1;i<inpTongSoLuoi;i++)
   {
      if(glbTapLenh[i]<=0)
      {
         Print("vi tri gia trong luoi: ",vitriLuoiGiaHienTai," vitri cua i:",i);
         GiaVaoLenh=inpGiaSan+glbKhoangNhayGia*i;
         GiaTP=inpGiaSan+glbKhoangNhayGia*(i+1);
         GiaSL=inpGiaSL;
         if(inpGiaSL<GiaVaoLenh && (inpLoaiLenh==ENUM_BUY_ALL||inpLoaiLenh==ENUM_BUY_STOP))
            glbTapLenh[i]=FunVaoLenh(OP_BUYSTOP,GiaVaoLenh,GiaSL,GiaTP,inpKhoiLuong);
      }
   }
}
//+------------------------------------------------------------------+
void FunVaoLenhLuoiKieuSell()
{
   int vitriLuoiGiaHienTai=FunXacDinhViTriCuaGiaHienTaiTrongLuoi();
   // Neu dang o vung gia so 4: vao lenh buy stop: 5,6,7; vao lenh sell limit o 1,2
   double GiaVaoLenh=0;
   double GiaSL=0;
   double GiaTP=0;
   for(int i=1;i<=vitriLuoiGiaHienTai-2;i++)
   {
      if(glbTapLenh[i]<=0)
      {
         GiaVaoLenh=inpGiaSan+glbKhoangNhayGia*i;
         GiaTP=inpGiaSan+glbKhoangNhayGia*(i-1);
         GiaSL=inpGiaSL;
         if(inpGiaSL>GiaVaoLenh || inpGiaSL==0)
         {
            if(inpLoaiLenh==ENUM_SELL_ALL||inpLoaiLenh==ENUM_SELL_STOP)
               glbTapLenh[i]=FunVaoLenh(OP_SELLSTOP,GiaVaoLenh,GiaSL,GiaTP,inpKhoiLuong);
         }
      }
   }
   for(int i=vitriLuoiGiaHienTai+1;i<inpTongSoLuoi;i++)
   {
      if(glbTapLenh[i]<=0)
      {
      
         GiaVaoLenh=inpGiaSan+glbKhoangNhayGia*i;
         GiaTP=inpGiaSan+glbKhoangNhayGia*(i-1);
         GiaSL=inpGiaSL;
         if(inpGiaSL>GiaVaoLenh|| inpGiaSL==0)
         {
            if(inpLoaiLenh==ENUM_SELL_ALL||inpLoaiLenh==ENUM_SELL_LIMIT)
               glbTapLenh[i]=FunVaoLenh(OP_SELLLIMIT,GiaVaoLenh,GiaSL,GiaTP,inpKhoiLuong);
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
   int TongLenh=inpTongSoLuoi-1;
   while(TongLenh>0)
   {
      if(glbTapLenh[TongLenh]<=0)
      {
         glbTapLenh[TongLenh]=-1;
         TongLenh--;
      }
      else
      {
         if(OrderSelect(glbTapLenh[TongLenh],SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()>1) 
            {
               if(OrderDelete(OrderTicket()))
               {
                   glbTapLenh[TongLenh]=-1;
                   TongLenh--;
               }
            }
            else if (OrderType()==1)
            {
                if(OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE))
                {
                   glbTapLenh[TongLenh]=-1;
                   TongLenh--;
                }
            }
            else 
            {
                if(OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE))
                {
                   glbTapLenh[TongLenh]=-1;
                   TongLenh--;
                }
             }
            
         }
      }
   }
}
void FunXoaLenhDaTPSL()
{
   for(int i=1;i<inpTongSoLuoi;i++)
   {
      if(glbTapLenh[i]>0)
      {
         if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)
               glbTapLenh[i]=-1;
         }
      }
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
bool FunKiemDaHetHanChua(NgayThang &HanCanKiemTra)
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