# EECS 598 Group 9: Kernel Sharing Winograd Systolic Array for CNN Acceleration
Contributors: Wenjie Geng, Taoran Ji, Jason Ning, Jennie Peng 

Main Reference: X. Liu, Y. Chen, C. Hao, A. Dhar, and D. Chen, “WinoCNN: Kernel Sharing Winograd Systolic Array for Efficient Convolutional Neural Network Acceleration on FPGAs,” arXiv.org, 2021. https://arxiv.org/abs/2107.04244 (accessed Nov. 30, 2024).
‌
## MATLAB
`winoPE.m`: a single winograd PE written in fixed point. The fixed point representation can be changed through the various input parameters.

`winoPE_test.m`: code that pre-processs image data, feeds into the Winograd PE, and plots the output data. It is also responsible for generating test data for the Verilog testbenches.

HOW TO RECREATE REPORT RESULT: press the "Run" button in `winoPE_test.m` to plot out the winoPE result for a 3 * 3 Laplace filter. You can make changes to variables like `size_k`, `file_generation`, and `A` to select your desired input image, filter size, and file generation mode. Starting at line 79, we have also provided a variety of 3 * 3 filters. Simply change the desired filter name to `kernel` to apply to the convolution operation.
