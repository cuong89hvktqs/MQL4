//+------------------------------------------------------------------+
//|                                          Magtingel_KhoangGia.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Button.mqh>
#include <Controls\RadioButton.mqh>
#include <Controls\RadioGroup.mqh>
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
  
enum ENUM_KIEU_MARTINGEL{
   TU_DONG,
   THEO_KHOANG_GIA
};
input double inpKhoiLuong=0.1;// Khoi luong co so:
input int inpTongLoChoPhep=400;//Tong lo cho phep ($):
input int inpMagicNumber=12345;// Magic number:
input int inpSlippage=50;//Slipage:
NgayThang NgayHetHan={25,06,2023};
CPanel myPanel;
CRadioButton rbtn1;
CRadioButton rbtn2;
CRadioGroup          m_radiogroup;    
int XCoSo=0;//pixcel
int YCoSo=40;//pixcel
int KichThuocBang=390;//pixcel
int KhoangCachHang=5;//pixcel
int ChieuDai=50;
int ChieuRong=20;

int glbTongLenh=0;
int glbTapLenh[100]={-1};
double glbLotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
ENUM_KIEU_MARTINGEL glbKieuDanhMatingel=TU_DONG;

int glbLenhLimit=-1;
bool glbChoPhepVaoLenhLimit=true;
double glbHeSoNhanKhoiLuong=1;
int glbTongLoChoPhep=inpTongLoChoPhep;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
   
   FunKhoiTaoGiaoDien();
   
   
   
//---
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
      FunLabelCreate(0,"lblComInfor",0,XCoSo+200,YCoSo+5,0,DoubleToString(MarketInfo(Symbol(),MODE_SPREAD),0),"Tahoma Bold",6);    
      if(glbKieuDanhMatingel==TU_DONG)
         Comment("Tong so lenh: ", glbTongLenh, "    Tong Lo cho phep: ", glbTongLoChoPhep, "\nNHOI LENH TU DONG");
      else 
         Comment("Tong so lenh: ", glbTongLenh, "    Tong Lo cho phep: ", glbTongLoChoPhep, "\nNHOI LENH THEO VUNG GIA");
     
      if(glbTongLenh>0)
      {
         if(glbLenhLimit>0)
         {
            if(OrderSelect(glbLenhLimit,SELECT_BY_TICKET,MODE_TRADES))
            {
               if(OrderType()==OP_BUY||OrderType()==OP_SELL)
               {
                  glbTapLenh[glbTongLenh]=glbLenhLimit;
                  glbTongLenh++;
                  glbLenhLimit=-1;
               }
               else if(OrderCloseTime()>0) glbLenhLimit=-1;
            }
         }
         else// vao lenh limit
         {
            if(glbChoPhepVaoLenhLimit==true)
            {
               if(glbKieuDanhMatingel==TU_DONG)
                  FunVaoLenhLimitTheoKieuTuDong();
               else
                  FunVaoLenhLimitTheoKieuVungGia();
            }
         }
         FunXoaLenhDaDongKhoiMang();   
         
         if(FunTinhTongLoiNhuan()<0 && MathAbs(FunTinhTongLoiNhuan())>glbTongLoChoPhep)
            FunDongTatCaCacLenhCuaCapTien();    
      }
      else 
      {
         if(glbLenhLimit>0) OrderDelete(glbLenhLimit);
         FunReset();
      }
     FunCaiDatSLTPChoLenhVaoBangTay();
  }

