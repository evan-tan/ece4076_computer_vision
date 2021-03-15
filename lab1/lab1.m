%%
close all; clear all; clc;
format short; format compact;

%{
DO NOT USE
conv2
imfilter
imgradientxy
%}

% load images into list
img_list = {};

% work with doubles not uint8
for i = 1:4
    img_name = "test0" + num2str(i - 1) + ".png";
    img_list{i} = im2double(imread(img_name));
end

img_list{5} = im2double(imread("test04.jpg"));
img_list{6} = im2double(imread("test05.jpg"));

%% Task 1
kernel = [2, 4, 5, 4, 2; ...
        4, 9, 12, 9, 4; ...
        5, 12, 15, 12, 5; ...
        4, 9, 12, 9, 4; ...
        2, 4, 5, 4, 2];

img = img_list{1};

for i = 1:length(img_list)
    img_blurred_list{i} = gaussian_blur(img_list{i}, kernel);
    figure
    %     imshow(img_blurred_list{i})
    montage({img_list{i}, img_blurred_list{i}})
end

%% Task 2

sobel_kernel = [];


%% Task 3

%% Task 4

%% Task 5
