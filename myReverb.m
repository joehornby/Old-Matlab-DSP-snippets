clear all
close all

% Initialisation.

[impulse_response,fs_IR,nbits_IR]= wavread('impulse.wav');
% conv_reverb(impulse_response);

wavwrite([zeros(1000,1); 1; zeros(10000,1);1;zeros(50000,1)],fs_IR,nbits_IR,'test01.wav');

infilename = 'test01.wav';
[BUFFER,fs,nbits] = get_sample(infilename);

outfilename = 'reverbOutput.wav';
put_sample(outfilename,fs,nbits);

N_H = length(impulse_response);    % Length of IR.
N_FFT = pow2(floor(log2(N_H))+1);   % Length of FFT.
N_X = N_FFT - N_H + 1;   % Input signal block size.
index = 1;
BUFFER = zeros((N_X + N_H -1),1);
H_OMEGA = fft([impulse_response;zeros(N_X,1)],N_FFT);


profile on


% Reverberation.

while(isfinite(BUFFER(1)))
    
    if index < N_X  &&  all(isfinite(BUFFER))       % Fill buffer.
        
        BUFFER(index) = get_sample();
        index = index + 1;
        
    elseif index == N_X      % When buffer is full.
        BUFFER(N_X) = get_sample();     % Update only last sample.
        
        x_omega = fft(BUFFER,N_FFT);    % Convolve x and h in freq domain.
        f_result = ifft(H_OMEGA.*x_omega);
        
        BUFFER = BUFFER + f_result;
        
        put_sample(BUFFER(1));
        
        BUFFER(1:end-1) = BUFFER(2:end); % Shift Buffer along.
        
    elseif any(~isfinite(BUFFER))       % If input has stopped.
        x_omega = fft(BUFFER,N_FFT);    % Convolve x and h in freq domain.
        f_result = ifft(H_OMEGA.*x_omega);
        BUFFER = BUFFER + f_result;
        put_sample(BUFFER(1));
        BUFFER(1:end-1) = BUFFER(2:end);
    end
end

% % Reverberation.
% while (isfinite(output))
%     if isfinite(x)
%         x = get_sample();
%         output = conv_reverb(x);
%     else
%         output = conv_reverb(NaN);
%     end
%     
%     put_sample(output);
% end


% Analysis
profile viewer

reverb_result = wavread(outfilename);
input = wavread(infilename);

plot(impulse_response)
figure
plot(reverb_result)
figure
plot(input)