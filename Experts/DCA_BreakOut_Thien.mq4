//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
input double inpKhoiLuong=0.01;//Khoi luong:
input int inpKhoangCachVaoLenh=10;// Khoang cach vao lenh (pips):
input int inpSpreadToiDa=50;//Spread toi da cho phep vao lenh (points):
input double inpStartTime=13;// Thoi Gian Bat Dau vao lenh (Gio VN):
input double inpEndTime=23;// Thoi Gian Ket Thuc vao lenh(Gio VN):
input bool inpChoPhepDongTatCaLenhKhiHetGio=true;//Cho phep dong tat ca cac lenh khi het gio:
input int inpSlippage=50;// Do truot gia (slippage -points):
input int inpMagicNumber=123;// Magic number:

double glbGiaCoSo=0;
int glbTongLenh=0;
int glbTapLenh[100];
int glbLenhStopNguoc=-1;
int glbLoaiLenhDangVao;
double glbGiaSL=0;
double glbGiaNhoiLenh=0;



struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,09,2023};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(FunKiemTraChuaHetHan(NgayHetHan)==false) return INIT_FAILED;
    glbGiaCoSo=Bid;
    //FunHLineCreate(0,"GiaCoSo",0,glbGiaCoSo);
    //if(glbTongLenh==0)
      FunXuLyTimLenhCoSo();
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll();
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(glbTongLenh==0)
   {
      if(FunKiemTraGioVaoLenh()==false)
      {
         Comment("Chua toi gio vao lenh");
         return;
      }
      Comment("Chua co lenh. Doi tin hieu vao lenh");
      if(glbGiaCoSo>0)
      {
         FunKiemTraVaoLenhDauTien();
      }      
      else // cos the dang cos lenh stop
      {
         FunXyLyVaoLenhNguocDauTien();
      }

   }
   else
   {
      if(FunKiemTraGioVaoLenh()==false && inpChoPhepDongTatCaLenhKhiHetGio==true)
         FunDongTatCaCacLenh();
      //Xy ly nhoi lenh va dich lenh stop len
      FunXuLyNhoiLenh();
      // Xu ly dong lenh
      FunKiemTraDongLenhBangTay();
      Comment("Tong lenh dang vao: ",glbTongLenh, "\nLenh stop nguoc: ",glbLenhStopNguoc);
   }
    
   
}
//----------------------------------------------------------------------
void FunXuLyTimLenhCoSo()
{
   glbTongLenh=0;
   glbLenhStopNguoc=-1;
   for (int i = 0; i < OrdersTotal(); i++)         
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      Print("MAgic number: ",OrderMagicNumber());
      if(OrderType()<=1 && OrderSymbol()==Symbol()&& OrderMagicNumber()==inpMagicNumber)
      {
         glbTapLenh[glbTongLenh]=OrderTicket();
         glbLoaiLenhDangVao=OrderType();
         glbTongLenh++;
      }
      if(OrderType()>3 && OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicNumber)
      {
         OrderDelete(OrderTicket());
      }
        
   }
   if(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET))
      {
         int tam=1;
         if(OrderType()==OP_SELL)tam=-1;
         glbGiaSL=OrderOpenPrice()-tam*inpKhoangCachVaoLenh*10*Point();
         glbGiaNhoiLenh=OrderOpenPrice()+tam*inpKhoangCachVaoLenh*10*Point();
         glbGiaCoSo=0;
         FunHLineCreate(0,"GiaNhoiLenh",0,glbGiaNhoiLenh);
         FunCapNhatSL(glbGiaSL);
         glbLenhStopNguoc=FunVaoLenh(5-glbLoaiLenhDangVao,glbGiaSL,0,0,inpKhoiLuong);
      }
   }
   
   
}
//----------------------------------------------------------------------
void FunXuLyNhoiLenh()
{
    if(glbLoaiLenhDangVao==OP_BUY)
    {
        if(Ask>=glbGiaNhoiLenh)
        {
            int Ticket=FunVaoLenh(OP_BUY,Ask,0,0,inpKhoiLuong);
            if(Ticket>0)
            {
                glbTapLenh[glbTongLenh]=Ticket;
                glbTongLenh++;
                OrderSelect(Ticket,SELECT_BY_TICKET);
                glbGiaSL=OrderOpenPrice()-inpKhoangCachVaoLenh*10*Point();
                glbGiaNhoiLenh=OrderOpenPrice()+inpKhoangCachVaoLenh*10*Point();
                FunHLineCreate(0,"GiaNhoiLenh",0,glbGiaNhoiLenh);
                FunCapNhatSL(glbGiaSL);
                OrderSelect(glbLenhStopNguoc,SELECT_BY_TICKET);
                OrderModify(OrderTicket(),glbGiaSL,OrderStopLoss(),OrderTakeProfit(),0,clrNONE);
            }
        }
    }
    else
    {
        if(Bid<=glbGiaNhoiLenh)
        {
            int Ticket=FunVaoLenh(OP_SELL,Bid,0,0,inpKhoiLuong);
            if(Ticket>0)
            {
                glbTapLenh[glbTongLenh]=Ticket;
                glbTongLenh++;
                OrderSelect(Ticket,SELECT_BY_TICKET);
                glbGiaSL=OrderOpenPrice()+inpKhoangCachVaoLenh*10*Point();
                glbGiaNhoiLenh=OrderOpenPrice()-inpKhoangCachVaoLenh*10*Point();
                FunHLineCreate(0,"GiaNhoiLenh",0,glbGiaNhoiLenh);
                FunCapNhatSL(glbGiaSL);
                OrderSelect(glbLenhStopNguoc,SELECT_BY_TICKET);
                OrderModify(OrderTicket(),glbGiaSL,OrderStopLoss(),OrderTakeProfit(),0,clrNONE);
            }
        }   
    }
}
//+------------------------------------------------------------------+
void FunKiemTraVaoLenhDauTien()
{
    int Ticket=-1;
    int LoaiLenh=-1;
    int GiaS=0;
    int check=0;
    if(glbGiaCoSo==0)return;
    FunHLineCreate(0,"GiaVaoLenhBuyStop",0,glbGiaCoSo+inpKhoangCachVaoLenh*10*Point(),clrRed);
    FunHLineCreate(0,"GiaVaoLenhSellStop",0,glbGiaCoSo-inpKhoangCachVaoLenh*10*Point(),clrRed);
    if(Bid>=glbGiaCoSo+inpKhoangCachVaoLenh*10*Point())
    {
        Ticket=FunVaoLenh(OP_BUY,Ask,0,0,inpKhoiLuong);
        LoaiLenh=OP_BUY;
        check=1;
    }
    if(Bid<=glbGiaCoSo-inpKhoangCachVaoLenh*10*Point())    
    {
        Ticket=FunVaoLenh(OP_SELL,Bid,0,0,inpKhoiLuong);
        LoaiLenh=OP_SELL;   
        check=-1;
    }
    if(Ticket>0)
    {
        Print("VAO LENH DAU TIEN");
        glbTapLenh[0]=Ticket;
        glbTongLenh=1;
        OrderSelect(Ticket,SELECT_BY_TICKET);
        glbGiaSL=OrderOpenPrice()-check*inpKhoangCachVaoLenh*10*Point();
        glbLoaiLenhDangVao=LoaiLenh;
        glbGiaNhoiLenh=OrderClosePrice()+check*inpKhoangCachVaoLenh*10*Point();
        FunHLineCreate(0,"GiaNhoiLenh",0,glbGiaNhoiLenh);
        glbGiaCoSo=0;
        FunHLineDelete(0,"GiaCoSo");
        FunCapNhatSL(glbGiaSL);
        glbLenhStopNguoc=FunVaoLenh(5-LoaiLenh,glbGiaSL,0,0,inpKhoiLuong);
        ObjectDelete("GiaVaoLenhBuyStop");
        ObjectDelete("GiaVaoLenhSellStop");
    }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
/**
 * This function fulfills the will of the developer
 * @return ( bool ): true: Dung gio vao lenh
 * false: Ngoai gio vao lenh
 */
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeLocal();
   //Print(TimeLocal());
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(inpStartTime<=inpEndTime)
      if(gio>=inpStartTime && gio<inpEndTime) return true;
      else return false;
   else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
      if(gio>=inpEndTime&&gio<inpStartTime) return false;
      else return true;
}

