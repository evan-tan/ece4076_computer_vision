clear all; close all; clc;
format short;
format compact;

%% q1.1

img = [
    0 4 12 16 16 16;
    0 4 12 16 16 16;
    0 4 12 16 20 16;
    0 4 12 16 16 16;
    0 4 12 16 16 16;
    0 4 12 16 16 16;
    ];

kernel = [
    -0.25 -0.25 -0.25;
    -0.25 3 -0.25;
    -0.25 -0.25 -0.25;
    ];
padding = 0;
q11_out = my_conv(img, kernel, padding)

%% q2.5
H = [-2 2 0;
    2 2 0;
    1 1 1;];
p1_ = [0, 0, 1];
p2_ = [1, 1, 1];
d1_ = [1, 0, 0];
d2_ = [0, 1, 0];

disp("Q2.5")
p1_f2 = H*p1_'
p2_f2 = H*p2_'
d1_f2 = H*d1_'
d2_f2 = H*d2_'

% q2.6
im2_horizon = cross(d1_f2, d2_f2)
% check horizon line
some_line = cross(d1_, d2_)';
H^-1 * some_line

%% q3.3
F = [4 5 -1;
    5 6 -1;
    -8 -4 -4];
p = [1 0 1];
q33 = F*p'

% q3.4
p1 = [2,2,1];
p2 = [4,0,1];
p3 = [1,1,1];

d1 = dot(p1,q33)
d2 = dot(p2, q33)
d3 = dot(p3, q33)

% 3.5 
% y = x => -x + y + 0 = 0
q35 = cross(q33, [1 -1 0])

%% q4.1
focal_len = 500;
skew = 0;
principal_pt = [320, 240];
K = mat_camera(focal_len, principal_pt, skew)
R = eye(3);
% keep units in mm
T = [100, 0, 0];
% projection matrix
q41 = K * [R T']

% q4.2
baseline = 100e-3;
z_dist = 5;
q42 = focal_len * baseline / z_dist

% q4.3
px_error = 1;
n_cameras = 2;
% min max
error = [-1, 1] * px_error * n_cameras;
z_range = focal_len * baseline ./ (q42 - error)

% q4.4
baseline = 200e-3;
disparity = focal_len * baseline / z_dist;
z_range = focal_len * baseline ./ (disparity - error)
