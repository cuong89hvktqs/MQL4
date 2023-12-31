//+------------------------------------------------------------------+
//|                                       Martinggel_NhanLenhMoi.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input double inpKhoiLuongGiaoDich=0.1;// Khoi luong giao dich:
input double inpBuocNhayBuy=20;// Buoc nhay buy(pips):
input double inpBuocNhaySell=20;// Buoc nhay sell (pips):
input double inpTP=40;// Take profit (pips):
input double inpSL=40;// Stop loss (pips):
input double inpGiaBuyLimit=0;// Gia canh buy limit khi khong co lenh buy nao:
input double inpGiaSellLimit=0;// Gia canh sell limit khi khong co lenh sell nao:
input int inpSlippage=50;//Slippage:
input int inpMagicNumber=12345;// Magic number:

struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,02,3023};
bool glbDaCoLenhSell=false;
bool glbDaCoLenhBuy=false;
int glbTicketLenhBuyCuoiCung=-1;
int glbLenhLimitBuy=-1;
int glbTicketLenhSellCuoiCung=-1;
int glbLenhLimitSell=-1;
double glbBuocNhayBuy=0;
double glbBuocNhaySell=0;
// Khi khong co lenh buy nao, neu gia nam tren gia X, dat 1 lenh buy limit
int glbLenhBuyLimitTheoGiaCoSan=-1;
// Khi khong co lenh sell nao, neu gia nam duoi gia X, dat 1 lenh sell limit
int glbLenhSellLimitTheoGiaCoSan=-1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
      glbBuocNhayBuy=inpBuocNhayBuy*10*Point();
      glbBuocNhaySell=inpBuocNhaySell*10*Point();
      FunXoaLenhLimit(OP_BUYLIMIT);
      FunXoaLenhLimit(OP_SELLLIMIT);
      glbTicketLenhBuyCuoiCung=FunTimLenhBuyHoacSellCuoiCung(OP_BUY);
      glbTicketLenhSellCuoiCung=FunTimLenhBuyHoacSellCuoiCung(OP_SELL);
      
      if(glbTicketLenhBuyCuoiCung>0)
      {
         if(OrderSelect(glbTicketLenhBuyCuoiCung,SELECT_BY_TICKET,MODE_TRADES))
         {
            double StopLoss=0, TakeProfit=0;
            if(inpSL>0) StopLoss=OrderOpenPrice()-inpSL*10*Point();
            if(inpTP>0) TakeProfit=OrderOpenPrice()+inpTP*10*Point();
            OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,TakeProfit,0,clrNONE);
            
            glbLenhLimitBuy=FunVaoLenh(OP_BUYLIMIT,OrderOpenPrice()-glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);   
                   
         }
      }
      if(glbTicketLenhSellCuoiCung>0)
      {
         if(OrderSelect(glbTicketLenhSellCuoiCung,SELECT_BY_TICKET,MODE_TRADES))
         {
            double StopLoss=0, TakeProfit=0;
            if(inpSL>0) StopLoss=OrderOpenPrice()+inpSL*10*Point();
            if(inpTP>0) TakeProfit=OrderOpenPrice()-inpTP*10*Point();
            OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,TakeProfit,0,clrNONE);
            
            glbLenhLimitSell=FunVaoLenh(OP_SELLLIMIT,OrderOpenPrice()+glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);          
         }
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
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      
      Comment("Dang co lenh. Dang canh nhoi lenh.\nLenh buy cuoi cung: ",glbTicketLenhBuyCuoiCung, "\nLenh sell cuoi cung: ",glbTicketLenhSellCuoiCung);
      FunXuLyLenhBuy();
      FunXuLyLenhSell();
      
      if(Bid>inpGiaBuyLimit && inpGiaBuyLimit>0)
      {
         if(glbLenhBuyLimitTheoGiaCoSan<0 && FunKiemTraXemCoLenhBuyHaySellKhong(OP_BUY)==false)
         {
            glbLenhBuyLimitTheoGiaCoSan=FunVaoLenh(OP_BUYLIMIT,inpGiaBuyLimit,inpSL,inpTP,inpKhoiLuongGiaoDich);
         }
      }
      if(Bid<inpGiaSellLimit && inpGiaSellLimit>0)
      {
         if(glbLenhSellLimitTheoGiaCoSan<0 && FunKiemTraXemCoLenhBuyHaySellKhong(OP_SELL)==false)
         {
            glbLenhSellLimitTheoGiaCoSan=FunVaoLenh(OP_SELLLIMIT,inpGiaSellLimit,inpSL,inpTP,inpKhoiLuongGiaoDich);
         }
      }     
      if(glbLenhBuyLimitTheoGiaCoSan>0)
      {
         if(OrderSelect(glbLenhBuyLimitTheoGiaCoSan,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) glbLenhBuyLimitTheoGiaCoSan=-1;
         }
         if(FunKiemTraXemCoLenhBuyHaySellKhong(OP_BUY)==true)
         {
            OrderDelete(glbLenhBuyLimitTheoGiaCoSan);
            glbLenhBuyLimitTheoGiaCoSan=-1;
         }         
      }
      
      if(glbLenhSellLimitTheoGiaCoSan>0)
      {
         if(OrderSelect(glbLenhSellLimitTheoGiaCoSan,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) glbLenhSellLimitTheoGiaCoSan=-1;
         }
         if(FunKiemTraXemCoLenhBuyHaySellKhong(OP_SELL)==true)
         {
            OrderDelete(glbLenhSellLimitTheoGiaCoSan);
            glbLenhSellLimitTheoGiaCoSan=-1;
         }      
      }
      
      if(glbTicketLenhBuyCuoiCung==-1 && glbTicketLenhSellCuoiCung==-1)
      {
         Comment("Doi lenh moi moi");
         return;
      } 
      
  }
  
