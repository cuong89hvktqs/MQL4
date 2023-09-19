//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
#property  indicator_chart_window
#include <Controls\Panel.mqh>
struct StrDiemNhoiLenh
{
    double _KhoiLuong;
    double _Points;
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,09,3023};
struct  StrTongLenhDuongLenhAm
{
   int TongLenhDuong;
   int TongLenhAm;
};

StrTongLenhDuongLenhAm glbTongLenhAmLenhDuongCuaBoLenhBuy,glbTongLenhAmLenhDuongCuaBoLenhSell;
CPanel myPanel;

input double inpVungGiaCanTrenBuy=0;// Vung gia can tren dung buy:
input double inpVungGiaCanDuoiBuy=0;// Vung gia can cuoi dung buy:
input double inpVungGiaCanTrenSell=0;// Vung gia can tren dung Sell:
input double inpVungGiaCanDuoiSell=0;// Vung gia can duoi dung sell:
//input int inpSL=100;//SL theo pips:
input unsigned int inpLoiNhuanToiThieuBanDau=10;//Chot loi theo so tien ($):
input unsigned int inpSoLenhKhiChuyenDichTPMoi=3;//So lenh khi dich chuyen TP moi:
input unsigned int inpLoiNhuanKhiKichHoatBaoVeLoiNhuan=20;//Kich hoat bao ve loi nhuan khi dat duoc loi nhuan ($):
input unsigned int inpLoiNhuanCanDuocBaoVe=10;//Loi nhuan can duoc bao ve ($):
input unsigned int inpSoPointLoiNhuanMongMuonDatDuoc=100;//So pip loi nhuan mong muon thuc te (Point):
input string inpComment="1";//Comment cua lenh vao bang tay de bot nhan lenh:
input string str1="CA DAT NHOI LENH DUONG";// CAI DAT NHOI LENH DUONG:
input bool inpChoPhepNhoiLenhDuong=true;//CHO PHEP CAI DAT NHOI LENH DUONG:
input string strDuong2="====Lenh nhoi duong 2=====";//Cai dat lenh nhoi duong so 2:
input double inpKhoiLuongNhoiDuong2=0.01;// Khoi luong nhoi duong lenh so 2:
input double inpKhoangCachNhoiLenhDuong2=100;// Khoang cach nhoi lenh so 2 (point):

input string strDuong3="====Lenh nhoi duong 3=====";//Cai dat lenh nhoi duong so 3:
input double inpKhoiLuongNhoiDuong3=0.01;// Khoi luong nhoi duong lenh so 3:
input double inpKhoangCachNhoiLenhDuong3=100;// Khoang cach nhoi lenh so 3 (point):

input string strDuong4="====Lenh nhoi duong 4=====";//Cai dat lenh nhoi duong so 4:
input double inpKhoiLuongNhoiDuong4=0.01;// Khoi luong nhoi duong lenh so 4:
input double inpKhoangCachNhoiLenhDuong4=100;// Khoang cach nhoi lenh so 4 (point):

input string strDuong5="====Lenh nhoi duong 5=====";//Cai dat lenh nhoi duong so 5:
input double inpKhoiLuongNhoiDuong5=0.01;// Khoi luong nhoi duong lenh so 5:
input double inpKhoangCachNhoiLenhDuong5=100;// Khoang cach nhoi lenh so 5 (point):

input string strDuong6="====Lenh nhoi duong 6=====";//Cai dat lenh nhoi duong so 6:
input double inpKhoiLuongNhoiDuong6=0.01;// Khoi luong nhoi duong lenh so 6:
input double inpKhoangCachNhoiLenhDuong6=100;// Khoang cach nhoi lenh so 6 (point):

input string strDuong7="====Lenh nhoi duong 7=====";//Cai dat lenh nhoi duong so 7:
input double inpKhoiLuongNhoiDuong7=0.01;// Khoi luong nhoi duong lenh so 7:
input double inpKhoangCachNhoiLenhDuong7=100;// Khoang cach nhoi lenh so 7 (point):

input string strDuong8="====Lenh nhoi duong 8=====";//Cai dat lenh nhoi duong so 8:
input double inpKhoiLuongNhoiDuong8=0.01;// Khoi luong nhoi duong lenh so 8:
input double inpKhoangCachNhoiLenhDuong8=100;// Khoang cach nhoi lenh so 8 (point):

input string strDuong9="====Lenh nhoi duong 9=====";//Cai dat lenh nhoi duong so 9:
input double inpKhoiLuongNhoiDuong9=0.01;// Khoi luong nhoi duong lenh so 9:
input double inpKhoangCachNhoiLenhDuong9=100;// Khoang cach nhoi lenh so 9 (point):
input string strDuong10="====Lenh nhoi duong 10=====";//Cai dat lenh nhoi duong so 10:
input double inpKhoiLuongNhoiDuong10=0.01;// Khoi luong nhoi duong lenh so 10:
input double inpKhoangCachNhoiLenhDuong10=100;// Khoang cach nhoi lenh so 10 (point):

input string str2="CA DAT NHOI LENH AM";// CAI DAT NHOI LENH AM:
input bool inpChoPhepNhoiLenhAm=true;//CHO PHEP CAI DAT NHOI LENH AM:
input string strAm2="====Lenh nhoi Am 2=====";//Cai dat lenh nhoi am so 2:
input double inpKhoiLuongNhoiAm2=0.01;// Khoi luong nhoi am lenh so 10:
input double inpKhoangCachNhoiLenhAm2=100;// Khoang cach nhoi lenh so 10 (point):

input string strAm3="====Lenh nhoi Am 3=====";//Cai dat lenh nhoi am so 3:
input double inpKhoiLuongNhoiAm3=0.01;// Khoi luong nhoi am lenh so 3:
input double inpKhoangCachNhoiLenhAm3=100;// Khoang cach nhoi lenh so 3 (point):

input string strAm4="====Lenh nhoi Am 4=====";//Cai dat lenh nhoi am so 4:
input double inpKhoiLuongNhoiAm4=0.01;// Khoi luong nhoi am lenh so 4:
input double inpKhoangCachNhoiLenhAm4=100;// Khoang cach nhoi lenh so 4 (point):

