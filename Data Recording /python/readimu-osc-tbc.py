#/usr/bin/python
from config import *
import time, sys, getopt, csv, pygame, random
import lib.motetalk as motetalk
from lib.motetalk import cmd, packetify, setpwm
from array import array
from collections import deque
import OSC, random,curses
import numpy as np
import scipy.signal as signal
import pygame


global length
global jerk_pos  

length = 31
temp   = [0] * (length)
smoothing = [0] * (len(derivative))
gaussian  = signal.gaussian(length,1,True)
hamming   = signal.hamming(length,True)
jerk_pos = True

class SensorWindows(object):
    def __init__(self, num_windows=9, window_length=9):
        self.length = window_length
        self.windows = []
        for i in xrange(num_windows):
            self.windows.append(np.zeros(window_length, dtype='f'))
        
        self.num_windows = num_windows
        self.index = 0
        
    def addValues(self, vals):
        if len(vals) != self.num_windows:
            print "ERROR: Number of values not equal to number of windows."
            return
        else:
            for i in xrange(self.num_windows):
                self.windows[i][self.index] = vals[i]
            self.index = (self.index + 1) % self.length
    
    def get(self, window_ind = -1):
        if window_ind == -1:
            return self.windows
        else:
            return self.windows[window_ind]    

def playSound():
  if sound:
    rand = random.randint(0,len(soundNames)-1)
    pygame.mixer.music.load('sounds/' + soundNames[rand] + '.ogg')
    pygame.mixer.music.play()

def log(data, client, csvwriter):
  row = [] 
  tempData = 0.;
  orderSensors = []
  row.append(str(time.time()))
  for sensor, setting in gina.iteritems():
    for axis, index in setting["data"].iteritems():
      msg = OSC.OSCMessage()                            if graph else ""
      msg.setAddress(setting["name"] + "/" + axis)      if graph else ""
      tempData = float(data[index]) / setting["scale"]
      msg.append(tempData)                              if graph else ""
      client.send(msg)                                  if graph else ""
      row.append(tempData)
      #print "(", sensor, ",", setting, ")"
 
  makeWindow(row[1:7], client, dorkbotHammer)
  csvwriter.writerow(row)

def plotOSC(client, address, data):
  if graph:
    msg = OSC.OSCMessage() 
    msg.setAddress(str(address))
    msg.append(data)
    client.send(msg)


def dorkbotHammer(data, client):
  magnitude = np.sqrt(np.array(data).dot(np.array(data)))
  global jerk_pos
  
  temp.append(data[4])
  temp.pop(0)

  smooth = np.convolve(temp,hamming,'valid')
  smoothing.append(float(smooth))
  smoothing.pop(0)
  plotOSC(client,'/gyro/hamming',smooth)
  jerk = deriv(smoothing,client)
  
  if jerk_pos:
      if jerk < -0.025:
          jerk_pos = False
          print "jerk change to neg ", jerk
          #print magnitude
          print data[4]
          if data[4] > 0.4 and data[1] > 0.005:
              print "HAMMERTIME "
              playSound()
  else:
      if jerk > 0.025:
          jerk_pos = True
          print "jerk change to pos ", jerk

def looseAcceptHammer(jerk, magnitude):
  if jerk > -0.05 and jerk < 0.05:
    if magnitude > 0.85:
      plotOSC(client,'/gyro/peaks',1.0)
      #playSound()
    else:
      plotOSC(client,'/gyro/peaks',0.0)

def makeWindow(data, client, hammerFunc):
  gyro = np.array(data[1])
  magnitude = np.sqrt(gyro.dot(gyro))
  plotOSC(client,'/gyro/net',magnitude)


  hammerFunc(data, client)

def deriv(data, client):
  #data = data[-len(derivative):]
  jerk = np.convolve(data,second_derivative,'valid')
  plotOSC(client,'/gyro/deriv',jerk)
  return jerk

def startup(m):
  m.sendbase(cmd.radio(23))
  # time.sleep(1)
  m.sendbase(cmd.flags(cmd.ledmode_cnt + cmd.notick))
  # time.sleep(1)

  m.sendheli(cmd.flags(cmd.ledmode_cnt + cmd.tick))
  # time.sleep(1)
  m.sendheli(cmd.mode(cmd.mode_imu_loop))
  # time.sleep(1)

  m.sendbase(cmd.mode(cmd.mode_sniff))
  # time.sleep(1)

