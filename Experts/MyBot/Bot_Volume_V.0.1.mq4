//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieforex.com"
#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

#import   "kernel32.dll"
int CreateFileW(string Filename,int AccessMode,int ShareMode,int PassAsZero,int CreationMode,int FlagsAndAttributes,int AlsoPassAsZero);
int GetFileSize(int FileHandle,int PassAsZero);
int SetFilePointer(int FileHandle,int Distance,int &PassAsZero[],int FromPosition);
int ReadFile(int FileHandle,uchar &BufferPtr[],int BufferLength,int  &BytesRead[],int PassAsZero);
int CloseHandle(int FileHandle);
#import
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };

NgayThang NgayHetHan={15,07,2024};

input double inpLots=0.02;// Khoi luong giao dich:
input int inpRisk=0; //Rui ro (%- ==0: => Lot co dinh):
input double inpSL=20;// //SL (Mac dinh EU-M5, goll: 500):
input double inpTP=40;//TP (Mac dinh EU-M5, gold: 1000):
input bool  inpChoPhepDichHoaVon=false;// CHo phep dich hoa von:
input double inpDiemCHoPhepoDichHoaVon=20;// Diem cho phep dich hoa von:
input bool inpTrailing = false;// Cho phep trailing stop:
input double inpDiemChoPhepTrailing=21;// Diem cho phep trailing stop (pips):
input int inpTongLenhToiDa=4;// Tong lenh toi da:
input string str1="Dang mac dinh theo gio server san Pepperstone";//CAI DAT GIO MO LENH
input double inpStartTime=8;// Gio mo lenh tu(8h):
input double inpEndTime=22;// Gio mo lenh den(Mua he: 22h; Mua dong: 23h):
input string inpGioNgoaiLe="16-18";// Gio ngoai le khong vao lenh (Mua he: 16-18, mua dong: 17-19; "": Tu dong xac dinh)
input int inpSlippage=50;// Slippage:
input int inpMagicID=1234;// Magic ID number:
//+------------------------------------------------------------------+
union Price
  {
      uchar             buffer[8];
      double            close;
  };

double data[][2];

int BytesToRead;
string    datapath;
string    result;
Price     m_price;
string Ordercomment="Bot vao lenh";
double glbPoint;
int    demsolenhdavao=0;
int glbTapLenh[100];
int glbLoaiLenhDangVao;
int glbTongLenhDangVao=0;
int glbTongLenhDaDong=0;
double glbLevel=0;
int glbGioNgoaiLeCanDuoi=0, glbGioNgoaiLeCanTren=0;
string glbComment;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


