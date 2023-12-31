//+------------------------------------------------------------------+
//|                                                  TestLibrary.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property strict   
//--- Including the trading panel class
//#include "Program.mqh"
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
struct StrTapLenh  
{
   int Ticket;
   double GiaTPTheoLine;
};
enum ENM_TRANG_THAI_BOT{
   ENM_ON,
   ENM_OFF
};  
enum ENM_XU_HUONG_THI_TRUONG{
   ENM_TANG,
   ENM_GIAM,
   ENM_SIDE_WAY,
   ENM_KHONG_XAC_DINH
};
enum ENM_XAC_DINH_XU_HUONG_THU_CONG{
   ENM_THU_CONG_OFF,//TU_DONG
   ENM_THU_CONG_TANG,//THU_CONG_TANG
   ENM_THU_CONG_GIAM,//THU_CONG_GIAM
   ENM_THU_CONG_SIDEWAY//THU_CONG_SIDEWAY
};
enum ENM_KIEU_VAO_LENH_TU_DONG
{
   ENM_OSMA,//OSMA
   ENM_BOLINGER,//BOLINGER BAND
};
enum ENM_LOAI_LENH_CHO_PHEP
{
   ENM_CHI_DANH_BUY,//BUY
   ENM_CHI_DANH_SELL,//SELL
   ENM_BUY_VA_SELL,// CA BUY VA SELL
};
enum ENM_KIEU_TINH_KHOI_LUONG
{
   ENM_CHON_MUC_NHO_NHAT,
   ENM_CHON_THEO_KHOI_LUONG_TRUOC_DO,
};
NgayThang NgayHetHan={20,02,3023};
input ENM_LOAI_LENH_CHO_PHEP inpLoaiLenhChoPhepVao=ENM_BUY_VA_SELL;// Loai lenh cho phep vao:
input int inpTongSoLenhChoPhep=100;// Tong so lenh cho phep:
input int inpKhoangCachGiuaHaiLenhCungChieu=10;// Khoang cach giua hai lenh cung chieu (pips):
input ENUM_TIMEFRAMES inpKhungThoiGianXuHuongLon=PERIOD_D1;// Khung thoi gian xu huong lon:
input double inpKhoangCachXacDinhVaoLenhKhiDoiXuHuongBBKhungLon=10;//Khoang cach doi xu huong de canh VAO lenh theo BB KHUNG LON(pips)
input double inpKhoangCachXacDinhThoatLenhKhiDoiXuHuongBBKhungLon=10;//Khoang cach doi xu huong de canh THOAT lenh theo BB KHUNG LON(pips)
input bool inpChoPhepDongCacLenhKhiThayDoiXuHuongLon=true;// Cho phep dong lenh khi doi xu huong lon (Neu False: se dong lenh theo xu huong nho)
input int inpBBPeriodKhungLon=20;// BB Period khung lon:
input int inpBBDevitationKhungLon=2;// BB Devitation khung lon
input string strKL="CAI DAT KHOI LUONG VAO LENH";//CAI DAT KHOI LUONG CAO LENH:
//input double inpKhoiLuong=0.01;//1. Khoi luong vao lenh (lotsize)
input double inpMucDanh=20000;//Muc danh: (Khoiluong=Tong tai san/Muc danh):
input ENM_KIEU_TINH_KHOI_LUONG inpKieuTinhKhoiLuongSauKhiCatLoTatCaLenh=ENM_CHON_THEO_KHOI_LUONG_TRUOC_DO;
input int inpPhanTramSutGiamTaiKhoanChoPhep=20;//Phanm tram sut giam tai khoan cho phep (%):
input double inpSoPipCatLo=15;//2. So pip cat lo khung trade (pips)
input string inpStrVaoLenh="CAI DAT VAO LENH";//3. VAO LENH
input double inpSoPipMaxBuy=5;//3.1. So pip max cach band duoi de vao Buy (pip)
input double inpSoPipMinBuy=2;//3.2. So pip min cach band duoi de vao Buy (pip)
input double inpSoPipMaxSell=5;//3.3. So pip max cach band duoi de vao Sell (pip)
input double inpSoPipMinSell=2;//3.4. So pip min cach band duoi de vao Sell (pip)
input string inpStrChotLenh="CAI DAT CHOT LENH";//4. CHOT LENH
input double inpSoPipChotLoiDangBand=5.0;//4.1. So pip cua duong band chot loi 1 cach band tren/duoi (Pips)
input double inpSoPipChotLoiDangLine=3.0;//4.2. So pip cau duong line loi 2 cach band tren/duoi (Pips)
input bool inpChoPhepDongLenhAmKhiChamBand=false;//4.3. Cho phep dong lenh AM khi cham band: true: cho phep
input ENUM_TIMEFRAMES inpKhungGioTinhOSMA_BB=PERIOD_H1;// 5. Khung gio lay xu huong OSMA, Bolingerband
input bool inpChoPhepDichHoaVon=false;// 6.1 Cho phep trailing stop khong: true: co - false: khong
input double inpSoPipMuonDichHoaVon=false;// 6.2 So pip muon dich hoa von (pips)
input string inpstr="KIEU VAO LENH TU DONG";//7. CAI DAT KIEU VAO LENH TU DONG
input ENM_XAC_DINH_XU_HUONG_THU_CONG inpXacDinhXuHuongThuCong=ENM_THU_CONG_OFF;//7. XAC DINH XU HUONG THU CONG - HAY TU DONG
input ENM_KIEU_VAO_LENH_TU_DONG inpKieuVaoLenhTuDong=ENM_BOLINGER;// 7.1. KIEU XAC DINH XU HUONG TU DONG THEO
input string inpStrThongSoOSMA="CAI DAT THONG SO OSMA";// 7.2. THONG SO OSMA
input int inpOSMAFastPeriod=12;//7.2.1. Fast EMA period
input int inpOSMASlowPeriod=26;//7.2.2. Slow EMA period
input int inpOSMASignalLinePeriod=9;//7.2.3. Signal line period
input string inpStrThongSoXuHuongBB="CAI DAT THONG SO XU HUONG THEO BB";// 7.3. THONG SO XAC DINH XU HUONG THEO BILINGER BAND
input double inpKhoangCachXacDinhDoiXuHuongBB=10;//7.3.1. Khoang cach doi xu huong de canh vao lenh theo BB(pips)
input bool inpChoPhepDongLenhKhiBBDoiXuHuongKhungNho=true;// 7.3.2. Cho phep dong lenh khi BB doi xu huong lan thu 2:
input double inpKhoangCachXacDinhDongLenhBB=10;//7.3.3. Khoang cach doi xu huong dong lenh theo BB (pips)

