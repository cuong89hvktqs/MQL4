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
// cos 2 kieu vao lenh: vao khi khung thoi gian nho bat dau dao trend chuyen sang cung trend voi khung lon
// C2: vao khi het cay nen, trend khung nho cung trend voi khung lon
enum ENUM_KIEU_VAO_LENH
{
   TF_NHO_DAO_TREND,
   TF_NHO_DANG_CUNG_TREND
};
enum ENUM_BOT
{
   TU_DONG,
   THEO_VUNG_GIA_TREN_DUOI,
   THEO_VUNG_GIA_KICH_HOAT 
};
enum ENUM_XU_HUONG
{
   XU_HUONG_TANG,
   XU_HUONG_GIAM
};
enum ENUM_LOAI_LENH
{
   LENH_BUY,
   LENH_SELL
};
enum ENUM_TINH_KHOI_LUONG
{
   THEO_PHAN_TRAM,
   THEO_LOTS
};
// Khung thoi gian vao lenh dao trend, cung trend voi khung thoi gian so sanh, va 02 khung thoi gian tham chieu
//input ENUM_TIMEFRAMES inpTFKhungThamChieu1=PERIOD_D1;// Khung thoi gian tham chieu 1:
//input ENUM_TIMEFRAMES inpTFKhungThamChieu2=PERIOD_H4;// Khung thoi gian tham chieu 2:
input ENUM_TIMEFRAMES inpTFKhungLon=PERIOD_H1;// Khung thoi gian so sanh (Lon hon khung thoi gian vao lenh):
input ENUM_TIMEFRAMES inpTFKhungNho=PERIOD_H1;// Khung thoi gian vao lenh:
input ENUM_KIEU_VAO_LENH inpKieuVaoLenh=TF_NHO_DAO_TREND;// Kieu vao lenh:
input int inpSoPointChoHoiVeTruocKhiVaoLenh=0;// So points cho hoi ve truoc khi vao lenh(=0: vao lenh luon):
input int inpSoNenChoDoiChoLenhLimit=0;//  Sau x nen gia khong hoi ve thi khong vao lenh nua:
input string inpThongSo="THONG SO CHO LENH DAU TIEN";//THONG SO: 
input double inpKhoiLuongCoSo=0.1; // Khoi luong lenh dau tien (lots >0):
input double inpRuiRoMotLenh=1;//Phan tram rui ro mot lenh (%)
input double inpPointTPCoSo=200;// Diem TP lenh dau tien (Points):
input double inpPointSLCoSo=200;// Diem SL lenh (Points):
input double inpSoPointKichHoatDichVeHoaVon=0;// SO point dat duoc khi kich hoat Dich SL ve hoa von voi lenh dau tien (=0: Khong dich):
input double inpSoPointMongMuonDeDuocHoaVon=0;// SO point mong muon se duoc hoa von (>0):

input double inpStartTime=0;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=24;// Thoi Gian Ket Thuc vao lenh(Server time):
input int inpSlippage=50;// Do truot gia (slippage):

input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1735772983:AAG4g3Qem_oGQN3bpTmztuLHiT67bQCsXWs";//Ma Token bot Telegram:
input string    inpSuperTrend_Name="xSuperTrend.ex4";      // Ten indicator supertrend:
input int    inpSuperTrend_Period=10;      // SuperTrend ATR Period
input double inpSuperTrend_Multiplier=3; // SuperTrend Multiplier
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={15,01,3022};
int glbTongSoLenh=0;
int glbLoaiLenhDangVao=-1;
int glbTapLenh[200];
int glbLenhLimit=-1;
int glbSlippage=50;
int glbMagic=12345;
double glbLoiNhuanLenhCoSoCoTheDatDuoc=0;
bool glbKhungLonDaDaoTrendChua=false;
int glbDemNenChoVaoLenhDauTien=0;
CCustomBot glbBotTelegram;
string glbMessages="";

