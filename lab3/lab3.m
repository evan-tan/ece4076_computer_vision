%%
close all; clear all; clc;
format short; format compact;

% load images
img_l = im2double(imread('left.jpg'));
img_r = im2double(imread('right.jpg'));

%%%% defining some helper functions
% convert 3D (XYZ) coordinates to 2D (XY)
convert_3d = @(mat) horzcat(mat(:, 1) ./ mat(:, 3), mat(:, 2) ./ mat(:, 3));

%% task 1 - draw test points on left image
pts_l = [
    338, 197, 1;
    468, 290, 1;
    253, 170, 1;
    263, 256, 1;
    242, 136, 1;
    ];

pts_l_2d = convert_3d(pts_l);
x = pts_l_2d(:, 1);
y = pts_l_2d(:, 2);

figA = figure; figure(figA);
subplot(1, 2, 1)
imshow(img_l);
title("left.jpg")
hold on
plot(x, y, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
hold off

%% task 2 - homography

% homography linking left to right
H_lr = [
    1.6010, -0.0300, -317.9341;
    0.1279, 1.5325, -22.5847;
    0.0007, 0, 1.2865;
    ];

pts_r = zeros(size(pts_l));
for r = 1:size(pts_l, 1)
    % transpose to match inner dimensions
    tmp = H_lr * pts_l(r, :)';
    pts_r(r, :) = tmp';
end
pts_r_2d = convert_3d(pts_r);
x = pts_r_2d(:, 1);
y = pts_r_2d(:, 2);

figure(figA);
subplot(1, 2, 2)
imshow(img_r);
hold on
plot(x, y, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
hold off
title("right.jpg")

%% task 3 - billinear interpolation in right image

pts_binter = bilinear_inter(img_r, pts_r_2d);
fprintf("Pixel intensities after bilinear interpolation:\n")
disp(pts_binter * 255)

%% task 4 - image stitching

% rows and cols of left and right images
[rl, cl] = size(img_l);
[rr, cr] = size(img_r);

combined = zeros(rl, cl + cr);
combined(1:rl, 1:cl) = img_l;

figB = figure; figure(figB);
imshow(combined)

% get all point indices
pt_indices = zeros(rl, cl, 2);

for col = 1:cl
    for row = 1:rl
        % we place col/row values in indices 1/2 because they are the x/y values
        pt_indices(row, col, 1) = col;
        pt_indices(row, col, 2) = row;
    end
end

% make homogenous by adding a column of ones to the RHS of matrix
pt_indices = reshape(pt_indices, rl * cl, 2);
pt_indices = horzcat(pt_indices, ones(size(pt_indices, 1), 1));

% transform pixel coordinates using Homography
clear pts_r pts_r_2d;
pts_r = zeros(size(pt_indices));
for k = 1:size(pt_indices, 1)
    tmp_pt = H_lr * pt_indices(k, :)';
    pts_r(k, :) = tmp_pt';
end

% convert 3D (XYZ) coordinates to 2D (XY)
pts_r_2d = convert_3d(pts_r);

cond1 = pts_r_2d >= 1;
% make sure x/y values fit
% we need < not <= since we check neighbouring pixels
cond2 = pts_r_2d(:, 1) < 512;
cond3 = pts_r_2d(:, 2) < 384;
good_rows = cond1(:, 1) & cond1(:, 2) & cond2(:) & cond3(:);
% drop any invalid pixel coordinates
pts_r_2d = pts_r_2d(good_rows, :);

% empty frame
pts_r_intensities = bilinear_inter(img_r, pts_r_2d);

% combined(rl+1:end, cl+1:end) = some image

%% task 5 -
