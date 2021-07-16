function [norm_coord] = norm_coord(coordinates)
    % NORM_COORD Normalize coordinates 
    % Input(s):
    %   coordinates => N X 3 coordinates in camera frame
    % Output(s):
    %   norm_coord => normalized coordinates in camera frame

    convert_3d = @(mat) horzcat(mat(:, 1) ./ mat(:, 3), mat(:, 2) ./ mat(:, 3));
    norm_coord = convert_3d(coordinates);
    if isrow(norm_coord)
        norm_coord = horzcat(norm_coord, 1);
    else
        norm_coord = horzcat(norm_coord, ones(length(norm_coord),1));
    end
end
