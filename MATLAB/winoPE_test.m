%% Test Single PE functionality 
clear;
clc;
% clf;

%------------- Setup Params -------------------

% extract data from image
A = imread('2424_pic.jpg');

% input and output size
input_n = 8;    %size for the input matrix and filter
input_r = 7;
U_n = 14;
U_r = 7;
V_n = 12;
V_r = 11;
middle_n = 16;
middle_r = 11;
out_n = 12;
out_r = 7;

size_k = 1;       % size_k = 0 for 3*3, = 1 for 1*1

% if file_generation = 1 then U, V matrices to txt files for 3*3
% if file_generation = 2 then U, V matrices to txt files for 1*1
% if file_generation = 3 then write input (8 bit sliced image) and V
% to txt files for memory tests
% NOTE:: setting file_generation param will automatically change size_k

file_generation = 3;

if (file_generation == 1)
    size_k = 0;
    input_folder_name = fullfile('..', 'matlab_data_out/3by3UV');
    if ~exist(input_folder_name, 'dir')
        mkdir(input_folder_name);
    end

    output_folder_name = fullfile('..', 'matlab_data_out/ans_33');
    if ~exist(output_folder_name, 'dir')
        mkdir(output_folder_name);
    end

elseif(file_generation == 2)
    size_k = 1;
    input_folder_name = fullfile('..', 'matlab_data_out/1by1UV');
    if ~exist(input_folder_name, 'dir')
        mkdir(input_folder_name);
    end

    output_folder_name = fullfile('..', 'matlab_data_out/ans_11');
    if ~exist(output_folder_name, 'dir')
        mkdir(output_folder_name);
    end
    
else %file_generation == 3
    size_k = 0;
    input_folder_name = fullfile('..', 'matlab_data_out/input_filter_HEX');
    input_HEX_fileName = fullfile(input_folder_name, 'input.txt');
    filter_HEX_fileName = fullfile(input_folder_name, 'filter.txt');

    input_HEX_fileID = fopen(input_HEX_fileName, 'w');
    filter_HEX_fileID = fopen(filter_HEX_fileName, 'w');
    
    if ~exist(input_folder_name, 'dir')
        mkdir(input_folder_name);
    end

    output_folder_name = fullfile('..', 'matlab_data_out/ans_33inputTEST');
    if ~exist(output_folder_name, 'dir')
        mkdir(output_folder_name);
    end
end


% should be values from -1 to 1?
if (size_k == 0)
    % TODO: CHANGE YOUR kernel HERE
    % NOTE: the kernel will be later normalized to range from [-1 to 1]
    kernel =    [-1, -1, -1; 
                 -1,  2, -1;    % was 8 in the middle
                 -1, -1, -1];   % Edge detection kernel
             
    kernel_2 =    [0, -1, 0; 
                   -1, 5, -1;    % Sharpen
                   0, -1, 0];
               
    kernel_3 =       [1, 0, -1; 
                   2, 0, -2;    % random
                   1, 0, -1];
               
    kernel_4 =       [0, -0.25, 0; 
                    -0.25, 1, -0.25;    % Laplace
                   0, -0.25, 0];
               
    kernel_5 =       [0, 1, 0; 
                    -1, 0, 1;    % 45 deg
                   0, -1, 0];
   
    kernel_6 =       [-1, 2, 0; 
                    -2, 1, 1.5;    % random
                   0, -1, 0];
    kernel_7 =        [0, 1, -2;
                     2, 1, 0;
                     -1, 0 ,-1];
             
    s0 = 0;
    s1 = 1;
elseif (size_k == 1)
     % TODO: CHANGE YOUR kernel HERE
     kernel = 1;
     s0 = 1;
     s1 = 0;
end

% G matrix pre-calc
G = [1/4,   0,      0;
    -1/6,  -1/6,    -1/6;
    -1/6,   1/6,    -1/6;
    1/24,   1/12,   1/6;
    1/24,   -1/12,  1/6;
    s0,     0,      s1];

B_T = [4, 0, -5, 0, 1, 0;
       0, -4, -4, 1, 1, 0;
       0, 4, -4, -1, 1, 0;
       0, -2, -1, 2, 1, 0;
       0, 2, -1, -2, 1, 0;
       0, 4, 0, -5, 0, 1];

if (size_k == 1)
    G = G(:, 1);
end


%
% A = ones(64,64,3);  %All white image

A_red = A(:, :, 1);
A_green = A(:, :, 2);
A_blue = A(:, :, 3);

% normalize each channel 
% REQUIRED:: Data pre-processing step, data will be between 0 to 1
A_red_norm = double(A_red) / 255;
A_green_norm = double(A_green) / 255;
A_blue_norm = double(A_blue) / 255;

% normalize kernel to [-1, 1]

if(size_k == 0)
    max_val = max(abs(kernel(:)));
    kernel_norm = kernel / max_val;
else
    kernel_norm = kernel;
end



%------------- END OF Setup Params -------------------



%------------- START OF ALL FLOAT TEST -------------------

% red_float_out = conv2(A_red_norm,kernel_norm,'same');
% green_float_out = conv2(A_green_norm,kernel_norm,'same');
% blue_float_out = conv2(A_blue_norm,kernel_norm,'same');

red_float_out = filter2(kernel_norm, A_red_norm);
green_float_out = filter2(kernel_norm, A_green_norm);
blue_float_out = filter2(kernel_norm, A_blue_norm);


