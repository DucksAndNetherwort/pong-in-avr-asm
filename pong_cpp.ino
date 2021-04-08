#include <SPI.h>
#include <SoftwareSerial.h>

#define CLK_PIN   13
#define DATA_PIN  11
#define CS_PIN    10

const int playerU = 9;
const int playerD = 8;
                        //quick note: this entire thing is running in asm. not one cpp function gets called
						//to switch to full C++, simply remove the "ASM" part from the function calls
uint8_t imgBuffer[16];
uint8_t P1 = 1;
uint8_t P2 = 1;
uint8_t paddleSize = 5;
uint8_t ball[2] = {7, 3};
bool trajectory[2] = {0xff, 0xff};
uint8_t score = 0;
uint8_t scoreDivide = 3;
uint8_t updateBall = 0;
//uint8_t justOnes[16] = {0b10000000, 0b01000000, 0b00100000, 0b00010000, 0b00001000, 0b00000100, 0b00000010, 0b00000001, 0b10000000, 0b01000000, 0b00100000, 0b00010000, 0b00001000, 0b00000100, 0b00000010, 0b00000001};

extern "C" void playerUpdateASM();
extern "C" void ballUpdateASM();
extern "C" void renderASM();
extern "C" void dispClearASM();
extern "C" void resetGameASM();
extern "C" void dispWriteASM();
extern "C" void spiSetup();

void render() {//render gamestate to image buffer for display
  //change a pixel: imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
  uint8_t pen[2];

  pen[0] = 15;
  pen[1] = P1;
  for(int i = 0; i < paddleSize; i++) {
    //render player paddle
    imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
    pen[1]++;
  }

  pen[0] = 0;
  pen[1] = ball[1] >> 1;
  if(ball[1] > (paddleSize + 1)) {
    pen[1] = (8 - paddleSize);
  }
  if(ball[1] < 1) {
    pen[1] = 0;
  }
  
  for(int i = 0; i < paddleSize; i++) {
    //render computer paddle
    imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
    pen[1]++;
  }

  pen[0] = ball[0];
  pen[1] = ball[1];
  //pen[0] = 0;
  //pen[1] = 1;
  imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
}

void dispWrite0() {//write image buffer to display
  uint8_t a = 1;
  uint8_t b = 0;
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(1);
  SPI.transfer(imgBuffer[1]);
  b++;
  SPI.transfer(1);
  SPI.transfer(imgBuffer[0]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(2);
  SPI.transfer(imgBuffer[3]);
  b++;
  SPI.transfer(2);
  SPI.transfer(imgBuffer[2]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(3);
  SPI.transfer(imgBuffer[5]);
  b++;
  SPI.transfer(3);
  SPI.transfer(imgBuffer[4]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(4);
  SPI.transfer(imgBuffer[7]);
  b++;
  SPI.transfer(4);
  SPI.transfer(imgBuffer[6]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(5);
  SPI.transfer(imgBuffer[9]);
  b++;
  SPI.transfer(5);
  SPI.transfer(imgBuffer[8]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(6);
  SPI.transfer(imgBuffer[11]);
  b++;
  SPI.transfer(6);
  SPI.transfer(imgBuffer[10]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(7);
  SPI.transfer(imgBuffer[13]);
  b++;
  SPI.transfer(7);
  SPI.transfer(imgBuffer[12]);
  b++;
  digitalWrite(CS_PIN, HIGH);

  digitalWrite(CS_PIN, LOW);
  a++;
  SPI.transfer(8);
  SPI.transfer(imgBuffer[15]);
  b++;
  SPI.transfer(8);
  SPI.transfer(imgBuffer[14]);
  b++;
  digitalWrite(CS_PIN, HIGH);
}

void dispWrite() {//updated version of the above function
  for(int y = 0; y < 8; y++) {
    digitalWrite(CS_PIN, LOW);
    SPI.transfer(y + 1);
    SPI.transfer(imgBuffer[(y << 1) + 1]);
    SPI.transfer(y + 1);
    SPI.transfer(imgBuffer[y << 1]);
    //Serial.println(y);
    digitalWrite(CS_PIN, HIGH);
  }
}

void dispClear() {//clear display
  for(int i = 0; i < 16; i++) {
    imgBuffer[i] = 0x00;
  }
}

void playerUpdate() {//update player paddle position
  if(!digitalRead(playerU) && (P1 > 0)) {
    P1--;
  }

  if(!digitalRead(playerD) && (P1 < (8 - paddleSize))) {
    P1++;
  }
}

void ballUpdate() {//update ball position/physics
  if(ball[1] >= 7) {
    trajectory[1] = false;
  }

  if(ball[1] == 0) {
    trajectory[1] = true;
  }

  if(ball[0] >= 15) {
    resetGame();
  }

  if(ball[0] == 14) {
    if((ball[1] >= P1) && (ball[1] < (P1 + paddleSize))) {
      trajectory[0] = false;
      score++;
    }
  }

  if(ball[0] == 1) {
    trajectory[0] = true;
  }

  if(trajectory[0]) {
    ball[0]++;
  }

  if(!trajectory[0]) {
    ball[0]--;
  }

  if(trajectory[1]) {
    ball[1]++;
  }

  if(!trajectory[1]) {
    ball[1]--;
  }
}

void resetGame() {//resets game state, duh
  asm("jmp 0x0000");
}

void setup() {
  pinMode(CS_PIN, OUTPUT); //DDRB: 0b00101100
  pinMode(playerU, INPUT_PULLUP);
  pinMode(playerD, INPUT_PULLUP);
  //SPI.begin();
  spiSetup();
  Serial.begin(115200);
  dispClearASM();
  dispWriteASM();
  PORTD = (1 << (scoreDivide - 1));
}

void loop() {
  updateBall++;

  if(updateBall > (7 - scoreDivide)) {
    updateBall = 0;
    ballUpdateASM();
  }

  playerUpdateASM();
  dispClearASM();
  renderASM();
  dispWriteASM();

  if(score >= (1 << scoreDivide)) {
    if(!(scoreDivide > 7)) {
      scoreDivide++;
      paddleSize--;
    }

    if(scoreDivide > 7) {
      scoreDivide = 7;
    }

    if(paddleSize < 1) {
      paddleSize = 1;
    }

    PORTD = (1 << (scoreDivide - 1));
  }
  
  delay(50);
}