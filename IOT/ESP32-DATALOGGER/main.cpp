//this program is used in a custom arduino mega 2560 datalogger used with a ds3231 rtc, a microsd module and sim800l GSm module
//the sonsors include a Rotronic hc2-sm or hc2xd with two analog  outputs for temperature and humidity
//rainguage-geoedge raingauge 0.55 per tipping.
//this in no way a professional coders work
//*********************************************************
//      PINOUTS
//*********************************************************]
//  SDCARD MODULE SPI MEGA PORTS
//  RTC I2C  SDA SCL
//  ANALOG INPUTS A3-temperature and A5-humidity
//  RAINGUAGE interuppt pin 2
//  power supply 5V buck to sd card and rtc
//  4V buck to GSM  9V buck to arduino MEGA
//  working in a perf board just for now I hope  

#include <Arduino.h>
#include <SD.h>
#include <SPI.h>
#include "RTClib.h"
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_wifi.h>
#include <Adafruit_ADS1X15.h>


RTC_DS3231 rtc;
Adafruit_ADS1115 ads;
File sdcard_file;
const int PROGMEM CSel = 5;
const int PROGMEM Tpin = 36, PROGMEM RHpin = 34;
float T, RH, temp, temp1, rhum, tmax=0, tmin=0,rhmax=0,rhmin=0;
const byte PROGMEM rainpin= 26, PROGMEM initpin = 30;
int rainC = 0, mode=0;
float rainQ = 0.0;
char rainA[6]; // for final-data
String gtime;
char ntime[20], rainC_time[20] ;
char reading[100];
char getURL[200];
char flbuff[8];
int dyr=0, dmnt=0, ddy=0, dhr=0, dmin=0, dsc=0;
char readings[4][6]={"temp","rhum","tmax","tmin"};
bool initv1=false, initv2=false,initv3=false,initv4=false, initialize=false,rsent=false,gstate=false,senddata(),varreset=false;
int gyr, gmnt, gdy, ghr, gmin, gsc, gtz;
int index1, index2; //index not used? check it!
volatile bool rain_t=false;
volatile unsigned long rtime; //millis inside rain interrupt
unsigned long ltime; //millis in loop recording rtc time
unsigned long logtime1,logtime2;
static unsigned long last_i_time=0;
void rain(),rtccheck(),initial(),ATRH(),timenow(),sdwrite(),sdata(),sdata1();/*gettime(),*/
char *formatNumber(float number, int len, int prec);
const int PROGMEM port = 80;
const char* ssid = "Tortilla";//AP ssid
const char* password = "Andi@123";//AP password

WiFiUDP udp;


void setup() {
  // put your setup code here, to run once:
Serial.begin(115200);
 // it has serial and gsm begin and checks modem
//analogRead(Tpin);
//analogRead(RHpin);
WiFi.mode( WIFI_STA );
ESP_ERROR_CHECK( esp_wifi_set_protocol( WIFI_IF_STA, WIFI_PROTOCOL_LR ) );
WiFi.begin(ssid, password);
udp.begin( 8888 );
pinMode(rainpin, INPUT);

attachInterrupt(digitalPinToInterrupt(rainpin), rain, FALLING);
pinMode(CSel, OUTPUT);
pinMode(Tpin, INPUT);
pinMode(RHpin, INPUT);
pinMode(initpin , OUTPUT);

ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
delay(3000);
initial();  //led not in circuit have to attach to pin 30;
rtccheck(); //checks whether time is right;

if (initialize) {
  digitalWrite(initpin,HIGH);
}
ATRH();
tmax = temp;
tmin = temp;
logtime1 = millis();
WiFi.mode(WIFI_OFF);
btStop();
}


void loop() {
  timenow();
  if (dhr== 00 && dmin == 00 && !varreset) {
	 tmax = temp;
	 tmin = temp;
	 rainC = 0;
   rainQ = 0.0;
   varreset=true;
  }
   if (dhr== 00 && dmin == 01){
     varreset=false;
  }
  logtime2=millis();
  if ((logtime2-logtime1) > 180000){
    ATRH();
    Serial.print("temp: ");
    Serial.print(temp);
    Serial.print("  RH: ");
    Serial.println(rhum);
    timenow();
    sdata();
    sdwrite();
    logtime1=millis();
    }
  if ((dmin == 00 || dmin == 10 || dmin == 20 || dmin == 30 || dmin == 40 || dmin == 50) && (!rsent)) { 
  	ATRH();
  	timenow();
   // sdata1();
    senddata();
  }
  if ((dmin == 01 || dmin == 11 || dmin == 21 || dmin == 31 || dmin == 41 || dmin == 51) && (!rsent)){
    senddata();
  } 
  if ((dmin == 02 || dmin == 12 || dmin == 22 || dmin == 32 || dmin == 42 || dmin == 52) && (rsent)){
    rsent=false;
    }  
 if (rain_t) {
    timenow();
    delay(40);
    rainC_time[19]='\0';
    strlcpy(rainC_time,ntime,19);
    ltime=millis()-rtime;
    rain_t=false;
    rainQ = rainC * 000.5;
    ATRH();
    sdata();
    sdwrite();
    //sdata1();
    senddata();
    if(rsent)
    {
      strlcpy(rainC_time,"0",19);
      ltime=0;
    }
    digitalWrite(initpin,HIGH);
    delay(300);
    digitalWrite(initpin,LOW);
    Serial.print(rainQ);Serial.print("  :  "); Serial.println(ltime);
   }
  }



