import pandas
import numpy
import datetime
import rpy2.robjects.numpy2ri
import sys
from rpy2.robjects.packages import importr
import matplotlib.pyplot as plt

def load_imu_csv(filename):
    recording = pandas.read_csv(filename, index_col=False)
    recording['timestamp'] = pandas.to_datetime(recording['timestamp'],unit='s')
    recording.set_index('timestamp', inplace=True)    
    return recording

def extract_feature(time1, time2, table):
    range_val = table.between_time(datetime.datetime.utcfromtimestamp(time1),datetime.datetime.utcfromtimestamp(time2))
    return range_val

def dtw_run(recording, example, window_size_min, window_size_max, step=None):
    rpy2.robjects.numpy2ri.activate()
    R = rpy2.robjects.r
    DTW = importr('dtw')

    scores = [None]*len(recording)
    # for each position in the recording
    for i in xrange(len(recording)):
        best_score = sys.maxint
        # for each window size
        for window_size in xrange(window_size_min, window_size_max):
            # find the DTW match score, and keep if better than previous scores
            alignment = R.dtw(example[['accX','accY','accZ', 'gyrX','gyrY','gyrZ']].values,recording[['accX','accY','accZ','gyrX','gyrY','gyrZ']][i:i+window_size].values, keep=True)
            score = alignment.rx('distance')[0][0]
            if score < best_score:
                scores[i] = [score, window_size]
    return scores


# def old_dtw(): 
#     best_dist = sys.maxint
#     best_ind = 0
#     high_matches = []
#     best_align = None
#     i = 0
#     while i < len(recording):
#         alignment = R.dtw(example[['gyrX','gyrY','gyrZ']].values, recording[['gyrX','gyrY','gyrZ']][i:i+80].values, keep=True)
#         dist = alignment.rx('distance')[0][0]
#         if dist < 13.0:
#             end_val = i+80
#             local_min = dist
#             local_min_ind = i
#             local_min_align = None
            
#             while i < end_val:
#                 i = i + 1
#                 alignment = R.dtw(example[['gyrX','gyrY','gyrZ']].values, recording[['gyrX','gyrY','gyrZ']][i:i+80].values, keep=True)
#                 dist = alignment.rx('distance')[0][0]
#                 if dist < best_dist:
#                     best_dist = dist
#                     best_ind = i
#                     best_align = alignment
#                 if dist < local_min:
#                     local_min = dist
#                     local_min_ind = i
#                     local_min_align = alignment
#             high_matches.append([local_min, local_min_ind, local_min_align])
#         i = i + 1


if __name__ == '__main__':
    recording = load_imu_csv("testVideo-7.csv")
    feature = extract_feature(1386186027.470,1386186028.165,recording)
    scores = dtw_run(recording, feature, 65, 90)
    for i in xrange(len(scores)):
        scores[i] = scores[i][0]
    plt.plot(recording.index.values,scores)
    print scores
