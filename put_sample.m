function put_sample(y,fs,nbits,normalise)
%PUT_SAMPLE - Stores individual samples and writes to .wav file.
%
% Syntax:  
%       put_sample(filename,fs,nbits,normalise)   % First call.
%       put_sample(y)
%
% Inputs:
%    filename - name of .wav file to be created.
%    fs       - sample rate.
%    nbits    - number of bits (not levels) used to represent amplitude.
%    normalise- normalise before writing .wav (true or false).
%    y        - single sample to be added to the write buffer.
%
%
%
% See also: WAVWRITE,  GET_SAMPLE

% Author: Joe Hornby
% November 2009; Last revision: 05-Jan-2010

%------------- BEGIN CODE --------------


persistent FS FILENAME NBITS BUFFER INDEX SIZE CHUNKSIZE MONOSTEREO NORMALISE;

if isempty(CHUNKSIZE)
    if nargin ~= 3  &&  nargin ~= 4;
        error('Must first call function with 3 or 4 inputs.');
    end
    if ischar(y)
        CHUNKSIZE = 2^14;
        FILENAME = y;
        FS = fs;
        NBITS = nbits;
        INDEX = 0;
        SIZE = CHUNKSIZE;
        NORMALISE = normalise;
    end

else
    if nargin ~= 1
        error('Function requires 1 input argument.');
    else
        if isempty(BUFFER)
            if isnumeric(y)
                MONOSTEREO = size(y,2);
                BUFFER = zeros(SIZE,MONOSTEREO);
            else
                error('Must first initialise function.');
            end
        end
    end

    if ~isfinite(y)        
        % Delete excess elements from buffer, write to .wav file.
        BUFFER((INDEX+1):end,:) = [];
        
        % Normalise if required.
        if NORMALISE
            BUFFER = BUFFER./max(abs(BUFFER))*0.9;
        end
        
        % Write to .wav file.
        wavwrite(BUFFER,FS,NBITS,FILENAME);
        clear BUFFER;
    else
        INDEX = INDEX + 1;
        if INDEX > SIZE
            % Extend the buffer by CHUNKSIZE.
            BUFFER = [BUFFER; zeros(CHUNKSIZE,MONOSTEREO)];
            SIZE = SIZE+CHUNKSIZE;
        end
            BUFFER(INDEX,:) = y;
    end
end

%------------- END OF CODE --------------