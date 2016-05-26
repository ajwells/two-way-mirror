
import java.util.Calendar;
import processing.io.*;

//weather variables
JSONObject weatherData;
JSONObject curWeatherData;
JSONArray temp;
String baseURL = "http://api.openweathermap.org/data/2.5/weather?id=4761054";
String apiKey = "95bedd4e8a97d4a8ab92bd77f10383b6";
String baseIconURL = "http://openweathermap.org/img/w/";

String curState = "";
String curDescription = "";
float curTemp = 0;
int curID = 0;
String location = "";
long sunriseTime = 0;
Calendar sunrise = Calendar.getInstance();
long sunsetTime = 0;
Calendar sunset = Calendar.getInstance();
long currentTime = 0;
Calendar current = Calendar.getInstance();
boolean daytime = false;

//clock variables
float cx, cy;
float secondsRadius;
float minutesRadius;
float hoursRadius;
float clockDiameter;

//pins
int onOffPin = 4;
int weatherPin = 5;
int clockPin = 6;
int otherPin = 13;

//other
int state = 0;
int onOff = 0;
int keyNum = 87;
int minute = 0;
int resetWeather = 10; //minutes to recapture weather data
boolean reset = false;


void setup() {
  
  //size(800, 480);
  noCursor();
  fullScreen();
  background(0);
  
  minute = minute();
  setupClock();
  getWeatherData();
  
  //pins
  GPIO.pinMode(onOffPin, GPIO.INPUT);
  GPIO.pinMode(weatherPin, GPIO.INPUT);
  GPIO.pinMode(clockPin, GPIO.INPUT);
  GPIO.pinMode(otherPin, GPIO.INPUT);
  GPIO.attachInterrupt(onOffPin, this, "pinEvent", GPIO.CHANGE);
  GPIO.attachInterrupt(weatherPin, this, "pinEvent", GPIO.RISING);
  GPIO.attachInterrupt(clockPin, this, "pinEvent", GPIO.RISING);
  GPIO.attachInterrupt(otherPin, this, "pinEvent", GPIO.RISING);
  
  if (GPIO.digitalRead(onOffPin) == GPIO.HIGH) {
    onOff = 1;
  }
}

void draw() {
  //get new weather data if enough time has passed
  if (((minute + resetWeather)%60) == minute()) {
    if (reset == false) {
      getWeatherData();
      reset = true;
      minute = minute();
      println(minute());
    } else {
      reset = false;
    }
  }
  //change state
  if (state == 0 && onOff == 1) { 
    drawClock();
  } else if (state == 1 && onOff == 1) {  
    drawWeather();
  } else if (state == 2 && onOff == 1) { 
  } else {
    background(0);
  }
}   

void pinEvent(int pin) {
  //noInterrupts();
  if (pin == onOffPin) {
    if (GPIO.digitalRead(pin) == GPIO.HIGH) {
      onOff = 1;
    } else {
      onOff = 0;
    }
  } else if (pin == clockPin) {
    state = 0;
  } else if (pin == weatherPin) {
    state = 1;
  } else if (pin == otherPin) {
    state = 2;
  }
  //interrupts();
}

void keyPressed() {
  if (key == 'c') {
    keyNum = keyCode;
  } else if (key == 'w') {
    keyNum = keyCode;
  }
}

void drawWeather() {
  background(0);
  
  drawWeatherPicture();  //draw picture
  drawWeatherInfo();  //draw info
  //drawClearDay();
  //drawClearNight();
  //drawLightCloudsDay();
  //drawLightCloudsNight();
  //drawCloudy();
  //drawHeavyClouds();
  //drawRainDay();
  //drawRainNight();
  //drawHeavyRain();
  //drawThunderstorm();
  //drawSnow();
  
}

void drawWeatherPicture() {
  
  if (curID <= 232 && curID >= 200) {
    drawThunderstorm(); 
  } else if (curID <= 321 && curID >= 300) {
    if (daytime) {  //daytime
      drawRainDay();
    } else {  //nightime
      drawRainNight(); 
    }
  } else if (curID <= 531 && curID >= 500) {
    drawHeavyRain(); 
  } else if (curID <= 622 && curID >= 600) {
    //snow 
  } else if (curID == 804) {
    drawHeavyClouds();
  } else if (curID == 803) {
    if (daytime) {  //daytime
      drawHeavyClouds();
    } else {  //nightime
      drawCloudy(); 
    } 
  } else if (curID == 802) {
    drawCloudy(); 
  } else if (curID == 800) {
    if (daytime) {  //daytime
      drawClearDay();
    } else {  //nightime
      drawClearNight(); 
    }
  } else {  //default to light clouds
    if (daytime) {  //daytime
      drawLightCloudsDay();
    } else {  //nightime
      drawLightCloudsNight(); 
    }
  }
}

