addpath('../sounds');

% BIG TEST ENERGY

[y, Fs] = audioread('../sounds/speech_countdown.aiff');
% Fs is samples per second. To get a 10ms window bin, divide Fs by 100
% Do 5ms to get a 240-width bin
obj = AutoTuner(y, pitches(5, 10), Fs, round(Fs / 200));
[s, f, t] = obj.getFreqSpectrum();
spectrogramPlot(t, f, s, 'Testing Spectrogram plot of Countdown Speech Sample', 'test_images/countdown_original_spectrogram.png');
[yNew, Fs] = obj.convertSpectrumToSignal(s);
disp('Playing the file countdown')
% sound(y, Fs)
sound(y(:,1) + y(:,2), Fs)
pause(12)
size(yNew)
sound(yNew, Fs)

[y, Fs] = audioread('../sounds/speech_powerwords.wav');
disp('Playing the file powerwords')
% Fs is samples per second. To get a 10ms window bin, divide Fs by 100
obj = AutoTuner(y, pitches(5, 10), Fs, round(Fs / 200));
[s, w, t] = obj.getFreqSpectrum();
spectrogramPlot(t, w, s, 'Testing Spectrogram plot of Power Words Speech Sample', 'test_images/powerwords_original_spectrogram.png');
[yNew, Fs] = obj.convertSpectrumToSignal(s);
disp('Playing the file powerwords')
% sound(y, Fs)
sound(y(:,1) + y(:,2), Fs)
pause(25)
size(yNew)
sound(yNew, Fs)
