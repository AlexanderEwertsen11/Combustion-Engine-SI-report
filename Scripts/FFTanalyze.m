function [f,fftp] = FFTanalyze(p,fsample)
% 
% FFT analysis of cylinder pressure curves (or other signals).
%
% p: vector or matrix with collumnwise pressure data.
% fsample: sample frequency in 1/s
% f: frequencies of the spectra in Hz.
% fftp: peak to peak amplitude of the spectra with same units as p.
%

[L,W] = size(p);
hamm = repmat(blackman(L,'periodic'),[1 W]);
p = hamm.*p;

NFFT = 2^(nextpow2(L)+4); % Next power of 2 from length of y
fftp = fft(p,NFFT)/L;
fftp = 4*abs(fftp(1:NFFT/2,:));
f = fsample/2*linspace(0,1,NFFT/2)';