//+------------------------------------------------------------------+ 
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(FunKiemDaHetHanChua(NgayHetHan)==true) return;
   if(id==CHARTEVENT_OBJECT_CLICK )
   {
      if(sparam=="btnBuy" || sparam=="btnSell")
      {
         if(glbTongLenh==0)
         {
            string KhoiLuongVaoLenh="";
            FunEditTextGet(KhoiLuongVaoLenh,0,"edtLots");
            int ticket=-1;
            if(sparam=="btnBuy" )ticket=FunVaoLenhSLTPTheoGia(OP_BUY,Ask,FunTinhGiaTriSLCuaLenh(Ask,OP_BUY),0,StringToDouble(KhoiLuongVaoLenh));
            else ticket=FunVaoLenhSLTPTheoGia(OP_SELL,Bid,FunTinhGiaTriSLCuaLenh(Bid,OP_SELL),0,StringToDouble(KhoiLuongVaoLenh));
            if(ticket>0)
            {
               glbTapLenh[glbTongLenh]=ticket;
               glbTongLenh++;
            }
         }
         else
            Alert("KHOGN CHO PHEP VAO LENH DO BOT DANG QUAN LY LENH DA CO");
      }
      if(sparam=="btnLotPlus" || sparam=="btnLotSub")
      {
         string KhoiLuongVaoLenh="";
         FunEditTextGet(KhoiLuongVaoLenh,0,"edtLots");
         double KhoiLuongCoSo=StringToDouble(KhoiLuongVaoLenh);
         if(sparam=="btnLotPlus")
         {
            KhoiLuongCoSo+=glbLotStep;
         }
         else
         {
             KhoiLuongCoSo-=glbLotStep;
             if(KhoiLuongCoSo<0)KhoiLuongCoSo=glbLotStep;
         }
        // Print(KhoiLuongCoSo);
        // Print(glbLotStep);
         FunEditTextChange(0,"edtLots",DoubleToString(KhoiLuongCoSo,FunTinhLotDecimal()));
      }
      if(sparam=="btnCloseAll")
      {
         FunDongTatCaCacLenhCuaCapTien();
         FunXoaLenhDaDongKhoiMang();
      }
      if(sparam=="btnHeSoNhanLotPlus" || sparam=="btnHeSoNhanLotSub")
      {
         string HeSoNhanKhoiLuong="";
         FunEditTextGet(HeSoNhanKhoiLuong,0,"edtHeSoNhanLot");
         double HeSoNhanCoSo=StringToDouble(HeSoNhanKhoiLuong);
         if(sparam=="btnHeSoNhanLotPlus")
         {
            HeSoNhanCoSo+=0.1;
         }
         else
         {
             HeSoNhanCoSo-=0.1;
             if(HeSoNhanCoSo<0)HeSoNhanCoSo=0;
         }
         glbHeSoNhanKhoiLuong=HeSoNhanCoSo;
         FunEditTextChange(0,"edtHeSoNhanLot",DoubleToString(HeSoNhanCoSo,1));
      }
      if(sparam=="btnKhoangCachPlus" || sparam=="btnKhoangCachSub")
      {
         string KhongCachBuoc="";
         FunEditTextGet(KhongCachBuoc,0,"edtKhoangCachBuoc");
         int KhongCachBuocCoSo=(int)StringToInteger(KhongCachBuoc);
         if(sparam=="btnKhoangCachPlus")
         {
            KhongCachBuocCoSo+=1;
         }
         else
         {
             KhongCachBuocCoSo-=1;
             if(KhongCachBuocCoSo<0)KhongCachBuocCoSo=0;
         }
         FunEditTextChange(0,"edtKhoangCachBuoc",IntegerToString(KhongCachBuocCoSo));
         FunEditTextChange(0,"edtKhoangGia1",DoubleToString(0,Digits));
         FunEditTextChange(0,"edtKhoangGia2",DoubleToString(0,Digits));
         FunEditTextChange(0,"edtBuocNhay","Pips");
      }
      
      if(sparam=="btnHeSoNhanPlus" || sparam=="btnHeSoNhanSub")
      {
         string HeSoNhan="";
         FunEditTextGet(HeSoNhan,0,"edtHeSoNhanBuoc");
         double HeSoNhanCoSo=StringToDouble(HeSoNhan);
         if(sparam=="btnHeSoNhanPlus")
         {
            HeSoNhanCoSo+=0.1;
         }
         else
         {
             HeSoNhanCoSo-=0.1;
             if(HeSoNhanCoSo<0)HeSoNhanCoSo=0;
         }
         FunEditTextChange(0,"edtHeSoNhanBuoc",DoubleToString(HeSoNhanCoSo,1));
      }
      if(sparam=="btnDichSLHoaVonPlus" || sparam=="btnDichSLHoaVonSub")
      {
         string KhoangCachBuoc="";
         FunEditTextGet(KhoangCachBuoc,0,"edtSoPipHoaVon");
         int KhongCachBuocCoSo=(int)StringToInteger(KhoangCachBuoc);
         if(sparam=="btnDichSLHoaVonPlus")
         {
            KhongCachBuocCoSo+=1;
         }
         else
         {
             KhongCachBuocCoSo-=1;
             if(KhongCachBuocCoSo<0)KhongCachBuocCoSo=0;
         }
         FunEditTextChange(0,"edtSoPipHoaVon",IntegerToString(KhongCachBuocCoSo));
      }
      if(sparam=="btnDichSLHoaVon")
      {
         string PipSLDichVe="";
         FunEditTextGet(PipSLDichVe,0,"edtSoPipHoaVon");
         if(StringToInteger(PipSLDichVe)!=0)
            FunDichSLCacLenhVeEntry((int)StringToInteger(PipSLDichVe));
      }
      
      ChartRedraw();
   }
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {

      if(sparam=="edtBuocNhay" || sparam=="edtKhoangGia1" ||sparam=="edtKhoangGia2" )
      {
         FunEditTextChange(0,"edtKhoangCachBuoc","0");
         glbKieuDanhMatingel=THEO_KHOANG_GIA;
         glbChoPhepVaoLenhLimit=true;
         if(sparam=="edtBuocNhay" && FunEditGetInteger(0,"edtBuocNhay")>0)
         {
            if(glbTongLenh>0 && glbLenhLimit>0)
            {
               if(OrderDelete(glbLenhLimit))
               {
                  FunVaoLenhLimitTheoKieuVungGia();
               }
            }
         }
      }
      if(sparam=="edtHeSoNhanLot")
      {
        string HeSoNhanLot="";
        FunEditTextGet(HeSoNhanLot,0,"edtHeSoNhanLot");
        if(StringToDouble(HeSoNhanLot)>0)
        {
           glbHeSoNhanKhoiLuong=StringToDouble(HeSoNhanLot);
           if(glbTongLenh>0 && glbLenhLimit>0)
           {
              
              if(OrderDelete(glbLenhLimit))
              {
                  if(glbChoPhepVaoLenhLimit==true)
                  {
                     if(glbKieuDanhMatingel==TU_DONG)
                        FunVaoLenhLimitTheoKieuTuDong();
                     else
                        FunVaoLenhLimitTheoKieuVungGia();
                  }    
              }
           }
           
        }
        else HeSoNhanLot="0";
      }
      if(sparam=="edtKhoangCachBuoc")
      {
         string KhoangCachBuoc="";
         FunEditTextGet(KhoangCachBuoc,0,"edtKhoangCachBuoc");
         if(StringToInteger(KhoangCachBuoc)>0)
         {
             FunEditTextChange(0,"edtKhoangGia1",DoubleToString(0,Digits));
             FunEditTextChange(0,"edtKhoangGia2",DoubleToString(0,Digits));
             FunEditTextChange(0,"edtBuocNhay","Buoc nhay");
             glbKieuDanhMatingel=TU_DONG;
             glbChoPhepVaoLenhLimit=true;
             if(glbTongLenh>0 && glbLenhLimit>0)
             {
                 if(OrderDelete(glbLenhLimit))
                 {
                    FunVaoLenhLimitTheoKieuTuDong();    
                 }
             }
          }
          else
          Alert("GIA TRI KHOANG CACH BUOC NHAY KHONG DUNG. PHAI >0");
      }
      if(sparam=="edtHeSoNhanBuoc")
      {
         if(FunEditGetDouble(0,"edtHeSoNhanBuoc")>0)
         {
             if(glbTongLenh>0 && glbLenhLimit>0)
             {
                 if(OrderDelete(glbLenhLimit))
                 {
                    FunVaoLenhLimitTheoKieuTuDong();    
                 }
             }
         }
      }
      if(sparam=="edtSLTheoGia")
      {
        string GiaSL="";
        FunEditTextGet(GiaSL,0,"edtSLTheoGia");
        if(StringToDouble(GiaSL)>0)
        {
           FunEditTextChange(0,"edtSLTheoPip","0");
           FunCapNhatThaySoiSLChoTatCaCacLenh();
        }
      }
      if(sparam=="edtSLTheoPip")
      {
        string PipSL="";
        FunEditTextGet(PipSL,0,"edtSLTheoPip");
        if(StringToDouble(PipSL)>0)
        {
           FunEditTextChange(0,"edtSLTheoGia",DoubleToString(0,Digits));
           FunCapNhatThaySoiSLChoTatCaCacLenh();
        }
      }
           
      if(sparam=="edtTongLoTuDong")
      {
        string TongToChoPhep="";
        FunEditTextGet(TongToChoPhep,0,"edtTongLoTuDong");
        if(StringToDouble(TongToChoPhep)>=0)
        {
          glbTongLoChoPhep=(int)StringToDouble(TongToChoPhep);
        }
      }
    
   }
}


