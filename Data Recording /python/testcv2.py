import cv2 
import time, sys

testnum = 15;

print "Filename testVideo-timestamp-" + str(testnum) + ".txt"
f = open("testVideo-timestamp-" + str(testnum) + ".txt", "w")


camera = cv2.VideoCapture(0)
fps = 9
capSize = (1028,720)
fourcc = cv2.cv.CV_FOURCC('T','H','E','O') # note the lower case
_, img = camera.read()
height, width, layers = img.shape

video = cv2.VideoWriter('output-' + str(testnum) + '.ogv', fourcc, fps, (width, height))

while True:
   _, img = camera.read()
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