input string inpStrThongSoBB="CAI DAT THONG SO BOLINGER BAND" ;//8.THONG SO BOLINGER BAND
input int inpBBPeriodKhungNho=20;//8.1. BB period
input double inpBBDevitationKhungNho=2.0;//8.2. BB deviations
input int inpBBBandShift=0;//8.3. BB Band shift
input string inpstrCaiDatGioVaoLenh="CO THE CAI DAT 01-03 VUNG GIO VAO LENH";//9.CAI DAT GIO VAO LENH
input string inpstrVung1="THAM SO BANG 0: KHONG SU DUNG";//9.1. VUNG GIO SO 1
input double inpStartTime1=0;//9.1.1. Thoi Gian Bat Dau vao lenh (Server time)
input double inpEndTime1=0;// 9.1.2. Thoi Gian Ket Thuc vao lenh(Server time)

input string inpstrVung2="THAM SO BANG 0: KHONG SU DUNG";//9.2. VUNG GIO SO 2
input double inpStartTime2=0;//9.2.1. Thoi Gian Bat Dau vao lenh (Server time)
input double inpEndTime2=0;// 9.2.2. Thoi Gian Ket Thuc vao lenh(Server time)

input string inpstrVung3="THAM SO BANG 0: KHONG SU DUNG";//9.3. VUNG GIO SO 3
input double inpStartTime3=0;//9.3.1. Thoi Gian Bat Dau vao lenh (Server time)
input double inpEndTime3=0;// 9.3.2. Thoi Gian Ket Thuc vao lenh(Server time)
input string inpstrGiuLenh="=0: KHONG AP DUNG THOI GIAN DU LENH";//10. CAI DAT SO PHUT GIU LENH
input int inpThoiGianGiuLenh=0;// 10.1. Thoi gian giu lenh (phut)


input int inpMagicNumber=12345;//12. Magic number
input int inpSlippage=50;// 13. Slippage (Points)
int glbTongSoLenh=0;
StrTapLenh glbTapLenh[200];
ENM_XU_HUONG_THI_TRUONG glbXuHuongHienTai;
bool glbDaVaoLenh=false;
double glbGiaLineTP=0;
double glbDemSoTrendLine=0;
ENUM_ORDER_TYPE glbLoaiLenhVao;
string glbTenLenhDuocVao="";
datetime glbThoiDiemXayRaDoiXuHuong=0;
datetime glbThoiDiemChuyeXHTangGanNhat=0;
datetime glbThoiDiemChuyeXHGiamGanNhat=0;
double glbKhoiLuongNhoNhat=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  
   
   if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
   if(inpLoaiLenhChoPhepVao==ENM_CHI_DANH_BUY)
      glbTenLenhDuocVao="CHI CHO PHEP BUY";
   else if(inpLoaiLenhChoPhepVao==ENM_CHI_DANH_SELL)
      glbTenLenhDuocVao="CHI CHO PHEP SELL";
   else glbTenLenhDuocVao="CHO PHEP CANH CA BUY  VA SELL";

   if(glbTongSoLenh<=0)
   {
      FunXuLyKhoiTaoBot();
      glbXuHuongHienTai=FunXacDinhXuHuongHienTai();
      glbThoiDiemChuyeXHGiamGanNhat=Time[0];
      glbThoiDiemChuyeXHTangGanNhat=Time[0];
      glbThoiDiemXayRaDoiXuHuong=Time[0];
   }
   if(glbKhoiLuongNhoNhat<=0)glbKhoiLuongNhoNhat=MarketInfo(Symbol(),MODE_MINLOT);
   
