function [match_ids] = match_keypoints(f_vals, f_desc, pair, fig_obj)
    % MATCH_KEYPOINTS   Match keypoints between pairs of images using feature
    %                   descriptors
    % Input(s):
    %   f_vals => 1 X M cell of M feature values,
    %                   each object is N X 128
    %   f_desc => 1 X M cell of M feature descriptors,
    %                   each object is N X 4 [x,y,scale,orientation]
    %   pair    => 1 X 2    pairwise indices of images you want
    %                       to use for triangulation
    %   fig_obj =>  figure to plot on
    % Output(s):
    %   match_ids => N X 2  pairwise match indices in f_desc that correspond to                    pair(1) and pair(2)

    assert(size(pair, 1) < length(f_desc))
    if nargin < 4
        fig_obj = false;
    end

    % image indices
    imA = pair(1);
    imB = pair(2);
    
    % offset columns to plot 
    offset_cols = 640;
    
    match_ids = [];
    n_rows = size(f_desc{imA}, 1);
    for ij = 1:n_rows
        vecA = f_vals{imA}(ij, :);
        % compute difference in desscriptor values between imA and imB
        all_dist = zeros(n_rows, 1);
        for kk = 1:n_rows
            % compare current keypoint values to all keypoints in imB
            tmp_vec = vecA - f_vals{imB}(kk, :);
            all_dist(kk) = norm(tmp_vec, 2);
        end

        % find 2 smallest distances, ASCENDING order
        [vals, ids] = mink(all_dist, 2);

        % found good match
        if vals(1) / vals(2) <= 0.5
            % save pair of good matches i.e rows in f_desc
            match_ids = [match_ids; ij ids(1)];

            if fig_obj ~= false
                kpA = f_desc{imA}(ij, 1:2);
                kpB = f_desc{imB}(ids(1), 1:2);
                % shift imB's x-coordinate
                kpB(1) = kpB(1) + offset_cols;
                x = [kpA(1) kpB(1)];
                y = [kpA(2) kpB(2)];
                hold on
                figure(fig_obj);
                line(x, y, 'Color', 'green');
            end
        else
            % no match found
        end
    end
    hold off

    fprintf("Ratio matching between %d and %d got %d matches\n", imA, imB, size(match_ids,1))
end
