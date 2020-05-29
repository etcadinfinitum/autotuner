classdef AutoTuner
    % TODO: comments

    properties (Access = public)
        tuned       % Vector of tuned values
        windowSize  % Size of Fourier Transform window
        overlap     % Size of FFT window overlap
    end     % public properties

    properties (Access = private)
    end     % private properties

    properties (Constant, Access = private)
    end

    methods (Access = public)
        function obj = AutoTuner(sig, targetFreqHz, windowSize)
        % constructor for AutoTuner signal

            if nargin < 2
                error('Not enough parameters were provided. An input signal and target frequency are required.')
            end
            if nargin == 2
                % assume windowSize was not provided; default to length(sig) / 20 or 256, whichever is greater
                obj.windowSize = max(round(length(sig) / 20), 256);
            else
                obj.windowSize = windowSize;
            end

            obj.overlap = 128;

            y = fft(sig);
            
            obj.tuned = ifft(y);

        end

    end     % public methods

    methods (Access = private)

    end     % private methods

end
