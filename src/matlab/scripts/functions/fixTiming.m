%% supposed to fix the timing issues

function t = fixTiming(t)
for i  = 1:(length(t))
    check = t(i,1);
    count = 0;
    
    while (check == t(i,1)) && ((i+count) <= numel(t))
%          if (i+count) > numel(t)
%              disp('successfully broke the while loop')
%             break
%          else
%              count = count +1;
%          end
        count = count +1;
        if (i+count) < numel(t)
            check = t(i+count,1);
        end
    end
    
    for j = 2:count
        t(i+j-1,1) = t(i,1) + ((j-1)/count)/100;
    end
    
    
end


