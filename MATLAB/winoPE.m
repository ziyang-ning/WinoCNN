%% setup input

filter_1 = [2];
filter_3 = [1, 0, 0; 0, 1, 0; 0, 0, 1];

A = imread('test598.jpg');
A_red = A(:, 1);
imshow(A);

out_1 = conv2(A, filter_1);
out_3 = conv2(A, filter_3);

figure();

imshow(out_1);