int OnInit()
{
    if(!IsDllsAllowed())
    {
      Alert("Make Sure DLL Import is Allowed");
      ExpertRemove();
      return(INIT_FAILED);
    }
    if(FunKiemTraChuaHetHan(NgayHetHan)==false)
    {
      return(INIT_FAILED);
    }   
    glbPoint=10*Point();
    ChartSetInteger(0,17,0,0);
    ChartSetInteger(0,0,1);
    string account_server=AccountInfoString(3);
    if(account_server=="")
    {
         account_server="default";
    }
   
   Ordercomment=IntegerToString(inpMagicID);
   FunKhoiTaoBoLenh();


    datapath=TerminalInfoString(3)+"\\history\\"
               +account_server+"\\"+Symbol()+"60"+".hst"; //changed from 240 to 60 (h4 -> h1)
    FunReadFileHst(datapath);
    FunTimGioNgoaiLe();
    
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll();
    ChartRedraw();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(glbTongLenhDangVao>0 && inpTrailing==true)
        FunTrailingStopCacLenh();
     if(glbTongLenhDangVao>0 && inpChoPhepDichHoaVon==true)
        FunDichHoaVonCacLenh();
    FunKiemTraXoaLenhKhoiMang();
    glbComment="Gio vao lenh: "+DoubleToString(inpStartTime,0)+ " - "+DoubleToString(inpEndTime,0);
    glbComment+="\nGio ngoai le khong vao lenh: "+IntegerToString(glbGioNgoaiLeCanDuoi)+" - "+IntegerToString(glbGioNgoaiLeCanTren);
    glbComment+="\nTong lenh dang vao: "+IntegerToString(glbTongLenhDangVao);
    if(FunKiemTraNgayVaoLenh()==false)
      glbComment+="\nKhong vao them lenh do thu 2 dau tuan hoac thu 6 co nonfam";
    if(glbLevel>Open[0])
   {
      glbComment+="\nBUY - "+DoubleToString( glbLevel,Digits);
   }
   else if(glbLevel>0)glbComment+="\nSELL - "+DoubleToString( glbLevel,Digits);
   glbComment+="\nGia h1: "+DoubleToString(iClose(Symbol(),PERIOD_H1,1));
   Comment(glbComment);

   if(!FunKiemTraSangNenMoiChua()==true)// Chua sang nen moi
    {
        return;
    }
    //Sang nen moi roi
    ChartRedraw();
    // Neu Volume hien tai khung H1 > H1 truoc do: khong kiem tra tiep
    if(iVolume(Symbol(),PERIOD_H1,0)>iVolume(Symbol(),PERIOD_H1,1)) //changed from h4 to h1        // Khoi luong giao dich hiện tại H1 nhỏ hơn trước đó tiếp tục
      return;
    if(!BytesToRead>0)//BytesToRead >0 tiếp tục
      return;
    int pos = -1 ;
  // Print("Vong lap moi:",BytesToRead);
   for(int i =0   ; i <BytesToRead-1 ; i++)// tim ra vi tri nen cuoi cung
     {
     
      if(!(data[i][0]<Time[0]))// nen = nen hien tai, break
         break;
      pos = i + 1;
     }
    // pos=pos-2;
    //Print("pos=",pos," time: ",TimeToString(data[pos][0]), " Level: ",data[pos][1]);
    //Print("Close h1-0: ",iClose(Symbol(),PERIOD_H1,0)," Close h1-1:",iClose(Symbol(),PERIOD_H1,1), " Close h1-2: ",iOpen(Symbol(),PERIOD_H1,2));
//********************************

   glbLevel=NormalizeDouble(data[pos][1],Digits);
   ObjectDelete("level");
   FunMakeLine(glbLevel);

   if(data[pos][1]>Open[0])
   {
      glbComment+="\nBUY - "+DoubleToString( data[pos][1],Digits);
   }
   else glbComment+="\nSELL - "+DoubleToString( data[pos][1],Digits);
   Comment(glbComment);

   if(MarketInfo(Symbol(),MODE_SPREAD)>20)
      return;

   if(pos>0)
   {

      if(glbTongLenhDangVao<inpTongLenhToiDa)//Tong so lenh buy va sell dang nho hon 70
      {
         if(data[pos][1]>Open[0])// Gia mở cua duoi duong line canh buy
            if(FunIsBuyPinbar())// xuat hien pinbar buy, buy
            {
               double BuySL=NormalizeDouble(Ask - inpSL*glbPoint,Digits);
               double BuyTP=NormalizeDouble(Ask + inpTP*glbPoint,Digits);
               if(AccountFreeMarginCheck(Symbol(),OP_BUY,FunGetLots())>0)
                 {
                     if(glbLoaiLenhDangVao==OP_SELL)
                     {
                        FunDongTatCaCacLenh();
                        glbTongLenhDangVao=0;   
                     }
                     if(FunKiemTraGioVaoLenh()==false) {Print("Khong vao lenh BUY do chua toi gio vao lenh");return; }  
                     if(FunKiemTraNgayVaoLenh()==false) {Print("Khong vao lenh BUY do chua toi ngay vao lenh");return; }  
                     int Ticket=OrderSend(Symbol(),OP_BUY,FunGetLots(),Ask,inpSlippage,BuySL,BuyTP,Ordercomment,inpMagicID,0,clrGreen);
                     if(Ticket>0)
                     {
                        glbTapLenh[glbTongLenhDangVao]=Ticket;
                        glbTongLenhDangVao++;
                        if(glbTongLenhDangVao==1)glbLoaiLenhDangVao=OP_BUY;
                     }

                 }
            }

         if(data[pos][1]<Open[0])
            if(FunIsSellPinbar())
            {
               double SellSL=NormalizeDouble(Bid + inpSL*glbPoint,Digits);
               double SellTP=NormalizeDouble(Bid - inpTP*glbPoint,Digits);
               if(AccountFreeMarginCheck(Symbol(),OP_SELL,FunGetLots())>0)
                 {
                     if(glbLoaiLenhDangVao==OP_BUY)
                     {
                        FunDongTatCaCacLenh();
                        glbTongLenhDangVao=0;   
                     }
                     if(FunKiemTraGioVaoLenh()==false) {Print("Khong vao lenh BUY do chua toi gio vao lenh");return; }  
                     if(FunKiemTraNgayVaoLenh()==false) {Print("Khong vao lenh BUY do chua toi ngay vao lenh");return; }  
                     int Ticket=OrderSend(Symbol(),OP_SELL,FunGetLots(),Ask,inpSlippage,SellSL,SellTP,Ordercomment,inpMagicID,0,clrRed);
                     if(Ticket>0)
                     {
                        glbTapLenh[glbTongLenhDangVao]=Ticket;
                        glbTongLenhDangVao++;
                        if(glbTongLenhDangVao==1)glbLoaiLenhDangVao=OP_SELL;
                     }
                 }
            }
      }

   }
    
   return;
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunReadFileHst(string FileName)
  {
   int       j=0;;
   string    strFileContents;
   int       Handle;
   int       LogFileSize;
   int       movehigh[1]= {0};
   uchar     buffer[];
   int       nNumberOfBytesToRead;
   int       read[1]= {0};
   int       i;
   double    mm;
//----- -----
   strFileContents="";
   Handle=CreateFileW(FileName,(int)0x80000000,3,0,3,0,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Handle==-1)
     {
      Comment("");
      return;
     }
   LogFileSize=GetFileSize(Handle,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(LogFileSize<=0)
     {
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((LogFileSize-148)/60==BytesToRead)//148 bytes header
     {
      return;
     }
   SetFilePointer(Handle,148,movehigh,0);
   BytesToRead=(LogFileSize-148)/60;// bars array (single-byte justification) . . . total 60 bytes
   ArrayResize(data,BytesToRead,0);
   nNumberOfBytesToRead=60;
   ArrayResize(buffer,60,0);
   int filehandele=FileOpen(Symbol()+".txt",FILE_WRITE|FILE_TXT,"\n");

   for(i=0; i<BytesToRead; i=i+1)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ReadFile(Handle,buffer,nNumberOfBytesToRead,read,NULL);
      if(read[0]==nNumberOfBytesToRead)// doc duoc 60 byte
        {
         result=StringFormat("0x%02x%02x%02x%02x%02x%02x%02x%02x",buffer[7],buffer[6],buffer[5],buffer[4],buffer[3],buffer[2],buffer[1],buffer[0]);//Ngay thang nam // bar start time
         // close price 8bytes
         m_price.buffer[0] = buffer[32];//// close price byte 1
         m_price.buffer[1] = buffer[33];// close price byte 2
         m_price.buffer[2] = buffer[34];// close price byte 3
         m_price.buffer[3] = buffer[35];// close price byte 4
         m_price.buffer[4] = buffer[36];// close pricebyte 5
         m_price.buffer[5] = buffer[37];// close pricebyte 6
         m_price.buffer[6] = buffer[38];// close pricebyte 7
         m_price.buffer[7] = buffer[39];// close pricebyte 8
         mm=m_price.close;
         data[j][0] = StringToDouble(result);//ngày tháng năm // bar start time
         data[j][1] = mm;//close price
         
          FileWrite(filehandele,IntegerToString(i)+": "+TimeToString(data[j][0])+": "+DoubleToString(data[j][1],Digits));
         j=j+1;
         strFileContents=TimeToString(StringToTime(result),3)+" "+DoubleToString(mm,8);
        
        }
      else
        {
         CloseHandle(Handle);
         return;
        }
     }
   CloseHandle(Handle);
   FileClose(filehandele);
   strFileContents=TimeToString(data[j-1][0])+" "+DoubleToString(data[j-1][1],8)+" "+DoubleToString(data[j-2][1],8)+" "+DoubleToString(data[j-3][1],8);
   
   result=strFileContents;
   //Print("j=",j," data:",strFileContents);
  }
//ReadFileHst <<==--------   --------
//+------------------------------------------------------------------+
void FunCloseBuy()
  {
   bool clo;
   while(FunCheckMarketBuyOrders()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicID)
               if(OrderType()==OP_BUY)
                  clo=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),inpSlippage,clrAqua);

        }
     }

  }
