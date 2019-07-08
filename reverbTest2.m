clear all; close all;

% INITIALISATION.


impulse_filename = 'impulse_church.wav';
in_filename = 'test.wav';
out_filename = 'output_test.wav';

h = wavread(impulse_filename);
[x_buffer,fs,nbits] = get_sample(in_filename);
put_sample(out_filename,fs,nbits);

i = 1;
N_h = length(h);
N_FFT = pow2(floor(log2(N_h))+1);
N_x = N_FFT - N_h + 1;

x_buffer = zeros((N_x + N_h -1),1);
y = zeros((N_x + N_h -1),1);
H_omega = fft([h;zeros(N_x-1,1)],N_FFT);


% REVERB: Overlap-Discard method.

while isfinite(y)
    sample = 1;
    while sample <= N_x     % Fill buffer up to point N_x.
        x_buffer(sample) = get_sample();
        sample = sample + 1;
    end
    
    while i<=N_x
        index = min(i+N_FFT-1,N_x);
        
        conv_result = ifft( fft(x_buffer(1:index),N_FFT) .* H_omega, N_FFT);
        
        y(i:i+N_FFT-N_h) = conv_result(N_h:N_FFT);
        
        for k = 1:N_FFT-N_h
            put_sample(y(k));
        end
        
        i = i + N_FFT - N_h + 1;
    end
end