input string strAm5="====Lenh nhoi Am 5=====";//Cai dat lenh nhoi am so 5:
input double inpKhoiLuongNhoiAm5=0.01;// Khoi luong nhoi am lenh so 5:
input double inpKhoangCachNhoiLenhAm5=100;// Khoang cach nhoi lenh so 5 (point):

input string strAm6="====Lenh nhoi Am 6=====";//Cai dat lenh nhoi am so 6:
input double inpKhoiLuongNhoiAm6=0.01;// Khoi luong nhoi am lenh so 6:
input double inpKhoangCachNhoiLenhAm6=100;// Khoang cach nhoi lenh so 6 (point):

input string strAm7="====Lenh nhoi Am 7=====";//Cai dat lenh nhoi am so 7:
input double inpKhoiLuongNhoiAm7=0.01;// Khoi luong nhoi am lenh so 7:
input double inpKhoangCachNhoiLenhAm7=100;// Khoang cach nhoi lenh so 7 (point):

input string strAm8="====Lenh nhoi Am 8=====";//Cai dat lenh nhoi am so 8:
input double inpKhoiLuongNhoiAm8=0.01;// Khoi luong nhoi am lenh so 8:
input double inpKhoangCachNhoiLenhAm8=100;// Khoang cach nhoi lenh so 8 (point):

input string strAm9="====Lenh nhoi Am 9=====";//Cai dat lenh nhoi am so 09:
input double inpKhoiLuongNhoiAm9=0.01;// Khoi luong nhoi am lenh so 09:
input double inpKhoangCachNhoiLenhAm9=100;// Khoang cach nhoi lenh so 09 (point):

input string strAm10="====Lenh nhoi Am 10=====";//Cai dat lenh nhoi am so 10:
input double inpKhoiLuongNhoiAm10=0.01;// Khoi luong nhoi am lenh so 10:
input double inpKhoangCachNhoiLenhAm10=100;// Khoang cach nhoi lenh so 10 (point):

input string strAm11="====Lenh nhoi Am 11=====";//Cai dat lenh nhoi am so 11:
input double inpKhoiLuongNhoiAm11=0.01;// Khoi luong nhoi am lenh so 11:
input double inpKhoangCachNhoiLenhAm11=100;// Khoang cach nhoi lenh so 11 (point):

input string strAm12="====Lenh nhoi Am 12=====";//Cai dat lenh nhoi am so 12:
input double inpKhoiLuongNhoiAm12=0.01;// Khoi luong nhoi am lenh so 12:
input double inpKhoangCachNhoiLenhAm12=100;// Khoang cach nhoi lenh so 12 (point):

input string strAm13="====Lenh nhoi Am 13=====";//Cai dat lenh nhoi am so 13:
input double inpKhoiLuongNhoiAm13=0.01;// Khoi luong nhoi am lenh so 13:
input double inpKhoangCachNhoiLenhAm13=100;// Khoang cach nhoi lenh so 13 (point):

input string strAm14="====Lenh nhoi Am 14=====";//Cai dat lenh nhoi am so 14:
input double inpKhoiLuongNhoiAm14=0.01;// Khoi luong nhoi am lenh so 14:
input double inpKhoangCachNhoiLenhAm14=100;// Khoang cach nhoi lenh so 14 (point):

input string strAm15="====Lenh nhoi Am 15=====";//Cai dat lenh nhoi am so 15:
input double inpKhoiLuongNhoiAm15=0.01;// Khoi luong nhoi am lenh so 15:
input double inpKhoangCachNhoiLenhAm15=100;// Khoang cach nhoi lenh so 15 (point):

input string strAm16="====Lenh nhoi Am 16=====";//Cai dat lenh nhoi am so 16:
input double inpKhoiLuongNhoiAm16=0.01;// Khoi luong nhoi am lenh so 16:
input double inpKhoangCachNhoiLenhAm16=100;// Khoang cach nhoi lenh so 16 (point):

input string strAm17="====Lenh nhoi Am 17=====";//Cai dat lenh nhoi am so 17:
input double inpKhoiLuongNhoiAm17=0.01;// Khoi luong nhoi am lenh so 17:
input double inpKhoangCachNhoiLenhAm17=100;// Khoang cach nhoi lenh so 17 (point):

input string strAm18="====Lenh nhoi Am 18=====";//Cai dat lenh nhoi am so 18:
input double inpKhoiLuongNhoiAm18=0.01;// Khoi luong nhoi am lenh so 18:
input double inpKhoangCachNhoiLenhAm18=100;// Khoang cach nhoi lenh so 18 (point):

input string strAm19="====Lenh nhoi Am 19=====";//Cai dat lenh nhoi am so 19:
input double inpKhoiLuongNhoiAm19=0.01;// Khoi luong nhoi am lenh so 19:
input double inpKhoangCachNhoiLenhAm19=100;// Khoang cach nhoi lenh so 19 (point):

input string strAm20="====Lenh nhoi Am 20=====";//Cai dat lenh nhoi am so 20:
input double inpKhoiLuongNhoiAm20=0.01;// Khoi luong nhoi am lenh so 20:
input double inpKhoangCachNhoiLenhAm20=100;// Khoang cach nhoi lenh so 20 (point):

input string strAm21="====Lenh nhoi Am 21=====";//Cai dat lenh nhoi am so 21:
input double inpKhoiLuongNhoiAm21=0.01;// Khoi luong nhoi am lenh so 21:
input double inpKhoangCachNhoiLenhAm21=100;// Khoang cach nhoi lenh so 21 (point):

input string strAm22="====Lenh nhoi Am 22=====";//Cai dat lenh nhoi am so 22:
input double inpKhoiLuongNhoiAm22=0.01;// Khoi luong nhoi am lenh so 22:
input double inpKhoangCachNhoiLenhAm22=100;// Khoang cach nhoi lenh so 22 (point):

input string strAm23="====Lenh nhoi Am 23=====";//Cai dat lenh nhoi am so 23:
input double inpKhoiLuongNhoiAm23=0.01;// Khoi luong nhoi am lenh so 23:
input double inpKhoangCachNhoiLenhAm23=100;// Khoang cach nhoi lenh so 23 (point):

input string strAm24="====Lenh nhoi Am 24=====";//Cai dat lenh nhoi am so 24:
input double inpKhoiLuongNhoiAm24=0.01;// Khoi luong nhoi am lenh so 24:
input double inpKhoangCachNhoiLenhAm24=100;// Khoang cach nhoi lenh so 24 (point):

