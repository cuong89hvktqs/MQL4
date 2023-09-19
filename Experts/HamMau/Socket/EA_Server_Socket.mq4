//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
#include <socket-library.mqh>

#define SOCKET_LIBRARY_USE_EVENTS
#define def_X_CoSo 0
#define def_Y_COSO 50
#define def_CAO 25
#define def_RONG 45
#define TIMER_FREQUENCY_MS    500
#define KEY_R 82
#define        WIDTH_IMAGE  1250     // Image width to call ChartScreenShot()
#define        HEIGHT_IMAGE 400     // Image height to call ChartScreenShot()

input ushort   InpServerPort = 64644;  // Server port
input string inpChannelName="@cuong89bot";//ID Kenh:
input string inpToken="1735772983:AAG4g3Qem_oGQN3bpTmztuLHiT67bQCsXWs";//Ma Token bot Telegram:

class CMyBot: public CCustomBot
{
   public:
     void ProcessMessages(void)
     {
      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);

         //--- if the message is not processed
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;
            //--- start
            if(text=="/start")
               SendMessage(chat.m_id,"Hello, world! I am bot. \xF680");

            //--- help
            if(text=="/help")
               SendMessage(chat.m_id,"My commands list: \n/start-start chatting with me \n/help-get help");
           }
        }
     }
     void ProcessMessagesGetLatestText(int &Total_signals, string &Messase_Signals[], long &Chat_Id)
     {
      string text="";
      int Total=0;
    //  Print("m_chat:",m_chats.Total());
      //m_chats.Save("test.txt");
      //CCustomChat tam=m_chats.GetCurrentNode();
      //Print("Cac gia tri: ",tam.m_id, " ",tam.m_last.chat_id, "  ",tam.m_new_one.chat_id);
      for(int i=0; i<m_chats.Total(); i++)
      {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
             chat.m_new_one.done=true;
             text=chat.m_new_one.message_text;
             Chat_Id=chat.m_id;
             Messase_Signals[Total]=text;
             Total++;
         }
       }
       Total_signals=Total;
     }
     
};





struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang glbNgayHetHan={30,9,3023};

struct  ThongTinClientGui
{
    string _TenTaiKhoan;
    string _FundName;
    string _TenGroup;
    int _IDTaiKhoan;
    string _AccBalance;
    string _AccEquity;
    string _ProfitDongLenh;
    string _ProfitHienTai;
    string _TrangThai;
    string _Orders;
    double _TongSoLotHomNayVao;
    int _TongSoNgayDaVaoLenh;
    
};
struct  ThongTinMayKhach
{
    string _TenTaiKhoan;
    string _TenGroup;
    int _IDTaiKhoan;
};
// Server socket
ServerSocket * glbServerSocket = NULL;

// Array of current clients
ClientSocket * glbClients[];
ClientSocket * glbManagers[];
ThongTinMayKhach glbThongTinMayKhach[50];
int glbTongSoMayClient=0;
int glbTongSoMayManager=0;
ThongTinClientGui glbThongTinClientGui[100];
// Watch for need to create timer;
bool glbCreatedTimer = false;
int glbTongSoRowClient=0;
int glbCheckConnectBot;
CMyBot glbBotTelegram;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(FunKiemTraChuaHetHan(glbNgayHetHan)==false)
      return INIT_FAILED;
    // If the EA is being reloaded, e.g. because of change of timeframe,
    // then we may already have done all the setup. See the 
   // termination code in OnDeinit.
   if (glbServerSocket) {
      Print("Dang tai lai EA voi socket hien co");
   } else {
      // Create the server socket
      glbServerSocket = new ServerSocket(InpServerPort, false);
      if (glbServerSocket.Created()) {
         Print("Server socket created");
   
         // Note: this can fail if MT4/5 starts up
         // with the EA already attached to a chart. Therefore,
         // we repeat in OnTick()
         glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
      } else {
         Print("Server socket Loi - Co the do port cai dat dang duoc su dung?");
         MessageBox("Server socket Loi - Co the do port cai dat dang duoc su dung?");
         //ExpertRemove();
      }
   } 
   FunThietLapMauNenCuaChart();
   FunCreatTableHeader();
   FunLabelCreate(0,"KetNoi",20,20,"MAY SERVER",clrYellow,15,"Arial",0,0,CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER) ;

   glbBotTelegram.Token(inpToken);
   glbCheckConnectBot=glbBotTelegram.GetMe();
   if(glbCheckConnectBot==0) glbBotTelegram.SendMessage(inpChannelName,"Server Ket noi telegram thanh cong.\nMuon server gui anh gui tin nhan: M");

  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    
   // For any other unload of the EA, delete the 
   // server socket and all the clients 
   
   glbCreatedTimer = false;
   
   // Delete all clients currently connected
   for (int i = 0; i < ArraySize(glbClients); i++) {
      delete glbClients[i];
   }
   ArrayResize(glbClients, 0);
   for (int i = 0; i < ArraySize(glbManagers); i++) {
      delete glbManagers[i];
   }
   ArrayResize(glbManagers, 0);

   // Free the server socket. *VERY* important, or else
   // the port number remains in use and un-reusable until
   // MT4/5 is shut down
   delete glbServerSocket;
   glbServerSocket = NULL;
   Print("Server socket dung hoat dong");
   ObjectsDeleteAll();
}