//--- Initialization successful
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//--------------------------------------------------------------------
      {
         if(FunKiemTraGioVaoLenh()==false)
         {
            if(glbTongSoLenh==0)
            {
               Comment("CHUA DEN GIO VAO LENH");
               return;
            
            }
            else Comment("CHUA DEN GIO VAO LENH.\nBOT CHI QUAN LY LENH DANG CO.\nKHONG VAO THEM LENH MOI.\nTONG LENH DANG CO: ",glbTongSoLenh);
         }
      }
      if(FunKiemTraSangNenMoiChua())
      {  
         glbXuHuongHienTai=FunXacDinhXuHuongHienTai();
         //Print("XH hien tai: ", glbXuHuongHienTai);
         glbDaVaoLenh=false;
         FunXuLyDongLenhKhiBBDoiChieu();
         
      }  
      
      FunKiemTraVaoLenhKhiNhayTick();
      
      if(glbTongSoLenh>0)// dang co lenh
      {
       
         FunKiemTraDongLenhTheoSutGiamPhanTramTaiKhoan();     
         FunKiemTraXoaLenhKhoiMang();
         if(glbTongSoLenh==0)
         {
            FunHLineDelete(0,"priceTP");
         }
         else
         {
            if(inpChoPhepDichHoaVon==true)
               FunXuLyLenhDichHoaVon();
            FunXuLyLenhKhiChamGiaTP();       
            FunKiemTraThoiGianGiuLenh();            
         }
            
      }
      
      Comment("XU HUONG LON VAO LENH: ", FunStringTenXuHuong(FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhVaoLenhKhiDoiXuHuongBBKhungLon,1)),
               "    XU HUONG LON CANH THOAT LENH: ", FunStringTenXuHuong(FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhThoatLenhKhiDoiXuHuongBBKhungLon,1)),
               "\nTONG LENH DANG CO: ",glbTongSoLenh, "    SO LENH TOI DA: ",inpTongSoLenhChoPhep, "\nkHOI LUONG NHO NHAT GIAO DICH: ",glbKhoiLuongNhoNhat);
      
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
  {
  }