void drawWeatherInfo() {
   int intTemp = int(kelvinToF(curTemp));
   String stringTemp = str(intTemp) + "\u00b0 F"; 
   textSize(100);
   fill(255);
   textAlign(CENTER);
   //text(stringTemp, 570, 230);
   text(stringTemp,(width*0.7), (height/3));
   
   textSize(50);
   //text(curDescription, 370, 270, 400, 180);
   text(curDescription, width*0.45, height*.7, width/2, 180);
}
  
void drawClearDay() {
  drawSun(width/4,height/2,height/2,height/2);
}

void drawClearNight() {
  drawMoon(width/4,height/2,height/2,height/2);
}

void drawLightCloudsDay() {
  drawSun(width/5,height/2.7,height/2.5,height/2.5);
  drawCloud(width/3.5,height/2.5,height/2.5,height/2.5,255);
}

void drawLightCloudsNight() {
  drawMoon(width/5,height/2.7,height/3,height/3);
  drawCloud(width/3.5,height/2.5,height/2.5,height/2.5,255);
}

void drawCloudy() {
  drawCloud(width/4,height/2.5,height/2,height/2,255);
}

void drawHeavyClouds() {
  drawCloud(width/3.5,height/3,height/2.3,height/2.3,175);
  drawCloud(width/4.5,height/2.5,height/2.3,height/2.3,255);
}

void drawRainDay() {
  drawSun(width/5,height/2.7,height/2.5,height/2.5);
  drawCloud(width/3.5,height/2.5,height/2.5,height/2.5,255);
  drawRainDrop(width/4.5,height*.7,width/30,height/12);
  drawRainDrop(width/3.5,height*.75,width/30,height/12);
  drawRainDrop(width/2.85,height*.7,width/30,height/12);
}

void drawRainNight() {
  drawMoon(width/5,height/2.7,height/3,height/3);
  drawCloud(width/3.5,height/2.5,height/2.5,height/2.5,255);
  drawRainDrop(width/4.5,height*.7,width/30,height/12);
  drawRainDrop(width/3.5,height*.75,width/30,height/12);
  drawRainDrop(width/2.85,height*.7,width/30,height/12);
}

void drawHeavyRain() {
  drawCloud(width/3.5,height/3,height/2.3,height/2.3,175);
  drawCloud(width/4.5,height/2.5,height/2.3,height/2.3,255);
  drawRainDrop(width*0.155,height*.72,width/30,height/12);
  drawRainDrop(width*0.225,height*.77,width/30,height/12);
  drawRainDrop(width*0.295,height*.72,width/30,height/12);
}

void drawThunderstorm() {
  drawCloud(width/3.5,height/3,height/2.3,height/2.3,175);
  drawCloud(width/4.5,height/2.5,height/2.3,height/2.3,255);
  drawLightningBolt(width/5.3,height/1.45,width/16,height/4.8);
  drawLightningBolt(width/3.8,height/1.52,width/16,height/4.8);
}

void drawSnow() {
  drawCloud(width/3.5,height/3,height/2.3,height/2.3,175);
  drawCloud(width/4.5,height/2.5,height/2.3,height/2.3,255);
  drawSnowflake(width/5.6,height/1.47,width/20,width/20);
  drawSnowflake(width/4.3,height/1.34,width/20,width/20);
  drawSnowflake(width/3.5,height/1.47,width/20,width/20);
}

//x and y are in the middle of the bolt
void drawSnowflake(float x, float y, float dx, float dy) {
  strokeWeight(8);
  stroke(135,206,250);
  for (int a = 0; a < 360; a+=45) {
    float angle = radians(a);
    line(x + cos(angle),  y + sin(angle), x + cos(angle) * 0.5*dx, y + sin(angle) * 0.5*dy);
  }
}

//x and y are in the middle of the bolt
void drawLightningBolt(float x, float y, float dx, float dy) {
  fill(255,255,0);
  noStroke();
  quad(x+(0.5*dx),y-(0.5*dy),x-(0.2*dx),y-(0.5*dy),x-(0.5*dx),y+(0.1*dy),x-(0.1*dx),y+(0.1*dy));
  quad(x-(0.5*dx),y+(0.1*dy),x+(0.2*dx),y+(0.1*dy),x+(0.4*dx),y-(0.05*dy),x,y-(0.05*dy));
  triangle(x+(0.4*dx),y-(0.05*dy),x-(0.25*dx),y+(0.5*dy),x,y);
}

//x and y are in the middle of the rain drop
void drawRainDrop(float x, float y, float dx, float dy) {
 fill(0,0,255);
 noStroke();
 ellipse(x,y,dx,0.5*dy);
 triangle(x,y-dy,x-(0.5*dx),y,x+(0.5*dx),y); 
}

//x and y are in the middle of the moon
void drawMoon(float x, float y, float dx, float dy) {
  fill(150);
  noStroke();
  ellipse(x,y,dx,dy);
  fill(50);
  ellipse(x-(0.25*dx),y+(0.25*dy),0.2*dx,0.2*dy);
  ellipse(x-(0.13*dx),y-(0.17*dy),0.3*dx,0.3*dy);
  ellipse(x+(0.25*dx),y+(0.05*dy),0.4*dx,0.4*dy);
}

