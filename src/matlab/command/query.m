function class = query(classifier, dataString, priors)

%{
title:  query function
author: Tim Campbell
date:   9/8/2014

description: 
    this is a previous script (prepareDataResample) that has been
    completely rewritten for online FabSense classification. The function
    is designed to be called from the command line and it either saves the
    data or calls a web server with its output. 

    previous the d structure represented all the data and annotations, in 
    query.m it is just the features data and features, once processed. 

arguments: 
    classifier: a .mat file classifier built from the training dataset
    using the buildClassifier Matlab script

    data: a string containing the data from a window of length 0.6 seconds
    there is an unknown amount of data in each window
    
    priors: is a string of numbers corresponding to the previous N
    classifications
%}

%% setup globals 
% global d;
% d = struct();
% 
% %% parse data string
% d.raw = parseData(dataString);
% 
% %% clean up timestamps
% d.time = fixTiming(d.raw(:,1));
% 
% %% resample the data to a consistent frequency
% resample();
% 
% %% structure the data
% structureWindow();
% 
% %% extract the features
% rmsVarFeature();
% ratiosFeature();
% fftFeature();
% 
% 
%% testing the classifier

%% convolution to smooth the returned label

%% save the data and response

%% sent a GET request to the NODE server with the class

class = randi(6,1);



