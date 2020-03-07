function hrfPointing = preparehrfpointing(pointingEvents, tr, ...
    sessionLength, minPulseRatio)
%PREPAREHRFPOINTING Summary of this function goes here
%   Detailed explanation goes here
%
%PARAMETERS
%   tr: length of a single pulse
%   sessionLength: how many pulses did the recording have
%   minPulseratio: minimal portio of the pulse that the event should cover
%   save: should the data be saved

    %% Pointing ----
    pointingTimes = geteventtimes(pointingEvents);
    pointingBlocks = eventtimestotrblocks(pointingTimes, tr, sessionLength);
    pointingBlocks = pointingBlocks > minPulseRatio;
    hrfPointing = convolveblockhrf(pointingBlocks, tr);
end