//x and y are in the middle of the sun
void drawSun(float x, float y, float dx, float dy) {
  fill(255,255,0);
  noStroke();
  ellipse(x,y,0.5*dx,0.5*dy);
  
  strokeWeight(8);
  stroke(255,255,0);
  for (int a = 0; a < 360; a+=45) {
    float angle = radians(a);
    line(x + cos(angle) * dx * 0.3,  y + sin(angle) * dy * 0.3, x + cos(angle) * 0.5*dx, y + sin(angle) * 0.5*dy);
  }
}

//x and y are in the middle of the cloud
void drawCloud(float x, float y, float dx, float dy, int fill) {
  fill(fill);
  noStroke();
  ellipse(x-(0.3*dx),y+(0.25*dy),0.5*dx,0.5*dy); //left
  ellipse(x+(0.3*dx),y+(0.25*dy),0.5*dx,0.5*dy); //right
  ellipse(x,y,0.6*dx,0.5*dy); //center
  rect(x-(0.3*dx),y,0.6*dx,0.5*dy); //center
}

//need to account for overload;
void getWeatherData() {
  String url = baseURL + "&APPID=" + apiKey;
  weatherData = loadJSONObject(url);
  location = weatherData.getString("name");
  
  temp = weatherData.getJSONArray("weather");
  curWeatherData = temp.getJSONObject(0);
  curState = curWeatherData.getString("main");
  curDescription = curWeatherData.getString("description");
  curID = curWeatherData.getInt("id");
  
  curWeatherData = weatherData.getJSONObject("main");
  curTemp = curWeatherData.getFloat("temp");
  
  //find whether daytime or nightime 
  curWeatherData = weatherData.getJSONObject("sys");
  sunriseTime = curWeatherData.getInt("sunrise");
  sunrise.setTimeInMillis(sunriseTime);
  sunsetTime = curWeatherData.getInt("sunset");
  sunrise.setTimeInMillis(sunsetTime);
  currentTime = weatherData.getInt("dt");
  current.setTimeInMillis(currentTime);
  if (currentTime >= sunriseTime && currentTime <= sunsetTime) {
    daytime = true;
  } else {
    daytime = false;
  }
  println(curState);
  println(curDescription);
  println(curID);
  println(kelvinToF(curTemp));
  println(location);
}

float kelvinToF(float kTemp) {
  float fTemp = kTemp * 1.8 - 459.67;
  return fTemp;
}

void setupClock() {
  float radius = min(width, height) / 2.5;
  secondsRadius = radius * 0.72;
  minutesRadius = radius * 0.60;
  hoursRadius = radius * 0.50;
  clockDiameter = radius * 1.8;
  
  cx = width / 4;
  cy = height / 2;
}

void drawClock() {
  background(0);
  drawClockFace();  //draw analog clock
  drawClockInfo();  //draw time and date
}  

void drawClockInfo() {
  //time
  fill(255);
  noStroke();
  rect(width*0.52, height/8, width*0.46, height/3.2, 10);
  int hour = hour();
  String ampm = "AM";
  if (hour > 11) {
    hour = hour - 12;
    ampm = "PM";
  }
  if (hour == 0) {
    hour = 12;
  }
  String stringTime = str(hour) + ":" + nf(minute(),2) + " " + ampm;
  textSize(80);
  fill(0);
  textAlign(CENTER);
  text(stringTime, (width*0.75), (height/3));
  //date
  fill(255);
  textSize(40);
  int day = day();
  int month = month();
  int year = year();
  String stringDate = str(month) + "/" + str(day) + "/" + str(year);
  text(stringDate, width*0.75, height*.7);
  
}  

void drawClockFace() {
  // Draw the clock background
  fill(80);
  stroke(255);
  noStroke();
  ellipse(cx, cy, clockDiameter, clockDiameter);
  
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(second(), 0, 60, 0, TWO_PI) - HALF_PI;
  float m = map(minute() + norm(second(), 0, 60), 0, 60, 0, TWO_PI) - HALF_PI; 
  float h = map(hour() + norm(minute(), 0, 60), 0, 24, 0, TWO_PI * 2) - HALF_PI;
  
  // Draw the hands of the clock
  stroke(255);
  strokeWeight(1);
  line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);
  strokeWeight(2);
  line(cx, cy, cx + cos(m) * minutesRadius, cy + sin(m) * minutesRadius);
  strokeWeight(4);
  line(cx, cy, cx + cos(h) * hoursRadius, cy + sin(h) * hoursRadius);
  
  // Draw the minute ticks
  strokeWeight(3);
  beginShape(POINTS);
  for (int a = 0; a < 360; a+=30) {
    float angle = radians(a);
    float x = cx + cos(angle) * secondsRadius;
    float y = cy + sin(angle) * secondsRadius;
    vertex(x, y);
  }
  endShape();
}