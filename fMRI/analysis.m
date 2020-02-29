%% Load the hce ica
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';

%% Load all the filtered components
pthsComponents = dir(fullfile(dataDirectory, 'filtered', '*.csv'));
components = struct();
for i = 1:numel(pthsComponents)
    [name, type] = getcomponentname(pthsComponents(i).name);
    components.(name) = dlmread(fullfile(pthsComponents(i).folder, pthsComponents(i).name));
end
%% load the participant names 
pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
subjects = importdata(pthSubjects);

%% 
for i = 1:numel(subjects)
    subMove(:,i) = readmatrix(fullfile(subPath,[subName,'_moving.txt']));
    subStill(:,i) = readmatrix(fullfile(subPath,[subName,'_still.txt']));
    subPoint(:,i) = readmatrix(fullfile(subPath,[subName,'_pointing.txt']));
    
    % Butterworth filter
    comps(:,:,i) = butter_filter(comps(:,:,i),tr,0.009,0.05);
    
    % Pearson
    corrIcMoveP(:,i) = corr(subMove(:,i),comps(:,:,i));
    corrIcStillP(:,i) = corr(subStill(:,i),comps(:,:,i));
    corrIcPointP(:,i) = corr(subPoint(:,i),comps(:,:,i));
    
    % Spearman
    corrIcMoveS(:,i) = corr(subMove(:,i),comps(:,:,i),'Type','Spearman');
    corrIcStillS(:,i) = corr(subStill(:,i),comps(:,:,i),'Type','Spearman');
    corrIcPointS(:,i) = corr(subPoint(:,i),comps(:,:,i),'Type','Spearman');
    
end