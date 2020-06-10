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
        fftLength = 1024;
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

            obj.overlap = round(obj.windowSize / 2);

            obj.targetFreq = targetFreqHz;
            obj.sampledAtFreq = samplingFreqHz;

            obj.win = hamming(obj.windowSize);
        end

        function [s, f, t] = getFreqSpectrum(obj)
            [s, f, t] = stft(obj.originalSig, obj.sampledAtFreq, 'Window', obj.win, 'OverlapLength', obj.overlap, 'FFTLength', obj.fftLength);
            % spectrogram(obj.originalSig, obj.windowSize, obj.overlap);
        end

        % Lizzy's attempt at autotuning full frequency STFT to a single 
        % pitch.
        function s = modulateFrequency(obj, originalSpectrum, origFreqRange)
            size(originalSpectrum); % debug
            % naive approach:
            %   0. take bottom half of rows (positive frequencies only, do the same for origFreqRange
            posiSpectrum = originalSpectrum(size(originalSpectrum, 1)/2 + 1:end,:);
            % size(posiSpectrum)
            % disp(['Positive freq spectrum size: ', num2str(size(posiSpectrum))])
            posiMagnitudes = abs(posiSpectrum);
            %   0. find index of target frequency obj.targetFreq in origFreqRange
            [targetFreqActual, targetIdx] = min(abs(origFreqRange - obj.targetFreq));
            targetIdx = targetIdx - (length(origFreqRange) / 2);
            % disp(['Tuning to frequency (closest match in freq spectrum): ', num2str(origFreqRange(targetIdx + length(origFreqRange) / 2))])
            for i=[1:size(posiSpectrum, 2)]
                %   1. take top 5(ish?) percent of magnitudes in each column
                %       - consider also just taking largest single magnitude...
                [freq, idx] = max(posiMagnitudes(:,i));
                %   2. find required offset to center spike over target frequency
                offset = targetIdx - idx;
                %   3. offset spectrum column by index difference
                col = posiSpectrum(:,i);
                % disp(['Column size: ', num2str(size(col))])
                size(posiSpectrum); % debug
                if offset < 0
                    % target freq is much lower
                    size(zeros(-offset - 1, 1));    % debug
                    size(col(-offset:end));     % debug
                    posiSpectrum(:,i) = [col(-offset:end); zeros(-offset - 1, 1)];
                else
                    % target freq is higher than mag spike location
                    posiSpectrum(:,i) = [zeros(offset, 1); col(1:length(col) - offset)];
                end
            end
            %   4. after all columns have been processed, create copy of processed matrix which has all columns inverted (mirrored copy of altered positive frequencies)
            negSpectrum = flip(posiSpectrum, 1);
            %   5. concatenate two matrices and return
            s = [negSpectrum; posiSpectrum];
            
        end

        function [y, Fs] = convertSpectrumToSignal(obj, s)
            y = real(istft(s, obj.sampledAtFreq, 'Window', obj.win, 'OverlapLength', obj.overlap, 'FFTLength', obj.fftLength));
            Fs = obj.sampledAtFreq;
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
        
        function correctedPitch = correctedPitchIdentification(ogPitch, pitchTable)
           % assumes pitches is sorted in ascending order
           if ogPitch < pitchTable(1)
               correctedPitch = pitchTable(1);
           elseif ogPitch > pitchTable(length(pitchTable))
               correctedPitch = pitchTable(length(pitchTable));
           else
               % unfortunate decision to linear search, but I'm okay w/ it
               curdiff = (pitchTable(length(pitchTable)) - pitchTable(1));
               correctedPitch = pitchTable(1);
               for idx = 2:(length(pitchTable)-1)
                   newdiff = abs(ogPitch - pitchTable(idx));
                   if newdiff < curdiff
                      curdiff = newdiff;
                      correctedPitch = pitchTable(idx);
                   end
               end
           end
           
        end
        
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
