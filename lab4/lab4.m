%%
clear all; close all; clc;
format short; format compact;

% task 1 - load and join images
im1 = im2double(imread('im1.jpg'));
im2 = im2double(imread('im2.jpg'));
im3 = im2double(imread('im3.jpg'));
im4 = im2double(imread('im4.jpg'));

% joined images
wide12 = [im1 im2];

% load and store feature descriptor and values
f_vals = cell(1, 4);
f_desc = cell(1, 4);
for ii = 1:4
    % load data from file
    f_name = "im" + int2str(ii) + ".sift";
    sift_data = importdata(f_name);
    sift_fd = sift_data(:, 1:4);
    vals = sift_data(:, 5:end);

    % store fd descriptor and values
    f_desc{ii} = sift_fd;
    f_vals{ii} = vals;
end

%% task 2 & 3 - draw keypoints

figA = figure; figure(figA);
hold on
imshow(wide12)
title("wide12: im1.jpg and im2.jpg joined")
hold off

% only plot for images 1 and 2
for ij = 1:2
    if ij == 1
        x = f_desc{ij}(:, 1);
    else
        % shift our x coordinates based on leftmost image
        x = f_desc{ij}(:, 1) + (ij - 1) * size(im1, 2);
    end
    y = f_desc{ij}(:, 2);
    hold on
    figure(figA);
    plot(x, y, 'rx', 'MarkerSize', 8, 'LineWidth', 0.1);
end
hold off


%% task 4 & 5 - match SIFT keypoints and show matches

% match keypoints between 1 and 2
match_pair = [1, 2];
match_ids = match_keypoints(f_vals, f_desc, match_pair, figA);

%% task 4 & 5 - min dist matching VS ratio matching
%{
QUESTION:
What happens if the nearest match is always used as a
valid match instead of the ratio - of - distance metric used in
the algorithm above?

ANSWER:
Since we always match, we will get 1000 matches (which is num. rows of SIFT
descriptor / values vector)
Bad matches are also introduced.
%}

%% task 6 - stereo reconstruction
%%%%%%%%%%% PREPROCESSING FOR Task 6 Part 3 %%%%%%%%%%%
% edge detection
im_gray = mean(im1, 3);
% vertical edge detector
sobel_x = [-1, 0, 1;
        -2, 0, 2;
        -1, 0, 1];
padding = 1;
mode = 'sobel';
img_sobel = my_conv(im_gray, sobel_x, mode, padding);
[~,cols] = maxk(sum(img_sobel),4);

% threshold
img_thresh = thresh(img_sobel,0.5);

% sum all columns
col_sum = sum(img_thresh);
% dirty way to handle slanted edges
offset = 2; % number of pixels to left and right of current column
regions = zeros(size(col_sum));
for kk = 1+offset:length(col_sum)-offset
    regions(kk) = sum(col_sum(kk-offset:kk+offset));
end

% specify minimum edge length
min_length = 250;
col_indices = find(regions > min_length);
box_edges = [min(col_indices), max(col_indices)];
box_len_px = max(box_edges) - min(box_edges);

figC = figure; figure(figC);
hold on
title('Showing box width')
imshow(im1)
xline(box_edges(1),'b')
xline(box_edges(2),'b')
hold off
%%%%%%%%%%% PREPROCESSING FOR Task 6 Part 3 %%%%%%%%%%%



% generate cross product matrix from given 1 X 3 matrix
cross_mat = @(mat)[0, -mat(3), mat(2); mat(3), 0, -mat(1); -mat(2), mat(1), 0];

focal_len = 1;
baseline = 1;
clear match_ids match_pair;
match_pairs = [1 2;
            1 3;
            1 4];
colors = ['r','g','b'];
match_ids = cell(1, length(match_pairs));
keypoints = cell(size(match_ids));
disparity = cell(1, length(match_pairs));
depth = cell(1, length(match_pairs));
coords_f1 = cell(1, length(match_pairs));
est_baselines = zeros(1,length(match_pairs));
box_len_m = 37e-2; % box length in metres
scale_units = box_len_m / box_len_px;   % metres per pixel
% plotting
figB = figure; figure(figB);
for ik = 1:size(match_pairs,1)
    % select images to be compared
    imA = match_pairs(ik,1);
    imB = match_pairs(ik,2);

    % perform keypoint matching
    match_indices = match_keypoints(f_vals, f_desc, match_pairs(ik,:));
    % get keypoint xy values
    kpA = f_desc{imA}(match_indices(:, 1), 1:2);
    kpB = f_desc{imB}(match_indices(:, 2), 1:2);

    % store matches for each pair
    match_ids{ik} = match_indices;

    % translation matrix
    t = [baseline 0 0]';
    % essential matrix
    E = cross_mat(t) * eye(3);

    % difference in horizontal coordinates
    curr_disparity = zeros(size(kpA, 1), 1);
    for jj = 1:size(kpA, 1)
        pt1 = kpA(jj, :);   % point from image 1
        pt2 = kpB(jj, :);   % point from image 2
        % l = E * pt1';     % epipolar line
        curr_disparity(jj) = abs(pt1(1) - pt2(1));
    end
    fprintf("Mean disparity: %.2f pixels\n", mean(curr_disparity))
    % depth of keypoints
    curr_depth = focal_len * baseline ./ curr_disparity;
    % estimate baseline
    est_baselines(ik) = mean(curr_disparity) * scale_units;
    % point coordinates in Frame 1
    pt_f1 = zeros(size(kpA));
    pt_f1(:, 1) = kpA(:, 1) .* curr_depth;
    pt_f1(:, 2) = kpA(:, 2) .* curr_depth;
    pt_f1(:, 3) = curr_depth;

    hold on
    view(-45,45) % REQUIRED! if not only 2D plot is shown
    scatter3(pt_f1(:, 1), pt_f1(:, 2), pt_f1(:, 3), colors(ik))

    % store for usage later
    disparity{ik} = curr_disparity;
    depth{ik} = curr_depth;
    coords_f1{ik} = pt_f1;
