function [y,fs,nbits] = get_sample(filename)
%GET_SAMPLE - Returns next sample from WAV file.
% Reads a wav file and returns a single sample at a time to simulate
% real-time stream of samples. Returns NaN when there are no more samples.
%
% Syntax:  [y,fs,nbits] = get_sample(filename) % First call.
%           y = get_sample()    % Subsequent calls.
%
% Inputs:
%    filename - filename of input audio file (.wav).
%
% Outputs:
%    y     - single sample from wave file.
%    fs    - on first call, returns the sample frequency of the audio file.
%    nbits - on first call, returns the bit depth of the audio file.
%
% Example: 
%    [y,fs,nbits] = get_sample('test.wav');
%    while(isfinite(y))
%        y = get_sample();
%    end
%
% Subfunctions: WAVREAD
%
% See also: WAVREAD,  PUT_SAMPLE

% Author: Joe Hornby
% November 2009; Last revision: 06-Jan-2010

%------------- BEGIN CODE --------------

persistent BUFFER BUFFER_SIZE INDEX

if isempty(BUFFER)  % First time function is called.
    if nargin ~= 1
        error 'Must have only one input argument on first call.';
    else
        [BUFFER,fs,nbits] = wavread(filename);
        BUFFER_SIZE = wavread(filename, 'size');
        INDEX = 0;
        % Initialise y to mono or stereo size (find size of 2nd dimension).
        y = zeros(1,size(BUFFER,2));
    end
else                % Subsequent calls to function.
    if nargin ~= 0
        error 'Must have no input argument after first call.';
    else
        INDEX = INDEX+1;
        if INDEX > BUFFER_SIZE(1)
            y(1,1) = NaN;
        else
            y = BUFFER(INDEX,:);
        end
    end
end

%------------- END OF CODE --------------