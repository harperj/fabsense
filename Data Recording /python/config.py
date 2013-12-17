
  #header =    "addr len cmd type n sx sy z1 z3 ta mx my mz lx ly lz ti gx gy gz mychk chk lqi rssi"
  #fmtstr = '!  H    b   b   b    H H  H  H  H  H  h  h  h  H  H  H  H  h  h  h  B     H   B   B'
  # header =    "addr len cmd type n mx my mz lx ly lz ti gx gy gz cm ct ca ce cp i0 i1 i2 i3 i4 i5 i6 i7 i8 i9 ia ib ic mychk chk lqi rssi"
  # fmtstr = '!  H    b   b   b    H h  h  h  H  H  H  H  h  h  h  H  H  H  H  H  B  B  B  B  B  B  B  B  B  B  B  B  B  B     H   B   B'
  #header =    "addr len cmd type n sx sy z1 z3 ta mx my mz lx ly lz ti gx gy gz cm ct ca ce cp mychk chk lqi rssi"
  #fmtstr = '!  H    b   b   b    H H  H  H  H  H  h  h  h  H  H  H  H  h  h  h  h  h  h  h  h  B     H   B   B'
  #s = sensitive accelerometer
  #z = filtered z axis of s
  #t = temperature for mag
  #m? = magnetometer
  #l? = large scale accelerometer
  #ti = temp for gyro
  #g? = gyro
  
directory = "../data/"
header = "addr len cmd type n sx sy z1 z3 ta lx ly lz ti gx gy gz mx my mz Address"
format = '! H  b   b   b  H  H  H  H  H  H  H  H  H  H  h  h  h h h h H'

gina = {"accel": {"name":"/acc", "data":{"x": 6, "y": 7, "z": 8}, "scale": 5000.0},"gyro":{"name":"/gyro", "data":{"x": 15, "y": 16, "z": 17}, "scale": 5000.0},"mag":{"name":"/mag", "data":{"x": 18, "y": 19, "z": 20}, "scale" : (360.0+0.5)}}

deriv = [1,0,-1]