def end(m):
  m.sendbase(cmd.mode(cmd.mode_spin))
  m.end()

def mAvg(num):
  temp.append(num)
  temp.pop(0)
  return sum(temp)/float(length)

def read(filename, verbose, graph):
  num_good = 0
  num_bad = 0
  num_skip = 0

  print filename

  with open(filename, 'w') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter= ",")
    csvwriter.writerow(["timestamp", "accX", "accY", "accZ", "gyrX", "gyrY", "gyrZ", "magX", "magY", "magZ"])


  # # BREAK CLEANLY
  #   # stdscr = curses.initscr()
  #   # curses.cbreak()
  #   # stdscr.keypad(1)
  #   # key = ''
  
    done = 0
    n = 0
    oldarr = []

    [client, m] = sniff(header, format, verbose, graph);

    []

    while not done:
      try:
        (arr, t, crc) = m.nextline()
        if (arr == False):
          done = 1
          sys.stderr.write("\n** Error ** ") if verbose else ""
          sys.stderr.write(repr(t) + "\n\n") if verbose else ""
        elif arr:
          if crc:
            sys.stderr.write("o") if verbose else ""
            sys.stderr.flush()
            num_bad = num_bad + 1
          else:
            if oldarr:
              dn = ((arr['n'] - n + 32768) % 65536) - 32768
              if dn == 1: 
                sys.stderr.write(".") if verbose else ""
              else:
                sys.stderr.write("!%d!" % (dn - 1)) if verbose else ""
                num_skip = num_skip + dn - 1
              sys.stderr.flush()
            s = repr(m)
            split = s.split(" ")

       
            log(split, client, csvwriter)

            n = arr['n']
            oldarr = arr
            num_good = num_good + 1
        else:
          sys.stderr.write("x") if verbose else ""
          sys.stderr.flush()
          num_bad = num_bad + 1
      except:
        sys.stderr.write(repr(sys.exc_info()))
        sys.stderr.write("\nQuitting... \n")
        done = 1

    end(m)

    
    sys.stderr.write( "%d Successful packets recieved\n" % num_good)
    sys.stderr.write( "%d packet errors\n" % num_bad)
    sys.stderr.write( "%d skipped packets\n" % num_skip)
    if (num_skip + num_good):
      sys.stderr.write( "%4.2f%% packet drop rate\n" % (num_skip * 100.0 / (num_skip + num_good)))

  #curses.endwin()

def sniff(header, format, verbose, graph):
  m = motetalk.motetalk(format, header, "/dev/tty.usbmodem1421", debug=False)
  startup(m)

  sys.stderr.write( "Starting up OSC...\n")         if verbose else ""
  client = OSC.OSCClient()                          if graph else ""
  client.connect( ('127.0.0.1', 8000) )             if graph else "" # note that the argument is a tupple and not two arguments
  sys.stderr.write( "Sniffing...\n")                if verbose else ""
  print "ts " + header


  try:
    (arr, t, crc) = m.nextline()
    (arr, t, crc) = m.nextline()
    (arr, t, crc) = m.nextline()
  except: 
    sys.stderr.write("oops") if verbose else ""
    pass

  return client, m



def main(argv):
  print 'FabSense v 1.0'

  outputfile = ''
  verbose = False
  global graph 
  graph = False
  global sound
  sound = False

  try:
    opts, args = getopt.getopt(argv,"ho:gsv",["ofile=","verbose","graph","sound"])
  except getopt.GetoptError:
    print 'test.py -o <outputfile>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
       print 'test.py -o <outputfile>'
       sys.exit()
    elif opt in ("-o", "--ofile"):
       outputfile = arg
    elif opt in ("-v","--verbose"):
      verbose  = True
    elif opt in ("-g","--graph"):
      graph = True
    elif opt in ("-s","--sound"):
      sound = True

  print 'Output file is "', outputfile
  if verbose :
    print 'Printing Verbose'

  #TODO (Look in data, count # folders, +1, mkdir +1, )
  path = directory + "1" + "/"
  filename = "false.csv"

  pygame.mixer.init()

  read(path + filename, verbose,graph)

if __name__ == "__main__":
  main(sys.argv[1:])
