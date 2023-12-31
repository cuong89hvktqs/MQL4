//+------------------------------------------------------------------+
//|                                         BotDanh6CapTien_Thai.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property  indicator_chart_window
#include <Controls/Panel.mqh>
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
NgayThang glbNgayHetHan={30,02,3023};
input double inpKhoiLuong=0.01;
input double inpTongTienLoToiDa=50;//Tong tien lo cho phep ($)(=0: Khong xet)
input bool inpChoPhepDongBotKhiCatLo=false;// Cho phep dong bot khi cat lo (true: cho phep):
input double inpTongTienLaiChoPhep=50;//Tong tien LAI toi da ($)(=0: Khong xet)
input string strThogSo="THONG SO NHOI LENH";//CAI DAT THONG SO NHOI LENH
input double inpSoTienAmNhoiLenh=6;//So tien am bat dau nhoi lenh ($):
input double inpHeSoNhoiAmTien=1;//He so cong lenh am tien:
input double inpHeSoNhoiKhoiLuong=1;//He so nhan nhoi lenh am tien:
input double inpStartTime=8;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=22;// Thoi Gian Ket Thuc vao lenh(Server time):
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
input bool inpChoPhepVaoLenh_3=false;// Cho phep vao lenh:
input double inpHeSoVaoLenh_3=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_3=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_4="THONG SO CAP TIEN SO 4";//CAI DAT THONG SO CHO CAP TIEN SO 4
input string inpTenCapTien_4="NZDUSD";// Ten cap tien:
input bool inpChoPhepVaoLenh_4=false;// Cho phep vao lenh:
input double inpHeSoVaoLenh_4=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_4=ENM_CUNG_CHIEU_XAUUSD;// Loai lenh vao:

input string str_5="THONG SO CAP TIEN SO 5";//CAI DAT THONG SO CHO CAP TIEN SO 5
input string inpTenCapTien_5="USDJPY";// Ten cap tien:
input bool inpChoPhepVaoLenh_5=false;// Cho phep vao lenh:
input double inpHeSoVaoLenh_5=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_5=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input string str_6="THONG SO CAP TIEN SO 6";//CAI DAT THONG SO CHO CAP TIEN SO 6
input string inpTenCapTien_6="USDCHF";// Ten cap tien:
input bool inpChoPhepVaoLenh_6=false;// Cho phep vao lenh:
input double inpHeSoVaoLenh_6=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_6=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input string str_7="THONG SO CAP TIEN SO 7";//CAI DAT THONG SO CHO CAP TIEN SO 7
input string inpTenCapTien_7="USDCAD";// Ten cap tien:
input bool inpChoPhepVaoLenh_7=false;// Cho phep vao lenh:
input double inpHeSoVaoLenh_7=2;//He so vao lenh:
input ENM_LOAI_LENH inpLoaiLenh_7=ENM_NGUOC_CHIEU_XAUUSD;// Loai lenh vao:

input int inpMagicNumber=12345;// Magic number:
input int inpSlippage=50;//Slippage:

