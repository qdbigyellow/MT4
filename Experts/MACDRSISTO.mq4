//+------------------------------------------------------------------+
//|                                                   MACDRSIADI.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input double   TakeProfit=50.0;
input double   Lots=0.1;
input double   TrailingStop=30.0;
input double   MACDOpenLevel=3.0;
input double   MACDCloseLevel=2.0;
input int      MATrendPeriod=26;
input int      MASmaPeriod=9;
input int      MAFastEMAPeriod=12;
input int      RSIPeriod=14;
input int      ADIPeriod=14;
input int      KPeriod = 5;
input int      DPeriod = 3;
input int      JPeriod = 3;
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
   double MaCurrent,MaPrevious;
   double RSICurrent, ADICurrent, StoBaseCurrent, StoSignalCurrent;
   double StoBasePrevious, StoSignalPrevious;
   int    cnt,ticket,total;
   double recommendation = 0.0;
   
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
     
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MacdHistCurrent = MacdCurrent - SignalCurrent;
   MacdHistPrevious = MacdPrevious - SignalPrevious;

   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   
   RSICurrent = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, 0);
   ADICurrent = iADX(NULL, 0, ADIPeriod, PRICE_CLOSE, 0, 0);
   StoBaseCurrent = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 0);
   StoSignalCurrent = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 0);
   StoBasePrevious = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, 1);
   StoSignalPrevious = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 1, MODE_SIGNAL, 1);
   
   
   total=OrdersTotal();
   
      if(total<1)
     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      
      //--- Calculation the recommendation ---
      recommendation = CalculateRecommendation(RSICurrent, StoBaseCurrent, StoBasePrevious, StoSignalCurrent, StoSignalPrevious);
      
      //--- check for long position (BUY) possibility
      if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && 
         MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
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
      if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
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
double CalculateRecommendation(double rsi, double k, double kPrevious, double d, double dPrevious){
   
   

   return 0.0;
}


double CalculateRSIRecommentdation(double rsi){
    int rsi_lower = 30;
    int rsi_upper = 70;
    double rec = 0.0;

    if (rsi < rsi_lower)
        rec = 1;    
    else if (rsi > rsi_upper)
        rec = -1;          
    else
        rec = (rsi - rsi_lower) / (rsi_upper - rsi_lower) * -2  + 1   ;              
    return rec;
}


double CalculateSTORecommendation(double k){
   int k_low = 20;
   int k_high = 80;
   double rec = 0.0;
      
   if (k >= k_high) {
      rec = -1;   
   } else if(k <= k_low){
      rec = 1;
   } else{
      rec = (k - k_low) / (k_high - k_low) * -2  + 1;
   }
   return rec;
}

double CalculateSTOIndicator(double k, double kPrevious, double d, double dPrevious){
   double ind = 0;
   if (k > d && kPrevious <= dPrevious){
         ind = 1;
   } else if (k <= d && kPrevious > dPrevious){
         ind = -1;
   } else if (k > d && kPrevious > dPrevious && k-d > kPrevious-dPrevious){
         ind = 2;
   }
   return ind;
}
