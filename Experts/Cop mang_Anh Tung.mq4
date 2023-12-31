#property copyright "abc"
#property link      "tailieuforex.com"
#property version   "1.00"
#property strict

enum type_trade  // Enumeration of named constants 
   { 
    BUY=0,
    SELL=1,
    NONE=-1,
   };
enum ENM_CAIDAT_THOI_GIAN
{
   ENM_ON,// GIOI HAN THOI GIAN MO LENH
   ENM_OFF// MO LENH LIEN TUC 24h
};
  enum ENM_CHON_MUI_GIO
  {
   ENM_TINH_THEO_GIO_SAN,//MUI GIO SAN GIAO DICH
   ENM_GIO_VIET_NAM//MUI GIO VIET NAM
  };
 enum ENM_KIEU_NHOI_LENH
{
   ENM_THEO_GIA_MO_LENH,//THEO GIA MO LENH BAN DAU
   ENM_THEO_GIA_NEN_DONG_CUA//THEO GIA NEN DONG CUA
};
input type_trade Type_Trade=BUY;
input double Lot= 1;
input int Number_Trade=1;// So lenh su dung lot magic, sau lenh nay khoi luong su dung he so cong
input double Lot_Plus=1;// He so cong lot
input string Lot_magic="1";
input ENM_KIEU_NHOI_LENH inpKieu_Nhoi_Lenh=ENM_THEO_GIA_NEN_DONG_CUA;//Kieu nhoi lenh
input bool inpCho_Phep_Nhoi_Khi_Dang_Lai=false;// Cho phep nhoi lenh khi lenh nhoi truoc do dang lai:
input double Steep_pip=100;
input int Profit_pip=200;
input bool inpChoPhepTangKhoangCachNhoiLenh=true;//Bat tang khoang cach pips nhoi lenh
input int inpSoLenhTangKhoangCachLv1=5;//So lenh bat dau tang khoang cach pips Lv1 (>=2):
input double inpSoPipTangKhoangCachLv1=100;//Khoang cach pips nhoi lenh khi tang Lv1:
input int inpSoLenhTangKhoangCachLv2=10;//So lenh bat dau tang khoang cach pips Lv2 (>=2):
input double inpSoPipTangKhoangCachLv2=200;//Khoang cach pips nhoi lenh khi tang Lv2:
input int inpSoLenhTangKhoangCachLv3=15;//So lenh bat dau tang khoang cach pips Lv3 (>=2):
input double inpSoPipTangKhoangCachLv3=300;//Khoang cach pips nhoi lenh khi tang Lv3:
input bool Xuoi_Order_History=false;
input string Key="abc ";
input int inpSoLenhToiDa=10;// So lenh toi da:
input double inpSoLotToiDa=10;//So lot toi da:
input double inpKhoanLoToiDaChoPhepTheoPhanTram=20;// Lo toi da cho phep tinh theo % :
input int inpKhoanLoTheoMoney=200;// Lo toi da cho phep tinh theo $ (=0: Se tinh theo %)
input bool inpChoPhepTuyChinhBuocLenh=false;// Cho phep tuy chinh buoc lenh:
input string inpBuocLenhTuyBien="100,200,200,200";
//input string inpCaiDatThoiGian="CAI DAT KHUNG GIO MO LENH";// KHUNG GIO MO LENH
input ENM_CAIDAT_THOI_GIAN inpChoPhepCaiDatThoiGian=ENM_ON;// Cho phep cai dat thoi gian mo lenh:
input ENM_CHON_MUI_GIO inpMuiGio=ENM_TINH_THEO_GIO_SAN;// Lua chon mui gio:
input string str0="NEU GIO DONG CUA < GIO MO CUA: CHO PHEP DANH XUYEN DEM";//LUU Y:
input double inpKhungGioMoLenh2=4;// Khung gio mo lenh thu 2:
input double inpKhungGioDongLenh2=24;// Khung gio dong lenh thu 2:
input double inpKhungGioMoLenh3=4;// Khung gio mo lenh thu 3:
input double inpKhungGioDongLenh3=24;// Khung gio dong lenh thu 3:
input double inpKhungGioMoLenh4=4;// Khung gio mo lenh thu 4:
input double inpKhungGioDongLenh4=24;// Khung gio dong lenh thu 4:
input double inpKhungGioMoLenh5=4;// Khung gio mo lenh thu 5:
input double inpKhungGioDongLenh5=24;// Khung gio dong lenh thu 5:
input double inpKhungGioMoLenh6=4;// Khung gio mo lenh thu 6:
input double inpKhungGioDongLenh6=24;// Khung gio dong lenh thu 6:
input double inpKhungGioMoLenh7=4;// Khung gio mo lenh thu 7:
input double inpKhungGioDongLenh7=24;// Khung gio dong lenh thu 7:

input double inpDongLenhKhiTaiKhoanNhoHon=0;// Dong lenh khi tai khoan nho hon ($):
input double inpDongLenhKhiTaiKhoanLonHon=0;// Dong lenh khi tai khoan lon hon ($):
input bool inpChoPhepDongLenhXongTheoVonVaoLenhTiep=false;// Cho phep vao lenh tiep sau khi dong lenh theo von ($):
datetime CheckTime;
double Point_sym;
int DIGIT;
int MAGIC;
double PRICE,STOPLOSS;
bool Active=true;

struct Account_info //bien mang cho Bittrex_getmarketsummaries(URL);
{
   ulong Acc;
   datetime Time_End;
}; Account_info Account[];
bool glbDaNhoiLenhTheoNenChua=false;
double glbTongLo=0;
double glbTongToToiDaChoPhep=0;
void init()
{
   ObjectsDeleteAll();
   Point_sym=TinhPoint(Symbol());
   DIGIT=MarketInfo(Symbol(),MODE_DIGITS);
   glbDaNhoiLenhTheoNenChua=false;
   if(inpKhoanLoTheoMoney>0)glbTongToToiDaChoPhep=inpKhoanLoTheoMoney;
   else
   {
      if(inpKhoanLoToiDaChoPhepTheoPhanTram>0) glbTongToToiDaChoPhep=inpKhoanLoToiDaChoPhepTheoPhanTram*AccountBalance()/100;
   }
   Array();
   Arr_Account();// khởi tại account info
   FunButtonCreate(0,"btnDongLenh",0,80,20,70,40,CORNER_RIGHT_UPPER,"Close All","Arial",10,clrBlue,clrPink);
   /*
   string namesever=AccountServer();
   StringToUpper(namesever);
   if(StringFind(namesever,"DEMO",0)<0 &&  StringFind(namesever,"TRIAL",0)<0){
      if(Check_Account(AccountNumber())==false){Active=false;Alert("Account Invalid");return;}
      if(Check_Time(TimeCurrent())==false){Active=false;Alert("Account Expires");return;}
   }*/
}
string Sym_Master;

