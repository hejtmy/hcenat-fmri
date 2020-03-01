%% Load the hce ica
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';

%% Load all the filtered components
pthsComponents = dir(fullfile(dataDirectory, 'filtered', '*.csv'));
components = [];
componentNames = {};
for i = 1:numel(pthsComponents)
    [name, type] = getcomponentname(pthsComponents(i).name);
    componentNames{i} = name;
    components(i,:,:) = dlmread(fullfile(pthsComponents(i).folder, pthsComponents(i).name));
end
%% load the participant names 
pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
subjects = importdata(pthSubjects);

%%
i = 1;
for i = 1:numel(subjects)
    [subject, ~] = getsubjectnamesession(subjects{i});
    
    moving = readhrf(subject, 'moving');
    still = readhrf(subject, 'still');
    pointing = readhrf(subject, 'pointing');
    
    % Butterworth filter
    % comps(:,:,i) = butter_filter(comps(:,:,i),tr,0.009,0.05);

    corrIcMoveP(:,i) = corr(moving,components(:,:,i)');
    corrIcStillP(:,i) = corr(still,components(:,:,i)');
    corrIcPointP(:,i) = corr(pointing,components(:,:,i)');
    
    % Spearman
    corrIcMoveS(:,i) = corr(moving,components(:,:,i)','Type','Spearman');
    corrIcStillS(:,i) = corr(still,components(:,:,i)','Type','Spearman');
    corrIcPointS(:,i) = corr(pointing,components(:,:,i)','Type','Spearman');
end
