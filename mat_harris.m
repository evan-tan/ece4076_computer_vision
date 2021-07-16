function [M, block_matrices] = mat_harris(x_grad, y_grad)
    % MAT_HARRIS Create Harris matrix using matrices of x and y gradients
    % Input(s):
    %   x_grad  => matrix for x gradients
    %   y_grad => matrix for y gradients
    % Output(s):
    %   M => Harris matrix
    %   block_matrices => each individual block matrix per pixel of the form...
    %                       [I_x^2, I_x*I_y; I_x*I_y, I_y^2]

    assert(isequal(size(x_grad), size(y_grad)))

    block_matrices = cell(size(x_grad));
    M = zeros(2, 2);
    for i = 1:size(block_matrices, 1)
        for j = 1:size(block_matrices, 2)
            block_matrices{i, j} = [x_grad(i, j)^2, x_grad(i, j) * y_grad(i, j);
                                x_grad(i, j) * y_grad(i, j), y_grad(i, j)^2;
                                ];
            M = M + block_matrices{i, j};
        end
    end
end
