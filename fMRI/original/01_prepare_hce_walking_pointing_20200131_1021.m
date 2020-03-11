clear ; clc

subs = importdata('/hydradb/hydra_io/vypocty/tomecek/hce/data_20181112/subs_20200131_1038.txt'); % list of subjects
fileIdWalk = fopen('/hydra-db/hydra_io/vypocty/tomecek/hce/info/20191211/walking.csv'); % select 'walking.csv' file
walking = textscan(fileIdWalk,'%s %s %f %f','HeaderLines',1,'Delimiter',','); % open 'walking.csv' file
fileIdPoint = fopen('/hydra-db/hydra_io/vypocty/tomecek/hce/info/20191211/pointing.csv'); % select 'pointing.csv' file
pointing = textscan(fileIdPoint,'%s %f %f %f','HeaderLines',1,'Delimiter',','); % open 'walking.csv' file
tr = 3; % TR = 3 sec
blankTs = zeros(400,1); % blank time series
hrf = spm_hrf(tr); % (SPM Toolbox required) create hrf function 

for i = 1:size(subs,1)
    %% WALKING 
    [~,subName,~] = fileparts(fileparts(subs{i}));
    subId = subName(5:10);
    [~,subSess,~] = fileparts(subs{i});
        
    walkingData = find(strcmp(walking{1}, subId)); % find relevant rows for each subject
    walkingTime = walking{3}(walkingData); % find onsets
    walkingDur = walking{4}(walkingData); % find durations
    
    % MOVING
    subMoving = strcmp(walking{2}(walkingData), 'moving'); % 'moving' indices
    subMovingTime = walkingTime(subMoving); % extract 'moving' onsets
     % QUESTION - can't this result in pulse 0?
     % QUESTION - how this handles situation where some events start say at
     % the time of 3.1 and others at 5.9? isn't that the same result,
     % although in some cases it "saturates" the entire pulse and in other
     % cases it barely impacts it? what about situation where the event is
     % from time 4.54-5.99. Does that get "discarded" completely?
    subMovingTime = round(subMovingTime./tr); % convert 'moving' onsents in seconds to volumes
    % QUESTION - - this basically removes any events happening at
    % 0.5! - shouldn't here be >=0
    nonNegMovingTime = find(subMovingTime > 0); % find negative onsets 
    subMovingTime = subMovingTime(nonNegMovingTime); % discard negative onsets
    subMovingDur = walkingDur(subMoving); % extract 'moving' durations
    subMovingDur = round(subMovingDur./tr); % convert 'moving' durations in seconds to volumes
    subMovingDur = subMovingDur(nonNegMovingTime); % discard negative durations
    [subMovingTime,sortInd] = sortrows(subMovingTime); % sort 'moving' onsets
    subMovingDur = subMovingDur(sortInd); % sort 'moving' durations according to 'moving' onsets
    
    % create 'moving' blocks
	movingTsTEMP = blankTs;
    for j = 1:size(subMovingTime,1)
        % QUESTION - I am a bit confused about the subMoving time being
        % position at the round, because matlab indexes at 1 - e.g if you
        % an event happens at time 1.56 - it gets rounded (1.56/3) to 1,
        % but it should be pulse 2!, not pulse 1. Pulse 1, starts at time 0
        % and time 3.1 should therefore be market as event happening at a
        % position 2, not a position 1. Shouldn't the subMovingTime be
        % either round(subMovingTime./tr) + 1; or this be 
        % subMovingTime(j)+1:subMovingTime(j)+subMovingDur(j) = ones? this
        % feels like everythig in shifted by one, right?
        movingTsTEMP(subMovingTime(j):subMovingTime(j)+subMovingDur(j)-1,1) = ones(subMovingDur(j),1);
    end
    movingTsTEMP = sum(movingTsTEMP,2); % merge blocks
    movingTs(:,i) = movingTsTEMP(1:size(blankTs,1));
    movingTsHrfTEMP = conv(movingTs(:,i), hrf); % convolution with hrf
    movingTsHrf(:,i) = movingTsHrfTEMP(1:length(movingTs)); % cut off the end (resulting time series are longer after convolution)
    writematrix(movingTsHrf(:,i),fullfile(subs{i},[subName,'_moving.txt']))
    
    % STILL
    subStill = strcmp(walking{2}(walkingData), 'still'); % 'still' indices
    subStillTime = walkingTime(subStill); % extract 'still' onsets
    subStillTime = round(subStillTime./tr); % convert 'still' onsents in seconds to volumes
    nonNegStillTime = find(subStillTime > 0); % find negative onsets
    subStillTime = subStillTime(nonNegStillTime); % discard negative onsets
    subStillDur = walkingDur(subStill); % extract 'still' durations
    subStillDur = round(subStillDur./tr); % convert 'still' durations in seconds to volumes
    subStillDur = subStillDur(nonNegStillTime); % discard negative durations
    [subStillTime,sortInd] = sortrows(subStillTime); % sort 'still' onsets
    subStillDur = subStillDur(sortInd); % sort 'still' durations according to 'still' onsets
    
    % create 'still' blocks
    stillTsTEMP = blankTs;
    for j = 1:size(subStillTime,1)
        stillTsTEMP(subStillTime(j):subStillTime(j)+subStillDur(j)-1,1) = ones(subStillDur(j),1);
    end
    stillTsTEMP = sum(stillTsTEMP,2); % merge blocks
    stillTs(:,i) = stillTsTEMP(1:size(blankTs,1));
    stillTsHrfTEMP = conv(stillTs(:,i),hrf); % convolution with hrf
    stillTsHrf(:,i) = stillTsHrfTEMP(1:length(stillTs)); % cut off the end (resulting time series are longer after convolution)
    writematrix(stillTsHrf(:,i),fullfile(subs{i},[subName,'_still.txt']))

    %% POINTING   
    pointingData = find(strcmp(pointing{1}, subId)); % find relevant rows for each subject
    pointingTime = pointing{2}(pointingData); % find onsets
    pointingDur = pointing{3}(pointingData); % find durations
    pointingAngle = pointing{4}(pointingData); % find angles
    
    subPointingTime = round(pointingTime./tr); % convert 'pointing' onsents in seconds to volumes
    nonNegPointingTime = find(subPointingTime > 0); % find negative onsets
    subPointingTime = subPointingTime(nonNegPointingTime); % discard negative onsets
    subPointingDur = round(pointingDur./tr); % convert 'pointing' durations in seconds to volumes
    subPointingDur = subPointingDur(nonNegPointingTime); % discard negative durations
    [subPointingTime,sortInd] = sortrows(subPointingTime); % sort 'pointing' onsets
    subPointingDur = subPointingDur(sortInd); % sort 'pointing' durations according to 'pointing' onsets
    subPointingAngle = pointingAngle(nonNegPointingTime); % discard angle_error
    subPointingAngle = subPointingAngle(sortInd); % sort 'pointing' angle_error according to 'pointing' onsets
    
    % create 'pointing' blocks
    pointingTsTEMP = blankTs;
    for j = 1:size(subPointingTime,1)
        pointingTsTEMP(subPointingTime(j):subPointingTime(j)+subPointingDur(j)-1,1) = ones(subPointingDur(j),1);
    end
    pointingTsTEMP = sum(pointingTsTEMP,2); % merge blocks
    pointingTs(:,i) = pointingTsTEMP(1:size(blankTs,1));
    pointingTsHrfTEMP = conv(pointingTs(:,i),hrf); % convolution with hrf
    pointingTsHrf(:,i) = pointingTsHrfTEMP(1:length(pointingTs)); % cut off the end (resulting time series are longer after convolution)
    writematrix(pointingTsHrf(:,i),fullfile(subs{i},[subName,'_pointing.txt']))
end