void start(){
   if(Active==false){return;}
   if(TimeCurrent()>D'2100.12.30'){Alert("Robot het han");return;}
   //NHOI LENH
   if(FunKiemTraSangNenMoiChua()==true)
   {
      glbDaNhoiLenhTheoNenChua=false;
   }
      
   if(Check_Mar(Symbol(),OP_BUY,Key)==true)// đang có lệnh, lay gia cua lenh cuoi cung va vào lênh tiếp theo dựa vào MAGIC
   {
      if(inpKieu_Nhoi_Lenh==ENM_THEO_GIA_MO_LENH)
         MARTINGALE(Symbol(),OP_BUY,Point_sym,Key);//Nhoi lenh
      else  MARTINGALE_BY_CLOSE_PRICE_CANDEL(Symbol(),OP_BUY,Point_sym,Key);//Nhoi lenh
      Price_TP(Symbol(),OP_BUY,Profit_pip,0,Point_sym,Key);// DIch TP
      // DOng lenh khi vuot qua khoan lo cho phep
      FunXuLyLenhKhiVuotQuaKhoanLoChoPhep();
      
   }
   if(Check_Mar(Symbol(),OP_SELL,Key)==true)// đang có lệnh vào lênh tiếp theo dựa vào MAGIC
   {
      if(inpKieu_Nhoi_Lenh==ENM_THEO_GIA_MO_LENH)
         MARTINGALE(Symbol(),OP_SELL,Point_sym,Key);
      else  MARTINGALE_BY_CLOSE_PRICE_CANDEL(Symbol(),OP_SELL,Point_sym,Key);//Nhoi lenh
      Price_TP(Symbol(),OP_SELL,Profit_pip,0,Point_sym,Key);//Dich TP
      // DOng lenh khi vuot qua khoan lo cho phep
      FunXuLyLenhKhiVuotQuaKhoanLoChoPhep();
   }
   // VAO lENH DAU TIEN
   int trend=Type_History(Symbol(),Key);// Lenh cuoi cùng đống là lệnh gì: -1: Chưa xác định
   if(FunKiemTraGioVaoLenh()==true)
   {
     // Comment("Doi lenh");
      if(trend==-1 && Type_Trade!=-1){
         if(DAT_LENH(Symbol(),Type_Trade,0,0,Array_lot[0],Key+"|"+1,0,Point_sym))
            glbDaNhoiLenhTheoNenChua=true;
      }else{
         if(Xuoi_Order_History==true){//Vao lenh xuoi theo lenh history
            if(DAT_LENH(Symbol(),trend,0,0,Array_lot[0],Key+"|"+1,0,Point_sym))
               glbDaNhoiLenhTheoNenChua=true;
         }else{// Vao lenh nguoc theo history
            if(trend==OP_BUY){
               if(DAT_LENH(Symbol(),OP_SELL,0,0,Array_lot[0],Key+"|"+1,0,Point_sym))
                  glbDaNhoiLenhTheoNenChua=true;
            }else{
               if(DAT_LENH(Symbol(),OP_BUY,0,0,Array_lot[0],Key+"|"+1,0,Point_sym))
                  glbDaNhoiLenhTheoNenChua=true;
            }
            
         }
      }
   }
   else
       FunDongTatCaCacLenh();
   FunKiemTraDongLenh();
   string Comments="GIO CUA SAN: "+IntegerToString(TimeHour(TimeCurrent()))+":"+IntegerToString(TimeMinute(TimeCurrent()));
   Comments+="\nTong lo hien tai: "+DoubleToStr(glbTongLo,2);
   if(glbTongToToiDaChoPhep>0)Comments+="\nTong lo cho phep: "+DoubleToStr(glbTongToToiDaChoPhep,2);
   Comment(Comments);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll();
   
}

bool Check_Mar(string sym,int type,string key_check) // Check lệnh sub
{
   MAGIC=-1;PRICE=0;STOPLOSS=-1;
   // xac đinh magic cuối cùng để xem đang vào bao nhieu lenh, lệnh cuối là giá nào
   for(int j=0; j<=OrdersTotal();j++){
      if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) {continue;}
      
      if(Cat_Chuoi(OrderComment(),"|",0)!=key_check){continue;}   
      if(OrderSymbol()==sym && OrderType()==type && OrderMagicNumber()>MAGIC){
         MAGIC=OrderMagicNumber();
         PRICE=OrderOpenPrice();// Giá lệnh cuối cùng
      }
   }
   if(MAGIC>-1){MAGIC++; return(true);}//đang có lệnh, canh vào lênh tiếp theo
   return(false);
}
// Lenh cuoi cung vào la lenh gi
int Type_History(string sym,string key_check){
   datetime checktime;
   int type=-1;
   for(int j=OrdersHistoryTotal()-1; j>=0;j--){
      if(!OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)) {continue;}
      if(Cat_Chuoi(OrderComment(),"|",0)!=key_check){continue;}
      if(OrderSymbol()==sym && OrderCloseTime()>checktime && OrderType()<2){
         checktime=OrderCloseTime();
         type=OrderType();
      }
   }
   return(type);
}

// =====================HEDGING=====================================================================

