function [processed_img, centroids_history] = my_kmeans(img, n_iter, K, viz)
    %MY_KMEANS Summary of this function goes here
    %   Detailed explanation goes here
    % Input(s):
    %   img         => img to apply k_means_clustering to
    %   n_iter      => number of iterations
    %   K           => number of clusters/centroids/"means"
    % Output(s):
    %   processed_img       => output img after convolution
    %   centroids_history   => centroids at every iteration

    if nargin == 3
        % whether or not to visualize kmeans
        viz = true;
    end
    
    % source random generator seed from clock
    rng(ceil(sum(clock)))
    
    
    % image flattened from 3D to 2D
    % flatten so we can iterate in 1 shot instead of 2 for loops
    new_rows = size(img, 1) * size(img, 2);
    new_cols = 3;
    % flatten image
    img_flat = reshape(img, new_rows, new_cols);

    % select initial centroids
    centroid_indices = ceil(rand(K, 1) * size(img_flat, 1));
    centroids = img_flat(centroid_indices, :);
    assert(isrow(centroid_indices) | iscolumn(centroid_indices))

    distances = zeros(size(img_flat, 1), K); % distance of each channel of each pixel to centroids
    labels = zeros(size(img_flat, 1), 1); % label for each pixel with index of nearest centroid
    min_dist = zeros(size(labels)); % minimum distance of each pixel

    img_tmp = zeros(size(img_flat));
    processed_img = zeros(size(img));
    centroids_history = cell(n_iter, 1);
    
    if viz == true
        original = figure;
        
        R = img(:, 100, 1); % x-axis
        G = img(:, 100, 2); % y-axis
        B = img(:, 100, 3); % z-axis
        COLORS = img(:, 100,:);
        % flatten 1D/2D tensors
        R = reshape(R, size(R, 1) * size(R, 2), 1);
        G = reshape(G, size(G, 1) * size(G, 2), 1);
        B = reshape(B, size(B, 1) * size(B, 2), 1);
        MARKER_SIZE = repmat(5,numel(R),1);
        COLORS = reshape(COLORS, size(COLORS, 1) * size(COLORS, 2), 3);
        
        % plot original image downsampled
        figure(original)
        scatter3(R, G, B, MARKER_SIZE,COLORS)
    end
    
    for n = 1:n_iter
        if viz == true
            fprintf("Iter %d\n", n)
        end
        
        % compute labels
        for ii = 1:size(img_flat, 1)
            for k = 1:K
                % go through each centroid, and calculate distance
                % column in distances represent distance for each centroid
                distances(ii, k) = norm(img_flat(ii, :) - centroids(k, :));
            end
            % determine minimum distance for current pixel, and closest centroid
            [dist, idx] = min(distances(ii, 1:K));
            labels(ii) = idx;       % store centroid labels for each pixel
            min_dist(ii) = dist;    % store minimum distance for each pixel
        end

        % update centroids or "means"
        
        figure(original)
        for ij = 1:K
            label_indices = (labels == ij);                     % label indices
            centroids(ij, :) = mean(img_flat(label_indices, :)); % update centroids

            idx = find(labels == ij); % assign pixels their respective centroids
            img_tmp(idx, :) = repmat(centroids(ij, :), size(idx, 1), 1);
        end
        
        % show updating of centroids
        if viz == true
            hold on
            r = centroids(:,1);
            g = centroids(:,2);
            b = centroids(:,3);
            MARKER_SIZE = repmat(25,numel(r),1);
            % COLORS = centroids(ij,:);
            % COLORS = reshape(COLORS, size(COLORS, 1) * size(COLORS, 2), 3);
            COLORS = repmat([0.8,0.3,0.7], numel(r), 1);
            
            % plot centroids on same scatter
            figure(original)
            scatter3(r, g, b, MARKER_SIZE,COLORS, 'x')
            view(55,15)
            hold off
        end
        disp(centroids)
        
        % unflatten image - reshape from 2D to 3D
        processed_img = reshape(img_tmp, size(img, 1), size(img, 2), 3);
        centroids_history{n} = centroids(:, :);
    end
end
