//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Bot FX | Chuyen code bot fx | SDT: 0971.926.248"
#property link      "tailieuforex.com"
#property version   "1.00"
#property strict

enum ENM_KIEU_LENH_DAU_TIEN{
    ENM_THU_CONG,// THU CONG
    ENM_THEO_MA,//THEO DUONG MA
};
struct  str_Lenh_Da_Vao
{
    int _Ticket;
    double _DiemVaoLenh;
    double _KhoiLuong;
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
input ENM_KIEU_LENH_DAU_TIEN inpKieuVaoLenh=ENM_THU_CONG;// Kieu vao lenh ban dau:
input double inpKhoiLuongCoSo=0.01;// Khoi luong:
input int inpDiemTPLenhDau=20;// Diem TP lenh dau tien (pips):
input int inpKhoangNhayGia=5;// Khoang nhay gia TP (pips):
input int inpKhoangCachNhoiLenh=50;//Khoang cach nhoi lenh (pips):
input int inpSlippage=50;// Do truot gia (slippage -points):
input int inpMagicNumber=123;

input string str="THAM SO MA";//CAI DAT VAO LENH THEO MA    
input int inpMAPeriod = 50;//MA period:
input ENUM_MA_METHOD inpMAMethod = MODE_EMA;//MA Method :
input ENUM_APPLIED_PRICE inpAppliedPrice=PRICE_CLOSE;// MA Applied Price: 
input ENUM_TIMEFRAMES inpMATimeFrame=PERIOD_CURRENT;// MA Time frame:
input string inpCommentLenhBuy="Vao lenh Buy";//Comment lenh Buy:
input string inpCommentLenhSell="Vao lenh Sell";//Comment lenh Sell:

NgayThang NgayHetHan={10,09,2023};
int glbTongLenh=0;
str_Lenh_Da_Vao glbTapLenh[200];
int glbLoaiLenhDangMartingel;
int glbLenhDanXen=-1;
str_Lenh_Da_Vao glbStrLenhMacDinh={-1,0,0};
double glbKhoiLuongCoSo=0;
double glbMyPoint;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  glbMyPoint=10*Point();
  if(StringFind(Symbol(),"XAU",0)>=0 && Digits()==3)
   glbMyPoint=100*Point();
   /*if (glbTongLenh<=0)
   {
     FunKhoiTaoLenhChoBot();
   }
   */
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
    string StrOutput="Tong lenh da vao: " + IntegerToString(glbTongLenh);
    for(int i=0;i<glbTongLenh;i++)
    {
        StrOutput+="\nTicket: "+IntegerToString(glbTapLenh[i]._Ticket);

    }
    StrOutput+="\nLenh vao dan xen: "+IntegerToString(glbLenhDanXen);
    Comment(StrOutput);
    if(FunKiemTraSangNenMoiChua())
    {
        if(glbTongLenh==0 && inpKieuVaoLenh==ENM_THEO_MA)
        {
            FunLenhDauTien();
            return;
        }
    }
    if(glbTongLenh==0)
    {
        if(glbLenhDanXen>0)
        {
            // Bien lenh dan xen thanfh lenh dau tien
            if(OrderSelect(glbLenhDanXen,SELECT_BY_TICKET,MODE_TRADES))
            {
                if(OrderCloseTime()<=0)// Lenh dang co
                {
                    glbTapLenh[glbTongLenh]._Ticket=OrderTicket();
                    glbTapLenh[glbTongLenh]._DiemVaoLenh=OrderOpenPrice();
                    glbTapLenh[glbTongLenh]._KhoiLuong=OrderLots();
                    glbLoaiLenhDangMartingel=OrderType();
                    glbKhoiLuongCoSo=OrderLots();
                    glbTongLenh=1;
                    glbLenhDanXen=-1;
                    return;
                }

            }
        }
        else if(inpKieuVaoLenh!=ENM_THEO_MA)
            FunLenhDauTien();
    }
    else
    {
        FunKiemTraVaoLenhHedge();
        FunKiemTraDongLenhBangTay();  
        // Vao lai lenh dan xen
        if(glbLenhDanXen>0)// dang co lenh dan xen
        {
            if(OrderSelect(glbLenhDanXen,SELECT_BY_TICKET,MODE_TRADES))
            {
                if(OrderCloseTime()>0)// Lenh da  dong lenh
                {
                   glbLenhDanXen=-1;
                }

            }
        }
        else
        {
            if(glbTongLenh<2) return;
            double DiemGiaVaoLenhDanXen=0;
            if(glbTongLenh%2==0) DiemGiaVaoLenhDanXen=glbTapLenh[glbTongLenh-1]._DiemVaoLenh;
            else DiemGiaVaoLenhDanXen=glbTapLenh[glbTongLenh-2]._DiemVaoLenh;
            if(Bid>=(DiemGiaVaoLenhDanXen-glbMyPoint)&& Bid<=(DiemGiaVaoLenhDanXen+glbMyPoint))
            {
                if(glbLoaiLenhDangMartingel==OP_BUY)
                    glbLenhDanXen=FunVaoLenh(OP_SELL,Bid,0,inpDiemTPLenhDau,glbKhoiLuongCoSo);
                else glbLenhDanXen=FunVaoLenh(OP_BUY,Ask,0,inpDiemTPLenhDau,glbKhoiLuongCoSo);
            }
        }
    }

}
//+------------------------------------------------------------------+
void FunKhoiTaoLenhChoBot()
{
    glbTongLenh=0;
    glbLenhDanXen=-1;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSymbol()==Symbol()&& OrderType()<=1)
        {
            glbTapLenh[glbTongLenh]._Ticket=OrderTicket();
            glbTapLenh[glbTongLenh]._DiemVaoLenh=OrderOpenPrice();
            glbTapLenh[glbTongLenh]._KhoiLuong=OrderLots();
            glbKhoiLuongCoSo=OrderLots();
            glbTongLenh++;
            glbLoaiLenhDangMartingel=OrderType();
        }
    }
    
}
//+------------------------------------------------------------------+
void FunKiemTraVaoLenhHedge()
{
    if(glbLoaiLenhDangMartingel==OP_BUY)
    {
        double SoPipLoiLo=(Ask-glbTapLenh[glbTongLenh-1]._DiemVaoLenh)/glbMyPoint;
        if(SoPipLoiLo<0 && MathAbs(SoPipLoiLo)>inpKhoangCachNhoiLenh)
        {
            // Vao lenh nhoi
            double KhoiLuongLenhNhoi=FunTinhKhoiLuongLenhNhoi();
            double DiemVaoLenh=Ask;
            double SoPipTP=inpDiemTPLenhDau+glbTongLenh*inpKhoangNhayGia;
            double DiemGiaTPMoi=Ask+SoPipTP*glbMyPoint+MarketInfo(Symbol(),MODE_SPREAD)*Point();
            DiemGiaTPMoi=NormalizeDouble(DiemGiaTPMoi,Digits());
            int ticket=FunVaoLenh(OP_BUY,DiemVaoLenh,0,0,KhoiLuongLenhNhoi);
            if (ticket>0)
            {
                glbTapLenh[glbTongLenh]._Ticket=ticket;
                glbTapLenh[glbTongLenh]._DiemVaoLenh=DiemVaoLenh;
                glbTapLenh[glbTongLenh]._KhoiLuong=KhoiLuongLenhNhoi;
                glbTongLenh++;
                FunCapNhatTPTheoGia(DiemGiaTPMoi);
                if(glbTongLenh%2==0 && glbLenhDanXen==-1)
                    glbLenhDanXen=FunVaoLenh(OP_SELL,Bid,0,inpDiemTPLenhDau,glbKhoiLuongCoSo);
            }
            
        }
    }
    else
    {
        double SoPipLoiLo=(glbTapLenh[glbTongLenh-1]._DiemVaoLenh-Bid)/glbMyPoint;
        if(SoPipLoiLo<0 && MathAbs(SoPipLoiLo)>inpKhoangCachNhoiLenh)
        {
            // Vao lenh nhoi
            double KhoiLuongLenhNhoi=FunTinhKhoiLuongLenhNhoi();
            double DiemVaoLenh=Bid;
            double SoPipTP=inpDiemTPLenhDau+glbTongLenh*inpKhoangNhayGia;
            double DiemGiaTPMoi=Bid-SoPipTP*glbMyPoint-MarketInfo(Symbol(),MODE_SPREAD)*Point();
            DiemGiaTPMoi=NormalizeDouble(DiemGiaTPMoi,Digits());
            int ticket=FunVaoLenh(OP_SELL,DiemVaoLenh,0,0,KhoiLuongLenhNhoi);
            if (ticket>0)
            {
                glbTapLenh[glbTongLenh]._Ticket=ticket;
                glbTapLenh[glbTongLenh]._DiemVaoLenh=DiemVaoLenh;
                glbTapLenh[glbTongLenh]._KhoiLuong=KhoiLuongLenhNhoi;
                glbTongLenh++;
                FunCapNhatTPTheoGia(DiemGiaTPMoi);
                if(glbTongLenh%2==0 && glbLenhDanXen==-1)
                    glbLenhDanXen=FunVaoLenh(OP_BUY,Ask,0,inpDiemTPLenhDau,glbKhoiLuongCoSo);
            }
            
        }

    }

    return;
}
//+------------------------------------------------------------------+
double FunTinhKhoiLuongLenhNhoi()
{
    if(glbTongLenh==0) return inpKhoiLuongCoSo;
    else if(glbTongLenh==1) return 2*glbTapLenh[glbTongLenh-1]._KhoiLuong;
    else return glbTapLenh[glbTongLenh-1]._KhoiLuong+ glbTapLenh[glbTongLenh-2]._KhoiLuong;
}

