function [output_img] = squish(input_img)
    % SQUISH Rescales pixel values if needed
    % Input(s):
    %   input_img => input image
    % Output(s):
    %   output_img => output image

    % main loop and shit
    if max(max(input_img)) > 1
        output_img = rescale(input_img, 0, 1);
    else
        output_img = input_img;
    end
end
