function [Fw,thresh,Pw_dB,Pw2_dB] = power_spectral_density(X,FS,fRes)
%POWER_SPECTRAL_DENSITY - Average squared magnitude of input frequency spectrum.
% Takes 32 averages of the input frequency spectrum magnitudes.
%
% Syntax:     [f,thresh_dB,P_dB_L,P_dB_R] = power_spectral_density(X,FS,fRes)
%
% Inputs:
%    X     - array of samples to be analysed.
%    FS    - sample frequency (sample rate) of data.
%    fRes  - frequency resolution (spacing between frequency points
%            in fourier transform (Optional input, 10 Hz default).
%
% Outputs:
%    f     - array of frequency values.
%    thresh_dB - array of hearing thresholds for comparison to shaped noise.
%    P_dB_L - array of Powers for mono track or left channel of stereo.
%    P_dB_R - array of Powers for right channel (if stereo).
%
% Required files: 'Threshold.csv'
%
% See also: PSD,  SPECTRUM

% Author: Joe Hornby
% November 2009; Last revision: 07-Jan-2010

%------------- BEGIN CODE --------------

if nargin == 2
    fRes = 10;
elseif nargin ~= 3
    error('Incorrect number of arguments. Must have 2 or 3 inputs - see help.');
elseif FS <= 1
    error('Sample rate must be positive integers.');
end

% Num points in FFT.
NFFT = FS/fRes;
overlap = 50; % Per cent.
windowLength = floor(length(X) / (33 * overlap/100) );


h = spectrum.welch('Hann', windowLength, overlap); % Instantiate handle object (h).

% Reference spectrum (for dB measurements).
noise = 2*rand(size(X))-1;
hpsd = psd(h, noise, 'NFFT', NFFT, 'FS', FS);
ref = mean(hpsd.data);
clear noise;
% Reference = quantised rectangular pdf noise at full-scale quant output.
% End of Reference calculation.

% Threshold of hearing.
thresh = dlmread('Threshold2.csv',',');

% PSD of input.
hpsd = psd(h, X(:,1), 'NFFT', NFFT, 'FS', FS);
% (hpsd = spectrum object.)

Fw = hpsd.Frequencies;  % Frequencies of data points
Pw = hpsd.Data; % Average Power spectral density
Pw_dB = 10 * log10(Pw/ref);   

% If stereo input.
if size(X,2) == 2
    hpsd2 = psd(h, X(:,2), 'NFFT', NFFT, 'FS', FS);
    Pw2 = hpsd2.Data;
    Pw2_dB = 10 * log10((Pw2)^2 / ref);
end

%------------- END OF CODE --------------
end     % End of function.
