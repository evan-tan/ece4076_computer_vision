%%
close all; clear all; clc;
format short; format compact;

% load images
img_l = im2double(imread('left.jpg'));
% make a copy so values match up in Task 3
img_r_org = im2double(imread('right.jpg'));
% % matches lighter pixels perfectly
% img_r = imadjust(img_r_org, [min(min(img_r_org)) max(max(img_r_org))], [min(min(img_l)) 1]);
% matches darker pixels perfectly
img_r = imadjust(img_r_org, [min(min(img_r_org)) max(max(img_r_org))], [0 1]);


% defining some helper functions
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
title("right.jpg")
hold on
plot(x, y, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
hold off

%% task 3 - billinear interpolation in right image

pts_binter = bilinear_inter(img_r_org, pts_r_2d);
fprintf("Task 3:\nPixel intensities after bilinear interpolation:\n")
disp(pts_binter * 255)

%% task 4 - image stitching

% rows (rl/rr) and cols (cl/cr) of left and right images
[rl, cl] = size(img_l);
[rr, cr] = size(img_r);

% add left image
img_stitched = zeros(rl, cl + cr);
img_stitched(1:rl, 1:cl) = img_l;

% storage for bilinear interpolated points
pts_r_intensities = [];
% cols start at 513, but there is some overlap
rhs_cols = 1+cl:size(img_stitched, 2);

clear tmp;
for row = 1:size(img_stitched, 1)
    % loop through RHS of combined image
    for col = rhs_cols
        % (x,y,z) format
        pt_r = [col, row, 1];

        % transposing in order to get 1 X 2 repr of point
        tmp = H_lr * pt_r';
        pt_r_2d = convert_3d(tmp');

        % drop bad coordinates
        cond1 = pt_r_2d >= 1;
        % we need < (not <=) since we check neighbouring pixels!
        % make sure x(columns) and y(rows) values fit
        cond2 = pt_r_2d(:, 1) < size(img_r, 2);
        cond3 = pt_r_2d(:, 2) < size(img_r, 1);
        good_row = cond1(:, 1) & cond1(:, 2) & cond2(:) & cond3(:);

        % pixel is valid, passed all checks
        if good_row == 1
            pt_intensity = bilinear_inter(img_r, pt_r_2d);
            % handle NaN values
            if isnan(pt_intensity)
                img_stitched(row, col) = 0;
            else
                img_stitched(row, col) = pt_intensity;
                % dynamically append
                pts_r_intensities = [pts_r_intensities; pt_intensity];
            end
        elseif good_row == 0
            % just set pixel value to black if indices invalid
            img_stitched(row, col) = 0;
        end
    end
end

figB = figure; figure(figB);
title("stitched image w/o post-processing")
hold on
imshow(img_stitched)
hold off

%% task 5 - better blending

% remove columns with ALL black pixels
good_cols = sum(img_stitched) > 0;
img_cropped = img_stitched(:, good_cols);

% adjust brightness by scaling RHS
img_flat = reshape(img_cropped, size(img_cropped, 1) * size(img_cropped, 2), 1);
% consider only non-zero pixels
img_flat = img_flat(img_flat > 0);
ref_mean = mean2(img_flat);
lhs_mean = mean2(img_cropped(:, 1:cl));

good_pixels = find(img_flat(384 * 512 + 1:end) ~= 0);
rhs_mean = mean2(img_flat(good_pixels));

if ref_mean < rhs_mean
    scaling = ref_mean / rhs_mean;
elseif ref_mean > rhs_mean
    scaling = rhs_mean / ref_mean;
else
    scaling = 1;
end
img_cropped(:, cl + 1:end) = img_cropped(:, cl + 1:end) * scaling;

% fill random dots with
for r = 2:size(img_cropped, 1) - 1
    for c = 2:size(img_cropped, 2) - 1
        if img_cropped(r, c) == 0
            neighbours = [img_cropped(r, c - 1), img_cropped(r, c + 1), ...
                        img_cropped(r - 1, c), img_cropped(r + 1, c)];
            if ~(any(neighbours == 0))
                img_cropped(r, c) = mean(neighbours);
            end
        end
    end
end

% adjust RHS of image
% makes foreground good, but background is still bad
offset = 4;
% temp storage for pixels
new_pixels = img_cropped(:, 513 + offset:end);
% set last few cols to black
img_cropped(:, end - offset + 1:end) = 0;
good_cols = find(sum(img_cropped) > 0);
img_cropped = img_cropped(:, good_cols);
img_cropped(:, 513:end) = new_pixels;

% gaussian blur the seam
gaussian_kernel = [15, 5, 4, 5, 15;
                    5, 12, 9, 12, 5;
                    4, 9, 2, 9, 4;
                    5, 12, 9, 12, 5;
                    15, 5, 4, 5, 15];
mode = "gaussian";
padding = 0;
% number of pixels we want to cover
offset = 10;
cols = 513 - offset / 2:513 + offset / 2;
img_tmp = img_cropped(:, cols);
img_tmp = my_conv(img_tmp, gaussian_kernel, mode, padding);
comp = (size(gaussian_kernel, 1) - 1) / 2;
cols = 513 - offset / 2 + comp:513 + offset / 2 - comp;
img_cropped(1 + comp:end - comp, cols) = img_tmp;

figC = figure; figure(figC);
title("post-processing")
hold on
imshow(img_cropped)
hold off


% adjust horizontal location of seam
