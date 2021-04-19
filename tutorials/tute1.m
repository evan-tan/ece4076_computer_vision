%% q3

img = zeros(12,12);

kernel = [1 1 1; 1 -8 1; 1 1 1];
img(4,6:7) = 10;
img(5,5:8) = 10;
img(6,4:9) = 10;
img(7,4:9) = 10;
img(8:9,4:9) = 10;
img_mod = my_conv(img,kernel,"sobel", 0);


%% q4

i1p1 = [0 0 0; 0 10 10; 0 10 10];
i2p2 = [0 10 10; 0 10 10; 0 0 0];
i1p2 = [10 20 20 ; 10 20 20; 10 10 10];
i2p1 = [10 10 10 ; 10 20 20; 10 20 20];

mean11 = mean(i1p1,'all');
mean12 = mean(i1p2,'all');
mean21 = mean(i2p1,'all');
mean22 = mean(i2p2,'all');

i11 = i1p1 - mean11;
i12 = i1p2 - mean12;
i21 = i2p1 - mean21;
i22 = i2p2 - mean22;