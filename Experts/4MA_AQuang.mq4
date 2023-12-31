//+------------------------------------------------------------------+
//|                                                   4MA_AQuang.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
CCustomBot glbBotTelegram;
input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1735772983:AAFn532QW457WhYRKszyONT1zznnCh_hORE";//Ma Token bot Telegram:
input double inpKhoiLuong=0.01;//Khoi luong vao lenh:
input int inpTP=200;//TP (pips):
input int inpSL=100;//SL (pips);
input int inpTrailingStop=100;// Trailing stop (pips):
input int inpSoNenVaoLenhTiep=14;// So nen vao lenh tiep theo:
input string inpStr1="THAM SO MA KHUNG LON";// CAI DAT THAM SO MA H4
input ENUM_TIMEFRAMES inpTFKhungLon=PERIOD_H4;//Timeframe khung lon:
input int inpMAPeriod13_H4=13;// MA ngan khung H4:
input ENUM_MA_METHOD inpMAMethod13_H4= MODE_EMA;//MA Method ngan H4:
input ENUM_APPLIED_PRICE inpAppliedPrice13_H4=PRICE_CLOSE;// MA applied price ngan H4: 
input int inpMAPeriod34_H4=34;// MA trung binh 1 khung H4:
input ENUM_MA_METHOD inpMAMethod34_H4 = MODE_EMA;//MA Method trung binh 1 khung H4:
input ENUM_APPLIED_PRICE inpAppliedPrice34_H4=PRICE_CLOSE;// MA applied price trung binh 1 khung H4:
input int inpMAPeriod50_H4=50;// MA trung binh 2 khung H4:
input ENUM_MA_METHOD inpMAMethod50_H4 = MODE_EMA;//MA Method trung binh 2 khung H4:
input ENUM_APPLIED_PRICE inpAppliedPrice50_H4=PRICE_CLOSE;// MA applied price trung binh 2 khung H4:
input int inpMAPeriod89_H4=89;// MA dai khung H4:
input ENUM_MA_METHOD inpMAMethod89_H4 = MODE_EMA;//MA Method dai khung H4:
input ENUM_APPLIED_PRICE inpAppliedPrice89_H4=PRICE_CLOSE;// MA applied price dai khung H4:
input string inpStr2="THAM SO MA KHUNG NHO";// CAI DAT THAM SO MA H1
input ENUM_TIMEFRAMES inpTFKhungNho=PERIOD_H1;// Timeframe khung nho:
input int inpMAPeriod13_H1=13;// MA ngan khung H1:
input ENUM_MA_METHOD inpMAMethod13_H1= MODE_EMA;//MA Method ngan H1:
input ENUM_APPLIED_PRICE inpAppliedPrice13_H1=PRICE_CLOSE;// MA applied price ngan H1: 
input int inpMAPeriod34_H1=34;// MA trung binh 1 khung H1:
input ENUM_MA_METHOD inpMAMethod34_H1 = MODE_EMA;//MA Method trung binh 1 khung H1:
input ENUM_APPLIED_PRICE inpAppliedPrice34_H1=PRICE_CLOSE;// MA applied price trung binh 1 khung H1:
input int inpMAPeriod50_H1=50;// MA trung binh 2 khung H1:
input ENUM_MA_METHOD inpMAMethod50_H1 = MODE_EMA;//MA Method trung binh 2 khung H1:
input ENUM_APPLIED_PRICE inpAppliedPrice50_H1=PRICE_CLOSE;// MA applied price trung binh 2 khung H1:
input int inpMAPeriod89_H1=89;// MA dai khung H1:
input ENUM_MA_METHOD inpMAMethod89_H1 = MODE_EMA;//MA Method dai khung H1:
input ENUM_APPLIED_PRICE inpAppliedPrice89_H1=PRICE_CLOSE;// MA applied price dai khung H1:
input int inpMagicNumber=123;// Magic number:
input int inpSlippage=50;//Slippage (points):
enum ENM_XuHuong
{
   ENM_TANG,
   ENM_GIAM,
   ENM_KHONG_XAC_DINH
};
int glbTongLenh=0;
int glbTapLenh[100];
int glbDemNenVaoLenh=0;
int glbLoaiLenhDangVao=-1;
datetime glbTimeVaoLenh;// Mooix nen chi co 1 lenh
int glbXuHuongKhungLon=-1;//Xu huong duoc xac dinh khi EM 50 h4 cat len mA89 hoac cat xuong: -1: Khong xa dinh, 0: cat len, 1: Cat xuong
string glbMessages="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      glbTimeVaoLenh=Time[1];
      glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele);
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(FunKiemTraSangNenMoiChuaKhungLon()==true)//Sang nen moi khunglon
      {
         //Print("KHUNG LON SANG NEN MOI");
         if(FunKiemTraGiaoCatMA50MA89KhungLonCanhVaoLenh()>=0)
               glbXuHuongKhungLon=FunKiemTraGiaoCatMA50MA89KhungLonCanhVaoLenh();
         if(FunKiemTraGiaCatMA34MA50KhungLonCanhDongLenh()>=0)
         {
            Print("Dong tat ca cac lenh khi khung lon ma34 cat ma 50");
            if(FunKiemTraGiaCatMA34MA50KhungLonCanhDongLenh()==1 && glbLoaiLenhDangVao==OP_BUY)
               FunDongTatCaCacLenh();
            if (FunKiemTraGiaCatMA34MA50KhungLonCanhDongLenh()==0 && glbLoaiLenhDangVao==OP_SELL)
               FunDongTatCaCacLenh();
         }
         //Print("Xu huong: ",glbXuHuongKhungLon);
      }
      if(FunKiemTraSangNenMoiChuaKhungHienTai()==true)// Sang nen moi khung nho
      {
         //Print("KHUNG nho SANG NEN MOI");
         if(glbTongLenh>0) glbDemNenVaoLenh++;
      } 
      double MAValue89_h1=FunTinhMAValue(inpTFKhungNho,inpMAPeriod89_H1,inpMAMethod89_H1,inpAppliedPrice89_H1,0);
      //Vao lenh BUY
      if(glbXuHuongKhungLon==0 && FunKiemTraDieuKienKhungLon()==0 && FunKiemTraDieuKienKhungNho()==0 && Bid<=MAValue89_h1)
      {
         if(glbTimeVaoLenh!=Time[0] && (glbDemNenVaoLenh==0 || glbDemNenVaoLenh>inpSoNenVaoLenhTiep))
         {
            // Vao lenh Buy
            int Ticket=-1;
            Ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong);
            if(Ticket>0)
            {
               glbTapLenh[glbTongLenh]=Ticket;
               glbTongLenh++;
               glbTimeVaoLenh=Time[0];
               glbDemNenVaoLenh=1;
               glbLoaiLenhDangVao=OP_BUY;
            }
         }
         return;
      } 
      //Vao lenh SELL 
      if(glbXuHuongKhungLon==1 && FunKiemTraDieuKienKhungLon()==1 && FunKiemTraDieuKienKhungNho()==1 && Bid>=MAValue89_h1)
      {
         if(glbTimeVaoLenh!=Time[0] && (glbDemNenVaoLenh==0 || glbDemNenVaoLenh>inpSoNenVaoLenhTiep))
         {
            // Vao lenh Buy
            int Ticket=-1;
            Ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong);
            if(Ticket>0)
            {
               glbTapLenh[glbTongLenh]=Ticket;
               glbTongLenh++;
               glbTimeVaoLenh=Time[0];
               glbDemNenVaoLenh=1;
               glbLoaiLenhDangVao=OP_SELL;
            }
         }
         return;
      }
      
      if(glbTongLenh>0)
      {
         FunKiemTraLenhChamSLTP();
         FunKiemTraLenhTrailingStop();
         glbMessages="Xu huong khung lon:"+FunTraVeTenXuHuongKhungLon()+"\nTong lenh: "+DoubleToString(glbTongLenh,0)+"\nDem ne vao lenh: "+DoubleToString(glbDemNenVaoLenh,0);
         Comment(glbMessages);
      } 
      else Comment("Xu huong khung lon: "+FunTraVeTenXuHuongKhungLon());
  }
