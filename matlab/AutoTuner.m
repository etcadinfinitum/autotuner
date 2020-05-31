classdef AutoTuner
    % TODO: comments

    properties (Access = public)
        originalSig % Input signal vector
        tuned       % Vector of tuned values
        windowSize  % Size of Fourier Transform window
        overlap     % Size of FFT window overlap
        originalSpecgram    % The spectrogram of the input signal
        win             % The shape of the sampling window (a vector value, hamming window UFN)
    end     % public properties

    properties (Access = private)
        targetFreq      % Frequency to tune to in Hz
        sampledAtFreq   % Sampling frequency of input signal
        
    end     % private properties

    properties (Constant, Access = private)
        fftLength = 256;
    end

    methods (Access = public)
        function obj = AutoTuner(sig, targetFreqHz, samplingFreqHz, windowSize)
        % constructor for AutoTuner signal

            if nargin < 2
                error('Not enough parameters were provided. An input signal and target frequency are required.')
            end

            if nargin < 3
                % assume windowSize was not provided; default to length(sig) / 20 or 256, whichever is greater
                obj.windowSize = max(round(length(sig) / 20), 256);
            else
                obj.windowSize = windowSize;
            end

            obj.originalSig = sum(sig, 2);

            obj.overlap = obj.windowSize / 2;

            obj.targetFreq = targetFreqHz;
            obj.sampledAtFreq = samplingFreqHz;

            obj.win = hamming(obj.windowSize);
        end

        function [s, f, t] = getFreqSpectrum(obj)
            [s, f, t] = stft(obj.originalSig, obj.sampledAtFreq, 'Window', obj.win, 'OverlapLength', obj.overlap, 'FFTLength', obj.fftLength);
            % spectrogram(obj.originalSig, obj.windowSize, obj.overlap);
        end

        % function modulateFrequency

        function [y, Fs] = convertSpectrumToSignal(obj, s)
            [s f t] = obj.getFreqSpectrum();
            
        end
        
        function AutoTuneToSelf(obj) 
            magspec = magnitudeSpectrum(obj.originalSig);
            hps = harmonicProductSpectrum(magspec);
            [s freqSpace] = stft(obj.originalSig);
            
            buckets = length(s(1,:));
            s_length = length(s(:,1));
            
            for idx = 1:buckets
               maxAmplitudes(idx) = max(hps(:,idx));
               pitchLocations = find(hps(:,idx) == maxAmplitudes(idx),idx,'first');
               pitchVector = freqSpace(pitchLocations(idx));
               adjustedPitchVector(idx) = correctPitchIdentification(pitchVector(idx), pitchTable);
               temp = adjustedPitchVector(idx)/pitchVector(idx);
               for idx2 = 1:s_length
                   det = round(idx2/temp);
                   if det <= 0
                       det = 1;
                   end
                   if det <= s_length
                       obj.tuned(idx, idx2) = s((hps),idx);
                   end
               end
            end
            
        end

    end     % public methods

    methods (Access = private)
        
        function magspec = magnitudeSpectrum(digital_signal)
           nfft = 2^nextpow2(length(digital_signal));
           magspec = fft(digital_signal, nfft);
           w = magspec/length(digital_signal);
           magspec = abs(w(1:floor(nfft/2 + 1)));
           magspec = 20*log10(magspec/min(magspec(:)));
        end

        function hps = harmonicProductSpectrum(magspec)
           % now can find hps (I hope)
           d = magspec(1:2:length(magspec));
           p = zeros((length(magspec) - length(d)),1);
           d = [d; p];
           hps = magspec.*d;
           for idx = 1:length(hps)
               hps(idx) = hps(idx)^(0.5);
           end
        end
        
    end     % private methods

end
