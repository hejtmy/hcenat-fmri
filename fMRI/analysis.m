%% Load the hce ica
dataDirectory = 'E:\OneDrive\NUDZ\projects\HCENAT\MRI-data-tomecek\';
% load the participant names -----
pthSubjects = fullfile(dataDirectory,'subs_20190830_1422.txt');
subjects = importdata(pthSubjects);

% Load all the filtered components ----
pthsComponents = dir(fullfile(dataDirectory, 'filtered', '*.csv'));
components = []; % TODO prealocation based on a first i
componentNames = cell(numel(pthsComponents));
for i = 1:numel(pthsComponents)
    [name, type] = getcomponentname(pthsComponents(i).name);
    componentNames{i} = name;
    components(i,:,:) = dlmread(fullfile(pthsComponents(i).folder,...
        pthsComponents(i).name));
end

%% Correlations
% correlations are 2d matrices of component x subject
for i = 1:numel(subjects)
    [subject, ~] = getsubjectnamesession(subjects{i});
    subjects{i} = subject;
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

%% Averaging
meanCorrMoveP = mean(corrIcMoveP,2,'omitnan');
meanCorrStillP = mean(corrIcStillP,2,'omitnan');
meanCorrPointP = mean(corrIcPointP,2,'omitnan');

%% PLOTS
figure
subplot(131)
correlationmatrix(corrIcMoveP, 'corr (Pearson) IC moving', subjects, componentNames);
subplot(132);
correlationmatrix(corrIcStillP, 'corr (Pearson) IC still', subjects, componentNames);
subplot(133)
correlationmatrix(corrIcPointP, 'corr (Pearson) IC pointing', subjects, componentNames);

figure('Position',[173,282,1656,532])
bar([meanCorrMoveP,meanCorrStillP,meanCorrPointP])
legend('moving','still','pointing')
title('mean corr. (Pearson) IC & moving, still, pointing')
xticks(1:numel(componentNames))
xticklabels(componentNames)