void MARTINGALE(string sym,int type,double point,string key_check){

   int convert; double Price,Price_sub,steep,netpip=0,price_sl=0,price_tp=0; 
   if(type==1){Price=MarketInfo(sym,MODE_BID);convert=-1;}
   if(type==0){Price=MarketInfo(sym,MODE_ASK);convert=1;}
   
   steep=Array_steep[MAGIC-1];// So point SL
   Price_sub=PRICE-convert*steep;

   double lot=Array_lot[MAGIC];
   if(MarketInfo(sym,MODE_MINLOT)==0.01){lot=NormalizeDouble(lot,2);}
   if(MarketInfo(sym,MODE_MINLOT)==0.1){lot=NormalizeDouble(lot,1);}
   if(MarketInfo(sym,MODE_MINLOT)==1){lot=NormalizeDouble(lot,0);}
   if(MAGIC==inpSoLenhToiDa || lot>inpSoLotToiDa) 
   {
      Print("Vuot qua so lot cho phep, so lenh cho phep, khong vao them lenh");
      return;
   }
   if(type==0 && Price<=Price_sub){
      MAGIC++;
      DAT_LENH(sym,type,0,0,lot,Key+"|"+MAGIC,MAGIC-1,Point_sym);
   }
   
   if(type==1 && Price>=Price_sub){
      MAGIC++;
      DAT_LENH(sym,type,0,0,lot,Key+"|"+MAGIC,MAGIC-1,Point_sym);
   }
}
void MARTINGALE_BY_CLOSE_PRICE_CANDEL(string sym,int type,double point,string key_check)
{
  // Print("Da nhoi lenh:",glbDaNhoiLenhTheoNenChua);
   if(glbDaNhoiLenhTheoNenChua==true)return;
   int convert; double Price=0,Price_sub,steep,netpip=0,price_sl=0,price_tp=0; 
   if(type==1){Price=MarketInfo(sym,MODE_BID);convert=-1;}
   if(type==0){Price=MarketInfo(sym,MODE_ASK);convert=1;}
   
   steep=Array_steep[MAGIC-1];// So point SL
   Price_sub=iClose(Symbol(),PERIOD_CURRENT,1)-convert*steep;
   //Print("Price: ", PRICE, " SubPrice: ",Price_sub);
   if(inpCho_Phep_Nhoi_Khi_Dang_Lai==false)// KHONG NHOi LENH KHI LENH NHOI CUOI DANG LAI
   {
      if(type==0 && PRICE<=Price_sub) return;
      if(type==1 && PRICE>=Price_sub) return;
   }
  // Print("Price: ",Price_sub);
   double lot=Array_lot[MAGIC];
   if(MarketInfo(sym,MODE_MINLOT)==0.01){lot=NormalizeDouble(lot,2);}
   if(MarketInfo(sym,MODE_MINLOT)==0.1){lot=NormalizeDouble(lot,1);}
   if(MarketInfo(sym,MODE_MINLOT)==1){lot=NormalizeDouble(lot,0);}
   if(MAGIC==inpSoLenhToiDa || lot>inpSoLotToiDa) 
   {
      Print("Vuot qua so lot cho phep, so lenh cho phep, khong vao them lenh");
      return;
   }
   if(type==0 && Price<=Price_sub){
      MAGIC++;
      //Print("VAo lenh");
      if(DAT_LENH(sym,type,0,0,lot,Key+"|"+MAGIC,MAGIC-1,Point_sym))
         glbDaNhoiLenhTheoNenChua=true;
   }
   
   if(type==1 && Price>=Price_sub){
      MAGIC++;
      //Print("VAo lenh");
      if(DAT_LENH(sym,type,0,0,lot,Key+"|"+MAGIC,MAGIC-1,Point_sym))
          glbDaNhoiLenhTheoNenChua=true;
   }
   
}

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

