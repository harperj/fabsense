fabsense
========

Notes on matlab files: 
The drawRealTime files are an attempt to visualize scrolling data. They don't actually work in realtime since I re-draw each frame. to use the drawRealTime, you are prompted for a file which is just a saved .mat file in the same directory. I have been using hammer1 and hammer2 recently. 

to build the machine learning, I have been stashing the many junky snippets of code into binRMS.m. This file bins the RMS signal with a moving average, builds the training examples, builds the classifier and then tests it. Somewhere I have code to build a confusion matrix. 