input string strAm25="====Lenh nhoi Am 25=====";//Cai dat lenh nhoi am so 25:
input double inpKhoiLuongNhoiAm25=0.01;// Khoi luong nhoi am lenh so 25:
input double inpKhoangCachNhoiLenhAm25=100;// Khoang cach nhoi lenh so 25 (point):
input string strAm26="====Lenh nhoi Am >= 26 lenh=====";//Cai dat lenh nhoi am so 25:
input double inpHeSoNhan=2;// He so nhan lenh am tu lenh so 26:
input double inpKhoangCachNhoiLenhAm26=100;// Khoang cach nhoi lenh tu lenh so 25 (point):

input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
int X_CoSo=0;
int Y_Co_So=170;

bool glbKiemTraDenVungGiaNgungBuy=false, glbKiemTraDenVungGiaNgungSell=false;
bool glbKichHoatBaoVeTaiSanBuy=false;
bool glbKichHoatBaoVeTaiSanSell=false;

bool glbChoPhepLapVaoLenhBuyChuKyMoi=true;
bool glbChoPhepLapVaoLenhSellChuKyMoi=true;

double glbKhoiLuongCoSoBuy=0;
double glbKhoiLuongCoSoSell=0;
int glbTapLenhSell[100];
int glbTapLenhBuy[100];
unsigned int glbTongLenhBuy=0;
unsigned int glbTongLenhSell=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(FunKiemTraChuaHetHan(NgayHetHan)==false) return INIT_FAILED;
   glbKiemTraDenVungGiaNgungBuy=false; 
   glbKiemTraDenVungGiaNgungSell=false;
   glbKichHoatBaoVeTaiSanBuy=false;
   glbKichHoatBaoVeTaiSanSell=false;
   

    myPanel.Create(0,"Bang",0,X_CoSo,Y_Co_So,X_CoSo+168,Y_Co_So+200);
    myPanel.ColorBackground(clrDarkSlateGray);
    FunLabelCreate(0,"LableMainSetting",0,X_CoSo+25,Y_Co_So+5,0,"MAIN SETTING","Arial",12,clrYellow);
    FunLabelCreate(0,"LableLapVaoLenhBuy",0,X_CoSo+5,Y_Co_So+30,0,"New cycle Buy:","Arial",12,clrYellow);
    // Fun
    if(glbChoPhepLapVaoLenhBuyChuKyMoi==true)
      FunButtonCreate(0,"btnLapVaoLenhBuy",0,X_CoSo+110,Y_Co_So+ 25,50,30,CORNER_LEFT_UPPER,"YES","Arial",12,clrBlue,clrLimeGreen);
    else 
      FunButtonCreate(0,"btnLapVaoLenhBuy",0,X_CoSo+110,Y_Co_So+ 25,50,30,CORNER_LEFT_UPPER,"NO","Arial",12,clrBlue,clrRed);

   FunLabelCreate(0,"LableLapVaoLenhSell",0,X_CoSo+5,Y_Co_So+65,0,"New cycle Sell:","Arial",12,clrYellow);
    // Fun
    if(glbChoPhepLapVaoLenhSellChuKyMoi==true)
      FunButtonCreate(0,"btnLapVaoLenhSell",0,X_CoSo+110,Y_Co_So+ 60,50,30,CORNER_LEFT_UPPER,"YES","Arial",12,clrBlue,clrLimeGreen);
    else 
      FunButtonCreate(0,"btnLapVaoLenhSell",0,X_CoSo+110,Y_Co_So+ 60,50,30,CORNER_LEFT_UPPER,"NO","Arial",12,clrBlue,clrRed);

    FunButtonCreate(0,"btnCloseBuy",0,X_CoSo+5,Y_Co_So+95,155,30,CORNER_LEFT_UPPER,"CLOSE BUY","Arial",12,clrYellow,clrBlue);
    FunButtonCreate(0,"btnCloseSell",0,X_CoSo+5,Y_Co_So+130,155  ,30,CORNER_LEFT_UPPER,"CLOSE SELL","Arial",12,clrYellow,clrRed);
    FunButtonCreate(0,"btnCloseAll",0,X_CoSo+5,Y_Co_So+ 165,155,30,CORNER_LEFT_UPPER,"CLOSE ALL","Arial",12,clrYellow,clrBlue);

   //if (glbTongLenhBuy==0)
   {
      glbKhoiLuongCoSoBuy=0;
      glbTongLenhBuy=0;
      
      
   }
  //if(glbTongLenhSell==0)
   {
      glbKhoiLuongCoSoSell=0;
      glbTongLenhSell=0;
      
   }
    


  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   ObjectsDeleteAll();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+


void OnTick()
{
   
   FunXuLyVoiLenhBuy();
   FunXuLyVoiLenhSell();
   string XauHienThi="";
   XauHienThi+="**********LENH BUY**********\n\t\tTong lenh buy: "+IntegerToString(glbTongLenhBuy);
   if(glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong>1)
      XauHienThi+="\n\tSo lenh nhoi duong: "+IntegerToString(glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong-1);
   if(glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhAm>1)
      XauHienThi+="\n\tSo leh nhoi am: "+IntegerToString(glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhAm-1);

   XauHienThi+="\n\t\tLoi nhuan hien tai: "+DoubleToString(FunTinhTongLoiNhuan(glbTapLenhBuy,glbTongLenhBuy),2);
   XauHienThi+="\n\t\tKhoi luong co so: "+DoubleToString(glbKhoiLuongCoSoBuy,2);
   if(glbKiemTraDenVungGiaNgungBuy==true)
      XauHienThi+="\n\t\tNgung vao lenh buy tiep theo do da cham vung gia can tren";
   if(glbKichHoatBaoVeTaiSanBuy)
      XauHienThi+="\n\t\tDa kich hoat bao ve tai khoan buy";
   if(glbChoPhepLapVaoLenhBuyChuKyMoi==false) 
      XauHienThi+="\n\t\tDUNG VAO LENH BUY CHU KY MOI";
   
   XauHienThi+="\n**********LENH SELL**********\n\t\tTong lenh sell: "+ IntegerToString(glbTongLenhSell);
   if(glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhDuong>1)
      XauHienThi+="\n\tSo lenh nhoi duong: "+IntegerToString(glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhDuong-1);
   if(glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhAm>1)
      XauHienThi+="\n\tSo leh nhoi am: "+IntegerToString(glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhAm-1);

   XauHienThi+="\n\t\tLoi nhuan hien tai: "+DoubleToString(FunTinhTongLoiNhuan(glbTapLenhSell,glbTongLenhSell),2);
   XauHienThi+="\n\t\tKhoi luong co so: "+DoubleToString(glbKhoiLuongCoSoSell,2);
   if(glbKiemTraDenVungGiaNgungSell==true)
      XauHienThi+="\n\t\tNgung vao lenh sell tiep theo do da cham vung gia can duoi";
   if(glbKichHoatBaoVeTaiSanSell)
      XauHienThi+="\n\t\tDa kich hoat bao ve tai khoan sell";
   if(glbChoPhepLapVaoLenhSellChuKyMoi==false) 
      XauHienThi+="\n\t\tDUNG VAO LENH SELL CHU KY MOI";
   Comment(XauHienThi);
   
}


