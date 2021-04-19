clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 24;

%==================================================================================================
% Compute HSV image
rows = 300;
columns = 400;
midX = columns / 2;
midY = rows / 2;
% Construct v image as uniform.
v = 0.95 * ones(rows, columns);
s = zeros(size(v)); % Initialize.
h = zeros(size(v)); % Initialize.
% Construct the h image as going from 0 to 1 as the angle goes from 0 to 360.
% Construct the S image going from 0 at the center to 1 at the edge.
for c = 1 : columns
	for r = 1 : rows
		% Radius goes from 0 to 1 at edge, a little more in the corners.
		radius = sqrt((r - midY)^2 + (c - midX)^2) / min([midX, midY]);
		s(r, c) = min(1, radius); % Max out at 1
		h(r, c) = atan2d((r - midY), (c - midX));
	end
end
% Flip h right to left.
h = fliplr(mat2gray(h));
% Construct the hsv image.
hsv = cat(3, h, s, v);

% Display the hue image.
subplot(2, 2, 1);
imshow(h, []);
title('H (Hue) Image', 'FontSize', fontSize);

% Display the saturation image.
subplot(2, 2, 2);
imshow(s, []);
title('S (Saturation) Image', 'FontSize', fontSize);

% Display the value image.
subplot(2, 2, 3);
imshow(v, []);
title('V (Value) Image (with V = 0.95)', 'FontSize', fontSize);

% Construct the RGB image.
rgbImage = hsv2rgb(hsv);
% Display the RGB image.
subplot(2, 2, 4);
imshow(rgbImage, []);
title('RGB Image, with V = 0.95', 'FontSize', fontSize);
drawnow;

% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

%==================================================================================================
% Show hsv color space for values of v = .10, .20, .30, .40, .50, .60, .70, .80, & .90.
figure;
rows = 50;
columns = 50;
midX = columns / 2;
midY = rows / 2;
s = zeros(rows, columns); % Initialize.
h = zeros(rows, columns); % Initialize.
for value = 0.10 : 0.10 : 0.90
	% Construct v image as uniform.
	v = value * ones(rows, columns);
	% Construct the h image as going from 0 to 1 as the angle goes from 0 to 360.
	% Construct the S image going from 0 at the center to 1 at the edge.
	for c = 1 : columns
		for r = 1 : rows
			% Radius goes from 0 to 1 at edge, a little more in the corners.
			radius = sqrt((r - midY)^2 + (c - midX)^2) / min([midX, midY]);
			s(r, c) = min(1, radius); % Max out at 1
			h(r, c) = atan2d((r - midY), (c - midX));
		end
	end
	% Flip h right to left.
	h = fliplr(mat2gray(h));
	% Construct the hsv image.
	hsv = cat(3, h, s, v);
	% Construct the RGB image.
	rgbImage = hsv2rgb(hsv);
	% Display it.
	subplot(3, 3, round(value/0.1));
	imshow(rgbImage);
	axis on;
	caption = sprintf('Value (V) = %.1f', value);
	title(caption, 'FontSize', fontSize);
end
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

%==================================================================================================
% Now compute CIE LAB image
figure;
rows = 300;
columns = 300;
minValue = -100;
maxValue = +100;
% Construct v image as uniform.
LImage = 50 * ones(rows, columns);
% Construct the b image as going from maxValue to minValue as the row goes from top to bottom.
% Construct the a image going from minValue at the left edge to maxValue at the right edge.
ramp = linspace(maxValue, minValue, rows);
bImage = repmat(ramp', [1, columns]);
ramp = linspace(minValue, maxValue, columns);
aImage = repmat(ramp, [rows, 1]);
lab = cat(3, LImage, aImage, bImage);

% Display the L image.
subplot(2, 2, 1);
imshow(LImage, []);
axis on;
title('L Image', 'FontSize', fontSize);

% Display the A image.
subplot(2, 2, 2);
imshow(aImage, []);
title('A Image', 'FontSize', fontSize);

% Display the B image.
subplot(2, 2, 3);
imshow(bImage, []);
title('B Image', 'FontSize', fontSize);

% Construct the RGB image going from lab to
colorTransform = makecform('lab2srgb');
% colorTransform2 = makecform('lch2lab');
% labImage2 = applycform(lab, colorTransform);
rgbImage = applycform(lab, colorTransform);
% Display the RGB image.
subplot(2, 2, 4);
imshow(rgbImage, []);
title('RGB Image', 'FontSize', fontSize);
drawnow;
% Extract the individual red, green, and blue color channels.
% redChannel = rgbImage(:, :, 1);
% greenChannel = rgbImage(:, :, 2);
% blueChannel = rgbImage(:, :, 3);

% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

%==================================================================================================
% Show lab color space for values of L = 10, 20, 30, 40, 50, 60, 70, 80, & 90.
ramp = linspace(-100,100, 50);
n = numel(ramp);

figure;
cform = makecform('lab2srgb');
a = repmat(ramp, [n 1]);           % -a on left
b = repmat(flipud(ramp'), [1 n]);  % -b on bottom
for i = 10 : 10 : 90
	L = i * ones(n, n);  % A single L value.	
	Lab = cat(3, L, a, b); % A 2D image.	
	rgb = applycform(Lab, cform);
	% Display it.
	subplot(3, 3, i/10);
	imshow(rgb);
	axis on;
	caption = sprintf('L = %d', i);
	title(caption, 'FontSize', fontSize);
end
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

