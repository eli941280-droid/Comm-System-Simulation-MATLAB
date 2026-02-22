clear;
close all;
% 仿真参数
fc = 1000;
Rb = 100;
fs = 8000;
ts = 1/fs;

% 基带信号生成
info = randi([0,1],1,10000);  % 产生待发送的二进制序列

info_map = info*2-1;   % 转化成双极码

sm_rect = rectpulse(info_map,80);           % 矩形脉冲



% BPSK 信号生成
t1 = (0:length(sm_rect)-1)*ts;

sc1 = cos(2*pi*fc*t1);                % 高频载波
%% 请实现 BPSK 信号生成
s_bpsk_rect = sm_rect .* sc1;         % BPSK信号产生
 

% Time-domain Waveforms
figure();
subplot(3,1,1);
plot(t1,sc1);
title('高频载波 ');
xlabel('时间 (s)');
axis([0.02 0.08 -1.5 1.5]);

subplot(3,1,2);
plot(t1,sm_rect);
title('矩形脉冲基带信号');
xlabel('时间 (s)');
axis([0.02 0.08 -1.5 1.5]);

subplot(3,1,3);
plot(t1,s_bpsk_rect);
title('BPSK调制信号');
xlabel('时间(s)');
axis([0.02 0.08 -1.5 1.5]);



% 带通滤波
wc_bpf = [2*pi*(fc-Rb)/fs, 2*pi*(fc+Rb)/fs];
bpf_hn = fir1(256, wc_bpf/pi);                % 带通滤波器设计

figure();
[h,w]=freqz(bpf_hn, 1, 4096);	
subplot(2,1,1);
plot(w*fs/(2*pi),20*log10(abs(h)),'r'); 
title('BPF频率响应');
xlabel('频率 (Hz)');
axis([400 1600 -120 10]);
grid on;

s_bpsk_bpf = filter(bpf_hn, 1, s_bpsk_rect);  % 滤波
subplot(2,1,2);
plot(t1,s_bpsk_bpf);
title('经过带通滤波器的BPSK信号');
xlabel('Time (s)');
axis([0.02 0.08 -1.5 1.5]);


fft_n = 2^nextpow2(length(s_bpsk_bpf));
SPSK_f = fftshift(fft(s_bpsk_rect,fft_n));

figure();
fHz=(-fft_n/2: fft_n/2-1)/fft_n*fs;
subplot(2,1,1);
plot(fHz,abs(SPSK_f));
% axis([400 1600 0 800]);
% axis([0 fs/2 0 800]);
grid on;
title('BPSK信号频率特性');
xlabel('频率 (Hz)');

SPSK_bpf_f = fftshift(fft(s_bpsk_bpf,fft_n));
fHz=(-fft_n/2: fft_n/2-1)/fft_n*fs;
subplot(2,1,2);
plot(fHz,abs(SPSK_bpf_f));
% axis([400 1600 0 800]);
% axis([0 fs/2 0 800]);
grid on;
title('经过带通滤波器的BPSK信号频率特性');
xlabel('频率 (Hz)');


%% 请实现相干解调原理
% 乘以载波
s_mul = s_bpsk_bpf .* (2*cos(2*pi*fc*t1));

figure()
wc = 2*2*pi*Rb/fs;
lbf_hn = fir1(32,wc/pi);               % 低通滤波器
[h,w]=freqz(lbf_hn, 1, 4096);												
plot(w*fs/(2*pi),20*log10(abs(h)),'r'); 
title('低通滤波器频率响应');
xlabel('频率(Hz)');
axis([0 1500 -120 10]);
grid on;

s_lpf = filter(lbf_hn, 1, s_mul);      % 低通滤波

figure();
subplot(2,1,1);
plot(t1(1:1200),sm_rect(1:1200)/2,'-r','LineWidth',2);
axis([0 0.15 -0.8 0.8]);
title('矩形脉冲基带信号');
xlabel('Time (s)');
grid on;