void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   
   if(id==CHARTEVENT_OBJECT_CLICK )
   {
      
      if(sparam=="btnLapVaoLenhBuy")
      {
         string text;
         if(FunButtonTextGet(text,0,"btnLapVaoLenhBuy"))
         {
            if ((text=="YES"))
            {
               FunButtonTextChange(0,"btnLapVaoLenhBuy","NO");
               FunButtonColorTextChange(0,"btnLapVaoLenhBuy",clrRed);
               glbChoPhepLapVaoLenhBuyChuKyMoi=false;
            }
            else
            {
               FunButtonTextChange(0,"btnLapVaoLenhBuy","YES");
               FunButtonColorTextChange(0,"btnLapVaoLenhBuy",clrLimeGreen);
               glbChoPhepLapVaoLenhBuyChuKyMoi=True;
               glbKhoiLuongCoSoBuy=0;
            }
            
         }

      }
      if(sparam=="btnLapVaoLenhSell")
      {
         string text;
         if(FunButtonTextGet(text,0,"btnLapVaoLenhSell"))
         {
            if ((text=="YES"))
            {
               FunButtonTextChange(0,"btnLapVaoLenhSell","NO");
               FunButtonColorTextChange(0,"btnLapVaoLenhSell",clrRed);
               glbChoPhepLapVaoLenhSellChuKyMoi=false;
            }
            else
            {
               FunButtonTextChange(0,"btnLapVaoLenhSell","YES");
               FunButtonColorTextChange(0,"btnLapVaoLenhSell",clrLimeGreen);
               glbChoPhepLapVaoLenhSellChuKyMoi=True;
               glbKhoiLuongCoSoSell=0;
            }
            
         }

      }

      if(sparam=="btnCloseBuy")
         { FunDongTatCaCacLenh(glbTapLenhBuy,glbTongLenhBuy);glbKichHoatBaoVeTaiSanBuy=false;}
      if(sparam=="btnCloseSell")
         {FunDongTatCaCacLenh(glbTapLenhSell,glbTongLenhSell);glbKichHoatBaoVeTaiSanSell=false;}
      if(sparam=="btnCloseAll")
      {
         FunDongTatCaCacLenh(glbTapLenhBuy,glbTongLenhBuy);
         FunDongTatCaCacLenh(glbTapLenhSell,glbTongLenhSell);
         glbKichHoatBaoVeTaiSanBuy=false;
         glbKichHoatBaoVeTaiSanSell=false;
      }
      ChartRedraw();
   }
}
//******************************XU LU LENH BUY**************************************************
void FunTimLenhCacSanCo(int &glbTapLenh[],int &glbTongLenh,StrTongLenhDuongLenhAm &glbTongLenhDuongLenhAm,double &glbKhoiLuongCoSo, int LoaiLenh)
{
   double GiaVaoLenhDauTien=0;
   glbTongLenh=0;
   glbKhoiLuongCoSo=0;
   glbTongLenhDuongLenhAm.TongLenhAm=0;
   glbTongLenhDuongLenhAm.TongLenhDuong=0;
   for (int i = 0; i< OrdersTotal(); i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      if(OrderSymbol()==Symbol()&&OrderType()==LoaiLenh && (OrderComment()==inpComment ||OrderMagicNumber()==inpMagicNumber))
      {
         glbTapLenh[glbTongLenh]=OrderTicket();
         glbTongLenh++;
         if(glbTongLenh==1)
         {
            glbKhoiLuongCoSo=OrderLots();
            GiaVaoLenhDauTien=OrderOpenPrice();
            glbTongLenhDuongLenhAm.TongLenhAm=1;
            glbTongLenhDuongLenhAm.TongLenhDuong=1;
         } 
         else
         {
            if(OrderOpenPrice()>GiaVaoLenhDauTien)
            {
               if(LoaiLenh==OP_BUY) glbTongLenhDuongLenhAm.TongLenhDuong++;
               else glbTongLenhDuongLenhAm.TongLenhAm++;
            }
            else if(OrderOpenPrice()<GiaVaoLenhDauTien)
            {
               if(LoaiLenh==OP_BUY)glbTongLenhDuongLenhAm.TongLenhAm++;
               else glbTongLenhDuongLenhAm.TongLenhDuong++;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
void FunXuLyVoiLenhBuy()
{
   if(glbKiemTraDenVungGiaNgungBuy==false && inpVungGiaCanTrenBuy>0)// KIem tra den vung ngung buy chua
   {
      if(Bid>=inpVungGiaCanTrenBuy) glbKiemTraDenVungGiaNgungBuy=true;
   }
   if(glbKiemTraDenVungGiaNgungBuy==false && inpVungGiaCanDuoiBuy>0)// KIem tra den vung ngung buy chua
   {
      if(Bid<=inpVungGiaCanDuoiBuy) glbKiemTraDenVungGiaNgungBuy=true;
   }

   if(glbTongLenhBuy==0)//Chua co lenh
   {
      FunTimLenhBuyKhiChuaCoLenh();
   }
   else
   {
      if(glbTongLenhBuy>=inpSoLenhKhiChuyenDichTPMoi)
      {
         if( glbKichHoatBaoVeTaiSanBuy==false)
         {
            if(FunTinhTongLoiNhuan(glbTapLenhBuy,glbTongLenhBuy)>=inpLoiNhuanKhiKichHoatBaoVeLoiNhuan) 
            {
               glbKichHoatBaoVeTaiSanBuy=true;
               Print("KICH HOAT BAO VE RUI RO TAI SAN CAC LENH BUY");
            }
         }
         else
         {
            if(FunTinhTongLoiNhuan(glbTapLenhBuy,glbTongLenhBuy)<=inpLoiNhuanCanDuocBaoVe)
            {
               FunDongTatCaCacLenh(glbTapLenhBuy,glbTongLenhBuy);glbKichHoatBaoVeTaiSanBuy=false;
               Print("DONG TAT CA CAC LENH BUY BAO VE TAI SAN");
            }
         }

      }
      else
      {
         if(FunTinhTongLoiNhuan(glbTapLenhBuy,glbTongLenhBuy)>=inpLoiNhuanToiThieuBanDau)//dong lenh khi dat duoc loi nhuan ban dau
         {   
            FunDongTatCaCacLenh(glbTapLenhBuy,glbTongLenhBuy);glbKichHoatBaoVeTaiSanBuy=false;
            Print("DONG TAT CA CAC LENH BUY KHI DAT DUOC LOI NHUAN MONG MUON BAN DAU");
         }
      }
      if(inpChoPhepNhoiLenhDuong==true && glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong<10 && glbKiemTraDenVungGiaNgungBuy==false)
      {
         FunXuLyNhoiLenhDuong(glbTapLenhBuy,glbTongLenhBuy,glbTongLenhAmLenhDuongCuaBoLenhBuy);
      }
      if(inpChoPhepNhoiLenhAm==true)
      {
         FunXuLyNhoiLenhAm(glbTapLenhBuy,glbTongLenhBuy,glbTongLenhAmLenhDuongCuaBoLenhBuy);
      }
      //FunKiemTraDongLenhBangTay(glbTapLenhBuy,glbTongLenhBuy);//DOng tat ca cac lenh
      FunKiemTraXoaLenhKhoiMang(glbTapLenhBuy,glbTongLenhBuy);
   }
}
//+------------------------------------------------------------------+
void FunTimLenhBuyKhiChuaCoLenh()
{
   if(glbKhoiLuongCoSoBuy!=0 && glbChoPhepLapVaoLenhBuyChuKyMoi==false) 
   {return;}
   // Kiem tra lenh vao bang tay
   //FunVaoLenh(OP_BUY,Ask,0,0,0.1);
   /* for (int i = 0; i < OrdersTotal(); i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      if(OrderType()==0 && OrderSymbol()==Symbol())
      {
         glbKhoiLuongCoSoBuy=OrderLots();
         glbTapLenhBuy[0]=OrderTicket();
         glbTongLenhBuy=1;
         glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhAm=1;
         glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong=1;
         glbKichHoatBaoVeTaiSanBuy=false;
         break;
      }
   } */
   if(glbKhoiLuongCoSoBuy==0)
   {
      FunTimLenhCacSanCo(glbTapLenhBuy,glbTongLenhBuy,glbTongLenhAmLenhDuongCuaBoLenhBuy,glbKhoiLuongCoSoBuy, OP_BUY);
      if(glbTongLenhBuy>=inpSoLenhKhiChuyenDichTPMoi)
         FunCapNhatDiemTPSL(glbTapLenhBuy,glbTongLenhBuy,inpSoPointLoiNhuanMongMuonDatDuoc);
      return;
   }  
      

   // Kiem tra lenh vao luon khi da dong lenh buy truoc do, van thoa man dieu kien buy
   if(glbTongLenhBuy>0) return;
   if(glbKiemTraDenVungGiaNgungBuy==false)// van vao lenh tiep khi chua den vung dung vao lenh buy
   {
      if(glbChoPhepLapVaoLenhBuyChuKyMoi==true && glbKhoiLuongCoSoBuy>0)
      {
         int Ticket=FunVaoLenh(OP_BUY,Ask,0,0,glbKhoiLuongCoSoBuy);
         if(Ticket>0)
         {
            glbTapLenhBuy[glbTongLenhBuy]=Ticket;
            glbTongLenhBuy++;
            glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhAm=1;
            glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong=1;
            glbKichHoatBaoVeTaiSanBuy=false;
         }
      }
      
   }
   else // Het lenh buy, ngung buy va vao lenh sell
   {
      if(glbTongLenhSell==0)
      {
         int Ticket=FunVaoLenh(OP_SELL,Bid,0,0,glbKhoiLuongCoSoBuy);
         if(Ticket>0)
         {
            Print("VAO LENH SELL DO DEN VUNG CAN PHIA TREN");
            glbTapLenhSell[glbTongLenhSell]=Ticket;
            glbTongLenhSell++;
            glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhAm=1;
            glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhDuong=1;
            glbKhoiLuongCoSoSell=glbKhoiLuongCoSoBuy;
            glbKichHoatBaoVeTaiSanSell=false;
         }
      }
   }

}

//******************************XU LU LENH SELL**************************************************
//+------------------------------------------------------------------+
void FunXuLyVoiLenhSell()
{
   if(glbKiemTraDenVungGiaNgungSell==false && inpVungGiaCanDuoiSell>0)// KIem tra den vung ngung buy chua
   {
      if(Bid<=inpVungGiaCanDuoiSell) glbKiemTraDenVungGiaNgungSell=true;
   }
   if(glbKiemTraDenVungGiaNgungSell==false && inpVungGiaCanTrenSell>0)// KIem tra den vung ngung buy chua
   {
      if(Bid>=inpVungGiaCanTrenSell) glbKiemTraDenVungGiaNgungSell=true;
   }

   if(glbTongLenhSell==0)//Chua co lenh
   {
      FunTimLenhSellKhiChuaCoLenh();
   }
   else
   {
      if(glbTongLenhSell>=inpSoLenhKhiChuyenDichTPMoi)
      {
         if( glbKichHoatBaoVeTaiSanSell==false)
         {
            if(FunTinhTongLoiNhuan(glbTapLenhSell,glbTongLenhSell)>=inpLoiNhuanKhiKichHoatBaoVeLoiNhuan) 
            {
               glbKichHoatBaoVeTaiSanSell=true;
               Print("KICH HOAT BAO VE RUI RO TAI SAN CAC LENH SELL");
            }
         }
         else
         {
            if(FunTinhTongLoiNhuan(glbTapLenhSell,glbTongLenhSell)<=inpLoiNhuanCanDuocBaoVe)
              {FunDongTatCaCacLenh(glbTapLenhSell,glbTongLenhSell);glbKichHoatBaoVeTaiSanSell=false;
               Print("DONG TAT CA CAC LENH SELL BAO VE TAI SAN");
              }
         }

      }
      else
      {
         if(FunTinhTongLoiNhuan(glbTapLenhSell,glbTongLenhSell)>=inpLoiNhuanToiThieuBanDau)//dong lenh khi dat duoc loi nhuan ban dau
            {FunDongTatCaCacLenh(glbTapLenhSell,glbTongLenhSell);glbKichHoatBaoVeTaiSanSell=false;
               Print("DONG TAT CA CAC LENH SELL KHI DAT DUOC LOI NHUAN MONG MUON BAN DAU");
            }
      }
      if(inpChoPhepNhoiLenhDuong==true && glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhDuong<10 && glbKiemTraDenVungGiaNgungSell==false)
      {
         FunXuLyNhoiLenhDuong(glbTapLenhSell,glbTongLenhSell,glbTongLenhAmLenhDuongCuaBoLenhSell);
      }
      if(inpChoPhepNhoiLenhAm==true)
      {
         FunXuLyNhoiLenhAm(glbTapLenhSell,glbTongLenhSell,glbTongLenhAmLenhDuongCuaBoLenhSell);
      }
      //FunKiemTraDongLenhBangTay(glbTapLenhSell,glbTongLenhSell);
      FunKiemTraXoaLenhKhoiMang(glbTapLenhSell,glbTongLenhSell);
   }
}

//+------------------------------------------------------------------+
void FunTimLenhSellKhiChuaCoLenh()
{
   if(glbKhoiLuongCoSoSell!=0 && glbChoPhepLapVaoLenhSellChuKyMoi==false) 
   {return;}
   // Kiem tra lenh vao bang tay
   //FunVaoLenh(OP_SELL,Bid,0,0,0.1);
   if(glbKhoiLuongCoSoSell==0)
   {
      FunTimLenhCacSanCo(glbTapLenhSell,glbTongLenhSell,glbTongLenhAmLenhDuongCuaBoLenhSell,glbKhoiLuongCoSoSell, OP_SELL);
      if(glbTongLenhSell>=inpSoLenhKhiChuyenDichTPMoi)
         FunCapNhatDiemTPSL(glbTapLenhSell,glbTongLenhSell,inpSoPointLoiNhuanMongMuonDatDuoc);
      //FunTimLenhCacSanCo(glbTapLenhSell,glbTongLenhSell,glbTongLenhAmLenhDuongCuaBoLenhSell,glbKhoiLuongCoSoSell,OP_SELL);
      return;
   }
      
   // Kiem tra lenh vao luon khi da dong lenh sell truoc do, van thoa man dieu kien sell
   if(glbTongLenhSell>0) return;
   if(glbKiemTraDenVungGiaNgungSell==false)// van vao lenh tiep khi chua den vung dung vao lenh buy
   {
      if(glbChoPhepLapVaoLenhSellChuKyMoi==true && glbKhoiLuongCoSoSell>0)
      {
         int Ticket=FunVaoLenh(OP_SELL,Bid,0,0,glbKhoiLuongCoSoSell);
         if(Ticket>0)
         {
            glbTapLenhSell[glbTongLenhSell]=Ticket;
            glbTongLenhSell++;
            glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhAm=1;
            glbTongLenhAmLenhDuongCuaBoLenhSell.TongLenhDuong=1;
            glbKichHoatBaoVeTaiSanSell=false;
         }
      }  
   }
   else // Het lenh sell, ngung sell va vao lenh buy
   {
      if(glbTongLenhBuy==0)
      {
         int Ticket=FunVaoLenh(OP_BUY,Ask,0,0,glbKhoiLuongCoSoSell);
         if(Ticket>0)
         {
            Print("VAO LENH BUY DO DEN VUNG CAN PHIA TREN");
            glbTapLenhBuy[glbTongLenhBuy]=Ticket;
            glbTongLenhBuy++;
            glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhAm=1;
            glbTongLenhAmLenhDuongCuaBoLenhBuy.TongLenhDuong=1;
            glbKhoiLuongCoSoBuy=glbKhoiLuongCoSoSell;
            glbKichHoatBaoVeTaiSanBuy=false;
         }
      }
   }

}

void FunXuLyNhoiLenhDuong(int &glbTapLenh[],unsigned int &glbTongLenh, StrTongLenhDuongLenhAm &TongLenhAmLenhDuong)
{
   if(glbTongLenh==0)return;
   int Ticket=-1;
   StrDiemNhoiLenh DiemNhoiLenhHienTai=FunTinhDiemNhoiLenhDuong(TongLenhAmLenhDuong.TongLenhDuong);
   OrderSelect(glbTapLenh[0],SELECT_BY_TICKET);
   if(OrderType()==OP_BUY)
   {
      double DiemNhoiLenh=OrderOpenPrice()+DiemNhoiLenhHienTai._Points*Point();
      if(Ask>=DiemNhoiLenh)
      {
         Ticket=FunVaoLenh(OP_BUY,Ask,0,0,DiemNhoiLenhHienTai._KhoiLuong);
      }
   }
   else
   {
      double DiemNhoiLenh=OrderOpenPrice()-DiemNhoiLenhHienTai._Points*Point();
      if(Bid<=DiemNhoiLenh)
      {
         Ticket=FunVaoLenh(OP_SELL,Bid,0,0,DiemNhoiLenhHienTai._KhoiLuong);
      }
   }
   if(Ticket>0)
   {
      glbTapLenh[glbTongLenh]=Ticket;
      glbTongLenh++;
      TongLenhAmLenhDuong.TongLenhDuong++;
      if(glbTongLenh>=inpSoLenhKhiChuyenDichTPMoi)
         FunCapNhatDiemTPSL(glbTapLenh,glbTongLenh,inpSoPointLoiNhuanMongMuonDatDuoc);
   }
}


//******************************HAM TONG QUAT**************************************************
void FunXuLyNhoiLenhAm(int &glbTapLenh[],unsigned int &glbTongLenh,StrTongLenhDuongLenhAm &TongLenhAmLenhDuong)
{
    if(glbTongLenh==0)return;
   int Ticket=-1;
   StrDiemNhoiLenh DiemNhoiLenhHienTai=FunTinhDiemNhoiLenhAm(TongLenhAmLenhDuong.TongLenhAm);
   if(DiemNhoiLenhHienTai._KhoiLuong<=0)return;
   OrderSelect(glbTapLenh[0],SELECT_BY_TICKET);
   if(OrderType()==OP_BUY)
   {
      double DiemNhoiLenh=OrderOpenPrice()-DiemNhoiLenhHienTai._Points*Point();
      if(Ask<=DiemNhoiLenh)
      {
         Ticket=FunVaoLenh(OP_BUY,Ask,0,0,DiemNhoiLenhHienTai._KhoiLuong);
      }
   }
   else
   {
      double DiemNhoiLenh=OrderOpenPrice()+DiemNhoiLenhHienTai._Points*Point();
      if(Bid>=DiemNhoiLenh)
      {
         Ticket=FunVaoLenh(OP_SELL,Bid,0,0,DiemNhoiLenhHienTai._KhoiLuong);
      }
   }
   if(Ticket>0)
   {
      glbTapLenh[glbTongLenh]=Ticket;
      glbTongLenh++;
      TongLenhAmLenhDuong.TongLenhAm++;
      if(glbTongLenh>=inpSoLenhKhiChuyenDichTPMoi)
         FunCapNhatDiemTPSL(glbTapLenh,glbTongLenh,inpSoPointLoiNhuanMongMuonDatDuoc);
   }
}
//+------------------------------------------------------------------+
void FunKiemTraDongLenhBangTay(int &glbTapLenh[], int &glbTongLenh)
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            FunDongTatCaCacLenh(glbTapLenh,glbTongLenh);
         }
      }
   }
}
//+------------------------------------------------------------------+
double FunTinhTongLoiNhuan(int &glbTapLenh[], int &glbTongLenh)
{
   double TongLoiNhuan=0;
   for (int i = 0; i < glbTongLenh; i++)
   {
      if(!OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))continue;
      TongLoiNhuan+=OrderProfit()+OrderSwap()+OrderCommission();
   }
   return NormalizeDouble(TongLoiNhuan,2);
   
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
void FunCapNhatDiemTPSL(int &glbTapLenh[], int &glbTongLenh,double LoiNhuanCanDatDuocTheoPoint)
{
   double DiemDongTatCaCacLenhTP=0;
   double TongComVaSwap=0;
   double TongTheoGia=0;
   double TongKhoiLuong=0;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double LoiNhuanCanDatDuocTP;
   OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET);
   int LoaiLenh=OrderType();
   if(LoaiLenh==OP_BUY)
   {
      for(int i=0;i<glbTongLenh;i++)
      {
         OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      LoiNhuanCanDatDuocTP=TongKhoiLuong*LoiNhuanCanDatDuocTheoPoint*nTickValue;
      if(LoiNhuanCanDatDuocTheoPoint==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue)+TongTheoGia)/TongKhoiLuong;
      //Print("TP:",DiemDongTatCaCacLenhTP, " Tong KL: ",TongKhoiLuong, " Loi nhuan can dat: ",LoiNhuanCanDatDuocTP);
      if(DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongLenh;i++)
         {
            if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
            {
               if(DiemDongTatCaCacLenhTP!=OrderTakeProfit())
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),DiemDongTatCaCacLenhTP,0,clrNONE);
            }
            
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
      LoiNhuanCanDatDuocTP=TongKhoiLuong*LoiNhuanCanDatDuocTheoPoint*nTickValue;
      if(LoiNhuanCanDatDuocTP==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(TongTheoGia-((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue))/TongKhoiLuong;
      //Print("TP:",DiemDongTatCaCacLenhTP);
      if( DiemDongTatCaCacLenhTP!=0)
      {
         DiemDongTatCaCacLenhTP=NormalizeDouble(DiemDongTatCaCacLenhTP,Digits);
         for(int i=0;i<glbTongLenh;i++)
         {
            if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
            {
               if(DiemDongTatCaCacLenhTP!=OrderTakeProfit())
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),DiemDongTatCaCacLenhTP,0,clrNONE);
            }
            
         }
      }
      
   }
}