//+------------------------------------------------------------------+
void FunCloseSell()
  {
   bool clo;
   while(FunCheckMarketSellOrders()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicID)
               if(OrderType()==OP_SELL)
                  clo=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),inpSlippage,clrAqua);

        }
     }
  }
//+------------------------------------------------------------------+
int FunCheckMarketSellOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=inpMagicID)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+  
int FunCheckMarketBuyOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=inpMagicID)
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
           }
        }
     }
   return(op);
  }

//+------------------------------------------------------------------+
double FunGetLots()
  {
   double lot;
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(inpRisk!=0)
     {
        double riskmoney=AccountBalance()*inpRisk/100, tickevalue=MarketInfo(Symbol(),MODE_TICKVALUE);
        lot=riskmoney/(tickevalue*inpSL*glbPoint/Point());
        if(lot<minlot)
            lot=minlot;
        if(lot>maxlot)
            lot=maxlot;
     }
   else
      lot=inpLots;
    lot=NormalizeDouble(lot,FunTinhPhanThapPhanKhoiLuong());
   return(lot);
  }
//+------------------------------------------------------------------+
int FunTinhPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

//+------------------------------------------------------------------+
void FunMakeLine(double price)
  {
   string name="level";

   if(price>iOpen(Symbol(),PERIOD_M1,0))
      Comment("BUY = "+DoubleToStr(price,Digits));
   if(price<iOpen(Symbol(),PERIOD_M1,0))
      Comment("SELL= "+DoubleToStr(price,Digits));

   if(ObjectFind(name)!=-1)
     {
      ObjectMove(name,0,iTime(Symbol(),PERIOD_M1,0),price);
      return;
     }
   ObjectCreate(name,OBJ_HLINE,0,0,price);
   ObjectSet(name,OBJPROP_COLOR,clrAqua);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_WIDTH,2);
   ObjectSet(name,OBJPROP_BACK,TRUE);
  }
