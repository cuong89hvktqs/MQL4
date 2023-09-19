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
input string str0="THAM SO HAI DUONG MA ";//CAI DAT THAM SO MA:
input double inpGiaCachMAKhiVaoLenhMin=5;// Khoang cach MIN gia hien tai so voi MA Dai:
input double inpGiaCachMAKhiVaoLenhMax=50;// Khoang cach MAX gia hien tai so voi MA Dai:
input double inpKhoangCachHaiDuongMA=8;// Khoang cach toi thieu 2 duong MA khi vao lenh:
input ENUM_TIMEFRAMES inpTFKhung=PERIOD_H1;//Timeframe tinh MA:
input int inpMAPeriodNgan=21;// MA ngan:
input ENUM_MA_METHOD inpMAMethodNgan= MODE_EMA;//MA ngan Method :
input ENUM_APPLIED_PRICE inpAppliedPriceNgan=PRICE_CLOSE;// MA ngan pplied price : 
input int inpMAPeriodDai=50;// MA dai
input ENUM_MA_METHOD inpMAMethodDai = MODE_EMA;//MA dai Method:
input ENUM_APPLIED_PRICE inpAppliedPriceDai=PRICE_CLOSE;// MA dai applied price:
input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
input string inpCommentBuy="Buy";//Comment  lenh buy:
input string inpCommentSell="Sell";//Comment  lenh sell:
input double inpKhungGioBatDauMoLenh=0;// Khung gio bat dau mo lenh:
input double inpKhungGioKetThucMoLenh=24;// Khung gio Ket thuc mo lenh:

double glbMyPoint=0;
int glbTicket=-1;
int glbLoaiLenh;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   glbMyPoint=10*Point();      
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
   if(glbTicket<=0) Comment("Doi lenh");
   else
   {
        Comment("Lenh dang vao: ",glbTicket);
        if(OrderSelect(glbTicket,SELECT_BY_TICKET))
        {
            if(OrderCloseTime()>0)glbTicket=-1;
        }
        if(inpSoPipDichHoaVon>0) FunDichHoaVon(glbTicket,inpSoPipDichHoaVon);

   }
   int DieuKien=FunKiemTraDieuKienVaoLenh();
   if(DieuKien>=0)
   {
        if(glbTicket<=0)
        {
            double KhoangCachGiaHienTai=MathAbs(Bid-FunTinhMAValue(inpTFKhung,inpMAPeriodDai,inpMAMethodDai,inpAppliedPriceDai,0));
            if(KhoangCachGiaHienTai<inpGiaCachMAKhiVaoLenhMin || KhoangCachGiaHienTai>inpGiaCachMAKhiVaoLenhMax)
                return;
            if(FunKiemTraGioVaoLenh())
            {
                if(DieuKien==0)
                    glbTicket=FunVaoLenh(DieuKien,Ask,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
                else glbTicket=FunVaoLenh(DieuKien,Bid,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
                glbLoaiLenh=DieuKien;
            }
        }
        else // Dang co lenh
        {
            if(glbLoaiLenh!=DieuKien)
            {
                if(FunDongLenh())
                {
                    glbTicket=-1;
                    double KhoangCachGiaHienTai=MathAbs(Bid-FunTinhMAValue(inpTFKhung,inpMAPeriodDai,inpMAMethodDai,inpAppliedPriceDai,0));
                    if(KhoangCachGiaHienTai<inpGiaCachMAKhiVaoLenhMin || KhoangCachGiaHienTai>inpGiaCachMAKhiVaoLenhMax)
                        return;
                    if(DieuKien==0)
                        glbTicket=FunVaoLenh(DieuKien,Ask,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
                    else glbTicket=FunVaoLenh(DieuKien,Bid,inpSoPipSL,inpSoPipTP,inpKhoiLuong,inpMagicNumber);
                    glbLoaiLenh=DieuKien;
                }
                
            }
        }
   }
   

}
//+----------------------------------------------------------------------------------------------------+
bool FunDongLenh()
{
    if(OrderSelect(glbTicket,SELECT_BY_TICKET))
    {
        if(OrderType()==OP_BUY)return OrderClose(glbTicket,OrderLots(),Bid,inpSlippage,clrNONE);
        else return OrderClose(glbTicket,OrderLots(),Ask,inpSlippage,clrNONE);
    }
    return false;
}
//+----------------------------------------------------------------------------------------------------+
int FunKiemTraDieuKienVaoLenh()// 0: Buy, 1: Sell, -1: Khong thoa ma dieukien
{
   double MA10_1,MA10_0,MA20_1,MA20_0;
   MA10_1=FunTinhMAValue(inpTFKhung,inpMAPeriodNgan,inpMAMethodNgan,inpAppliedPriceNgan,1);
   MA10_0=FunTinhMAValue(inpTFKhung,inpMAPeriodNgan,inpMAMethodNgan,inpAppliedPriceNgan,0);
   MA20_1=FunTinhMAValue(inpTFKhung,inpMAPeriodDai,inpMAMethodDai,inpAppliedPriceDai,1);
   MA20_0=FunTinhMAValue(inpTFKhung,inpMAPeriodDai,inpMAMethodDai,inpAppliedPriceDai,0);
   double KhoangCach2MA=MathAbs(MA20_0-MA10_0)/glbMyPoint;
   if(MA10_1<MA20_1 && MA10_0>MA20_0 && KhoangCach2MA>=inpKhoangCachHaiDuongMA) return 0;
   if(MA10_1>MA20_1 && MA10_0<MA20_0 && KhoangCach2MA>=inpKhoangCachHaiDuongMA) return 1;
   return -1;
}
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
//+----------------------------------------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;
   if (inpKhungGioBatDauMoLenh<inpKhungGioKetThucMoLenh)
   {
      if(gio>=inpKhungGioBatDauMoLenh && gio<inpKhungGioKetThucMoLenh) return true;
      else return false;
   }
   else
   {
      if(gio>=inpKhungGioBatDauMoLenh && gio<inpKhungGioKetThucMoLenh) return false;
      else return true;
   }
   
    
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
            break;
         }
      }
   }
}