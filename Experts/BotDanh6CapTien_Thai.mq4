//+------------------------------------------------------------------+
//|                                         BotDanh6CapTien_Thai.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
enum ENM_LOAI_LENH{
   ENM_CUNG_CHIEU_XAUUSD,// Cung chieu 
   ENM_NGUOC_CHIEU_XAUUSD,//Nguoc chieu
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
struct StrCapTien{
   string TenCapTien;
   double HeSoVaoLenh;
   ENM_LOAI_LENH LoaiLenh;
};
NgayThang glbNgayHetHan={20,02,2023};
input double inpKhoiLuong=0.01;
input double inpTongTienLoToiDa=50;//Tong tien lo cho phep ($)(=0: Khong xet)
input bool inpChoPhepDongBotKhiCatLo=false;// CHo phep dong bot khi cat lo (true: cho phep):
input double inpTongTienLaiChoPhep=50;//Tong tien LAI toi da ($)(=0: Khong xet)
input string str="THAM SO EMA:";//CAI DAT THAM SO EMA
input int inpMALow=12;// MA ngan:
input int inpMALong=36; //MA dai:
input ENUM_MA_METHOD inpMAMethod=MODE_EMA;//MA method:
input ENUM_APPLIED_PRICE inpAppliedPrice=PRICE_CLOSE;// Gia tinh EMA:
input string str_1="THONG SO CAP TIEN SO 1";//CAI DAT THONG SO CHO CAP TIEN SO 1
input string inpTenCapTien_1="EURUSD";// Ten cap tien:
input bool inpChoPhepVaoLenh_1=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_1=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_1=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_2="THONG SO CAP TIEN SO 2";//CAI DAT THONG SO CHO CAP TIEN SO 2
input string inpTenCapTien_2="GBPUSD";// Ten cap tien:
input bool inpChoPhepVaoLenh_2=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_2=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_2=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_3="THONG SO CAP TIEN SO 3";//CAI DAT THONG SO CHO CAP TIEN SO 3
input string inpTenCapTien_3="AUDUSD";// Ten cap tien:
input bool inpChoPhepVaoLenh_3=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_3=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_3=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_4="THONG SO CAP TIEN SO 4";//CAI DAT THONG SO CHO CAP TIEN SO 4
input string inpTenCapTien_4="NZDUSD";// Ten cap tien:
input bool inpChoPhepVaoLenh_4=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_4=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_4=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_5="THONG SO CAP TIEN SO 5";//CAI DAT THONG SO CHO CAP TIEN SO 5
input string inpTenCapTien_5="USDJPY";// Ten cap tien:
input bool inpChoPhepVaoLenh_5=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_5=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_5=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input string str_6="THONG SO CAP TIEN SO 6";//CAI DAT THONG SO CHO CAP TIEN SO 6
input string inpTenCapTien_6="USDCHF";// Ten cap tien:
input bool inpChoPhepVaoLenh_6=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_6=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_6=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input string str_7="THONG SO CAP TIEN SO 7";//CAI DAT THONG SO CHO CAP TIEN SO 7
input string inpTenCapTien_7="USDCAD";// Ten cap tien:
input bool inpChoPhepVaoLenh_7=true;// Cho phep vao lenh:
input double inpHeSoVaoLenh_7=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_7=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input int inpMagicNumber=12345;// Magic number:
input int inpSlippage=50;//Slippage:
string glbMessages="";
int glbSlippage=50;
int glbMagic=12345;
double glbSoLotCoban=0;
int glbTongSoLenh=0;
int glbTapLenh[200];
int glbTongSoCapTienDuocVaoLenh=0;
StrCapTien glbTapCacCapTien[10];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   glbMagic=inpMagicNumber;
   glbSlippage=inpSlippage;
   glbSoLotCoban=inpKhoiLuong;
   glbTongSoCapTienDuocVaoLenh=0;
   if(FunKiemTraHetHan(glbNgayHetHan)==false)
      return INIT_FAILED;
   if(inpChoPhepVaoLenh_1==true && inpTenCapTien_1!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_1;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_1;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_1;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_2==true && inpTenCapTien_2!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_2;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_2;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_2;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_3==true && inpTenCapTien_3!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_3;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_3;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_3;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_4==true && inpTenCapTien_4!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_4;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_4;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_4;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_5==true && inpTenCapTien_5!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_5;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_5;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_5;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_6==true && inpTenCapTien_6!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_6;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_6;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_6;
      glbTongSoCapTienDuocVaoLenh++;
   }
   if(inpChoPhepVaoLenh_7==true && inpTenCapTien_7!=Symbol())
   {
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].TenCapTien=inpTenCapTien_7;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].HeSoVaoLenh=inpHeSoVaoLenh_7;
      glbTapCacCapTien[glbTongSoCapTienDuocVaoLenh].LoaiLenh=inpLoaiLenh_7;
      glbTongSoCapTienDuocVaoLenh++;
   }
