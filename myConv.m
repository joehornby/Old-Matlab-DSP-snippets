clear all; close all;

% INITIALISATION.

wetdry = 1;   % Amount of reverb added to signal (0 - 1);
T_60 = [10];   % Reverb time in seconds. **Leave blank [] to use unaltered IR.


impulse_filename = 'impulse_SLucia.wav';
in_filename = 'claves.wav';
out_filename = ['output_claves' datestr(clock) '.wav'];

h = wavread(impulse_filename);
[x,fs,nbits] = get_sample(in_filename);
put_sample(out_filename,fs,nbits,true);


N_h = length(h);
N_FFT = pow2(floor(log2(N_h))+1);
N_x = N_FFT - N_h + 1;

% Apply envelope to IR if desired T_60 is shorter than IR.
if ~isempty(T_60)   % If a value is given for desired T_60.
    if T_60*fs >= N_h  % Check it is within the limits of the IR.
        warning('Desired reverb time longer than impulse response. No changes made.')
    else    % If all is well, alter the IR.
        h = h .* (exp(-(1:N_h)./(T_60*fs)))';
    end
end

y_prev = zeros(N_h-1,1);    % Used to store previous convolution tail (overlap-add).
y = zeros((N_x + N_h - 1),1);           % Initialise to vector of zeros.
conv_result = zeros((N_x + N_h - 1),1); % "
H_omega = fft([h;zeros(N_x,1)],N_FFT);  % FFT of IR for frequency domain multiplication.
loop = true;    % Used to determine when to stop looping.


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
    
    y = (1-wetdry).*x + conv_result;    % Add reverb to input. (Wet/Dry mix included in conv_result).
    y(1:N_h-1) = y(1:N_h-1) + y_prev;   % Add previous reverb tail to output. (Overlap add).
    y_prev = y(N_x+1:N_x+N_h-1);    % Store tail for next iteration.
    
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
