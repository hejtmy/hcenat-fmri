function [hrfMovement, hrfStill] = preparehrfmovement(walkingEvents, tr, ...
    sessionLength, minPulseRatio)
%PREPARESUBJECTHRF Summary of this function goes here
%   Detailed explanation goes here
%
%PARAMETERS
%   tr: length of a single pulse
%   sessionLength: how many pulses did the recording have
%   minPulseratio: minimal portio of the pulse that the event should cover

    %% Movement ----
    movingTimes = geteventtimes(walkingEvents, 'moving');
    movementBlocks = eventtimestotrblocks(movingTimes, tr, sessionLength);
    movementBlocks = movementBlocks > minPulseRatio;
    hrfMovement = convolveblockhrf(movementBlocks, tr);

    %% Still -------
    stillTimes = geteventtimes(walkingEvents, 'still');
    stillBlocks = eventtimestotrblocks(stillTimes, tr, sessionLength);
    stillBlocks = stillBlocks > minPulseRatio;
    hrfStill  = convolveblockhrf(stillBlocks, tr);
end