//+------------------------------------------------------------------+  
bool FunKiemTraXemCoLenhBuyHaySellKhong(int LoaiLenh)//True: Co, false: khong
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()==LoaiLenh)
         {
            return true;
         }
      }
   }
   return false;
} 
//+------------------------------------------------------------------+  
void FunXuLyLenhBuy()
{
  // Xu ly buy
   if(glbLenhLimitBuy>0)
   {
         if(OrderSelect(glbLenhLimitBuy,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) glbLenhLimitBuy=-1;
            else if(OrderType()==OP_BUY)
            {
               glbTicketLenhBuyCuoiCung=glbLenhLimitBuy;
               glbLenhLimitBuy=FunVaoLenh(OP_BUYLIMIT,OrderOpenPrice()-glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);
            }
         }
   } 
   if(glbTicketLenhBuyCuoiCung>0)
   {
      if(OrderSelect(glbTicketLenhBuyCuoiCung,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderCloseTime()>0)
         {
            glbTicketLenhBuyCuoiCung=-1;
            OrderDelete(glbLenhLimitBuy);
            glbLenhLimitBuy=-1;
         }
         else
         {
            if(glbLenhLimitBuy<=0)
               glbLenhLimitBuy=FunVaoLenh(OP_BUYLIMIT,OrderOpenPrice()-glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);
         }
      }
   }
   else
   {
      glbTicketLenhBuyCuoiCung=FunTimLenhBuyHoacSellCuoiCung(OP_BUY);
      if(glbTicketLenhBuyCuoiCung>0)
      {
            double StopLoss=0, TakeProfit=0;
            if(inpSL>0) StopLoss=OrderOpenPrice()-inpSL*10*Point();
            if(inpTP>0) TakeProfit=OrderOpenPrice()+inpTP*10*Point();
            OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,TakeProfit,0,clrNONE);
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+  
void FunXuLyLenhSell()
{
  // Xu ly buy
   if(glbLenhLimitSell>0)
   {
         if(OrderSelect(glbLenhLimitSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) glbLenhLimitSell=-1;
            else if(OrderType()==OP_SELL)
            {
               glbTicketLenhSellCuoiCung=glbLenhLimitSell;
               glbLenhLimitSell=FunVaoLenh(OP_SELLLIMIT,OrderOpenPrice()+glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);
            }
         }
   } 
   if(glbTicketLenhSellCuoiCung>0)
   {
      if(OrderSelect(glbTicketLenhSellCuoiCung,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderCloseTime()>0)
         {
            glbTicketLenhSellCuoiCung=-1;
            OrderDelete(glbLenhLimitSell);
            glbLenhLimitSell=-1;
         }
         else
         {
            if(glbLenhLimitSell<0)
               glbLenhLimitSell=FunVaoLenh(OP_SELLLIMIT,OrderOpenPrice()+glbBuocNhayBuy,inpSL,inpTP,inpKhoiLuongGiaoDich);
         }
      }
   }
   else
   {
     // Print("Tim lenh sell");
      glbTicketLenhSellCuoiCung=FunTimLenhBuyHoacSellCuoiCung(OP_SELL);
      if(glbTicketLenhSellCuoiCung>0)
      {
            double StopLoss=0, TakeProfit=0;
            if(inpSL>0) StopLoss=OrderOpenPrice()+inpSL*10*Point();
            if(inpTP>0) TakeProfit=OrderOpenPrice()-inpTP*10*Point();
            OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,TakeProfit,0,clrNONE);
      }
   }
}
//+------------------------------------------------------------------+ 
int FunTimLenhBuyHoacSellCuoiCung(int LoaiLenh)
{
   int LenhCuoiCung=-1;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()==LoaiLenh && OrderSymbol()==Symbol())
         {
            LenhCuoiCung=OrderTicket();
            break;
         }
      }
   }   
   return LenhCuoiCung;
}
//+------------------------------------------------------------------+
void FunXoaLenhLimit( int LoaiLenhLimit)
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol() && OrderType()==LoaiLenhLimit)
         {
            OrderDelete(OrderTicket());
         }
      }
   }
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
      case OP_SELLLIMIT:return "SELL";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
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