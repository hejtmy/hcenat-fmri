function [hrfMovement, hrfStill] = preparehrfmovement(walkingEvents, tr, ...
    sessionLength, minPulseRatio)
%PREPARESUBJECTHRF This function prepares HRF for movement based on exported events
%   and defined parameters 
%
%PARAMETERS
%   walkingEvents: output of getsubjectevents
%   tr: length of a single pulse
%   sessionLength: how many pulses did the recording have
%   minPulseratio: minimal portio of the pulse that the event should cover.
%       if the event say comes at time 8.9, for 

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

