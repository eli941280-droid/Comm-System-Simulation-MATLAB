clear all;
close all;
clc;

%% AM的调制及其解调

fs = 128;
dt = 1/fs;
t = 0: dt : 50;
NFFT = 2^16; %傅里叶变换点数
f = linspace(-fs/2, fs/2, NFFT);

%% 需要同学们自己生成调制信号、载波信号以及已调信号

fm=1;%信号的频率
s_m=cos(2*pi*fm*t); %基带信号
S_m=t2f(s_m,NFFT); %傅里叶变换

fc=10;%载波信号的频率
s_c=cos(2*pi*fc*t); %sin信号
S_c=t2f(s_c,NFFT); %傅里叶变换

s_AM = (1 + s_m) .* s_c;
S_AM = t2f(s_AM, NFFT);


%低通滤波
wc=3*2*pi*fm/fs;                        %解调器低通滤波器截止频率，3fm
lbf_hn=fir1(32,wc/pi);                     %低通滤波器系统函数，FIR滤波器
freqz(lbf_hn, 1, 1024, fs);

%% 需要同学自己编写相干解调


%% 需要同学自己编写非相干解调


%% 画图，至少需要呈现这些图，并能与DSB调制方式、SSB调制方式进行比较
figure;
subplot(3,2,1)
plot(t,s_m); grid on;
xlabel('t(s)')
title('调制信号')
xlim([0, 5]);
subplot(3,2,3)
plot(t,s_c); grid on;
xlabel('t(s)')
title('载波信号')
xlim([0, 5]);
subplot(3,2,5)
plot(t,s_AM);grid on;
xlabel('t(s)')
title('AM信号')
xlim([0, 5]);

subplot(3,2,2)
plot(f,abs(S_m));grid on;
xlabel('f(Hz)')
title('调制信号的幅度-频率特性')
xlim([-4 4]);
subplot(3,2,4)
plot(f,abs(S_c));grid on;
xlabel('f(Hz)')
title('载波信号的幅度-频率特性')
xlim([-15 15]);
subplot(3,2,6)
plot(f,abs(S_AM));grid on;
xlabel('f(Hz)')
title('AM信号的幅度-频率特性')
xlim([-15 15]);

%相干解调信号过程
figure;
subplot(2,2,1);
plot(t, s_cor_temp);grid on;
xlabel('t(s)');xlim([0, 10]);
title('相干解调通过乘法器后时域');
subplot(2,2,3);
plot(t, dem_cor_out);grid on;
xlabel('t(s)');xlim([0, 10]);
title('相干解调输出');
subplot(2,2,2);
plot(f, abs(S_cor_temp));grid on;
xlabel('f(HZ)');xlim([-25, 25]);
title('相干解调通过乘法器后频域');
subplot(2,2,4);
plot(f, abs(S_cor_out));grid on;
xlabel('f(HZ)');xlim([-10, 10]);
title('相干解调输出频域');

%非相干解调信号过程
figure;
subplot(2,2,1);
plot(t, s_uncor_temp);grid on;
xlabel('t(s)');xlim([0, 10]);
title('非相干解调通过乘法器后时域');
subplot(2,2,3);
plot(t, dem_uncor_out);grid on;
xlabel('t(s)');xlim([0, 10]);
title('非相干解调输出');
subplot(2,2,2);
plot(f, abs(S_uncor_temp));grid on;
xlabel('f(HZ)');xlim([-25, 25]);
title('非相干解调通过乘法器后频域');
subplot(2,2,4);
plot(f, abs(S_uncor_out));grid on;
xlabel('f(HZ)');xlim([-10, 10]);
title('非相干解调输出频域');
