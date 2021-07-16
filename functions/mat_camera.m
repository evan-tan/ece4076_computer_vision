function [K] = mat_camera(focal_len, principal_pt, skew)
    % MAT_CAMERA Generate camera matrix K from principal point and focal length
    % Input(s):
    %   focal_len => focal length
    %   principal_pt => 1X2 principal point coordinates in image frame
    %               i.e. for a 640 X 480 image with principal pt in centre
    %               the coords will be (320, 240)
    %   skew => 
    % Output(s):
    %   K => camera matrix

    assert(length(principal_pt) == 2)

    K = [
        focal_len,  skew,       principal_pt(1);
        0,          focal_len,  principal_pt(2);
        0,          0,          1
        ];
end
