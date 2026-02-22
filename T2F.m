function [f,sf]= T2F(t,st)
T=t(end);
df = 1/T;
N = length(st);
f=-N/2*df : df : N/2 * df-df;
sf = fft(st);
sf = T/N * fftshift(sf);
