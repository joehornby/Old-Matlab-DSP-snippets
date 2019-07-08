clear all
close all

infile = 'test.wav';
impulsefile = 'impulse_church.wav';


[x,fs] = wavread(infile);
h = wavread(impulsefile);


N_X = length(x);
N_H = length(h);
N_FFT = pow2(floor(log2(N_H))+1);

y=zeros(N_X+N_H-1,1);

H_OMEGA = fft([h;zeros(N_X,1)],N_FFT);


x_omega = fft([x;zeros(N_H-1,1)],N_FFT);
f_result = real(ifft(real(H_OMEGA).*real(x_omega),N_FFT));
        
y = y + f_result;

wavwrite(y,fs,'output_basic.wav');

plot (x)
figure
plot (h)

figure

plot (y)
