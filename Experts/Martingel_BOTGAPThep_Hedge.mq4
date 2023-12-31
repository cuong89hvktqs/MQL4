//+------------------------------------------------------------------+
//|                                                   BotGapThep.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
// Gia nam trong vung gia A-B se kich hoat lenh, ueuu cau bat buoc luc vao lenh gia Bid phai nam trogn vung A_B
// Gia nam trong vung gia A-B, khi gia chm den vung gia kich hoat moi vao lenh dau tiên của chu kỳ đầu tiên. Các lệnh chu kỳ sau vào tuân theo yêu cầu của vùng giá A-B
enum ENUM_BOT
{
   TU_DONG,
   THEO_VUNG_GIA_TREN_DUOI,
   THEO_VUNG_GIA_KICH_HOAT 
};
enum ENUM_LOAI_LENH
{
   LENH_BUY,
   LENH_SELL
};
// KHI BOT VAO THEO VUNG GIA: CAN BIET BOT DANG DINH VAO THEO KIEU CANH LENH NAO khi canh lenh vao theo gia kich hoat
enum ENUM_KIEU_CANH_LENH{
   CANH_BUY_LIMIT,
   CANH_BUY_STOP,
   CANH_SELL_LIMIT,
   CANH_SELL_STOP
};
enum ENUM_TINH_KHOI_LUONG
{
   THEO_PHAN_TRAM,
   THEO_LOTS
};
input ENUM_BOT inpKieuBot=TU_DONG;// Kieu BOT hoat dong:
input ENUM_LOAI_LENH inpLoaiLenh=LENH_SELL;// Loai lenh se vao:
input double inpGiaCanTren=0;// Vung gia can tren:
input double inpGiaCanDuoi=0;// Vung gia can duoi:
input double inpGiaKichHoat=0;// Vung Gia Kich hoat lenh Limit:
input int inpTongLoiNhuanToiDaTatCacCacChuKy=0;//Tong loi nhuan toi da cho cap tien ($<=0: Khong gioi han):
input string inpThongSo="THONG SO CHO LENH DAU TIEN";//THONG SO: 
input double inpKhoiLuongCoSo=0.01; // Khoi luong lenh dau tien (lots >0):
input double inpPointTPCoSo=300;// Diem TP lenh dau tien (Points):
input string inpThongSoNhoiLenh="THONG SO CHO NHOI LENH TIEP THEO";//THONG SO: 
input double inpHeSoNhanKhoiLuongLenh=2;// He so nhan khoi luong lenh:
input double inpKhoangCachNhoiLenh=150;// Khoang Cach nhoi lenh (points):
input double inpSoLenhGiuNguyenKhoangCanhNhoi=0;//So lenh giu nguyen khoang cach nhoi lenh (<=1: Khong co lenh nao):
input double inpHeSoKhoangCachNhoiLenh=1;//He so nhan khoang cach nhoi lenh:
input double inpSoLenhChoPhepHedge=4;// So lenh cho phep hedge:
input int inpTongSoLenhToiDa=8;//Tong so lenh toi da:
input double inpVungGiaKhongChoPhepNhoiLenh=0; // Vung Gia khong Cho phep nhoi lenh  (=0: Vao thoai mai):
input double inpVungGiaSLToanBoLenh=0;// Vung Gia SL toan bo cac lenh (=0: Nhoi thoai mai):
input double inpVungGiaTPToanBoLenh=0;//Vung gia TP toan bo lenh (=0: Khong kiem tra):
input int inpTongLoToiDaMotChuKy=0;// Tong am toi da ($<=0: Full tai khoan):
input double inpStartTime=8;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=22;// Thoi Gian Ket Thuc vao lenh(Server time):
input int inpSlippage=100;// Do truot gia (slippage):
input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1735772983:AAG4g3Qem_oGQN3bpTmztuLHiT67bQCsXWs";//Ma Token bot Telegram:
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={23,12,3022};
int glbTongSoLenh=0;
int glbTapLenh[200];
int glbLenhLimit=-1;
int glbSlippage=50;
int glbMagic=12345;
double glbGiaVaoLenhCoSo=0;
double glbLoiNhuanLenhCoSoCoTheDatDuoc=0;
double glbTongLoiNhuanCanDatDeDongLenh=0;
double glbTongLoiLoCuaTatCaCacChuKy=0;
ENUM_KIEU_CANH_LENH glbKieuCanhLenhVaoTheoGiaKichHoat;
bool glbDaVuotQuaVungGiaVaoLenh=false;// Khi vao lenh theo vung gia, neu gia da vuot qua vung gia can tren, can duoi thi khong vao lenh nua
bool glbDaDatDuocLoiNhuanToiDaChua=false;
bool glbDaVaoLenhTheoVungGiaKichHoatChua=false;
CCustomBot glbBotTelegram;
string glbMessages="";