//---
   if(glbTongSoLenh==0)
   {
      FunTimCacLenhDeQuanLy();
   }
   EventSetTimer(1);// SAu 2 giay xu ly 1 lan
   OnTimer();
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
      Comment("DOI GIAO CAT MA");
      
      if(FunKiemTraSangNenMoiChua()==true)
      {
         if(glbTongSoLenh==0)
         {          
            int KiemTra=-2;
            KiemTra=FunKiemTraGiaoCatMA();
            if(KiemTra==0) 
            {
               Comment("DOI GIAO CAT MA");
               return;
            }
            if(KiemTra==-1)// Vao lenh sell
            {
               FunVaoLenhSell();
               return;
            }
            if(KiemTra==1)
            {
               FunVaoLenhBuy();
               return;
            }
         }
      }
      
      if(glbTongSoLenh==0)
      {
         FunNhanDienLenhTayLamLenhDauTien();
      }
      
      if(glbTongSoLenh>0)
      {
         double LoiNhuanTamThoi=FunTinhTongLoiNhuanCacLenh();
         if(LoiNhuanTamThoi>=inpTongTienLaiChoPhep && inpTongTienLaiChoPhep>0)
         {
            Print("DONG TAT CAC CAC LENH DO DAT DU LOI NHUAN");
            FunDongTatCaCacLenh();
         }
         if(LoiNhuanTamThoi<0 && MathAbs(LoiNhuanTamThoi)>=inpTongTienLoToiDa && inpTongTienLoToiDa>0)
         {
            Print("DONG TAT CAC CAC LENH DO DAT LO TOI DA CHO PHEP");
            FunDongTatCaCacLenh();
            if(inpChoPhepDongBotKhiCatLo==true)
               ExpertRemove();
         }
         FunKiemTraDongLenhBangTay();      
         Comment("Tong lenh dang quan ly: ", glbTongSoLenh,"\nTong loi nhuan tam thoi: ",LoiNhuanTamThoi); 
      }
  }
 //+------------------------------------------------------------------+
 
void OnTimer()
{
   
   if(glbTongSoLenh==0)
   {
         FunNhanDienLenhTayLamLenhDauTien();
   }
   
   
   FunKiemTraDongLenhBangTay();    
}
 //+------------------------------------------------------------------+
double FunTinhTongLoiNhuanCacLenh()
{
   double TongLoiNhuan=0;
   for(int i=0;i<glbTongSoLenh; i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         TongLoiNhuan+=OrderProfit()+OrderSwap()+OrderCommission();
      }
   }
  return NormalizeDouble(TongLoiNhuan,2); 
}
//+------------------------------------------------------------------+
void FunNhanDienLenhTayLamLenhDauTien()
{
   double ticket=-1;
   for(int i=OrdersTotal()-1;i>=0;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()<=1 && OrderSymbol()==Symbol() && OrderMagicNumber()==0)
         {
            Print("Magic number:",OrderMagicNumber());
            glbTapLenh[glbTongSoLenh]=OrderTicket();
            glbSoLotCoban=OrderLots();
            glbTongSoLenh++;
            if(OrderType()==0)
               FunVaoCacLenhDoiUngCuaCacCapTien(OP_BUY);
            else FunVaoCacLenhDoiUngCuaCacCapTien(OP_SELL);
            return;
         }
      }
   }
}
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongSoLenh;i++)
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
void FunVaoLenhSell()
{
   int ticket=FunVaoLenh(Symbol(),OP_SELL,Bid,0,0,inpKhoiLuong);
   double KhoiLuongVaoLenh=0;
   if(ticket>0)
   {
      glbTapLenh[glbTongSoLenh]=ticket;
      glbTongSoLenh++;
      FunVaoCacLenhDoiUngCuaCacCapTien(OP_SELL);
   }  
} 

//+------------------------------------------------------------------+
void FunVaoLenhBuy()
{
   int ticket=FunVaoLenh(Symbol(),OP_BUY,Ask,0,0,inpKhoiLuong);
   if(ticket>0)
   {
      glbTapLenh[glbTongSoLenh]=ticket;
      glbTongSoLenh++;
       FunVaoCacLenhDoiUngCuaCacCapTien(OP_BUY);
   }  
}