//+------------------------------------------------------------------+
double FunTinhMAValue(ENUM_TIMEFRAMES MA_TimeFrame, int MA_Period, ENUM_MA_METHOD MA_Method, ENUM_APPLIED_PRICE MA_Applied_price, int shift=0)
{
   return iMA(Symbol(),MA_TimeFrame,MA_Period,0,MA_Method,MA_Applied_price,shift);
}
//+------------------------------------------------------------------+
string FunTraVeTenXuHuongKhungLon()
{
   if(glbXuHuongKhungLon==0) return "CANH BUY";
   else if(glbXuHuongKhungLon==1) return "CANH SELL";
   else return "CHUA XAC DINH";
}
int FunKiemTraDieuKienKhungLon()// 0: Buy, 1: Sell, -1: Khong thoa ma dieukien
{
   double MA13,MA34,MA50,MA89;
   MA13=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13_H1,inpMAMethod13_H4,inpAppliedPrice13_H4);
   MA34=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34_H4,inpMAMethod34_H4,inpAppliedPrice34_H4);
   MA50=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50_H4,inpMAMethod50_H4,inpAppliedPrice50_H4);
   MA89=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89_H4,inpMAMethod89_H4,inpAppliedPrice89_H4);
   if(MA13>MA34 && MA34>MA50 && MA50>MA89) return 0;
   if(MA13<MA34 && MA34<MA50 && MA50<MA89) return 1;
   return -1;
}
//********************************************************************/
int FunKiemTraDieuKienKhungNho()// 0: Buy, 1: Sell, -1: Khong thoa ma dieukien
{
   double MA13,MA34,MA50,MA89;
   MA13=FunTinhMAValue(inpTFKhungNho,inpMAPeriod13_H1,inpMAMethod13_H1,inpAppliedPrice13_H1);
   MA34=FunTinhMAValue(inpTFKhungNho,inpMAPeriod34_H1,inpMAMethod34_H1,inpAppliedPrice34_H1);
   MA50=FunTinhMAValue(inpTFKhungNho,inpMAPeriod50_H1,inpMAMethod50_H1,inpAppliedPrice50_H1);
   MA89=FunTinhMAValue(inpTFKhungNho,inpMAPeriod89_H1,inpMAMethod89_H1,inpAppliedPrice89_H1);
   if(MA13>MA34 && MA34>MA50 && MA50>MA89) return 0;
   if(MA13<MA34 && MA34<MA50 && MA50<MA89) return 1;
   return -1;
}
//********************************************************************/
bool FunKiemTraSangNenMoiChuaKhungHienTai()
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
//********************************************************************/
bool FunKiemTraSangNenMoiChuaKhungLon()
{
   static datetime _NenCuoi=iTime(Symbol(),inpTFKhungLon,0);
   datetime _NenHienTai=iTime(Symbol(),inpTFKhungLon,0);
   if(_NenCuoi!=_NenHienTai)
   {
      _NenCuoi=_NenHienTai;
      return true;
   }
   else return false;
 }