void OnTimer()
{
   // Accept any new pending connections
   FunAcceptNewConnections();
   
   // Process any incoming data on each client socket,
   // bearing in mind that HandleSocketIncomingData()
   // can delete sockets and reduce the size of the array
   // if a socket has been closed
   int TongClient=ArraySize(glbClients);
   //Print("Tong client : ", TongClient, " Tong may quan ly: ",ArraySize(glbManagers));
   for (int i = TongClient - 1; i >= 0; i--) {
     FunHandleSocketIncomingData(i);
   }
  
   FunDanhDauClientMatKetNoiTrongBang();
   for (int i = 0; i < glbTongSoRowClient; i++)
   {
        FunCreatRowOfTable(i);
   }
   FunGuiDuLieuChoMayManager();
   FunProcessSignalTele();
   ChartRedraw();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (!glbCreatedTimer) glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
    Comment("Tong may manager: ",glbTongSoMayManager);
}

//+------------------------------------------------------------------+
void FunDanhDauClientMatKetNoiTrongBang()
{
   for(int i=0;i<glbTongSoRowClient;i++)
   {
      bool kt=false;
      for(int j=0;j<glbTongSoMayClient;j++)
      {
         if(glbThongTinMayKhach[j]._IDTaiKhoan==glbThongTinClientGui[i]._IDTaiKhoan )
         {
            kt=true;break;
         }
      }
      if(!kt)
      {
         glbThongTinClientGui[i]._TrangThai="Deactive";
         glbThongTinClientGui[i]._ProfitDongLenh="0";
         glbThongTinClientGui[i]._ProfitHienTai="0";
         glbThongTinClientGui[i]._Orders="";
      }
   }
}
//+------------------------------------------------------------------+
void FunAcceptNewConnections()
{
   // Keep accepting any pending connections until Accept() returns NULL
   ClientSocket * pNewClient = NULL;
   do {
      pNewClient = glbServerSocket.Accept();
      if (pNewClient != NULL) 
      {
         string MessageFirst=pNewClient.Receive("\r\n");
         Print("MessageFirst: ",MessageFirst);
         if(StringFind(MessageFirst,"Client")>=0)
         {
            int sz = ArraySize(glbClients);
            ArrayResize(glbClients, sz + 1);
            glbClients[sz] = pNewClient;
            glbTongSoMayClient=sz + 1;
            Print("Co ket noi moi client");  
         }
         else 
         {
            int sz = ArraySize(glbManagers);
            ArrayResize(glbManagers, sz + 1);
            glbManagers[sz] = pNewClient;
            glbTongSoMayManager=sz + 1;
            Print("Co ket noi moi manager");
         }
      }
   } while (pNewClient != NULL);
}
//+------------------------------------------------------------------+
void FunHandleSocketIncomingData(int idxClient)
{
   ClientSocket * pClient = glbClients[idxClient];

   // Keep reading CRLF-terminated lines of input from the client
   // until we run out of new data
   bool bForceClose = false; // Client has sent a "close" message
   string strCommand;
   do {
      strCommand = pClient.Receive("\r\n");
      if (strCommand == "quote") {
         pClient.Send(Symbol() + "," + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_BID), 6) + "," + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_ASK), 6) + "\r\n");
      } else if (strCommand == "close") {
         bForceClose = true;
      } else if (StringFind(strCommand, "FILE:") == 0) {
         // Chua xu ly truyen nhan file
      } else if (strCommand != "") {
         //Print("Xau nhan duoc: ",strCommand);
         FunXuLyXauThongTinNhanTuClient(idxClient,strCommand);
      }
   } while (strCommand != "");
   // If the socket has been closed, or the client has sent a close message,
   // release the socket and shuffle the glbClients[] array
   if (!pClient.IsSocketConnected() || bForceClose) {
      Print("Client mat ket noi");

      // Client is dead. Destroy the object
      delete pClient;
      
      // And remove from the array
      int ctClients = ArraySize(glbClients);
      for (int i = idxClient + 1; i < ctClients; i++) {
         glbClients[i - 1] = glbClients[i];
         glbThongTinMayKhach[i - 1] = glbThongTinMayKhach[i];
      }
      ctClients--;
      ArrayResize(glbClients, ctClients);
      glbTongSoMayClient--;// GIam so may khach di
      
   }
}
//+------------------------------------------------------------------+
void FunGuiDuLieuChoMayManager()
{
   int TongManager=ArraySize(glbManagers);
   //Print(" Tong may quan ly: ",ArraySize(glbManagers));
   for (int idxManager = TongManager - 1; idxManager >= 0; idxManager--) 
   {
      ClientSocket * pManager = glbManagers[idxManager];
      if (!pManager.IsSocketConnected()) //Mat ket noi
      {
         Print("Managers mat ket noi");

         // Client is dead. Destroy the object
         delete pManager;
         
         // And remove from the array
         for (int  i= idxManager + 1; i < TongManager; i++) 
         {
            glbManagers[i - 1] = glbManagers[i];
         }
         TongManager--;
         ArrayResize(glbManagers, TongManager);
         glbTongSoMayManager--;// GIam so may khach di
      }
      else
      {
         for (int  i = 0; i < glbTongSoRowClient; i++)
         {
            pManager.Send(FunDoiThongTinClientThanhXau(glbThongTinClientGui[i])+"\r\n");
            //Print(FunDoiThongTinClientThanhXau(glbThongTinClientGui[i]));
         }
      }
   }
}
//+------------------------------------------------------------------+
void FunXuLyXauThongTinNhanTuClient(int idxClient,string strCommand)
{
   //Print("Xau: ",strCommand);
   string KetQuaXuLyXau[];
   ThongTinClientGui strThongTinClient;
   int k=StringSplit(strCommand,',',KetQuaXuLyXau);
   if(k>0)
   {
      StringReplace(KetQuaXuLyXau[0]," ","");
      StringToUpper(KetQuaXuLyXau[0]);
      strThongTinClient._TenTaiKhoan=KetQuaXuLyXau[0];
      strThongTinClient._FundName=KetQuaXuLyXau[1];
      strThongTinClient._TenGroup=(KetQuaXuLyXau[2]);
      strThongTinClient._IDTaiKhoan=(int)StringToInteger(KetQuaXuLyXau[3]);
      strThongTinClient._AccBalance=(KetQuaXuLyXau[4]);
      strThongTinClient._AccEquity=(KetQuaXuLyXau[5]);
      strThongTinClient._ProfitDongLenh=(KetQuaXuLyXau[6]);
      strThongTinClient._ProfitHienTai=(KetQuaXuLyXau[7]);
      strThongTinClient._Orders=KetQuaXuLyXau[8];
      if(k>10)
      {
         strThongTinClient._TongSoLotHomNayVao=StringToDouble(KetQuaXuLyXau[9]);
         strThongTinClient._TongSoNgayDaVaoLenh=(int)StringToInteger(KetQuaXuLyXau[10]);
      }
      strThongTinClient._TrangThai="Active";
   }
   glbThongTinMayKhach[idxClient]._IDTaiKhoan=strThongTinClient._IDTaiKhoan;
   glbThongTinMayKhach[idxClient]._TenTaiKhoan=strThongTinClient._TenTaiKhoan;
   glbThongTinMayKhach[idxClient]._TenGroup=strThongTinClient._TenGroup;

   bool KiemTraXemCoTrongBangChua=false;
   for (int i = 0; i < glbTongSoRowClient; i++)
   {
      if(glbThongTinClientGui[i]._IDTaiKhoan==strThongTinClient._IDTaiKhoan)
      {
         glbThongTinClientGui[i]=strThongTinClient;
         KiemTraXemCoTrongBangChua=true;
         break;
      }
   }
   if(!KiemTraXemCoTrongBangChua)
   {
      if(strThongTinClient._IDTaiKhoan>0)
      {
         FunChenPhanTuVaoBang( strThongTinClient);
         //glbThongTinClientGui[glbTongSoRowClient]=strThongTinClient;
         //glbTongSoRowClient++;
      }  
   }
}

