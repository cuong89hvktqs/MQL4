//+------------------------------------------------------------------+
//|                                          Break_In_Time_AnhDo.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int inpCandelSize=40;//Candel size (points):
input int inpCandelMiliseconds=1000;// Candel Miliseconds:
input double inpVolume=0.01;// Volumes:
input int inpSL=300;// Stoploss (points):
input int inpTP=600;// Tacke profit (points):
input bool inpArlet=false;//Use Arlert:
input int inpDelayTP=60;//Second to wait after TP:
input int inpDelaySL=10;//Second to wait after SL:
input int inpMaxSpread=100;// Max spread (points):
input int inpMagicNumber=123345;// Magic number:
input int inpSlippage=100;//Slippage (points):
input int inpTrailingStop=300;// Traling stop (points):
input int inpBreakeven=100;// Break even (points):
input int inpLockProfitTrigger=200;// Lock profit trigger (points):
input int inpLockProfit=50;// Lock profit (points):
input double inpStartTime=8;// Start time (Server time):
input double inpEndTime=22;// End time (Server time):             
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int glbTicket=-1;
struct NgayThang
{
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
};
NgayThang NgayHetHan={1,01,2022};

double glbPrePrice=0;
double glbCurrPrice=0;
double glbMaxPoints=0;// Max(MathAbs(glbCurrPrice-glbPrePrice));
int glbRedOrGreenCandel=0;//-1: Red; 1: Green
uint glbPreTickCount=0;
int glbCountTime=0;
uint glbDelayTickCount=0;// Băt dau tính Tickcout để Thoi gian tre can cho de vao lenh
int glbMaxDelayTimeToNewOrder=0;
string glbComment="";
int OnInit()
  {
//---
      if(IsDemo()!=true && FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      glbPreTickCount=GetTickCount();
      glbPrePrice=Bid;
      glbCurrPrice=Bid;
      glbComment="\n -----------------------------------------------\n Account Type: "+FunAccountType()+"\n -----------------------------------------------\n"; 
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
     
     FunTinhPointChenhLech();
     string str=glbComment;
     str+=" Broker Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"\n Trade Lots:  "+DoubleToString(inpVolume,2)+"\n Spread = "+DoubleToString(MarketInfo(Symbol(),MODE_SPREAD),1);
     str+="\n Candel= "+DoubleToStr(glbMaxPoints,1)+" points/"+IntegerToString(glbCountTime)+" MiliSeconds\n-----------------------------------------------\n";
     if(glbTicket<=0)
     {
        if(FunCheckTime()==false) {str+=" IT'S NOT TIME TO TRADE"; Comment(str);return;}
        //Kiểm tra độ giãn spread
        if(MarketInfo(Symbol(),MODE_SPREAD)>inpMaxSpread) {str+=" OVER SPREAD"; Comment(str);return;}
        int delayTime=(int)(GetTickCount()-glbDelayTickCount);
        Print("TickCount:",GetTickCount(), "  Delay count:",glbDelayTickCount);
        if(delayTime<=glbMaxDelayTimeToNewOrder) {str+=" STOP TRADE IN "+IntegerToString(glbMaxDelayTimeToNewOrder)+ " MILI SECONDS: "+IntegerToString(delayTime); Comment(str);return;}
        else glbDelayTickCount=0;
        if(glbMaxPoints>=inpCandelSize && glbCountTime<=inpCandelMiliseconds)
        {
            //Open Order
            Print("Open order. Maxpoint: ",glbMaxPoints, " CountTime= ",glbCountTime, " NenXanhDo= ",glbRedOrGreenCandel);
            if(glbRedOrGreenCandel==-1)
            {
               glbTicket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpVolume);
               if(glbTicket>0)
               {
                  str+="\n ORDER IS OPENED";
                  Print("Vao lenh. Ticket=",glbTicket);
               }
               else
                  Print("Loi vao lenh sell");
            }
            else if(glbRedOrGreenCandel==1)
            {
               glbTicket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpVolume);
               if(glbTicket>0)
               {
                  str+="\n ORDER IS OPENED";
                  Print("Vao lenh. Ticket=",glbTicket);
               }
               else
                  Print("Loi vao lenh Buy");
            }
        }
        else
        {str+=" WAITING TO TRADE"; Comment(str);return;}
     }
     else
     {
         OrderSelect(glbTicket,SELECT_BY_TICKET,MODE_TRADES);
         if(OrderCloseTime()>0)
         {
            // Dong lenh doi 60s
            glbTicket=-1;
            
            glbDelayTickCount=GetTickCount();
            // Tính thời gian đợi lệnh mới
            if(OrderProfit()>0) glbMaxDelayTimeToNewOrder=inpDelayTP*1000;
            else glbMaxDelayTimeToNewOrder=inpDelaySL*1000;
         }
         else
         { 
            str+=" ORDER IS OPENING";
            Print("Vao lenh. Ticket=",glbTicket);
            FunBreakEven(glbTicket);
            FunLockProfit(glbTicket);
            FunTraiLingStop(glbTicket);
         }
     }
     Comment(str);
  }
 
  
