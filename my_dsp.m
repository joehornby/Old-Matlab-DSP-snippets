close all
clear all

%
% Initialisation.
%

ditherType = 0; % 0 none, 1 RPDF, 2 TPDF.
shapeNoise = true; % true or false.

disp('Initialising functions...')

inFilename = 'BigYellowTaxi_Mono_10s.wav';
outFilename = 'output.wav';
quantLevels = 32;
[y,fs,nbits] = get_sample(inFilename);
inputSize = wavread(inFilename,'size');
put_sample(outFilename, fs, nbits);
noise_shaping_quantiser(quantLevels,ditherType,shapeNoise); 
% Quantiser initialised and contained in noise_shape.


%
% Processing.
%

profile on
profile clear

disp('Processing file...')

while isfinite(y)
    y = get_sample(inFilename);
    if isfinite(y)
        y(1,1) = noise_shaping_quantiser(y(1,1));
        try    % If Stereo.
            y(1,2) = noise_shaping_quantiser(y(1,2));
        catch exception
        end
    end
    put_sample(y);   % Final call (when y = NaN) - write wav file.
end

disp('Processing complete.')

profile report
profile off


%%
% Analysis.
%

disp('Analysing output...')

input = wavread(inFilename);
output = wavread(outFilename);
fftRes = 10;

pdfOut = probability_density_function(output,quantLevels);
xVals = linspace(-1,1,length(pdfOut));
figure
plot(xVals,pdfOut)

if inputSize(2) == 1
    [freq,hearingThresh,Pw_dB] = power_spectral_density(output-input,fs,fftRes);
    
    figure
    semilogx(hearingThresh(:,1),hearingThresh(:,2))
    hold on;
    semilogx(freq,Pw_dB);
    set(gca,'XLim',[20,20000],'XTick',[20,100,1000,20000],'XTickLabel',{'20 Hz','100 Hz','1 kHz','20 kHz'})
    grid on;
    legend('Threshold of Hearing', 'PSD of quantisation error');
    
elseif inputSize(2) == 2
    [freq,hearingThresh,Pw_dB_L,Pw_dB_R] = power_spectral_density(output-input,fs,fftRes);
    
    figure
    semilogx(hearingThresh(:,1),hearingThresh(:,3))
    hold on;
    semilogx(freq,Pw_dB_L,'k',freq,Pw_dB_R,'r');
    set(gca,'XLim',[20,20000],'XTick',[20,100,1000,20000],'XTickLabel',{'20 Hz','100 Hz','1 kHz','20 kHz'})
    grid on;
    legend('Threshold of Hearing','PSD: Left track quantisation error','PSD: Right track quantisation error');
end

disp('Anaylisis complete.')

%
% End.
%