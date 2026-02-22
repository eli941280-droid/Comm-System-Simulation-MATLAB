---

# Communication System Simulation (MATLAB) | 通信系统仿真

A comprehensive MATLAB simulation suite covering Analog and Digital Communication Principles.
一套完整的《通信原理》MATLAB 仿真方案，涵盖模拟与数字通信系统的核心链路。

---

## 🌟 Project Highlights | 项目亮点

* **Complete Analog Modulation Suite | 完整的模拟调制链路**: Implemented AM, DSB, and SSB (USB/LSB) with coherent and non-coherent demodulation.
* 实现了 AM、DSB 以及 SSB（上/下边带）的调制，并包含相干与非相干解调分析。


* **Deep FM Physics Verification | 调频物理特性深度验证**: Explored wideband FM (WBFM) through **Carson's Rule** and the **Bessel Zero** phenomenon.
* 通过实验验证了宽带 FM 的**卡森公式**带宽理论，并演示了  时的**载波零点**现象。


* **Advanced Hilbert Demodulation | 高级 Hilbert 解调算法**: Implemented Instantaneous Phase Demodulation using Hilbert Transform for FM signals.
* 利用 Hilbert 变换提取瞬时相位，实现了比传统微分包络法更具鲁棒性的 FM 解调。


* **Pulse Shaping & Spectrum Analysis | 脉冲成形与频谱分析**: Comparative study between **Rectangular Pulse** and **Root Raised Cosine (SRRC)** shaping in BPSK systems.
* 对比研究了 BPSK 系统中**矩形脉冲**与**根升余弦（SRRC）滚降脉冲**对频谱泄露的影响。



---

## 📂 Repository Structure | 目录结构

```text
├── src/
│   ├── Analog_Modulation/      # 模拟调制模块
│   │   ├── Linear_Mod.m        # AM, DSB, SSB (USB/LSB)
│   │   ├── FM_Basic.m          # FM Modulation & Carson's Rule
│   │   └── FM_Hilbert.m        # Hilbert Phase Demodulation
│   ├── Digital_Modulation/     # 数字调制模块
│   │   └── BPSK_Simulation.m   # BPSK & Pulse Shaping (SRRC)
│   └── utils/                  # Utility Functions | 工具函数
│       ├── T2F.m / F2T.m       # Fourier Transform Tools
│       └── lpf.m               # Ideal Low-pass Filter
└── README.md

```

---

## 🔬 Core Theory | 核心理论展示

### 1. Frequency Modulation (FM)

The FM signal is defined as:
调频信号定义为：


We verified **Carson's Rule** for bandwidth estimation:
我们验证了用于带宽估计的**卡森公式**：


### 2. Digital Baseband Shaping

To suppress spectral leakage in BPSK, we apply **Raised Cosine Filtering**:
为了抑制 BPSK 的频谱泄露，我们应用了**升余弦滤波**：

* **Benefit**: Effectively suppresses sidelobes compared to rectangular pulses.
* **优势**: 相比矩形脉冲，能有效抑制旁瓣，减少邻道干扰。

---

## 📊 Visualizations | 仿真结果
<img width="3500" height="2625" alt="图1" src="https://github.com/user-attachments/assets/65eba653-f12e-4677-b17d-5a104aeb20df" />
<img width="3500" height="2625" alt="图2" src="https://github.com/user-attachments/assets/809ccdf3-2d0c-4ba1-8170-7ef6badb619b" />
* **注：**: 更多实验图像请自行运行程序



---

## 🛠️ Requirements & Usage | 环境要求与使用

* MATLAB R2020b or later.
* Signal Processing Toolbox.
* **Run**: Open any script in `src/` and press `F5` to execute.

---

> **Author**: [Eric]

---