//+-------------------------------------------------------------------------------+
void FunXuLyKhoiTaoBot()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicNumber)
         {
            glbTapLenh[glbTongSoLenh].Ticket=OrderTicket();
            glbTapLenh[glbTongSoLenh].GiaTPTheoLine=StringToDouble(OrderComment());
            glbTongSoLenh++;
         }
      }
   }
}
//+-------------------------------------------------------------------------------+
void FunKiemTraVaoLenhKhiNhayTick()
{
   int DieuKienVaoLenh=FunKiemTraDieuKienVaoLenh();
   if(DieuKienVaoLenh>=0 && glbDaVaoLenh==false)
   {
     if(FunKiemTraGioVaoLenh()==false)
     {
         return;// Chua den gio vao lenh
     }
     if(DieuKienVaoLenh==0)// Thoa man dieu kien Buy
     {
         if(FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhVaoLenhKhiDoiXuHuongBBKhungLon,1)!=ENM_TANG) return;
         bool ChoPhepBuy=false;
         if(glbTongSoLenh<inpTongSoLenhChoPhep && glbTongSoLenh>0)
         {
            // Tim lenh buy gan nhat, neu lenh buy gan nhat thoi gian vao lenh <thoi gian doi xu huong Thi cho phep  vao lenh tiep
            // Khoang cach lenh buy gan nhat toi lenh hien tai >=10 pip
            // 
            
            int vtBuyGanNhat=glbTongSoLenh-1;
            while(vtBuyGanNhat>=0)
            {
               if(OrderSelect(glbTapLenh[vtBuyGanNhat].Ticket,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_BUY) 
                  {
                     int KhoangCachToiLenhGanNhat=(OrderOpenPrice()-Ask)/(10*Point());
                     if(OrderOpenTime()<glbThoiDiemXayRaDoiXuHuong && KhoangCachToiLenhGanNhat>=inpKhoangCachGiuaHaiLenhCungChieu) {ChoPhepBuy=true;}
                     else ChoPhepBuy=false;
                     break;
                  }
                  else vtBuyGanNhat--;
               }             
            }
            if(vtBuyGanNhat<0)//Khong co lenh buy nao
               ChoPhepBuy=true;// Cho phep vao lenh buy luon   
         }
         else if(glbTongSoLenh<=0)// Chua co lenh nao cho phep vao buy luon
            ChoPhepBuy=true;
         else ChoPhepBuy=false;
        // Print("CHO PHEP Buy: ", ChoPhepBuy);
         if(ChoPhepBuy==true && inpLoaiLenhChoPhepVao!=ENM_CHI_DANH_SELL)
         {
            // Dong tat ca cac lenh sell
            
            glbGiaLineTP=FunTinhBBValueUp()-inpSoPipChotLoiDangLine*10*Point();
            int ticket=FunVaoLenh(OP_BUY,Ask,inpSoPipCatLo,0,FunTinhKhoiLuongTheoMucDanh(),DoubleToString(glbGiaLineTP,Digits));
            if(ticket>0)
            {
               
               glbTapLenh[glbTongSoLenh].Ticket=ticket;
               glbTapLenh[glbTongSoLenh].GiaTPTheoLine=glbGiaLineTP;
               glbTongSoLenh++;              
               FunHLineCreate(0,"priceTP",0,glbGiaLineTP);          
              // OrderModify(ticket,Ask,0,glbGiaLineTP,0,clrNONE);
               glbDaVaoLenh=true;
               glbLoaiLenhVao=OP_BUY;
            }
         }
     }
     else // Xet vao lenh sell
     {
          if(FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhVaoLenhKhiDoiXuHuongBBKhungLon,1)!=ENM_GIAM) return;
         bool ChoPhepSell=false;
         if(glbTongSoLenh<inpTongSoLenhChoPhep && glbTongSoLenh>0)
         {
            int vtSellGanNhat=glbTongSoLenh-1;
            while(vtSellGanNhat>=0)
            {
               if(OrderSelect(glbTapLenh[vtSellGanNhat].Ticket,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_SELL) 
                  {
                     int KhoangCachToiLenhGanNhat=(Bid-OrderOpenPrice())/(10*Point());
                     if(OrderOpenTime()<glbThoiDiemXayRaDoiXuHuong && KhoangCachToiLenhGanNhat>=inpKhoangCachGiuaHaiLenhCungChieu) {ChoPhepSell=true;}
                     else ChoPhepSell=false;
                     break;
                  }
                  else vtSellGanNhat--;
               }             
            }
            if(vtSellGanNhat<0)//Khong co lenh sell nao
               ChoPhepSell=true;// Cho phep vao lenh sell luon   
         }
         else if(glbTongSoLenh<=0)// Chua co lenh nao vao sell luon
            ChoPhepSell=true;
         else ChoPhepSell=false;
        // Print("CHO PHEP SELL: ", ChoPhepSell);
        if(ChoPhepSell==true && inpLoaiLenhChoPhepVao!=ENM_CHI_DANH_BUY)
         {
            glbGiaLineTP=FunTinhBBValueLow()+inpSoPipChotLoiDangLine*10*Point();
            int ticket=FunVaoLenh(OP_SELL,Bid,inpSoPipCatLo,0,FunTinhKhoiLuongTheoMucDanh(),DoubleToString(glbGiaLineTP,Digits));
            if(ticket>0)
            {
               glbTapLenh[glbTongSoLenh].Ticket=ticket;
               glbTapLenh[glbTongSoLenh].GiaTPTheoLine=glbGiaLineTP;
               glbTongSoLenh++;
               FunHLineCreate(0,"priceTP",0,glbGiaLineTP);
            //   OrderModify(ticket,Bid,0,glbGiaLineTP,0,clrNONE);
               glbDaVaoLenh=true;
               glbLoaiLenhVao=OP_SELL;
            }
         } 
         
     }                
   }
}
//+------------------------------------------------------------------+
void FunXuLyDongLenhKhiBBDoiChieu()
{
   if(glbTongSoLenh>0)
   {  
      if(inpChoPhepDongCacLenhKhiThayDoiXuHuongLon==true)
      {
         //Xu ly dong lenh khi thay doi theo xu huong lon
         ENM_XU_HUONG_THI_TRUONG xuhuongkhunglon1=FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhThoatLenhKhiDoiXuHuongBBKhungLon,1);
         //ENM_XU_HUONG_THI_TRUONG xuhuongkhunglon2=FunXacDinhXuHuongTheoBB(inpKhungThoiGianXuHuongLon,inpBBPeriodKhungLon,inpBBDevitationKhungLon,inpKhoangCachXacDinhThoatLenhKhiDoiXuHuongBBKhungLon,2);
         if(xuhuongkhunglon1==ENM_GIAM)
         {
            for(int i=glbTongSoLenh-1;i>=0;i--)
            {
               if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_BUY && OrderCloseTime()<=0)
                  {
   
                        Print("KIEM TRA DONG CAC LENH BUY TRUOC DO DO BB KHUNG LON DOI SANG GIAM.Gio mo lenh: ",OrderOpenTime(),  " Time: ",glbThoiDiemChuyeXHTangGanNhat);
                        FunDongLenh(OrderTicket());
                  }
               }
            }
            FunKiemTraXoaLenhKhoiMang();
         }
         else  if(xuhuongkhunglon1==ENM_TANG)
         {
            
            for(int i=glbTongSoLenh-1;i>=0;i--)
            {
               if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_SELL && OrderCloseTime()<=0)
                  {
                        Print("KIEM TRA DONG CAC LENH SELL TRUOC DO DO BB KHUNG LON DOI SANG TANG. Gio mo lenh: ",OrderOpenTime(),  " Time XH : ",glbThoiDiemChuyeXHGiamGanNhat);
                        FunDongLenh(OrderTicket());
                  }
               }
            }
            FunKiemTraXoaLenhKhoiMang();
         }          
                
         return;
      }
      if(inpChoPhepDongLenhKhiBBDoiXuHuongKhungNho==false) return; 
      // Kiem tra dong lenh khi xu huong lon doi chieu
      // DOng lenh khi BB khung nho doi chieu
      ENM_XU_HUONG_THI_TRUONG xuhuongthitruongkhungnho=FunXacDinhXuHuongTheoBB(inpKhungGioTinhOSMA_BB,inpBBPeriodKhungNho,inpBBDevitationKhungNho,inpKhoangCachXacDinhDongLenhBB,0);
      //Print("Xu huong BB:",xuhuongthitruong);
      if(xuhuongthitruongkhungnho==ENM_GIAM)
      {
         for(int i=glbTongSoLenh-1;i>=0;i--)
         {
            if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==OP_BUY && OrderCloseTime()<=0 && FunSoSanhThoiGianTime1NhoHonTime2((datetime)OrderOpenTime(),glbThoiDiemChuyeXHTangGanNhat))
               {

                     Print("KIEM TRA DONG CAC LENH BUY TRUOC DO DO BB KHUNG THAM CHIEU NHO DOI SANG GIAM.Gio mo lenh: ",OrderOpenTime(),  " Time: ",glbThoiDiemChuyeXHTangGanNhat);
                     FunDongLenh(OrderTicket());
               }
            }
         }
         FunKiemTraXoaLenhKhoiMang();
      }
      else  if(xuhuongthitruongkhungnho==ENM_TANG)
      {
         
         for(int i=glbTongSoLenh-1;i>=0;i--)
         {
            if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==OP_SELL && OrderCloseTime()<=0 && FunSoSanhThoiGianTime1NhoHonTime2((datetime)OrderOpenTime(),glbThoiDiemChuyeXHGiamGanNhat))
               {
                     Print("KIEM TRA DONG CAC LENH SELL TRUOC DO DO BB KHUNG THAM CHIEU NHO DOI SANG TANG. Gio mo lenh: ",OrderOpenTime(),  " Time XH : ",glbThoiDiemChuyeXHGiamGanNhat);
                     FunDongLenh(OrderTicket());
               }
            }
         }
         FunKiemTraXoaLenhKhoiMang();
      }              
   }
}
//+------------------------------------------------------------------+
int FunDemSoLenhBuyHoacSellTrongTapLenh(int LoaiLenh)
{
   int dem=0;
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(i,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==LoaiLenh) dem++;
      }
   }
   return dem;
}
//+------------------------------------------------------------------+
void FunXuLyLenhKhiChamGiaTP()
{
   if(glbTongSoLenh<=0) return;
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            double BBUp=FunTinhBBValueUp();
            double BandTPValue=BBUp-inpSoPipChotLoiDangBand*10*Point();
            /*
            if(Close[0]>=BBUp)
            {
               Print("DONG LENH BUY DO CHAM BAND TREN CUA BOLINGER BAND");
               OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
            }
            */
            if(Close[0]>=glbTapLenh[i].GiaTPTheoLine)
            {
               if(OrderProfit()>0)
               {
                  OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
                  Print("DONG LENH BUY DO CHAM DUONG LINE: ", glbTapLenh[i].GiaTPTheoLine);
               }
            }
            if(Close[0]>=BandTPValue)
            {
               if(OrderProfit()>0)
               {
                  OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
                  Print("DONG LENH BUY DUONG DO CHAM DUONG BAND SONG SONG VOI BB");
               }
               else if(inpChoPhepDongLenhAmKhiChamBand==true)
               {
                  OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
                  Print("DONG LENH BUY AM DO CHAM DUONG BAND SONG SONG VOI BB");
               }
            }
         }
         else// Xu ly lenh sell
         {
            double BBLow=FunTinhBBValueLow();
            double BandTPValue=BBLow+inpSoPipChotLoiDangBand*10*Point();
            /*
            if(Close[0]<=BBLow)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
               Print("DONG LENH SELL DO CHAM BAND DUOI CUA BOLINGER BAND");
            }
            */
            if(Close[0]<=glbTapLenh[i].GiaTPTheoLine)
            {
               if(OrderProfit()>0)
               {
                  OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
                  Print("DONG LENH SELL DO CHAM DUONG LINE: ", glbTapLenh[i].GiaTPTheoLine);
               }
            }
            if(Close[0]<=BandTPValue)
            {
               if(OrderProfit()>0)
               {
                  OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
                  Print("DONG LENH SELL DUONG DO CHAM DUONG BAND SONG SONG VOI BB");
               }
               else if(inpChoPhepDongLenhAmKhiChamBand==true)
               {
                  OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
                  Print("DONG LENH SELL AM DO CHAM DUONG BAND SONG SONG VOI BB");
               }
            }
         }
      
      }
   }
}

