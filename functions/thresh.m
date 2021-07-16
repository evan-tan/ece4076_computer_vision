function [thresholded_img] = thresh(img, thresh_val)
    %THRESH Simple thresholding function
    % Input(s):
    %   img => input image to threshold
    %   thresh_val => minimum intensity of pixel value from 0-255
    % Output(s):
    %   thresholded_img => thresholded image

    [r, c] = size(img);
    % squish pixel intensity 0-255 to 0-1
    pixel_vals = rescale(0:255, 0, 1);

    if mean(img, 'all') <= 1 && thresh_val > 1
        % use 0-255 as index to grab appropriate threshold value
        % add 1 since MATLAB arrays start from 1 not 0
        thresh_val = round(thresh_val) + 1;
        thresh_val = pixel_vals(thresh_val);
    end

    thresholded_img = zeros(r, c);

    for i = 1:r
        for j = 1:c
            if img(i, j) >= thresh_val
                % set as white pixel
                thresholded_img(i, j) = 1;
            else
                % set as black pixel
                thresholded_img(i, j) = 0;
            end
        end
    end
end
