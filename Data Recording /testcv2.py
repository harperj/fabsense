import cv2 
import time, sys

print "Filename testVideo-timestamp-7.txt"
f = open("testNoVideo-timestamp-7.txt", "w")


camera = cv2.VideoCapture(0)
fps = 6
capSize = (1028,720)
fourcc = cv2.cv.CV_FOURCC('T','H','E','O') # note the lower case
_, img = camera.read()
height, width, layers = img.shape

video = cv2.VideoWriter('output-7.ogv', fourcc, fps, (width, height))

while True:
   _, img = camera.read()
   video.write(img)
   f.write(str(time.time()) + "\n")

   #cv2.imshow("webcam",img)
   if (cv2.waitKey(40) != -1):
       break

f.close()

video.release()  
video = None
camera.release()


## CV_CAP_PROP_FPS
##cv2.VideoCapture.get(propId)

