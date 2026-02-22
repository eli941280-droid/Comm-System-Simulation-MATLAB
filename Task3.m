clc; clear; close all


dt = 0.005;        % 设定步长 (采样周期)
fs = 1/dt;         % 采样频率 (200Hz)
t = 0:dt:3;        % 时间向量
am = 5;            % 调制信号幅度
fm = 5;            % 调制信号频率
mt = am*cos(2*pi*fm*t); % 生成调制信号 (基带信号)

% 积分生成相位
j_mt(1) = 0;
for i = 1:length(t)-1
    j_mt(i+1) = j_mt(i) + mt(i)*dt;
end

fc = 25;           % 载波频率
ct = cos(2*pi*fc*t); 
kf = 20;           % 调频灵敏度 (决定了调频指数 beta = kf*am/fm)
sft = cos(2*pi*fc*t + kf*j_mt); % 生成FM已调信号

% ================= 噪声设置 =================
sn1 = 10;  % 小信噪比 (dB)
sn2 = 40;  % 大信噪比 (dB)

% ================= 扩展内容1：定义两种解调函数 =================

% 辅助函数：计算频谱 (用于扩展内容2)
get_spectrum = @(x, fs) abs(fftshift(fft(x)))/length(x);
freq_axis = linspace(-fs/2, fs/2, length(t));

% ================= Figure 1: 无噪声情况 =================
figure(1)
subplot(3,1,1); plot(t,mt);
xlabel('时间t'); title('调制信号的时域图(beta = 20)');
grid on;

subplot(3,1,2); plot(t,sft);
xlabel('时间t'); title('无噪声已调信号的时域图(beta = 20)');

% --- 原有解调方法 (微分+包络) ---
nsfm = sft;
diff_nsfmn1 = diff(nsfm);
diff_nsfmn1 = [diff_nsfmn1 0];
env_nsfmn1 = abs(hilbert(diff_nsfmn1));
demod_1 = env_nsfmn1 - mean(env_nsfmn1); % 去直流
% 归一化/缩放以匹配原始信号幅度 (近似处理)
demod_1_plot = demod_1./400 - 30; 

subplot(3,1,3);
plot((1:length(demod_1))./2000, demod_1_plot, 'r');
xlabel('时间t'); title('无噪声解调(微分包络法)(beta = 20)');
xlim([0,0.3]);

% 保存无噪声解调结果用于频谱分析
demod_no_noise = demod_1_plot; 

% ================= Figure 2: 小信噪比 (SNR=10dB) =================
figure(2)
db1 = am^2 / (2*(10^(sn1/10)));
n1 = sqrt(db1) * randn(size(t));
nsfm1 = n1 + sft; % 含噪信号

subplot(3,1,1); plot(t,mt); title('调制信号(beta = 20)'); grid on;
subplot(3,1,2); plot(t,nsfm1); title(['含噪信号 SNR=' num2str(sn1) 'dB (beta = 20)']);

% --- 解调 ---
diff_nsfmn1 = diff(nsfm1);
diff_nsfmn1 = [diff_nsfmn1 0];
env_nsfmn1 = abs(hilbert(diff_nsfmn1));
demod_2 = env_nsfmn1 - mean(env_nsfmn1);
demod_2_plot = demod_2./400 - 30;

subplot(3,1,3);
plot((1:length(demod_2))./2000, demod_2_plot, 'r');
xlabel('时间t'); title('小信噪比解调信号(beta = 20)');
xlim([0,0.3]);

% ================= Figure 3: 大信噪比 (SNR=40dB) =================
figure(3)
db2 = am^2 / (2*(10^(sn2/10)));
n2 = sqrt(db2) * randn(size(t));
nsfm2 = n2 + sft;

subplot(3,1,1); plot(t,mt); title('调制信号(beta = 20)'); grid on;
subplot(3,1,2); plot(t,nsfm2); title(['含噪信号 SNR=' num2str(sn2) 'dB (beta = 20)']);

