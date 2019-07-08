clear all;close all;

%% INITIALISATION.

impulse_filename = 'impulse_church.wav';
[impulse_response,fs_IR,nbits_IR]= wavread(impulse_filename);

% wavwrite([zeros(1000,1); 1; zeros(10000,1);1;zeros(50000,1)],fs_IR,nbits_IR,'test01.wav');

infilename = 'test.wav';
[BUFFER,fs,nbits] = get_sample(infilename);

outfilename = 'output_test.wav';
put_sample(outfilename,fs,nbits);

N_H = length(impulse_response);    % Length of IR.
N_FFT = pow2(floor(log2(N_H))+1);   % Length of FFT.
N_X = N_FFT - N_H + 1;   % Input signal block size.
impulse_response = [impulse_response;zeros(N_X-1,1)];
INDEX = 1;
BUFFER = zeros((N_X + N_H -1),1);
H_OMEGA = fft(impulse_response(:,1),N_FFT);
out_buffer = 0;


profile on


%% REVERB BUFFER.
while (isfinite(BUFFER(1)))
    if INDEX < N_X  &&  all(isfinite(BUFFER))
        % Is buffer full yet, and is there still samples being input (no
        % NaN)?
        
        BUFFER(INDEX) = get_sample();
        INDEX = INDEX + 1;
        
        
    elseif INDEX == N_X  &&  all(isfinite(BUFFER))
        % If buffer is full, and there are still samples.
        BUFFER(N_X) = get_sample();
        
        x_omega = fft(BUFFER, N_FFT);
        conv_result = ifft(x_omega.*H_OMEGA);
        
        out_buffer = out_buffer + conv_result;
        
        put_sample(out_buffer(1))
        
        % Shift Buffer along.
        BUFFER(1:end) = [BUFFER(N_X:end);zeros(N_X-1,1)];
        out_buffer(1:end) = [out_buffer(N_X:end);zeros(N_X-1,1)];
        
    elseif any(~isfinite(BUFFER))
        % If Samples have run out (NaN present in Buffer).
        
        for i = 1:INDEX
            x_omega = fft(BUFFER, N_FFT);
            conv_result = ifft(x_omega.*h_omega);
            
            out_buffer = out_buffer + conv_result;
            
            % output each sample, including NaN - this will write .wav within
            % put_sample().
            put_sample(out_buffer(1));
            
            % Shift Buffer along.
            BUFFER(1:end) = [BUFFER(N_X:end);zeros(N_X-1,1)];
            out_buffer(1:end) = [out_buffer(N_X:end);zeros(N_X-1,1)];
        end
    end
end


%% ANALYSIS.

profile viewer

in = wavread(infilename);
figure
plot(in)

out = wavread(outfilename);
figure
plot(out)