//+------------------------------------------------------------------+
void FunDongTatCaCacLenh(int &glbTapLenh[],unsigned int &glbTongLenh)
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

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang(int &glbTapLenh[], int &glbTongLenh)
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

//+------------------------------------------------------------------+
StrDiemNhoiLenh FunTinhDiemNhoiLenhDuong(int TongLenhDangCo)
{
    StrDiemNhoiLenh Tam;
    switch (TongLenhDangCo)
    {
    case 1:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong2;
        Tam._Points=inpKhoangCachNhoiLenhDuong2;
        break;
    case 2:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong3;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3;
        break;
    case 3:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong4;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4;
        break;
    case 4:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong5;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5;
        break;
    case 5:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong6;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5+
                     inpKhoangCachNhoiLenhDuong6;
        break;
    case 6:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong7;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5+
                     inpKhoangCachNhoiLenhDuong6+ inpKhoangCachNhoiLenhDuong7;
        break;
    case 7:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong8;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5+
                     inpKhoangCachNhoiLenhDuong6+ inpKhoangCachNhoiLenhDuong7+inpKhoangCachNhoiLenhDuong8;
        break;
    case 8:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong9;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5+
                     inpKhoangCachNhoiLenhDuong6+ inpKhoangCachNhoiLenhDuong7+inpKhoangCachNhoiLenhDuong8+inpKhoangCachNhoiLenhDuong9;
        break;
    case 9:
        Tam._KhoiLuong=inpKhoiLuongNhoiDuong10;
        Tam._Points=inpKhoangCachNhoiLenhDuong2+inpKhoangCachNhoiLenhDuong3+inpKhoangCachNhoiLenhDuong4+inpKhoangCachNhoiLenhDuong5+
                  inpKhoangCachNhoiLenhDuong6+ inpKhoangCachNhoiLenhDuong7+inpKhoangCachNhoiLenhDuong8+inpKhoangCachNhoiLenhDuong9+
                  inpKhoangCachNhoiLenhDuong10;
        break;
    default:
         Tam._KhoiLuong=0;
        Tam._Points=0;
        break;
    }
    return Tam;
}

