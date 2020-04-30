/*
Dogstagram
by Kara Ngamsopee

This is Dogstagram where you at a lot cute doggos and give them love by tapping the screen :)
You can adjust the speed of the slideshow by turning the potentiometer.
*/

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

String[] data;

int buttonValue = 0;
int potValue = 0;
int ldrValue = 0;

int serialIndex = 2;

// timing for doggo slideshow
Timer displayTimer;
Timer blinkTimer;
float timePerLine = 0;
float minTimePerLine = 100;
float maxTimePerLine = 2000;
int defaultTimerPerLine = 1500;

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

PImage heart;

// variables for the doggo slideslow
PImage[] photoList;
int numImages = 5;
int currentImg = 0;

// button for the heart
boolean button = false;

void setup ( ) {
  size (1000, 600);    

  // List all the available serial ports
  printArray(Serial.list());

  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200); 

  // Allocate the timer
  displayTimer = new Timer(defaultTimerPerLine);
  blinkTimer = new Timer(1000);

  // start the slideshow
  startSlide();

  // create list
  photoList = new PImage[numImages];

  // load doggo images
  photoList[0] = loadImage("assets/dog1.jpg");
  photoList[1] = loadImage("assets/dog2.jpg");
  photoList[2] = loadImage("assets/dog3.jpg");
  photoList[3] = loadImage("assets/dog4.jpg");
  photoList[4] = loadImage("assets/dog5.jpg");
  //instagram like heart
  heart = loadImage("assets/heart.png");

} 


//call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  

    print(inBuffer);

    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));

    // This function will make an array of TWO items, 1st item = button value, 2nd item = potValue
    data = split(inBuffer, ',');

    // have THREE items — ERROR-CHECK HERE
    if ( data.length >= 3 ) {
      buttonValue = int(data[0]);           // first index = button value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value

      // change the display timer
      timePerLine = map( potValue, minPotValue, maxPotValue, minTimePerLine, maxTimePerLine );
      displayTimer.setTimer( int(timePerLine));
      blinkTimer.setTimer( int(500));
    }
  }
} 

void draw ( ) {  
  // every loop, look for serial information
  checkSerial();

  drawBackground();
  checkMousePress();
  checkTimer();
  doggoImages();
} 

// if input value is 1 (from ESP32, indicating a button has been pressed), change the background
void drawBackground() {
  background(250, 250, 250);
}



// resets all variables
void startSlide() {
  currentImg = 0;
  displayTimer.start();
}

void checkTimer() {
  if ( displayTimer.expired() ) {
    currentImg++;

    if ( currentImg == photoList.length ) 
      currentImg = 0;

    displayTimer.start();
  }
}

void doggoImages() {
  
  image(photoList[currentImg], 250, 50);
  
// when button is on, show a heart on top of the picture
  if (button == true) {
    image(heart, 400, 200, 200, 200);
  } 
}


void checkMousePress() {
  if (mousePressed == true) {
    blinkTimer.start();
    button = true;
  }

 // after 0.5 sec, turn the button off
  if ( blinkTimer.expired() ) {
    button = false;
    blinkTimer.start();
  }
  
}
