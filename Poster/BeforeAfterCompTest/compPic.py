from PIL import Image
from math import sqrt

im1 = Image.open("peppers1.png")
#im2 = Image.open("peppers2.png")
#im3 = Image.open("peppers1.png")
#im4 = Image.open("peppers2.png")

im5 = Image.new(im1.mode, im1.size)
im6 = Image.new(im1.mode, im1.size)
im7 = Image.new(im1.mode, im1.size)

im1.close()


for firstIm in range(1,5):
  im1 = Image.open("peppers" + str(firstIm) + ".png")
  
  for secondIm in range(1, 5):
  
    
    im2 = Image.open("peppers" + str(secondIm) + ".png")
  
    for x in range(im2.size[0]):
      for y in range(im2.size[1]):
        pixel1 = im1.getpixel((x,y))
        pixel2 = im2.getpixel((x,y))
        Rdiff = pixel1[0] - pixel2[0]
        Gdiff = pixel1[1] - pixel2[1]
        Bdiff = pixel1[2] - pixel2[2]
        Adiff = pixel1[3] - pixel2[3]
        Dist = Rdiff**2 + Gdiff**2 + Bdiff**2 + Adiff**2
        Dist = sqrt(Dist)
        im5.putpixel((x,y),(int(Dist), int(Dist), int(Dist), 255))
        
    for x in range(im2.size[0]):
      for y in range(im2.size[1]):
        pixel1 = im1.getpixel((x,y))
        pixel2 = im2.getpixel((x,y))
        Rdiff = pixel1[0] - pixel2[0]
        Gdiff = pixel1[1] - pixel2[1]
        Bdiff = pixel1[2] - pixel2[2]
        Adiff = pixel1[3] - pixel2[3]
        Dist = Rdiff**2 + Gdiff**2 + Bdiff**2 + Adiff**2
        Dist = sqrt(Dist)
        im6.putpixel((x,y),(Rdiff, Gdiff, Bdiff, 255))
    
    for x in range(im2.size[0]):
      for y in range(im2.size[1]):
        pixel1 = im1.getpixel((x,y))
        pixel2 = im2.getpixel((x,y))
        Rdiff = pixel1[0] - pixel2[0]
        Gdiff = pixel1[1] - pixel2[1]
        Bdiff = pixel1[2] - pixel2[2]
        Adiff = pixel1[3] - pixel2[3]
        Dist = Rdiff**2 + Gdiff**2 + Bdiff**2 + Adiff**2
        Dist = sqrt(Dist)
        im7.putpixel((x,y),(abs(Rdiff), abs(Gdiff), abs(Bdiff), 255))
    
    im2.close()
    
    im5.save("diff" + str(firstIm) + "-" + str(secondIm) + ".png")
    im6.save("colordiff" + str(firstIm) + "-" + str(secondIm) + ".png")
    im6.save("abscolordiff" + str(firstIm) + "-" + str(secondIm) + ".png")
    
  im1.close()