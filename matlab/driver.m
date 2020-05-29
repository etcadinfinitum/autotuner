addpath('../sounds');

% BIG TEST ENERGY

[y, Fs] = audioread('../sounds/speech_countdown.aiff');
disp('Playing the file')
% sound(y, Fs)
sound(y(:,1) + y(:,2), Fs)
% Fs is samples per second. To get a 10ms window bin, divide Fs by 100
obj = AutoTuner(y, pitches(5, 10), Fs, round(Fs / 100));
[s, w, t] = obj.getFreqSpectrum();
spectrogramPlot(t, w, s, 'Testing Spectrogram plot of Countdown Speech Sample', 'test_images/countdown_original_spectrogram.png')

[y, Fs] = audioread('../sounds/speech_countdown.aiff');
disp('Playing the file')
% sound(y, Fs)
sound(y(:,1) + y(:,2), Fs)
% Fs is samples per second. To get a 10ms window bin, divide Fs by 100
obj = AutoTuner(y, pitches(5, 10), Fs, round(Fs / 100));
[s, w, t] = obj.getFreqSpectrum();
spectrogramPlot(t, w, s, 'Testing Spectrogram plot of Countdown Speech Sample', 'test_images/countdown_original_spectrogram.png')