end

title('Scatter plot for points in Frame 1')
xlabel('uz')
ylabel('vz')
zlabel('z')
legend_str = [];
for jk=1:length(match_pairs)
    a = strcat('im',num2str(match_pairs(jk,1)));all_coords_f1 = cell(1, length(match_pairs));
    b = strcat(' and im',num2str(match_pairs(jk,2)));
    legend_str = [legend_str; strcat(a,b)];
end
legend(legend_str(1,:), legend_str(2,:), legend_str(3,:))
grid on
hold off

%{
QUANTIFYING RESULTS:
Camera is shifted parallel from im1 to im4disparity{3} (ascending order), however, we
are assuming the same baseline. Thus when we calculate depth, disparity
changes but the baseline doesn't resulting in lower values when we shift
from 1&2 -> 1&3 -> 1&4
%}


%% task 7 - reprojection of 3D points

figD = figure;
hold on
imshow(im3)
title("im3.jpg with good keypoints drawn")
hold off

match_ids = match_keypoints(f_vals, f_desc, [1 3]);
figure(figD)
hold on
plot(f_desc{3}(match_ids(:,2), 1), f_desc{3}(match_ids(:,2), 2), 'rx', ...
                'MarkerSize', 8, 'LineWidth', 0.1);
hold off

disparity_14 = disparity{3};
baseline_13 = est_baselines(2);
kpA = f_desc{imA}(match_indices(:, 1), 1:2);
kpB = f_desc{imB}(match_indices(:, 2), 1:2);

% store matches for each pair
match_ids{ik} = match_indices;

% translation matrix
t = [baseline 0 0]';
% essential matrix
E = cross_mat(t) * eye(3);

% difference in horizontal coordinates
curr_disparity = zeros(size(kpA, 1), 1);
for jj = 1:size(kpA, 1)
    pt1 = kpA(jj, :);   % point from image 1
    pt2 = kpB(jj, :);   % point from image 2
    % l = E * pt1';     % epipolar line
    curr_disparity(jj) = abs(pt1(1) - pt2(1));
end
fprintf("Mean disparity: %.2f pixels\n", mean(curr_disparity))
% depth of keypoints
curr_depth = focal_len * baseline ./ curr_disparity;
% estimate baseline
est_baselines(ik) = mean(curr_disparity) * scale_units;
% point coordinates in Frame 1
pt_f1 = zeros(size(kpA));
pt_f1(:, 1) = kpA(:, 1) .* curr_depth;
pt_f1(:, 2) = kpA(:, 2) .* curr_depth;
pt_f1(:, 3) = curr_depth;

hold on
view(-45,45) % REQUIRED! if not only 2D plot is shown
scatter3(pt_f1(:, 1), pt_f1(:, 2), pt_f1(:, 3), colors(ik))

% store for usage later
disparity{ik} = curr_disparity;
depth{ik} = curr_depth;
coords_f1{ik} = pt_f1;
end

title('Scatter plot for points in Frame 1')
xlabel('uz')
ylabel('vz')
zlabel('z')
legend_str = [];
for jk=1:length(match_pairs)
a = strcat('im',num2str(match_pairs(jk,1)));all_coords_f1 = cell(1, length(match_pairs));
b = strcat(' and im',num2str(match_pairs(jk,2)));
legend_str = [legend_str; strcat(a,b)];
end
legend(legend_str(1,:), legend_str(2,:), legend_str(3,:))
grid on
hold off

%{
QUANTIFYING RESULTS:
Camera is shifted parallel from im1 to im4disparity{3} (ascending order), however, we
are assuming the same baseline. Thus when we calculate depth, disparity
changes but the baseline doesn't resulting in lower values when we shift
from 1&2 -> 1&3 -> 1&4
%}


%% task 7 - reprojection of 3D points

figD = figure;
hold on
imshow(im3)
title("im3.jpg with good keypoints drawn")
hold off

match_ids = match_keypoints(f_vals, f_desc, [1 3]);
figure(figD)
hold on
plot(f_desc{3}(match_ids(:,2), 1), f_desc{3}(match_ids(:,2), 2), 'rx', ...
            'MarkerSize', 8, 'LineWidth', 0.1);
hold off

disparity_14 = disparity{3};
baseline_13 = est_baselines(2);
baseline_14 = est_baselines(3);
baseline_ratio = baseline_13 / baseline_14;
% this is in world frame, so [uz,vz,z]
new_coords = coords_f1{3} .* baseline_ratio;
% translate x coordinates accordingly
translate_pct = abs(baseline_14 + baseline_13)*scale
baseline_14 = est_baselines(3);
baseline_ratio = baseline_13 / baseline_14;
% this is in world frame, so [uz,vz,z]
new_coords = coords_f1{3} .* baseline_ratio;
% translate x coordinates accordingly
translate_pct = abs(baseline_14 + baseline_13)*scale_units^-1 / size(im1,2);
new_coords(:,1) = new_coords(:,1) * (1+ translate_pct);
% only want [u,v] == [x,y]
coords_2d_x = new_coords(:,1) ./ new_coords(:,3);
coords_2d_y = new_coords(:,2) ./ new_coords(:,3);

hold on
plot(coords_2d_x, coords_2d_y, 'yx', 'MarkerSize', 8, 'LineWidth', 0.1);
hold off