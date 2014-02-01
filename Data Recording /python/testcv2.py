import cv2 
import time, sys

testnum = 15;

print "Filename testVideo-timestamp-" + str(testnum) + ".txt"
f = open("testVideo-timestamp-" + str(testnum) + ".txt", "w")


camera = cv2.VideoCapture(0)

fps = 15
camera.set(cv2.cv.CV_CAP_PROP_FPS, 15)
capSize = (1028,768)

fourcc = cv2.cv.CV_FOURCC('X','V','I','D')  # note the lower case
_, img = camera.read()
height, width, layers = img.shape

video = cv2.VideoWriter('output-' + str(testnum) + '.avi', fourcc, fps, (width, height), 1)

while True:
   _, img = camera.read()
   video.write(img)
   f.write(str(time.time()) + "\n")

   #cv2.imshow("webcam",img)
   if (cv2.waitKey(1) != -1):
       break

f.close()

video.release()  
video = None
camera.release()


## CV_CAP_PROP_FPS
##cv2.VideoCapture.get(propId)

