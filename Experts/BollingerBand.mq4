//+------------------------------------------------------------------+
//|                                                   MACDRSIADI.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Expert strategy:                                                  |
//|    When MACD trade signal happen, chekc RSI, and STO status      |
//|    When STO trade signal happen, check RSI and MACD              |
//|    Always create Trailing stop together.                         |
//+------------------------------------------------------------------+



#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input double   TakeProfit=120.0;
input double   Lots=0.1;
input double   TrailingStop=20.0;
input double   StopLoss = 70.0;
input int      MaxOpenPosition = 1;
input double   MACDOpenLevel=3.0;
input double   MACDCloseLevel=2.0;
input int      MATrendPeriod=26;
input int      MASmaPeriod=9;
input int      MAFastEMAPeriod=12;
input int      MAShort = 10;
input int      MaLong = 50;
input int      RSIPeriod=14;
input int      ADIPeriod=14;
input int      KPeriod = 5;
input int      DPeriod = 3;
input int      JPeriod = 3;
input int      DDBPeriod = PERIOD_H4;
input int      INDICATORPeriod = PERIOD_H1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double MacdCurrent,MacdPrevious;
   double SignalCurrent,SignalPrevious;
   double MacdHistCurrent, MacdHistPrevious;
   double Ma10,Ma20;
   double RSICurrent, ADICurrent, StoBaseCurrent; //, StoSignalCurrent;
   //double StoBasePrevious, StoSignalPrevious;
   int    cnt,ticket,total;
   double recommendation = 0.0 , indicator = 0;
   double band1upper_0, band1upper_1, band1upper_2; // 1 diviation upper line -0 -1 -2 day
   double band1lower_0, band1lower_1, band1lower_2; // 1 diviation lower line -0 -1 -2 day
   double band2upper_0, band2upper_1, band2upper_2; // 2 diviation upper line -0 -1 -2 day
   double band2lower_0, band2lower_1, band2lower_2; // 2 diviation lower line -0 -1 -2 day
   
  
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
     
   //Print("Start check trading condition");  
     
   MacdCurrent=iMACD(NULL,INDICATORPeriod,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,INDICATORPeriod,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,INDICATORPeriod,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,INDICATORPeriod,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MacdHistCurrent = MacdCurrent - SignalCurrent;
   MacdHistPrevious = MacdPrevious - SignalPrevious;

   Ma10=iMA(NULL,INDICATORPeriod,MAShort,0,MODE_SMA,PRICE_CLOSE,0);
   Ma20=iMA(NULL,INDICATORPeriod,MaLong,0,MODE_SMA,PRICE_CLOSE,1);
   
   RSICurrent = iRSI(NULL, INDICATORPeriod, RSIPeriod, PRICE_CLOSE, 0);
   ADICurrent = iADX(NULL, INDICATORPeriod, ADIPeriod, PRICE_CLOSE, 0, 0);
   StoBaseCurrent = iStochastic(NULL, INDICATORPeriod, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 0);
   //StoSignalCurrent = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 0);
   //StoBasePrevious = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 1);
   //StoSignalPrevious = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 1);
   
   band1upper_0 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_UPPER,0);
   band1upper_1 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_UPPER,1);
   band1upper_2 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_UPPER,2);
   
   band1lower_0 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_LOWER,0);
   band1lower_1 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_LOWER,1);
   band1lower_2 = iBands(NULL,DDBPeriod,20, 1,0,PRICE_CLOSE,MODE_LOWER,2);
   
   band2upper_0 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_UPPER,0);
   band2upper_1 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_UPPER,1);
   band2upper_2 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_UPPER,2);
   
   band2lower_0 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_LOWER,0);
   band2lower_1 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_LOWER,1);
   band2lower_2 = iBands(NULL,DDBPeriod,20, 2,0,PRICE_CLOSE,MODE_LOWER,2);
   bool longconfident = LongConfident(RSICurrent, ADICurrent, StoBaseCurrent, Ma10, Ma20, MacdCurrent, SignalCurrent);
   bool shortconfident = ShortConfident(RSICurrent, ADICurrent, StoBaseCurrent, Ma10, Ma20, MacdCurrent, SignalCurrent);  
   total=OrdersTotal();
   
      if(total<MaxOpenPosition)
     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      
      //--- Calculation the recommendation ---
      
      //--- check for long position (BUY) possibility
      //if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && 
      //   MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)      
      
      if (toLong(band1upper_0,band1upper_1, band1upper_2,band2upper_0,band2upper_1,band2upper_2,longconfident))
        {
         Print("RSI is ", RSICurrent);
         Print("ADI is ", ADICurrent);
         Print("K is " , StoBaseCurrent);
         Print("MACD is ", MacdCurrent);
         Print("MACD signal is ", SignalCurrent);
         Print("MA 10 is ", Ma10);
         Print("MA 50 is ", Ma20);
         
         double sl = MathMax(iLow(NULL,0,2), Ask - StopLoss * Point);
         ticket=OrderSend(Symbol(),OP_BUY,Lots, Ask, 3.0, sl ,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
         return;
        }
      //--- check for short position (SELL) possibility
      //if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
      //   MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
      if(toShort(band1lower_0,band1lower_1, band1lower_2,band2lower_0,band2lower_1,band2lower_2, shortconfident))  // Conservative when Short
        {
         double sl = MathMin(band1lower_2, Bid + StopLoss * Point * 0.5);
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3.0,sl, Bid-TakeProfit*Point*0.5,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- exit from the "no opened orders" block
      return;
     }


//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- should it be closed?
            //if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
            //   MacdCurrent>(MACDCloseLevel*Point))
            
            if(toShort(band1lower_0,band1lower_1, band1lower_2,band2lower_0,band2lower_1,band2lower_2, longconfident))
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- should it be closed?
            //if(MacdCurrent<0 && MacdCurrent>SignalCurrent && 
            //   MacdPrevious<SignalPrevious && MathAbs(MacdCurrent)>(MACDCloseLevel*Point))
            if (toLong(band1upper_0,band1upper_1, band1upper_2,band2upper_0,band2upper_1,band2upper_2,longconfident))            
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Calculate Recommendation                                              |
//+------------------------------------------------------------------+


bool RSI_buy(double rsi){
   return (rsi < 70);
   //return true;
}

bool RSI_sell(double rsi){
   return (rsi > 80);
   //return false;
}

bool Macd_buy(double macd, double macdsignal){
   return MathAbs(macd)>(MACDOpenLevel*Point) && macd > macdsignal;
}

bool Macd_sell(double macd, double macdsignal){
   return macd < macdsignal;
}

bool Ma_buy(double ma1, double ma2){
   return ma1>ma2;
}

bool Ma_sell(double ma1, double ma2){
   return ma1<ma2;   
}

bool ADI_buy(double adi){
   return ( adi > 25 && adi <36);
   //return true;
}

bool ADI_sell(double adi){
   return (adi < 20 || adi > 45);   
}

bool STO_buy(double sto){
   return ( sto < 80);
   //return true;
}

bool STO_sell(double sto){
   return (sto > 90);
   //return false;
}


bool LongConfident(double rsi, double adi, double sto, double mashort , double malong, double macd, double macdsignal) {
   
   return RSI_buy(rsi) && ADI_buy(adi) && STO_buy(sto) && Ma_buy(mashort, malong) && Macd_buy(macd, macdsignal);

}

bool ShortConfident(double rsi, double adi, double sto, double mashort , double malong, double macd, double macdsignal){
   return RSI_sell(rsi) && ADI_sell(adi) && STO_sell(sto) && Ma_sell(mashort, malong) && Macd_sell(macd, macdsignal);
}

bool toLong(double b1h_0, double b1h_1, double b1h_2, double b2h_0, double b2h_1, double b2h_2, bool confident){   
   return (iClose(NULL,DDBPeriod,2) <= b1h_2 && iClose(NULL,DDBPeriod,1) > b1h_1 && (iClose(NULL,DDBPeriod,0) - b1h_0 >= 10 * Point) && 
           iClose(NULL,DDBPeriod,1) < b2h_1 && iClose(NULL,DDBPeriod,0) < b2h_0  && 
           confident);       
}

bool toShort(double b1l_0, double b1l_1, double b1l_2, double b2l_0, double b2l_1, double b2l_2, bool confident){
   return (iClose(NULL,DDBPeriod,2) >= b1l_2 && iClose(NULL,DDBPeriod,1) < b1l_1 && (b1l_0 - iClose(NULL,DDBPeriod,0)>= 10 * Point) && 
           iClose(NULL,DDBPeriod,1) > b2l_1 && iClose(NULL,DDBPeriod,0) > b2l_0 &&   
           confident);   
}