//+------------------------------------------------------------------+
StrDiemNhoiLenh FunTinhDiemNhoiLenhAm(int TongLenhDangCo)
{
    StrDiemNhoiLenh Tam;
    Tam._KhoiLuong=0;
    Tam._Points=0;
    if(TongLenhDangCo<=0) return Tam;
    switch (TongLenhDangCo)
    {
    case 1:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm2;
        Tam._Points=inpKhoangCachNhoiLenhAm2;
        break;
    case 2:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm3;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3;
        break;
    case 3:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm4;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4;
        break;
    case 4:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm5;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5;
        break;
    case 5:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm6;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6;
        break;
    case 6:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm7;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7;
        break;
    case 7:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm8;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8;
        break;
    case 8:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm9;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9;
        break;
    case 9:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm10;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10;
        break;
    
    case 10:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm11;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11;
        break;
    case 11:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm12;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12;
        break;

    case 12:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm13;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13;
        break;
    case 13:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm14;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14;
        break;
    case 14:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm15;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15;
        break;
    case 15:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm16;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16;
        break;
    case 16:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm17;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17;
        break;
    case 17:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm18;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18;
        break;
    case 18:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm19;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19;
        break;
    case 19:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm20;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20;
        break;
    case 20:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm21;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21;
        break;
    case 21:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm22;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21+
                    inpKhoangCachNhoiLenhAm22;
        break;

    case 22:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm23;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21+
                    inpKhoangCachNhoiLenhAm22+inpKhoangCachNhoiLenhAm23;
        break;
    case 23:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm24;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21+
                    inpKhoangCachNhoiLenhAm22+inpKhoangCachNhoiLenhAm23+inpKhoangCachNhoiLenhAm24;
        break;
    case 24:
        Tam._KhoiLuong=inpKhoiLuongNhoiAm25;
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21+
                    inpKhoangCachNhoiLenhAm22+inpKhoangCachNhoiLenhAm23+inpKhoangCachNhoiLenhAm24+inpKhoangCachNhoiLenhAm25;
        break;
    default: //Tong lenh dang co >=25
        Tam._KhoiLuong=inpKhoiLuongNhoiAm25*MathPow(inpHeSoNhan,TongLenhDangCo+1-25);
        Tam._KhoiLuong=NormalizeDouble(Tam._KhoiLuong,FunPhanThapPhanKhoiLuong());
        Tam._Points=inpKhoangCachNhoiLenhAm2+inpKhoangCachNhoiLenhAm3+inpKhoangCachNhoiLenhAm4+inpKhoangCachNhoiLenhAm5+
                    inpKhoangCachNhoiLenhAm6+inpKhoangCachNhoiLenhAm7+inpKhoangCachNhoiLenhAm8+inpKhoangCachNhoiLenhAm9+
                    inpKhoangCachNhoiLenhAm10+inpKhoangCachNhoiLenhAm11+inpKhoangCachNhoiLenhAm12+inpKhoangCachNhoiLenhAm13+
                    inpKhoangCachNhoiLenhAm14+inpKhoangCachNhoiLenhAm15+inpKhoangCachNhoiLenhAm16+inpKhoangCachNhoiLenhAm17+
                    inpKhoangCachNhoiLenhAm18+inpKhoangCachNhoiLenhAm19+inpKhoangCachNhoiLenhAm20+inpKhoangCachNhoiLenhAm21+
                    inpKhoangCachNhoiLenhAm22+inpKhoangCachNhoiLenhAm23+inpKhoangCachNhoiLenhAm24+inpKhoangCachNhoiLenhAm25+
                    inpKhoangCachNhoiLenhAm25*(TongLenhDangCo+1-25);
        break;
    }
    return Tam;
}
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
  
}
//********************************VE GIAO DIEN****************************
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
bool FunButtonTextGet(string      &text,        // text
                 const long   chart_ID=0,  // chart's ID
                 const string name="Button") // object name
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
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,clr))
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
//| Create a bitmap in the chart window                              |
//+------------------------------------------------------------------+
bool FunBitmapCreate(const long            chart_ID=0,        // chart's ID
                  const string          name="Bitmap",     // bitmap name
                  const int             sub_window=0,      // subwindow index
                  datetime              time=0,            // anchor point time
                  double                price=0,           // anchor point price
                  const string          file="",           // bitmap file name
                  const int             width=10,          // visibility scope X coordinate
                  const int             height=10,         // visibility scope Y coordinate
                  const int             x_offset=0,        // visibility scope shift by X axis
                  const int             y_offset=0,        // visibility scope shift by Y axis
                  const color           clr=clrRed,        // border color when highlighted
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style when highlighted
                  const int             point_width=1,     // move point size
                  const bool            back=false,        // in the background
                  const bool            selection=false,   // highlight to move
                  const bool            hidden=true,       // hidden in the object list
                  const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeBitmapEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a bitmap
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create a bitmap in the chart window! Error code = ",GetLastError());
      return(false);
     }
//--- set the path to the image file
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,file))
     {
      Print(__FUNCTION__,
            ": failed to load the image! Error code = ",GetLastError());
      return(false);
     }
//--- set visibility scope for the image; if width or height values
//--- exceed the width and height (respectively) of a source image,
//--- it is not drawn; in the opposite case,
//--- only the part corresponding to these values is drawn
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the part of an image that is to be displayed in the visibility scope
//--- the default part is the upper left area of an image; the values allow
//--- performing a shift from this area displaying another part of the image
   ObjectSetInteger(chart_ID,name,OBJPROP_XOFFSET,x_offset);
   ObjectSetInteger(chart_ID,name,OBJPROP_YOFFSET,y_offset);
//--- set the border color when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a size of the anchor point for moving an object
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,point_width);
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
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeBitmapEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
 //+------------------------------------------------------------------+
//| Delete the rectangle label                                       |
//+------------------------------------------------------------------+
bool FunRectLabelDelete(const long   chart_ID=0,       // chart's ID
                     const string name="RectLabel") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
  bool FunRectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunRectLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
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
//| Change Edit object's text                                        |
//+------------------------------------------------------------------+
bool FunEditTextChange(const long   chart_ID=0,  // chart's ID
                    const string name="Edit", // object name
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