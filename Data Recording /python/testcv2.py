import cv2 
import time, sys

f = open("outputime.txt", "w")


camera = cv2.VideoCapture(0)
fps = 20
capSize = (1028,720)
fourcc = cv2.cv.CV_FOURCC(*'MJPG') # note the lower case
_, img = camera.read()
height, width, layers = img.shape

video = cv2.VideoWriter('output.mov', -1, fps, (width,height))

while True:	
   _, img = camera.read()
   cv2.imshow('frame',img)
   video.write(img)
   f.write(str(time.time()) + "\n")

   #cv2.imshow("webcam",img)
   if (cv2.waitKey(10) != -1):
       break

f.close()

video.release()  
video = None
camera.release()


## CV_CAP_PROP_FPS
##cv2.VideoCapture.get(propId)

