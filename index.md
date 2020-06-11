---
layout: default
---

# Autotuning Signals in Matlab

A project by [Lizzy Presland](https://linkedin.com/in/etcadinfinitum), 
[Bo Simmons](https://www.linkedin.com/in/bowman-simmons/), and 
Jayden Fullerton.

## General advice from Stiber (TODO remove this)

Cutting across these topics, your report should make it clear what you learned, relating to both the course material and any unexpected problems or issues that gave you new insight.

## Summary

In this project, we work to create a utility which processes an audio 
file (for example, human speech or synthesized musical notes) and 
and produces an audio which has its pitch corrected to a desired 
frequency in the Western chromatic scale.

## Background

In the music industry, the process of pitch correction, informally known 
as autotuning, is a common practice. Its musical merits are [in constant 
dispute](https://ocw.mit.edu/courses/music-and-theater-arts/21m-380-music-and-technology-contemporary-history-and-aesthetics-fall-2009/projects/MIT21M_380F09_proj_mtech_3.pdf) 
in the music industry, but its prevalence and popularity in many 
genres of popular music has secured the technique's importance in music 
production and in digital signal processing (DSP).

The implementation of an autotuner is closely related to the more general 
DSP technique known as a _phase vocoder_. TODO elaborate

NOTE: An introduction to the application area, including how your project fits into the existing state of the art. You should have done a literature search and read some real (i.e., non-web) reference material.

## Techniques

To analyze the frequency content of the audio signal, we utilized 
short-time Fourier transforms (STFTs) of the input signal. This technique 
decomposes the audio signal into a series of Fourier transforms, which 
allows the time domain signal to be represented as a series of 
frequency domain spectra. With this technique, we can analyze the 
frequency components of a signal to determine which frequency or frequencies 
are represented in a small time window of the signal, and work to make changes 
to that frequency spectrum to achieve our desired results.

This approach, described by Laroche and Dolson (1999), can be outlined as follows:

1. Take a Short-Time Fourier-Transform for the input signal.
2. Detect peaks within the STFT.
3. Calculate frequency shift for each peak.
4. Shift the frequency of each peak.
5. Inverse the STFT in order to produce a tuned signal.

These steps will be elaborated on further through the remainder of this section.

Our group made two attempts at implementing this approach. The first worked at 
effectively tuning individual pitches, but was particularly choppy and at times 
failed to identify the correct frequency shift. For this reason, we took a second 
approach. The results section contains data from both, but the remainder of the techniques 
section focuses on the second of our attempts at implementation.

### 1. Short-Time Fourier-Transform

A short-time Fourier-transform breaks a signal into windows of a known time duration, and 
applies an FFT individually for each window.

**TODO: Brief mathematical description of FFT**

**TODO: Briefly cite text on page ~132 about stfts**

**TODO: Hamming window page 128 of textbook**

This is critical because it doesn't just tell us which frequencies are present in the 
signal as a whole, but during which manageably sized tme durations those frequencies 
are present. This is what enables us to tune different points in the signal to different 
pitches, and also to reconstruct the signal later after shifting pitches.

Our final approach fits Laroche and Dolson's description of a basic, peak-based, pitch-shifting phase covoder. 
Like our solution, their basic approach utilizes a fixed, uniform window size (the segments on which the ffts are made) 
and allows a fixed 50% overlap. This is a more simplistic and naive approach, but has half the computational complexity 
of using 75% overlap (Laroche & Dolson, 1999).

### 2. Peak Detection

When implementing pitch correction, our first approach was simplistic. 
We elected to locate the frequency with the largest magnitude in each 
column of the STFT, which we assume is the fundamental frequency for that 
transform. This was true for both approaches.

### 3 and 4. Calculating and Implementing Frequency Shift for each Window

Once a fundamental frequency had been identified, we then performed a raw offset of the column 
containing that transform so that the fundamental frequency of each STFT column resided in the 
frequency-domain bin which was closest to the target frequency. 

### 5. Inverse Short-Time Fourier-Transform

After performing modifications to the signal's STFT, it is necessary to 
convert the frequency domain representation of the modified signal to the 
time domain. To accomplish this, we take the inverse of the STFT, which 
inverts the process used to produce the STFT. First, the inverse FFT of 
each frequency domain window is calculated, and then the time domain 
signal values are rescaled using the inverse of the same mapping used to 
scale the input signal's window. If a Hamming window is used, the reciprocal 
of the scale value for each element is used to rescale each element in 
the inverted FFT. Lastly, if the overlap parameter is non-zero, the resulting 
reconverted signal is cumulatively at the offset specified by the overlap 
parameter.

We specifically searched for, and utilized, and istft which utilized the Overlap-add 
method (pictured in Figure 1).

| ![Overlap-Add Method Process](./media/images/1280px-Overlap-add_algorithm.png) |
|--------------------------------------------------------------------------------|
| Figure 1: Overlap-Add Algorithm Visualization |

TODO: citable source is needed; also, diagram of this process would be useful.

NOTE: Course concepts and algorithms covered by the project. This section is the core justification that this project should result in a good grade for you.

## Design

To isolate the processing and transformation of a signal, and the parameters 
required to perform these tasks, we created a class `AutoTuner` to provide 
object members and functions which perform the steps necessary to perform 
pitch correction. Such a structure allows for multiple pitch correction 
approaches to be written and documented. We explicitly decided that the 
client utilizing the class would be responsible for calling the class 
functions which perform pitch correction and convert the frequency domain 
STFT back into a time domain signal. Separating each of these steps gives 
the user greater control over inspecting and graphing the signal at various 
steps in the process.

Furthermore, we also decided that the `AutoTuner` class would not have 
any graphing utilities embedded into the 

Our final design relied primarily on the following methods:

* **tuneSampled()** to perform the stft using Matlab's spectrogram function, pass the output to correctPitchSpectrum(), then perform an istft on the result.
* **correctPitchSpectrum()** to iteratively perform peak detection and pitch correction for each window of the stft.

**Code Block 1: Function Definition for tuneSampled():**

```matlab
function [ts Fs] = tuneSampled(ogSignal, samplingRate, windowsize, nfft, waveName, targetPitches)
    Fs = samplingRate;
    % actual stft using spectrogram part
    [s f t] = spectrogram(ogSignal, hanning(windowsize), windowsize/2, nfft, samplingRate);
    % file stuff
    spectrogram(ogSignal, hanning(windowsize), windowsize/2, nfft, samplingRate, 'yaxis');
    plotTitle = strcat('Spectrogram for Original ', waveName);
    title(plotTitle);
    fn = strcat('spectrogram_', waveName, '_original.png');     % TODO (make appropriate destination)
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
    fn = strcat('v2_spectrogram_', waveName, '_tuned.png');     % TODO (make appropriate destination)
    saveas(gcf, fn); 
    fn = strcat('v2_', waveName, '_tuned.wav');                 % TODO (make appropriate destination)
    audiowrite(fn, ts, Fs);
    % play output
    sound(ts, Fs);
end
```

Note that, while a separate version exists for handling two channel audio by separately tuning each channel, 
simply adding the channels together and calling tuneSampled is more efficient.

**Code Block 2: Function Definition for correctPitchSpectrum():**

```matlab
function correctedSpectrum = correctPitchSpectrum(s, f, targetPitches)
    % s - short-time spectrum
    % f - frequency space
    % return correctedSpectrum - a vector of the corrected short-time spectrum values
    absS = abs(s);
    y = 20*log10(absS/min(absS(:)));
    % need number of buckets
    numBuckets = length(s(1,:));
    % pre-allocation of return array as Matlab's "intellisense" whinges about it
    correctedSpectrum = zeros(length(s(:,1)),numBuckets);
    % main loop
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
```

TODO: Evaluate this note:
NOTE: A complete design description. It should be extensive enough for someone else to continue development of the project.

## Results

### Approach 1: Raw Frequency Domain Offsets

We ran tests on a few sound examples, showing the altered spectrograms 
and resulting sounds.

Here's a simple test which uses an E♭ in the 5th octave as input.

| Original Signal | Output Signal   |
|-----------------|-----------------|
| ![original spectrogram of E-flat 5](./media/images/v1_straighttoneEb5_specgram_original.png) | ![spectrogram after tuning](./media/images/v1_straighttoneEb5_specgram_tuned.png) |
|  <audio controls markdown="0"><source src="./media/audio/straighttoneEb5_original.wav" type="audio/wav">Your browser does not support the audio element.</audio> | <audio controls markdown="0"><source src="./media/audio/v1_straighttone_result.wav" type="audio/wav">Your browser does not support the audio element.</audio> |

We then tested the software on complex and overtone-rich signals.

|--------|-----------------|-----------------|
| Spoken countdown | ![original spectrogram of E-flat 5](./media/images/v1_countdown_specgram_original.png)<br/>Original spectrogram of spoken numerical countdown. | ![spectrogram after tuning](./media/images/v1_countdown_specgram_tuned.png)<br/>Spectrogram of speech example after pitch correction is applied. |
| ^^ | Audio files of a) original signal, b) pitch correction reference tone, and c) pitch corrected sound. <br/><audio controls markdown="0" style="width: 100%;"><source src="./media/audio/v1_countdown_result.wav" type="audio/wav">Your browser does not support the audio element.</audio> ||
| Synthesized C major scale | ![original spectrogram of c major scale](./media/images/v1_scale_specgram_original.png)<br/>Original spectrogram of C major scale. | ![spectrogram after tuning](./media/images/v1_scale_specgram_tuned.png)<br/>Spectrogram of C major scale after pitch correction is applied. |
| C Major scale audio results |  Audio files of a) original signal, b) pitch correction reference tone, and c) pitch corrected sound. <br/><audio controls markdown="0" style="width: 100%;"><source src="./media/audio/v1_scale_result.wav" type="audio/wav">Your browser does not support the audio element.</audio> ||
| Buddhist Vajrayana chant | ![original spectrogram of vajrayana buddhist chant](./media/images/v1_vajrayana_specgram_original.png)<br/>Original spectrogram of Buddhist vajrayana chant. | ![spectrogram after tuning](./media/images/v1_vajrayana_specgram_tuned.png)<br/>Spectrogram of chant after pitch correction is applied. |
| Buddhist Vajrayana chant audio | Audio files of a) original signal, b) pitch correction reference tone, and c) pitch corrected sound.<br/><audio controls markdown="0" style="width: 100%;"><source src="./media/audio/v1_vajrayana_result.wav" type="audio/wav">Your browser does not support the audio element.</audio> ||

