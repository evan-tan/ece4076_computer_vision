format short; format compact;
close all; clear all; clc;
%% q1 i

img = [85, 78, 75, 72, 71, 70, 72;
    83, 80, 76, 71, 72, 69, 67;
    82, 79, 54, 52, 53, 61, 61;
    77, 68, 51, 50, 51, 49, 51;
    75, 62, 53, 52, 49, 48, 49;
    74, 73, 65, 63, 55, 48, 44;
    74, 72, 71, 68, 55, 46, 40;
    ];

[res, circle_px] = fast_corner(img, 9, 20);
res(~isnan(res))
%% q1 ii
max_thresh = 20;
test = zeros(1, max_thresh);
for thresh = 1:max_thresh
    [tmp, ~] = fast_corner(img, 12, thresh);
    test(thresh) = tmp(~isnan(tmp));
end
fprintf("Max threshold = %d\n", max(find(test == 1)))

%% q1 iii & iv
img_slice = img(2:end - 1, 2:end - 1);

padding = 0;
% create square kernel, pad with zeros
x_kernel = [0, 0, 0;
        -1, 0, 1;
        0, 0, 0];
x_gradient = my_conv(img_slice, x_kernel, "sobel", padding);
y_kernel = x_kernel';
y_gradient = my_conv(img_slice, y_kernel, "sobel", padding);

%% q1 v
% Harris matrix, M
[M, block_matrices] = harris_mat(x_gradient, y_gradient);

%% q1 vi
% get eigenvalues of harris matrix, M
E = eig(M);