//+------------------------------------------------------------------+

void FunVaoLenhLimitTheoKieuTuDong()
{
   double HeSoNhanLot=glbHeSoNhanKhoiLuong;
   double HeSoNhanBuocNhay=FunEditGetDouble(0,"edtHeSoNhanBuoc");
   int KhoangBuocNhay=FunEditGetInteger(0,"edtKhoangCachBuoc");
   //Print("HS Lot: ", HeSoNhanLot, " HS Buoc Nhay: ", HeSoNhanBuocNhay," KHoang Buoc nhay: ", KhoangBuocNhay);
   double GiaSL=0;
   double GiaVaoLenh=0;
   double KhoiLuongVaoLenh=0;
   if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         GiaVaoLenh=OrderOpenPrice()-KhoangBuocNhay*MathPow(HeSoNhanBuocNhay,glbTongLenh)*10*Point();
      }
      else GiaVaoLenh=OrderOpenPrice()+KhoangBuocNhay*MathPow(HeSoNhanBuocNhay,glbTongLenh)*10*Point();
      GiaVaoLenh=NormalizeDouble(GiaVaoLenh,Digits);
      KhoiLuongVaoLenh=NormalizeDouble(OrderLots()*HeSoNhanLot,FunTinhLotDecimal());
      GiaSL=FunTinhGiaTriSLCuaLenh(GiaVaoLenh,OrderType());
      int ticket=FunVaoLenhSLTPTheoGia(OrderType()+2,GiaVaoLenh,GiaSL,0,KhoiLuongVaoLenh);
      if(ticket>0)
         glbLenhLimit=ticket;
      else 
      {
         Print("VAO LENH LIMIT TU DONG BI LOI");
         glbChoPhepVaoLenhLimit=false;
      }
   }
}
//+------------------------------------------------------------------+
 void FunVaoLenhLimitTheoKieuVungGia()
 {
   double VungGiaCao=FunEditGetDouble(0,"edtKhoangGia2");
   double VungGiaThap=FunEditGetDouble(0,"edtKhoangGia1");
   int BuocNhay=FunEditGetInteger(0,"edtBuocNhay");
   double VungGiaVaoLenhLimit=0;
   double HeSoNhanLot=glbHeSoNhanKhoiLuong;
   double KhoiLuongVaoLenh=0;
   double GiaSL=0;
   
   if(VungGiaCao<VungGiaThap)
   {
      double Tam=VungGiaCao;
      VungGiaCao=VungGiaThap; VungGiaThap=Tam;
   }
   if(VungGiaCao>0 && VungGiaThap>0 && BuocNhay >0)
   {
      VungGiaVaoLenhLimit=FunTimVungGiaGanNhatDeDatLenh(VungGiaCao,VungGiaThap,BuocNhay);
      if(VungGiaVaoLenhLimit>0)
      {
         if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET,MODE_TRADES))
         {
            VungGiaVaoLenhLimit=NormalizeDouble(VungGiaVaoLenhLimit,Digits);
            KhoiLuongVaoLenh=NormalizeDouble(OrderLots()*HeSoNhanLot,FunTinhLotDecimal());
            GiaSL=FunTinhGiaTriSLCuaLenh(VungGiaVaoLenhLimit,OrderType());
            int ticket=FunVaoLenhSLTPTheoGia(OrderType()+2,VungGiaVaoLenhLimit,GiaSL,0,KhoiLuongVaoLenh);
            if(ticket>0)
               glbLenhLimit=ticket;
            else 
            {
               Print("VAO LENH LIMIT THEO VUNG GIA BI LOI");
               Print("VUng Gia vao lenh: ", VungGiaVaoLenhLimit);
               glbChoPhepVaoLenhLimit=false;
            }
         }
      }
      else
      {
         Print("VAO LENH LIMIT THEO VUNG GIA BI LOI");
         glbChoPhepVaoLenhLimit=false;
      }
   }
   
 }