//+------------------------------------------------------------------+
void FunXuLyLenhDichHoaVon()
{
   if(glbTongSoLenh<=0) return;
   for(int i=0;i<glbTongSoLenh; i++)
   {
      if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderStopLoss()<OrderOpenPrice()|| OrderStopLoss()==0)
            {
               double BBGiua=iBands(Symbol(),0,inpBBPeriodKhungNho,inpBBDevitationKhungNho,0,PRICE_CLOSE,MODE_MAIN,0);
               if(BBGiua>=(OrderOpenPrice()+(10+MarketInfo(Symbol(),MODE_SPREAD))*Point()))
               {
                  if(Close[0]>BBGiua)
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+inpSoPipMuonDichHoaVon*10*Point(),OrderTakeProfit(),0,clrNONE);
                     
               }
            }
         }
         else
         {
            if(OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0)
            {
               double BBGiua=iBands(Symbol(),0,inpBBPeriodKhungNho,inpBBDevitationKhungNho,0,PRICE_CLOSE,MODE_MAIN,0);
               if(BBGiua<=(OrderOpenPrice()-(10+MarketInfo(Symbol(),MODE_SPREAD))*Point()))
               {
                  if(Close[0]<BBGiua)
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-inpSoPipMuonDichHoaVon*10*Point(),OrderTakeProfit(),0,clrNONE);            
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
int FunKiemTraDieuKienVaoLenh()//-1: chau thoa man, 0: buy 1:sell
{
   int DieuKienVaoLenh=-1;
   if(glbXuHuongHienTai==ENM_TANG || glbXuHuongHienTai==ENM_SIDE_WAY)
   {
      // Kiem tra dieu kien vao lenh buy
      double BBLow=FunTinhBBValueLow();
      double BienTren=BBLow+inpSoPipMaxBuy*10*Point();
      double BienDuoi=BBLow+inpSoPipMinBuy*10*Point();
      if(BienTren<BienDuoi) {
         double tam=BienTren;
         BienTren=BienDuoi;
         BienDuoi=tam;
      }
      if(Close[0]<=BienTren && Close[0]>=BienDuoi && Close[0]==Low[0])
         DieuKienVaoLenh=0;// Du dk Vao lenh buy
   }
   if(glbXuHuongHienTai==ENM_GIAM || glbXuHuongHienTai==ENM_SIDE_WAY)
   {
      // Kiem tra dieu kien vao lenh sell
      double BBHigh=FunTinhBBValueUp();
      double BienTren=BBHigh-inpSoPipMinSell*10*Point();
      double BienDuoi=BBHigh-inpSoPipMaxSell*10*Point();
      if(BienTren<BienDuoi) {
         double tam=BienTren;
         BienTren=BienDuoi;
         BienDuoi=tam;
      }
      if(Close[0]>=BienDuoi && Close[0]<=BienTren && Close[0]==High[0])
         DieuKienVaoLenh=1;// Du dk Vao lenh sell
   }
   return DieuKienVaoLenh;
}
//+------------------------------------------------------------------+
double FunTinhBBValueUp()
{
   return iBands(Symbol(),0,inpBBPeriodKhungNho,inpBBDevitationKhungNho,0,PRICE_CLOSE,MODE_UPPER,0);
}
//+------------------------------------------------------------------+
double FunTinhBBValueLow()
{
   return iBands(Symbol(),0,inpBBPeriodKhungNho,inpBBDevitationKhungNho,0,PRICE_CLOSE,MODE_LOWER,0);
}  
//+------------------------------------------------------------------+
ENM_XU_HUONG_THI_TRUONG FunXacDinhXuHuongThiTruongTheoOSMAHoacBBKhungNho(int TimeFrameXacDinh, int Shift)
{
   if(inpKieuVaoLenhTuDong==ENM_OSMA)
   {
      double osmaValue=iOsMA(Symbol(),TimeFrameXacDinh,inpOSMAFastPeriod,inpOSMASlowPeriod,inpOSMASignalLinePeriod,PRICE_CLOSE,Shift);
      if(osmaValue>0) return ENM_TANG;
      else if(osmaValue<0) return ENM_GIAM;
      else return ENM_KHONG_XAC_DINH;
   }
   else
   {
      return FunXacDinhXuHuongTheoBB(TimeFrameXacDinh,inpBBPeriodKhungNho,inpBBDevitationKhungNho,inpKhoangCachXacDinhDoiXuHuongBB, Shift);
   }
   
}
ENM_XU_HUONG_THI_TRUONG FunXacDinhXuHuongTheoBB(int TimeFrameXacDinh,int BBPeriod,int BBDevitation,double KhoangCachDoiXuHuong, int Shift)
{
   double BBValue=iBands(Symbol(),TimeFrameXacDinh,BBPeriod,BBDevitation,0,PRICE_CLOSE,MODE_MAIN,Shift);
    double BBValuei=0, KhoangCach=0;
   int i=Shift+1;
   while(i<=500)
   {
       BBValuei=iBands(Symbol(),TimeFrameXacDinh,BBPeriod,BBDevitation,0,PRICE_CLOSE,MODE_MAIN,i);
       KhoangCach=MathAbs(BBValuei-BBValue)/(10*Point());
       KhoangCach=NormalizeDouble(KhoangCach,2);
       if(KhoangCach>=KhoangCachDoiXuHuong) break;
       i++;    
   }
   if(KhoangCach>=KhoangCachDoiXuHuong)
   {
     //Print("Khoang cach: ", KhoangCach, " Khoang cach doi xu huong: ",KhoangCachDoiXuHuong, " Nen: ",i);
      if(BBValuei<BBValue) return ENM_TANG;
      else return ENM_GIAM;
   }  
   else return ENM_KHONG_XAC_DINH;
}
//+------------------------------------------------------------------+
ENM_XU_HUONG_THI_TRUONG FunXacDinhXuHuongHienTai()
{
   ENM_XU_HUONG_THI_TRUONG xuhuonghientai;
   if(inpXacDinhXuHuongThuCong==ENM_THU_CONG_OFF)
   {
      xuhuonghientai=FunXacDinhXuHuongThiTruongTheoOSMAHoacBBKhungNho(inpKhungGioTinhOSMA_BB,0);
      ENM_XU_HUONG_THI_TRUONG xuhuongtruocdo=FunXacDinhXuHuongThiTruongTheoOSMAHoacBBKhungNho(inpKhungGioTinhOSMA_BB,1);
      if(xuhuongtruocdo!=xuhuonghientai)
      {
         glbThoiDiemXayRaDoiXuHuong=Time[0];
         if(xuhuonghientai==ENM_TANG)
            glbThoiDiemChuyeXHTangGanNhat=Time[0];
         else if(xuhuonghientai==ENM_GIAM)
            glbThoiDiemChuyeXHGiamGanNhat=Time[0];
         Print("Thoi diem XH hien tai: ", glbThoiDiemXayRaDoiXuHuong," XH tang gan nhat: ",glbThoiDiemChuyeXHTangGanNhat, " XH giam gan nhat: ",glbThoiDiemChuyeXHGiamGanNhat );
         //Print("Doi xu huong. Thoi gian: ",glbThoiDiemXayRaDoiXuHuong);
      }
   }
   else
   {
      if(inpXacDinhXuHuongThuCong==ENM_THU_CONG_TANG)
      {
         xuhuonghientai=ENM_TANG;
         glbThoiDiemXayRaDoiXuHuong=0;
         glbThoiDiemChuyeXHTangGanNhat=0;
         glbThoiDiemChuyeXHGiamGanNhat=0;
      }
      else if(inpXacDinhXuHuongThuCong==ENM_THU_CONG_GIAM)
      {
         xuhuonghientai=ENM_GIAM;
         glbThoiDiemXayRaDoiXuHuong=0;
         glbThoiDiemChuyeXHTangGanNhat=0;
         glbThoiDiemChuyeXHGiamGanNhat=0;
      }
      else 
      {
         xuhuonghientai=ENM_SIDE_WAY;
         glbThoiDiemXayRaDoiXuHuong=0;
         glbThoiDiemChuyeXHTangGanNhat=0;
         glbThoiDiemChuyeXHGiamGanNhat=0;
      }
   }
   
   return xuhuonghientai;
}
//+------------------------------------------------------------------+
//---------------------------------Tinh khoi luong vao lenh-----------------------------------------
double FunTinhKhoiLuong(double soPip, double SoTienRuiRo)
{
   double khoi_luong_nho_nhat=MarketInfo(Symbol(),MODE_MINLOT);
   if(SoTienRuiRo>0)
   {
      double point=soPip*10;
      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
      double TongLoChoPhep=SoTienRuiRo;
      double khoiluongvaolenh=NormalizeDouble(TongLoChoPhep/(point*nTickValue),FunTinhLotDecimal());
      if(khoiluongvaolenh<khoi_luong_nho_nhat)khoiluongvaolenh=khoi_luong_nho_nhat;
      return khoiluongvaolenh;
   }
   else return 0;
}
//////////////////TINH SO THAP PHAN CUA LOTS//////////////////////
int FunTinhLotDecimal()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
//---------------------------------Tinh so tien -----------------------------------------
double FunTinhSoTienLo(double SoPip, double SoLot)
{
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double TongLo=SoPip*10*nTickValue*SoLot;
   return NormalizeDouble(TongLo,2);
}
//---------------------------------Tinh so pip-----------------------------------------
double FunTinhSoPips(double SoTienLoChoPhep, double SoLot)
{
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double SoPip=SoTienLoChoPhep/(10*nTickValue*SoLot);
   return NormalizeDouble(SoPip,2);
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
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, string Comments)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,Comments,inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,Comments,inpMagicNumber,0,clrRed);
    }
    return Ticket;
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
//+------------------------------------------------------------------+
void FunKiemTraThoiGianGiuLenh()
{
   //Thoi gian giu lenh cua lenh sau cung, neu dong lenh nay, dong tat ca cac lenh cung chieu
   
   if(inpThoiGianGiuLenh<=0) return;
   if(OrderSelect(glbTapLenh[glbTongSoLenh-1].Ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      datetime time=OrderOpenTime()+inpThoiGianGiuLenh*60;
      if(time<=TimeCurrent())
      {
         int LoaiLenh=OrderType();
         Print("DO QUA THOI GIAN GIU LENH. DONG CAC LENH: ",LoaiLenh);
         if(LoaiLenh==OP_SELL)OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
         else OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
         for(int i=0;i<glbTongSoLenh-1;i++)
         {
            if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET,MODE_TRADES))
            {        
                  if(OrderType()==LoaiLenh)
                  {
                     if(LoaiLenh==OP_SELL)OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
                     else OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
                  }    
            }
         }
         FunKiemTraXoaLenhKhoiMang();
      }
   }
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET))
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
}
//+------------------------------------------------------------------+
void FunDongLenh(int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         OrderClose(ticket,OrderLots(),Bid,inpSlippage,clrNONE);
      }
      else if(OrderType()==OP_SELL)
      {
         OrderClose(ticket,OrderLots(),Ask,inpSlippage,clrNONE);
      }
      else OrderDelete(ticket);
   }
}

