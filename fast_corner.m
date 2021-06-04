function [output_labels, circle_pixels] = fast_corners(input_img, N, threshold)
    % FAST_CORNERS Detect fast corners in image
    % Input(s):
    %   input_img => input image
    %   N         => number of pixels i.e. Fast-N, Fast-9, Fast-12, etc.
    %   threshold => amount surrounding pixels have to be brighter by
    % Output(s):
    %   output_labels => output labels where pixels are Fast Corners
    %   circle_pixels => intensities of pixels in circle

    output_labels = NaN(size(input_img));

    % calculate number of rows/cols of output image
    n_rows = size(input_img, 1);
    n_cols = size(input_img, 2);

    % radius of circle
    radius = 3;
    max_N = 16;
    directions = linspace(0, 2 * pi * (max_N - 1) / max_N, max_N);
    % vertical and horizontal offsets, make negative due to image coordinate frame
    row_os = -round(3 * cos(directions));
    col_os = -round(3 * sin(directions));

    for i = 1 + radius:n_rows - radius
        for j = 1 + radius:n_cols - radius
            % circle rows and cols
            c_rows = row_os + i;
            c_cols = col_os + j;
            % get all surrounding pixel, starting from 12 o'clock
            circle_pixels = zeros(1, max_N);
            for k = 1:max_N
                circle_pixels(k) = input_img(c_rows(k), c_cols(k));
            end
            centre_pixel = input_img(i, j);
            % check which pixels are greater than centre pixel
            px_ids = circle_pixels > (centre_pixel + threshold);
            if sum(px_ids) ~= 16
                while px_ids(end) ~= 0
                    px_ids = circshift(px_ids, 1);
                end
            end
            start1 = strfind([0, px_ids == 1], [0 1]);
            end1 = strfind([px_ids == 1, ], [1 0]);
            blocks = (end1 - start1 + 1);
            if blocks >= N
                output_labels(i, j) = true;
            else
                output_labels(i, j) = false;
            end
        end
    end
