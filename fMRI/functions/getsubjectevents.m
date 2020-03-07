function subjectData = getsubjectevents(eventData, subject)
%GETSUBJECTEVENTS Returns only a portion of passed events which correspond
%   to a given subject.
%   PARAMETERS:
%   eventData: Expects eventData to be in specific format with 
%   1x4 cell array of SubjectId, EventName, EventTime, EventDuration
iSubject = strcmp(eventData{1}, subject);

% Selects just subject portion of the dataset
subjectData = cellfun(@(x) x(iSubject), eventData, 'UniformOutput', false);

end

