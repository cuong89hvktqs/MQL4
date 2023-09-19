//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieforex.com"
#property version   "1.00"
#property strict

input double inpKhoiLuong=0.01;//Khoi luong ban dau:
input int inpSoPipTP=200;// So pips TP:
input int inpSoPipSL=50;// So pips SL ban dau:
input int inpSoPipDichHoaVon=10;// So pip dich hoa von (=0: khong dich hoa von):
input int inpSoPipTrailing=15;// So pip trailing stop (=0: khong trailing stop):
input bool inpChoPhepDongLenhKhiGiaCatMa=true;// Chp phep dong lenh khi gia cat MA:
input string str0="THAM SO HAI DUONG MA ";//CAI DAT THAM SO MA:
input ENUM_TIMEFRAMES inpTFKhung=PERIOD_H1;//Timeframe tinh MA:
input int inpMAPeriodNgan=10;// MA ngan:
input ENUM_MA_METHOD inpMAMethodNgan= MODE_EMA;//MA ngan Method :
input ENUM_APPLIED_PRICE inpAppliedPriceNgan=PRICE_CLOSE;// MA ngan pplied price : 
input double inpKhoangCachVaoLenh=20;// Khong cach gia so voi MA de vao lenh (pips):
input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
input string inpCommentBuy="Buy";//Comment  lenh buy:
input string inpCommentSell="Sell";//Comment  lenh sell:
input double inpKhungGioBatDauMoLenh=0;// Khung gio bat dau mo lenh:
input double inpKhungGioKetThucMoLenh=24;// Khung gio Ket thuc mo lenh:

double glbMyPoint=0;
int glbTicket=-1;
int glbLoaiLenh;
bool glbDaVaoLenhBuy=false;
bool glbDaVaoLenhSell=false;
int glbLoaiLenhCanhVao;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  glbMyPoint=10*Point();  
  FunTimLenhCoSo();
  
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(FunKiemTraSangNenMoiChua())
    {
        int tam=FunKiemTraGiaoCat();
        if(tam>=0)
        {
            if(tam==0)
            {
                if(glbTicket<=0) glbDaVaoLenhBuy=false;
                else
                {
                    if(glbLoaiLenh==OP_SELL)
                    {
                        glbDaVaoLenhBuy=false;
                        if(inpChoPhepDongLenhKhiGiaCatMa)
                            if(FunDongLenh(glbTicket)) glbTicket=-1;
                    }
                }
            }
            else 
            {
                if(glbTicket<=0) glbDaVaoLenhSell=false;
                else
                {
                    if(glbLoaiLenh==OP_BUY)
                    {
                        glbDaVaoLenhSell=false;
                        if(inpChoPhepDongLenhKhiGiaCatMa)
                            if(FunDongLenh(glbTicket)) glbTicket=-1;
                    }
                }
            }

        }
    }
    if(glbTicket<=0)
    {
        Comment("Doi lenh");
        double MAValue=FunTinhMAValue(inpTFKhung,inpMAPeriodNgan,inpMAMethodNgan,inpAppliedPriceNgan,0);
        double KhoangCachPip=(Bid-MAValue)/glbMyPoint;
        if(KhoangCachPip>=inpKhoangCachVaoLenh && glbDaVaoLenhBuy==false)
        {
            glbTicket=FunVaoLenh(OP_BUY,Ask,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
            if(glbTicket>0)
            {
                glbLoaiLenh=OP_BUY;
                glbDaVaoLenhBuy=true;
            }
        }
        if(KhoangCachPip<0 && MathAbs(KhoangCachPip)>=inpKhoangCachVaoLenh && glbDaVaoLenhSell==false)
        {
            
            glbTicket=FunVaoLenh(OP_SELL,Bid,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
            if(glbTicket>0)
            {
                glbLoaiLenh=OP_SELL;
                glbDaVaoLenhSell=true;
            }
        }
    }  
    if(glbTicket>0)
    {
        if(OrderSelect(glbTicket,SELECT_BY_TICKET))
        {
            if(OrderCloseTime()>0)
            {
                glbTicket=-1;
                return;
            }
        }
        if(inpSoPipDichHoaVon>0) FunDichHoaVon(glbTicket,inpSoPipDichHoaVon);
        if(inpSoPipTrailing>0) FunTrailingStopTicket(glbTicket,inpSoPipTrailing);
        Comment("Lenh da vao. Ticket: ",glbTicket);
    }
   
}
int FunKiemTraGiaoCat()//0: cat len, 1 cat xuong
{
    double tam=FunTinhMAValue(inpTFKhung,inpMAPeriodNgan,inpMAMethodNgan,inpAppliedPriceNgan,1);
    if(Open[1]<=tam && Close[1]>tam) return 0;
    if(Open[1]>=tam && Close[1]<tam)return 1;
    return -1;
}
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------------------------------+
bool FunDongLenh(int Ticket)
{
    if(OrderSelect(Ticket,SELECT_BY_TICKET))
    {
        if(OrderType()==OP_BUY)return OrderClose(Ticket,OrderLots(),Bid,inpSlippage,clrNONE);
        else return OrderClose(Ticket,OrderLots(),Ask,inpSlippage,clrNONE);
    }
    return false;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDichHoaVon(int ticket, int SoPipDeDichHoaVon)
{
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice())
         {
            if(Bid>=(OrderOpenPrice()+SoPipDeDichHoaVon*glbMyPoint))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point(),OrderTakeProfit(),0,clrNONE))
                Print("Dia hoa von LOI");   
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice())
         {
            if(Bid<=(OrderOpenPrice()-SoPipDeDichHoaVon*glbMyPoint))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("hoa von bi LOI");  
         }
      }
      
   }
}
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
void FunTrailingStopTicket(int ticket, int pipTrailingStop)
{
      if(pipTrailingStop<=0) return;
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
         double DiemTrailingStop=pipTrailingStop*10;
         double SoPointLoiLo=FunCountProfitPoints(OrderTicket());
         if (SoPointLoiLo>DiemTrailingStop)
         {
            double StopLoss=0;
            if(OrderType()==1)//lệnh sell
            {
            
               StopLoss=Bid+ DiemTrailingStop*Point();
               if(OrderStopLoss()>StopLoss && StopLoss<OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh SELL that bai");            
            }
            else if(OrderType()==0)// Lệnh buy
            {
               StopLoss=Bid-DiemTrailingStop*Point();
               if(OrderStopLoss()<StopLoss &&StopLoss>OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh BUY that bai");               
            }
         }
         
      }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 double FunCountProfitPoints(int TichKet)
 {
      double SoPointLoiLoHienTai=0; 
      if( OrderSelect( TichKet,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUY)
            {
               SoPointLoiLoHienTai=(Bid -OrderOpenPrice())/Point;
            }
            else if(OrderType()==OP_SELL)
            {
               SoPointLoiLoHienTai=(OrderOpenPrice()-Ask)/Point;
            }
         }      
      return NormalizeDouble(SoPointLoiLoHienTai,2);
 }
//+----------------------------------------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;
    if(gio>=inpKhungGioBatDauMoLenh && gio<inpKhungGioKetThucMoLenh) return true;
    else return false;
}

//+----------------------------------------------------------------------------------------------------+
double FunTinhMAValue(ENUM_TIMEFRAMES MA_TimeFrame, int MA_Period, ENUM_MA_METHOD MA_Method, ENUM_APPLIED_PRICE MA_Applied_price, int shift=0)
{
   return iMA(Symbol(),MA_TimeFrame,MA_Period,0,MA_Method,MA_Applied_price,shift);
}

//+----------------------------------------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, int MagicID)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentBuy,MagicID,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentSell,MagicID,0,clrRed);
    }
    return Ticket;
}
//+----------------------------------------------------------------------------------------------------+
void FunTimLenhCoSo()
{
   glbTicket=-1;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol()&& OrderType()<2)
         {
            glbTicket=OrderTicket();
            glbLoaiLenh=OrderType();
            if(glbLoaiLenh==0)glbDaVaoLenhBuy=true;
            else glbDaVaoLenhSell=true;
            break;
         }
      }
   }
}