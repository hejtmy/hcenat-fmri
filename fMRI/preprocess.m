clear ; clc
% paths work if the matlab is loaded at the project ROOT
%% preparing data paths
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';

pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
pthWalkingData = fullfile(pwd,'exports','walking.csv');
pthPointingData = fullfile(pwd,'exports','pointing.csv');

%% Loading behavioural files
subs = importdata(pthSubjects);

walkingData = readeventfile(pthWalkingData, '%s %f %f %s');
walkingData = filtervalidevents(walkingData);

pointingData = readeventfile(pthPointingData, '%s %f %f %f');
pointingData = filtervalidevents(pointingData);
%% Setting FMRI base
TR = 3; % TR = 3 sec
SESSION_LENGTH = 400;
blankTs = zeros(400,1); % blank time series
hrf = spm_hrf(TR); % (SPM Toolbox required) create hrf function 

%% Per subject
i = 1;
[subject, ~] = getsubjectnamesession(subs{i});
subjectData = getsubjectevents(walkingData, subject);
movingTimes = geteventtimes(subjectData, 'moving');
movementBlocks = eventtimestotrblocks(movingTimes, TR, SESSION_LENGTH);
