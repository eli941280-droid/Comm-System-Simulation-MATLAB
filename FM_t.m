clear all;
close all;
clc;

%% 参数设置 
Am = 5;         % 调制信号幅度
fm = 5;         % 调制信号频率
fc = 50;        % 载波频率
mf = 2;        % 调频指数
Ac = 1;         % 载波幅度 

dt = 0.005;     % 设定步长
t = 0:dt:3;     % 时间序列

%% 生成调制信号、载波信号以及已调信号
% 调制信号 m(t) = Am * cos(2*pi*fm*t)
mt = Am * cos(2*pi*fm*t); 

% 载波信号 c(t) = Ac * cos(2*pi*fc*t)
ct = Ac * cos(2*pi*fc*t);

% FM已调信号 s(t) = Ac * cos(2*pi*fc*t + mf*sin(2*pi*fm*t)) 
sft = Ac * cos(2*pi*fc*t + mf * sin(2*pi*fm*t));

%% 绘制三类信号的时域图 
figure(1) 
subplot(311);
plot(t, mt);
axis([0 1 -5.1 5.1]); % 根据调制信号幅度调整坐标轴
xlabel('t (s)');
title('调制信号时域图');
grid on;

subplot(312);
plot(t, ct);
axis([0 1 -1.1 1.1]);
xlabel('t (s)');
title('载波时域图');
grid on;

subplot(313);
plot(t, sft);
axis([0 1 -1.1 1.1]);
xlabel('t (s)');
title('已调信号时域图 (无噪声)');
grid on;

%% 绘制调制信号与已调信号的频域图
% 调用子函数 T2F 
[f1, fmm] = T2F(t, mt);
[f2, Fm] = T2F(t, sft);

figure(2)
subplot(211);
plot(f1, abs(fmm));
axis([-40 40 0 max(abs(fmm))]);
xlabel('f (Hz)');
title('调制信号频谱');
grid on;

subplot(212);
plot(f2, abs(Fm));
axis([-80 80 0 max(abs(Fm))]);
xlabel('f (Hz)');
title('已调信号频谱');
grid on;

%% 绘制无噪声情况下的对比 
figure(3)
subplot(2,1,1);
plot(t, mt);
xlabel('时间 t');
title('调制信号的时域图');
grid on;

subplot(2,1,2);
plot(t, sft);
xlabel('时间 t');
title('无噪声条件下已调信号的时域图');
grid on;

%% 6. 小信噪比 (10dB) 条件下的信号处理
SNR_small = 10; % dB
% sigma^2 = A^2 / (2 * 10^(B/10)), 这里 B 即为 SNR
sigma_small = sqrt(Ac^2 / (2 * 10^(SNR_small/10))); 
noise_small = sigma_small * randn(size(t)); % 生成高斯白噪声 
sft_small_noise = sft + noise_small;        % 叠加噪声

figure(4);
subplot(2,1,1);
plot(t, mt);
axis([0 3 -5.1 5.1]);
xlabel('时间 t');
title('调制信号的时域图');
grid on;

subplot(2,1,2);
plot(t, sft_small_noise);
xlabel('时间 t');
title(['含小信噪比 (' num2str(SNR_small) 'dB) 高斯白噪声已调信号的时域图']);
grid on;

%% 7. 大信噪比 (40dB) 条件下的信号处理 
SNR_large = 40; % dB
% 计算噪声标准差
sigma_large = sqrt(Ac^2 / (2 * 10^(SNR_large/10)));
noise_large = sigma_large * randn(size(t));
sft_large_noise = sft + noise_large;

figure(5);
subplot(2,1,1);
plot(t, mt);
axis([0 3 -5.1 5.1]);
xlabel('时间 t');
title('调制信号的时域图');
grid on;

subplot(2,1,2);
plot(t, sft_large_noise);
axis([0 3 -1.5 1.5]);
xlabel('时间 t');
title(['含大信噪比 (' num2str(SNR_large) 'dB) 高斯白噪声已调信号的时域图']);
grid on;