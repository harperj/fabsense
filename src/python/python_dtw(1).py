# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

%pylab inline

# <codecell>

import pandas
import numpy
import datetime
import rpy2.robjects.numpy2ri
rpy2.robjects.numpy2ri.activate()
from rpy2.robjects.packages import importr
R = rpy2.robjects.r
DTW = importr('dtw')

# <codecell>

recording = pandas.read_csv("testVideo-7.csv", index_col=False)

# <codecell>

recording

# <codecell>

recording['timestamp'] = pandas.to_datetime(recording['timestamp'],unit='s')
recording.set_index('timestamp', inplace=True)

# <codecell>

recording

# <codecell>

recording[['accX','accY','accZ']].plot()

# <codecell>

hammer_dates = [numpy.datetime64(1386186027470, 'ms'), numpy.datetime64(1386186028165, 'ms')]
datetime.datetime.utcfromtimestamp(1386186027.470)

# <codecell>

hammering = recording.between_time(datetime.datetime.utcfromtimestamp(1386186027.470),datetime.datetime.utcfromtimestamp(1386186028.165))
hammering[['gyrX','gyrY','gyrZ']].plot()

# <codecell>

recording[0:20]

# <codecell>

alignment = R.dtw(hammering['gyrY'].values, recording['gyrY'][0:80].values, keep=True)
alignment.rx('distance')[0][0]

# <codecell>

#testing DTW using R and simple windowing
best_dist = 10000
best_ind = 0
high_matches = []
best_align = None
i = 0
while i < len(recording):
    alignment = R.dtw(hammering[['gyrX','gyrY','gyrZ']].values, recording[['gyrX','gyrY','gyrZ']][i:i+80].values, keep=True)
    dist = alignment.rx('distance')[0][0]
    if dist < 13.0:
        end_val = i+80
        local_min = dist
        local_min_ind = i
        local_min_align = None
        
        while i < end_val:
            i = i + 1
            alignment = R.dtw(hammering[['gyrX','gyrY','gyrZ']].values, recording[['gyrX','gyrY','gyrZ']][i:i+80].values, keep=True)
            dist = alignment.rx('distance')[0][0]
            if dist < best_dist:
                best_dist = dist
                best_ind = i
                best_align = alignment
            if dist < local_min:
                local_min = dist
                local_min_ind = i
                local_min_align = alignment
        high_matches.append([local_min, local_min_ind, local_min_align])
    i = i + 1

# <codecell>

match_inds = []
for n in range(len(high_matches)):
    match_inds.append(high_matches[n][1])
for ind in match_inds:
    print str(recording.index[ind].value) + "," + str(recording.index[ind+80].value)

# <codecell>

high_matches[0][0]

# <codecell>

fig, axes = plt.subplots(nrows=9)
for i in range(8):
    recording[['gyrX','gyrY','gyrZ']][high_matches[i][1]:high_matches[i][1]+80].plot(ax=axes[i], legend=False)
hammering[['gyrX','gyrY','gyrZ']].plot(ax=axes[8], legend=False)

# <codecell>

hammering[['accX','accY','accZ']].plot()

# <codecell>

#R.plot(high_matches[0][2],type="twoway");

# <codecell>


# <codecell>


# <codecell>


