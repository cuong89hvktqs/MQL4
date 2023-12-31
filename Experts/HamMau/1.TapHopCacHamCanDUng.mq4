//+------------------------------------------------------------------+
//|                                          TapHopCacHamCanDUng.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
input double inpStartTime=8;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=22;// Thoi Gian Ket Thuc vao lenh(Server time):
input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1735772983:AAG4g3Qem_oGQN3bpTmztuLHiT67bQCsXWs";//Ma Token bot Telegram:

CCustomBot glbBotTelegram;
string glbMessages="";
int glbSlippage=50;
int glbMagic=12345;

int glbTongLenh=0;
int glbTapLenh[200];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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


struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,04,3022};

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
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
 string FunTraVeTenLenh(int LoaiLenh)
 {
   switch (LoaiLenh)
   {
      case OP_BUY: return "BUY";
      break;
      case OP_SELL:return "SELL";
      break;
      case OP_BUYLIMIT:return "BUY LIMIT";
      break;
      case OP_SELLLIMIT:return "SELL LIMIT";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
 
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
/**
 * This function fulfills the will of the developer
 * @param  LoaiLenh: Argument 1
 * @param  LoiNhuanCanDatDuocTP: Argument 2
 * @param  LoiNhuanCatLoSL: Argument 3
 */
void FunCapNhatDiemTPSL(int LoaiLenh,double LoiNhuanCanDatDuocTP=0,double LoiNhuanCatLoSL=-0)
{
   double DiemDongTatCaCacLenhTP=0;
   double DiemDongTatCaCacLenhSL=0;
   double TongComVaSwap=0;
   double TongTheoGia=0;
   double TongKhoiLuong=0;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(LoiNhuanCatLoSL>0) LoiNhuanCatLoSL=-LoiNhuanCatLoSL;
   if(LoaiLenh==OP_BUY)
   {
      for(int i=0;i<glbTongLenh;i++)
      {
         OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      if(LoiNhuanCanDatDuocTP==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue)+TongTheoGia)/TongKhoiLuong;
      if(LoiNhuanCatLoSL==0)DiemDongTatCaCacLenhSL=0;
      else DiemDongTatCaCacLenhSL=(((LoiNhuanCatLoSL-TongComVaSwap)*Point()/nTickValue)+TongTheoGia)/TongKhoiLuong;
      Print("SL:",DiemDongTatCaCacLenhSL,"  TP:",DiemDongTatCaCacLenhTP," tien SL:",LoiNhuanCatLoSL);
      if(DiemDongTatCaCacLenhSL!=0 || DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhSL=NormalizeDouble(DiemDongTatCaCacLenhSL,Digits);
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongLenh;i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,DiemDongTatCaCacLenhTP,0,clrNONE);
           // OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,OrderTakeProfit(),0,clrNONE);
         }
      }
      
   }
   else
   {
    //   Print("Tong lenh sell:",glbTongLenhSell," Loi nhuan can dat duoc:",LoiNhuanCanDatDuoc);
      for(int i=0;i<glbTongLenh;i++)
      {
         OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
   //   Print("Tong com:",TongComVaSwap," TongTheoGia:",TongTheoGia," Tong Khoi Luong:",TongKhoiLuong);
      if(LoiNhuanCanDatDuocTP==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(TongTheoGia-((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue))/TongKhoiLuong;
      if(LoiNhuanCatLoSL==0)DiemDongTatCaCacLenhSL=0;
      else DiemDongTatCaCacLenhSL=(TongTheoGia-((LoiNhuanCatLoSL-TongComVaSwap)*Point()/nTickValue))/TongKhoiLuong;
      Print("SL:",DiemDongTatCaCacLenhSL,"  TP:",DiemDongTatCaCacLenhTP," tien SL:",LoiNhuanCatLoSL);
      if(DiemDongTatCaCacLenhSL!=0 || DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhSL=NormalizeDouble(DiemDongTatCaCacLenhSL,Digits);
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongLenh;i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,DiemDongTatCaCacLenhTP,0,clrNONE);
            //OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,OrderTakeProfit(),0,clrNONE);
         }
      }
      
   }
}

 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 string FunTraVeTenLenh_V2(int LoaiLenh)
 {
   switch (LoaiLenh)
   {
      case OP_BUY: return "BUY";
      break;
      case OP_SELL:return "SELL";
      break;
      case OP_BUYLIMIT:return "BUY LIMIT";
      break;
      case OP_SELLLIMIT:return "SELL";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
 
 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(inpStartTime<=inpEndTime)
      if(gio>=inpStartTime && gio<inpEndTime) return true;
      else return false;
   else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
      if(gio>=inpEndTime&&gio<inpStartTime) return false;
      else return true;
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 double FunDemSoPipLoiLoHienTai(int TichKet)
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
                  glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLOI KHI DONG LENH BUY: ERROR",Symbol()));   
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
                  glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\n LOI KHI DONG LENH SELL: ERROR",Symbol()));   
               }
               else 
               {  
                  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;  
              }
            }
         }
      }
   }
   /*
   while(glbLenhLimit>0)
   {
      if(OrderDelete(glbLenhLimit))
      {
         glbLenhLimit=-1;
          glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nXOA LENH LIMIT\nTicket: %d",Symbol(),glbLenhLimit));   
       }
   }
   */
}

 //---------------------------------Tinh khoi luong vao lenh-----------------------------------------
double FunTinhKhoiLuongVaoLenh(double stoploss, double diemvaolenh, double SoTienRuiRo)
{
   double khoi_luong_nho_nhat=MarketInfo(Symbol(),MODE_MINLOT);
   if(SoTienRuiRo>0)
   {
      double point=MathAbs(stoploss-diemvaolenh)/Point();
      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
      double TongLoChoPhep=SoTienRuiRo;
      double khoiluongvaolenh=NormalizeDouble(TongLoChoPhep/(point*nTickValue),FunPhanThapPhanKhoiLuong());
      if(khoiluongvaolenh<khoi_luong_nho_nhat)khoiluongvaolenh=khoi_luong_nho_nhat;
      return khoiluongvaolenh;
   }
   else return 0;
}
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDichHoaVon(int ticket, int SoPipDeDichHoaVon)
{
   //if(inpBreakeven<=0) return;
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice())
         {
            if(Bid>=(OrderOpenPrice()+SoPipDeDichHoaVon*10*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point(),OrderTakeProfit(),0,clrNONE))
                Print("Dia hoa von LOI");  
              // else Print("Breakeven");  
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice())
         {
            if(Bid<=(OrderOpenPrice()-SoPipDeDichHoaVon*10*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("hoa von bi LOI");  
               //Dic else Print("Breakeven"); 
         }
      }
      
   }

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
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongLenh--;
         }
      }
   }
}
//----------------------------------------------------------------------------------------//
 void FunXoaPhanTuKhoiMang(int &MangCanXoa[], int &TongSoPhanTu, int ticketCanXoa)
 {
      for(int i=0;i<TongSoPhanTu;i++)
      {
         if(MangCanXoa[i]==ticketCanXoa)
         {
            for(int j=i;j<TongSoPhanTu-1;j++)
            {
               MangCanXoa[j]=MangCanXoa[j+1];
            }
            TongSoPhanTu--;
         }
      }
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

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDongTatCaCacLenh_V2()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
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
}



 