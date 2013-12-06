
%% practice toggle button
clc

h = figure(1);
button = uicontrol('Style','togglebutton', 'Position', ...
    [20,20,100,20],'String','Start-Stop Rec',...
    'Callback', @toggleState);