void FunChenPhanTuVaoBang(ThongTinClientGui &strThongTinClient)
{
   int Vitri=FunTimViTriCanChen(strThongTinClient);
   glbTongSoRowClient++;
   for (int i = glbTongSoRowClient-1; i >Vitri; i--)
   {
      glbThongTinClientGui[i]=glbThongTinClientGui[i-1];
   }
   glbThongTinClientGui[Vitri]=strThongTinClient;
   
}
//+------------------------------------------------------------------+
int FunTimViTriCanChen(ThongTinClientGui &strThongTinClient)
{
   int k=-1, Vitri=glbTongSoRowClient;
   string Name;
   if((k=StringFind(strThongTinClient._TenTaiKhoan," ",0))>=0)
      Name=StringSubstr(strThongTinClient._TenTaiKhoan,k,StringLen(strThongTinClient._TenTaiKhoan)-k);
   else Name=strThongTinClient._TenTaiKhoan;
   for (int i = 0; i < glbTongSoRowClient; i++)
   {
      string XauSoSanh;
      if((k=StringFind(glbThongTinClientGui[i]._TenTaiKhoan," ",0))>=0)
         XauSoSanh=StringSubstr(glbThongTinClientGui[i]._TenTaiKhoan,k,StringLen(glbThongTinClientGui[i]._TenTaiKhoan)-k);
      else XauSoSanh=glbThongTinClientGui[i]._TenTaiKhoan;
      if(StringCompare(Name,XauSoSanh)<0)
      {
         Vitri=i;break;
      }
   }
   return Vitri;
}
//+------------------------------------------------------------------+
string  FunDoiThongTinClientThanhXau(ThongTinClientGui &ThongTinClient)
{
   string s="";
   s+=ThongTinClient._TenTaiKhoan+","+ThongTinClient._FundName+","+ThongTinClient._TenGroup+","+IntegerToString(ThongTinClient._IDTaiKhoan)+
      ","+(ThongTinClient._AccBalance)+ ","+(ThongTinClient._AccEquity)+","+
      (ThongTinClient._ProfitDongLenh)+","+(ThongTinClient._ProfitHienTai)+
      ","+ThongTinClient._Orders+
      ","+ThongTinClient._TrangThai+
      ","+DoubleToString(ThongTinClient._TongSoLotHomNayVao,2)+
      ","+IntegerToString(ThongTinClient._TongSoNgayDaVaoLenh);
       
   return s;
}
//+------------------------------------------------------------------+
void FunXuLyXauThongTinNhanDuoc(int idxClient,string strCommand)
{
   string KetQuaXuLyXau[];
   int k=StringSplit(strCommand,',',KetQuaXuLyXau);
   if(k>0)
   {
      StringReplace(KetQuaXuLyXau[0]," ","");
      StringToUpper(KetQuaXuLyXau[0]);
      glbThongTinClientGui[idxClient]._TenTaiKhoan=KetQuaXuLyXau[0];
      glbThongTinClientGui[idxClient]._FundName=KetQuaXuLyXau[1];
      glbThongTinClientGui[idxClient]._TenGroup=KetQuaXuLyXau[2];
      glbThongTinClientGui[idxClient]._IDTaiKhoan=(int)StringToInteger( KetQuaXuLyXau[3]);
      glbThongTinClientGui[idxClient]._AccBalance=(KetQuaXuLyXau[4]);
      glbThongTinClientGui[idxClient]._AccEquity=(KetQuaXuLyXau[5]);
      glbThongTinClientGui[idxClient]._ProfitDongLenh=(KetQuaXuLyXau[6]);
      glbThongTinClientGui[idxClient]._ProfitHienTai=(KetQuaXuLyXau[7]);
      glbThongTinClientGui[idxClient]._Orders=KetQuaXuLyXau[8];
   }
}
//+------------------------------------------------------------------+
void FunThietLapMauNenCuaChart(const long chart_ID=0)
{
    ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clrBlack);
    ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clrWhite);
    ChartSetInteger(chart_ID,CHART_COLOR_GRID,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_LINE,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_VOLUME,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_BID,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_ASK,clrNONE);
}
//+------------------------------------------------------------------+
void FunCreatTableHeader()
{
    // Creat header
    FunLabelCreate(0,"No",def_X_CoSo+5,def_Y_COSO,"No",clrWhite) ;
    FunLabelCreate(0,"Name",def_X_CoSo+def_RONG-10,def_Y_COSO,"Name",clrWhite) ;
    FunLabelCreate(0,"Server",(int)(def_X_CoSo+3.5*def_RONG),def_Y_COSO,"Server",clrLimeGreen) ;
    FunLabelCreate(0,"Accout",(int)(def_X_CoSo+5.4*def_RONG),def_Y_COSO,"Accout",clrWhite) ;
    FunLabelCreate(0,"Group",def_X_CoSo+7.8*def_RONG,def_Y_COSO,"Group",clrWhite) ;
    FunLabelCreate(0,"Day",def_X_CoSo+9*def_RONG,def_Y_COSO,"Day",clrWhite) ;
    FunLabelCreate(0,"Balance",def_X_CoSo+10*def_RONG,def_Y_COSO,"Balance",clrWhite) ;
    FunLabelCreate(0,"Equity",def_X_CoSo+12.2*def_RONG,def_Y_COSO,"Equity",clrWhite) ;
    FunLabelCreate(0,"ToDayProfit",def_X_CoSo+14.2*def_RONG,def_Y_COSO,"ToDayProfit",clrWhite) ;
    FunLabelCreate(0,"Profit",int(def_X_CoSo+16.6*def_RONG),def_Y_COSO,"Profit",clrWhite) ;
    FunLabelCreate(0,"Orders",int(def_X_CoSo+18.6*def_RONG),def_Y_COSO,"Orders",clrWhite) ;
    FunLabelCreate(0,"Status",def_X_CoSo+24*def_RONG,def_Y_COSO,"Status",clrWhite) ;
}


