import csv, sys, getopt

def sample_csv(filename, outfilename, subsample, _debug = False):
    with open(filename, 'rU') as datafile:
        with open(outfilename, 'w') as outfile:
            # HEADER
            outfile.write(datafile.readline())
            
            # DATA
            counter = 0
            badline = 0
            for line in datafile: 
                line = line.strip()
                # x = 10 if a > b else 11
                if len(line) == 0:
                    continue
                else:
                    line = line + '\n'
            
                if _debug:
                    if not line:
                        badline = badline +1
                        print 'Blank line: ', str(badline)
                    elif line is '\n':
                        badline = badline +1
                        print 'New Line: ', str(badline)
                    elif line is '\r':
                        badline = badline +1
                        print 'Return Line: ', str(badline)

                if counter % subsample == 0: #change the numerical value for 1/n sampling
                    outfile.write(line)
                counter = counter + 1
            
            
            
# if __name__ == '__main__':
# 	# change the trial number here
# 	num = str(73)
# 	# change the trial name here
# 	name = num + '-hammer'
# 	from_str = 'data/'+name+'/'+num+'-data.csv'
# 	to_str = 'data/'+name+'/'+num+'-sampled.csv'
# 	sample_csv(from_str,to_str, True)

def main(argv):
  print 'FabSense Sub-Sampling script'

  outputfile = ''
  subsample = 10;

  #takes the subsample and filename as inputs.   

  try:
    opts, args = getopt.getopt(argv,"ht:n:",["trial=","subsample="])
  except getopt.GetoptError:
    print '-t <trial#>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
       print 'sample_csv.py -t <##-tool>  -n <subsample num>'
       sys.exit()
    elif opt in ("-t", "--trial"):
       outputfile = str(arg) 
    elif opt in ("-n","--verbose"):
      subsample  = int(arg)

  print 'Trial Number is:', outputfile
  print 'Subsampling by a factor of: ', subsample



  if len(outputfile) is not 0:
    #split the input string
    #trial,name = outputfile.split('-')

    filename = 'data/temporary-data/'+ outputfile +'-data.csv'
    outfilename = 'data/temporary-data/'+ outputfile +'-sampled.csv'

    #function call
    sample_csv(filename,outfilename, subsample)

  #TODO (Look in data, count # folders, +1, mkdir +1, )

if __name__ == "__main__":
  main(sys.argv[1:])
 