Strictly testing:

$$H(z) = \frac{Y(z)}{X(z)}$$

TODO: write up an analysis of what happened to the audio clips we tried 
to autotune.

### Approach 2: TODO figure out what to call this

These are the results for the second approach, using 50% window overlap, fixed 
window length, and a non-object-oriented approach. We were able to improve our 
turning, as well as choppiness and overall fidelity to the original audio's sound 
characteristics.

For the purposes of this approach, Matlab’s `spectrogram` function was used rather than the stft function, partially for the purpose of consolidating code where spectrogram’s needed to be produced anyways. The bulk of the process was performed by a single method, `correctPitchSpectrum`. That’s method’s function definition is shown below in Code Block 1.

Our first step was validating this second approach. To this end, we generated an audio file with constantly increasing frequency (available below), and attempted to tune it to the C-Major scale. This proved effective, and the tuning shows in the spectrogram as horizontal steps for each change in pitch.

| Original Signal | Output Signal   |
|-----------------|-----------------|
| ![Spectrogram for Original Increasing Frequency Audio](./media/images/spectrogram__Increasing_original.png) | ![spectrogram after tuning](./media/images/v2_spectrogram__Increasing_tuned.png) |
|  <audio controls markdown="0"><source src="./media/audio/increasing.wav" type="audio/wav">Your browser does not support the audio element.</audio> | <audio controls markdown="0"><source src="./media/audio/v2__Increasing_tuned.wav" type="audio/wav">Your browser does not support the audio element.</audio> |

