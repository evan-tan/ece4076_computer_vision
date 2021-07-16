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
imshow(im1)
xline(box_edges(1),'b')
xline(box_edges(2),'b')
%%%%%%%%%%% PREPROCESSING FOR Task 6 Part 3 %%%%%%%%%%%
