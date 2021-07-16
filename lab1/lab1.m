%%
close all; clear all; clc;
format short; format compact;

%%
%{
DO NOT USE in your implementation, but use to check answers!!!
conv2
imfilter
imgradientxy
imgradient
%}

%% Load all images into cell
images = {};
for i = 1:4
    img_name = "test0" + num2str(i - 1) + ".png";
    % images{i} = imread(img_name);
    % upgrade image data to double
    images{i} = im2double(imread(img_name));
end

% images{5} = im2double(imread("test04.jpg"));
% images{6} = im2double(imread("test05.jpg"));
for j = 5:6
    img_name = "test0" + num2str(j - 1) + ".jpg";
    images{j} = im2double(imread(img_name));
end

%% Task 1: Implement Gaussian Blur
gaussian_kernel = [2, 4, 5, 4, 2;
                4, 9, 12, 9, 4;
                5, 12, 15, 12, 5;
                4, 9, 12, 9, 4;
                2, 4, 5, 4, 2];

for i = 1:length(images)
    % perform gaussian blur (convolution operation)
    blurred_images{i} = my_conv(images{i}, gaussian_kernel, 2);
    figure
    montage({images{i}, blurred_images{i}})
    title("Gaussin blur (RHS) of Image " + num2str(i) + "(LHS)")
end

%% Task 2: Calculate Image Gradients
%{
NOTE: All computation is done here except for Task 5, see comments for
reference
%}
close all;

% sobel kernel for vertical edges
sobel_x = [-1, 0, 1;
        -2, 0, 2;
        -1, 0, 1];
% sobel kernel for horizontal edges
sobel_y = [-1, -2, -1;
        0, 0, 0;
        1, 2, 1];
% flip kernel values about vertical
% sobel_x = fliplr(sobel_x);
% sobel_y = sobel_x';

% =================================
% ONLY USE THIS FOR ANSWER CHECKING
% diff_x = [];
% diff_y = [];
% =================================

gradient_mag = {};
gradient_orient = {};
gradient_colorized = {};
theta = {};
theta_adj = {};

% Task 4: define cardinal directions
directions = linspace(0, 2 * pi * 7/8, 8);
% consider negative directions for gradient orientation
% take from index 2 since we want unique values
directions = horzcat(directions, -directions(2:end));

for i = 1:length(blurred_images)
    % just aliasing
    img = blurred_images{i};

    % perform convolution with sobel filter
    G_x = my_conv(img, sobel_x, 1);
    G_y = my_conv(img, sobel_y, 1);

    % =================================
    % ONLY USE THIS FOR ANSWER CHECKING
    %     [Gx, Gy] = imgradientxy(img);
    %     diff_x(i) = sum(Gx, 'all') - sum(result_x, 'all');
    %     diff_y(i) = sum(Gy, 'all') - sum(result_y, 'all');
    % =================================

    % Task 3: calculate gradient magnitude
    gradient_mag{i} = sqrt(G_x.^2 + G_y.^2);

    % Task 4: calculate gradient orientation
    % range is 0 to 2*pi, what about fe31or special cases of theta?
    theta{i} = atan2(G_y, G_x);
    [n_rows, n_cols] = size(gradient_mag{i});
    for j = 1:n_rows
        for k = 1:n_cols
            % determine which cardinal direction theta(j,k) is closest to
            [d_theta, index] = min(abs(theta{i}(j, k) - directions));
            theta_adj{i}(j, k) = directions(index);
            % theta_adj = deg2rad(round(theta(j,k) / 45) * 45);
            gradient_orient{i}(j, k) = theta_adj{i}(j, k);
        end
    end
    
    % colorize gradients
    gradient_colorized{i} = colorize_gradients(gradient_orient{i}, directions);

    % rescale if needed
    img = squish(img);
    G_x = squish(G_x);
    G_y = squish(G_y);

    % plot results
    figure
    subplot(1, 3, 1)
    imshow(img)
    title("Blurred image " + num2str(i))
    subplot(1, 3, 2)
    imshow(G_x)
    title("sobel (vertical)")
    subplot(1, 3, 3)
    imshow(G_y)
    title("sobel (horizontal)")
end

%% Task 3: Calculate Gradient Magnitude
close all;

% show gradient magnitude
% this is meant to show the strength of edges!
for j = 1:length(blurred_images)
    figure

    % rescale if needed
    blurred_images{j} = squish(blurred_images{j});
    gradient_mag{j} = squish(gradient_mag{j});

    subplot(1, 2, 1)
    % imshow(blurred_images{j})
    % title("Blurred image " + num2str(j))
    imshow(gradient_mag{j})
    title("Gradient magnitude")
    [gmag, gdir] = imgradient(blurred_images{j});
    subplot(1, 2, 2)
    imshow(squish(gmag))
    title("gmag (built-in)")
end

%% Task 4: Calculate Gradient Orientation
close all;

% show gradient magnitude and gradient orientation
for j = 1:length(blurred_images)
    figure

    % rescale if needed
    blurred_images{j} = squish(blurred_images{j});
    gradient_mag{j} = squish(gradient_mag{j});
    % negative gradients should be shown now that we consider bidirectional
    % cardinal directions
    gradient_orient{j} = squish(gradient_orient{j});
    gradient_colorized{j} = squish(gradient_colorized{j});
    
    % subplot(1, 4, 1)
    % imshow(blurred_images{j})
    % title("Blurred image " + num2str(j))
    subplot(1, 4, 1)
    imshow(gradient_mag{j})
    title("Gradient magnitude")
    subplot(1, 4, 2)
    imshow(gradient_orient{j})
    title("Gradient orientation")
    subplot(1, 4, 3)
    % use built-in function for answer checking
    [gmag, gdir] = imgradient(blurred_images{j});
    imshow(squish(gdir))
    title("gdir (built-in)")
    subplot(1,4,4)
    imshow(gradient_colorized{j})
    title("Gradient orientation (Colorized)")
end


%% Task 5: NMS and Thresholding
close all;

% thin the edges using NMS
nms_images = {};
thresh_images = {};

for k = 1:length(gradient_mag)
    nms_images{k} = my_nms(gradient_mag{k}, gradient_orient{k});
    thresh_images{k} = thresh(nms_images{k}, 255/5);

    % rescale if needed
    nms_images{k} = squish(nms_images{k});
    thresh_images{k} = squish(thresh_images{k});

    figure
    subplot(1, 3, 1)
    imshow(gradient_mag{k})
    title("Gradient magnitude")
    subplot(1, 3, 2)
    imshow(nms_images{k})
    title("Apply NMS")
    subplot(1, 3, 3)
    imshow(thresh_images{k})
    title("NMS & Thresh")
end
