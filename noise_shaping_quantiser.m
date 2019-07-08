function [output,noise] = noise_shaping_quantiser(x,ditherType,shapeNoise) % x is number of levels (first call) and sample (subsequent calls).
%NOISE_SHAPE - Quntises input and shapes noise, with optional dither.
%
%
% Syntax:  
%   Initialisation (First Call to Function)
%       noise_shape(numLevels,ditherType,shapeNoise)
%
%   Subsequent Calls to Function
%       [output,noise] = noise_shape(sample)
%
%   NOTE: for stereo signals, use one call of the function for each track
%         (L & R) to give different noise on Left and Right channel.
%
% Inputs:
%    sample     - Floating point sample value between -1 and 1.
%    numLevels  - Number of quantisation levels (positive integer).
%    ditherType - 0 for no dither
%                 1 for rectangular pdf dither, 
%                 2 for triangular pdf dither.
%    shapeNoise - true for noise-shaping
%                 false for no noise-shaping.
%
% Outputs:
%    output - Quantised sample with selected dither and noise-shaping.
%    noise - Quantisation noise without signal.
%
%
% See also: QUANTISE

% Author: Joe Hornby
% November 2009; Last revision: 29-Dec-2009

%------------- BEGIN CODE --------------

persistent ZMINUS1...
    ZMINUS2...
    ZMINUS3 ZMINUS4 ZMINUS5...
    SHAPENOISE...
    NLEVELS...
    DITHER...
    A1...
    A2...
    A3 A4 A5;


% INITIALISATION

if isempty(NLEVELS)
    if nargin ~= 3
        error('Three arguments required on first call to function: numLevels, ditherType, shapeNoise. See Help for details.');
    elseif isfinite(x) && ditherType >= 0 && ditherType <= 2 && islogical(shapeNoise)
        % Initialise values.
        SHAPENOISE = shapeNoise;
        ZMINUS1 = 0;
        ZMINUS2 = 0;
        ZMINUS3 = 0;
        ZMINUS4 = 0;
        ZMINUS5 = 0;
        NLEVELS = x;
        DITHER = ditherType;
        A1 = 2.033;%1.726;%1.652; % 1.537;     % Values according to Lipshitz (***Change Value***).
        A2 = -2.165;%-0.7678;%-1.049; %-0.8367;   % Try higher order (A3, A4..). Which is best? Limit?
        A3 = 1.959;%-0.2709;%0.1382;
        A4 = -1.590;
        A5 = 0.6149;
        quantise(NLEVELS);  % Initialise quantiser.
        return;
    else
        error('Number of levels must be a number. Dither type must be 0 (off), 1 (triangluar pdf) or 2 (rectangular pdf). shapeNoise must be either true or false.');
    end

else
    if nargin == 1
        if SHAPENOISE == true
            quantInput = x - (A1 * ZMINUS1 + A2 * ZMINUS2 + A3 * ZMINUS3+A4*ZMINUS4+A5*ZMINUS5);
%             quantInput = x - (A1 * ZMINUS1 + A2 * ZMINUS2);
        else
            quantInput = x;
        end
        
        if DITHER == 1  % Rectangular pdf.
            ditherNoise = (rand - 0.5) / (NLEVELS / 2);    % Dither peak-peak amplitude equal to LSB.
            quantInput = quantInput + ditherNoise;
        
        elseif DITHER == 2  % Triangular pdf.
            ditherNoise = (rand - rand) / (NLEVELS / 2);   % Dither peak-peak amplitude equal to 2*LSB.
            quantInput = quantInput + ditherNoise;
        end
        
        output = quantise(quantInput);
        noise = output - x;
        
        ZMINUS5 = ZMINUS4;
        ZMINUS4 = ZMINUS3;
        ZMINUS3 = ZMINUS2;
        ZMINUS2 = ZMINUS1;
        ZMINUS1 = output - quantInput; 
    else
        error('Must have one argument after initialisation. See Help for details.');
    end
end

%------------- END OF CODE --------------
