function eventTimes = geteventtimes(eventData, eventName)
%GETEVENTTIMES Returns 2D matrix of eventStart and eventEnd times. Filters
%   for specific events if eventName is passed
%   
%   PARAMETERS:
%   eventData: Expects eventData to eb in specific format with 1x4 cell array
%       of SubjectId, EventTime, EventDuration, EventName.
%   eventName: optional parameter defining name of the event in the 4th
%       column
% Validate the eventData
if ~all(size(eventData) == [1,4])
    warning('The event data has unexpected dimensions');
    return; 
end
if(nargin == 2)
    iEvent = strcmp(eventData{4}, eventName);
else
    iEvent = 1:numel(eventData{2});
end
eventTimes = [eventData{2}(iEvent), ...
    eventData{2}(iEvent) + eventData{3}(iEvent)];
end

