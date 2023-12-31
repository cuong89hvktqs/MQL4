//+------------------------------------------------------------------+
//|                                                     BB_Quang.mq4 |
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
input int inpTP=100;//TP (pips):
input int inpSL=50;//SL (pips);
input int inpTrailingStop=20;// Trailing stop (pips):
input int inpSoNenVaoLenhTiep=14;// So nen vao lenh tiep theo:
input int inpMaNgan=20;// MA ngan:
input int inpMaTrungBinh=50;//MA Trung binh:
input int inpMaDai=200;//MA dai:
input ENUM_MA_METHOD inpMAKieu=MODE_EMA;//Loai MA:
input ENUM_APPLIED_PRICE inpMAGia=PRICE_CLOSE;// Gia tinh MA;
input int inpBB=20;// Kieu BB:
input ENUM_APPLIED_PRICE inpBBGia=PRICE_CLOSE;
input double inpBBDevitation=2;//BB devitation:
input int inpMagicNumber=123;// Magic number:
input int inpSlippage=50;//Slippage (points):
int glbTongLenh=0;
int glbTapLenh[100];
int glbDemNenVaoLenh=0;
int glbLoaiLenhDangVao=-1;
datetime glbTimeVaoLenh;// Mooix nen chi co 1 lenh
string glbMessages="";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      
      Print(Time[0]);
      glbTimeVaoLenh=Time[1];
      glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele);
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
      if(glbTongLenh==0)
      {
         double MANgan=FunTinhMaValue(inpMaNgan);
         double MADai=FunTinhMaValue(inpMaDai);
         double MATrungBinh=FunTinhMaValue(inpMaTrungBinh);
         
         if(MANgan>MATrungBinh && MATrungBinh>MADai)
         {
            double BBLow=FunTinhBBValueLow(inpBB);
            if(Low[0]<=BBLow)
            {
                 if(glbTimeVaoLenh==Time[0]) return;
                 int ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                   {
                      glbMessages=StringFormat("Cap tien: "+ Symbol()+"\nHanh dong: BUY\nTicket=%d",ticket);
                      glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                      glbTapLenh[glbTongLenh]=ticket;glbTongLenh++; glbLoaiLenhDangVao=OP_BUY;glbTimeVaoLenh=Time[0];
                   }  
                  else Print("Vao lenh Buy loi");
            }
            else Comment("Canh vao lenh Buy","\nMA ngan: ",DoubleToString(MANgan,5), "\nMA dai:",DoubleToStr(MADai,5));
         }
          if(MANgan<MATrungBinh && MATrungBinh<MADai)
         {
            double BBUp=FunTinhBBValueUpper(inpBB);
            if(High[0]>=BBUp)
            {
                 if(glbTimeVaoLenh==Time[0]) return;
                 int ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                  {
                  
                     glbMessages=StringFormat("Cap tien: "+ Symbol()+"\nHanh dong: SELL\nTicket=%d",ticket);
                     glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                     glbTapLenh[glbTongLenh]=ticket;glbTongLenh++; glbLoaiLenhDangVao=OP_SELL;glbTimeVaoLenh=Time[0]; 
                  }
                  else Print("Vao lenh Sell loi"); 
            }
            else Comment("Canh vao lenh Sell",DoubleToString(MANgan,5), "\nMA dai:",DoubleToStr(MADai,5));
            
         }
      }
      else
      {
         Comment("Tong lenh:",glbTongLenh,"\nDem nen:",glbDemNenVaoLenh);
         if(FunKiemTraSangNenMoiChua()) glbDemNenVaoLenh++;
         //////////////// Kiem tra dong lenh theo SL, TP////////////////////////////////////////
         FunKiemTraLenhChamSLTP();
         FunKiemTraLenhTrailingStop();
         // Kiem tra ddonsg lenehj khi ma50 giao cat ma200
         if(FunKiemTraDieuKienDognLenhTheoMA(glbLoaiLenhDangVao)==true)
         {
            if(glbLoaiLenhDangVao==true) glbBotTelegram.SendMessage(inpChannelName,"Cap tien: "+ Symbol()+"\nDang co lenh BUY.\nMA50 cat xuong MA200.");
            else  glbBotTelegram.SendMessage(inpChannelName,"Cap tien: "+ Symbol()+"\nDang co lenh SELL.\nMA50 cat len MA200.");
            
          //  Print("Dong lenh. DO MA50 gia cat MA200");
          //  FunDongTatCaCacLenh();
         }
         ///////////////// Kiem tra vao lenh tiep theo//////////////////////////////////////////
         if(glbLoaiLenhDangVao==OP_BUY)
         {
            if(FunTinhMaValue(inpMaNgan)>FunTinhMaValue(inpMaTrungBinh) && FunTinhMaValue(inpMaTrungBinh)>FunTinhMaValue(inpMaDai)&& Low[0]<=FunTinhBBValueLow(inpBB))
            {
               
               if(glbDemNenVaoLenh>=inpSoNenVaoLenhTiep)
               {
                  Print("MA ngan: ",FunTinhMaValue(inpMaNgan), " MA dai: ", FunTinhMaValue(inpMaDai), " BB low: ",FunTinhBBValueLow(inpBB));
                  int ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                  {
                     glbMessages=StringFormat("Cap tien: "+ Symbol()+"\nHanh dong: BUY\nTicket=%d",ticket);
                      glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                     {glbTapLenh[glbTongLenh]=ticket;glbTongLenh++;glbDemNenVaoLenh=0;}  
                  }
                  else Print("Vao lenh Buy loi");
               }
            }
            
         }
         else
         {
            if(FunTinhMaValue(inpMaNgan)<FunTinhMaValue(inpMaTrungBinh) && FunTinhMaValue(inpMaTrungBinh)<FunTinhMaValue(inpMaDai) &&High[0]>=FunTinhBBValueUpper(inpBB))
            {
               
               if(glbDemNenVaoLenh>=inpSoNenVaoLenhTiep)
               {
                  Print("MA ngan: ",FunTinhMaValue(inpMaNgan), " MA dai: ", FunTinhMaValue(inpMaDai), " BB up: ",FunTinhBBValueUpper(inpBB));
                  int ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                  {
                     glbMessages=StringFormat("Cap tien: "+ Symbol()+"\nHanh dong: SELL\nTicket=%d",ticket);
                      glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                   {glbTapLenh[glbTongLenh]=ticket;glbTongLenh++;glbDemNenVaoLenh=0;}  
                  }
                  else Print("Vao lenh Sell loi"); 
               }
            }
         }
         /*
         /////////Kiem tra dong lenh khi cham BB/////////////////////////
         if(glbLoaiLenhDangVao==OP_BUY)
         {
            double BBBandTren=FunTinhBBValueUpper(inpBB);
            if(High[0]>=BBBandTren) 
            {
               FunDongTatCaCacLenh();
               if(FunTinhMaValue(inpMaNgan)<FunTinhMaValue(inpMaDai))
               {
                  int ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                   {glbTapLenh[glbTongLenh]=ticket;glbTongLenh++; glbLoaiLenhDangVao=OP_SELL;} 
                  else Print("Vao lenh Sell loi"); 
               }
            }
         }
         else
         {
            double BBBandDuoi=FunTinhBBValueLow(inpBB);
            if(Low[0]<=BBBandDuoi) 
            {
               FunDongTatCaCacLenh();   
               if(FunTinhMaValue(inpMaNgan)>FunTinhMaValue(inpMaDai))
               {
                  int ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong);
                  if (ticket>0)
                   {glbTapLenh[glbTongLenh]=ticket;glbTongLenh++; glbLoaiLenhDangVao=OP_BUY;}  
                  else Print("Vao lenh Buy loi");
               }
            }
         }

         */
      }
  }
