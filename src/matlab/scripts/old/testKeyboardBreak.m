function testKeyboardBreak(data)
    a = 0;
    while a < 100
        while ~waitforbuttonpress;
            pause('on');

        end
        a = a + 1;
        disp(data(a,1));

    end  

end