static datetime _LastBar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      glbSlippage=inpSlippage;
      glbLoiNhuanLenhCoSoCoTheDatDuoc=MarketInfo(Symbol(),MODE_TICKVALUE)*inpPointTPCoSo*inpKhoiLuongCoSo;
      // Kieem tra xem cos phai lenh vao teo vung gia
      // Neu vao theo vung gia thi cang canh stop, hay limit
      if(inpKieuBot==THEO_VUNG_GIA_TREN_DUOI||inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
      {
         if(inpGiaCanTren==0|| inpGiaCanDuoi==0)
         {
            Alert("VUNG GIA CAN TREN, CAN DUOI PHAI KHAC 0");
            return INIT_FAILED;
         }
         if(inpGiaCanTren<=inpGiaCanDuoi)
         {
            Alert("VUNG GIA CAN TREN PHAI LON HON CAN DUOI: DANG KHOI TAO SAI");
            return INIT_FAILED;
         }       
         if(inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
         {
            if(inpGiaKichHoat<inpGiaCanDuoi || inpGiaKichHoat>inpGiaCanTren)
            {
                Alert("Gia kich hoat lenh phai nam trong vung can tren, can duoi");
               return INIT_FAILED;
            }
            if(inpGiaKichHoat==0)
            {
                Alert("Gia kich hoat lenh phai >0");
               return INIT_FAILED;
            }
            if(inpLoaiLenh==LENH_BUY )// canh buy
            {
               if(Bid<inpGiaKichHoat)
               {
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_BUY_STOP;
               }
               else
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_BUY_LIMIT;
            }
            else
            {
               if(Bid>inpGiaKichHoat)
               {
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_SELL_STOP;
               }
               else glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_SELL_LIMIT;
            }
         }       
      }
     // FunKhoiTaoBanDauChoBotNhanCacLenh();
      if(glbTongSoLenh==0)// Chua co lenh nao
      {
         if(inpKieuBot==THEO_VUNG_GIA_TREN_DUOI)
         {
            if(Bid <inpGiaCanDuoi || Bid >inpGiaCanTren)
            {
               Alert("GIA THI TRUONG PHAI NAM TRONG VUNG GIA CAN TREN, CAN DUOI ");
               return INIT_FAILED;
            }
         }
         if(inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
         {                   
            if(inpLoaiLenh==LENH_BUY )// canh buy
            {
               if(Bid<inpGiaKichHoat)
               {
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_BUY_STOP;
               }
               else
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_BUY_LIMIT;
            }
            else
            {
               if(Bid>inpGiaKichHoat)
               {
                  glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_SELL_STOP;
               }
               else glbKieuCanhLenhVaoTheoGiaKichHoat=CANH_SELL_LIMIT;
            }
         } 
          glbDaVuotQuaVungGiaVaoLenh=false;
          glbDaDatDuocLoiNhuanToiDaChua=false;
          glbTongLoiLoCuaTatCaCacChuKy=0;
          glbDaVaoLenhTheoVungGiaKichHoatChua=false;
          FunReset();      
      }
      else // dang co lenh
      {
          if(inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
            glbDaVaoLenhTheoVungGiaKichHoatChua=true;
      }
       
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
      if(inpKieuBot==THEO_VUNG_GIA_TREN_DUOI)
      {
         if(glbDaVuotQuaVungGiaVaoLenh==false)
            glbDaVuotQuaVungGiaVaoLenh=FunKiemTraDaVuotQuaVungGiaVaoLenh();
         if(glbDaVuotQuaVungGiaVaoLenh && glbTongSoLenh==0)
         {
            Comment("Bot da vuot qua vung gia canh vao lenh. Khong cho phep vao lenh dau tien");
            return;
         }   
      }
      else if(inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
      {
         if(glbDaVaoLenhTheoVungGiaKichHoatChua==true)
         {
            if(glbDaVuotQuaVungGiaVaoLenh==false)
               glbDaVuotQuaVungGiaVaoLenh=FunKiemTraDaVuotQuaVungGiaVaoLenh();
         } 
         if(glbDaVuotQuaVungGiaVaoLenh && glbTongSoLenh==0)
         {
            Comment("Bot da vuot qua vung gia canh vao lenh. Khong cho phep vao lenh dau tien");
            return;
         }     
      }
      
      if(glbTongSoLenh==0)
      {
         
         if(inpTongLoiNhuanToiDaTatCacCacChuKy>0&&glbDaDatDuocLoiNhuanToiDaChua==true)
         {
            Comment("Bot da dat duoc loi nhuan toi da. Khong vao lenh nua");
            glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nBOT DA DAT LOI NHUAN TOI DA. DUNG (STOP) VAO LENH",Symbol()));
            return;
         }
         if(FunKiemTraGioVaoLenh()==false)// Chua den gio vao lenh
         {
            Comment(StringFormat("Chua toi gio vao lenh.\nGio vao lenh:%0.2f-%0.2f (Tinh theo gio Server)",inpStartTime, inpEndTime));
            return;
         }
         Comment("Doi lenh dau tien");
         if(glbDaVaoLenhTheoVungGiaKichHoatChua==false && inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
         {
            // VAO LENH KHI GIA CHAM VUNG KICH HOAT
            if(inpLoaiLenh==OP_BUY)
            {
               if((glbKieuCanhLenhVaoTheoGiaKichHoat==CANH_BUY_LIMIT && Bid<=inpGiaKichHoat)|| (glbKieuCanhLenhVaoTheoGiaKichHoat==CANH_BUY_STOP && Bid>=inpGiaKichHoat))
               {
                  FunXuLyVaoLenhDauTien(inpLoaiLenh);
                  if(glbTongSoLenh>0)
                     glbDaVaoLenhTheoVungGiaKichHoatChua=true;
                  return;
               }
                  
            }
            else
            {
               if((glbKieuCanhLenhVaoTheoGiaKichHoat==CANH_SELL_LIMIT && Bid>=inpGiaKichHoat)|| (glbKieuCanhLenhVaoTheoGiaKichHoat==CANH_SELL_STOP && Bid<=inpGiaKichHoat))
               {
                  FunXuLyVaoLenhDauTien(inpLoaiLenh);
                  if(glbTongSoLenh>0)
                     glbDaVaoLenhTheoVungGiaKichHoatChua=true;
                  return;
               }
            }
         }
         if(FunKiemTraSangNenMoiChua())
         {
            if(inpKieuBot==THEO_VUNG_GIA_KICH_HOAT)
            {
               if(glbDaVaoLenhTheoVungGiaKichHoatChua==true)
                   FunXuLyVaoLenhDauTien(inpLoaiLenh);
            }
            else if(inpKieuBot==THEO_VUNG_GIA_TREN_DUOI)
            {
               if(Bid>=inpGiaCanDuoi&& Bid<=inpGiaCanTren)
                  FunXuLyVaoLenhDauTien(inpLoaiLenh);
            }
            else FunXuLyVaoLenhDauTien(inpLoaiLenh);           
         }
      }
      else// Tong so lenh dang >0
      {
         if(glbLenhLimit>0)
         {
            if(OrderSelect(glbLenhLimit,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==OP_BUY|| OrderType()==OP_SELL)// Lenh limit da hit
               {
                  glbTapLenh[glbTongSoLenh]=glbLenhLimit;
                  glbTongSoLenh++;
                  if(glbTongSoLenh==inpSoLenhChoPhepHedge)
                  {
                     FunXuLyHedge(OrderType());
                     glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nXUAT HIEN HEDGING.\n Tong So lenh hien tai: %d",Symbol(),glbTongSoLenh));
                     ExpertRemove();
                     return;
                  }
                  FunCapNhatDiemTPSL(inpLoaiLenh,glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc,inpTongLoToiDaMotChuKy);
                  glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLENH LIMIT DA KHOP LENH.\n Tong So lenh hien tai: %d",Symbol(),glbTongSoLenh));
                  glbLenhLimit=FunXuLyVaoLenhCho();
                  
               }
            }
         }
         FunKiemTraDongLenhBangTay();// Neu cso 1 lenh dong, dong tat ca cac lenh con lai
         FunKiemTraDongLenhTheoLoiNhuanCuaChuKy();   // Đạt đủ lợi nhuận sẽ đóng lệnh
         // Khi gia da vuot qua vung gia vao lenh, Hoa von se cat het tat ca cac lenh
         if(inpKieuBot!=TU_DONG&& glbDaVuotQuaVungGiaVaoLenh==true && FunTinhTongLoiLoHienTai()>0)FunDongTatCaCacLenh();
         string TinHienThi=StringFormat("Tong so lenh:%d\n",glbTongSoLenh);
         TinHienThi+=StringFormat("Tong so lenh toi da cho phep:%d\n",inpTongSoLenhToiDa);
         TinHienThi+= StringFormat("Tong loi lo hien tai:%0.2f\n",FunTinhTongLoiLoHienTai());
         TinHienThi+= StringFormat("Loi nhuan toi da cho phep cua chu ky:%0.2f\n",glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc);
         TinHienThi+= StringFormat("Tong Lo Toi Da Cho Phep cua chu ky hien tai:%0.2f\n",inpTongLoToiDaMotChuKy);
         TinHienThi+= StringFormat("Tong Loi Nhuan cua tat cac cac chu ky truoc:%0.2f\nTong lo toi da cua tat cac cac chu ky:%0.2f",glbTongLoiLoCuaTatCaCacChuKy,inpTongLoiNhuanToiDaTatCacCacChuKy);         
         Comment(TinHienThi);  
      }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraDaVuotQuaVungGiaVaoLenh()
{
   if(Bid>inpGiaCanTren) return true;
   if(Bid<inpGiaCanDuoi) return true;
   return false;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunXuLyHedge(int LoaiLenhDangQuanLy)
{
   // Vao lenh hedge
   double Lots=FunTingTongSoLotHienTai();
   int ticket=-1;
   while(ticket==-1)
   {
      if(LoaiLenhDangQuanLy==OP_BUY) ticket=FunVaoLenh(OP_SELL,Bid,0,0,Lots);
      else ticket=FunVaoLenh(OP_BUY,Ask,0,0,Lots);
   }
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,clrNONE);
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraDongLenhTheoLoiNhuanCuaChuKy()
{
   double LoiNhuanCuaChuKyHienTai=FunTinhTongLoiLoHienTai();
   double LaiChoPhep=glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc;
   // Kkhi loi nhuan lo toi muc cho phep: Dong tat ca cac lenh
   if(LoiNhuanCuaChuKyHienTai<0 && MathAbs(LoiNhuanCuaChuKyHienTai)>=inpTongLoToiDaMotChuKy && inpTongLoToiDaMotChuKy>0)
      FunDongTatCaCacLenh();
   // Khi tong loi nhuan cua tat cac cac chu ky dat muc cho phep, dong tat ca cac lenh, khong cho phep vao lenh moi
   if((glbTongLoiLoCuaTatCaCacChuKy+LoiNhuanCuaChuKyHienTai)>0 && (glbTongLoiLoCuaTatCaCacChuKy+LoiNhuanCuaChuKyHienTai)>=inpTongLoiNhuanToiDaTatCacCacChuKy && inpTongLoiNhuanToiDaTatCacCacChuKy>0)
   {
      FunDongTatCaCacLenh();
      glbDaDatDuocLoiNhuanToiDaChua=true;
   }  
   // Khi loi nhuan dat muc cho phep dong tat cac cac lenh
   if(LoiNhuanCuaChuKyHienTai>0 && LoiNhuanCuaChuKyHienTai>=LaiChoPhep && LaiChoPhep>0)
      FunDongTatCaCacLenh(); 
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunTinhTongLoiLoHienTai()
{
   double TongLoiLo=0;
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
         TongLoiLo+=OrderProfit()+OrderSwap()+OrderCommission();
   }
   return TongLoiLo;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunTingTongSoLotHienTai()
{
   double TongSoLot=0;
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
         TongSoLot+=OrderLots();
   }
   return TongSoLot;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunXuLyVaoLenhDauTien(ENUM_LOAI_LENH LoaiLenhVao)
{
   double DiemVaoLenh,StopLoss=0, TakeProfit=0, KhoiLuongVaoLenh;
   ENUM_ORDER_TYPE LoaiLenh;
   int  Ticket=-1;
   
   if(LoaiLenhVao==LENH_BUY)
   {
      if(Ask>inpVungGiaTPToanBoLenh && inpVungGiaTPToanBoLenh>0)
      {
         Print("KHONG VAO LENH BUY DAU TIEN DO GIA VUOT QUA VUNG GIA TP TOAN BO LENH");
         return;
      }
      LoaiLenh=OP_BUY;
      DiemVaoLenh=Ask;
      StopLoss=inpVungGiaSLToanBoLenh;
      TakeProfit=Ask+inpPointTPCoSo*Point();
      if(TakeProfit>inpVungGiaTPToanBoLenh && inpVungGiaTPToanBoLenh>0) TakeProfit=inpVungGiaTPToanBoLenh;
      
   }
   else
   {
      if(Bid<inpVungGiaTPToanBoLenh)
      {
         Print("KHONG VAO LENH SELL DAU TIEN DO GIA VUOT QUA VUNG GIA TP TOAN BO LENH");
         return;
      }
      LoaiLenh=OP_SELL;
      DiemVaoLenh=Bid;
      StopLoss=inpVungGiaSLToanBoLenh;
      TakeProfit=Bid-inpPointTPCoSo*Point();
      if(TakeProfit<inpVungGiaTPToanBoLenh) TakeProfit=inpVungGiaTPToanBoLenh;
   }
   KhoiLuongVaoLenh=inpKhoiLuongCoSo;
   Ticket=FunVaoLenh(LoaiLenh,DiemVaoLenh,StopLoss,TakeProfit,KhoiLuongVaoLenh);
   if(Ticket>0)
   {
      glbTapLenh[glbTongSoLenh]=Ticket;
      glbTongSoLenh++;
      glbGiaVaoLenhCoSo=DiemVaoLenh;
      string s=StringFormat("Cap tien: %s\nMO LENH DAU TIEN: %s\nTicket: %d\nDIEM VAO LENH: %f\nSTOPLOSS: %f\nTAKE PROFIT: %f",Symbol(),FunTraVeTenLenh(LoaiLenh),Ticket,NormalizeDouble(DiemVaoLenh,Digits),NormalizeDouble(StopLoss,Digits), NormalizeDouble(TakeProfit,Digits));
      glbBotTelegram.SendMessage(inpChannelName,s);
      glbLenhLimit=FunXuLyVaoLenhCho();    
   }   
   else
   {
      Print("Cap tien:", OrderSymbol()," Vao lenh dau tien bi loi. Diem vao lenh: ", DiemVaoLenh, " StopLoss: ", StopLoss, " TakeProfit: ",TakeProfit);
      Comment("Vao lenh dau tien bi loi. Diem vao lenh: ", DiemVaoLenh, " StopLoss: ", StopLoss, " TakeProfit: ",TakeProfit);
      glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nMO LENH DAU TIEN BI LOI", Symbol()));
      ExpertRemove();
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int FunXuLyVaoLenhCho()
{
    int TicketLenhCho=-1;
    double DiemVaoLenh,StopLoss=0, TakeProfit=0, KhoiLuongVaoLenh;
    ENUM_ORDER_TYPE LoaiLenh;
    if(glbTongSoLenh>0)
    {
       if(glbTongSoLenh>=inpTongSoLenhToiDa) 
       {
         Print(Symbol(),":KHONG VAO LENH LIMIT. DO DA DAT SO LENH TOI DA");
         return -1;
       }
       if(inpLoaiLenh==LENH_BUY) 
       {
         LoaiLenh=OP_BUYLIMIT;
         // Neu Tong so lenh dang co < xlenh, khoang cach nhoi lenh duoc giu nguyen
         // Neu tong so lenh dang co >x lenh, khoang cach nhoi lenh duoc nhan them voi 1 he so
         if((glbTongSoLenh)<inpSoLenhGiuNguyenKhoangCanhNhoi)
            DiemVaoLenh=glbGiaVaoLenhCoSo-glbTongSoLenh*inpKhoangCachNhoiLenh*Point();
         else 
         {
            double TongHeSo=0;
            for(int i=1; i<=(glbTongSoLenh-inpSoLenhGiuNguyenKhoangCanhNhoi+1);i++)
               TongHeSo+=MathPow(inpHeSoKhoangCachNhoiLenh,i);
            DiemVaoLenh=glbGiaVaoLenhCoSo-(inpSoLenhGiuNguyenKhoangCanhNhoi-1)*inpKhoangCachNhoiLenh*Point()-TongHeSo*inpKhoangCachNhoiLenh*Point();
         }
         StopLoss=inpVungGiaSLToanBoLenh;
         KhoiLuongVaoLenh=MathPow(inpHeSoNhanKhoiLuongLenh,glbTongSoLenh)*inpKhoiLuongCoSo;
         KhoiLuongVaoLenh=FunLamTronKhoiLuongVaoLenh(KhoiLuongVaoLenh);
         
         if(inpVungGiaKhongChoPhepNhoiLenh>0 && DiemVaoLenh<inpVungGiaKhongChoPhepNhoiLenh)
         {
            Print(Symbol(),":KHONG VAO LENH LIMIT. DO DIEM VAO LENH VUOT QUA VUNG GIA CHO PHEP");
            return -1;
        }
       }
       else
       {
         LoaiLenh=OP_SELLLIMIT;
         if((glbTongSoLenh)<inpSoLenhGiuNguyenKhoangCanhNhoi)
            DiemVaoLenh=glbGiaVaoLenhCoSo+glbTongSoLenh*inpKhoangCachNhoiLenh*Point();
         else 
         {
            double TongHeSo=0;
            for(int i=1; i<=(glbTongSoLenh-inpSoLenhGiuNguyenKhoangCanhNhoi+1);i++)
               TongHeSo+=MathPow(inpHeSoKhoangCachNhoiLenh,i);
            DiemVaoLenh=glbGiaVaoLenhCoSo+(inpSoLenhGiuNguyenKhoangCanhNhoi-1)*inpKhoangCachNhoiLenh*Point()+TongHeSo*inpKhoangCachNhoiLenh*Point();
         }   
         
         StopLoss=inpVungGiaSLToanBoLenh;
         KhoiLuongVaoLenh=MathPow(inpHeSoNhanKhoiLuongLenh,glbTongSoLenh)*inpKhoiLuongCoSo;
         KhoiLuongVaoLenh=FunLamTronKhoiLuongVaoLenh(KhoiLuongVaoLenh);
         if(inpVungGiaKhongChoPhepNhoiLenh>0 && DiemVaoLenh>inpVungGiaKhongChoPhepNhoiLenh)
         {
            Print(Symbol(),":KHONG VAO LENH LIMIT. DO DIEM VAO LENH VUOT QUA VUNG GIA CHO PHEP");
            return -1;
         }
       }
       if(inpVungGiaTPToanBoLenh>0) TakeProfit=inpVungGiaTPToanBoLenh;
       TicketLenhCho=FunVaoLenhCho(KhoiLuongVaoLenh,DiemVaoLenh,LoaiLenh,TakeProfit,StopLoss);
       if(TicketLenhCho<=0)
       {
         Print(Symbol(),":Vao lenh cho bi loi. Gia vao lenh:",DiemVaoLenh, " SL:",StopLoss, "TP: ",TakeProfit, " Khoi luong: ",KhoiLuongVaoLenh);
       }
       else
       {
         string s=StringFormat("Cap tien: %s\nMO LENH CHO: %s\nTicket: %d\nDIEM VAO LENH: %f\nSTOPLOSS: %f\nTAKE PROFIT: %f",Symbol(), FunTraVeTenLenh(LoaiLenh),TicketLenhCho,NormalizeDouble(DiemVaoLenh,Digits),NormalizeDouble(StopLoss,Digits), NormalizeDouble(TakeProfit,Digits));
         glbBotTelegram.SendMessage(inpChannelName,s);
       }
    }
    return TicketLenhCho;
}

//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLoss, double TakeProfit, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
         
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,NormalizeDouble(DiemVaoLenh,Digits),glbSlippage,NormalizeDouble(StopLoss,Digits),NormalizeDouble(TakeProfit,Digits),"EA",glbMagic,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,NormalizeDouble(DiemVaoLenh,Digits),glbSlippage,NormalizeDouble(StopLoss,Digits),NormalizeDouble(TakeProfit,Digits),"EA",glbMagic,0,clrRed);
    }
    return Ticket;
}
//---------------------------------Tinh khoi luong vao lenh-----------------------------------------
double FunTinhKhoiLuongVaoLenh(double stoploss, double diemvaolenh, double PhanTramRuiRo)
{
   double SoTienRuiRo=PhanTramRuiRo*AccountBalance()/100;
   if(SoTienRuiRo>0)
   {
      double point=MathAbs(stoploss-diemvaolenh)/Point();
      
      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
      //Print("So nTickValue:",nTickValue);
      double TongLoChoPhep=SoTienRuiRo;
      double khoiluongvaolenh=TongLoChoPhep/(point*nTickValue);
      khoiluongvaolenh=FunLamTronKhoiLuongVaoLenh(khoiluongvaolenh);
     // Print("Khoi luong vao lenh: ",khoiluongvaolenh);
      return khoiluongvaolenh;
   }
   else return 0;
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunLamTronKhoiLuongVaoLenh(double KhoiLuong)
{
   double LotSize=KhoiLuong;
   //--- LotSize rounded regarding Broker LOTSTEP
    if(MarketInfo(Symbol(),MODE_LOTSTEP)==1)
    {
      LotSize=NormalizeDouble(LotSize,0);
      if(LotSize<1) LotSize=1;
    }
    if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
    {
      LotSize=NormalizeDouble(LotSize,1);
      if(LotSize<0.1) LotSize=0.1;
    }
    if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)
    {
      LotSize=NormalizeDouble(LotSize,2);
      if(LotSize<0.01) LotSize=0.01;
    }
    if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.001)
    {
      LotSize=NormalizeDouble(LotSize,3);
      if(LotSize<0.001) LotSize=0.001;
    }
    return LotSize;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChua()
 {
   //static datetime _LastBar;
   datetime currBar=Time[0];//iTime(OrderSymbol(),0,0);
   //Print("Last bar:", _LastBar, " Curr bar: ",currBar);
   if(_LastBar!=currBar)
   {
      _LastBar=currBar;
      return true;
   }
   else return false;
 }
 //+------------------------------------------------------------------+
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

void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
            string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
            glbBotTelegram.SendMessage(inpChannelName,s);
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
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
                  string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d \nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
                  glbBotTelegram.SendMessage(inpChannelName,s);
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
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap(); 
                  string s=StringFormat("Cap tien: %s\nDONG LENH %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderOpenPrice(),OrderProfit());
                  glbBotTelegram.SendMessage(inpChannelName,s);   
              }
            }
         }
      }
   }
   while(glbLenhLimit>0)
   {
      if(OrderDelete(glbLenhLimit))
      {
         glbLenhLimit=-1;
          glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nXOA LENH LIMIT\nTicket: %d",Symbol(),glbLenhLimit));   
       }
   }
   _LastBar=Time[0];
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
bool FunKiemTraGioVaoLenh()
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(gio>=inpStartTime && gio<inpEndTime) return true;
   else return false;
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
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int FunVaoLenhCho(double KhoiLuong, double GiaVaoLenh,int LoaiLenh,double TakeProfit=0, double StopLoss=0)
 {
   int ticket=-1;
   double sl=NormalizeDouble(StopLoss,Digits);
   double tp=NormalizeDouble(TakeProfit,Digits);
   KhoiLuong=FunLamTronKhoiLuongVaoLenh(KhoiLuong);
   if(LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
   {
      ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuong,NormalizeDouble(GiaVaoLenh,Digits),glbSlippage,sl,tp,"EA",glbMagic,0,clrNONE);
   }
   else if(LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
   {
      ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuong,NormalizeDouble(GiaVaoLenh,Digits),glbSlippage,sl,tp,"EA",glbMagic,0,clrNONE);
   }
   return ticket;
   
 }
 
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
 void FunReset()
 {
   glbTongSoLenh=0;
   ArrayFill(glbTapLenh,0,200,-1);
   glbLenhLimit=-1;
   glbGiaVaoLenhCoSo=0;
   glbTongLoiNhuanCanDatDeDongLenh=0;
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
 
 
 void FunKhoiTaoBanDauChoBotNhanCacLenh()
 {
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==glbMagic)
         {
            if(OrderType()==OP_BUY ||OrderType()==OP_SELL)
            {
               glbTapLenh[glbTongSoLenh]=OrderTicket();
               glbTongSoLenh++;
            }
            else glbLenhLimit=OrderTicket();
         }
      }
   }
}


//+------------------------------------------------------------------+
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
      for(int i=0;i<glbTongSoLenh;i++)
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
         for(int i=0;i<glbTongSoLenh;i++)
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
      for(int i=0;i<glbTongSoLenh;i++)
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
         for(int i=0;i<glbTongSoLenh;i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,DiemDongTatCaCacLenhTP,0,clrNONE);
            //OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,OrderTakeProfit(),0,clrNONE);
         }
      }
      
   }
}