static datetime _LastBar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      
      if(IsDemo()==false && FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      glbSlippage=inpSlippage;
      glbLoiNhuanLenhCoSoCoTheDatDuoc=MarketInfo(Symbol(),MODE_TICKVALUE)*inpPointTPCoSo*inpKhoiLuongCoSo;
     // FunKhoiTaoBanDauChoBotNhanCacLenh();
      if(glbTongSoLenh==0)// Chua co lenh nao
      {   
          FunReset();      
      }
       if(inpSoPointChoHoiVeTruocKhiVaoLenh>0)
       {
         if(inpSoNenChoDoiChoLenhLimit<=0)
         {
            Alert("So Point cho hoi ve de vao lenh >0 thi so nen cho doi cung phai >0");
            return INIT_FAILED;
         }   
       }
       if(inpSoPointChoHoiVeTruocKhiVaoLenh>0 && inpSoPointChoHoiVeTruocKhiVaoLenh<=MarketInfo(Symbol(), MODE_SPREAD))
       {
          Alert("So Point cho hoi ve de vao lenh phai > SPREAD");
          return INIT_FAILED;
       }     
     // glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
    // glbBotTelegram.SendMessage(inpChannelName,msgTele);
      
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
      // Khung lon hon va doi trend thi rest tong loi nhuan cua tat ca cac chu ky=0;
      if(FunKiemTraSangNenMoiChuaKhungLonHon()==true)
      {
         Print("Xu huong khung Lon:",FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon)));
         if(FunXacDinhXuHuongCuaSuperTrend(inpTFKhungLon,1)!=FunXacDinhXuHuongCuaSuperTrend(inpTFKhungLon,2))
         {
            Print("KHUNG LON DAO CHIEU");
         }
      }
    
      //========================================================================================================================//
      if(glbTongSoLenh==0 && glbLenhLimit>0)// dang canh vao lenh limit dau tien
      {
         if(OrderSelect(glbLenhLimit,SELECT_BY_TICKET,MODE_TRADES))
         {
               if(OrderType()==OP_BUY|| OrderType()==OP_SELL)// Lenh limit da hit
               {
                  glbTapLenh[glbTongSoLenh]=glbLenhLimit;
                  glbTongSoLenh++;
                  glbLoaiLenhDangVao=OrderType();
                  string s=StringFormat("Cap tien: %s\nMO LENH DAU TIEN: %s\nTicket: %d\nDIEM VAO LENH: %f\nSTOPLOSS: %f\nTAKE PROFIT: %f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),NormalizeDouble(OrderOpenPrice(),Digits),NormalizeDouble(OrderStopLoss(),Digits), NormalizeDouble(OrderTakeProfit(),Digits));
                  //FunCapNhatDiemTPSL(glbLoaiLenhDangVao,glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc,inpTongLoToiDaMotChuKy);
                 // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLENH LIMIT DA KHOP LENH.\n Tong So lenh hien tai: %d",Symbol(),glbTongSoLenh));
                   return; 
               }
              else
              {
               // XU huong da doi, xoa lenh limit
                  if(OrderType()==OP_BUYLIMIT && FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho)==XU_HUONG_TANG)// Tredn xu huong lon tang, xu huong nho tang vao lenh SELL
                  {
                     Print("XOA LENH LIMTI DO KHUNG HIEN TAI XU HUONG DA DOI TREND");
                     OrderDelete(glbLenhLimit,clrNONE);
                     glbLenhLimit=-1;
                  }
                   if(OrderType()==OP_SELLLIMIT && FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho)==XU_HUONG_GIAM)// Tredn xu huong lon giam, xu huong nho giam vao lenh BUY
                  {
                     Print("XOA LENH LIMTI DO KHUNG HIEN TAI XU HUONG DA DOI TREND");
                     OrderDelete(glbLenhLimit,clrNONE);
                     glbLenhLimit=-1;
                  }
              }
         }
         if(FunKiemTraSangNenMoiChua()==true)
         {
            glbDemNenChoVaoLenhDauTien++;
            if(glbDemNenChoVaoLenhDauTien>=inpSoNenChoDoiChoLenhLimit && inpSoNenChoDoiChoLenhLimit>0)
            {
               Print("XOA LENH LIMTI DO VUOT QUA SO NEN CANH LENH LIMIT CHO PHEP");
               if(OrderDelete(glbLenhLimit,clrNONE))
                  glbLenhLimit=-1;
            }       
         }
         Comment("DANG CANH LENH LIMIT DAU TIEN KHI DAO TREND\nSo nen canh toi da: ",inpSoNenChoDoiChoLenhLimit,"\nSo nen da canh: ",glbDemNenChoVaoLenhDauTien);
      }
      
      //========================================================================================================================//
      if(glbTongSoLenh==0 && glbLenhLimit==-1)// Chua co lenh nao, cung chua canh lenhlimit nao
      {
         
         
         if(FunKiemTraGioVaoLenh()==false)// Chua den gio vao lenh
         {
            Comment(StringFormat("Chua toi gio vao lenh.\nGio vao lenh:%0.2f-%0.2f (Tinh theo gio Server)",inpStartTime, inpEndTime));
            return;
         }
         string TinHienThi="";
        // TinHienThi+="XU HUONG KHUNG THOI GIAN THAM CHIEU 1 "+FunHienThiTenKhungThoiGian(inpTFKhungThamChieu1)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungThamChieu1));
        // TinHienThi+="\nXU HUONG KHUNG THOI GIAN THAM CHIEU 2 "+FunHienThiTenKhungThoiGian(inpTFKhungThamChieu2)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungThamChieu2));
         TinHienThi+="\nXU HUONG KHUNG THOI GIAN LON "+FunHienThiTenKhungThoiGian(inpTFKhungLon)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon));
         TinHienThi+="\nXU HUONG KHUNG THOI GIAN NHO "+FunHienThiTenKhungThoiGian(inpTFKhungNho)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho));
         TinHienThi+="\nDoi lenh dau tien";
         Comment(TinHienThi);
         
         if(FunKiemTraSangNenMoiChua())
         { 
           if(inpKieuVaoLenh==TF_NHO_DAO_TREND)
           {
             
              // XU huong lon giam, xu huong nho chuyn tu tang sang giam, vao lenh mua
              if(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon)==XU_HUONG_GIAM && FunKiemTraDaoTrendChua(inpTFKhungNho)==-1)
              {
                  //  Print("CO DAO TREND");
                   if(inpSoPointChoHoiVeTruocKhiVaoLenh<=0)// Val enh luon khong can cho hoi ve
                   {
                     FunXuLyVaoLenhDauTien(OP_BUY); 
                     glbLoaiLenhDangVao=OP_BUY;
                   }
                   else
                   {
                     glbLenhLimit=OrderSend(Symbol(),OP_BUYLIMIT,FunTinhKhoiLuongVaoLenh(),Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point(),glbSlippage,Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point()+inpPointSLCoSo*Point(),Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point()-inpPointTPCoSo*Point(),"EA",glbMagic,0,clrNONE);
                     glbDemNenChoVaoLenhDauTien=0;
                     if(glbLenhLimit<0)
                     {
                        Print("LOI VAO LENH LIMIT DAU TIEN");
                        Alert("LOI VAO LENH LIMIT DAU TIEN");
                     }
                   } 
                   return;          
              }
              // XU huong lon tang, xu huong nho chuyen tu giam sang tang, vao lenh ban
              if(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon)==XU_HUONG_TANG && FunKiemTraDaoTrendChua(inpTFKhungNho)==1)
              {
                  // Print("CO DAO TREND");
                  if(inpSoPointChoHoiVeTruocKhiVaoLenh<=0)// Val enh luon khong can cho hoi ve
                  {
                   FunXuLyVaoLenhDauTien(OP_SELL);  
                   glbLoaiLenhDangVao=OP_SELL;  
                  }
                  else
                  {
                     glbLenhLimit=OrderSend(Symbol(),OP_SELLLIMIT,FunTinhKhoiLuongVaoLenh(),Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point(),glbSlippage,Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point()-inpPointSLCoSo*Point(),Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point()+inpPointTPCoSo*Point(),"EA",glbMagic,0,clrNONE);
                     glbDemNenChoVaoLenhDauTien=0;
                     if(glbLenhLimit<0)
                     {
                        Print("LOI VAO LENH LIMIT DAU TIEN");
                        Alert("LOI VAO LENH LIMIT DAU TIEN");
                     }
                  }
                   return;       
              } 
           }
            else // TIME fram nho dang cung trend
            {
               // XU huong lon giam, xu huong nho giam vao buy
              if(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon)==XU_HUONG_GIAM  && FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho)==XU_HUONG_GIAM)
              {
                   if(inpSoPointChoHoiVeTruocKhiVaoLenh<=0)// Val enh luon khong can cho hoi ve
                   {
                     FunXuLyVaoLenhDauTien(OP_BUY); 
                     glbLoaiLenhDangVao=OP_BUY;
                   }
                   else
                   {
                     glbLenhLimit=OrderSend(Symbol(),OP_BUYLIMIT,FunTinhKhoiLuongVaoLenh(),Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point(),glbSlippage,Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point()+inpPointSLCoSo*Point(),Bid+inpSoPointChoHoiVeTruocKhiVaoLenh*Point()-inpPointTPCoSo*Point(),"EA",glbMagic,0,clrNONE);
                     glbDemNenChoVaoLenhDauTien=0;
                     if(glbLenhLimit<0)
                     {
                        Print("LOI VAO LENH LIMIT DAU TIEN");
                        Alert("LOI VAO LENH LIMIT DAU TIEN");
                     }
                   } 
                   return;            
              }
              // XU huong lon tang, xu huong nho  tang vao sell
              if(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon)==XU_HUONG_TANG &&  FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho)==XU_HUONG_TANG)
              {
                    if(inpSoPointChoHoiVeTruocKhiVaoLenh<=0)// Val enh luon khong can cho hoi ve
                     {
                      FunXuLyVaoLenhDauTien(OP_SELL);  
                      glbLoaiLenhDangVao=OP_SELL;  
                     }
                     else
                     {
                        glbLenhLimit=OrderSend(Symbol(),OP_SELLLIMIT,FunTinhKhoiLuongVaoLenh(),Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point(),glbSlippage,Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point()-inpPointSLCoSo*Point(),Ask-inpSoPointChoHoiVeTruocKhiVaoLenh*Point()+inpPointTPCoSo*Point(),"EA",glbMagic,0,clrNONE);
                        glbDemNenChoVaoLenhDauTien=0;
                        if(glbLenhLimit<0)
                        {
                           Print("LOI VAO LENH LIMIT DAU TIEN");
                           Alert("LOI VAO LENH LIMIT DAU TIEN");
                        }
                     }
                      return;       
              } 
            }    
         }
      }
      //========================================================================================================================//
      if(glbTongSoLenh>0)// Tong so lenh dang >0 Dang co lenh
      {
         if(glbLenhLimit>0)
         {
            if(OrderSelect(glbLenhLimit,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==OP_BUY|| OrderType()==OP_SELL)// Lenh limit da hit
               {
                  glbTapLenh[glbTongSoLenh]=glbLenhLimit;
                  glbTongSoLenh++;
                 // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLENH LIMIT DA KHOP LENH.\n Tong So lenh hien tai: %d",Symbol(),glbTongSoLenh));
               }
            }
         }
         FunKiemTraDongLenhBangTay();// Neu cso 1 lenh dong, dong tat ca cac lenh con lai
         FunKiemTraDongLenhTheoLoiNhuanCuaChuKy();   // Đạt đủ lợi nhuận sẽ đóng lệnh   \
         
         // Kiem tra dich SL ve hoa von neu dang co 1 lenh va cham diem dich SL
         if(glbTongSoLenh==1)
         {
            if(inpSoPointKichHoatDichVeHoaVon>0) FunKiemTraDichSLVeHoaVon();
         }
         
         string TinHienThi="";
        // TinHienThi+="XU HUONG KHUNG THOI GIAN THAM CHIEU 1 "+FunHienThiTenKhungThoiGian(inpTFKhungThamChieu1)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungThamChieu1));
        // TinHienThi+="\nXU HUONG KHUNG THOI GIAN THAM CHIEU 2 "+FunHienThiTenKhungThoiGian(inpTFKhungThamChieu2)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungThamChieu2));
         TinHienThi+="\nXU HUONG KHUNG THOI GIAN LON "+FunHienThiTenKhungThoiGian(inpTFKhungLon)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungLon));
         TinHienThi+="\nXU HUONG KHUNG THOI GIAN NHO "+FunHienThiTenKhungThoiGian(inpTFKhungNho)+": "+FunHienThiTenXuHuongSupperTrend(FunXacDinhXuHuongHienTaiCuaSuperTrend(inpTFKhungNho))+"\n";
         if(glbKhungLonDaDaoTrendChua==true)
            TinHienThi+="\nKHUNG THOI GIAN LON DA DOI XU HUONG\n";
         TinHienThi+=StringFormat("Lenh hien tai:%s\n",FunTraVeTenLenh(glbLoaiLenhDangVao));
         TinHienThi+=StringFormat("Tong so lenh:%d\n",glbTongSoLenh);
         TinHienThi+= StringFormat("Tong loi lo hien tai:%0.2f\n",FunTinhTongLoiLoHienTai());
         TinHienThi+= StringFormat("Loi nhuan toi da cho phep cua chu ky:%0.2f\n",glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc);         
        // TinHienThi+= StringFormat("Tong Loi Nhuan toi da cho phep cua tat cac cac chu ky truoc:%0.2f\nTong lo toi da cho phep tat cac cac chu ky:%0.2f",inpTongLoiNhuanToiDaTatCacCacChuKy,-inpTongLoToiDaChoPhepTatCacCacChuKy);         
         Comment(TinHienThi);               
      }
      //========================================================================================================================//
      
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraDongLenhTheoLoiNhuanCuaChuKy()
{
   double LoiNhuanCuaChuKyHienTai=FunTinhTongLoiLoHienTai();
   double LaiChoPhep=glbTongSoLenh*glbLoiNhuanLenhCoSoCoTheDatDuoc;
   // Kkhi loi nhuan lo toi muc cho phep: Dong tat ca cac lenh
   // Khi tong loi nhuan cua tat cac cac chu ky dat muc cho phep, dong tat ca cac lenh, khong cho phep vao lenh moi
  
 
   // Khi loi nhuan dat muc cho phep dong tat cac cac lenh
   if(LoiNhuanCuaChuKyHienTai>0 && LoiNhuanCuaChuKyHienTai>=LaiChoPhep && LaiChoPhep>0)
   {
      Print("DONG TAT CA LENH DO VUOT QUA LOI NHUAN CHO PHEP CUA CHU KY HIEN TAI");
      FunDongTatCaCacLenh();
   }
      
   
   
}
void FunKiemTraDichSLVeHoaVon()
{
   if(OrderSelect(glbTapLenh[0],SELECT_BY_TICKET,MODE_TRADES))
   {
      //Print("Ticket=",OrderTicket(), " Loai lenh: ",OrderType());
      double GiaDichSLVeHoaVon=0;
      if(OrderType()==OP_BUY)
      {
        GiaDichSLVeHoaVon=OrderOpenPrice()+inpSoPointKichHoatDichVeHoaVon*Point();
        if(Bid>=GiaDichSLVeHoaVon && OrderStopLoss()<OrderOpenPrice())
        {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+inpSoPointMongMuonDeDuocHoaVon*Point(),OrderTakeProfit(),0,clrNONE))
            {
               if(OrderDelete(glbLenhLimit))
                  glbLenhLimit=-1;
            }
        }
        
      }
      else
      {
         
         GiaDichSLVeHoaVon=OrderOpenPrice()-inpSoPointKichHoatDichVeHoaVon*Point();
        if(Bid<=GiaDichSLVeHoaVon && ((OrderStopLoss()>OrderOpenPrice())||OrderStopLoss()==0))
        {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-inpSoPointMongMuonDeDuocHoaVon*Point(),OrderTakeProfit(),0,clrNONE))
            {
               if(OrderDelete(glbLenhLimit))
                  glbLenhLimit=-1;
            }
        }
      }
      
   }
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
void FunXuLyVaoLenhDauTien(ENUM_ORDER_TYPE LoaiLenhVao)
{
   double DiemVaoLenh,StopLoss=0, TakeProfit=0, KhoiLuongVaoLenh;
   ENUM_ORDER_TYPE LoaiLenh;
   int  Ticket=-1;
   
   if(LoaiLenhVao==OP_BUY)
   {
      LoaiLenh=OP_BUY;
      DiemVaoLenh=Ask;
      StopLoss=Ask-inpPointSLCoSo*Point();
      TakeProfit=Ask+inpPointTPCoSo*Point();
   }
   else
   {
      LoaiLenh=OP_SELL;
      DiemVaoLenh=Bid;
      StopLoss=Bid+inpPointSLCoSo*Point();
      TakeProfit=Bid-inpPointTPCoSo*Point();
   }
   KhoiLuongVaoLenh=FunTinhKhoiLuongVaoLenh();
   Ticket=FunVaoLenh(LoaiLenh,DiemVaoLenh,StopLoss,TakeProfit,KhoiLuongVaoLenh);
   if(Ticket>0)
   {
      glbTapLenh[glbTongSoLenh]=Ticket;
      glbTongSoLenh++;
      glbLoaiLenhDangVao=LoaiLenh;
      string s=StringFormat("Cap tien: %s\nMO LENH DAU TIEN: %s\nTicket: %d\nDIEM VAO LENH: %f\nSTOPLOSS: %f\nTAKE PROFIT: %f",Symbol(),FunTraVeTenLenh(LoaiLenh),Ticket,NormalizeDouble(DiemVaoLenh,Digits),NormalizeDouble(StopLoss,Digits), NormalizeDouble(TakeProfit,Digits));
     // glbBotTelegram.SendMessage(inpChannelName,s);    
   }   
   else
   {
      Print("Cap tien:", OrderSymbol()," Vao lenh dau tien bi loi. Diem vao lenh: ", DiemVaoLenh, " StopLoss: ", StopLoss, " TakeProfit: ",TakeProfit);
      Comment("Vao lenh dau tien bi loi. Diem vao lenh: ", DiemVaoLenh, " StopLoss: ", StopLoss, " TakeProfit: ",TakeProfit);
     // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nMO LENH DAU TIEN BI LOI", Symbol()));
      ExpertRemove();
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int FunKiemTraDaoTrendChua(ENUM_TIMEFRAMES TFKiemTra)// -1: da dao trend tang sang giam: 0: chua dao tren; 1: dao tren tu giam sang tang
{
   int mode_down=1,mode_up=2;
   int shift1=1,shift2=2;
   ENUM_XU_HUONG XuHuong1,XuHuong2;
   // Value: 1.039446 Down: 2147483647.0 Up: 1.039446
   double spt_value_down_shitf1=FunLayGiaTriSuperTrend( shift1, mode_down, TFKiemTra);
   double spt_value_up_shitf1=FunLayGiaTriSuperTrend( shift1, mode_up,TFKiemTra);
   if(spt_value_down_shitf1>spt_value_up_shitf1) XuHuong1=XU_HUONG_TANG;
   else XuHuong1=XU_HUONG_GIAM;
   
   
   double spt_value_down_shitf2=FunLayGiaTriSuperTrend( shift2, mode_down, TFKiemTra);
   double spt_value_up_shitf2=FunLayGiaTriSuperTrend( shift2, mode_up,TFKiemTra);
   if(spt_value_down_shitf2>spt_value_up_shitf2) XuHuong2=XU_HUONG_TANG;//Down: 2147483647.0 Up: 1.039446
   else XuHuong2=XU_HUONG_GIAM;
   
   if(XuHuong2!=XuHuong1)// Co dao trend
   {
      //Print("XUAT HIEN DAO TREND KHUNG THOI GIAN HIEN TAI");
      if(XuHuong2==XU_HUONG_TANG && XuHuong1==XU_HUONG_GIAM) return -1;// dao tu tang sang giam
      if(XuHuong2==XU_HUONG_GIAM && XuHuong1==XU_HUONG_TANG) return 1;
      else return 0;
   }
   else return 0;// Khog dao trend
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ENUM_XU_HUONG FunXacDinhXuHuongHienTaiCuaSuperTrend(ENUM_TIMEFRAMES TFKiemTra)
{
   int mode_down=1,mode_up=2;
   int shift1=1;
   ENUM_XU_HUONG XuHuong1;
   // Value: 1.039446 Down: 2147483647.0 Up: 1.039446
   double spt_value_down_shitf1=FunLayGiaTriSuperTrend( shift1, mode_down, TFKiemTra);
   double spt_value_up_shitf1=FunLayGiaTriSuperTrend( shift1, mode_up,TFKiemTra);
   if(spt_value_down_shitf1>spt_value_up_shitf1) XuHuong1=XU_HUONG_TANG;
   else XuHuong1=XU_HUONG_GIAM;
   return XuHuong1;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ENUM_XU_HUONG FunXacDinhXuHuongCuaSuperTrend(ENUM_TIMEFRAMES TFKiemTra, int shift)
{
   int mode_down=1,mode_up=2;
   ENUM_XU_HUONG XuHuong1;
   // Value: 1.039446 Down: 2147483647.0 Up: 1.039446
   double spt_value_down_shitf1=FunLayGiaTriSuperTrend( shift, mode_down, TFKiemTra);
   double spt_value_up_shitf1=FunLayGiaTriSuperTrend( shift, mode_up,TFKiemTra);
   if(spt_value_down_shitf1>spt_value_up_shitf1) XuHuong1=XU_HUONG_TANG;
   else XuHuong1=XU_HUONG_GIAM;
   return XuHuong1;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunLayGiaTriSuperTrend(int shift=1, int mode=0, ENUM_TIMEFRAMES tf=PERIOD_CURRENT)
{
   double spt_value=0;
   spt_value=iCustom(Symbol(),tf,inpSuperTrend_Name,"tailieuforex.com","--------------",inpSuperTrend_Period,inpSuperTrend_Multiplier,mode,shift);
   return NormalizeDouble(spt_value,Digits);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

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
 bool FunKiemTraSangNenMoiChuaKhungLonHon()
 {
   static datetime _LastBarKhungLon;
   datetime currBarKhungLon=iTime(Symbol(),inpTFKhungLon,0);//  Time[0];//iTime(OrderSymbol(),0,0);

   if(_LastBarKhungLon!=currBarKhungLon)
   {
      _LastBarKhungLon=currBarKhungLon;
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
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
            string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
            //glbBotTelegram.SendMessage(inpChannelName,s);
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");
                 // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLOI KHI DONG LENH BUY: ERROR",Symbol()));   
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d \nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
                 // glbBotTelegram.SendMessage(inpChannelName,s);
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");
                 // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\n LOI KHI DONG LENH SELL: ERROR",Symbol()));   
               }
               else 
               {  
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  string s=StringFormat("Cap tien: %s\nDONG LENH %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderOpenPrice(),OrderProfit());
                 // glbBotTelegram.SendMessage(inpChannelName,s);   
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
         // glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nXOA LENH LIMIT\nTicket: %d",Symbol(),glbLenhLimit));   
       }
       else
         glbLenhLimit=-1;
   }
   _LastBar=Time[0];
   FunReset();
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
   if(inpStartTime==0 && inpEndTime==0) return true;
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
   if(ticket<=0)
      Print(Symbol(),":Vao lenh cho bi loi. Gia vao lenh:",GiaVaoLenh, " SL:",sl, "TP: ",tp, " Khoi luong: ",KhoiLuong);
   return ticket;
   
 }
 
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
 void FunReset()
 {
   glbTongSoLenh=0;
   ArrayFill(glbTapLenh,0,200,-1);
   glbLenhLimit=-1;
   glbLoaiLenhDangVao=-1;
   glbKhungLonDaDaoTrendChua=false;
   glbDemNenChoVaoLenhDauTien=0;
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
         if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
         {
            TongComVaSwap+=OrderCommission()+OrderSwap();
            TongTheoGia+=OrderOpenPrice()*OrderLots();
            TongKhoiLuong+=OrderLots();
         }
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
            if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,DiemDongTatCaCacLenhTP,0,clrNONE)==false)
                  Print("Loi dich SL,TP ticket: ",OrderTicket(), "  Diem dich SL: ", DiemDongTatCaCacLenhSL, " Diem TP: ",DiemDongTatCaCacLenhTP);
            }
         }
      }
      
   }
   else
   {
    //   Print("Tong lenh sell:",glbTongLenhSell," Loi nhuan can dat duoc:",LoiNhuanCanDatDuoc);
      for(int i=0;i<glbTongSoLenh;i++)
      {
         if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
         {
            TongComVaSwap+=OrderCommission()+OrderSwap();
            TongTheoGia+=OrderOpenPrice()*OrderLots();
            TongKhoiLuong+=OrderLots();
         }
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
            if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),DiemDongTatCaCacLenhSL,DiemDongTatCaCacLenhTP,0,clrNONE)==false)
                  Print("Loi dich SL,TP ticket: ",OrderTicket(), "  Diem dich SL: ", DiemDongTatCaCacLenhSL, " Diem TP: ",DiemDongTatCaCacLenhTP);
            }
         }
      }
      
   }
}

