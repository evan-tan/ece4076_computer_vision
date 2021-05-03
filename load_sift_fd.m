function [sift_fd, fd_values] = load_sift_fd(file_name)
    % LOAD_SIFT_FD Load SIFT Descriptor values for file
    % Input(s):
    %   file_name => string for file name
    % Output(s):
    %   sift_fd     => N X 4 SIFT feature descriptor
    %                   Format: [x,y,scale,orientation]
    %   fd_values   => N X 128 SIFT feature descriptor values
    %                   NOTE: This asssume 5th column onwards are just %                         descriptor values!!!


    % error checking
    assert(isstring(file_name))

    % load from file
    sift_data = importdata(file_name);
    sift_fd = sift_data(:,1:4);
    fd_values = sift_data(:,5:end);

end
