function validData = filtervalidevents(eventData)
%FILTERVALIDEVENTS Returns valid event data. Primarily removes negative
%onsets and events and events which happen after recording ended (TODO!)
%   Detailed explanation goes here
iValid = eventData{2} > 0;
validData = cellfun(@(x) x(iValid), eventData, 'UniformOutput', false);
end