Next, and as a point of comparison between the two approaches, consider the C-Major scale .wav file used for testing purposes above. The output was choppy, an not entirely on pitch. Note that our expectation is no significant pitch change, with a secondary goal of maintaining sound characteristics.

Note that while the displayed results were achieved by first adding the two channels of audio sampled from the original .wav file, the same result was achieved by separately tuning each channel and recombining at the end. This is to be expected for a scale.

| Original Signal | Output Signal   |
|-----------------|-----------------|
| ![Spectrogram for Original C-Major Scale Audio](./media/images/v2_scale_spectrogram_og.png) | ![spectrogram after tuning](./media/images/v2_scale_spectrogram_tuned.png) |
|  <audio controls markdown="0"><source src="./media/audio/scale_original.wav" type="audio/wav">Your browser does not support the audio element.</audio> | <audio controls markdown="0"><source src="./media/audio/v2_scale_result.wav" type="audio/wav">Your browser does not support the audio element.</audio> |

There are two key observations to make:

* First, the tones are smoother and appear to be the correct pitch.
* Second, the duration of the output audio is slightly shorter.

The first observation is reflective of the fact that this second approach works extremely well for single tone audio, while the second is reflective of the fact that, during the peak identification process, the beginning and end were ever so slightly truncated.

While the C-Major scale provides an example of the advantages of this second approach over our first, now consider the Vajrayana chant.

| Original Signal | Output Signal   |
|-----------------|-----------------|
| ![Spectrogram for Original Vajrayana Chant](./media/images/spectrogram_chant_original.png) | ![spectrogram after tuning](./media/images/v2_spectrogram_chant_tuned.png) |
|  <audio controls markdown="0"><source src="./media/audio/vajrayana_original.wav" type="audio/wav">Your browser does not support the audio element.</audio> | <audio controls markdown="0"><source src="./media/audio/v2_chant_tuned.wav" type="audio/wav">Your browser does not support the audio element.</audio> |

## User Guide

Following these steps will allow anyone to run the software and 
reproduce our results or experiment with user-supplied sound samples.

