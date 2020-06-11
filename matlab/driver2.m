addpath('../sounds');
addpath('utils');

% Read in pitch table from this directory
pitchTable
cmajorPitchTable

%% Test for Sound with Frequency Increasing At Constant Rate
% 1) read in
[ogSignal, Fso] = audioread('increasing.wav')
% 2) tune
[ts Fs] = tuneSampled(ogSignal, Fso, 1000, 1024, 'increasing', cmajorPitches)
pause(44); % not part of process

%% Test for cscale
% 1) read in
[ogSignal, Fso] = audioread('eqt-major-sc.wav')
% 2) combine two channels
ogSignal = ogSignal(:,1) + ogSignal(:,2)
% 3) tune
[ts Fs] = tuneSampled(ogSignal, Fso, 1000, 1024, 'CMajorScale', cmajorPitches)
pause(6); % not part of process

%% Test for Vajrayana Chant
% 1) read in
[ogSignal, Fso] = audioread('overtones_vajrayana.aiff')
% 2) combine two channels
ogSignal = ogSignal(:,1) + ogSignal(:,2)
% 3) tune
[ts Fs] = tuneSampled(ogSignal, Fso, 1000, 1024, 'VajrayanaChant', cmajorPitches)