void FunTinhPointChenhLech()
{
   glbCurrPrice=Bid;
  // Print("Pre Price:",glbPrePrice, " Curr:",glbCurrPrice);
   
   double currPoints=(glbCurrPrice-glbPrePrice)/Point();
   
   if(MathAbs(currPoints)>glbMaxPoints)
   {
      glbMaxPoints=(int)MathAbs(currPoints);
      if(currPoints<=0)glbRedOrGreenCandel=-1;
      else glbRedOrGreenCandel=1;
      glbPrePrice=glbCurrPrice;
   }
   glbCountTime=(int)(GetTickCount()-glbPreTickCount);
   if((glbCountTime)>inpCandelMiliseconds)
      FunReSetCounter();
   
}

void FunReSetCounter()
{
    glbPrePrice=Bid;
    glbCurrPrice=Bid;
    glbMaxPoints=0;// Max(MathAbs(glbCurrPrice-glbPrePrice));
    glbRedOrGreenCandel=0;//-1: Red; 1: Green
    glbPreTickCount=GetTickCount();
    glbCountTime=0;
}
// This is an EVENT function that will be called every
// x milliseconds [see EventSetMillisecondTimer() in OnInit()]

//+------------------------------------------------------------------+
//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPoints, double TakeProfitPoints, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       StopLoss=DiemVaoLenh-StopLossPoints*Point();
       TakeProfit=DiemVaoLenh+TakeProfitPoints*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      StopLoss=DiemVaoLenh+StopLossPoints*Point();
       TakeProfit=DiemVaoLenh-TakeProfitPoints*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//-----------------------------------------Trailing stop-----------------------------------------

void FunTraiLingStop(int ticket)
{
   if(inpTrailingStop<=0) return;
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
         double DiemTrailingStop=inpTrailingStop;
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
 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunBreakEven(int ticket)
{
   if(inpBreakeven<=0) return;
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice())
         {
            if(Bid>=(OrderOpenPrice()+inpBreakeven*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point(),OrderTakeProfit(),0,clrNONE))
                Print("Breakeven error");  
               else Print("Breakeven");  
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice())
         {
            if(Bid<=(OrderOpenPrice()-inpBreakeven*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("Breakeven error");  
               else Print("Breakeven"); 
         }
      }
      
   }

}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void FunLockProfit(int ticket)
{
   if(inpLockProfitTrigger<=0) return;
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<(OrderOpenPrice()+inpLockProfit*Point))
         {
            
            if(Bid>=(OrderOpenPrice()+inpLockProfitTrigger*Point))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+inpLockProfit*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("Lock profit error");
               else Print("Lock profit");
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>(OrderOpenPrice()-inpLockProfit*Point))
         {
            if(Bid<=(OrderOpenPrice()-inpLockProfitTrigger*Point))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-inpLockProfit*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("Lock profit error");
               else Print("Lock profit");
         }
      }
      
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunCheckTime()
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(gio>=inpStartTime && gio<inpEndTime) return true;
   else return false;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


string FunAccountType()
{
   if(IsDemo()) return "DEMO";
   else return "REAL";
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