% --- 解调 ---
diff_nsfmn1 = diff(nsfm2);
diff_nsfmn1 = [diff_nsfmn1 0];
env_nsfmn1 = abs(hilbert(diff_nsfmn1));
demod_3 = env_nsfmn1 - mean(env_nsfmn1);
demod_3_plot = demod_3./400 - 30;

subplot(3,1,3);
plot((1:length(demod_3))./2000, demod_3_plot, 'r');
xlabel('时间t'); title('大信噪比解调信号(beta = 20)');
xlim([0,0.3]);

% ==========================================================
%       扩展内容 1: 使用另一种解调算法 (Hilbert 相位微分法)
% ==========================================================
figure(4)
sgtitle('扩展1：使用Hilbert相位微分法进行解调 (对比原有方法)');

% 对无噪声信号进行解调 (Hilbert相位法)
z = hilbert(sft);           % 1. 生成解析信号
inst_phase = unwrap(angle(z)); % 2. 提取瞬时相位并解卷绕
inst_freq = diff(inst_phase)/(2*pi*dt); % 3. 微分相位得到瞬时频率 f = d(phi)/dt / 2pi
inst_freq = [inst_freq 0];  % 补齐长度
demod_hilbert = inst_freq - fc; % 4. 去除载波频率分量

subplot(2,1,1);
plot(t, mt, 'b', 'LineWidth', 1.5); hold on;
plot(t, demod_hilbert/kf * 2*pi, 'r--'); % 理论上幅度需除以kf，这里做简单归一化演示
legend('原始调制信号', 'Hilbert解调信号');
title('Hilbert相位法解调效果');
xlabel('时间t'); grid on;

subplot(2,1,2);
plot(t, demod_hilbert);
title('Hilbert解调信号波形 (未缩放)');
xlabel('时间t'); grid on;

% ==========================================================
%       扩展内容 2 & 3: 频域分析与解调增益辅助观察
%       (修正了直流偏置问题，并增加了dB显示以辅助分析增益)
% ==========================================================
figure(5)
sgtitle(['扩展2：不同信噪比下解调信号频谱 (beta = ' num2str(kf) ')']);

% 定义计算单边频谱(dB)的函数
% 输入 x: 信号, fs: 采样率
% 输出: 归一化幅度谱(dB)
get_spectrum_db = @(x) 20*log10(abs(fftshift(fft(x - mean(x))))/length(x) + eps); 

% 计算三种情况下的频谱
spec_no_noise = get_spectrum_db(demod_1); % 使用 demod_1 (无偏移原始解调信号)
spec_low_snr  = get_spectrum_db(demod_2); % 使用 demod_2 (SNR=10dB)
spec_high_snr = get_spectrum_db(demod_3); % 使用 demod_3 (SNR=40dB)

% 绘图
subplot(3,1,1);
plot(freq_axis, spec_no_noise, 'b', 'LineWidth', 1.2);
xlim([-20 20]); ylim([-100 0]); % 限制Y轴范围以便观察底噪
grid on;
title('无噪声解调信号频谱 (dB)'); 
ylabel('幅度 (dB)'); xlabel('频率 (Hz)');
text(5, max(spec_no_noise(freq_axis>0)), '\leftarrow 5Hz 基波', 'FontSize', 8);

subplot(3,1,2);
plot(freq_axis, spec_low_snr, 'r');
xlim([-20 20]); ylim([-60 0]); 
grid on;
title(['小信噪比 (' num2str(sn1) 'dB) 解调信号频谱']); 
ylabel('幅度 (dB)'); xlabel('频率 (Hz)');

subplot(3,1,3);
plot(freq_axis, spec_high_snr, 'm');
xlim([-20 20]); ylim([-80 0]); 
grid on;
title(['大信噪比 (' num2str(sn2) 'dB) 解调信号频谱']); 
ylabel('幅度 (dB)'); xlabel('频率 (Hz)');

