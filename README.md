# EECS 598 Group 9: Kernel Sharing Winograd Systolic Array for CNN Acceleration
Contributors: Wenjie Geng, Taoran Ji, Jason Ning, Jennie Peng 

Main Reference: X. Liu, Y. Chen, C. Hao, A. Dhar, and D. Chen, “WinoCNN: Kernel Sharing Winograd Systolic Array for Efficient Convolutional Neural Network Acceleration on FPGAs,” arXiv.org, 2021. https://arxiv.org/abs/2107.04244 (accessed Nov. 30, 2024).
‌
## MATLAB
`winoPE.m`: a single winograd PE written in fixed point. The fixed point representation can be changed through the various input parameters.

`winoPE_test.m`: code that pre-processs image data, feeds into the Winograd PE, and plots the output data. It is also responsible for generating test data for the Verilog testbenches.

`IDOD_TEST.m`: code that expand on the ideas of `winoPE_test.m`, generalizing it to various `ID` and `OD` sizes. The default `ID = 2` and `OD = 4`.

`data_post_proces.m`: code that post process the generated raw data output from `winoPE_test.m` and `IDOD_TEST.m` so it matches the data format of the RTL memory output. Note that this does not change the data, just adding zeros. This function is called at the end of `winoPE_test.m` and `IDOD_TEST.m` 

For both files, you can make changes to variables like `size_k`, `file_generation`, and `A` to select your desired input image, filter size, and file generation mode. The default input to perform the convolution operation is the red (and green if ID = 2) channel of the input image. Starting at line 79, we have also provided a variety of 3 * 3 filters. Simply change the desired filter name to `kernel` to apply to the convolution operation. 

NOTE: Report Results are created with the input image `A = imread('2424_pic.jpg');` due to the size limitations of the Verilog SRAM. 

## Verilog
All Verilog modules are inside the `/verilog` directory, the testbenches are inside the `/testbench` directory and Verdi signals configurations are saved as `signal.rc` files. Explanation of what each module perform can be found inside of the project report. `\test1` and `\test2` contains the input and output for the two seperate test.

## Verilog file explaination:

`CIM_mem_top.sv`: connects CIM, SRAM, output memory controller
`CIM.sv`: code for computer-near-memory blcok
`data_controller.sv`: code for data controller
`data_mem_controller_top.sv`: connects data controller, input memory and input memory controller
`main_controler.sv`: code for main controller
`newPE.sv`: processing element
`output_mem_top.sv`: connects output memory and output controllers
`SRAM.v`: code for SRAM
`top.v`: top level design
`weight_controller.sv`: code for weight controller
`weight_mem_controller_top.sv`: connects weight controller, input memory and input memory controller


## HOW TO RECREATE REPORT RESULT:

### Step 1: Generate Data Using the MATLAB Model
Press the "Run" button in `winoPE_test.m` to run winoPE with `ID = OD = 1` and a 3 * 3 Laplace filter. The plots will automatically show up, and error information will display in the terminal. You can find the output data used by the testbenches in the directory: `../matlab_data_out/input2424_filter33_ID1OD1`.

or

Press the "Run" button in `IDOD_TEST.m` to run winoPE with `ID = 2`, `OD = 4`. The set of 8 kernels can be found at around line 138: `kernel = [kernel_1, kernel_1, kernel_2, kernel_2, kernel_3, kernel_4, kernel_5, kernel_6];`. The plots will automatically show up, and error information will display in the terminal. You can find the output data used by the testbenches in the directory: `../matlab_data_out/input2424_filter33_ID2OD4`.

The filer matrices `filter.txt` and input matrices `input.txt` that's going to be loaded by the memory can be found inside the output directory. The correct answer for testbench comparison can be found inside the `/ans` folder of the output folder. The intermediate U, and V matrices are in the `/in_U_in_V` folder. 

### Step 2: File Setup 

NOTE: This repository already have the pre-generated data inside the needed folder. If you are not generating a new set of data, you can skip this step.

#### To Run Test1 (ID = 1, OD = 1):

In `\test1` folder, `data_scan_in.txt` and `weight_scan_in.txt` are the inputs for test1. The ground truth is `Y_HEX_modified.txt`. Scan out data are stored in `output_mem1_scan_out.txt` and `output_mem2_scan_out.txt`

Find the `Makefile` and make sure the testbench is `top_test1.sv`

#### To Run Test2 (ID = 2, OD = 4):
In `\test2` folder, `filter_OD4.txt` and `input_ID2.txt` are the inputs for test1. The ground truth are `output_odd_modified.txt` and `output_even_modified.txt`. Scan out data are stored in `output_mem1_scan_out.txt` and `output_mem2_scan_out.txt`

Find the `Makefile` and make sure the testbench is `top_test2.sv`

### Step 3: Run the Testbench

In the terminal, run `$ make` or `$ make verdi`

Output files will be automatically generated. To compare the MATLAB result and testbench result, type: `$ make diff1` or `$ make diff2` depending on your test. Test could be changed by changing the testbench in Makefile

### Step 4: Syn the project

Enter the `/syn` folder. Run `$ module load eecs598-002/f23` and then run `$ make syn`. Reports could be find in `/syn/reports`
