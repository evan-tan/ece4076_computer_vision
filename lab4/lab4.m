%%
% clc;
clear all; close all;
format short; format compact;

% task 1 - load and join images
img_l = im2double(imread('left.jpg'));
im1 = im2double(imread('im1.jpg'));
im2 = im2double(imread('im2.jpg'));
im3 = im2double(imread('im3.jpg'));
im4 = im2double(imread('im4.jpg'));

wide12 = [im1 im2];
wide34 = [im3 im4];

figA = figure; figure(figA);
hold on
imshow(wide12)
title("im1.jpg and im2.jpg joined")
hold off

%% task 2 & 3 - draw keypoints
hold on
for ii = 1:2
	f_name = "im" + int2str(ii) + ".sift";
	[sift_fd, fd_vals] = load_sift_fd(f_name);
	if ii == 1
        x = sift_fd(:,1);
    else
        % shift our x coordinates based on leftmost image
		x = sift_fd(:,1) + (ii-1)*size(im1,2);
	end
	y = sift_fd(:,2);
    figure(figA);
	plot(x,y, 'rx', 'MarkerSize', 8, 'LineWidth', 0.1);
end
hold off

%% task 2 & 3 - validate correctness of keypoints
% 7/8 so we don't overlap 0 & 2pi
cardinal_directions = linspace(0,2*pi*7/8, 8);

%% task 4 & 5 - match SIFT keypoints and show matches


