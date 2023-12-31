//+------------------------------------------------------------------+
//|                                      Martingel_Buy_Sell_Luoi.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input int inpBuocNhay=10;//Buoc nhay (pips):
input double inpKhoiLuongBanDau=0.01;//Khoi luong ban dau (lots):
input double inpHeSoNhanKhoiLuong=2;//He so nhan khoi luong:
input double inpLoiNhuanMongMuon=2;//Loi nhuan mong muon($):
input int inpSlippage=50;
input int inpMagic=12345;
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang glbNgayHetHan={30,05,3023};

int glbSlippage=50;
int glbMagic=12345;
int glbLenhBuyDau=-1;
int glbLenhSellDau=-1;
int glbLenhLe=-1;
int glbTongSoLenh=0;
int glbTapLenh[200];
int glbLoaiLenhCuatTapLenh;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   glbMagic=inpMagic;
   glbSlippage=inpSlippage;
   if(FunKiemTraHetHan(glbNgayHetHan)==false) return INIT_FAILED;
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
      if(glbLenhBuyDau<=0&&glbLenhSellDau<=0)//Chua co lenh nao, vao lenh
      {
         if(glbTongSoLenh<=0)
         {
            glbLenhBuyDau=FunVaoLenh(OP_BUY,Ask,0,inpBuocNhay,inpKhoiLuongBanDau);
            glbLenhSellDau=FunVaoLenh(OP_SELL,Bid,0,inpBuocNhay,inpKhoiLuongBanDau);
         }
      }
      else if(glbLenhBuyDau>0&&glbLenhSellDau>0)
      {
         if(OrderSelect(glbLenhBuyDau,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) 
            {
               glbLenhBuyDau=-1;
               glbTapLenh[glbTongSoLenh]=glbLenhSellDau;
               glbTongSoLenh++;
               glbLenhSellDau=-1;
               glbLenhLe=FunVaoLenh(OP_BUY,Ask,0,inpBuocNhay,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
               glbTapLenh[glbTongSoLenh]=FunVaoLenh(OP_SELL,Bid,0,0,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
               glbLoaiLenhCuatTapLenh=OP_SELL;
               FunCapNhatDiemTPSL(glbLoaiLenhCuatTapLenh,inpLoiNhuanMongMuon);
               glbTongSoLenh++;
               return;
            }
         }
         if(OrderSelect(glbLenhSellDau,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0) 
            {
                glbLenhSellDau=-1;
                glbTapLenh[glbTongSoLenh]=glbLenhBuyDau;
                glbTongSoLenh++;
                glbLenhBuyDau=-1;
                glbLenhLe=FunVaoLenh(OP_SELL,Bid,0,inpBuocNhay,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                glbTapLenh[glbTongSoLenh]=FunVaoLenh(OP_BUY,Ask,0,0,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                glbTongSoLenh++;
                glbLoaiLenhCuatTapLenh=OP_BUY;
                FunCapNhatDiemTPSL(glbLoaiLenhCuatTapLenh,inpLoiNhuanMongMuon);
                return;
            }
         }
      }
      if(glbLenhLe>0)
      {
         if(OrderSelect(glbLenhLe,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)
            {
               if(OrderProfit()>0)
               {
                  if(glbLoaiLenhCuatTapLenh==OP_SELL)
                  {
                     glbLenhLe=FunVaoLenh(OP_BUY,Ask,0,inpBuocNhay,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                     glbTapLenh[glbTongSoLenh]=FunVaoLenh(OP_SELL,Bid,0,0,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                     glbTongSoLenh++;
                     FunCapNhatDiemTPSL(glbLoaiLenhCuatTapLenh,inpLoiNhuanMongMuon);
                  }
                  else   
                  {
                     glbLenhLe=FunVaoLenh(OP_SELL,Bid,0,inpBuocNhay,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                      glbTapLenh[glbTongSoLenh]=FunVaoLenh(OP_BUY,Ask,0,0,inpKhoiLuongBanDau*MathPow(inpHeSoNhanKhoiLuong,glbTongSoLenh));
                      glbTongSoLenh++;
                     FunCapNhatDiemTPSL(glbLoaiLenhCuatTapLenh,inpLoiNhuanMongMuon);
                  }               
               }
               else 
               {
                  // Dong tat ca cac lenh
                  FunDongTatCaCacLenh();
                  glbLenhLe=-1;
               }
            }
         }
      }
      FunKiemTraXoaLenhKhoiMang();
  }
//+------------------------------------------------------------------+
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

int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagic,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagic,0,clrRed);
    }
    return Ticket;
}

//+------------------------------------------------------------------+
void FunCapNhatDiemTPSL(int LoaiLenh,double LoiNhuanCanDatDuocTP=-1)
{
   double DiemDongTatCaCacLenhTP=0;;
   double TongComVaSwap=0;
   double TongTheoGia=0;
   double TongKhoiLuong=0;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(LoaiLenh==OP_BUY)
   {
      for(int i=0;i<glbTongSoLenh;i++)
      {
         OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      OrderSelect(glbLenhLe,SELECT_BY_TICKET,MODE_TRADES);//Lenh sell doi nguoc
      TongComVaSwap+=OrderCommission()+OrderSwap();
      TongTheoGia-=OrderOpenPrice()*OrderLots();
      TongKhoiLuong-=OrderLots();
      
      DiemDongTatCaCacLenhTP=(((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue)+TongTheoGia)/TongKhoiLuong;
      Print("SL:",0,"  TP:",DiemDongTatCaCacLenhTP);
      if(DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongSoLenh;i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),DiemDongTatCaCacLenhTP,0,clrNONE);
           // OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,OrderTakeProfit(),0,clrNONE);
         }
         OrderSelect(glbLenhLe,SELECT_BY_TICKET,MODE_TRADES);
         OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhTP,OrderTakeProfit(),0,clrNONE);
      }
      
   }
   else
   {
    //   Print("Tong lenh sell:",glbTongLenhSell," Loi nhuan can dat duoc:",LoiNhuanCanDatDuoc);
      for(int i=0;i<glbTongSoLenh;i++)
      {
         OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      OrderSelect(glbLenhLe,SELECT_BY_TICKET,MODE_TRADES);//Lenh buy doi nguoc
      TongComVaSwap+=OrderCommission()+OrderSwap();
      TongTheoGia-=OrderOpenPrice()*OrderLots();
      TongKhoiLuong-=OrderLots();
      
       DiemDongTatCaCacLenhTP=(TongTheoGia-((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue))/TongKhoiLuong;;
      Print("SL:",0,"  TP:",DiemDongTatCaCacLenhTP);
      if(DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongSoLenh;i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),DiemDongTatCaCacLenhTP,0,clrNONE);
            //OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,OrderTakeProfit(),0,clrNONE);
         }
         OrderSelect(glbLenhLe,SELECT_BY_TICKET,MODE_TRADES);
         OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhTP,OrderTakeProfit(),0,clrNONE);
      }
      
   }
}

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
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");  
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
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
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--; 
              }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
           FunDongTatCaCacLenh();
           // DOng lenh  le
           if(OrderSelect(glbLenhLe,SELECT_BY_TICKET))
            {
               if(OrderCloseTime()>0)
               {
                  //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
                  glbLenhLe=-1;
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
                     {  glbLenhLe=-1;
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
                       glbLenhLe=-1;
                    }
                  }
               }
            }
           return;
         }
      }
      
      
   }
}