function [output] = probability_density_function(input,nLevels)
%PROBABILITY_DENSITY_FUNCTION - Returns probability of values being used.
%
% Syntax:  output = probability_density_function(input,nLevels)
%
% Inputs:
%    input   - array of values to be analysed.
%    nLevels - number of quantisation levels used to represent amplitude of 
%              input data (2^numBits).
%
% Outputs:
%    output - array of probability densities, of same length as input.

% Author: Joe Hornby
% October 2009; Last revision: 03-Jan-2010

%------------- BEGIN CODE --------------

if nargin ~= 2
    error('Must have 2 inputs: input,numLevels.');
end

% Remove zeros from input.
input = input(input ~= 0);
input_size = length(input);

% Make input a positive integer (for index).
input_int = (input .* nLevels/2) + (nLevels/2 + 0.5);
% clear input;

% Initialise input count array.
input_count = zeros(nLevels,1);

for i = 1:length(input_int)
    % Count the number of times values occur by using input as index.
    if input_int(i) - fix(input_int(i)) == 0  % Check that all indices are integers.
        input_count(input_int(i)) = input_count(input_int(i)) + 1;
    else
        warning(['Index ' num2str(i) ' of input_int not an integer. Value = ' num2str(input_int(i)) ])
    end
end

% Probability density.
output = input_count./input_size;

%------------- END OF CODE --------------

end     % End of function.