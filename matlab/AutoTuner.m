classdef AutoTuner
    % TODO: comments

    properties (Access = public)
        originalSig % Input signal vector
        tuned       % Vector of tuned values
        windowSize  % Size of Fourier Transform window
        overlap     % Size of FFT window overlap
        originalSpecgram    % The spectrogram of the input signal
    end     % public properties

    properties (Access = private)
        targetFreq      % Frequency to tune to in Hz
        sampledAtFreq   % Sampling frequency of input signal
    end     % private properties

    properties (Constant, Access = private)
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

            obj.overlap = min(128, obj.windowSize/2);

            obj.targetFreq = targetFreqHz;
            obj.sampledAtFreq = samplingFreqHz;

        end

        function [s, w, t] = getFreqSpectrum(obj)
            [s, w, t] = spectrogram(obj.originalSig, obj.windowSize, obj.overlap);
            obj.originalSpecgram = s;
        end

        % function modulateFrequency

    end     % public methods

    methods (Access = private)

    end     % private methods

end