//+------------------------------------------------------------------+
void FunCaiDatSLTPChoLenhVaoBangTay()
{
   double GiaSL=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         // Chi set SL, TP cho lenh bang tay
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()!=inpMagicNumber)
         {
            if(OrderStopLoss()==0)
            {
               GiaSL=FunTinhGiaTriSLCuaLenh(OrderOpenPrice(),OrderType());
              // Print("Gia SL: ", GiaSL, "i=",i);
               switch(OrderType())
               {
                  case OP_BUY:
                     if(GiaSL<Bid)
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                   break;
                  case OP_SELL:
                     if(GiaSL>Ask)
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE) ;
                  break;
                  case OP_BUYLIMIT:
                     if(GiaSL<OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_SELLLIMIT:
                     if(GiaSL>OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_BUYSTOP:
                        if(GiaSL<OrderOpenPrice())
                           OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_SELLSTOP:
                     if(GiaSL>OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;             
               }
                  
            }
            
         }
      }
   }
}

//+------------------------------------------------------------------+
void FunCapNhatThaySoiSLChoTatCaCacLenh()
{
   double GiaSL=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         // Chi set SL, TP cho lenh bang tay
         if(OrderSymbol()==Symbol())
         {
            {
               GiaSL=FunTinhGiaTriSLCuaLenh(OrderOpenPrice(),OrderType());
              // Print("Gia SL: ", GiaSL, "i=",i);
               switch(OrderType())
               {
                  case OP_BUY:
                     if(GiaSL<Bid)
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                   break;
                  case OP_SELL:
                     if(GiaSL>Ask)
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE) ;
                  break;
                  case OP_BUYLIMIT:
                     if(GiaSL<OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_SELLLIMIT:
                     if(GiaSL>OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_BUYSTOP:
                        if(GiaSL<OrderOpenPrice())
                           OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;
                  case OP_SELLSTOP:
                     if(GiaSL>OrderOpenPrice())
                        OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,OrderTakeProfit(),0,clrNONE);
                  break;             
               }
                  
            }
            
         }
      }
   }
}
//+------------------------------------------------------------------+
double FunTimVungGiaGanNhatDeDatLenh(double VungGiaCao, double VungGiaThap, int BuocNhay)
{
   double VungGiaVaoLenh=0;
   if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)// Tim Vung gia gan nhat cho lenh buy
      {
         double GiaCanSoSanh=OrderOpenPrice();// Tim cai gia gan vung gia vao lenh de so sanh, tim diem vao lenh
         if(OrderOpenPrice()>Bid) GiaCanSoSanh=Bid;
         int i=0;
         do
         {
            VungGiaVaoLenh=VungGiaCao-i*BuocNhay*10*Point();
            if(VungGiaVaoLenh<GiaCanSoSanh && VungGiaVaoLenh>=VungGiaThap)
               break;
            i++;
         }while(VungGiaVaoLenh>=VungGiaThap); 
         if(VungGiaVaoLenh<VungGiaThap) VungGiaVaoLenh=0;
      }
      else// Tim Vung gia gan nhat cho lenh sell
      {  
         double GiaCanSoSanh=OrderOpenPrice();// Tim cai gia gan vung gia vao lenh de so sanh, tim diem vao lenh
         if(OrderOpenPrice()<Bid) GiaCanSoSanh=Bid;
         int i=0;
         do
         {
            VungGiaVaoLenh=VungGiaThap+i*BuocNhay*10*Point();
            if(VungGiaVaoLenh>GiaCanSoSanh && VungGiaVaoLenh<=VungGiaCao)
               break;
            i++;
         }while(VungGiaVaoLenh<=VungGiaCao); 
         if(VungGiaVaoLenh>VungGiaCao) VungGiaVaoLenh=0;
         
      }
   }
   return VungGiaVaoLenh;
}
//+------------------------------------------------------------------+
void FunDichSLCacLenhVeEntry(int SoPipDichVe)
{
   double GiaDichSL=0;
   
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(OrderType()==OP_BUY)
            {
               GiaDichSL=OrderOpenPrice()+SoPipDichVe*10*Point();
               Print("Gia dich SL:", GiaDichSL);
               if(GiaDichSL<Bid)
                  OrderModify(OrderTicket(),OrderOpenPrice(),GiaDichSL,OrderTakeProfit(),0,clrNONE);
            }
            else if(OrderType()==OP_SELL)
            {
               GiaDichSL=OrderOpenPrice()-SoPipDichVe*10*Point();
               Print("Gia dich SL:", GiaDichSL);
               if(GiaDichSL>Ask)
                  OrderModify(OrderTicket(),OrderOpenPrice(),GiaDichSL,OrderTakeProfit(),0,clrNONE);
            }
         }
            
      }
   }

}
//+------------------------------------------------------------------+
double FunTinhTongLoiNhuan()
{
   double tong=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
            tong+=OrderProfit()+OrderSwap()+OrderCommission();
      }
   }
   return tong;
}
//+------------------------------------------------------------------+
double FunTinhGiaTriSLCuaLenh(double DiemVaoLenh, int LoaiLenh)
{
   double GiaSL=0;
   string tam="";
   FunEditTextGet(tam,0,"edtSLTheoGia");
   if(StringToDouble(tam)>0)
   {
      GiaSL=StringToDouble(tam);
      if(LoaiLenh%2==0)
      {
         if(GiaSL>=DiemVaoLenh)
         {
            GiaSL=0;
            Print("NHAP SAI GIA SL CUA LENH");
         }
      }
      else
      {
         if(GiaSL<=DiemVaoLenh) 
         {
            GiaSL=0;
            Print("NHAP SAI GIA SL CUA LENH");
         }
      }
    //  Print("SL theo gia: ", GiaSL);
   }
   else
   {
      FunEditTextGet(tam,0,"edtSLTheoPip");
      if(StringToInteger(tam)>0)
      {
         double PipSL=(int)StringToInteger(tam);
         if(LoaiLenh%2==0) GiaSL=DiemVaoLenh-PipSL*10*Point();
         else GiaSL=DiemVaoLenh+PipSL*10*Point();
      }
     // Print("SL theo pip: ", GiaSL, " Tam:",StringToInteger(tam));
   }
   return GiaSL;
   
}
//+------------------------------------------------------------------+