void rtccheck() {
if (rtc.begin()) {
   timenow();
   if ((rtc.lostPower()) || (dyr < 2021)) {
    //gettime();
	char gtime1[19];
    gtime.toCharArray(gtime1,sizeof(gtime1));
    sscanf(gtime1,"%d/%d/%d,%d:%d:%d", &gyr, &gmnt, &gdy, &ghr, &gmin, &gsc);
	rtc.adjust(DateTime(gyr, gmnt, gdy, ghr, gmin, gsc));
    }
  }
}
void ATRH() {
  
  timenow();
		T = 0.0;
  for (int i = 0; i<5; i++) {
     float Tn= ads.readADC_SingleEnded(0);;
    T = T + Tn;
    delay(40);       
    }
    
	T = T * 0.2; //average 
   RH = 0.0;
  for (int i = 0; i<5; i++) {
      float RHn=ads.readADC_SingleEnded(1);
    RH = RH + RHn;
    delay(40);
  }
  RH = RH * 0.2;
  temp = ((T*(0.03125))*0.1-40);
  rhum = (RH*(0.03125))*0.1;
  if (temp > tmax) {
	  tmax=temp;
  }
  if (temp < tmin) {
	  tmin = temp;
  }
  if (rhum > rhmax) {
	  rhmax=rhum;
  }
  if (rhum < rhmin) {
	  rhmin = rhum;
  }
  //sdata();
 }

void rain() {
  //static unsigned long last_i_time=0;
  unsigned long i_time=millis();  //apparently you can use millis inside an ISR -made me a lunatic for 3 months 
  if(i_time-last_i_time>1000){     //but it wont change inside this loop since all clocks are paused
	rainC++;                        //here both i_time and rtime is essentially same
	rain_t= true;                   //rtime is used to detect the time elapsed from the interrupt to the code in-
  rtime = millis();               //-loop where the rain parameter is handled but it is not calculated that has to be done in post
  }
  last_i_time=i_time;
}

void timenow() {
  DateTime now = rtc.now();
  dyr=now.year(), dmnt=now.month(),ddy=now.day(),dhr=now.hour(),dmin=now.minute(),dsc=now.second();
  //ntime= dyr + '/'+ dmnt + '/' + ddy + ' ' + dhr + ':' + dmin + ':' + dsc;
  snprintf(ntime,20,"%d/%d/%d,%d:%d:%d", dyr,dmnt, ddy, dhr, dmin, dsc);
}

void initial() {
  if (!rtc.begin()) {
      initv1=false;
     }
  else {
  initv1=true;
  }
  int x = 1;
  while (( WiFi.status() != WL_CONNECTED ) && (x < 10)){
      delay(500);
      Serial.print(WiFi.status());
      Serial.println(x);
     x++;
     }
    if ( WiFi.status() == WL_CONNECTED ) {
    initv2=true;
    } 
  else {
     initv2=false;
  }
  
  if (SD.begin()){
     initv3=true;
  }
  else {
    initv3=false;
  }
  if (ads.begin()){
    initv4=true; }
    else{
      initv4=false;
    }

  if (initv1 && initv3 && initv2 && initv4 ) {
      initialize = true;
    } else {
    initialize = false;
    }    
}

// check time via esp32 coe needed
/*
void gettime() {
      Serial3.println("ntime?");
      unsigned long tmil = millis();
      while(millis()<tmil+4000){
        if (Serial3.available() > 0) {
        gtime = Serial3.readString();
        break;
      }
      }
    }
*/


void sdata()
{
  dtostrf(temp,5,2,readings[0]);
  dtostrf(rhum,5,2,readings[1]);
  dtostrf(tmax,5,2,readings[2]);
  dtostrf(tmin,5,2,readings[3]);
  ////Serial.println("before-rainA");
  delay(1000);
  dtostrf(rainQ,-5,1,rainA);
 // strncpy(rainA,(formatNumber(rainQ,5, 1)),6);
  delay(1000);
    for (int x = 0;x<4;x++){
     readings[x][5]='\0';
     }
    sprintf(reading,"%s|%s|%s|%s|%s|%s|%i",ntime,readings[0],readings[1],readings[2],readings[3],rainA,rainC);
    //sprintf(getURL,"%s%s%s%s%s%s%s%s%s%s%s%s%i%s%lu%s%s%s%s","GET http://65.0.5.138/raindata/insert.php?","t=",readings[0],"&tM=",readings[2],"&tm=",readings[3],"&rh=",readings[1],"&rq=",rainA,"&rc=",rainC,"&ret=",ltime,"&rct=",rainC_time,"&time=",ntime);
    
}

bool senddata() {

}

char *formatNumber(float number, int len, int prec) {
  dtostrf(number,len,prec,flbuff);
  for (int i = 0; i < len+1; i++) {
    if (flbuff[i]==' ') flbuff[i]='0';
  }
  return flbuff;
}

void sdwrite() {
  char filename[12];
  snprintf(filename,12,"/%i-%i.txt",ddy,dmnt); // "/ is needed for esp32 code"
  digitalWrite(CSel,HIGH);
  if (SD.begin(CSel)) {
    if(SD.exists(filename))
     {
      sdcard_file = SD.open(filename, FILE_APPEND); // file_write for arduino file_append for esp32
        if (sdcard_file) {
          sdcard_file.println(reading);
        }
        sdcard_file.close();
      }
     else {
      sdcard_file = SD.open(filename, FILE_WRITE);
      if (sdcard_file) {
        sdcard_file.print("Date,Time,Temp,RH,Tmax,Tmin,rainA,rainC,rainC_time,ltime");
        sdcard_file.println();
        sdcard_file.println(reading);
      }
      sdcard_file.close();
     }
  }
   else {
    Serial.print("card failed");
   }
    digitalWrite(CSel,LOW);
}