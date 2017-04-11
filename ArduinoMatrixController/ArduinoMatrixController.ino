#include "Affine.h"

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
                                    
const Matrix Protanomaly =   Affine(Vector(.82, .18,   0),
                                    Vector(.33, .67,   0),
                                    Vector(  0, .13, .88), 
                                    Point(   0,   0,   0));
                                    
const Matrix Deuteranopia =  Affine(Vector(.63, .38,   0),
                                    Vector( .7,  .3,   0),
                                    Vector(  0,  .3,  .7),
                                    Point(   0,   0,   0));
                                    
const Matrix Deuteranomaly = Affine(Vector( .8,  .2,   0),
                                    Vector(.26, .74,   0),
                                    Vector(  0, .14, .86),
                                    Point(   0,   0,   0));
                                    
const Matrix Tritanopia =    Affine(Vector(.95, .05,   0),
                                    Vector(  0, .43, .57), 
                                    Vector(  0, .48, .53),
                                    Point(   0,   0,   0));
                                    
const Matrix Tritanomaly =   Affine(Vector(.97, .03,   0),
                                    Vector(  0, .73, .27),
                                    Vector(  0, .18, .82),
                                    Point(   0,   0,   0));
                                    
const Matrix Achromatopsia = Affine(Vector( .3, .59, .11),
                                    Vector( .3, .59, .11),
                                    Vector( .3, .59, .11),
                                    Point(   0,   0,   0));
                                    
const Matrix Achromatomaly = Affine(Vector(.62, .32, .06),
                                    Vector(.16, .78, .06),
                                    Vector(.16, .32, .52),
                                    Point(   0,   0,   0));
const Matrix InverseM = Affine(Vector(-1,0,0),
                              Vector(0,-1,0),
                              Vector(0,0,-1),
                              Point(1,1,1));

const Matrix Simulation = Transpose(Scale(1.f/65536.f)*
                                    Affine(Vector(7365, 58170, 0),
                                           Vector(7365, 58170 , 0),
                                           Vector(262, -262, 65536), 
                                           Point(0,0,0)));

const Matrix Adjustment = Transpose(Scale(1.f/65536.f)*
                                    Affine(Vector(0, 0, 0),
                                           Vector(45875, 65536,0),
                                           Vector(45875, 0, 65536), 
                                           Point(0,0,0)));

void setup() {
  // initialize the serial communication:
  Serial.begin(2000000);
  //Serial.begin(115200);
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
}

void loop() {
    const double rwgt = 0.3333;// 0.3086;
    const double gwgt = 0.3334;// 0.6094;
    const double bwgt = 0.3333;// 0.0820;
    double sat;//= ;
    static float time = 0;
    sat = (float)analogRead(A0) / 64 - (1024/128);
    time += (float)analogRead(A1)/1024;
    //PrintMatrix(Rot(time, Vector(1,1,1))*Scale(sat), 1);
    while(1)
    {
      static double t = 0;
      t += 0.01;
      static char value = 0;
      PrintMatrix(Simulation,1);
      PrintMatrix(Adjustment,2);
      PrintMatrix(Protanopia,3);
//      value++;
//    PrintMatrix(Trans(Vector(value*255 + 255/3, value*255 + 2*255/3, value*255)),1);
    delay(20);
    }
    //double multiplier = analogRead(A1) + 1;
    //sat /= 1023/2;
    //sat -= 1;
    //multiplier /= 8;
    //sat *= multiplier;
    //Serial.println(sat);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*rwgt + sat)* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*gwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*bwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*rwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*gwgt + sat)* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*bwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*rwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.print((int32_t)(((1.0-sat)*gwgt )* 65536),HEX);
//    Serial.print(" 0x");
//    Serial.println((int32_t)(((1.0-sat)*bwgt + sat)* 65536),HEX);
    delay(1000);
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