void Price_TP(string sym,int type,double TP_Pip,double profit,double p,string key_check)
{  
   int i,rec,cnt=0;
   double minlot=10000000,sumlot,sumprice;
   
   for(i=0; i<=OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;}
      if(Cat_Chuoi(OrderComment(),"|",0)!=key_check){continue;}   
      if(OrderSymbol()==sym && OrderType()==type){if(OrderLots()<minlot){minlot=OrderLots();}}
   } 
   
   for(i=0; i<=OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;}
      if(Cat_Chuoi(OrderComment(),"|",0)!=key_check){continue;}
      if(OrderSymbol()==sym && OrderType()==type){
         sumprice+=OrderOpenPrice()*(OrderLots()/minlot);
         sumlot+=OrderLots();
      }
   }
   if(minlot==10000000){return;}
   sumprice=sumprice/(sumlot/minlot);
   
   double sl=0;
   double tp=0;
   if(TP_Pip==0){
      tp=(profit/(sumlot*TICK*DIG))*p;
      if(type==0){
         tp=NormalizeDouble(sumprice+tp,DIGIT);
      }else
      if(type==1){
         tp=NormalizeDouble(sumprice-tp,DIGIT);
      }
   }else{
      TP_Pip=MathAbs(TP_Pip);
      if(type==0){
         tp=NormalizeDouble(sumprice+TP_Pip*p,DIGIT);
      }else
      if(type==1){
         tp=NormalizeDouble(sumprice-TP_Pip*p,DIGIT);
      }
   } 
   
   for(i=0; i<=OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;}
      if(Cat_Chuoi(OrderComment(),"|",0)!=key_check){continue;}
      if(OrderSymbol()==sym && OrderType()==type){
         if(OrderTakeProfit()!=tp){rec=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,NULL);}
         //if(OrderStopLoss()!=sl && sl>0){rec=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,NULL);}
      }
   }
}

bool DAT_LENH(string sym,int type,double SL_Pip,double TP_Pip,double lot,string cmt,int magic,double point)//Đặt lệnh
{
   if(KiemTra_LenhTreo(sym,type,magic,cmt)==true)// ĐANG CÓ LỆNH RỒI có MAGIC rồi, khong vào lênh nữa
   {return(false);}
   double StopLoss_point=SL_Pip*point, TakeProfit_point=TP_Pip*point;
   double Price=0; double SL=0, TP = 0; color Mau=clrRed;
   //Print("hello");
//=====================================================================
   if(type==0) // Dat lenh BUY -------------------------------------
   {
      Price = MarketInfo(sym,MODE_ASK);
      if(SL_Pip!=0){SL = Price-StopLoss_point;}
      if(TP_Pip!=0){TP = Price+TakeProfit_point;}
      Mau = clrAliceBlue;
   }
   else if(type == 1)//Dat lenh SELL ------------------------------------
   {
      Price = MarketInfo(sym,MODE_BID);
      if(SL_Pip!=0){SL = Price+StopLoss_point;}
      if(TP_Pip!=0){TP = Price-TakeProfit_point;}
      Mau = clrRed;
   }
   int rec = OrderSend(sym,type,lot,Price,3,SL,TP,cmt,magic,0,Mau);
   if (rec<=0) {Print("Loi Main: " + GetLastError()+"|"+SL+"|"+TP+"|"+Price);}else{return(true);}
   return(false);
   
}
bool KiemTra_LenhTreo(string sym,int type,int magic,string cmt){
   for(int i=0; i<=OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;}
      if(OrderSymbol()==sym && OrderMagicNumber()==magic && OrderComment()==cmt){return(true);}
     }
     
   return(false);
}


double TICK; int DIG;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TinhPoint(string Sym1)
  {
   double Digit_=MarketInfo(Sym1,MODE_DIGITS); //Tinh so ky tu thap phan sau dau phay cua ma Symbol1
   TICK=MarketInfo(Sym1,MODE_TICKVALUE);
   int Dig=1;
   if(Digit_==3 || Digit_==5) {Dig=10;DIG=10;} else {Dig=1;DIG=1;}
   if(StringFind(Sym1,"GOL",0) >-1 || StringFind(Sym1,"XAU",0) >-1) {Dig=10;DIG=10;}
   if(StringFind(Sym1,"SIL",0) >-1 || StringFind(Sym1,"XGU",0) >-1) {Dig=MathPow(10,Digit_-2);DIG=MathPow(10,Digit_-2);}
   double Point_=MarketInfo(Sym1,MODE_POINT); // Gia tri point
   double convert=Dig*Point_;
   return(convert);
  }

string Cat_Chuoi(string Chuoi, string PhanCach, int index)
{
   int sta=-1, to=StringFind(Chuoi,PhanCach,0);
   
   for (int i=0; i<index; i++)
   {
      sta=StringFind(Chuoi,PhanCach,to);
      to=StringFind(Chuoi,PhanCach,sta+1); 
   }
   
   string CatChuoi=StringSubstr(Chuoi,sta+1,to-sta-1); 
   return(CatChuoi);
}

