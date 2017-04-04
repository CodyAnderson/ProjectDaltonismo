#include "Affine.h"

void setup() {
  // initialize the serial communication:
  Serial.begin(2000000);
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
    PrintMatrix(Rot(time, Vector(1,1,1))*Scale(sat));
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
    delay(20);
}

void PrintMatrix(const Matrix &m)
{
  for(int i = 0; i < 3; ++i)
  {
    for(int j = 0; j < 3; ++j)
    {
      Serial.print(" 0x");
      Serial.print((int32_t)(m[j][i] * 65536),HEX);
    }
  }
  
  Serial.println("M");
}

