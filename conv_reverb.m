function [ y ] = conv_reverb( x )
%CONV_REVERB Reverberator using convolution of real impulse response
%   Detailed explanation goes here

%Author: J E Hornby
%Last revision: April 2009

persistent H_OMEGA N_X N_FFT N_H BUFFER INDEX;

INDEX = 1;

if isfinite(x)
    
    if isempty(H_OMEGA) && nargin == 1      % Initialisation, x = IR.
        
        N_H = length(x);    % Length of IR.
        N_FFT = pow2(floor(log2(N_H))+1);   % Length of FFT.
        N_X = N_FFT - N_H + 1;   % Input signal block size.
        
        BUFFER = zeros((N_X + N_H -1),1);
        
        H_OMEGA = fft([x;zeros(N_X,1)],N_FFT);
        y = 0;
        
    elseif INDEX < N_X       % Fill buffer.
        
        BUFFER(INDEX) = x;
        INDEX = INDEX + 1;
        y = 0;
        
    elseif INDEX == N_X      % Subsequent calls to function.
        BUFFER(N_X) = x;
        
        x_omega = fft(BUFFER,N_FFT);
        f_result = ifft(H_OMEGA.*x_omega);
        
        BUFFER = BUFFER + f_result;
        
        y = BUFFER(1);
        
        BUFFER(1:end-1) = BUFFER(2:end); % Shift Buffer along.
        
    end
    
else % End of input: Output extra samples in reverb tail.
    INDEX = INDEX + 1;
    
    if INDEX <= length(BUFFER)
        y = BUFFER(INDEX);
    else
        y = NaN;
    end
end
end

