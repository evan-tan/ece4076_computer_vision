function [E] = mat_essential(trans_mat, rot_mat)
    % MAT_ESSENTIAL Generate essential matrix E from matrix t and R
    % Input(s):
    %   trans_mat => Translation Matrix, T
    %   rot_mat => Rotation Matrix, R
    % Output(s):
    %   E => Essential Matrix, E

    assert(length(trans_mat) == 3)
    assert(isequal(rot_mat, [3, 3]))
    % generate cross product matrix from given 1 X 3 matrix
    cross_mat = @(mat)[0, -mat(3), mat(2); mat(3), 0, -mat(1); -mat(2), mat(1), 0];

    E = cross_mat(trans_mat) * rot_mat;
end