void FunCreatRowOfTable(int idxRow)
{
    string RowName_No="No"+IntegerToString(idxRow);
    string RowName_Name="Name"+IntegerToString(idxRow);
    string RowName_Server="Server"+IntegerToString(idxRow);
    string RowName_Accout="Accout"+IntegerToString(idxRow);
    string RowName_Group="Group"+IntegerToString(idxRow);
    string RowName_Day="Day"+IntegerToString(idxRow);
    string RowName_Balance="Balance"+IntegerToString(idxRow);
    string RowName_Equity="Equity"+IntegerToString(idxRow);
    string RowName_ToDayProfit="ToDayProfit"+IntegerToString(idxRow);
    string RowName_Profit="Profit"+IntegerToString(idxRow);
    string RowName_Status="Status"+IntegerToString(idxRow);
    string RowName_Orders="Orders"+IntegerToString(idxRow);
    int Y_COSO=def_Y_COSO+(idxRow+1)*def_CAO;
    FunLabelCreate(0,RowName_No,def_X_CoSo+5,Y_COSO,IntegerToString(idxRow+1),clrWhite) ;
    FunLabelCreate(0,RowName_Name,def_X_CoSo+def_RONG-10,Y_COSO,glbThongTinClientGui[idxRow]._TenTaiKhoan,clrWhite) ;
    FunLabelCreate(0,RowName_Server,(int)(def_X_CoSo+3.5*def_RONG),Y_COSO,glbThongTinClientGui[idxRow]._FundName,clrWhite) ;
    FunLabelCreate(0,RowName_Accout,(int)(def_X_CoSo+5.4*def_RONG),Y_COSO,IntegerToString(glbThongTinClientGui[idxRow]._IDTaiKhoan),clrWhite) ;
    FunLabelCreate(0,RowName_Group,def_X_CoSo+7.8*def_RONG,Y_COSO,glbThongTinClientGui[idxRow]._TenGroup,clrYellow) ;
    
    FunLabelCreate(0,RowName_Day,def_X_CoSo+9*def_RONG,Y_COSO,IntegerToString(glbThongTinClientGui[idxRow]._TongSoNgayDaVaoLenh),clrRed) ;
    if(glbThongTinClientGui[idxRow]._TongSoLotHomNayVao>0)
      FunLabelChangeColor(0,RowName_Day,C'8,241,8');
    
    FunLabelCreate(0,RowName_Balance,def_X_CoSo+10*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._AccBalance),clrWhite) ;
    
    
    FunLabelCreate(0,RowName_Equity,def_X_CoSo+12.2*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._AccEquity),clrWhite) ;
    
    FunLabelCreate(0,RowName_ToDayProfit,def_X_CoSo+14.2*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._ProfitDongLenh),clrLimeGreen) ;
    if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitDongLenh)<0)
        FunLabelChangeColor(0,RowName_ToDayProfit,clrRed);
    else if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitDongLenh)==0)
        FunLabelChangeColor(0,RowName_ToDayProfit,clrWhite);
    
    
    FunLabelCreate(0,RowName_Profit,(int)(def_X_CoSo+16.6*def_RONG),Y_COSO,(glbThongTinClientGui[idxRow]._ProfitHienTai),clrLimeGreen) ;
    if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitHienTai)<0)
        FunLabelChangeColor(0,RowName_Profit,clrRed);
    else if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitHienTai)==0)
        FunLabelChangeColor(0,RowName_Profit,clrWhite); 

    FunLabelCreate(0,RowName_Orders,(int)(def_X_CoSo+18.6*def_RONG),Y_COSO,(glbThongTinClientGui[idxRow]._Orders),clrWhite) ;
    FunLabelCreate(0,RowName_Status,def_X_CoSo+24*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._TrangThai),clrLimeGreen) ;
    if(glbThongTinClientGui[idxRow]._TrangThai=="Deactive")
        FunLabelChangeColor(0,RowName_Status,clrRed);
}
void FunRemoveRowOfTable (int idxRow)
{
   string RowName_No="No"+IntegerToString(idxRow);
   string RowName_Name="Name"+IntegerToString(idxRow);
   string RowName_Server="Server"+IntegerToString(idxRow);
   string RowName_Accout="Accout"+IntegerToString(idxRow);
   string RowName_Group="Group"+IntegerToString(idxRow);
   string RowName_Day="Day"+IntegerToString(idxRow);
   string RowName_Balance="Balance"+IntegerToString(idxRow);
   string RowName_Equity="Equity"+IntegerToString(idxRow);
   string RowName_ToDayProfit="ToDayProfit"+IntegerToString(idxRow);
   string RowName_Profit="Profit"+IntegerToString(idxRow);
   string RowName_Status="Status"+IntegerToString(idxRow);
   string RowName_Orders="Orders"+IntegerToString(idxRow);
   FunLabelDelete(0,RowName_No);
   FunLabelDelete(0,RowName_Name);
   FunLabelDelete(0,RowName_Server);
   FunLabelDelete(0,RowName_Accout);
   FunLabelDelete(0,RowName_Group);
   FunLabelDelete(0,RowName_Day);
   FunLabelDelete(0,RowName_Balance);
   FunLabelDelete(0,RowName_Equity);
   FunLabelDelete(0,RowName_ToDayProfit);
   FunLabelDelete(0,RowName_Profit);
   FunLabelDelete(0,RowName_Status);
   FunLabelDelete(0,RowName_Orders);
}

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name               
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const string            text="Label",             // text
                 const color             clr=clrWheat,               // color
                 const int               font_size=11,             // font size
                 const string            font="Arial",             // font
                 const int               sub_window=0,             // subwindow index
                 const double            angle=0.0,                // text slope
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring              
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
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunLabelChangeText(const long   chart_ID=0,  // chart's ID
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
bool FunLabelChangeColor(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const color clr=clrWhite) // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the color! Error code = ",GetLastError());
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
void OnChartEvent(const int id,const long &lparam,const double& dparam,const string& sparam)
{
   if(id==CHARTEVENT_KEYDOWN)
   {
      if((int)lparam==KEY_R)
      {
         for(int i=0;i<glbTongSoRowClient; i++)
            FunRemoveRowOfTable(i);
         glbTongSoRowClient=0;
      }
   }
}

 void FunProcessSignalTele()
 {
     // Caapj nhat msg moi
   int Total_Signal=0;
   long Chat_Id=-1;
   string Message_Signal[100];
   
   glbBotTelegram.GetUpdatesV1_Chanel();
   glbBotTelegram.ProcessMessagesGetLatestText(Total_Signal,Message_Signal,Chat_Id);
   // Xu ly msg den
   for(int j=0;j<Total_Signal;j++)
   {
      string TeleString=Message_Signal[j];
      if(TeleString!="")Print("Tin nhan tu telegram: ",TeleString, ", chat id: ",Chat_Id);
      if(TeleString=="M"||TeleString=="m")
      {
         if(ChartScreenShot(0,"server.png",WIDTH_IMAGE,HEIGHT_IMAGE,ALIGN_RIGHT))
         {
            //glbBotTelegram.GetUpdatesV2_Chanel()
            //glbBotTelegram.SendPhoto(Chat_Id,"server.jpg","Server Image");
            string nameImageFile_id="";
            Print(glbBotTelegram.SendPhoto(nameImageFile_id,inpChannelName,"server.png","",false,1000));
            //Print("Image id: ",nameImageFile_id);
            
         }
      }
   }
 }