void FunVaoCacLenhDoiUngCuaCacCapTien(ENUM_ORDER_TYPE LoaiLenh)
{
   double ticket=-1;
   if(LoaiLenh==OP_BUY)
   {
      for(int i=0;i<glbTongSoCapTienDuocVaoLenh;i++)
      {
         ticket=-1;
         string CapTien=glbTapCacCapTien[i].TenCapTien;
         double KhoiLuongLenh=NormalizeDouble(glbSoLotCoban*glbTapCacCapTien[i].HeSoVaoLenh,FunTinhLotDecimal(glbTapCacCapTien[i].TenCapTien));
         ENUM_ORDER_TYPE LoaiLenhVao;
         double GiaVaoLenh=0;
         if(glbTapCacCapTien[i].LoaiLenh==ENM_CUNG_CHIEU_XAUUSD) 
         {
            LoaiLenhVao=OP_BUY;
            GiaVaoLenh=MarketInfo(CapTien,MODE_ASK);
         }
         else
         {
            LoaiLenhVao=OP_SELL;
            GiaVaoLenh=MarketInfo(CapTien,MODE_BID);
         }
         ticket=FunVaoLenh(CapTien,LoaiLenhVao,GiaVaoLenh,0,0,KhoiLuongLenh);
         if(ticket>0)
         {
             glbTapLenh[glbTongSoLenh]=ticket;
             glbTongSoLenh++;
         }
      }
   }
   else if(LoaiLenh==OP_SELL)
   {
      for(int i=0;i<glbTongSoCapTienDuocVaoLenh;i++)
      {
         ticket=-1;
         string CapTien=glbTapCacCapTien[i].TenCapTien;
         double KhoiLuongLenh=NormalizeDouble(glbSoLotCoban*glbTapCacCapTien[i].HeSoVaoLenh,FunTinhLotDecimal(glbTapCacCapTien[i].TenCapTien));
         ENUM_ORDER_TYPE LoaiLenhVao;
         double GiaVaoLenh=0;
         if(glbTapCacCapTien[i].LoaiLenh==ENM_CUNG_CHIEU_XAUUSD) 
         {
            LoaiLenhVao=OP_SELL;
            GiaVaoLenh=MarketInfo(CapTien,MODE_BID);
         }
         else
         {
            LoaiLenhVao=OP_BUY;
            GiaVaoLenh=MarketInfo(CapTien,MODE_ASK);
         }
         ticket=FunVaoLenh(CapTien,LoaiLenhVao,GiaVaoLenh,0,0,KhoiLuongLenh);
         if(ticket>0)
         {
             glbTapLenh[glbTongSoLenh]=ticket;
             glbTongSoLenh++;
         }
      }
   }
}
//+------------------------------------------------------------------+
int FunTinhLotDecimal(string CapTien)
{
   double lot_step=MarketInfo(CapTien,MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
 //+------------------------------------------------------------------+
void FunTimCacLenhDeQuanLy()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()==inpMagicNumber)
         {
            glbTapLenh[glbTongSoLenh]=OrderTicket();
            glbTongSoLenh++;
         }
      }
   }
}
//+------------------------------------------------------------------+
int FunKiemTraGiaoCatMA()//-1: Tin hieu sell, 0: Khong co tin hieu; 1: Tin hieu buy
{
   /*
   double MAlow1=FunTinhGiaTriMA(inpMALow,1);
   double MAlow2=FunTinhGiaTriMA(inpMALow,2);
   double MAhigh1=FunTinhGiaTriMA(inpMALong,1);
   double MAhigh2=FunTinhGiaTriMA(inpMALong,2);
   if(MAlow1>MAhigh1 && MAlow2<MAhigh2) return 1;
   if(MAlow1<MAhigh1 && MAlow2>MAhigh2) return -1;
   */
   if(Open[1]<Close[1]) return 1;
   if(Open[1]>Close[1]) return -1;
   return 0;
}

double FunTinhGiaTriMA(int MAPeriod,int shift)
{
   return iMA(Symbol(),0,MAPeriod,0,inpMAMethod,inpAppliedPrice,shift);
}
  
//+------------------------------------------------------------------+
int FunVaoLenh(string CapTien,int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(CapTien,LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(CapTien,LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
bool FunKiemTraHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
{
   bool kt=true;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;
    }
    return kt;
}
//+------------------------------------------------------------------+

 bool FunKiemTraSangNenMoiChua()
 {
   static datetime _LastBar=Time[0];;
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   datetime currBar=Time[0];//iTime(OrderSymbol(),0,0);
   if(_LastBar!=currBar)
   {
      _LastBar=currBar;
      return true;
   }
   else return false;
 }

void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),inpSlippage,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");  
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),inpSlippage,clrRed))
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