void FunXoaLenhDaDongKhoiMang()
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
            glbTapLenh[glbTongLenh-1]=-1;
            glbTongLenh--;
         }
      }
   }
}
//+------------------------------------------------------------------+
void FunDongTatCaCacLenhCuaCapTien()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(OrderType()==OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
            }
            else if(OrderType()==OP_SELL)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
            }
            else OrderDelete(OrderTicket());
         }
      }
   }
  FunReset();
}

void FunReset()
{
   glbTongLenh=0;
   ArrayFill(glbTapLenh,0,100,-1);
   glbChoPhepVaoLenhLimit=true;
   glbLenhLimit=-1;
}
//+------------------------------------------------------------------+
int FunTinhLotDecimal()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

//+------------------------------------------------------------------+ 
int FunVaoLenhSLTPTheoPip(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
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
int FunVaoLenhSLTPTheoGia(int LoaiLenh, double DiemVaoLenh,double GiaStopLoss=0, double GiaTakeProfit=0, double KhoiLuongVaoLenh=0)
{
    int Ticket=-1;
    double StopLoss=GiaStopLoss,TakeProfit=GiaTakeProfit;
    Print("Gia vao lenh: ",DiemVaoLenh, " SL: ", StopLoss, " TP: ",TakeProfit, " Khoi luong: ",KhoiLuongVaoLenh);
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    { 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    { 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+ 
void FunKhoiTaoGiaoDien()
{
   myPanel.Create(0,"Bang",0,XCoSo,YCoSo,XCoSo+KichThuocBang-160,YCoSo+KichThuocBang-90);
   myPanel.ColorBackground(clrDarkSlateGray);
   
   FunLabelCreate(0,"lblSwapLong",0,XCoSo+5,YCoSo+5,0,"SW: LONG: ","Tahoma Bold",6,clrWhite);
   FunLabelCreate(0,"txtSwapInfoLong",0,XCoSo+55,YCoSo+5,0,DoubleToString(MarketInfo(Symbol(),MODE_SWAPLONG),2),"Tahoma Bold",6);
   FunLabelCreate(0,"lblSwapShort",0,XCoSo+85,YCoSo+5,0,"SHORT: ","Tahoma Bold",6,clrWhite);
   FunLabelCreate(0,"txtSwapInfoShort",0,XCoSo+120,YCoSo+5,0,DoubleToString(MarketInfo(Symbol(),MODE_SWAPSHORT),2),"Tahoma Bold",6);
   FunLabelCreate(0,"lblCom",0,XCoSo+150,YCoSo+5,0,"SPREAD:","Tahoma Bold",6,clrWhite);
   FunLabelCreate(0,"lblComInfor",0,XCoSo+200,YCoSo+5,0,DoubleToString(MarketInfo(Symbol(),MODE_SPREAD),0),"Tahoma Bold",6);
   
   
   FunButtonCreate(0,"btnBuy",0,XCoSo+5,YCoSo+20,ChieuDai+15,ChieuRong,0,"BUY","Tahoma Bold",7,clrWhite,clrGreen,clrGreen);
   FunButtonCreate(0,"btnLotPlus",0,XCoSo+30+ChieuDai,YCoSo+20,ChieuRong,ChieuRong,0,"+","Tahoma Bold",7,clrBlack,clrWhite,clrWhite);
   FunEditCreate(0,"edtLots",0,XCoSo+ChieuDai+ChieuRong+30,YCoSo+20,ChieuDai/2+5,ChieuRong,DoubleToString(inpKhoiLuong,FunTinhLotDecimal()));
   FunButtonCreate(0,"btnLotSub",0,XCoSo+ChieuDai+ChieuRong+35+ChieuDai/2,YCoSo+20,ChieuRong,ChieuRong,0,"-","Tahoma Bold",7,clrBlack,clrWhite,clrWhite);
   FunButtonCreate(0,"btnSell",0,XCoSo+ChieuDai+2*ChieuRong+45+ChieuDai/2,YCoSo+20,ChieuDai+15,ChieuRong,0,"SELL","Tahoma Bold",7,clrWhite,clrRed,clrRed);
   FunButtonCreate(0,"btnCloseAll",0,XCoSo+5,YCoSo+ChieuRong+26,XCoSo+ChieuDai+2*ChieuRong+55+3*ChieuDai/2,ChieuRong,0,"CLOSE ALL ORDER","Tahoma Bold",7,clrWhite,clrRed,clrRed);
   
   FunLabelCreate(0,"lblHeSoNhanLot",0,XCoSo+5,YCoSo+2*ChieuRong+35,0,"HE SO NHAN LOTS: ","Tahoma Bold",7,clrWhite);
   FunButtonCreate(0,"btnHeSoNhanLotPlus",0,XCoSo+150-ChieuRong,YCoSo+2*ChieuRong+30,ChieuRong,ChieuRong,0,"+","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   FunEditCreate(0,"edtHeSoNhanLot",0,XCoSo+150,YCoSo+2*ChieuRong+30,40,ChieuRong,DoubleToString(1,1));
   FunButtonCreate(0,"btnHeSoNhanLotSub",0,XCoSo+150+40,YCoSo+2*ChieuRong+30,ChieuRong,ChieuRong,0,"-","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);

   
   FunLabelCreate(0,"lblKhoangGia",0,XCoSo+5,YCoSo+3*ChieuRong+45,0,"VUNG GIA: ","Tahoma Bold",7,clrRed);
   FunEditCreate(0,"edtKhoangGia1",0,XCoSo+65,YCoSo+3*ChieuRong+40,50,ChieuRong,DoubleToString(0,Digits),"Tahoma Bold",8,clrRed);
   FunEditCreate(0,"edtKhoangGia2",0,XCoSo+125,YCoSo+3*ChieuRong+40,50,ChieuRong,DoubleToString(0,Digits),"Tahoma Bold",8,clrRed);
   FunEditCreate(0,"edtBuocNhay",0,XCoSo+185,YCoSo+3*ChieuRong+40,40,ChieuRong,"Pips","Tahoma Bold",8,clrRed);
   
   
  
   FunLabelCreate(0,"lblKhoangCachBuoc",0,XCoSo+5,YCoSo+4*ChieuRong+55,0,"THEO BUOC NHAY: ","Tahoma Bold",7,clrYellow);
   FunButtonCreate(0,"btnKhoangCachPlus",0,XCoSo+180-ChieuRong,YCoSo+4*ChieuRong+50,ChieuRong,ChieuRong,0,"+","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   FunEditCreate(0,"edtKhoangCachBuoc",0,XCoSo+180,YCoSo+4*ChieuRong+50,25,ChieuRong,IntegerToString(30));
   FunButtonCreate(0,"btnKhoangCachSub",0,XCoSo+180+25,YCoSo+4*ChieuRong+50,ChieuRong,ChieuRong,0,"-","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   
   FunLabelCreate(0,"lbeHeSoNhanBuoc",0,XCoSo+5,YCoSo+5*ChieuRong+60,0,"HS NHAN BUOC NHAY: ","Tahoma Bold",7,clrYellow);
   FunButtonCreate(0,"btnHeSoNhanPlus",0,XCoSo+180-ChieuRong,YCoSo+5*ChieuRong+55,ChieuRong,ChieuRong,0,"+","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   FunEditCreate(0,"edtHeSoNhanBuoc",0,XCoSo+180,YCoSo+5*ChieuRong+55,25,ChieuRong,DoubleToString(1,1));
   FunButtonCreate(0,"btnHeSoNhanSub",0,XCoSo+180+25,YCoSo+5*ChieuRong+55,ChieuRong,ChieuRong,0,"-","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   
   
   FunLabelCreate(0,"lblSLCacLenh",0,XCoSo+5,YCoSo+6*ChieuRong+70,0,"SL CAC LENH THEO GIA: ","Tahoma Bold",7,clrWhite);
   FunEditCreate(0,"edtSLTheoGia",0,XCoSo+140,YCoSo+6*ChieuRong+65,70,ChieuRong,DoubleToString(0,Digits));
   FunLabelCreate(0,"lblHoac",0,XCoSo+5,YCoSo+7*ChieuRong+80,0,"SL CAC LENH THEO PIPS: ","Tahoma Bold",7,clrWhite);
   FunEditCreate(0,"edtSLTheoPip",0,XCoSo+140,YCoSo+7*ChieuRong+75,50,ChieuRong,IntegerToString(50));
   
   
   FunLabelCreate(0,"lblDichSLHoaVon",0,XCoSo+5,YCoSo+8*ChieuRong+90,0,"DICH SL +PIPS: ","Tahoma Bold",7,clrWhite);
   FunButtonCreate(0,"btnDichSLHoaVonPlus",0,XCoSo+110-ChieuRong,YCoSo+8*ChieuRong+85,ChieuRong,ChieuRong,0,"+","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   FunEditCreate(0,"edtSoPipHoaVon",0,XCoSo+110,YCoSo+8*ChieuRong+85,30,ChieuRong,IntegerToString(20));
   FunButtonCreate(0,"btnDichSLHoaVonSub",0,XCoSo+110+30,YCoSo+8*ChieuRong+85,ChieuRong,ChieuRong,0,"-","Tahoma Bold",8,clrBlack,clrWhite,clrWhite);
   FunButtonCreate(0,"btnDichSLHoaVon",0,XCoSo+110+40+ChieuRong,YCoSo+8*ChieuRong+85,ChieuDai,ChieuRong,0,"DICH+","Tahoma Bold",7,clrWhite,clrRed,clrRed);
   
   FunLabelCreate(0,"lblTongLoTuDong",0,XCoSo+5,YCoSo+9*ChieuRong+100,0,"TONG LO TU DONG: ","Tahoma Bold",7,clrWhite);
   FunEditCreate(0,"edtTongLoTuDong",0,XCoSo+115,YCoSo+9*ChieuRong+95,100,ChieuRong,IntegerToString(inpTongLoChoPhep),"Tahoma Bold",7);
   
}

//+------------------------------------------------------------------+ 
bool FunKiemDaHetHanChua(NgayThang &HanCanKiemTra)// False: Chua; True: Roi
{
   bool kt=false;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;
    }
    return kt;
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
                  const string            font="Tahoma Bold",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrWhite,             // text color
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
                 const string            font="Tahoma Bold",             // font
                 const int               font_size=7,             // font size
                 const color             clr=clrWhite,               // color
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
   TextSetFont(font,font_size,FW_BOLD);
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
                const string           font="Tahoma Bold",             // font
                const int              font_size=8,            // font size
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrWhite,       // border color           
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring              
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
double FunEditGetDouble(const long   chart_ID=0,  // chart's ID
                 const string name="Edit") // object name
  {
//--- reset the error value
   string text;
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(-1);
     }
     
//--- successful execution
   return(StringToDouble(text));
  }

//+------------------------------------------------------------------+
int FunEditGetInteger(const long   chart_ID=0,  // chart's ID
                 const string name="Edit") // object name
  {
//--- reset the error value
   string text;
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(-1);
     }
     
//--- successful execution
   return((int)StringToInteger(text));
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