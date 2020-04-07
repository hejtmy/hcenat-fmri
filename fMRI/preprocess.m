clear ; clc
% paths work if the matlab is loaded at the project ROOT
%% preparing data paths
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';

pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
pthWalkingData = fullfile(pwd,'exports','walking.csv');
pthWalkingLearnData = fullfile(pwd,'exports','walking-learn.csv');
pthWalkingTrialData = fullfile(pwd,'exports','walking-trial.csv');
pthPointingData = fullfile(pwd,'exports','pointing.csv');
pthPointingLearnData = fullfile(pwd,'exports','pointing-learn.csv');
pthPointingTrialData = fullfile(pwd,'exports','pointing-trial.csv');

%% Loading behavioural files
subjects = importdata(pthSubjects);

walkingData = readeventfile(pthWalkingData, '%s %f %f %s');
walkingData = filtervalidevents(walkingData);

walkingLearnData = readeventfile(pthWalkingLearnData, '%s %f %f %s');
walkingLearnData = filtervalidevents(walkingLearnData);

walkingTrialData = readeventfile(pthWalkingTrialData, '%s %f %f %s');
walkingTrialData = filtervalidevents(walkingTrialData);

pointingData = readeventfile(pthPointingData, '%s %f %f %f');
pointingData = filtervalidevents(pointingData);

pointingLearnData = readeventfile(pthPointingLearnData, '%s %f %f %f');
pointingLearnData = filtervalidevents(pointingLearnData);

pointingTrialData = readeventfile(pthPointingTrialData, '%s %f %f %f');
pointingTrialData = filtervalidevents(pointingTrialData);
%% Setting FMRI base
TR = 3; % TR = 3 sec
SESSION_LENGTH = 400;
MIN_PULSE_RATIO = 0.9; %minimum ratio of a pulse happening in event

%% Per subject
for i = 1:numel(subjects)
    [subject, ~] = getsubjectnamesession(subjects{i});
    disp(['Preparing subject ' subject]);
    %% Movement ----
    subjectData = getsubjectevents(walkingData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, subject, 'moving');
    savehrf(hrfStill, subject, 'still');
    
    subjectData = getsubjectevents(walkingLearnData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, subject, 'moving-learn');
    savehrf(hrfStill, subject, 'still-learn');
    
    subjectData = getsubjectevents(walkingTrialData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, subject, 'moving-trial');
    savehrf(hrfStill, subject, 'still-trial');

    %% Pointing ----
    subjectData = getsubjectevents(pointingData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, subject, 'pointing');
    
    subjectData = getsubjectevents(pointingLearnData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, subject, 'pointing-learn');
    
    subjectData = getsubjectevents(pointingTrialData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, subject, 'pointing-trial');
end