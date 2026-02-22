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

%% ==========================================================
%  以下为新增的“实验扩展”代码
%  依据：《通信原理》实验指导书 实验扩展部分 (Page 16)
%  ==========================================================

%% 8. 扩展实验一：验证卡森公式 (Carson's Rule)
% 卡森公式: B = 2 * (mf + 1) * fm
% 目的: 观察宽带FM (WBFM) 的频谱分布，验证绝大部分能量是否在带宽内。

% 设置新的参数: 增大调频指数 mf 到 5
mf_ext = 5; 
% 生成新的已调信号 (WBFM)
sft_wbfm = Ac * cos(2*pi*fc*t + mf_ext * sin(2*pi*fm*t));

% 计算频谱
[f_ext, F_wbfm] = T2F(t, sft_wbfm);

% 计算理论带宽边界
B_Carson = 2 * (mf_ext + 1) * fm;  % B = 2 * (5+1) * 5 = 60 Hz
f_lower = fc - B_Carson/2;         % 下边界 50 - 30 = 20 Hz
f_upper = fc + B_Carson/2;         % 上边界 50 + 30 = 80 Hz

figure(6);
plot(f_ext, abs(F_wbfm), 'b', 'LineWidth', 1); hold on;
% 绘制红色虚线标示卡森带宽范围
xline(f_lower, '--r', 'LineWidth', 1.5);
xline(f_upper, '--r', 'LineWidth', 1.5);
xline(-f_lower, '--r', 'LineWidth', 1.5); % 负频率对应部分
xline(-f_upper, '--r', 'LineWidth', 1.5);

axis([-100 100 0 max(abs(F_wbfm))*1.2]);
xlabel('频率 f (Hz)');
title(['扩展实验1: 验证卡森公式 (mf=5, 理论带宽=' num2str(B_Carson) 'Hz)']);
legend('实际频谱', '卡森带宽边界');
grid on;

%% 9. 扩展实验二：载波零点现象 (Bessel Zero)
% 目的: 验证当 mf = 2.405 时，载波分量 J0(mf) 消失
% 这是 Bessel 函数的一个特性，常用于测量频偏。

mf_zero = 2.405; % 第一类贝塞尔函数 J0 的第一个零点
sft_zero = Ac * cos(2*pi*fc*t + mf_zero * sin(2*pi*fm*t));

% 计算频谱
[f_zero, F_zero] = T2F(t, sft_zero);

figure(7);
plot(f_zero, abs(F_zero), 'k'); hold on;
% 标记载波频率位置 (50Hz)
stem(fc, max(abs(F_zero))/5, 'r', 'filled'); 
text(fc+2, max(abs(F_zero))/5, '\leftarrow 载波分量幅度接近0', 'Color', 'red');

axis([0 100 0 max(abs(F_zero))*1.2]);
xlabel('频率 f (Hz)');
title(['扩展实验2: 载波消隐现象 (mf = ' num2str(mf_zero) ')']);
grid on;

%% ==========================================================
%  补充函数定义 (为了确保脚本能独立运行，在此处定义 T2F)
%  ==========================================================
function [f, S] = T2F(t, s)
    % 输入: t (时间向量), s (信号向量)
    % 输出: f (频率向量), S (频谱幅度)
    dt = t(2) - t(1);
    T = t(end) - t(1) + dt;  % 信号总时长
    N = length(s);           % 采样点数
    
    % 使用 fft 并通过 fftshift 将零频移到中心
    S = fftshift(fft(s)) * dt; 
    
    % 生成频率轴 (双边谱)
    fs = 1/dt;
    f = linspace(-fs/2, fs/2, N);
end