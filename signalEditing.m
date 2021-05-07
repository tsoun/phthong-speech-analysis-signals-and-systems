function [] = signalEditing()
    [x1, rate] = audioread("x1.wav");
    cutOffFrequency = 1500;             % cut off freq for the ideal lowpass
    carrierFrequency = 5000;            % freq of the carrier signal during AM
    
    x2 = firstPart(x1, rate, cutOffFrequency);
    x3 = secondPart(x2, rate, carrierFrequency);
    x4 = thirdPart(x3, rate, carrierFrequency);
    x5 = lastPart(x4, rate, cutOffFrequency);
end

function filteredSignal = lastPart (signal, rate, cut)
    f = (-length(signal)/2 : length(signal)/2 -1)*rate/length(signal);
    fourierSignal = fftshift(fft(signal));
    
    H = 1 - heaviside(f - cut) - heaviside(- f - cut);
    filteredFourierSignal = fftshift(H .* fourierSignal);
    
    figure 
    plotFreq(fftshift(filteredFourierSignal), f, 'Frequency Domain, Demod. & Filtered Audio (Lowpass 1.5 KHz)');
    
    figure
    filteredSignal = 2*ifft(filteredFourierSignal);
    plotTime(filteredSignal, rate, 'Time Domain, Demodulated & Filtered Audio (Lowpass 1.5 KHz)');  
    
    audiowrite('x5.wav', filteredSignal, rate);
end

function demodulatedSignal = thirdPart (signal, rate, carrierFrequency)
    t = linspace(0, length(signal)/rate, length(signal));
    f = (-length(signal)/2 : length(signal)/2 -1)*rate/length(signal);  
    
    cosine = cos(2*pi*carrierFrequency*t);
    demodulatedSignal = signal .* cosine;
    figure
    plotTime(demodulatedSignal, rate, 'Time Domain, Demodulated Signal');
    
    figure 
    plotFreq(fftshift(fft(demodulatedSignal)), f, ' Frequency Domain, Demodulated Signal');
    
    audiowrite('x4.wav', demodulatedSignal, rate);
end

function modSignal = secondPart (signal, rate, carrierFrequency)
    t = linspace(0, length(signal)/rate, length(signal));
    f = (-length(signal)/2 : length(signal)/2 -1)*rate/length(signal);

    cosine = cos(2*pi*carrierFrequency*t);
    modSignal = signal .* cosine;
    figure
    plotTime(modSignal, rate, 'Time Domain, Modulated Signal');
    
    figure 
    plotFreq(fftshift(fft(modSignal)), f, 'Frequency Domain, Modulated Signal');
    
    audiowrite('x3.wav', modSignal, rate);
end

function filteredSignal = firstPart (signal, rate, cut)
    figure
    plotTime(signal, rate, 'Time Domain, Unfiltered Audio');

    figure
    f = (-length(signal)/2 : length(signal)/2 -1)*rate/length(signal);    
    fourierSignal = fftshift(fft(signal));
    plotFreq(fourierSignal, f, 'Frequency Domain, Unfiltered Audio');

    figure
    H = 1 - heaviside(f - cut) - heaviside(- f - cut);
    plotFreq(H, f, 'Rectangular Pulse, Cut-Off Frequency at 1.5 KHz');
    figure
    filteredFourierSignal = H .* fourierSignal';
    plotFreq(filteredFourierSignal, f, 'Frequency Domain, Filtered Audio (Lowpass 1.5 KHz)');
    filteredFourierSignal = fftshift(filteredFourierSignal);
    
    figure
    filteredSignal = ifft(filteredFourierSignal);
    plotTime(filteredSignal, rate, 'Time Domain, Filtered Audio (Lowpass 1.5 KHz)');
    
    audiowrite('x2.wav', filteredSignal, rate);
end

function [] = plotFreq (data, f, ntitle)
    plot(f, abs(data),'color', [0 0 0] + 0.2);
    grid on;
    xlabel('Frequency [Hz]');
    ylabel('Magnitude');
    title(ntitle);
    xlim([-2000, 2000]);
end

function [] = plotTime (data, Fs, ntitle)
    t = linspace(0, length(data)/Fs, length(data));
    plot(t, data, 'color', [0 0 0] + 0.1);
    grid on;
    xlabel('Time [sec]');
    ylabel('Amplitude');
    title(ntitle);
end