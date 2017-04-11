// Ben Nollan
// Assignment 1
// CS250
// Spring 2017

#include "Affine.h"


Hcoord::Hcoord(float X, float Y,float Z, float W) : x(X), y(Y), z(Z), w(W)
{

}


Point::Point(float X, float Y, float Z)
{
  x = X;
  y = Y;
  z = Z;
  w = 1;
}

Vector::Vector(float X, float Y, float Z)
{
  x = X;
  y = Y;
  z = Z;
  w = 0;
}

Affine::Affine()
{
  row[3][3] = 1;
}

Affine::Affine(const Vector& Lx, const Vector& Ly, const Vector& Lz, const Point& disp)
{
  for (int i = 0; i < 4; ++i)
  {
    row[i][0] = Lx[i];
    row[i][1] = Ly[i];
    row[i][2] = Lz[i];
    row[i][3] = disp[i];
  }
}

Hcoord operator+(const Hcoord& u, const Hcoord& v)
{
  return Hcoord(u.x + v.x, u.y + v.y, u.z + v.z, u.w + v.w);
}

Hcoord operator-(const Hcoord& u, const Hcoord& v)
{
  return Hcoord(u.x - v.x, u.y - v.y, u.z - v.z, u.w - v.w);
}

Hcoord operator-(const Hcoord& v)
{
  return Hcoord(-v.x, -v.y, -v.z, -v.w);
}

Hcoord operator*(float r, const Hcoord& v)
{
  return Hcoord(v.x * r, v.y * r, v.z * r, v.w * r);
}

Hcoord operator*(const Matrix& A, const Hcoord& v)
{
  Hcoord newH;
  for (int i = 0; i < 4; ++i)
  {
    newH[i] = A[i][0] * v[0] 
              + A[i][1] * v[1] 
              + A[i][2] * v[2] 
              + A[i][3] * v[3];
  }
  return newH;
}

Matrix operator*(const Matrix& A, const Matrix& B)
{
  Affine newA;
  for (int i = 0; i < 4; ++i)
  {
    for (int j = 0; j < 4; ++j)
    {
      newA[i][j] = A[i][0] * B[0][j] 
                    + A[i][1] * B[1][j] 
                    + A[i][2] * B[2][j] 
                    + A[i][3] * B[3][j];
    }
  }
  return newA;
}

float dot(const Vector& u, const Vector& v)
{
  return u.x * v.x + u.y * v.y + u.z * v.z;
}

float abs(const Vector& v)
{
  return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vector normalize(const Vector& v)
{
  Vector newV;
  float length = abs(v);
  newV.x = v.x / length;
  newV.y = v.y / length;
  newV.z = v.z / length;
  return newV;
}

Vector cross(const Vector& u, const Vector& v)
{
  Vector newV;
  newV.x = u.y * v.z - u.z * v.y;
  newV.y = u.z * v.x - u.x * v.z;
  newV.z = u.x * v.y - u.y * v.x;
  return newV;
}

Affine Rot(float t, const Vector& v)
{
  float cosT = cos(t);
  float transposeScalar = (1 - cosT) / (v.x*v.x + v.y*v.y + v.z*v.z);
  float crossScalar = sin(t) / abs(v);
  Affine crossMatrix;
  crossMatrix[0][1] = -v.z * crossScalar;
  crossMatrix[1][0] =  v.z * crossScalar;
  crossMatrix[0][2] =  v.y * crossScalar;
  crossMatrix[2][0] = -v.y * crossScalar;
  crossMatrix[1][2] = -v.x * crossScalar;
  crossMatrix[2][1] =  v.x * crossScalar;

  Affine newM;
  for (int i = 0; i < 3; ++i)
  {
    for (int j = 0; j < 3; ++j)
    {
      float temp;
      if (i == j)
        temp = cosT;
      else
        temp = crossMatrix[i][j];

      newM[i][j] = temp + v[i] * v[j] * transposeScalar;
    }
  }
  newM[3][3] = 1;
  return newM;
}

Affine Trans(const Vector& v)
{
  Affine newM;
  newM[0][0] = 1;
  newM[1][1] = 1;
  newM[2][2] = 1;
  newM[0][3] = v.x;
  newM[1][3] = v.y;
  newM[2][3] = v.z;
  return newM;
}

Affine Scale(float r)
{
  Affine newM;
  for (int i = 0; i < 3; ++i)
    newM[i][i] = r;
  return newM;
}

Affine Scale(float rx, float ry, float rz)
{
  Affine newM;
  newM[0][0] = rx;
  newM[1][1] = ry;
  newM[2][2] = rz;
  return newM;
}

Affine Inverse(const Affine& A)
{
  Affine newA;
  newA[0][0] = A[1][1] * A[2][2] - A[1][2] * A[2][1];
  newA[0][1] = A[0][2] * A[2][1] - A[0][1] * A[2][2];
  newA[0][2] = A[0][1] * A[1][2] - A[0][2] * A[1][1];
  newA[1][0] = A[2][0] * A[1][2] - A[1][0] * A[2][2];
  newA[1][1] = A[0][0] * A[2][2] - A[0][2] * A[2][0];
  newA[1][2] = A[0][2] * A[1][0] - A[0][0] * A[1][2];
  newA[2][0] = A[1][0] * A[2][1] - A[1][1] * A[2][0];
  newA[2][1] = A[0][1] * A[2][0] - A[0][0] * A[2][1];
  newA[2][2] = A[0][0] * A[1][1] - A[1][0] * A[1][0];

  float det = A[0][0] * newA[0][0] + A[1][0] * newA[0][1] + A[2][0] * newA[0][2];
  for (int i = 0; i < 3; ++i)
  {
    for (int j = 0; j < 3; ++j)
      newA[i][j] /= det;
  }
  Vector translation = newA * Vector(-A[0][3], -A[1][3], -A[2][3]);
  newA[0][3] = translation[0];
  newA[1][3] = translation[1];
  newA[2][3] = translation[2];
  return newA;
}

Affine Transpose(const Affine& A)
{
  Affine newOne;
  for(int i = 0; i < 4; ++i)
  {
    for(int j = 0; j < 4; ++j)
    {
      newOne[i][j] = A[j][i];
    }
  }
  return newOne;
}

