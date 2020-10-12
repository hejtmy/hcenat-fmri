%%
clear ; clc

%% Setting FMRI base
TR = 3; % TR = 3 sec
SESSION_LENGTH = 400;
MIN_PULSE_RATIO = 0.5; %minimum ratio of a pulse happening in event

% paths work if the matlab is loaded at the project ROOT
%% preparing data paths
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';
eventDirectory = fullfile(pwd, 'exports', 'shifted-events');
exportDirectory = fullfile(pwd, 'exports', 'shifted-hrf');

%% 
% All environment variables should be set above
% This is done because of the shifted components
createandexporthrfs

clear; clc;