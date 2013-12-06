 %%
 % example from: http://www.mathworks.com/matlabcentral/answers/42241
t = 1:168;
 x = cos((2*pi)/12*t)+randn(size(t));
 % if you have the signal processing toolbox
 [Pxx,F] = periodogram(x,rectwin(length(x)),length(x),1);
 plot(F,10*log10(Pxx)); xlabel('Cycles/hour');
 ylabel('dB/(Cycles/hour');
 % if not
%  xdft = 1/168*fft(x);
%  xper = abs(xdft(1:length(x)/2+1)).^2;
%  df = 1/168;
%  freq = 0:df:1/2;
%  plot(freq,10*log10(xper))
%  xlabel('Cycles/hour');
%  ylabel('dB/Cycles/hour');

%%
% example from http://www.mathworks.com/matlabcentral/answers/42241
 t = 0:.001:.25;
 Fs = 1000;
 x = sin(2*pi*50*t) + sin(2*pi*120*t);
 y = x + 2*randn(size(t));
 Y = fft(y,251);
 Y = Y(1:floor(251/2)+1);
 Y = 1/(251*Fs)*(Y.*conj(Y));
 df = 1000/251;
 freq = 0:df:500;
 plot(freq,Y);
 
 %% 
 
 % my code for analyzing chunks of data, it doesn't work...
 clf 
 
 start = 1000;
 stop  = 1400;
 duration = data(stop,1)-data(start,1);
 inc = duration/(stop-start);
 
 t = 0:inc:duration;
 %t = data(start:stop,1);
 Fs = 10;
 %x = sin(2*pi*50*t) + sin(2*pi*120*t);
 y = data(start:stop,2);
 y = y - rms(y);
 Y = fft(y,251);
 Y = Y(1:floor(251/2)+1);
 Y = 1/(251*Fs)*(Y.*conj(Y));
 Y = Y(2:end);
 df = Fs/251;
 freq = 0:df:Fs/2;
 freq = freq(2:end);
 subplot(2,1,1);
 plot(freq,Y);
 
subplot(2,1,2);
 plot(t,y);
 
 %%
 % example from: 
 %http://www.mathworks.com/help/matlab/examples/fft-for-spectral-analysis.html
clf
 
t = 0:.001:.25;
steps = length(t);
x = sin(2*pi*50*t) + sin(2*pi*120*t);
y = x + 2*randn(size(t));
subplot(3,1,1);
%plot(y(1:50))
plot(t,y)
title('Noisy time domain signal')

Y   = fft(y,steps);          %where 251 is the length of t
Pyy = Y.*conj(Y)/steps;    %creates power spectral density
sym = ceil(steps/2);
f   = 1000/steps*(0:(sym+1));    %creates the frequency bins

%plot total range
subplot(3,1,2);
plot(f,Pyy(1:(sym+2)))
title('Power spectral density')
xlabel('Frequency (Hz)')

%plot zoom range
subplot(3,1,3);
plot(f(1:50),Pyy(1:50))
title('Power spectral density')
xlabel('Frequency (Hz)')

%% 

%trying to get my windows to work on the fft example:
clf

start = 1000;
stop  = 1900;
fMax  = 1000;

%build time & data vectors
duration = data(stop,1)-data(start,1);
inc = duration/(stop-start);
t = 0:inc:duration;
steps = length(t);
y = data(start:stop,2);
y = y - rms(y);

subplot(3,1,1);
plot(t,y)
title('Noisy time domain signal')

Y   = fft(y,steps);              
Pyy = Y.*conj(Y)/steps;          %creates power spectral density
sym = ceil(steps/2);
f   = fMax/steps*(0:(sym+1));    %creates the frequency bins

%plot total range
subplot(3,1,2);
plot(f,Pyy(1:(sym+2)))
title('Power spectral density')
xlabel('Frequency (Hz)')

%plot zoom range
subplot(3,1,3);
plot(f(1:50),Pyy(1:50))
title('Power spectral density')
xlabel('Frequency (Hz)')





 