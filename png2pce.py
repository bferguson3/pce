#!/usr/bin/python3
# png288.py
# use: $ python3 png288.py <imagefile>

# $ python3 -m pip install --upgrade Pillow
# $ pip install numpy

import numpy
import sys 
import os 
from PIL import Image, ImageDraw

img, b2, b3 = None, None, None 

###
raw = True
###

def FilterPlane(p):
    a = []
    wid = img.size[0]
    hei = img.size[1]
    for ii in range(0, hei):
        for jj in range(0, wid):
            data = img.getpixel((jj,ii))
            #print(data)
            if(data & p):
                a.append(1)
            else:
                a.append(0)
    return a
totalbytes = 0

obstr = ''                
img = Image.open(sys.argv[1])
b2 = numpy.asarray(img)
b3 = Image.new('L', (b2.shape[1], b2.shape[0]), 0)
o = []

fn = os.path.splitext(sys.argv[1])[0]
fn2 = fn.split('/')
fn2 = fn2[len(fn2)-1]

a = FilterPlane(0b0001)
b = FilterPlane(0b0010)
c = FilterPlane(0b0100)
d = FilterPlane(0b1000)

imsize = img.size 

# split a,b,c,d into 8x8 pixel arrangements 
atiles = []
btiles = []
ctiles = []
dtiles = []


h = 0
while h < imsize[1]:
    w = 0
    while w < imsize[0]:
        #by = ''
        y = 0
        while y < 8:
            # PLANE 0
            x = 0
            bystr = '.byte %'
            while x < 8:
                if((h+y) < imsize[1]) and ((w+x)<imsize[0]):
                    bystr += str(a[((h+y)*imsize[0])+(w+x)])
                else:
                    padd = True 
                x += 1
            print(bystr)
            # PLANE 1
            x = 0
            bystr = '.byte %'
            while x < 8:
                if((h+y) < imsize[1]) and ((w+x)<imsize[0]):
                    bystr += str(b[((h+y)*imsize[0])+(w+x)])
                else:
                    padd = True 
                x += 1
            print(bystr)
            y += 1
        print('')
        y = 0
        while y < 8:
            # PLANE 2
            x = 0
            bystr = '.byte %'
            while x < 8:
                if((h+y) < imsize[1]) and ((w+x)<imsize[0]):
                    bystr += str(c[((h+y)*imsize[0])+(w+x)])
                else:
                    padd = True 
                x += 1
            print(bystr)
            # PLANE 3
            x = 0
            bystr = '.byte %'
            while x < 8:
                if((h+y) < imsize[1]) and ((w+x)<imsize[0]):
                    bystr += str(d[((h+y)*imsize[0])+(w+x)])
                else:
                    padd = True 
                x += 1
            print(bystr)
            y += 1
        
        print('')
        
        w += 8
    h += 8
