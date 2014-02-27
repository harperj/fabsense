import csv

def sample_csv(filename, outfilename):
    with open(filename, 'r') as datafile:
        with open(outfilename, 'w') as outfile:
            outfile.write(datafile.readline())
            
            counter = 0
            for line in datafile:
                if counter % 15 == 0: #change the numerical value for 1/n sampling
                    outfile.write(line)
                counter = counter + 1
            
            
            
if __name__ == '__main__':
    sample_csv('data/7-hammer/7-data.csv', 'data/7-hammer/7-sampled.csv')