//+------------------------------------------------------------------+
void FunCapNhatTPTheoGia(double GiaTP)
{
    for (int i = 0; i < glbTongLenh; i++)
    {
        if(OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET))
        {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),GiaTP,0,clrNONE))
                Print("Loi Dich diem TP. Gia dich TP: ",GiaTP, " Ticket:",OrderTicket());
        }
    }
    
}
//+------------------------------------------------------------------+
void FunLenhDauTien()
{
    if(inpKieuVaoLenh==ENM_THU_CONG)
    {
        for(int i=0;i<OrdersTotal();i++)
        {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            {
                if(OrderSymbol()==Symbol())
                {
                    glbTapLenh[glbTongLenh]._Ticket=OrderTicket();
                    glbTapLenh[glbTongLenh]._DiemVaoLenh=OrderOpenPrice();
                    glbTapLenh[glbTongLenh]._KhoiLuong=OrderLots();
                    glbKhoiLuongCoSo=OrderLots();
                    glbTongLenh=1;
                    glbLoaiLenhDangMartingel=OrderType();
                }
            }
        }
    }
    else
    {
        int DieuKienVaoLenhTheoMA=FunKiemTraDieuKienVaoLenhTheoMA();
        if(DieuKienVaoLenhTheoMA==0)
        {
            int ticket=FunVaoLenh(OP_BUY,Ask,0,inpDiemTPLenhDau,inpKhoiLuongCoSo);
            if(ticket>0)
            {
                glbTapLenh[glbTongLenh]._Ticket=ticket;
                glbTapLenh[glbTongLenh]._DiemVaoLenh=Ask;
                glbTapLenh[glbTongLenh]._KhoiLuong=inpKhoiLuongCoSo;
                glbKhoiLuongCoSo=inpKhoiLuongCoSo;
                glbTongLenh++;
                glbLoaiLenhDangMartingel=OP_BUY;
            }
        }
        else if (DieuKienVaoLenhTheoMA==1)
        {
            int ticket=FunVaoLenh(OP_SELL,Bid,0,inpDiemTPLenhDau,inpKhoiLuongCoSo);
            if(ticket>0)
            {
                glbTapLenh[glbTongLenh]._Ticket=ticket;
                glbTapLenh[glbTongLenh]._DiemVaoLenh=Bid;
                glbTapLenh[glbTongLenh]._KhoiLuong=inpKhoiLuongCoSo;
                glbKhoiLuongCoSo=inpKhoiLuongCoSo;
                glbTongLenh++;
                glbLoaiLenhDangMartingel=OP_SELL;
            }
        }
        
    }

}

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
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET))
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
      if(OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET))
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

