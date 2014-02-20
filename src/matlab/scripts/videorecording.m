%% Determine Camera info
camera = imaqhwinfo('macvideo'); %using built-in webcam
imaqhelp videoinput
vid = videoinput('macvideo',1);
preview(vid);

%% 
%vid = videoinput('macvideo',1);
vidObj = VideoWriter('output.avi');
open(vidObj);
while true;
    writeVideo(vidObj,im2frame(getsnapshot(vid)));
end

close(vidObj);



%% from mathworks website

vidobj = videoinput('macvideo',1);
set(vidobj,'FramesPerTrigger',inf)
logfile = VideoWriter('output.avi);

%%
start(vidobj)
%%
numAvail = vidobj.FramesAvailable
%%
stop(vidobj)