bool FunHLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=true,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunHLineDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
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
//| Get price horizontal line                                         |
//+------------------------------------------------------------------+
double FunHlineGetPrice(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   
   ResetLastError();
   if(ObjectFind(chart_ID,name)<0)
   {
      Print(__FUNCTION__,
            ": failed to finde horizontal line: ",name, " Error code = ",GetLastError());
            return false;
   }
   double price=ObjectGet(name,OBJPROP_PRICE1);
//--- successful execution
   return price;
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool FunHLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool FunTrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   FunChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunTrendDelete(chart_ID,name);
   }
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move trend line anchor point                                     |
//+------------------------------------------------------------------+
bool FunTrendPointChange(const long   chart_ID=0,       // chart's ID
                      const string name="TrendLine", // line name
                      const int    point_index=0,    // anchor point index
                      datetime     time=0,           // anchor point time coordinate
                      double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move trend line's anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| The function deletes the trend line from the chart.              |
//+------------------------------------------------------------------+
bool FunTrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a trend line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void FunChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one
   if(!price2)
      price2=price1;
  }

  
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
/*
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,pos;
//---
//--- counting from 0 to rates_total
   ArraySetAsSeries(Buf_up,false);
   ArraySetAsSeries(Buf_low,false);
//--- preliminary calculations
   pos=prev_calculated-1;
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      Buf_up[i]=iBands(Symbol(),0,inpBBPeriod,inpBBDeviation,0,PRICE_CLOSE,MODE_UPPER,i)-inpSoPipChotLoiDangBand*10*Point();
      Buf_low[i]=iBands(Symbol(),0,inpBBPeriod,inpBBDeviation,0,PRICE_CLOSE,MODE_LOWER,i)+inpSoPipChotLoiDangBand*10*Point();
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
*/

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   bool kt=false;
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(inpStartTime1!=0 || inpEndTime1!=0)
   {
      if(gio>=inpStartTime1 && gio<inpEndTime1) kt= true;
   }
   if(inpStartTime2!=0 || inpEndTime2!=0)
   {
      if(gio>=inpStartTime1 && gio<inpEndTime1) kt= true;
   }
   if(inpStartTime3!=0 || inpEndTime3!=0)
   {
      if(gio>=inpStartTime1 && gio<inpEndTime1) kt= true;
   }
   if(inpStartTime1==0 && inpEndTime1==0&&inpStartTime2==0&&inpEndTime2==0&&inpStartTime3==0&&inpEndTime3==0)
      kt=true;
   return kt;
}

