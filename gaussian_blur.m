function [blurred_img] = gaussian_blur(img, kernel)
    %GAUSSIAN_BLUR Summary of this function goes here
    %   Detailed explanation goes here
    % iterate over rows, size format (rows, cols)

    assert(size(kernel, 1) == size(kernel, 2))
    % calculate number of rows/cols of output image, NO padding
    n_rows = size(img, 1) - size(kernel, 1) + 1;
    n_cols = size(img, 2) - size(kernel, 2) + 1;
    vert_offset = size(kernel, 1) - 1;
    horz_offset = size(kernel, 2) - 1;
    blurred_img = zeros(n_rows, n_cols);
    for i = 1:n_rows
        for j = 1:n_cols
            blurred_img(i, j) = 1 / sum(kernel, 'all') * sum(kernel .* img(i:i +vert_offset, j:j +horz_offset), 'all');
        end
    end
end
