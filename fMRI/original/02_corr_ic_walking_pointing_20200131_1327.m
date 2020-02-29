clear ; clc

addpath('/hydra-db/hydra_io/vypocty/tomecek/hce/info/filters')

load('/hydradb/hydra_io/vypocty/tomecek/hce/results/gift_20181126_0924/hce_ica_parameter_info.mat') % GIFT parameter file
load('/hydradb/hydra_io/vypocty/tomecek/hce/results/gift_20181126_0924/comps/comps_20181204_121411.mat') % IC time series

tr = 3; % TR = 3 sec
numSigCorr = 5; % Number of significant IC (just for visualization)

for i = 1:sesInfo.numOfSub
    
    subPath = fileparts(sesInfo.userInput.files(i).name(1,:));
    [~,subName,~] = fileparts(fileparts(subPath));
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

%% PLOTS
% Pearson
meanCorrMoveP = mean(corrIcMoveP,2,'omitnan');
meanCorrStillP = mean(corrIcStillP,2,'omitnan');
meanCorrPointP = mean(corrIcPointP,2,'omitnan');

[maxCorrMoveP,maxCorrMovePInd] = sortrows(meanCorrMoveP,'descend');
[maxCorrStillP,maxCorrStillPInd] = sortrows(meanCorrStillP,'descend');
[maxCorrPointP,maxCorrPointPInd] = sortrows(meanCorrPointP,'descend');

[minCorrMoveP,minCorrMovePInd] = sortrows(meanCorrMoveP,'ascend');
[minCorrStillP,minCorrStillPInd] = sortrows(meanCorrStillP,'ascend');
[minCorrPointP,minCorrPointPInd] = sortrows(meanCorrPointP,'ascend');

figure
subplot(131)
imagesc(corrIcMoveP);colorbar;title('corr (Pearson) IC moving')
subplot(132)
imagesc(corrIcStillP);colorbar;title('corr (Pearson) IC still')
subplot(133)
imagesc(corrIcPointP);colorbar;title('corr (Pearson) IC pointing')

figure('Position',[173,282,1656,532])
bar([meanCorrMoveP,meanCorrStillP,meanCorrPointP])
legend('moving','still','pointing')
title('mean corr. (Pearson) IC & moving, still, pointing')
hold on
text(maxCorrMovePInd(1:numSigCorr)+0.25,maxCorrMoveP(1:numSigCorr),cellstr(num2str(maxCorrMovePInd(1:numSigCorr))),'color',[0 0.4470 0.7410],'FontSize',8)
text(maxCorrStillPInd(1:numSigCorr)+0.25,maxCorrStillP(1:numSigCorr),cellstr(num2str(maxCorrStillPInd(1:numSigCorr))),'color',[0.8500 0.3250 0.0980],'FontSize',8)
text(maxCorrPointPInd(1:numSigCorr)+0.25,maxCorrPointP(1:numSigCorr),cellstr(num2str(maxCorrPointPInd(1:numSigCorr))),'color',[0.9290 0.6940 0.1250],'FontSize',8)
text(minCorrMovePInd(1:numSigCorr)+0.25,minCorrMoveP(1:numSigCorr),cellstr(num2str(minCorrMovePInd(1:numSigCorr))),'color',[0 0.4470 0.7410],'FontSize',8)
text(minCorrStillPInd(1:numSigCorr)+0.25,minCorrStillP(1:numSigCorr),cellstr(num2str(minCorrStillPInd(1:numSigCorr))),'color',[0.8500 0.3250 0.0980],'FontSize',8)
text(minCorrPointPInd(1:numSigCorr)+0.25,minCorrPointP(1:numSigCorr),cellstr(num2str(minCorrPointPInd(1:numSigCorr))),'color',[0.9290 0.6940 0.1250],'FontSize',8)

% Spearman
meanCorrMoveS = mean(corrIcMoveS,2,'omitnan');
meanCorrStillS = mean(corrIcStillS,2,'omitnan');
meanCorrPointS = mean(corrIcPointS,2,'omitnan');

[maxCorrMoveS,maxCorrMoveSInd] = sortrows(meanCorrMoveS,'descend');
[maxCorrStillS,maxCorrStillSInd] = sortrows(meanCorrStillS,'descend');
[maxCorrPointS,maxCorrPointSInd] = sortrows(meanCorrPointS,'descend');

[minCorrMoveS,minCorrMoveSInd] = sortrows(meanCorrMoveS,'ascend');
[minCorrStillS,minCorrStillSInd] = sortrows(meanCorrStillS,'ascend');
[minCorrPointS,minCorrPointSInd] = sortrows(meanCorrPointS,'ascend');

figure
subplot(131)
imagesc(corrIcMoveS);colorbar;title('corr (Spearman) IC moving')
subplot(132)
imagesc(corrIcStillS);colorbar;title('corr (Spearman) IC still')
subplot(133)
imagesc(corrIcPointS);colorbar;title('corr (Spearman) IC pointing')

figure('Position',[173,282,1656,532])
bar([meanCorrMoveS,meanCorrStillS,meanCorrPointS])
legend('moving','still','pointing')
title('mean corr. (Spearman) IC & moving, still, pointing')
hold on
text(maxCorrMoveSInd(1:numSigCorr)+0.25,maxCorrMoveS(1:numSigCorr),cellstr(num2str(maxCorrMoveSInd(1:numSigCorr))),'color',[0 0.4470 0.7410],'FontSize',8)
text(maxCorrStillSInd(1:numSigCorr)+0.25,maxCorrStillS(1:numSigCorr),cellstr(num2str(maxCorrStillSInd(1:numSigCorr))),'color',[0.8500 0.3250 0.0980],'FontSize',8)
text(maxCorrPointSInd(1:numSigCorr)+0.25,maxCorrPointS(1:numSigCorr),cellstr(num2str(maxCorrPointSInd(1:numSigCorr))),'color',[0.9290 0.6940 0.1250],'FontSize',8)
text(minCorrMoveSInd(1:numSigCorr)+0.25,minCorrMoveS(1:numSigCorr),cellstr(num2str(minCorrMoveSInd(1:numSigCorr))),'color',[0 0.4470 0.7410],'FontSize',8)
text(minCorrStillSInd(1:numSigCorr)+0.25,minCorrStillS(1:numSigCorr),cellstr(num2str(minCorrStillSInd(1:numSigCorr))),'color',[0.8500 0.3250 0.0980],'FontSize',8)
text(minCorrPointSInd(1:numSigCorr)+0.25,minCorrPointS(1:numSigCorr),cellstr(num2str(minCorrPointSInd(1:numSigCorr))),'color',[0.9290 0.6940 0.1250],'FontSize',8)

% figure
% hold on
% histogram(subMove,'EdgeColor','none')
% histogram(subStill,'EdgeColor','none')
% histogram(subPoint,'EdgeColor','none')
