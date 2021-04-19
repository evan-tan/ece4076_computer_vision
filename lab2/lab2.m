%%
close all; clear all; clc;
format short; format compact;

% load Image
img = im2double(imread('mandrill.jpg'));
% image flattened from 3D to 2D
% flatten so we can iterate in 1 shot instead of 2 for loops
new_rows = size(img, 1) * size(img, 2);
new_cols = 3;
img_flat = reshape(img, new_rows, new_cols);
%% task 1,2 & 3 kmeans clustering algorithm with vizualization
%{
Too few clusters => lose detail i.e. extreme case of 2 clusters gives
binary image basically
TOo many clusters => increased detail, i.e. extreme case of 10 gives image
almost the same as original image. clusters here don't tell you much and
this operation is computationally expensive.
%}

% number of clusters
K = 4;
% number of iterations
n_iter = 10;
% set false only if you want the end results
viz = true;
[img_clustered, centroids_history] = my_kmeans(img, n_iter, K, viz);

figure
subplot(1,2,1); imshow(img); title('original image')
subplot(1,2,2); imshow(img_clustered); title('kmeans')



%% task 4 & 5 kmeans++ clustering
for n = 1:n_iterations
    fprintf("Iter: %d\n", n)
    % compute labels
    for ii = 1:size(img_flat, 1)
        for k = 1:K
            % go through each centroid, and calculate distance
            % column in distances represent distance for each centroid
            distances(ii, k) = norm(img_flat(ii, :) - centroids(k, :));
        end
        % determine minimum distance for current pixel, and closest centroid
        [dist, idx] = min(distances(ii, 1:K));
        % store centroid labels for each pixel
        labels(ii) = idx;
        % store minimum distance for each pixel
        min_dist(ii) = dist;
    end

    figure(2)
    plot3(R, G, B, 'o','Color', 'b', 'MarkerSize', 2)
    hold on
    % update centroids or "means"
    for ij = 1:K
        % label indices
        label_indices = (labels == ij);
        centroids(ij, :) = mean(img_flat(label_indices, :));
        
        
        curr_centroid = centroids(ij,:);
        r = curr_centroid(1);
        g = curr_centroid(2);
        b = curr_centroid(3);
        plot3(r, g, b, '>','Color', 'r', 'MarkerSize', 5)
       
        % assign pixels their respective centroids
        idx = find(labels == ij);
        img_tmp(idx, :) = repmat(centroids(ij, :), size(idx, 1), 1);
    end
    hold off
    % unflatten image - reshape from 2D to 3D
    img_final = reshape(img_tmp, size(img, 1), size(img, 2), 3);
    figure(1)
    subplot(1, 2, 2)
    imshow(img_final)
    title('segmented')
%     if n < n_iterations
%         input("Waiting for keypress\n")
%     end
end

fprintf("Final centroids:\n")
scaled_centroids = 255 * centroids;
disp(scaled_centroids)
