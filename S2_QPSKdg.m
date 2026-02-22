close all;
clear;

% --------QPSK Constellations
% clear all;
% close all;

x_qpsk = randi([0,1],1,10000)*2-1 + 1i*(randi([0,1],1,10000)*2-1); % case 1

scatterplot(x_qpsk);
xlabel('I');
ylabel('Q');
title('无噪声星座');
line([0 0],[-3 3],'Color','r');
line([-3 3],[0 0],'Color','r');
axis([-2 2 -2 2]);
grid on;

%% 请分别实现信噪比为30dB、10dB、0dB星座图
snr_values = [30, 10, 0];
for i = 1:length(snr_values)
    snr = snr_values(i);
    noise = (1/sqrt(2)) * (randn(size(x_qpsk)) + 1i*randn(size(x_qpsk))) * 10^(-snr/20);
    x_noisy = x_qpsk + noise;
    
    figure(i);
    scatterplot(x_noisy);
    xlabel('I');
    ylabel('Q');
    title(['信噪比为', num2str(snr), 'dB的星座图']);
    line([0 0],[-3 3],'Color','r');
    line([-3 3],[0 0],'Color','r');
    axis([-2 2 -2 2]);
    grid on;
end


% %% 扩展3：QPSK 误码率(BER) vs 信噪比(SNR) 仿真
clear;

% 仿真参数
num_bits = 100000;      % 仿真比特数 (增加数量以获得平滑曲线)
EbNo_dB = 0:1:10;       % Eb/No 范围 (dB)
SNR_dB = EbNo_dB + 10*log10(2); % QPSK中，SNR = Eb/No + 10log10(k), k=2 bits/symbol
BER_sim = zeros(1, length(EbNo_dB)); % 存放仿真误码率

% 1. 生成随机比特
data_bits = randi([0, 1], 1, num_bits);

% 2. QPSK 调制 (格雷码映射: 00->1+j, 01->-1+j, 11->-1-j, 10->1-j)
% 将比特流重组为符号
data_I = data_bits(1:2:end)*2 - 1; % 奇数位 -> I路
data_Q = data_bits(2:2:end)*2 - 1; % 偶数位 -> Q路
tx_sig = (data_I + 1i * data_Q) / sqrt(2); % 归一化功率

% 3. 循环不同的信噪比
for k = 1:length(EbNo_dB)

    % 添加高斯白噪声
    % awgn 函数可以直接使用 'measured' 自动测算信号功率
    rx_sig = awgn(tx_sig, SNR_dB(k), 'measured');

    % QPSK 解调 (最大似然判决/最小欧氏距离)
    % 简单的象限判断
    rx_I = real(rx_sig);
    rx_Q = imag(rx_sig);

    demod_I = sign(rx_I);
    demod_Q = sign(rx_Q);

    % 恢复比特流
    demod_bits = zeros(1, num_bits);
    demod_bits(1:2:end) = (demod_I + 1) / 2;
    demod_bits(2:2:end) = (demod_Q + 1) / 2;

    % 计算误码率
    [num_errors, ber] = biterr(data_bits, demod_bits);
    BER_sim(k) = ber;
end

% 4. 计算理论误码率
% QPSK的理论误码率公式与BPSK相同 (作为Eb/No的函数时)
BER_theory = berawgn(EbNo_dB, 'psk', 4, 'nondiff'); 

% 5. 绘图对比
figure('Name', '扩展3：QPSK 误码率曲线');
semilogy(EbNo_dB, BER_theory, 'b-', 'LineWidth', 2); hold on;
semilogy(EbNo_dB, BER_sim, 'r*', 'MarkerSize', 8);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('误码率 (BER)');
legend('理论值', '仿真值');
title('QPSK系统误码率性能分析');
