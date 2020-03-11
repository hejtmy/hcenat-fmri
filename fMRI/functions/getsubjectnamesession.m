function [subjectName, session] = getsubjectnamesession(string)
%GETSUBJECTNAME Returns subject name and session from passed code
%
%PARAMETERS
%   string: hcenat code from the MRI. e.g. HCE_P00710_20160503_1522_1
%RETURNS:
%   subjectName: code of the subject, eg. P00710
%   session: session number (1 or 2)
[~, tok] = regexp(string, 'HCE_(.*?)_.+(\d+)', 'match', 'tokens');
if(numel(tok) > 0)
    subjectName = tok{1}{1};
    session = tok{1}{2};
end
end