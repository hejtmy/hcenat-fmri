function trblocks = eventtimestotrblocks(eventTimes, tr, sessionLength)
%TIMEINTOTRBLOKCS This function takes times and TR time and converts events
%   into a vector of percentage of tr that the event took place
% PARAMETERS
%   eventTimes: 2D matrix with [startTime, endTime], nrow is the numebr of
%   events
%   tr: time of a single block
%   sessionLength: number of TR blocks which were in a single session
% RETURNS
%   vector of length session length with a number between 0-1, defiining
%   percentage of the TR that the event was happening. e.g. [0,0.5,1,0.2,0]
%   would say that the event wasn't happening in the first block, happened
%   for half the time of the second, full time of the third and 20 percent
%   of the 4th block.

iHappenedDuringSession = all(eventTimes < (tr * (sessionLength-1)), 2);
eventTimes = eventTimes(iHappenedDuringSession, :);

trblocks = zeros(sessionLength, 1);
startPulses = round(eventTimes(:,1)/tr - mod(eventTimes(:,1),tr)/tr);
startProportions = 1 - mod(eventTimes(:,1),tr)/tr;
endPulses = round(eventTimes(:,2)/tr - mod(eventTimes(:,2),tr)/tr);
endProportions = mod(eventTimes(:,2),tr)/tr;

for i = 1:numel(startPulses)
    trblocks(startPulses(i):(endPulses(i)-1)) = 1;
end

trblocks(startPulses) = startProportions;
% situation when participants both stops and starts in the same pulse
trblocks(endPulses) = trblocks(endPulses) + endProportions;

end
