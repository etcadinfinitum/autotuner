function [ts Fs] = tuneSampledTwoChannelsSeparately(ogSignal, samplingRate, windowsize, nfft, waveName, targetPitches)
    Fs = samplingRate;
    ogs1 = ogSignal(:,1);
    ogs2 = ogSignal(:,2);
    ogSignal = ogs1 + ogs2;
    % file stuff
    spectrogram(ogSignal, hanning(windowsize), windowsize/2, nfft, samplingRate, 'yaxis');
    plotTitle = strcat('Spectrogram for Original ', waveName);
    title(plotTitle);
    fn = strcat('test_images/spectrogram_', waveName, '_original.png');     % TODO (make appropriate destination)
    saveas(gcf, fn); 
    % actual pitch correction and istft
    % actual stft using spectrogram part
    [s1 f1 t1] = spectrogram(ogs1, hanning(windowsize), windowsize/2, nfft, samplingRate);
    [s2 f2 t2] = spectrogram(ogs2, hanning(windowsize), windowsize/2, nfft, samplingRate);
    % correction and istft
    sc1 = correctPitchSpectrum(s1, f1, targetPitches);
    sc1 = conj(sc1);
    sc2 = correctPitchSpectrum(s2, f2, targetPitches);
    sc2 = conj(sc2);
    ts1 = depricatedistft(sc1, nfft, windowsize, windowsize/2);
    ts2 = depricatedistft(sc2, nfft, windowsize, windowsize/2);
    % file stuff
    ts = ts1 + ts2;
    spectrogram(ts, hanning(windowsize), windowsize/2, nfft, samplingRate, 'yaxis');
    plotTitle = strcat('Spectrogram for v2 Both Channels Tuned ', waveName);
    title(plotTitle);
    fn = strcat('test_images/v2_spectrogram_', waveName, '_twochannel_tuned.png');     % TODO (make appropriate destination)
    saveas(gcf, fn); 
    fn = strcat('test_audio/v2_', waveName, 'twochannel_tuned.wav');                 % TODO (make appropriate destination)
    audiowrite(fn, ts, Fs);
    % play output
    sound(ts, Fs);
end