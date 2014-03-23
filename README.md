fabsense
========
Notes on ideal matlab pipeline: These notes are to help me understand the process a file should go through after the data has bee collected. 
1. data recorded and stored into text file
2. import to matlab format (structure? array?)
3. create rms signal, smooth and bin the rms
4. import an annotations text file
5. create a list of annotated segments
6. play back the file with annotations, rms
7. Dynamic Time Warping:
	a. import canonical examples
	b. 



Old Notes (no longer relevant):
The drawRealTime files are an attempt to visualize scrolling data. They don't actually work in realtime since I re-draw each frame. to use the drawRealTime, you are prompted for a file which is just a saved .mat file in the same directory. I have been using hammer1 and hammer2 recently. 

to build the machine learning, I have been stashing the many junky snippets of code into binRMS.m. This file bins the RMS signal with a moving average, builds the training examples, builds the classifier and then tests it. Somewhere I have code to build a confusion matrix. 