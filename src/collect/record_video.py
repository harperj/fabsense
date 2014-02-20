import cv2 
import time, sys, os

def capture_video(save_dir):
    camera = cv2.VideoCapture(0)
    timing_file = open(save_dir+"/"+save_dir+'-times.txt', 'w')
    camera.set(cv2.cv.CV_CAP_PROP_FPS, 30)

    fourcc = cv2.cv.CV_FOURCC('X','V','I','D')  # note the lower case
    _, img = camera.read()
    height, width, layers = img.shape
    
    
    times = []
    frames = []

    try:
        while True:	
            _, img = camera.read()
            frames.append(img)
            timing_file.write(str(time.time()) + "\n")
            times.append(time.time())
            #cv2.imshow("webcam",img)

    except:
        fps = find_fps(times)
        print fps
        video = cv2.VideoWriter(save_dir+"/"+save_dir+'-video.avi', fourcc, fps, (width, height), 1)
        for i in xrange(len(frames)):
            video.write(frames[i])

        timing_file.close()
        video.release()  
        video = None
        camera.release()

def find_fps(times):
    if len(times) == 1:
        return 0
        
    total = 0
    for i in xrange(len(times)):
        if i != 0:
            total += times[i] - times[i-1]
        
    avg = total / (len(times) - 1)
    return 1 / avg


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "USAGE: python record_video.py [folder_path]"
    else:
        os.mkdir(sys.argv[1])
        capture_video(sys.argv[1])
    
