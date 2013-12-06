'''
The purpose of this file is to simply record small chunks of IMU data to a text file
There is no OSC funtionality. More data is stored in readimu-osc.py and pollimu.py

'''
import time, sys
import lib.motetalk as motetalk
from lib.motetalk import cmd, packetify, setpwm

import OSC
import time, random

def startup(m):
  m.sendbase(cmd.radio(23))
  m.sendbase(cmd.flags(cmd.ledmode_cnt + cmd.notick))
  m.sendheli(cmd.flags(cmd.ledmode_cnt + cmd.tick))
  m.sendheli(cmd.mode(cmd.mode_imu_loop))
  m.sendbase(cmd.mode(cmd.mode_sniff))

def end(m):
  m.sendbase(cmd.mode(cmd.mode_spin))
  m.end()

num_good = 0
num_bad = 0
num_skip = 0

# added for recording purposes
print "Filename format (tool)-(activity)-(repetitions).txt"
tool = raw_input("Enter tool: ")
act  = raw_input("Enter activity: ")
rep  = raw_input("Enter repetitions: ")
trl  = raw_input("Enter trial: ")

f = open(tool + "-" + act + "-" + rep + "-" + trl + "-" + ".txt", "w")
f.write(str("Header: " + tool + " " + act + " " + rep + " " + trl + " ")  + "\n")
f.write(str("timestamp, accX, accY, accZ, gyrX, gyrY, gyrZ, magX, magY, magZ") + "\n")


done = 0
n = 0
oldarr = []

header = "addr len cmd type n sx sy z1 z3 ta lx ly lz ti gx gy gz mx my mz Address"
fmtstr = '! H  b   b   b  H  H  H  H  H  H  H  H  H  H  h  h  h h h h H'

m = motetalk.motetalk(fmtstr, header, "/dev/tty.usbmodem1431", debug=False)
startup(m)

sys.stderr.write( "Sniffing...\n")
print "ts " + header

try:
  (arr, t, crc) = m.nextline()
  (arr, t, crc) = m.nextline()
  (arr, t, crc) = m.nextline()
except: 
  sys.stderr.write("oops")
  pass

while not done:

  try:
    (arr, t, crc) = m.nextline()
    if (arr == False):
      done = 1
      sys.stderr.write("\n** Error ** ")
      sys.stderr.write(repr(t) + "\n\n")
    elif arr:
      if crc:
        sys.stderr.write("o")
        sys.stderr.flush()
        num_bad = num_bad + 1
      else:
        if oldarr:
          dn = ((arr['n'] - n + 32768) % 65536) - 32768
          if dn == 1: 
            sys.stderr.write(".")
          else:
            sys.stderr.write("!%d!" % (dn - 1))
            num_skip = num_skip + dn - 1
          sys.stderr.flush()
        s = repr(m)
        split = s.split(" ")

        #write timestamp to file
        f.write(str(time.time()) + ", ")

        for i in range(6,9):
          msg = float(split[i])/5000.0
          f.write(str(msg) + ", ") 

        for i in range(15,19):
          msg = float(split[i])/5000.0
          f.write(str(msg) + ", ") 
             
        for i in range(18,21):
          msg = float(split[i])/360.0+0.5
          f.write(str(msg) + ", ") 

        f.write("\n")  

        n = arr['n']
        oldarr = arr
        num_good = num_good + 1
    else:
      sys.stderr.write("x")
      sys.stderr.flush()
      num_bad = num_bad + 1
  except:
    sys.stderr.write(repr(sys.exc_info()))
    sys.stderr.write("\nQuitting... \n")
    done = 1

end(m)

f.close()
sys.stderr.write( "%d Successful packets recieved\n" % num_good)
sys.stderr.write( "%d packet errors\n" % num_bad)
sys.stderr.write( "%d skipped packets\n" % num_skip)
if (num_skip + num_good):
  sys.stderr.write( "%4.2f%% packet drop rate\n" % (num_skip * 100.0 / (num_skip + num_good)))


