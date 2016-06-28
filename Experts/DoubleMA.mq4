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
input double   TakeProfit=40.0;
input double   Lots=0.1;
input double   TrailingStop=10.0;
input double   StopLoss = 20.0;
input int      MaxOpenPosition = 1;
input double   MACDOpenLevel=3.0;
input double   MACDCloseLevel=2.0;
input int      MATrendPeriod=26;
input int      MASmaPeriod=9;
input int      MAFastEMAPeriod=12;
input int      MAShort = 10;
input int      MAMid = 20;
input int      MALong = 50;
input int      MAVeryLong = 100;
input int      RSIPeriod=14;
input int      ADIPeriod=14;
input int      KPeriod = 5;
input int      DPeriod = 3;
input int      JPeriod = 3;
input int      PowerPeriod = 13;
input int      DDBTimeFrame = PERIOD_M30;
input int      INDICATORTimeFrame = PERIOD_M15;
input int      INDICATORPeriod = 6;

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
   // Cannot use variable to define the array size.    
   double Macd[6],MacdSignal[6], MacdHist[6];
   double Ma10[6], Ma20[6],Ma50[6], Ma100[6], EMA20[6];
   double RSI[6], ADI[6], STO_K[6], BullPower[6], BearPower[6];
   double Band1Upper[6], Band1Lower[6], Band2Upper[6], Band2Lower[6];
   ArrayInitialize(RSI,EMPTY_VALUE);
   ArrayInitialize(ADI,EMPTY_VALUE);
   ArrayInitialize(STO_K,EMPTY_VALUE);
   ArrayInitialize(Ma10,EMPTY_VALUE);
   ArrayInitialize(Ma20,EMPTY_VALUE);
   ArrayInitialize(Ma50,EMPTY_VALUE);
   ArrayInitialize(Macd,EMPTY_VALUE);
   ArrayInitialize(MacdSignal,EMPTY_VALUE);
   ArrayInitialize(Band1Lower,EMPTY_VALUE);
   ArrayInitialize(Band1Upper,EMPTY_VALUE);

   //double StoBasePrevious, StoSignalPrevious;
   int    cnt,ticket,total;
   double recommendation = 0.0 , indicator = 0;
   
  
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
   
   for(int i=0;i< INDICATORPeriod;i++)
     {
         Macd[i] = iMACD(NULL,INDICATORTimeFrame,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
         MacdSignal[i] = iMACD(NULL,INDICATORTimeFrame,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
         MacdHist[i] = Macd[i] - MacdSignal[i];
         Ma10[i]=iMA(NULL,INDICATORTimeFrame,MAShort,0,MODE_SMA,PRICE_CLOSE,i);   
         Ma20[i]=iMA(NULL,INDICATORTimeFrame,MAMid,0,MODE_SMA,PRICE_CLOSE,i);
         Ma50[i]=iMA(NULL,INDICATORTimeFrame,MALong,0,MODE_SMA,PRICE_CLOSE,i); 
         Ma100[i]=iMA(NULL,INDICATORTimeFrame,MALong,0,MODE_SMA,PRICE_CLOSE,i);
         EMA20[i]=iMA(NULL,INDICATORTimeFrame,MALong,0,MODE_EMA,PRICE_CLOSE,i);  
         RSI[i] = iRSI(NULL, INDICATORTimeFrame, RSIPeriod, PRICE_CLOSE, i);
         ADI[i] = iADX(NULL, INDICATORTimeFrame, ADIPeriod, PRICE_CLOSE, 0, i);
         STO_K[i] = iStochastic(NULL, INDICATORTimeFrame, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, i);
         BullPower[i] = iBullsPower(NULL, INDICATORTimeFrame, PowerPeriod, PRICE_CLOSE, i);
         BearPower[i] = iBearsPower(NULL, INDICATORTimeFrame, PowerPeriod, PRICE_CLOSE, i);
         Band1Lower[i] = iBands(NULL,DDBTimeFrame,20, 1,0,PRICE_CLOSE,MODE_LOWER,i);
         Band1Upper[i] = iBands(NULL,DDBTimeFrame,20, 1,0,PRICE_CLOSE,MODE_UPPER,i);
         Band2Lower[i] = iBands(NULL,DDBTimeFrame,20, 2,0,PRICE_CLOSE,MODE_LOWER,i);
         Band2Upper[i] = iBands(NULL,DDBTimeFrame,20, 2,0,PRICE_CLOSE,MODE_UPPER,i); 
     }
     

   //bool longconfident = LongConfident(RSI[0], ADI[0], STO_K[0], Ma10[0], Ma20[0],Ma50[0], Macd[0], MacdSignal[0]);
   //bool shortconfident = ShortConfident(RSI[0], ADI[0], STO_K[0], Ma10[0], Ma20[0],Ma50[0], Macd[0], MacdSignal[0]);  
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
      if (toLong(Macd, EMA20, Ma100))
        {
         Print("RSI is ", RSI[0]);
         Print("ADI is ", ADI[0]);
         Print("K is " , STO_K[0]);
         Print("MACDHist is ", MacdHist[0]);
         Print("MACD is ", Macd[0]);
         Print("MA 10 is ", Ma10[0]);
         Print("MA 20 is ", Ma20[0]);
         Print("MA 50 is ", Ma50[0]);
         Print("Bull power is ", BullPower[0]);
         Print("Bear Power is ", BearPower[0]);
         
         
         double sl = MathMax(iLow(NULL,INDICATORTimeFrame,2), Ask - StopLoss * Point);
         ticket=OrderSend(Symbol(),OP_BUY,Lots, Ask, 3.0, sl ,Ask+TakeProfit*Point,"Double MA",16384,0,Green);
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
      if(toShort(Macd, EMA20, Ma100))  // Conservative when Short
        {
         double sl = MathMin(iHigh(NULL,INDICATORTimeFrame,2), Bid + StopLoss * Point * 0.5);
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3.0,sl, Bid-TakeProfit*Point*0.5,"Double MA",16384,0,Red);
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

bool Macd_buy(double& macd[6]){
   //return macd[5] <= 0 && macd[0] > 0 && macd[1] > 0 && macd[2] > 0 && macd[3] > 0 && macd[4] > 0 && (macd[0] > macd[1] >macd[2] >macd[3]> macd[4]);    
   return macd[5] <= 0 && macd[4] > 0 && (macd[0] > macd[1] >macd[2] >macd[3]> macd[4]);    
}

bool Macd_sell(double& macd[6]){
    return macd[5] >= 0 && macd[0] < 0 && macd[1] < 0 && macd[2] < 0 && macd[3] < 0 && macd[4] < 0;
}

bool Ma_buy(double& ma1[6], double& ma2[6]) {
   return ((iClose(NULL, 0 , 0) > MathMax(ma1[0], ma2[0] + 15 * Point )) ||
          (iClose(NULL, 0 , 1) > MathMax(ma1[1], ma2[1] + 15 * Point )) || 
          (iClose(NULL, 0 , 2) > MathMax(ma1[2], ma2[2] + 15 * Point )) || 
          (iClose(NULL, 0 , 3) > MathMax(ma1[3], ma2[3] + 15 * Point )) ||
          (iClose(NULL, 0 , 4) > MathMax(ma1[4], ma2[4] + 15 * Point ))) && 
          (iClose(NULL, 0 , 0) > ma1[0] && iClose(NULL, 0 , 0) > ma2[0] &&
           iClose(NULL, 0 , 1) > ma1[1] && iClose(NULL, 0 , 1) > ma2[1] && 
           iClose(NULL, 0 , 2) > ma1[2] && iClose(NULL, 0 , 2) > ma2[2] && 
           iClose(NULL, 0 , 3) > ma1[3] && iClose(NULL, 0 , 3) > ma2[3] &&  
           iClose(NULL, 0 , 4) > ma1[4] && iClose(NULL, 0 , 4) > ma2[4] );
}

bool Ma_sell(double& ma1[6], double& ma2[6]){
   return ((iClose(NULL, 0 , 0) < MathMax(ma1[0], ma2[0] - 15 * Point)) ||
          (iClose(NULL, 0 , 1) < MathMax(ma1[1], ma2[1] + 15 * Point)) ||
          (iClose(NULL, 0 , 2) < MathMax(ma1[2], ma2[2] + 15 * Point)) ||
          (iClose(NULL, 0 , 3) < MathMax(ma1[3], ma2[3] + 15 * Point)) ||
          (iClose(NULL, 0 , 4) < MathMax(ma1[4], ma2[4] + 15 * Point))) && 
          ( iClose(NULL, 0 , 0) < ma1[0] && iClose(NULL, 0 , 0) < ma2[0] && 
            iClose(NULL, 0 , 1) < ma1[1] && iClose(NULL, 0 , 1) < ma2[1] &&
            iClose(NULL, 0 , 2) < ma1[2] && iClose(NULL, 0 , 2) < ma2[2] &&
            iClose(NULL, 0 , 3) < ma1[3] && iClose(NULL, 0 , 3) < ma2[3] &&
            iClose(NULL, 0 , 4) < ma1[4] && iClose(NULL, 0 , 4) < ma2[4]);
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



bool LongConfident(double rsi, double adi, double sto, double mashort , double mamid, double malong, double macd, double macdsignal) {
   return false;   
   //return RSI_buy(rsi) && ADI_buy(adi) && STO_buy(sto) && Ma_buy(mashort, mamid) && Ma_buy(mamid, malong) && Macd_buy(macd, macdsignal);

}

bool ShortConfident(double rsi, double adi, double sto, double mashort, double mamid, double malong, double macd, double macdsignal){
   //return RSI_sell(rsi) && ADI_sell(adi) && STO_sell(sto) && Ma_sell(mashort, mamid) && Ma_sell(mamid, malong) && Macd_sell(macd, macdsignal);
   return false;
}


bool toLong(double& macd[6], double& ema[6], double& ma[6]){
   return Macd_buy(macd) && Ma_buy(ema, ma);   
   
}

bool toShort(double& macd[6], double& ema[6], double& ma[6]){
   return Macd_sell(macd) && Ma_sell(ema, ma) && false;
}