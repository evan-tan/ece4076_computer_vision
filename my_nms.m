function [nms_image] = my_nms(gradient_mag, gradient_orient)
    %MY_NMS
    % Input(s):
    %   gradient_mag: gradient magnitude of image
    %   gradient_orient: gradient orientation of image
    % Output(s):
    %   nms_image: NMS'd image

    assert(isequal(size(gradient_mag), size(gradient_orient)))

    [n_rows, n_cols] = size(gradient_mag);
    % no issues with padding here
    nms_image = zeros(n_rows, n_cols);
    % r,c because maybe matlab will confuse it with some other shit
    for r = 2:n_rows - 1
        for c = 2:n_cols - 1
            % determine offsets using gradient orientation
            horz_offset = round(cos(gradient_orient(r, c)));
            vert_offset = round(sin(gradient_orient(r, c)));

            % get pixels for comparison
            cur = gradient_mag(r, c);
            pos_grad = gradient_mag(r + horz_offset, c + vert_offset);
            neg_grad = gradient_mag(r - horz_offset, c - vert_offset);

            if cur > pos_grad && cur > neg_grad
                % preserve pixel value
                nms_image(r, c) = cur;
            else
                % set pixel to black
                nms_image(r, c) = 0;
            end
        end
    end
end
