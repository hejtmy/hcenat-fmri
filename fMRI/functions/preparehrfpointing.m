function hrfPointing = preparehrfpointing(pointingEvents, tr, ...
    sessionLength, minPulseRatio)
%PREPAREHRFPOINTING This function prepares HRF for poining events
%
%PARAMETERS
%   pointingEvents: events as exported by getsubjectevents for pointing
%   tr: length of a single pulse
%   sessionLength: how many pulses did the recording have
%   minPulseratio: minimal portio of the pulse that the event should cover

    %% Pointing ----
    pointingTimes = geteventtimes(pointingEvents);
    pointingBlocks = eventtimestotrblocks(pointingTimes, tr, sessionLength);
    pointingBlocks = pointingBlocks > minPulseRatio;
    hrfPointing = convolveblockhrf(pointingBlocks, tr);
end

