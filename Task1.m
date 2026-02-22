clear;close all;clc;

%% AM的调制及其解调

fs = 100000;
dt = 1/fs;
t = 0: dt : 50;
NFFT = 1024; %傅里叶变换点数
f = linspace(-fs/2, fs/2, NFFT);

% 1. 生成调制信号、载波信号以及已调信号

% 调制信号
fm = 1000; % 信号的频率
s_m = cos(2*pi*fm*t); % 基带信号
S_m = t2f(s_m,NFFT); % 傅里叶变换

% 载波信号
fc = 10000; % 载波信号的频率
s_c = cos(2*pi*fc*t); % 载波
S_c = t2f(s_c,NFFT); % 傅里叶变换

% AM 调制
% 公式: s_AM(t) = [1 + m(t)] * c(t)
s_AM = (1 + s_m) .* s_c;
S_AM = t2f(s_AM, NFFT);

%% DSB 调制
% 公式: s_DSB(t) = m(t) * c(t)
s_DSB = s_m .* s_c;
S_DSB = t2f(s_DSB, NFFT);

%% SSB 调制
% 这里生成 m(t) 和 c(t) 的希尔伯特变换
s_m_hat = imag(hilbert(s_m)); 
s_c_hat = imag(hilbert(s_c));

% 上边带 (USB): m(t)c(t) - m^(t)c^(t)
s_SSB_USB = 0.5 * s_m .* s_c - 0.5 * s_m_hat .* s_c_hat; 
S_SSB_USB = t2f(s_SSB_USB, NFFT);

% 下边带 (LSB): m(t)c(t) + m^(t)c^(t)
s_SSB_LSB = 0.5 * s_m .* s_c + 0.5 * s_m_hat .* s_c_hat; 
S_SSB_LSB = t2f(s_SSB_LSB, NFFT);


%% 2. 滤波器设计

% 低通滤波
% 截止频率设置: 1.5 * fm
wc = 1.5 * 2 * pi * fm / fs;             
% 低通滤波器系统函数，FIR滤波器
lbf_hn = fir1(16, wc/pi);                     


%% 3. DSB 信号的相干解调
% 1. 乘法器输出 (与同频同相载波相乘)
s_dsb_mult = s_DSB .* s_c;
S_dsb_mult = t2f(s_dsb_mult, NFFT);

% 2. 低通滤波器输出 (解调信号)
s_dsb_demod = filter(lbf_hn, 1, s_dsb_mult);
% DSB没有直流分量，不需要去直流，但因为乘以载波有个0.5的系数，幅度会减半
% 此处保持原始幅度，以便观察 cos(phi) 的衰减效果
S_dsb_demod = t2f(s_dsb_demod, NFFT);


%% 4. 非相干解调

% 步骤1: 通过乘法器后时域 (对于非相干，这里模拟全波整流/取绝对值)
s_uncor_temp = abs(s_AM); 
S_uncor_temp = t2f(s_uncor_temp, NFFT);

% 步骤2: 通过低通滤波器提取包络
dem_uncor_out = filter(lbf_hn, 1, s_uncor_temp);

% 步骤3: 移除直流分量
% 包络检波得到的信号是 1+m(t) 的形式，包含直流分量
dem_uncor_out = dem_uncor_out - mean(dem_uncor_out);
% 幅度修正 (由 2/pi 系数导致，这里乘以 pi/2 恢复大致幅度，可选)
dem_uncor_out = dem_uncor_out * (pi/2); 

S_uncor_out = t2f(dem_uncor_out, NFFT);


%% 画图1
figure;
subplot(2,1,1)
plot(t,s_m); grid on;
xlabel('t(s)')
title('2023210391-李彦辰-调制信号')
xlim([0, 0.01]);

subplot(2,1,2)
plot(t,s_c); grid on;
xlabel('t(s)')
title('2023210391-李彦辰-载波信号')
xlim([0, 0.01]);

%% 画图2
figure;
subplot(3,1,1)
plot(t,s_DSB);grid on;
xlabel('t(s)')
title('2023210391-李彦辰-DSB已调信号')
xlim([0, 0.01]);
ylim([-2, 2]);

subplot(3,1,2)
plot(t,s_AM);grid on;
xlabel('t(s)')
title('2023210391-李彦辰-AM已调信号')
xlim([0, 0.01]);
ylim([-2, 2]);

subplot(3,1,3)
plot(t,s_m);grid on;
xlabel('t(s)')
title('2023210391-李彦辰-调制信号')
xlim([0, 0.01]);
ylim([-2, 2]);


%% 画图3: 六种信号的频谱 

figure('Name', '2023210391-李彦辰');
subplot(3,2,1);
plot(f/1000, abs(S_m)); grid on;
xlabel('f(kHz)'); title('调制信号频谱');
xlim([0, 22]); 

subplot(3,2,2);
plot(f/1000, abs(S_c)); grid on;
xlabel('f(kHz)'); title('载波信号频谱');
xlim([0, 22]);

