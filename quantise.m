function [output] = quantise(x)
%QUANTISE - Quantises input sample to 32 levels (mid-rise).
%   Mid-rise quantiser (no zero level)
%   
%   First call to function:
%       quantise(numLevels)
%
%   Subsequent calls:
%       quantise(sample)
%
%   numLevels - quantisation levels.
%   sample - floating point sample value between -1 and 1.
%
%   output - quantised sample value between -1 and 1.
%
%   Example:
%    quantise(32);
%    quantise(pi/10)    =
%
%           0.3750
%
% Subfunctions: ROUND
%
% See also: ROUND,  QUANTISE_NOISESHAPER

% Author: Joe Hornby
% November 2009; Last revision: 20-Dec-2009

%------------- BEGIN CODE --------------
persistent NUMLEVELS;

if isempty(NUMLEVELS)
    if nargin == 1 && x>0
        NUMLEVELS = x;
        return;
    else
        error('Incorrect input argument. Must have 1 positive integer argument on first call (number of levels).');
    end
else
    if nargin == 1
        % Limit input (more efficient than if statements).
        x = min(x, 1-1/NUMLEVELS);
        x = max(x,-1);
        
        % Round input using floor: round toward -ve infinity.
        output = (floor(NUMLEVELS/2 * x) + 0.5) / (NUMLEVELS/2);
    else
        error('Must have one floating point input after first call.');
    end
end

%------------- END OF CODE --------------