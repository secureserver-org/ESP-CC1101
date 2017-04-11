#include <SoftwareSerial.h>

#define OB_LED 13  // Arduino onboard LED
#define ESP_PD 4  // ESP power down pin
#define ESP_SS_RX 6  // ESP software serial RX
#define ESP_SS_TX 3  // ESP software serial TX

String arduinoSerialContent = "";
String espSerialContent = "";

bool isEspReady = false;

SoftwareSerial ESPSerial(ESP_SS_RX, ESP_SS_TX);  // ESP Serial

void setup() {
  Serial.begin(9600);
  ESPSerial.begin(9600);

  pinMode(OB_LED, OUTPUT);
  pinMode(ESP_PD, OUTPUT);

  digitalWrite(ESP_PD, HIGH);  // Enable ESP (PD active high)

  Serial.println("ARDUINO_OK");
}

void loop() {
  arduinoSerial();
  espSerial();
}


// Reset ESP by cycling PD pin
void cmd_ESP_RESET(String args) {
  digitalWrite(ESP_PD, LOW);
  delay(50);
  digitalWrite(ESP_PD, HIGH);
  isEspReady = false;
}

void cmd_ESP_PD(String args) {
  if (args == "0") {
    digitalWrite(ESP_PD, LOW);
  }
  else if (args == "1") {
    digitalWrite(ESP_PD, HIGH);
  }
  else {
    Serial.println("INVALID_ARGS");
  }
}


// Parse Arduino serial commands
void arduinoParseCommands(String cmd, String args) {
  if (cmd == "ESP_RESET") {
    cmd_ESP_RESET(args);
  }
  else if (cmd == "ESP_PD") {
    cmd_ESP_PD(args);
  }
  else {
    Serial.print("INVALID_CMD");
  }
}

// Handle Arduino serial communication
void arduinoSerial() {
  char character;

  while(Serial.available()) {  // Concat serial characters
    character = Serial.read();
    arduinoSerialContent.concat(character);
  }

  if (arduinoSerialContent != "" && character == '\n') {
    // Remove newline character
    arduinoSerialContent = arduinoSerialContent.substring(0, arduinoSerialContent.length() - 1);

    // Echo serial content
    Serial.println("> " + arduinoSerialContent);

    // Split content into command and arguments
    String cmd;
    String args;
    if (arduinoSerialContent.indexOf(" ") >= 1) {
      cmd = arduinoSerialContent.substring(0, arduinoSerialContent.indexOf(" "));
      args = arduinoSerialContent.substring(arduinoSerialContent.indexOf(" ") + 1, arduinoSerialContent.length());
    }
    else {
      cmd = arduinoSerialContent;
    }

    arduinoParseCommands(cmd, args);
    arduinoSerialContent = "";
  }
}

// Parse ESP serial commands
void espParseCommands(String cmd) {
  if (cmd == "NODEMCU_READY") {
    Serial.println("ESP8288_OK");
    isEspReady = true;
  }
  else if (cmd == "AP_ACTIVE") {
    Serial.println("ESP8266_AP_ACTIVE");
  }
  else if (cmd.indexOf("AP_IP=") > -1) {
    String apIP = cmd.substring(cmd.indexOf("AP_IP=")+6, cmd.length());
    Serial.println("ESP8266_AP_IP=" + apIP);
  }
  else if (cmd == "WIFI_CONNECTING") {
    Serial.println("ESP8266_WIFI_CONNECTING");
  }
  else if (cmd == "WIFI_CONNECTED") {
    Serial.println("ESP8266_WIFI_CONNECTED");
  }
  else if (cmd.indexOf("WIFI_IP=") > -1) {
    String wifiIP = cmd.substring(cmd.indexOf("WIFI_IP=")+8, cmd.length());
    Serial.println("ESP8266_WIFI_IP=" + wifiIP);
  }
  else if (cmd == "TCP_LISTENING") {
    Serial.println("ESP8266_TCP_LISTENING");
  }
  else if (cmd.indexOf("TCP_PEER=") > -1) {
    String peerIP = cmd.substring(cmd.indexOf("TCP_PEER=")+9, cmd.length());
    Serial.println("ESP8266_PEER_IP=" + peerIP);
  }
}

// Handle ESP serial communication
void espSerial() {
  char character;

  while (ESPSerial.available()) {  // Concat serial characters
    character = ESPSerial.read();
    espSerialContent.concat(character);
  }

  if (espSerialContent != "" && character == '\n') {
    // Remove newline character
    espSerialContent = espSerialContent.substring(0, espSerialContent.length() - 2);

    espParseCommands(espSerialContent);
    espSerialContent = "";
  }
}
