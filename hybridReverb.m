clear all; close all;

% INITIALISATION.

wetdry = 0.1;   % Amount of reverb added to signal (0 - 1);

impulse_filename = 'impulse_digital.wav';
in_filename = 'claves.wav';
out_filename = 'output_claves_digital_half.wav';

h = wavread(impulse_filename);
[x,fs,nbits] = get_sample(in_filename);
put_sample(out_filename,fs,nbits,true);


N_h = length(h);
N_FFT = pow2(floor(log2(N_h))+1);
N_x = N_FFT - N_h + 1;

y_prev = zeros(N_h-1,1);
y = zeros((N_x + N_h - 1),1);
H_omega = fft([h;zeros(N_x,1)],N_FFT);
loop = true;
conv_result = zeros((N_x + N_h - 1),1);

% FDN Initialisation.

M = [971 977 983 991]; % Delay lengths for each comb filter.

delay1 = zeros(M(1),1);
delay2 = zeros(M(2),1);
delay3 = zeros(M(3),1);
delay4 = zeros(M(4),1);


profile off
profile on

while loop    

    y = zeros((N_x + N_h - 1),1);   % Reset input and output to zeros.
    x = y;

    % Fill input buffer.
    i = 1;
    while i <= N_x  &&  loop
        x(i) = get_sample();
        if ~isfinite(x(i))
            x(i) = 0;   % Set end of file to 0 to avoid lots of NaN in y.
            loop = false;
        end
        i = i + 1;
    end
    
    conv_result = wetdry .* ifft( fft([x;zeros(N_h,1)],N_FFT) .* H_omega);
    
    y = x + conv_result;    % Add reverb to input. (Wet/Dry mix included in conv_result).
    y(1:N_h-1) = y(1:N_h-1) + y_prev;   % Add previous reverb tail to output. (Overlap add).
    y_prev = y(N_x+1:N_x+N_h-1);    % Store tail for next iteration.
    
    
    %
    % FDN - Late reflections
    %
    

    
    %%%%%%% End of FDN.
    
    if ~loop
        for i = 1:N_x
            put_sample(y(i))
        end
        for i = 1:N_h-1     % add reverb tail onto output buffer.
            put_sample(y_prev(i))
        end
        put_sample(NaN)     % Write wav.
    else
        for i = 1:N_x
            put_sample(y(i))
        end
    
    end
    
        
end

profile viewer

plot(wavread(out_filename))
