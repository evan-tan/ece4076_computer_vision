function [pts_binter] = bilinear_inter(img, pts_2d)
    % BILINEAR_INTER Perform bilinear interpolation for a set of points
    % Input(s):
    %   img     => H X W input image, where H = num. rows, W = num. columns
    %   pts_2d  => N X 2 point indices to perform bilinear interpolation on,
    %                with the format (x,y) in normal XY coordinate frame
    % Output(s):
    %   pts_binter => N X 1 intensity values for points
    
    % ensuring max indices don't exceed image dimensions
    % if matrix has more than 1 row
    if size(pts_2d,1) > 1
        max_vals = max(pts_2d);
        xmax = max_vals(1);
        ymax = max_vals(2);
        % x values correspond to columns in img
        % y values correspond to rows    in img
        assert(xmax < size(img, 2))
        assert(ymax < size(img, 1))
    else
        assert(pts_2d(1) < size(img, 2))
        assert(pts_2d(2) < size(img,1))
    end

    % preallocating
    pts_binter = zeros(size(pts_2d, 1), 1);
    for ij = 1:size(pts_2d, 1)
        % DON'T THINK LIKE OPENCV PYTHON
        % we are using conventional xy-axes HERE
        btm_left = floor(pts_2d(ij, :));
        top_right = ceil(pts_2d(ij, :));

        % x-left, x-right, y-high, y-low
        xl = btm_left(1);
        xr = top_right(1);
        yh = top_right(2);
        yl = btm_left(2);
        
        frac_a = (xr - pts_2d(ij, 1)) / (xr - xl);
        frac_b = (pts_2d(ij, 1) - xl) / (xr - xl);
        frac_c = (yh - pts_2d(ij, 2)) / (yh - yl);
        frac_d = (pts_2d(ij, 2) - yl) / (yh - yl);
%         if (yh-yl) == 0
%             % get pixel values directly
%         else
%             frac_c = (yh - pts_2d(ij, 2)) / (yh - yl);
%             frac_d = (pts_2d(ij, 2) - yl) / (yh - yl);
%         end
%         
%         if (xr-xl) == 0
%             % get pixel values directly
%         else
%             frac_a = (xr - pts_2d(ij, 1)) / (xr - xl);
%             frac_b = (pts_2d(ij, 1) - xl) / (xr - xl);
%         end
            
        

        % get intensity values
        % img frame has 0,0 at top left, not bottom left!!!
        % NOW THINK LIKE OPENCV PYTHON
        % what happens if indexing is out of bounds?
        A = img(yh, xl);
        B = img(yh, xr);
        C = img(yl, xl);
        D = img(yl, xr);

        % bilinear high, bilinear low
        bh = frac_a * A + frac_b * B;
        bl = frac_a * C + frac_b * D;
        final_val = frac_c * bl + frac_d * bh;
        
        if isnan(final_val)
            final_val = 0;
        end
        
        pts_binter(ij) = final_val;
    end
end