%------------- END OF ALL FLOAT TEST -------------------



%------------- START OF FIXED GROUND TRUTH -------------------
%This section won't be very useful

% put kernel and input into fixed point notation
% we don't need this anymore because weight should be pre-computed


red_in = fi(A_red_norm, 1, input_n, input_r);
green_in = fi(A_green_norm, 1, input_n, input_r);
blue_in = fi(A_blue_norm, 1, input_n, input_r);
kernel_in = fi(kernel_norm, 1, input_n, input_r);

% convolution
red_out = conv2(double(red_in), double(kernel_in),'same');
green_out = conv2(double(green_in), double(kernel_in),'same');
blue_out = conv2(double(blue_in), double(kernel_in),'same');


% fixed point output
red_out_fixed = fi(red_out, 1, out_n, out_r);
green_out_fixed = fi(green_out, 1, out_n, out_r);
blue_out_fixed = fi(blue_out, 1, out_n, out_r);

%------------- END OF FIXED GROUND TRUTH -------------------

%------------- START OF WINOPE TESTBENCH -------------------

% padding the input
padSize = floor((size(kernel) - 1) / 2);
A_red_padded = padarray(A_red_norm, padSize, 0, 'both');
A_green_padded = padarray(A_green_norm, padSize, 0, 'both');
A_blue_padded = padarray(A_blue_norm, padSize, 0, 'both');


% winograd loop
% default m=4,r=3
m = 4;
r = 3;
if (size_k == 0)
    r = 3;
    m = 4;
elseif (size_k == 1)
    r = 1;
    m = 6;
end

%prepare the output matrix and the number of iters
[height, width] = size(A_red);
red_out_wino = zeros(height, width);

% filename counter for test data output
filename_count = 0;

% performing winoPE for red channel
for i = 1 : m : height
    out_j = 1;
    for j = 1 : m : width
        
        % hard coding 5 because m + r - 1 = 6
        input = A_red_padded(i:i+5, j:j+5);
        
        if(file_generation == 3)
            input_HEX_vals = fi(input, 1, input_n, input_r).hex;
            flattened = strjoin(string(input_HEX_vals), ' ');
            pretty_HEX_data = regexprep(flattened, '\s+', ''); % Replace multiple spaces with nothing
            fprintf(input_HEX_fileID, '%s\n', pretty_HEX_data); % Write the character array
        end
        
        %fixed point for kernel and input
        input = double(fi(input, 1, input_n, input_r));
        
        % do kernel calc in floating point
%         kernel_norm = double(fi(kernel_norm, 1, input_n, input_r));
        
        V = double(G * kernel_norm * G.');
        U = double(B_T * input * B_T.');
        
        if(file_generation == 1 || file_generation == 2)
            in_U = double(fi(U, 1, U_n, U_r).int);
            in_V = double(fi(V, 1, V_n, V_r).int);

            % Save to text files
            writematrix(in_U, fullfile(input_folder_name, strcat(string(filename_count) ,'in_U.txt')), 'Delimiter', ' ');
            writematrix(in_V, fullfile(input_folder_name, 'in_V.txt'), 'Delimiter', ' ');
        end
        if(file_generation == 3 && filename_count == 0)
            in_V_HEX = fi(V, 1, V_n, V_r).hex;
            V_flattened = strjoin(string(in_V_HEX), ' ');
            pretty_V_HEX_data = regexprep(V_flattened, '\s+', ''); % Replace multiple spaces with nothing
            fprintf(filter_HEX_fileID, '%s\n', pretty_V_HEX_data); % Write the character array
            fclose(filter_HEX_fileID);
        end
        
        [out_U, out_V, Y] = winoPE(U, V, size_k, U_n, U_r, V_n, V_r, middle_n, middle_r, out_n, out_r, ...
                                 file_generation, output_folder_name, filename_count);
                             
        filename_count = filename_count + 1; %update filename counter
        if(size_k == 0)
            red_out_wino(i:i+3, j:j+3) = Y;
        end
        
        if(size_k == 1)
            red_out_wino(i:i+5, j:j+5) = Y;
        end

    end
end



diff_float = red_out_wino - red_float_out
max_diff_wino = max(max(abs(diff_float)))


% meaning less

% diff_fixed = red_out_wino - red_out_fixed;
% max_diff_wino_fixed = max(max(abs(diff_fixed)));
% 
% diff_float_fix_truth = red_float_out - red_out_fixed;
% max_diff_truths = max(max(abs(diff_float_fix_truth)));


%------------- END OF WINOPE TESTBENCH -------------------


%------------- Plotting -------------------
subplot(2, 2, 1), imshow(A_red_norm), title('Original Red Channel Float Input');

red_float_out_gray = mat2gray(red_float_out);
subplot(2, 2, 2), imshow(red_float_out_gray), title('Red Channel Float Out');

red_out_fixed_gray = mat2gray(double(red_out_fixed));
subplot(2, 2, 3), imshow(red_float_out_gray), title('Red Channel Fixed Out');

red_out_wino_gray = mat2gray(red_out_wino);
subplot(2, 2, 4), imshow(red_out_wino_gray), title('Red Channel WINO fixed Out');

sgtitle({'Comparison of Original Image, Floating Point Conv2d',
        'Fixed-Point Conv2d, and Fixed-Point WINOPE'});






