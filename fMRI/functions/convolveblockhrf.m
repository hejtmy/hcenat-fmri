function hrfconv = convolveblockhrf(trblocks, tr)
%CONVOLVEBLOCKHRF Convolve the blocks of 0s and 1s with hrf function. 
%   PARAMETERS
%   trblokcs: a series of 0s and 1s defining if the event was happening at
%   the given block or not
%   tr: length fo the block
%   
    hrf = spm_hrf(tr); % (SPM Toolbox required) create hrf function 
    hrfconv = conv(trblocks, hrf);
    % cut off the end (resulting time series are longer after convolution)
    hrfconv = hrfconv(1:length(trblocks));
end

