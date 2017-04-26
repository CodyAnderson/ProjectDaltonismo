#include "Affine.h"

#define LEFT_BTN 8
#define RIGHT_BTN 9
#define CENTER_BTN 10
#define STATE_MAX 6
#define TRANSITION_INCREMENT 0.1f

// Matrix one = simulation....
// Matrix two = compensation...
// Matrix three = adjustment...


const Matrix Normal =        Affine(Vector(  1,   0,   0),
                                    Vector(  0,   1,   0), 
                                    Vector(  0,   0,   1),
                                    Point(   0,   0,   0));
                                    
const Matrix Protanopia =    Transpose(Affine(Vector(.57, .43,   0),
                                    Vector(.56, .44,   0),
                                    Vector(  0, .24, .76),
                                    Point(   0,   0,   0)));
                                    
const Matrix Protanomaly =   Transpose(Affine(Vector(.82, .18,   0),
                                    Vector(.33, .67,   0),
                                    Vector(  0, .13, .88), 
                                    Point(   0,   0,   0)));
                                    
const Matrix Deuteranopia =  Transpose(Affine(Vector(.63, .38,   0),
                                    Vector( .7,  .3,   0),
                                    Vector(  0,  .3,  .7),
                                    Point(   0,   0,   0)));
                                    
const Matrix Deuteranomaly = Transpose(Affine(Vector( .8,  .2,   0),
                                    Vector(.26, .74,   0),
                                    Vector(  0, .14, .86),
                                    Point(   0,   0,   0)));
                                    
const Matrix Tritanopia =    Transpose(Affine(Vector(.95, .05,   0),
                                    Vector(  0, .43, .57), 
                                    Vector(  0, .48, .53),
                                    Point(   0,   0,   0)));
                                    
const Matrix Tritanomaly =   Transpose(Affine(Vector(.97, .03,   0),
                                    Vector(  0, .73, .27),
                                    Vector(  0, .18, .82),
                                    Point(   0,   0,   0)));
                                    
const Matrix Achromatopsia = Transpose(Affine(Vector( .3, .59, .11),
                                    Vector( .3, .59, .11),
                                    Vector( .3, .59, .11),
                                    Point(   0,   0,   0)));
                                    
const Matrix Achromatomaly = Transpose(Affine(Vector(.62, .32, .06),
                                    Vector(.16, .78, .06),
                                    Vector(.16, .32, .52),
                                    Point(   0,   0,   0)));
const Matrix InverseM = Affine(Vector(-1,0,0),
                              Vector(0,-1,0),
                              Vector(0,0,-1),
                              Point(1,1,1));

const Matrix ProCompensation = Transpose(Scale(1.f/65536.f)*
                                    Affine(Vector(7365, 58170, 0),
                                           Vector(7365, 58170 , 0),
                                           Vector(262, -262, 65536), 
                                           Point(0,0,0)));

const Matrix ProAdjustment = Transpose(Scale(1.f/65536.f)*
                                    Affine(Vector(0, 0, 0),
                                           Vector(45875, 65536,0),
                                           Vector(45875, 0, 65536), 
                                           Point(0,0,0)));

const Matrix Compensation2 = Transpose(Affine(Vector(0, 0.0332818, -0.0877292),Vector(0, 0.033282, -0.0877289),Vector(0, -0.00486077, 0.694434),Point(0,0,0)));

const Matrix SuperBoosted = Scale(64) * Trans(Vector(-0.7f,-0.7f,-0.7f));

const Matrix Inversion = Scale(-1) * Trans(Vector(-1,-1,-1));

void setup() {
  // initialize the serial communication:
  Serial.begin(2000000);
  //Serial.begin(115200);
  pinMode(3, INPUT);
  pinMode(8, INPUT);
  pinMode(9, INPUT);
  pinMode(10, INPUT);
}