string glbMessages="";
int glbSlippage=50;
int glbMagic=12345;
double glbSoLotCoban=inpKhoiLuong;
int glbLoaiLenhDangVao;
int glbTongSoLenh=0;
int glbTapLenh[200];
int glbTongSoCapTienDuocVaoLenh=0;
int glbSoLanNhoiLenh=0;// Chua nhoi lenh, neu dong 1 bo lenh thi So lan nhoi lenh se giam di
int glbTongSoLanDaVaoBoLenh=0;
double glbTongLoChoPhepTruocKhiNhoiLenh=inpSoTienAmNhoiLenh;
StrCapTien glbTapCacCapTien[10];
CPanel myPanel;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   glbMagic=inpMagicNumber;
   glbSlippage=inpSlippage;
   glbTongSoCapTienDuocVaoLenh=1;// Ban dau chi co GOLD
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
   FunKiemTraSangNenMoiChua();
   
   myPanel.Create(0,"Bang",0,0,70,150,235);
   myPanel.ColorBackground(clrDarkSlateGray);
   FunLabelCreate(0,"LableRisk",0,10,75,0,"ORDER MANAGEMENT","Arial",9,clrYellow);
      
   FunLabelCreate(0,"lblBoLenh",0,10,95,0,"BO LENH CAN DONG:","Arial",9,clrRed,0);
   
   FunEditCreate(0,"edtBoLenh",0,4,115,50,30,IntegerToString(5),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
   FunButtonCreate(0,"btnDongBoLenh",0,60,115,85,30,CORNER_LEFT_UPPER,"BO LENH","Arial",9,clrBlue,clrPink);
   
   FunButtonCreate(0,"btnDongToanBo",0,4,150,140,30,CORNER_LEFT_UPPER,"CLOSE ALL ORDERS","Arial",9,clrYellow,clrBlue);
   FunLabelCreate(0,"lblSetText",0,4,185,0,"SET: ","Arial",9,clrWhite);
   FunLabelCreate(0,"lblSetValue",0,35,185,0,"0","Arial",9,clrWhite);
   FunLabelCreate(0,"lblLoiNhuan",0,4,200,0,"Loi nhuan: ","Arial",9,clrWhite);
   FunLabelCreate(0,"lblLoiNhuanValue",0,70,200,0,"0","Arial",9,clrWhite);
   FunLabelCreate(0,"lblLossTiepTheo",0,4,215,0,"Loss lenh tiep:","Arial",9,clrWhite);
   FunLabelCreate(0,"lblLossTiepTheoValue",0,90,215,0,"0","Arial",9,clrWhite);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
     ObjectsDeleteAll(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(FunKiemTraGioVaoLenh()==false)
      {
         if(glbTongSoLenh<=0)
         {
            Comment("Chua den gio vao lenh");
            return;
         }
      }
      if(FunKiemTraSangNenMoiChua()==true)
      {
         if(glbTongSoLenh==0)
         {          
            int KiemTra=-2;
            KiemTra=FunKiemTraGiaoCatMA();
            Print("Kiem Tra=",KiemTra);
            if(KiemTra==0) 
            {
               Comment("DOI LENH");
               return;
            }
            if(KiemTra==-1)// Vao lenh sell
            {
               
               glbSoLotCoban=inpKhoiLuong;
               glbSoLanNhoiLenh=1;
               glbTongSoLanDaVaoBoLenh=1;
               FunVaoLenhSell();
               
               glbTongLoChoPhepTruocKhiNhoiLenh=inpSoTienAmNhoiLenh;
               return;
            }
            if(KiemTra==1)
            {
               glbSoLotCoban=inpKhoiLuong;
               glbSoLanNhoiLenh=1;
               glbTongSoLanDaVaoBoLenh=1;
               FunVaoLenhBuy();
               
               glbTongLoChoPhepTruocKhiNhoiLenh=inpSoTienAmNhoiLenh;
               return;
            }
         }
      }
      /*
      if(glbTongSoLenh==0)
      {
        // Print("NHANH LENH THEO TAY");
         FunNhanDienLenhTayLamLenhDauTien();
      }
      */
      if(glbTongSoLenh>0)
      {
         double LoiNhuanTamThoi=FunTinhTongLoiNhuanCacLenh();
       //   Print("Tong lenh: ",glbTongSoLenh);
         if(LoiNhuanTamThoi>=inpTongTienLaiChoPhep && inpTongTienLaiChoPhep>0)
         {
            Print("DONG TAT CAC CAC LENH DO DAT DU LOI NHUAN");
            FunDongTatCaCacLenh();
            FunReset();
         }
         if(LoiNhuanTamThoi<0 && MathAbs(LoiNhuanTamThoi)>=inpTongTienLoToiDa && inpTongTienLoToiDa>0)
         {
            Print("DONG TAT CAC CAC LENH DO DAT LO TOI DA CHO PHEP");
            FunDongTatCaCacLenh();
            FunReset();
            if(inpChoPhepDongBotKhiCatLo==true)
               ExpertRemove();
         }
          glbSoLanNhoiLenh=(glbTongSoLenh/glbTongSoCapTienDuocVaoLenh);
          glbTongLoChoPhepTruocKhiNhoiLenh=inpSoTienAmNhoiLenh*FunTinhHeSoNhanTinhTienAmChoPhep(glbSoLanNhoiLenh);     
         if(LoiNhuanTamThoi<0 && MathAbs(LoiNhuanTamThoi)>=glbTongLoChoPhepTruocKhiNhoiLenh)
         {
            glbSoLotCoban=glbSoLotCoban*inpHeSoNhoiKhoiLuong;
            glbSoLotCoban=NormalizeDouble(glbSoLotCoban,FunTinhLotDecimal(Symbol()));
            if(glbLoaiLenhDangVao==OP_BUY)
            {            
               glbTongSoLanDaVaoBoLenh++;
               FunVaoLenhBuy();                      
            }
            else if(glbLoaiLenhDangVao==OP_SELL)
            {
                glbTongSoLanDaVaoBoLenh++;
                FunVaoLenhSell();              
            }       
         } 
          FunKiemTraDongLenhBangTay();  
          FunKiemTraXoaLenhKhoiMang();   
         //Comment("Tong lenh dang quan ly: ", glbTongSoLenh,"\nTong loi nhuan tam thoi: ",LoiNhuanTamThoi, "\nSo lan da vao lenh: ",glbSoLanNhoiLenh, "\nTong lo cho phep truoc khi nhoi lenh: ",glbTongLoChoPhepTruocKhiNhoiLenh, "\nTong lo toi da cho phep: ",inpTongTienLoToiDa); 
         Comment("DANG CO LENH");
         FunLabelCreate(0,"lblSetValue",0,35,185,0,IntegerToString(glbSoLanNhoiLenh),"Arial",9,clrWhite);
         FunLabelCreate(0,"lblLoiNhuanValue",0,70,200,0,DoubleToString(LoiNhuanTamThoi,2),"Arial",9,clrWhite);
         FunLabelCreate(0,"lblLossTiepTheoValue",0,90,215,0,DoubleToString(-glbTongLoChoPhepTruocKhiNhoiLenh,2),"Arial",9,clrWhite);
      }
      else 
      {
         Comment("DOI LENH");
         FunLabelCreate(0,"lblSetValue",0,35,185,0,IntegerToString(0),"Arial",9,clrWhite);
         FunLabelCreate(0,"lblLoiNhuanValue",0,70,200,0,IntegerToString(0),"Arial",9,clrWhite);
         FunLabelCreate(0,"lblLossTiepTheoValue",0,90,215,0,IntegerToString(0),"Arial",9,clrWhite);
      }
  }
 //+------------------------------------------------------------------+
 
void OnTimer()
{
   /*
   if(glbTongSoLenh==0)
   {
         FunNhanDienLenhTayLamLenhDauTien();
   }
   */
   FunKiemTraDongLenhBangTay();    
   
}
 //+------------------------------------------------------------------+
 void FunReset()
 {
   glbSoLanNhoiLenh=0;
   glbTongSoLanDaVaoBoLenh=0;
   glbTongLoChoPhepTruocKhiNhoiLenh=0;
   glbSoLotCoban=inpKhoiLuong;
   glbTongSoLenh=0;
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
            glbTongLoChoPhepTruocKhiNhoiLenh=inpSoTienAmNhoiLenh;
            glbSoLanNhoiLenh++;
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
           // FunDongTatCaCacLenh();
           // FunReset();
           FunDongBoLenhVaoCungThoiDiem(StringToInteger(OrderComment()));
         }
      }
   }
}
//+------------------------------------------------------------------+
void FunVaoLenhSell()
{
   int ticket=FunVaoLenh(Symbol(),OP_SELL,Bid,0,0,glbSoLotCoban);
   glbLoaiLenhDangVao=OP_SELL;
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
   int ticket=FunVaoLenh(Symbol(),OP_BUY,Ask,0,0,glbSoLotCoban);
   glbLoaiLenhDangVao=OP_BUY;
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
   if(glbTongSoLenh>0 )
   {
      if(glbTongSoLenh%glbTongSoCapTienDuocVaoLenh==0)
      {
         OrderSelect(glbTapLenh[0],SELECT_BY_TICKET,MODE_TRADES);
         glbLoaiLenhDangVao=OrderType();
         int SoLanDaNhoiLenh=glbTongSoLenh/glbTongSoCapTienDuocVaoLenh;
         glbSoLanNhoiLenh=SoLanDaNhoiLenh;
         glbSoLotCoban=inpKhoiLuong*SoLanDaNhoiLenh;
         glbTongLoChoPhepTruocKhiNhoiLenh=inpKhoiLuong*FunTinhHeSoNhanTinhTienAmChoPhep(SoLanDaNhoiLenh);
      }
      else
      {
         Alert("BOT KHONG XU LY DUOC CAC LENH DANG VAO");
         ExpertRemove();
      }
   }
   
}
int FunTinhHeSoNhanTinhTienAmChoPhep(int SoLanNhoiLenh)
{
   int tong=0;
   for(int i=0;i<SoLanNhoiLenh;i++)
      tong+=MathPow(inpHeSoNhoiAmTien,i);
   return tong;
}