//+------------------------------------------------------------------+

double FunTinhMaValue(int MAPeriod)
{
   return iMA(Symbol(),0,MAPeriod,0,inpMAKieu,inpMAGia,0);
}

double FunTinhBBValueUpper(int BBPeriod)
{
   return iBands(Symbol(),0,inpBB,inpBBDevitation,0,inpBBGia,MODE_UPPER,0);
}

double FunTinhBBValueLow(int BBPeriod)
{
   return iBands(Symbol(),0,inpBB,inpBBDevitation,0,inpBBGia,MODE_LOWER,0);
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
    for(int i=0;i<glbTongLenh;i++)
   {
          FunTrailingStopTicket( glbTapLenh[i]);
   }
 }
 
 void FunTrailingStopTicket(int ticket)
{
   if(inpTrailingStop<=0) return;
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
 

bool FunKiemTraDieuKienDognLenhTheoMA(int LoaiLenh)// True: Thoa man dieu kien dong lenh, false khong thoa man
{
  
   double ma50_0=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,0);
   double ma50_1=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,1);
   double ma200_1=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,1);
    double ma200_0=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,0);
   //  Print("Kiem tra dong lenh buy sell");
    if(LoaiLenh==OP_BUY)
    {
      if(ma50_0<ma200_0 && ma50_1>=ma200_1) return true;
      else return false;
    }
    else if(LoaiLenh==OP_SELL)
    {
      if(ma50_0>ma200_0 && ma50_1<=ma200_1) return true;
      else return false;
    }
    else return false;
}