addpath('../sounds');
addpath('utils');

% Read in pitch table from this directory
pitchTable

% performSinglePitchAutoTune('test_sig_Eb5', 'wav', pitches(5, 10), 'test_images/test_sig_Eb5');
% performSinglePitchAutoTune('speech_countdown', 'aiff', pitches(5, 10), 'test_images/countdown');
performSinglePitchAutoTune('eqt-major-sc', 'wav', pitches(5, 10), 'test_images/CMscale');
performSinglePitchAutoTune('overtones_vajrayana', 'aiff', pitches(5, 10), 'test_images/vajrayana');

function performSinglePitchAutoTune(audioFilename, audioFilenameExt, desiredPitch, spectrogramFileNameShort)
    [y, Fs] = audioread(['../sounds/', audioFilename, '.', audioFilenameExt]);
    % TESTING ONLY
    % y = y(1:100000);
    % Fs is samples per second. To get a 10ms window bin, divide Fs by 100
    % Do 5ms to get a 240-width bin
    obj = AutoTuner(y, desiredPitch, Fs, round(Fs / 50));
    [s, f, t] = obj.getFreqSpectrum();
    spectrogramPlot(t, f, s, ['Testing Spectrogram plot of ', audioFilename, ' Sample'], [spectrogramFileNameShort, '_original_spectrogram.png']);

    % The true test
    s = obj.modulateFrequency(s, f);
    spectrogramPlot(t, f, s, ['Spectrogram of Tuned ', audioFilename, ' Sample'], [spectrogramFileNameShort, '_tuned_spectrogram.png']);

    % Get the resulting sound signal
    [yNew, Fs] = obj.convertSpectrumToSignal(s);
    disp(['Playing the file ', audioFilename])
    % sound(y, Fs)
    soundsc(sum(y, 2), Fs)
    pause(4)
    disp('Playing the note to tune to')
    tone = AnalogSignal('sine', 1, desiredPitch, 3);
    audiowrite(['test_audio/tone_', num2str(desiredPitch), 'hz.wav'], samplehold(tone, 1/Fs), Fs);
    [tone, toneFs] = audioread(['test_audio/tone_', num2str(desiredPitch), 'hz.wav']);
    soundsc(sum(tone, 2), toneFs)
    pause(4)
    disp('Playing the tuned sound')
    % size(yNew)
    soundsc(yNew, Fs)
    audiowrite(['test_audio/', audioFilename, '_tuned_', num2str(desiredPitch), '.wav'], rescale(yNew, -1, 1), Fs)
    disp(['Min and max of y: ', num2str(min(y)), ' ', num2str(max(y))])
    disp(['Min and max of tone: ', num2str(min(tone)), ' ', num2str(max(tone))])
    disp(['Min and max of yNew: ', num2str(min(yNew)), ' ', num2str(max(yNew))])
    audiowrite(['test_audio/', audioFilename, '_orig_tone_tuned_', num2str(desiredPitch), '.wav'], [rescale(sum(y, 2), -1, 1); zeros(round(Fs/2), 1); rescale(sum(tone, 2), -1, 1); zeros(round(Fs/2), 1); rescale(sum(yNew, 2), -1, 1)], Fs);
end
