function [result] = colorize_gradients(gradient_orient, directions)
    % COLORIZE_GRADIENTS Colorize gradients, by feeding gradient orientation
    % Input(s):
    %   gradient_orient => gradient orientation matrix
    %   directions => cardinal directions matrix
    % Output(s):
    %   output_img => output image

    pink = [255, 0, 127];
    purple = fliplr(pink);
    blue = [0, 0, 255];
    cyan = [0, 1, 1] * 255;
    green = [0, 255, 0];
    yellow = fliplr(cyan);
    orange = [255, 127, 0];
    red = [255, 0, 0];

    % main loop and shit
    if max(max(input_img)) > 1
        output_img = rescale(input_img, 0, 1);
    else
        output_img = input_img;
    end
end
