format short; format compact;
close all; clear all; clc;
%% q1

focal_len = 320;
principal_pt = [320, 240];
skew = 0;
K = mat_camera(focal_len, principal_pt, skew)

%% q2 
fov = 2*atan(640/2*320)

%% q3
% E matrix (transformation matrix)
E = [1 0 0 0;
    0 0.7 -0.7 0;
    0 0.7 0.7 3;
    ];
P = K*E
