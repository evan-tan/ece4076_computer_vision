clear all; close all; clc;
format short;
format compact;
%% q1

img = [
    0 0 0 0 0 0 0;
    0 0 0 0 0 0 0;
    0 10 0 0 0 0 0;
    0 0 0 0 10 10 10;
    0 0 0 10 10 10 10;
    0 0 0 10 10 0 10;
    0 0 0 10 10 10 10;
    ];

kernel = [1 2 1;
    2 4 2;
    1 2 1];

res = my_conv(img, kernel, 0)

%% q2

% q2a
focal_len = 554;
K = mat_camera(focal_len, [320,240], 0)
% q2b
fov = 2*atan(640/(2*focal_len));
fov = rad2deg(fov)
% q2c
p1 = [1 2 10]';
p2 = [2 3 12]';

p1_Fc = K*p1
p1_Fc_norm = norm_coord(p1_Fc')'
p2_Fc = K*p2
p2_Fc_norm = norm_coord(p2_Fc')'