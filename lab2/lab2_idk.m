%%
close all; clear all; clc;
format short; format compact;

%% loading
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
n_iterations = 10;

% select initial centroids
centroid_indices = ceil(rand(K, 1) * size(img_flat, 1));
centroids = img_flat(centroid_indices, :);

assert(isrow(centroid_indices) | iscolumn(centroid_indices))
% store distance of each channel of each pixel to centroids
distances = zeros(size(img_flat, 1), K);
% store label for each pixel with index of nearest centroid
labels = zeros(size(img_flat, 1), 1);
% determine minimum distance of each pixel
min_dist = zeros(size(labels));

img_tmp = zeros(size(img_flat));
fprintf("Number of clusters: %d\n", K)
fprintf("Initial centroids:\n")
scaled_centroids = 255 * centroids;
disp(scaled_centroids)

figure
figure(1)
subplot(1, 2, 1)
imshow(img)
title('original image')

figure
figure(2)
R = img(:, 100, 1);
G = img(:, 100, 2);
B = img(:, 100, 3);
R = reshape(R, size(R, 1) * size(R, 2), 1);
G = reshape(G, size(G, 1) * size(G, 2), 1);
B = reshape(B, size(B, 1) * size(B, 2), 1);
S = zeros(size(R,1),3);
plot3(R, G, B, 'o','Color', 'b', 'MarkerSize', 2)
hold on
for kk = 1:K
   figure(2)
   curr_centroid = centroids(kk,:);
   r = curr_centroid(1);
   g = curr_centroid(2);
   b = curr_centroid(3);
   plot3(r, g, b, 'o','Color', 'r', 'MarkerSize', 3)

end
hold off

% TODO: convert this into a function
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
        plot3(r, g, b, 'o','Color', 'r', 'MarkerSize', 5)
       
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