double Array_lot[300];int Number_Lot;
double Array_steep[300];
void Array()//Biến mảng close- lot
{
   int i,x=0; double lot=0;
   string xau="Bo khoang cach: ";
   if(inpChoPhepTuyChinhBuocLenh==true)FunKhoiTaoBoBuocLenhTuyChinh();
   for(i=0; i<200;i++){
      if(i<=Number_Trade-1){
         Array_lot[i]=double(Cat_Chuoi(Lot_magic,",",i))*Lot;
      }else{
         Array_lot[i]=Array_lot[i-1]+Lot_Plus;
      }
      if(inpChoPhepTuyChinhBuocLenh==false)
      {
         Array_steep[i]=NormalizeDouble(Steep_pip*Point_sym,DIGIT);
         if(inpChoPhepTangKhoangCachNhoiLenh==true)
         {
            if(i>=inpSoLenhTangKhoangCachLv1-2)Array_steep[i]=NormalizeDouble(inpSoPipTangKhoangCachLv1*Point_sym,DIGIT);
            if(i>=inpSoLenhTangKhoangCachLv2-2)Array_steep[i]=NormalizeDouble(inpSoPipTangKhoangCachLv2*Point_sym,DIGIT);
            if(i>=inpSoLenhTangKhoangCachLv3-2)Array_steep[i]=NormalizeDouble(inpSoPipTangKhoangCachLv3*Point_sym,DIGIT);
         }
      }
      xau+=DoubleToString(Array_steep[i])+";  ";
   }
   Print(xau);
}
//+------------------------------------------------------------------+
void FunXuLyLenhKhiVuotQuaKhoanLoChoPhep()
{
   // Tinh toing lo hien tai
   double TongLo=0;
   double LoChoPhep=glbTongToToiDaChoPhep;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      if(OrderSymbol()==Symbol()&& OrderType()<=1 && StringFind( OrderComment(),Key)>=0)
      {
         TongLo+=OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   glbTongLo=TongLo;
   if(MathAbs(TongLo)>=LoChoPhep && TongLo<0 && LoChoPhep>0) 
   {
      FunDongTatCaCacLenh();
      Print("DONG TAT CA CAC LENH DO VUOT QUA LO CHO PHEP. LO HIEN TAI: ",TongLo);
      glbTongLo=0;
   }
}
//+------------------------------------------------------------------+
// XỬ LÝ BƯỚC LỆNH TÙY CHỈNH//
void FunKhoiTaoBoBuocLenhTuyChinh()
{
   if(inpChoPhepTuyChinhBuocLenh==false) return;
   string sep=",";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(inpBuocLenhTuyBien,u_sep,result);
   if(k>0)
   {
        for (int i = 0; i < k; i++)
        {
            Array_steep[i]=NormalizeDouble(StringToDouble(result[i])*Point_sym,DIGIT);
        }
        for (int  j = k; j < 200; j++)
        {
            Array_steep[j]=NormalizeDouble(StringToDouble(result[k-1])*Point_sym,DIGIT);
        }       
   }
   else
   {
        MessageBox("THAM SO BUOC LENH TUY BIEN DANG BI LOI");
        ExpertRemove();
   }
}
bool Check_Account(ulong account)
{
   for(int i=0; i<ArraySize(Account);i++){
      if(account==Account[i].Acc){return(true);}
   }
   return(false);
}

bool Check_Time(datetime time)
{
   for(int i=0; i<ArraySize(Account);i++){
      if(time<Account[i].Time_End){return(true);}
   }
   return(false);
}

void Arr_Account(){
   ArrayResize(Account,4);
   Account[0].Acc=14122713332;   Account[0].Time_End=D'2017.04.05 00:00';
   Account[1].Acc=9014412;       Account[1].Time_End=D'2017.04.04 00:00';
   Account[2].Acc=9014697;       Account[2].Time_End=D'2017.04.05 00:00';
   Account[3].Acc=9014698;       Account[3].Time_End=D'2017.04.05 00:00';
}


 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   if(inpChoPhepCaiDatThoiGian==ENM_OFF) return true;
   datetime timelocal;
   if(inpMuiGio==ENM_TINH_THEO_GIO_SAN)timelocal=TimeCurrent();//TimeLocal();
   else timelocal=TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;
   bool kt=false;
   switch (DayOfWeek())
   {
   case 0:// Chu nhat
    kt=false;
    break;
   case 1:// thu 2
      if(inpKhungGioMoLenh2<=inpKhungGioDongLenh2)
         if(gio>=inpKhungGioMoLenh2 && gio<inpKhungGioDongLenh2) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh2&&gio<24) kt= true;
    break;
    case 2:
      if(inpKhungGioMoLenh3<=inpKhungGioDongLenh3)
         if(gio>=inpKhungGioMoLenh3 && gio<inpKhungGioDongLenh3) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh3&&gio<24) kt= true;
      if(inpKhungGioMoLenh2>inpKhungGioDongLenh2)  
         if(gio>=0 && gio<inpKhungGioDongLenh2) kt=true;
    break;
    case 3:
      if(inpKhungGioMoLenh4<=inpKhungGioDongLenh4)
         if(gio>=inpKhungGioMoLenh4 && gio<inpKhungGioDongLenh4) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh4&&gio<24) kt= true;
      if(inpKhungGioMoLenh3>inpKhungGioDongLenh2)  
         if(gio>=0 && gio<inpKhungGioDongLenh3) kt=true;   
    break;
    case 4:
      if(inpKhungGioMoLenh5<=inpKhungGioDongLenh5)
         if(gio>=inpKhungGioMoLenh5 && gio<inpKhungGioDongLenh5) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh5&&gio<24) kt= true;
      // DAnh xuyen dem cua nagy thu 4
      if(inpKhungGioMoLenh4>inpKhungGioDongLenh4)  
         if(gio>=0 && gio<inpKhungGioDongLenh4) kt=true;
    break;
    case 5:
      if(inpKhungGioMoLenh6<=inpKhungGioDongLenh6)
         if(gio>=inpKhungGioMoLenh6 && gio<inpKhungGioDongLenh6) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh6&&gio<24) kt= true;
      if(inpKhungGioMoLenh5>inpKhungGioDongLenh5)  
         if(gio>=0 && gio<inpKhungGioDongLenh5) kt=true;
    break;
    case 6:
      if(inpKhungGioMoLenh7<=inpKhungGioDongLenh7)
         if(gio>=inpKhungGioMoLenh7 && gio<inpKhungGioDongLenh7) kt= true;
         else kt= false;
      else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
         if(gio>=inpKhungGioMoLenh7&&gio<24) kt= true;
      if(inpKhungGioMoLenh6>inpKhungGioDongLenh6)  
         if(gio>=0 && gio<inpKhungGioDongLenh6) kt=true;
    break;
   default:
    break;
   }
   return kt;
}