subplot(2,1,2);
plot(t1(1:1200),s_lpf(1:1200),'-b');
axis([0 0.15 -0.8 0.8]);
title('解调的基带信号');
xlabel('Time (s)');
grid on;

%% 扩展1：滚降脉冲成形 (替换原本的 rectpulse 部分)
% 参数定义 (保持原有 fs, Rb)
sps = fs / Rb; % 每个符号的采样点数 (8000/100 = 80)
rolloff = 0.5; % 滚降系数 (alpha)，可设为 0 ~ 1
span = 6;      % 滤波器截断符号数

% 设计升余弦滤波器
h_rc = rcosdesign(rolloff, span, sps, 'sqrt'); % 使用根升余弦(SRRC)通常用于匹配滤波，若仅看成形可用'normal'
% 这里为了演示成形效果，暂时使用 'normal' 或者直接卷积
h_shape = rcosdesign(rolloff, span, sps, 'normal');

% 生成滚降信号
% upfirdn 会自动进行上采样(插值)并滤波
s_bpsk_rc_baseband = upfirdn(info_map, h_shape, sps); 

% 截取有效部分以匹配时间轴(卷积会增加长度)
len_diff = length(s_bpsk_rc_baseband) - length(sm_rect);
s_bpsk_rc_baseband = s_bpsk_rc_baseband(floor(len_diff/2)+1 : end-ceil(len_diff/2));

% 调制到载波
s_bpsk_rc = s_bpsk_rc_baseband .* sc1;

% --- 绘图对比 ---
figure('Name', '扩展1：矩形脉冲 vs 滚降脉冲');
% 时域对比
subplot(2,1,1);
plot(t1(1:500), s_bpsk_rect(1:500), 'b'); hold on;
plot(t1(1:500), s_bpsk_rc(1:500), 'r', 'LineWidth', 1.5);
legend('矩形脉冲BPSK', '滚降脉冲BPSK');
title('时域波形对比 (前500点)');
xlabel('时间(s)'); grid on;

% 频域对比 (功率谱密度)
subplot(2,1,2);
[pxx_rect, f_rect] = periodogram(s_bpsk_rect, [], [], fs, 'centered');
[pxx_rc, f_rc] = periodogram(s_bpsk_rc, [], [], fs, 'centered');
plot(f_rect, 10*log10(pxx_rect), 'b'); hold on;
plot(f_rc, 10*log10(pxx_rc), 'r', 'LineWidth', 1.5);
title('频谱/带宽分析对比');
xlabel('频率 (Hz)'); ylabel('功率谱密度 (dB)');
legend('矩形脉冲 (旁瓣大)', '滚降脉冲 (旁瓣抑制)');
xlim([fc-400, fc+400]); grid on;
%% 扩展2：原始基带 vs 解调信号 差异分析

% 时域已经在原代码中画出 (subplot 2,1,1 和 2,1,2)
% 这里重点补充频域对比和误差分析

figure('Name', '扩展2：输入输出信号频域对比');
fft_len = 4096;

% 原始基带频谱
F_orig = fftshift(fft(sm_rect, fft_len));
% 解调基带频谱 (经过低通后)
F_demod = fftshift(fft(s_lpf, fft_len));
freq_axis = (-fft_len/2 : fft_len/2 - 1) * (fs/fft_len);

subplot(2,1,1);
plot(freq_axis, abs(F_orig)/max(abs(F_orig)));
title('原始基带信号归一化频谱 (Sinc函数形状)');
xlabel('频率(Hz)'); xlim([-500 500]); grid on;

subplot(2,1,2);
plot(freq_axis, abs(F_demod)/max(abs(F_demod)));
title('解调后基带信号归一化频谱');
xlabel('频率(Hz)'); xlim([-500 500]); grid on;

% 计算延时 (互相关)
[c, lags] = xcorr(sm_rect, s_lpf);
[~, I] = max(c);
delay_samples = lags(I);
time_delay = delay_samples * ts;
fprintf('分析结果：解调信号相对于原始信号存在约 %.4f 秒的时间延迟。\n', abs(time_delay));