void loop() {
  //Determine which effect
  int state = StateChooser();
  //Choose effect
  Matrix *One, *Two, *Three;
  switch(state)
  {
    case 1:
    One = &Protanopia;
    Two = &ProCompensation;
    Three = &ProAdjustment;
    break;
    case 2:
    One = &Deuteranopia;
    Two = &ProCompensation;
    Three = &ProAdjustment;
    break;
    case 3:
    One = &Tritanopia;
    Two = &ProCompensation;
    Three = &ProAdjustment;
    break;
    case 4:
    One = &Inversion;
    Two = &Normal;
    Three = &Normal;
    break;
    case 5:
    One = &SuperBoosted;
    Two = &Normal;
    Three = &Normal;
    break;
    default:
    One = &Normal;
    Two = &Normal;
    Three = &Normal;
    break;
  }
  //Transition effect
  OutputTripleDeuce(One,Two,Three);
  //Wait for next frame

      //PrintMatrix(Protanopia,1);
      //PrintMatrix(ProCompensation,2);
      //PrintMatrix(ProAdjustment,3);

      
     // value = sin(t) * 0.5f + 0.5f;
      //PrintMatrix(Scale(value) * Protanopia + Scale(1-value) * Normal,1);
      //PrintMatrix(Scale(value) * ProCompensation + Scale(1-value) * Normal,2);
      //PrintMatrix(Scale(value) * ProAdjustment + Scale(1-value) * Normal,3);
      //PrintMatrix(Scale(128) * Trans(Vector(-value/2-0.5f,-value/2-0.5f,-value/2-0.5f)),1);
    //PrintMatrix(Trans(Vector(value*255 + 255/3, value*255 + 2*255/3, value*255)),1);
    WaitForFrame();
}

void WaitForFrame()
{
  static unsigned long t = 0;
  while(t + 20 > millis() && !digitalRead(3));
  t = millis();
}

void OutputTripleDeuce(Matrix *One, Matrix *Two, Matrix *Three)
{
  static Matrix *prevOne = &Normal;
  static Matrix *prevTwo = &Normal;
  static Matrix *prevThree = &Normal;
  static Matrix *transOne = &Normal;
  static Matrix *transTwo = &Normal;
  static Matrix *transThree = &Normal;
  static float t = 0;
  if(t)
  {
    float mue = cos(t) * 0.5f + 0.5f;
    PrintMatrix(Scale(1-mue) * *transOne + Scale(mue) * *prevOne,1);
    PrintMatrix(Scale(1-mue) * *transTwo + Scale(mue) * *prevTwo,2);
    PrintMatrix(Scale(1-mue) * *transThree + Scale(mue) * *prevThree,3);
    t += TRANSITION_INCREMENT;
    if(t > 3.1415926)
    {
      t = 0;
      prevOne = transOne;
      prevTwo = transTwo;
      prevThree = transThree;
    }
  }
  else if(One != prevOne || Two != prevTwo || Three != prevThree)
  {
    t = TRANSITION_INCREMENT;
    transOne = One;
    transTwo = Two;
    transThree = Three;
  }
  else
  {
    PrintMatrix(*prevOne,1);
    PrintMatrix(*prevTwo,2);
    PrintMatrix(*prevThree,3);
  }
}

int StateChooser()
{
  // {LEFT_BTN, RIGHT_BTN, CENTER_BTN, ON/OFF}
  static int state = 0;
  static int buttonStates = 0;
  int currentButtonStates = 0;
  if(!digitalRead(LEFT_BTN))
  {
    currentButtonStates |= 1;
    if((!(buttonStates & 1)) && state)
      --state;
  }
  if(!digitalRead(RIGHT_BTN))
  {
    currentButtonStates |= 2;
    if((!(buttonStates & 2)) && state < STATE_MAX)
      ++state;
  }
  if(!digitalRead(CENTER_BTN))
  {
    currentButtonStates |= 4;
    if(!(buttonStates & 4))
      if(buttonStates & 8)
        buttonStates &= ~8;
      else
        buttonStates |= 8;
  }
  buttonStates = currentButtonStates | (buttonStates & 8);
  if((buttonStates & 8))
    return 0;
  else
    return state;
  
}

void PrintMatrix(const Matrix &m, int spot)
{
  Serial.print(spot);
  for(int i = 0; i < 4; ++i)
  {
    for(int j = 0; j < 4; ++j)
    {
      Serial.print(" 0x");
      Serial.print((int32_t)(m[i][j] * 65536),HEX);
    }
  }
  
  Serial.println("M");
}

