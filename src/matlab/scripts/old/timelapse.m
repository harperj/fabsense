% When executing the following code, you may need to
% modify it to match your acquisition hardware.
imaqhwinfo

vid = videoinput('macvideo',1);


%% determine frame rate
set(vid,'FramesPerTrigger',100);
start(vid);
wait(vid,Inf);

% Retrieve the frames and timestamps for each frame.
numframes = get(vid,'FramesAvailable');
[frames,time] = getdata(vid,numframes);

% Calculate the frame rate by taking  the average difference
% between the timestamps for each frame.
framerate = mean(1./diff(time))

%%
% We want to compress 30 seconds into 3 seconds, so
% only acquire every tenth frame.
set(vid,'FrameGrabInterval',10);

%% determine number of frames to aquire
capturetime = 30;
interval = get(vid,'FrameGrabInterval');
numframes = floor(capturetime * framerate / interval)

set(vid,'FramesPerTrigger', numframes);

%% configure AVI disk logging
set(vid,'LoggingMode','disk');

avi = avifile('timelapsevideo','fps',framerate);
%set(vid,'DiskLogger',avi);
vid

vwObj = VideoWriter('timelapsevideo','Uncompressed AVI');
vwObj.FrameRate = framerate;
set(vid,'DiskLogger',vwObj);
vid


%% running the time lapse
start(vid);

% Wait for the capture to complete before continuing.
wait(vid,Inf);

vwObj = get(vid,'DiskLogger');
close(vwObj);