bool FunSoSanhThoiGianTime1NhoHonTime2(datetime Time1, datetime Time2)// True : time1<time 2, false: Time 1>=time2
{
  // Print("Time 1: ", Time1, " Time2: ", Time2);

   if(TimeYear(Time1)<TimeYear(Time2)) return true;
   if(TimeYear(Time1)>TimeYear(Time2)) return false;
   if(TimeMonth(Time1)<TimeMonth(Time2)) return true;
   if(TimeMonth(Time1)>TimeMonth(Time2)) return false;

   if(TimeDay(Time1)<TimeDay(Time2)) return true;
   if(TimeDay(Time1)>TimeDay(Time2)) return false;

   if(TimeHour(Time1)<TimeHour(Time1)) return true;
   if(TimeHour(Time1)>TimeHour(Time2)) return false;

   if(TimeMinute(Time1)<TimeMinute(Time2)) return true;
   if(TimeMinute(Time1)>TimeMinute(Time2)) return false;
   if(TimeSeconds(Time1)<TimeSeconds(Time2)) return true; 
   if(TimeSeconds(Time1)>TimeSeconds(Time2)) return false;
   return false;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1].Ticket,SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTapLenh[glbTongSoLenh-1].Ticket=-1;
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
               {  glbTapLenh[glbTongSoLenh-1].Ticket=-1;glbTongSoLenh--;
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
                  glbTapLenh[glbTongSoLenh-1].Ticket=-1;glbTongSoLenh--;  
               }
            }
         }
      }
   }
}