void FunDongTatCaCacLenh()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1]._Ticket,SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongLenh-1]=glbStrLenhMacDinh;
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
               {  glbTapLenh[glbTongLenh-1]=glbStrLenhMacDinh;glbTongLenh--;
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
                  glbTapLenh[glbTongLenh-1]=glbStrLenhMacDinh;glbTongLenh--;
              }
            }
         }
      }
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
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*glbMyPoint;
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*glbMyPoint;  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentLenhBuy,inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*glbMyPoint;
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*glbMyPoint;  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentLenhSell,inpMagicNumber,0,clrRed);
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

//+------------------------------------------------------------------+
int  FunKiemTraDieuKienVaoLenhTheoMA() //-1: Khong vao, ): BUY, 1:Sell
{
    double MAVAlue1=iMA(Symbol(),inpMATimeFrame,inpMAPeriod,0,inpMAMethod,inpAppliedPrice,1);
    double MAVAlue2=iMA(Symbol(),inpMATimeFrame,inpMAPeriod,0,inpMAMethod,inpAppliedPrice,2);
    if(Close[1]<MAVAlue1 && Close[2]>MAVAlue2 && Open[2]>MAVAlue2) return 0;
    if(Close[1]>MAVAlue1 && Close[2]<MAVAlue2 && Open[2]<MAVAlue2) return 1;
    return -1;
}