function [processed_img] = my_conv(img, kernel, mode, padding)
    % MY_CONV Implement convolution operation from scratch
    % Input(s):
    %   img     => img to apply convolution to
    %   kernel  => kernel weights
    %   mode    => e.g. gaussian, sobel
    % Output(s):
    %   processed_img => output img after convolution

    % set default value of mode variable
    if nargin == 2
        mode = "";
        padding = 0;
    elseif nargin == 3
        padding = 0;
    end

    % make sure kernel is square
    assert(size(kernel, 1) == size(kernel, 2))
    assert(padding >= 0)

    % alternatively, use the following
    % assert(mean(size(a) == size(a)', 'all') == 1)

    % calculate number of rows/cols of output image
    n_rows = size(img, 1) - size(kernel, 1) + 1;
    n_cols = size(img, 2) - size(kernel, 2) + 1;
    % offset excludes current pixel thus -1
    vert_offset = size(kernel, 1) - 1;
    horz_offset = size(kernel, 2) - 1;

    if mode == "gaussian"
        scale = 1 / sum(kernel, 'all');
    elseif mode == "sobel"
        scale = 1;
    end

    % preallocate and iterate over rows, size format (rows, cols)
    processed_img = zeros(n_rows, n_cols);
    for i = 1:n_rows
        for j = 1:n_cols
            processed_img(i, j) = scale * sum(kernel .* img(i:i +vert_offset, j:j +horz_offset), 'all');
        end
    end

    % pad image with zeros
    if padding > 0
        % use n_rows since we're concatenating column tensors
        col_padding = zeros(n_rows, padding);
        processed_img = horzcat(col_padding, processed_img);
        processed_img = horzcat(processed_img, col_padding);

        % after adding cols,
        % n_cols != size(processed_img{1}, 2)
        row_padding = zeros(padding, size(processed_img, 2));
        processed_img = vertcat(row_padding, processed_img);
        processed_img = vertcat(processed_img, row_padding);
    end
end