string FunStringTenXuHuong(ENM_XU_HUONG_THI_TRUONG xuhuong)
{
   switch(xuhuong)
   {
      case ENM_TANG: return "TANG";
      case ENM_GIAM: return "GIAM";
      case ENM_SIDE_WAY: return "SIDEWAY";
      default: return "KHONG XAC DINH";
      
   }
}
//**********************************************************************************************************
double FunTinhKhoiLuongTheoMucDanh()
{
   double KhoiLuong=AccountEquity()/inpMucDanh;
   KhoiLuong=NormalizeDouble(KhoiLuong,FunPhanThapPhanKhoiLuong());
   double MinLot=MarketInfo(Symbol(),MODE_MINLOT);
   if(KhoiLuong<glbKhoiLuongNhoNhat )KhoiLuong=glbKhoiLuongNhoNhat;
   if(KhoiLuong<MinLot)KhoiLuong=MinLot;
   return KhoiLuong;
}
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

void FunKiemTraDongLenhTheoSutGiamPhanTramTaiKhoan()
{
   double TongLo=0;
   double KLGiaoDichCuoi=0;
   double SutGiamChoPhep=inpPhanTramSutGiamTaiKhoanChoPhep*AccountBalance()/100;
   for (int i = 0; i < glbTongSoLenh; i++)
   {
      if(OrderSelect(glbTapLenh[i].Ticket,SELECT_BY_TICKET))
      {
         TongLo+=OrderSwap()+OrderProfit()+OrderCommission();
         if(i==glbTongSoLenh-1)
            KLGiaoDichCuoi=OrderLots();
      } 
   }
  // Print("Tong lo: ",TongLo, " Sut giam: ",SutGiamChoPhep);;
   if(TongLo<0 && MathAbs(TongLo)>=SutGiamChoPhep)
   {
      Print("DONG LENH DO SUT GIAM ", inpPhanTramSutGiamTaiKhoanChoPhep, "% TAI KHOAN");
      FunDongTatCaCacLenh();
      if(inpKieuTinhKhoiLuongSauKhiCatLoTatCaLenh==ENM_CHON_THEO_KHOI_LUONG_TRUOC_DO)
         glbKhoiLuongNhoNhat=KLGiaoDichCuoi;
   }
}
