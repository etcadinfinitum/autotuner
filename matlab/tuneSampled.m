function [ts Fs] = tuneSampled(ogSignal, samplingRate, windowsize, nfft, waveName, targetPitches)
    Fs = samplingRate;
    % actual stft using spectrogram part
    [s f t] = spectrogram(ogSignal, hanning(windowsize), windowsize/2, nfft, samplingRate);
    % file stuff
    spectrogram(ogSignal, hanning(windowsize), windowsize/2, nfft, samplingRate, 'yaxis');
    plotTitle = strcat('Spectrogram for Original ', waveName);
    title(plotTitle);
    fn = strcat('test_images/spectrogram_', waveName, '_original.png');     % TODO (make appropriate destination)
    saveas(gcf, fn); 
    % actual pitch correction and istft
    sc = correctPitchSpectrum(s, f, targetPitches);
    sc = conj(sc);
    ts = depricatedistft(sc, nfft, windowsize, windowsize/2);
    % file stuff
    [s f t] = spectrogram(ts, hanning(windowsize), windowsize/2, nfft, samplingRate);
    spectrogram(ts, hanning(windowsize), windowsize/2, nfft, samplingRate, 'yaxis');
    plotTitle = strcat('Spectrogram for v2 Tuned ', waveName);
    title(plotTitle);
    fn = strcat('test_images/v2_spectrogram_', waveName, '_tuned.png');     % TODO (make appropriate destination)
    saveas(gcf, fn); 
    fn = strcat('test_audio/v2_', waveName, '_tuned.wav');                 % TODO (make appropriate destination)
    audiowrite(fn, ts, Fs);
    % play output
    sound(ts, Fs);
end
