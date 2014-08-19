import csv, sys, getopt

def sample_csv(filename, outfilename, _debug = False):
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

                if counter % 15 == 0: #change the numerical value for 1/n sampling
                    outfile.write(line)
                counter = counter + 1
            
            
            
if __name__ == '__main__':
	# change the trial number here
	num = str(73)
	# change the trial name here
	name = num + '-hammer'
	from_str = 'data/'+name+'/'+num+'-data.csv'
	to_str = 'data/'+name+'/'+num+'-sampled.csv'
	sample_csv(from_str,to_str, True)
 