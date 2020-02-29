function [subjectName, session] = getsubjectnamesession(string)
%GETSUBJECTNAME Returns subject name from passed code
%   Detailed explanation goes here
[~, tok] = regexp(string, 'HCE_(.*?)_.+(\d+)', 'match', 'tokens');
if(numel(tok) > 0)
    subjectName = tok{1}{1};
    session = tok{1}{2};
end
end