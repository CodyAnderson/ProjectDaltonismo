// Affine.h
// -- points, vectors, transformations in 3D
// cs250 12/16

#ifndef CS250_AFFINE_H
#define CS250_AFFINE_H

#include <math.h>
//#include <cassert>


struct Hcoord {
  float x, y, z, w;
  explicit Hcoord(float X=0, float Y=0, float Z=0, float W=0);
  float& operator[](int i) { return *(&x+i); }
  float operator[](int i) const { return *(&x+i); }
};


struct Point : Hcoord {
  explicit Point(float X=0, float Y=0, float Z=0);
  Point(const Hcoord& v) : Hcoord(v) { };//assert(Near(w,1)); }
};
  

struct Vector : Hcoord {
  explicit Vector(float X=0, float Y=0, float Z=0);
  Vector(const Hcoord& v) : Hcoord(v) { };//assert(Near(w,0)); }
};


struct Matrix {
  Hcoord row[4];
  Hcoord& operator[](int i) { return row[i]; }
  const Hcoord& operator[](int i) const { return row[i]; }
};


struct Affine : Matrix {
  Affine(void);
  Affine(const Vector& Lx, const Vector& Ly, const Vector& Lz, const Point& D);
  Affine(const Matrix& M) : Matrix(M)                 
      { };
};


Hcoord operator+(const Hcoord& u, const Hcoord& v);
Hcoord operator-(const Hcoord& u, const Hcoord& v);
Hcoord operator-(const Hcoord& v);
Hcoord operator*(float r, const Hcoord& v);
Hcoord operator*(const Matrix& A, const Hcoord& v);
Matrix operator*(const Matrix& A, const Matrix& B);
float dot(const Vector& u, const Vector& v);
//float abs(const Vector& v);
Vector normalize(const Vector& v);
Vector cross(const Vector& u, const Vector& v);
Affine Rot(float t, const Vector& v);
Affine Trans(const Vector& v);
Affine Scale(float r);
Affine Scale(float rx, float ry, float rz);
Affine Inverse(const Affine& A);


#endif

