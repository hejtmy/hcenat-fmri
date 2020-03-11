clear ; clc
% paths work if the matlab is loaded at the project ROOT
%% preparing data paths
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';

pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
pthWalkingData = fullfile(pwd,'exports','walking.csv');
pthPointingData = fullfile(pwd,'exports','pointing.csv');

%% Loading behavioural files
subjects = importdata(pthSubjects);

walkingData = readeventfile(pthWalkingData, '%s %f %f %s');
walkingData = filtervalidevents(walkingData);

pointingData = readeventfile(pthPointingData, '%s %f %f %f');
pointingData = filtervalidevents(pointingData);

%% Setting FMRI base
TR = 3; % TR = 3 sec
SESSION_LENGTH = 400;
MIN_PULSE_RATIO = 0.9; %minimum ratio of a pulse happening in event

%% Per subject
for i = 1:numel(subjects)
    [subject, ~] = getsubjectnamesession(subjects{i});
    subjectData = getsubjectevents(walkingData, subject);
    disp(['Preparing subject ' subject]);
    %% Movement ----
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, subject, 'moving');
    savehrf(hrfStill, subject, 'still');
    
    %% Pointing ----
    subjectData = getsubjectevents(pointingData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, subject, 'pointing');
end