/**
 * This function fulfills the will of the developer
 */
void  FunXyLyVaoLenhNguocDauTien()
{
    int Ticket=-1;
    if(OrderSelect(glbLenhStopNguoc,SELECT_BY_TICKET))
    {
        if(OrderType()<=1)
        {
            int check=0;
            if(OrderType()==0)check=1;
            else check=-1;
            glbTapLenh[0]=OrderTicket();
            glbTongLenh=1;
            glbGiaSL=OrderOpenPrice()-check*inpKhoangCachVaoLenh*10*Point();
            glbLoaiLenhDangVao=OrderType();
            glbGiaNhoiLenh=OrderClosePrice()+check*inpKhoangCachVaoLenh*10*Point();
            FunHLineCreate(0,"GiaNhoiLenh",0,glbGiaNhoiLenh);
            glbGiaCoSo=0;
            FunHLineDelete(0,"GiaCoSo");
            FunCapNhatSL(glbGiaSL);
             Print("VAO LENH NGUOC");
            glbLenhStopNguoc=FunVaoLenh(5-OrderType(),glbGiaSL,0,0,inpKhoiLuong);
            return;
        }
        if(OrderCloseTime()>0)
        {
            glbGiaCoSo=Bid;
        }
    }
    
}
//--------------------------------------------------------------------------
void FunCapNhatSL(double GiaSL)
{
    for (int i = 0; i < glbTongLenh; i++)       
    {
        if(!OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))continue;
        if(OrderStopLoss()!=GiaSL)OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
    }
}
//--------------------------------------------------------------------------
void FunDongTatCaCacLenh()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongLenh-1]=-1;
            glbTongLenh--;
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");   
               }
               else 
               {  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");
               }
               else 
               {  
                  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--; 
              }
            }
         }
      }
   }
   ObjectsDeleteAll();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongLenh;i++)
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
/**
 * This function fulfills the will of the developer
 * @param  LoaiLenh: Argument 1
 * @param  DiemVaoLenh: Argument 2
 * @param  StopLossPips: Argument 3
 * @param  TakeProfitPips: Argument 4
 * @param  KhoiLuongVaoLenh: Argument 5
 * @return ( int )
 */
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,
                        "Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,
                        "Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}


bool FunHLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrLimeGreen,        // line color
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
bool FunKiemTraChuaHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
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