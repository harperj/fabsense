import csv

def sample_csv(filename, outfilename):
    with open(filename, 'r') as datafile:
        with open(outfilename, 'w') as outfile:
            outfile.write(datafile.readline())
            
            counter = 0
            for line in datafile:
                if counter % 5 == 0: #change the numerical value for 1/n sampling
                    outfile.write(line)
                counter = counter + 1
            
            
            
if __name__ == '__main__':
	# change the trial number here
	num = str(69)
	# change the trial name here
	name = num + '-hammer'
	from_str = 'data/'+name+'/'+num+'-data.csv'
	to_str = 'data/'+name+'/'+num+'-sampled.csv'
	sample_csv(from_str,to_str)
