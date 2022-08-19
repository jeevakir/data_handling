#include <SD_ZH03B.h>
#include <SoftwareSerial.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

SoftwareSerial ZHSerial(D1, D2); // RX, TX
SD_ZH03B ZH03B( ZHSerial, SD_ZH03B::SENSOR_ZH06 );
const char* ssid     = "********";
const char* password = "********";
//WiFiServer server(80);

ESP8266WebServer server(80);
IPAddress local_IP(192, 168, 0, 150);
// Set your Gateway IP address
IPAddress gateway(192, 168, 0, 1);

IPAddress subnet(255, 255, 255, 0);
IPAddress primaryDNS(8, 8, 8, 8);   //optional
IPAddress secondaryDNS(8, 8, 4, 4); //optional

  int PM1_0; 
  int PM2_5;
  int PM10_0;
  char aqcat[20];
  char color[15];
  int readtime,oldreadtime;
String SendHTML(int PM1_0stat,int PM2_5stat,int PM10_0stat,String aqcat_stat, String color_stat);
void readSensorData(),handle_OnConnect(),handle_NotFound();

void setup() {
    Serial.begin(115200);
    ZHSerial.begin(9600);
    delay(100);
    ZH03B.setMode( SD_ZH03B::QA_MODE );
  WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    }
  server.on("/", handle_OnConnect);
  server.onNotFound(handle_NotFound);

  server.begin();
  readSensorData();
}

void loop(){
   server.handleClient();
   readtime = millis();
   if((readtime - oldreadtime)>2000){
     readSensorData();
   }
   
}

void handle_OnConnect() {
  readSensorData();
  if(PM2_5>251){
      strcpy(aqcat,"Hazardous");
      strcpy(color,"Red");
    }
    else if (PM2_5>151){
      strcpy(aqcat,"Very_unhealthy");
      strcpy(color,"Pink");
    }
    else if (PM2_5>57){
     strcpy(aqcat,"unhealthy");
     strcpy(color,"Orange");
    }
    else if (PM2_5>36){
    strcpy(aqcat,"Sensitive");
    strcpy(color,"Yellow");
    }
    else if (PM2_5>13){
      strcpy(aqcat,"Acceptable");
      strcpy(color,"LightGreen");
    }
    else{
      strcpy(aqcat,"Good");
      strcpy(color,"DarkGreen");
    }
  Serial.println(aqcat);
  
  server.send(200, "text/html", SendHTML(PM1_0,PM2_5,PM10_0,aqcat,color)); 
}
void handle_NotFound(){
  server.send(404, "text/plain", "Not found");
}

String SendHTML(int PM1_0stat,int PM2_5stat,int PM10_0stat,String aqcat_stat, String color_stat){
  String ptr = "<!DOCTYPE html> <html>\n";
  ptr +="<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\">\n";
  ptr +="<title>DUST Sensor-esp8266</title>\n";
  ptr +="<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}\n";
  ptr +="body{margin-top: 50px;} h1 {color: #444444;margin: 50px auto 30px;}\n";
  ptr +="p {font-size: 24px;color: #444444;margin-bottom: 10px;}\n";
  ptr +="</style>\n";  //AJAX begin
  ptr +="<script>\n";
  ptr +="setInterval(loadDoc,5000);\n";
  ptr +="function loadDoc() {\n";
  ptr +="var xhttp = new XMLHttpRequest();\n";
  ptr +="xhttp.onreadystatechange = function() {\n";
  ptr +="if (this.readyState == 4 && this.status == 200) {\n";
  ptr +="document.getElementById(\"webpage\").innerHTML =this.responseText}\n";
  ptr +="};\n";
  ptr +="xhttp.open(\"GET\", \"/\", true);\n";
  ptr +="xhttp.send();\n";
  ptr +="}\n";
  ptr +="</script>\n"; //AJAX end
  ptr +="</head>\n";
  ptr +="<body>\n";
  
  ptr +="<div id=\"webpage\">\n";
  ptr +="<h1>ESP8266 DUST Sensor</h1>\n";
  ptr +="<p>PM1.0: ";
  ptr +=(int)PM1_0stat;
  ptr +="<p>PM2.5: ";
  ptr +=(int)PM2_5stat;
  ptr +="<p>PM10: ";
  ptr +=(int)PM10_0stat;
  ptr +="\n";
  ptr +="<h1>AQI</h1>\n";
  ptr +="<p style=\"background-color:";
  ptr +=String(color_stat);
  ptr +=";\">";
  ptr +=String(aqcat_stat);
  ptr +="</p>";
  ptr +="</div>\n";
  
  ptr +="</body>\n";
  ptr +="</html>\n";
  return ptr;
}

void readSensorData() {
//char printbuf1[80];
   
if( ZH03B.readData() ) {
    //Serial.print( ZH03B.getMode() == SD_ZH03B::IU_MODE ? "IU:" : "Q&A:" );  
    //sprintf(printbuf1, "PM1.0: %d, PM2.5 : %d, PM10 : %d", ZH03B.getPM1_0(), ZH03B.getPM2_5(), ZH03B.getPM10_0() );
    //Serial.println(printbuf1);
    oldreadtime = millis();
    //ZH03B.wakeup();
    delay(1000);
    PM1_0 = ZH03B.getPM1_0();
    PM2_5 = ZH03B.getPM2_5();
    PM10_0 = ZH03B.getPM10_0();
   // ZH03B.sleep();
}
}