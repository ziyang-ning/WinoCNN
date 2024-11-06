%% Test Single PE functionality 
clear;
clc;
% clf;

size = 0;       %size = 0 for 3*3, = 1 for 1*1

% should be values from -1 to 1?
if (size == 0)
    % TODO: CHANGE YOUR kernel HERE
    kernel =    [-1, -1, -1; 
                 -1,  8, -1; 
                 -1, -1, -1];   %Edge detection kernel
    s0 = 0;
    s1 = 1;
elseif (size == 1)
     % TODO: CHANGE YOUR kernel HERE
     kernel = [0.3];
     s0 = 1;
     s1 = 0;
end

% G matrix pre-calc
G = [1/4,   0,      0;
    -1/6,  -1/6,    -1/6;
    -1/6,   1/6,    -1/6;
    1/24,   1/12,   1/6;
    1/24,   -1/12,  1/6;
    1/24,   -1/12,  1/6;
    s0,     0,      s1];

B_T = [4, 0, -5, 0, 1, 0;
       0, -4, -4, 1, 1, 0;
       0, 4, -4, -1, 1, 0;
       0, -2, -1, 2, 1, 0;
       0, 2, -1, -2, 1, 0;
       0, 4, 0, -5, 0, 1];

if (size == 1)
    G = G(:, 1);
end
        
%input and output size
input_n = 8;
input_r = 4;
middle_n = 12;
middle_r = 4;
out_n = 12;
out_r = 4;

%extract data from image
A = imread('test2.jpg');
A_red = A(:, :, 1);
A_green = A(:, :, 2);
A_blue = A(:, :, 3);

%normalize each channel 
%REQUIRED:: Data pre-processing step, data will be between 0 to 1
A_red_norm = double(A_red) / 255;
A_green_norm = double(A_green) / 255;
A_blue_norm = double(A_blue) / 255;

%put kernel and input into fixed point notation
red_in = fi(A_red_norm, 1, input_n, input_r);
green_in = fi(A_green_norm, 1, input_n, input_r);
blue_in = fi(A_blue_norm, 1, input_n, input_r);
kernel = fi(kernel, 1, input_n, input_r);

%convolution
red_out = conv2(double(red_in), double(kernel)); %maybe need the 'same'
green_out = conv2(double(green_in), double(kernel)); %maybe need the 'same'
blue_out = conv2(double(blue_in), double(kernel)); %maybe need the 'same'

%fixed point output
red_out_fixed = fi(red_out, 1, out_n, out_r);
green_out_fixed = fi(green_out, 1, out_n, out_r);
blue_out_fixed = fi(blue_out, 1, out_n, out_r);

% first approach, mutiply everything in double then convert to fixed
V = G * kernel * G.';
U = B_T * input * B_T.';