subplot(3,2,3);
plot(f/1000, abs(S_DSB)); grid on;
xlabel('f(kHz)'); title('DSB已调信号频谱');
xlim([0, 22]);

subplot(3,2,4);
plot(f/1000, abs(S_AM)); grid on;
xlabel('f(kHz)'); title('AM已调信号频谱');
xlim([0, 22]);

subplot(3,2,5);
plot(f/1000, abs(S_SSB_USB)); grid on;
xlabel('f(kHz)'); title('SSB已调信号，上边带频谱');
xlim([0, 22]);

subplot(3,2,6);
plot(f/1000, abs(S_SSB_LSB)); grid on;
xlabel('f(kHz)'); title('SSB已调信号，下边带频谱');
xlim([0, 22]);

%% 画图4: DSB解调过程频谱与波形
figure('Name', 'DSB解调过程');

% 1. 解调乘法器输出信号频谱
subplot(3,1,1);
plot(f/1000, abs(S_dsb_mult)); grid on;
xlabel('f(kHz)'); title('2023210391-李彦辰-解调乘法器输出信号频谱');
xlim([0, 22]);
% 说明: 这里应该能看到 0Hz (基带) 和 20kHz (2倍频) 两个分量

% 2. 解调器输出信号频谱 (经过低通滤波后)
subplot(3,1,2);
plot(f/1000, abs(S_dsb_demod)); grid on;
xlabel('f(kHz)'); title('2023210391-李彦辰-解调器输出信号频谱');
xlim([0, 22]);
% 说明: 这里应该只剩下 0Hz 附近的基带分量，20kHz 被滤除

% 3. 解调器输出信号波形
subplot(3,1,3);
plot(t, s_dsb_demod); grid on;
xlabel('t(s)'); title('2023210391-李彦辰-解调器输出信号');
xlim([0, 0.01]);
% 说明: 波形应为正弦波，幅度约为0.5 (因为相干解调系数为1/2)



%% 画图5: 载波相位偏差对DSB解调的影响

phases = [pi/8, pi/4, pi/3, pi/2];
titles = {'\pi/8', '\pi/4', '\pi/3', '\pi/2'};

figure('Name', '2023210391-李彦辰-不同载波相位下的解调结果');
for i = 1:4
    phi = phases(i);
    % 生成带有相位偏差的本地载波
    s_c_phase = cos(2*pi*fc*t + phi);
    
    % 解调乘法
    s_demod_phase_mult = s_DSB .* s_c_phase;
    
    % 低通滤波
    s_demod_phase_out = filter(lbf_hn, 1, s_demod_phase_mult);
    
    % 绘图
    subplot(2,2,i);
    plot(t, s_demod_phase_out); grid on;
    xlabel('t(s)'); 
    title(['解调器输出信号，解调载波相差 ', titles{i}]);
    xlim([0, 0.01]); 
    ylim([-0.6 0.6]); % 固定Y轴范围以便观察幅度衰减
end


fc_high = 5000; 
wh = fc_high / (fs/2); % 归一化频率 (fir1的参数必须归一化到 Nyquist频率)

% 使用 'high' 参数设计高通滤波器
hpf_hn = fir1(32, wh, 'high'); 
% 注：阶数设为32 (比之前的16高一点)，为了获得更陡峭的过渡带，
% 确保能把 1kHz 的基带信号衰减得更干净。

% 2. 信号通过高通滤波器
s_hpf_out = filter(hpf_hn, 1, s_dsb_mult);
S_hpf_out = t2f(s_hpf_out, NFFT);

% 3. 画图分析
figure('Name', '高通滤波器分析：提取倍频分量');

% 子图1: 滤波器的频率响应 (简单示意)
[H_hpf, W_hpf] = freqz(hpf_hn, 1, 512, fs);
subplot(3,1,1);
plot(W_hpf, abs(H_hpf)); grid on;
title('2023210391-李彦辰-设计的 FIR 高通滤波器幅频响应 (fc = 5kHz)');
xlabel('频率 (Hz)'); ylabel('幅度');
xlim([0, 25000]); % 关注 0-25k 范围

% 子图2: 高通滤波后的频谱
subplot(3,1,2);
plot(f/1000, abs(S_hpf_out)); grid on;
title('2023210391-李彦辰-高通滤波输出信号频谱');
xlabel('f (kHz)'); ylabel('幅度');
xlim([0, 25]);
% 预期现象：0Hz附近的信号没了，只剩下 20kHz (2*fc) 附近的信号

% 子图3: 高通滤波后的时域波形
subplot(3,1,3);
plot(t, s_hpf_out); grid on;
title('2023210391-李彦辰-高通滤波输出信号波形 (倍频分量)');
xlabel('t (s)'); ylabel('幅度');
xlim([0, 0.005]); % 放大看细节
% 预期现象：这是一个频率很高(20kHz)的波形，且幅度随 m(t) 变化