//+------------------------------------------------------------------+
int FunKiemTraGiaoCatMA()//-1: Tin hieu sell, 0: Khong co tin hieu; 1: Tin hieu buy
{
   return 1;
   /*
   double MAlow1=FunTinhGiaTriMA(inpMALow,1);
   double MAlow2=FunTinhGiaTriMA(inpMALow,2);
   double MAhigh1=FunTinhGiaTriMA(inpMALong,1);
   double MAhigh2=FunTinhGiaTriMA(inpMALong,2);
   if(MAlow1>MAhigh1 && MAlow2<MAhigh2) return 1;
   if(MAlow1<MAhigh1 && MAlow2>MAhigh2) return -1;
   */
   
  // if(Open[1]<Close[1]) return 1;
  // if(Open[1]>Close[1]) return -1;
  // return 0;
      
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
      Ticket=OrderSend(CapTien,LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,IntegerToString(glbTongSoLanDaVaoBoLenh),inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(CapTien,LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,IntegerToString(glbTongSoLanDaVaoBoLenh),inpMagicNumber,0,clrRed);
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
   FunReset();
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: dung gio vao lenh, false: chua den gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(gio>=inpStartTime && gio<inpEndTime) return true;
   else return false;
}

void FunDongBoLenhVaoCungThoiDiem(int VitriBoLenh)
{
   Print("Kiem tra DOng lenh");
   int kt=false;
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(StringToInteger(OrderComment())==VitriBoLenh)
         {
            Print("Thuc hien dong lenh");
            if(OrderType()==OP_BUY)
            {
               kt=true;
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),inpSlippage,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");  
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               kt=true;
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),inpSlippage,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");   
               }
            }
         }
         
      }
   }
   FunKiemTraXoaLenhKhoiMang();
   //if(kt==true) glbSoLanNhoiLenh--;
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
            for(int j=i;j<glbTongSoLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongSoLenh--;
         }
      }
   }
   if(glbTongSoLenh==0)
      FunReset();
}


