function [] = signalEditing()
    [x1, rate] = audioread("x1.wav");

    x2 = firstPart(x1, rate, 1500);
    x3 = secondPart(x2, rate);
    x4 = thirdPart(x3, rate);
    x5 = lastPart(x4, rate, 1500);
end

function filteredSignal = lastPart (signal, rate, cut)
    f = (-length(signal)/2 : length(signal)/2 -1)*rate/length(signal);
    fourierSignal = fftshift(fft(signal));
    
    H = 1 - heaviside(f - cut) - heaviside(- f - cut);
    filteredFourierSignal = fftshift(H .* fourierSignal);
    
    figure
    filteredSignal = ifft(filteredFourierSignal);
    plotTime(filteredSignal, rate, 'Time Domain, Demodulated & Filtered Audio (Lowpass 1.5 KHz)');  
    
    audiowrite('x5.wav', filteredSignal, rate);
end

function demodulatedSignal = thirdPart (signal, rate)
    t = linspace(0, length(signal)/rate, length(signal));
    
    cosine = cos(2*pi*5000*t);
    demodulatedSignal = signal .* cosine;
    figure
    plotTime(demodulatedSignal, rate, 'Demodulated Signal');
    
    audiowrite('x4.wav', demodulatedSignal, rate);
end

function modSignal = secondPart (signal, rate)
    t = linspace(0, length(signal)/rate, length(signal));

    cosine = cos(2*pi*5000*t);
    modSignal = signal .* cosine;
    figure
    plotTime(modSignal, rate, 'Modulated Signal');
    
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
    filteredFourierSignal = H .* fourierSignal';
    plotFreq(filteredFourierSignal, f, 'Freq Domain, Filtered Audio (Lowpass 1.5 KHz)');
    filteredFourierSignal = fftshift(filteredFourierSignal);
    
    figure
    filteredSignal = ifft(filteredFourierSignal);
    plotTime(filteredSignal, rate, 'Time Domain, Filtered Audio (Lowpass 1.5 KHz)');
    
    audiowrite('x2.wav', filteredSignal, rate);
end

function [] = plotFreq (data, f, ntitle)
    plot(f, abs(data));
    grid on;
    xlabel('Frequency [Hz]');
    ylabel('Magnitude');
    title(ntitle);
end

function [] = plotTime (data, Fs, ntitle)
    t = linspace(0, length(data)/Fs, length(data));
    plot(t, data);
    grid on;
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title(ntitle);
end