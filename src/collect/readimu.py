#/usr/bin/python
from config import *
import time, sys, getopt, csv
import lib.motetalk as motetalk
from lib.motetalk import cmd, packetify, setpwm
from array import array
from collections import deque
import OSC, random,curses
import numpy as np

global last

length = 20
temp   = [0] * (length)
last = float(0)
#window   = collections.deque(maxlen = 9)

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
    
    def get(self):
        return self.windows
                

def log(data, client, csvwriter):
  row = []
  i = 0; j = 0; tempData = 0.;
  row.append(str(time.time()))
  for sensor, setting in gina.iteritems():
    for axis, index in setting["data"].iteritems():
        msg = OSC.OSCMessage()
        msg.setAddress(setting["name"] + "/" + axis)
        tempData = float(data[index]) / setting["scale"]
        msg.append(tempData)
        client.send(msg)
        row.append(tempData)
        windowsAdd(tempData)
    #     print i+j
    #     j += 1
    # j = 0
    # i += 1

  #pseudocode: makeWindow(transpose(row(1:)))
  csvwriter.writerow(row)

def windowsAdd(tempData):
  #pseudocode for i in windows: windows[i].append(row[i])
  #averageing kernel: [.2, .2, .2, .2, .2]
  #derivative kernal
  #pseudocode 
  windows[position].append(tempData)

  #window[position][index] = tempData




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
  # print "You've made it this far: " + str(temp)
  return sum(temp)/float(length)

def getSlope(num):
  global last 
  if (num >= last):
    last = num
    return 1;
  else:
    last = num;
    return 0;

def read(filename, verbose):
  num_good = 0
  num_bad = 0
  num_skip = 0

  print filename

  with open(filename, 'w') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter= " ")
    csvwriter.writerow(["timestamp", "accX", "accY", "accZ", "gyrX", "gyrY", "gyrZ", "magX", "magY", "magZ"])


  # # BREAK CLEANLY
  #   # stdscr = curses.initscr()
  #   # curses.cbreak()
  #   # stdscr.keypad(1)
  #   # key = ''
  
    done = 0
    n = 0
    oldarr = []

    [client, m] = sniff(header, format, verbose);

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

def sniff(header, format, verbose):
  m = motetalk.motetalk(format, header, "/dev/tty.usbmodem1431", debug=False)
  startup(m)

  sys.stderr.write( "Starting up OSC...\n") if verbose else ""
  client = OSC.OSCClient()
  client.connect( ('127.0.0.1', 8000) ) # note that the argument is a tupple and not two arguments
  sys.stderr.write( "Sniffing...\n") if verbose else ""
  print "ts " + header


  try:
    (arr, t, crc) = m.nextline()
    (arr, t, crc) = m.nextline()
    (arr, t, crc) = m.nextline()
  except: 
    sys.stderr.write("oops") if verbose else ""
    pass

  return client, m
if __name__ == "__main__":
  main(sys.argv[1:])



def main(argv):
  print 'FabSense v 1.0'

  outputfile = ''
  verbose = False
  graph = False
  try:
    opts, args = getopt.getopt(argv,"ho:v",["ofile=","verbose=","graph="])
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

  print 'Output file is "', outputfile
  if verbose :
    print 'Printing Verbose'

  #TODO (Look in data, count # folders, +1, mkdir +1, )
  path = directory + "1" + "/"
  filename = "data.csv"

  read(path + filename, verbose)