//********************************************************************/
int FunKiemTraGiaoCatMA50MA89KhungLonCanhVaoLenh()//0: Cat len, 1: Cat xuong, -1: khong xac dinh
{
   double MA50_shift1, MA50_shift0, MA89_shift1,MA89_shift0;
   MA50_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50_H4,inpMAMethod50_H4,inpAppliedPrice50_H4,0);
   MA89_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89_H4,inpMAMethod89_H4,inpAppliedPrice89_H4,0);
   MA50_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50_H4,inpMAMethod50_H4,inpAppliedPrice50_H4,1);
   MA89_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89_H4,inpMAMethod89_H4,inpAppliedPrice89_H4,1);
   if(MA50_shift1<=MA89_shift1 && MA50_shift0>=MA89_shift0) return 0;
   if(MA50_shift1>=MA89_shift1 && MA50_shift0<=MA89_shift0) return 1;
   return -1;
} 
//********************************************************************/
int FunKiemTraGiaCatMA34MA50KhungLonCanhDongLenh()
{
   double MA34_shift1, MA34_shift0, MA50_shift1,MA50_shift0;
   MA34_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34_H4,inpMAMethod34_H4,inpAppliedPrice34_H4,0);
   MA50_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50_H4,inpMAMethod50_H4,inpAppliedPrice50_H4,0);
   MA34_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34_H4,inpMAMethod34_H4,inpAppliedPrice34_H4,1);
   MA50_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50_H4,inpMAMethod50_H4,inpAppliedPrice50_H4,1);
   if(MA34_shift1<=MA50_shift1 && MA34_shift0>MA50_shift0) return 0;
   if(MA34_shift1>=MA50_shift1 && MA34_shift0<MA50_shift0) return 1;
   return -1;
}
//+------------------------------------------------------------------+
//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void FunDongTatCaCacLenh()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE))
            {
                glbMessages=StringFormat("Cap tien: %s\n\nHanh dong: DONG LENH\nTicket=%d \nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
                glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                glbTongLenh--;
            }
         }
         else
         {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE))
            {
               glbMessages=StringFormat("Cap tien: %s\nHanh dong: DONG LENH\nTicket=%d \nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
               glbBotTelegram.SendMessage(inpChannelName,glbMessages); 
               glbTongLenh--;
            }
         }   
      }
   }
   glbDemNenVaoLenh=0;
   glbLoaiLenhDangVao=-1;
   ArrayFill(glbTapLenh,0,100,0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
 void FunKiemTraLenhChamSLTP()
 {
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbMessages=StringFormat("Cap tien: %s\nHanh dong: DONG LENH.\nTicket=%d\nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
            glbBotTelegram.SendMessage(inpChannelName,glbMessages);
            glbTapLenh[i]=0;
            for(int j=i+1;j<glbTongLenh;j++)
            {
               int Tam=glbTapLenh[j-1];
               glbTapLenh[j-1]=glbTapLenh[j];
               glbTapLenh[j]=Tam;
            }
            glbTongLenh--;
         }
      }
   }
   if(glbTongLenh==0)
   {
      glbDemNenVaoLenh=0;
      glbLoaiLenhDangVao=-1;
      
   }
 }
 
 void FunKiemTraLenhTrailingStop()
 {
    if(inpTrailingStop<=0) return;
    for(int i=0;i<glbTongLenh;i++)
   {
          FunTrailingStopTicket( glbTapLenh[i]);
   }
 }
 
 void FunTrailingStopTicket(int ticket)
{
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
         double DiemTrailingStop=inpTrailingStop*10;
         double SoPointLoiLo=FunCountProfitPoints(OrderTicket());
         if (SoPointLoiLo>DiemTrailingStop)
         {
            double StopLoss=0;
            if(OrderType()==1)//lệnh sell
            {
            
               StopLoss=Bid+ DiemTrailingStop*Point;
               if(OrderStopLoss()>StopLoss && StopLoss<OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh SELL that bai");            
            }
            else if(OrderType()==0)// Lệnh buy
            {
               StopLoss=Bid-DiemTrailingStop*Point;
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
 