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
    % transpose to match inner dimensions (for matmul)
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

% rows (rl/rr) and cols (cl/cr) of left and right images
[rl, cl] = size(img_l);
[rr, cr] = size(img_r);

combined = zeros(rl, cl + cr);
combined(1:rl, 1:cl) = img_l;

figB = figure; figure(figB);
imshow(combined)

% loop through RHS of combined image
for row = 1:size(combined, 1)
    % cols start at 513!
    for col = 1 + size(img_l, 2):size(combined, 2)
        % (x,y,z) format
        pt_r = [col, row, 1];
        pt_r_2d = convert_3d((H_lr * pt_r')');

        % drop bad coordinates
        cond1 = pt_r_2d >= 1;
        % we need < not <= since we check neighbouring pixels!
        % make sure x(columns) and y(rows) values fit
        cond2 = pt_r_2d(:, 1) < 512;
        cond3 = pt_r_2d(:, 2) < 384;
        good_row = cond1(:, 1) & cond1(:, 2) & cond2(:) & cond3(:);

        % pixel is valid
        if good_row == 1
            combined(row, col) = bilinear_inter(img_r, pt_r_2d);
        elseif good_row == 0
            combined(row, col) = 0;
        end
    end
end

figure(figB);
imshow(combined)

%% task 5 - better blending

% remove columns with ALL black pixels
good_cols = find(sum(combined) > 0);
figC = figure; figure(figC);
cropped = combined(:,good_cols);
imshow(cropped)

% adjust brightness - normalize image?

% gaussian blur / alpha blending @ seam

% adjust horizontal location of seam