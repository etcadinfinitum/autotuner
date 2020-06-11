function correctedSpectrum = correctPitchSpectrum(s, f, targetPitches)
    % s - short-time spectrum
    % f - TODO
    % y - TODO
    % return correctedSpectrum - a vector of the corrected short-time spectrum values
    absS = abs(s);
    y = 20*log10(absS/min(absS(:)));
    % need number of buckets
    numBuckets = length(s(1,:));
    % pre-allocation of return array as Matlab's "intellisense" whinges about it
    correctedSpectrum = zeros(length(s(:,1)),numBuckets);

    for bucket = 1:numBuckets
        % 1) Identify fundamental frequency for each bucket using frequency that corresponds to max amplitude
        selectedPitch = f(find((y(:,bucket) == max(y(:,bucket))),bucket,'first'));
        % 2) individual pitch correction by finding closest value in target table
        [d, idx] = min(abs(targetPitches - selectedPitch));
        correctedpitch = targetPitches(idx);
        % 3) perform pitch shift 
        shiftFactor = correctedpitch/selectedPitch;
        for idx = 1:length(s(:,1))
            shiftval = round(idx/shiftFactor);
            if shiftval <= length(s(:,1))
                if shiftval <= 0 % No negative out of bounds indexing
                    shiftval = 1;
                end
                correctedSpectrum(idx,bucket) = s(shiftval,bucket);
            end
        end
    end
end
