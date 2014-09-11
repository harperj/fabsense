%% ahh!! here comes FFT

%the fft features are one sum for each sensor
fftadd = zeros(length(d.windows),fftbins*3);

for i = 1:length(d.windows)
    
    %loop over sensors
    for j = 1:numel(sen)
        %loop over axes
        for k = 1:3;
            
            temp = d.windows{i}.(sen{j})(k,:);
            T = winSize;
            NFFT = fftbins*2;
            fs = NFFT/T;
            df = fs/NFFT;
            %fAxis = 0:df:(fs-df);
            F = abs(fft(temp,NFFT));
            F = F(1:floor(end/2));
            
            %adds the ffts in each axis to their sensor, then in each sensor
            %has its own section
            fftadd(i,(1+(j-1)*fftbins):j*fftbins) = ...
                fftadd(i,(1+(j-1)*fftbins):j*fftbins) + F;
        end
    end
end

d.features = [d.features,fftadd];