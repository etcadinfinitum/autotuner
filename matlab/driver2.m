addpath('../sounds');
addpath('utils');

% Read in pitch table from this directory
pitchTable
cmajorPitchTable

%% Test for cscale
% 1) read in
[ogSignal, Fso] = audioread('eqt-major-sc.wav')
% 2) combine two channels
ogSignal = ogSignal(:,1) + ogSignal(:,2)
% 3) tune
[ts Fs] = tuneSampled(ogSignal, Fso, 1000, 1024, 'C_Major_Scale', cmajorPitches)