bool FunIsBuyPinbar()
  {
//start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actHigherPart,actHigherPart1;
   actOp=Open[1];
   actCl=Close[1];
   actHi=High[1];
   actLo=Low[1];
   preOp=Open[2];
   preCl=Close[2];
   preHi=High[2];
   preLo=Low[2];
//SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actHigherPart=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
   actHigherPart1=actHi-actRange*0.4;//helping variable to not have too much counting in IF part
//end of declaratins
//start function body
   double dayRange=FunAveRange4();
   if((actCl>actHigherPart1&&actOp>actHigherPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
//(actHi<(preHi-preRange*0.3))&& //High of PB is NOT higher than 1/2 of previous Bar
      (actLo+actRange*0.25<preLo)) //Nose of the PB is at least 1/3 lower than previous bar
     {

      if(Low[ArrayMinimum(Low,3,2)]>Low[1])
         return (true);
     }
   return(false);

  }//------------END FUNCTION-------------

//+------------------------------------------------------------------+
//| User function AveRange4                                          |
//+------------------------------------------------------------------+
double FunAveRange4()
  {
   double sum=0;
   double rangeSerie[4];

   int i=0;
   int ind=1;
   int startYear=1995;


   while(i<4)
     {
      //datetime pok=Time[pos+ind];
      if(TimeDayOfWeek(Time[ind])!=0)
        {
         sum+=High[ind]-Low[ind];//make summation
         i++;
        }
      ind++;
      //i++;
     } 
//Comment(sum/4.0);
   return (sum/4.0);//make average, don't count min and max, this is why I divide by 4 and not by 6


  }//------------END FUNCTION-------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FunIsSellPinbar()
  {
//start of declarations
   double actOp,actCl,actHi,actLo,preHi,preLo,preCl,preOp,actRange,preRange,actLowerPart, actLowerPart1;
   actOp=Open[1];
   actCl=Close[1];
   actHi=High[1];
   actLo=Low[1];
   preOp=Open[2];
   preCl=Close[2];
   preHi=High[2];
   preLo=Low[2];
//SetProxy(preHi,preLo,preOp,preCl);//Check proxy
   actRange=actHi-actLo;
   preRange=preHi-preLo;
   actLowerPart=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
   actLowerPart1=actLo+actRange*0.4;//helping variable to not have too much counting in IF part
//end of declaratins

//start function body

   double dayRange=FunAveRange4();//Trung binh cua 4 nen truoc do (high-low)
   if((actCl<actLowerPart1&&actOp<actLowerPart)&&  //Close&Open of PB is in higher 1/3 of PB
      (actRange>dayRange*0.5)&& //PB is not too small
//(actLo>(preLo+preRange/3.0))&& //Low of PB is NOT lower than 1/2 of previous Bar
      (actHi-actRange*0.25>preHi)) //Nose of the PB is at least 1/3 lower than previous bar

     {
      if(High[ArrayMaximum(High,3,2)]<High[1])
         return (true);
     }
   return false;
  }//------------END FUNCTION-------------
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(glbGioNgoaiLeCanDuoi==0 || glbGioNgoaiLeCanTren==0)
   {
        if(gio>=inpStartTime && gio<inpEndTime) return true;
   }
   else
   {
        if(gio>=inpStartTime && gio<inpEndTime && (gio<glbGioNgoaiLeCanDuoi||gio>=glbGioNgoaiLeCanTren)) return true;

   }
   
    return false;
}
//+------------------------------------------------------------------+
void FunTimGioNgoaiLe()
{
    if(inpGioNgoaiLe=="")
    {
        if(TimeMonth(TimeCurrent())>=4 && TimeMonth(TimeCurrent())<10) 
         {
               glbGioNgoaiLeCanDuoi=16;
               glbGioNgoaiLeCanTren=18;
         }
         else
         {
               glbGioNgoaiLeCanDuoi=17;
               glbGioNgoaiLeCanTren=19;
         }
    }
    else
    {
        string CacXauCat[];
        ushort u_sep;  
        u_sep=StringGetCharacter("-",0);
        int k=StringSplit(inpGioNgoaiLe,u_sep,CacXauCat);
        glbGioNgoaiLeCanDuoi=StringToInteger(CacXauCat[0]);
        glbGioNgoaiLeCanTren=StringToInteger(CacXauCat[1]);
    }
    
}

