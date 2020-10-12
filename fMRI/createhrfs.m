%%
clear ; clc

%% Setting FMRI base
TR = 3; % TR = 3 sec
SESSION_LENGTH = 400;
MIN_PULSE_RATIO = 0.5; %minimum ratio of a pulse happening in event

% paths work if the matlab is loaded at the project ROOT
%% preparing data paths
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';
eventDirectory = fulfille(pwd, 'exports', 'events');
exportDirectory = fullfile(pwd, 'exports', 'hrf');

pthSubjects = fullfile(dataDirectory, 'subs_20190830_1422.txt');
pthWalkingData = fullfile(eventDirectory, 'walking.csv');
pthWalkingLearnData = fullfile(eventDirectory, 'walking-learn.csv');
pthWalkingTrialData = fullfile(eventDirectory, 'walking-trial.csv');
pthPointingData = fullfile(eventDirectory, 'pointing.csv');
pthPointingLearnData = fullfile(eventDirectory, 'pointing-learn.csv');
pthPointingTrialData = fullfile(eventDirectory, 'pointing-trial.csv');

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

%% Per subject
for i = 1:numel(subjects)
    [subject, ~] = getsubjectnamesession(subjects{i});
    disp(['Preparing subject ' subject]);
    %% Movement ------------------
    subjectData = getsubjectevents(walkingData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, exportDirectory, subject, 'moving');
    savehrf(hrfStill, exportDirectory, subject, 'still');
    
    subjectData = getsubjectevents(walkingLearnData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, exportDirectory, subject, 'moving-learn');
    savehrf(hrfStill, exportDirectory, subject, 'still-learn');
    
    subjectData = getsubjectevents(walkingTrialData, subject);
    [hrfMovement, hrfStill] = preparehrfmovement(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfMovement, subject, 'moving-trial');
    savehrf(hrfStill, exportDirectory, subject, 'still-trial');

    %% Pointing -----------------
    subjectData = getsubjectevents(pointingData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, exportDirectory, subject, 'pointing');
    
    subjectData = getsubjectevents(pointingLearnData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, exportDirectory, subject, 'pointing-learn');
    
    subjectData = getsubjectevents(pointingTrialData, subject);
    hrfPoinitng = preparehrfpointing(subjectData, TR,...
        SESSION_LENGTH, MIN_PULSE_RATIO);
    savehrf(hrfPoinitng, exportDirectory, subject, 'pointing-trial');
end