//+------------------------------------------------------------------+
//| Create the text                                      |
//+------------------------------------------------------------------+
bool FunTextCreate( const int chart_ID=0,
               const string name="text",
               const string text="text",
               const int       sub_window=0,      // subwindow index
               double    price=0,           // price
               const color     clr=clrYellow)
{
    if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //--- reset the error value
      if(ObjectFind(chart_ID,name)>=0)
      {
         ObjectDelete(chart_ID,name);
      }
      ResetLastError();
      //--- create a text
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,Time[0],price))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());
      return(false);
     }
    ObjectSetText(name,text,10,NULL,clr);

    //ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_LEFT);    
    return true;  
}
//+------------------------------------------------------------------+
//| Move the text                                     |
//+------------------------------------------------------------------+
bool FunTextMove(const string name="Text", // object name
              datetime     time=0,      // anchor point time coordinate
              double       price=0)     // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunTextChange(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const string text="Text") // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the button                                      |
//+------------------------------------------------------------------+
bool FunButtonCreate(const string name="text",
               const string text="text",
               const int       sub_window=0,      // subwindow index
               double    price=0,           // price
               const color     clr=clrYellow)
{
    if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //--- reset the error value
      ResetLastError();
      //--- create a text
   if(!ObjectCreate(name,OBJ_TEXT,sub_window,Time[0],price))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());
      return(false);
     }
    ObjectSetText(name,text,10,NULL,clr);
    return true;  
}               
//+------------------------------------------------------------------+
//| Delete a object                                         |
//+------------------------------------------------------------------+
bool FunObjectDelete(
                 const string name="TextGiaCaoNhat") //  name
  {
//--- reset the error value
   ResetLastError();
//--- delete a texy
   if(!ObjectDelete(name))
     {
      Print(__FUNCTION__,
            ": failed to delete a object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool FunButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunButtonDelete(chart_ID,name);
   }
//--- create the charbutton
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Change button text                                               |
//+------------------------------------------------------------------+
bool FunButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change button text                                               |
//+------------------------------------------------------------------+
bool FunButtonColorTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const color clr=clrBlack)   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the text color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the button                                                |
//+------------------------------------------------------------------+
bool FunButtonDelete(const long   chart_ID=0,    // chart's ID
                  const string name="Button") // button name
  {
//--- reset the error value
   ResetLastError();
//--- delete the button
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditCreate(const long             chart_ID=0,               // chart's ID
                const string           name="Edit",              // object name
                const int              sub_window=0,             // subwindow index
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE,       // border color
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunEditDelete(chart_ID,name);
   }
   ResetLastError();
//--- create edit field
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  //+------------------------------------------------------------------+
//| Return Edit object text                                          |
//+------------------------------------------------------------------+
bool FunEditTextGet(string      &text,        // text
                 const long   chart_ID=0,  // chart's ID
                 const string name="Edit") // object name
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditDelete(const long   chart_ID=0,  // chart's ID
                const string name="Edit") // object name
{
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="btnDongBoLenh")
      {
         string ViTriBoLenh="";
         
         FunEditTextGet(ViTriBoLenh,0,"edtBoLenh");
         
         if(StringToInteger(ViTriBoLenh)>0)
         {
            Print("So len nhoi lenh: ", glbSoLanNhoiLenh, " Vi tri dong lenh: ",ViTriBoLenh);
            if (StringToInteger(ViTriBoLenh)>glbSoLanNhoiLenh)
            {
               MessageBox("Nhap Bo lenh sai");
            }
            else FunDongBoLenhVaoCungThoiDiem((int)StringToInteger(ViTriBoLenh));
         }
         else MessageBox("Nhap Bo lenh sai");
      }
       if(sparam=="btnDongToanBo")
      {
         FunDongTatCaCacLenh();
      }
  }

}