//+------------------------------------------------------------------+

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
int FunTinhTongSoLenh()
{
   int dem=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()==inpMagicID)
            dem++;
      }
   }
   return dem;
}
//+------------------------------------------------------------------+
void FunTrailingStopCacLenh()
{
    for(int i=0;i<glbTongLenhDangVao;i++)
    {
         FunTraiLingStopTicket(glbTapLenh[i]);
    }
}
//+------------------------------------------------------------------+
void FunDichHoaVonCacLenh()
{
    for(int i=0;i<glbTongLenhDangVao;i++)
    {
         FunDichHoaVon(glbTapLenh[i],inpDiemCHoPhepoDichHoaVon);
    }
}


 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunTraiLingStopTicket(int ticket)
{
      if(inpDiemChoPhepTrailing<=0) return;
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
        double DiemTrailingStop=inpDiemChoPhepTrailing;
        double SoPipLoiLo=0;
        if(OrderType()==OP_BUY)
        {
            SoPipLoiLo=(Bid -OrderOpenPrice())/glbPoint;
        }
        else if(OrderType()==OP_SELL)
        {
            SoPipLoiLo=(OrderOpenPrice()-Ask)/glbPoint;
        }
       
         if (SoPipLoiLo>DiemTrailingStop)
         {
           // Print("So pip loi lo: ",SoPipLoiLo," Diem trailing: ",DiemTrailingStop);
            double StopLoss=0;
            if(OrderType()==1)//lệnh sell
            {
            
               StopLoss=Bid+ DiemTrailingStop*glbPoint;
               if(OrderStopLoss()>StopLoss && StopLoss<OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh SELL that bai");            
            }
            else if(OrderType()==0)// Lệnh buy
            {
               StopLoss=Bid-DiemTrailingStop*glbPoint;
               if(OrderStopLoss()<StopLoss &&StopLoss>OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh BUY that bai");               
            }
         }
         
      }
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

void FunDongTatCaCacLenh()
{
   while(glbTongLenhDangVao>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenhDangVao-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongLenhDangVao-1]=-1;
            glbTongLenhDangVao--;
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
               {  glbTapLenh[glbTongLenhDangVao-1]=-1;glbTongLenhDangVao--;
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
                  glbTapLenh[glbTongLenhDangVao-1]=-1;glbTongLenhDangVao--;
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
   for(int i=0;i<glbTongLenhDangVao;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongLenhDangVao-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongLenhDangVao--;
         }
      }
   }
}

void FunKhoiTaoBoLenh()
{
   glbTongLenhDangVao=0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()==inpMagicID)
         {
            glbTapLenh[glbTongLenhDangVao]=OrderTicket();
            glbTongLenhDangVao++;
            if(glbTongLenhDangVao==1)glbLoaiLenhDangVao=OrderType();
         }
      }
   }
   
}

void FunDichHoaVon(int ticket, double SoPipDeDichHoaVon)
{
   //if(inpBreakeven<=0) return;
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice())
         {
            if(Bid>=(OrderOpenPrice()+SoPipDeDichHoaVon*10*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point(),OrderTakeProfit(),0,clrNONE))
                Print("Dich hoa von LOI");  
              // else Print("Breakeven");  
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice())
         {
            if(Bid<=(OrderOpenPrice()-SoPipDeDichHoaVon*Point()))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("Dich hoa von bi LOI");  
               //Dic else Print("Breakeven"); 
         }
      }
      
   }

}

bool FunKiemTraNgayVaoLenh()// Thu 2 khong vao lenh, thu 6 dau thang khong vao lenh
{
   if(DayOfWeek()==1)return false;
   if(DayOfWeek()==5)// Thu 6
   {
      if(Day()<8) return false;//Norn farm khong vao lenh
   }
   return true;
}
 