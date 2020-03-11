function subjectData = getsubjectevents(eventData, subject)
%GETSUBJECTEVENTS Returns only a portion of passed events which correspond
%   to a given subject.
%PARAMETERS:
%   eventData: Expects eventData to be in specific format with 
%       N x 3+ cell array of [subject, time, duration, optional columns...]
%       values
%   subject: subject code, usually extracted from MRI code with
%       getsubjectnamesession
iSubject = strcmp(eventData{1}, subject);
subjectData = cellfun(@(x) x(iSubject), eventData, 'UniformOutput', false);

end