The relevant structure of our project is as follows:

```
.
├── matlab/
│   ├── AutoTuner.m
│   ├── driver.m
│   ├── pitchTable.m
│   ├── spectrogramPlot.m
│   ├── test_audio/
│   ├── test_images/
│   └── utils
│       └── AnalogSignal.m
└── sounds/
```

Each of the Matlab files listed here performs specific functionality.

* `AutoTuner.m`: A class which rovides the core implementation of our pitch 
  correction approaches and necessary utilities.
  It contains an object constructor which stores the input arguments and other 
  necessary parameters for creating the STFT and its inverse. There are 
  other important methods in this file which perform pitch correction and 
  create the STFT and its inverse. 
* `driver.m`: the driver for the end-to-end processing of an audio file. 
  It contains a utility method called `performSinglePitchAutoTune`, which 
  allows the user to decrease the repetitiveness of the various steps 
  needed to produce STFT modifications, spectrograms, and audio files for 
  the resulting pitch correction.
  This file also contains calls to produce pitch correction results for 
  different inputs.
* `pitchTable.m`: Contains a matrix of the frequencies of the Western 
  chromatic scale from octave 0 through octave 8.
* `spectrogramPlot.m`: Creates plots of the STFT and the modified STFT 
  to show the original and pitch-corrected value of the signal in the 
  frequency domain.
* `utils/AnalogSignal.m`: we wished to produce an example of the target 
  frequency so that the target frequency and processed input can be 
  compared with each other by the listener. To do this, we utilize the 
  AnalogSignal class provided by Prof. Stiber.

To provide new sound samples, add audio files to the `sounds/` directory.

Then, navigate to the `matlab/` directory and open up the `driver.m` file. 

Around line 7, there are a series of calls to the `performSinglePitchAutoTune` 
method. You may add, remove, or reorder these calls as you see fit, and 
you may add a call to process a sound file you have provided.

If, for example, you wanted to process an audio file called `example.wav`, 
you would move it to the `sounds/` directory, and in `driver.m`, add a 
single call:

```matlab
performSinglePitchAutoTune('example', 'wav', pitches(5, 10), 'test_images/example');
```

Then, from the Matlab IDE or from the CLI application, you can invoke 
the pitch correction process by simply typing `driver` to run the script file.

The software produces spectrogram plots of the original signal's STFT 
and the modified STFT after pitch correction has been applied. The software 
also produces the following audio files:

* A copy of the target frequency tone, saved as `test_audio/tone_<desiredPitch>hz.wav`
* A copy of the pitch correction result of the original signal, saved as `test_audio/<audioFilename>_tuned_<desiredPitch>.wav`
* A concatenated version of the input, desired tone, and resulting signal after pitch correction, with half a second of silence between each signal

How does your software work (from the user’s point of view)? Should include things like screen shots. Illustrate the sytem in operation with real execution examples. A screencast video would be appropriate here (but is not required). If you want to do this, please contact me ahead of time to deliver the video separately, since I assume that it will be too big to submit via Canvas.

## Alternative Approaches

TODO: Discusses other possible ways to implement this.

## Limitations

Our existing implementation of this solution requires a single tone as 
input, and does not allow for a time-series representation of multiple 
target pitches. 

NOTE: What your project doesn’t do, that it might have, given time and motivation.

## Problems

Our basic approach, which performs a frequency-domain offset without scaling the magnitude values in each frequency domain bin, has numerous pitfalls:

1. By taking the single largest magnitude in each frequency-domain bin, 
   this implementation is susceptible to signal noise.
2. In complex sound structures which have natural overtones, the overtones 
   which have lower magnitudes are not properly scaled when the fundamental 
   frequency is scaled. This behavior corrupts the sound and introduces 
   
NOTE: Problems encountered and solutions applied (or, if not solved, possible avenues for solution).

## Future Work

NOTE: Suggested extensions to your program.

## References

Diaz, Joe. "The Fate of Auto-Tune." Music and Technology (2009). [Online PDF.](https://ocw.mit.edu/courses/music-and-theater-arts/21m-380-music-and-technology-contemporary-history-and-aesthetics-fall-2009/projects/MIT21M_380F09_proj_mtech_3.pdf)

Laroche, J., and M. Dolson. “New Phase-Vocoder Techniques for Pitch-Shifting, Harmonizing and Other Exotic Effects.” Proceedings of the 1999 IEEE Workshop on Applications of Signal Processing to Audio and Acoustics. 1999, pp. 91–94., [doi:10.1109/aspaa.1999.810857](doi:10.1109/aspaa.1999.810857). [Online PDF](https://www.ee.columbia.edu/~dpwe/papers/LaroD99-pvoc.pdf)

