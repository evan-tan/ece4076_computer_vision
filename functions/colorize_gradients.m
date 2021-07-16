function [result] = colorize_gradients(gradient_orient, directions)
    % COLORIZE_GRADIENTS Colorize gradients, by feeding gradient orientation
    % Input(s):
    %   gradient_orient => gradient orientation matrix
    %   directions => cardinal directions matrix
    % Output(s):
    %   result => output image

    pink = [255, 0, 127];
    purple = fliplr(pink);
    blue = [0, 0, 255];
    cyan = [0, 1, 1] * 255;
    green = [0, 255, 0];
    yellow = fliplr(cyan);
    orange = [255, 127, 0];
    red = [255, 0, 0];
    colors = [pink; purple; blue; cyan; green; yellow; orange; red];

    lighter_colors = zeros(size(colors));
    for i = 1:length(colors)
        % current color
        color = colors(i, :);
        for j = 1:length(color)
            if color(j) < 255
                color(j) = color(j) + 50;
            end
        end
        lighter_colors(i, :) = color;
    end
    colors = vertcat(colors, lighter_colors(2:end, :));

    assert(length(colors) == length(directions))

    [r, c] = size(gradient_orient);
    n_channels = 3;
    result = zeros(r, c, n_channels);

    for k = 1:size(gradient_orient, 1)
        for l = 1:size(gradient_orient, 2)
            index_array = gradient_orient(k, l) == directions;
            selected_color = colors(index_array, :);
            result(k, l, :) = selected_color;
        end
    end
end
