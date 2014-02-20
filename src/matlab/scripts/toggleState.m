function toggleState(button, eventdata)
button_state = get(button,'Value')
global data
global timestamp
if button_state == get(button,'Max')
	% Toggle button is pressed-take appropriate action
    data(timestamp,13) = 1;
   
elseif button_state == get(button,'Min')
	% Toggle button is not pressed-take appropriate action
    data(timestamp,13) = 2;
        
end