void FunKiemTraDongLenh()
{
   if((inpDongLenhKhiTaiKhoanNhoHon>0 && AccountEquity()<=inpDongLenhKhiTaiKhoanNhoHon) || (inpDongLenhKhiTaiKhoanLonHon>0 && AccountEquity()>=inpDongLenhKhiTaiKhoanLonHon))
   {
      FunDongTatCaCacLenh();
      if(inpChoPhepDongLenhXongTheoVonVaoLenhTiep==false)
         ExpertRemove();
   }
}
void FunDongTatCaCacLenh()
{
   for(int j=OrdersTotal()-1; j>=0;j--){
      if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) {continue;}
      if(Cat_Chuoi(OrderComment(),"|",0)!=Key){continue;}   
      if(OrderSymbol()==Symbol() && OrderType()<=1 &&  StringFind( OrderComment(),Key)>=0)
      {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy"); 
               }
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");
               }
            }
      }
   }
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

 void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{

     
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="btnDongLenh")
      {
         FunDongTatCaCacLenh();
         Comment("Doi lenh moi");
          ChartRedraw();
      } 
   }
}
//+------------------------------------------------------------------+
//| TẬP HỢP CÁC HÀM XỬ LÝ ĐƯỜNG LINE                                 |
//+------------------------------------------------------------------+

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