string FunHienThiTenKhungThoiGian(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_CURRENT: 
         return "Khung hien tai";
      case PERIOD_D1:
         return "D1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_H1:
         return "H1";
      case PERIOD_M30:
         return "M30";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_MN1:
         return "MN1";
      default: return "Loi khung thoi gian";
   }
}

string FunHienThiTenXuHuongSupperTrend(ENUM_XU_HUONG xh)
{
   switch(xh)
   {
      case XU_HUONG_GIAM: 
         return "GIAM";
      case XU_HUONG_TANG:
         return "TANG";
      default: return "KHONG XAC DINH";
   }
}

double FunTinhKhoiLuongVaoLenh()
{
      if(inpKhoiLuongCoSo>0) return inpKhoiLuongCoSo;
      
      double khoi_luong_nho_nhat=MarketInfo(Symbol(),MODE_MINLOT);
      
      double point=inpPointSLCoSo;
      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
      double TongLoChoPhep=inpRuiRoMotLenh;
      double khoiluongvaolenh=NormalizeDouble(TongLoChoPhep/(point*nTickValue),FunPhanThapPhanKhoiLuong());
      if(khoiluongvaolenh<khoi_luong_nho_nhat)khoiluongvaolenh=khoi_luong_nho_nhat;
      return khoiluongvaolenh;
   
}


int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
