function [silhouettefValues, daviesBouldinfValues, dunnfValues, inertiafValues] = kmeans_InternalValidation(data, num_clusters, numFolds)

% Extract features and labels
features = data(:, 1:3);  % assuming the first 3 columns are features
labels = data(:, 4);      % assuming the last column is the class label

% Initialize metrics arrays
silhouetteValues = zeros(1, numFolds);
daviesBouldinValues = zeros(1, numFolds);
dunnValues = zeros(1, numFolds);
inertiaValues = zeros(1, numFolds);

% K-fold cross-validation
cv = cvpartition(labels, 'KFold', numFolds);

for fold = 1:numFolds
    trainIdx = training(cv, fold);
    testIdx = test(cv, fold);
    
    % Training data
    X_train = features(trainIdx, :);
    y_train = labels(trainIdx);
    
    % Testing data
    X_test = features(testIdx, :);
    y_test = labels(testIdx);
    
    % Perform k-means clustering
    [idx, centroids] = kmeans(X_train, num_clusters, 'Replicates', 5);  % you can adjust the number of replicates
    
    % Evaluate metrics
    silhouetteValues(fold) = silhouette(X_train, idx);
    daviesBouldinValues(fold) = daviesbouldin(X_train, idx);
    dunnValues(fold) = dunn(X_train, idx);
    inertiaValues(fold) = sum(pdist2(X_train, mean(X_train(idx, :)).^2));
end

% Display average performance metrics
silhouettefValues = mean(silhouetteValues);
daviesBouldinfValues = mean(daviesBouldinValues);
dunnfValues = mean(dunnValues);
inertiafValues = mean(inertiaValues);

%% FUNCTIONS
% Silhoutte Index
function silhouette_score = silhouette(data, labels)
    % data: n x m matrix, where n is the number of samples and m is the number of features
    % labels: n x 1 vector representing the cluster assignments for each sample
    
    % Number of samples
    n = size(data, 1);
    
    % Unique cluster labels
    unique_labels = unique(labels);
    
    % Number of clusters
    num_clusters = numel(unique_labels);
    
    % Calculate pairwise distance matrix
    distance_matrix = pdist2(data, data);
    
    % Initialize silhouette scores
    silhouette_scores = zeros(n, 1);
    
    % Loop over each sample
    for i = 1:n
        % Get the cluster label for the current sample
        current_label = labels(i);
        
        % Calculate average distance to samples in the same cluster (a)
        same_cluster_distances = distance_matrix(i, labels == current_label);
        a = mean(same_cluster_distances);
        
        % Initialize minimum average distance to samples in other clusters (b)
        b = Inf;
        
        % Loop over other clusters
        for j = 1:num_clusters
            if j ~= current_label
                % Calculate average distance to samples in other clusters
                other_cluster_distances = distance_matrix(i, labels == unique_labels(j));
                b_j = mean(other_cluster_distances);
                
                % Update minimum distance
                b = min(b, b_j);
            end
        end
        
        % Calculate silhouette score for the current sample
        silhouette_scores(i) = (b - a) / max(a, b);
    end
    
    % Calculate overall silhouette score
    silhouette_score = mean(silhouette_scores);
end

% Davies-Bouldin Index
function dbIndex = daviesbouldin(X, idx)
    k = max(idx);
    centroids = zeros(k, size(X, 2));
    for i = 1:k
        centroids(i, :) = mean(X(idx == i, :));
    end
    
    dbIndex = 0;
    for i = 1:k
        for j = 1:k
            if i ~= j
                dists = pdist2(X(idx == i, :), centroids(j, :));
                avgDist1 = mean(dists);
                
                dists = pdist2(X(idx == j, :), centroids(j, :));
                avgDist2 = mean(dists);
                
                dbIndex = dbIndex + (avgDist1 + avgDist2) / pdist2(centroids(i, :), centroids(j, :));
            end
        end
    end
    dbIndex = dbIndex / k;
end

% Dunn Index
function dunnIndex = dunn(X, idx)
    k = max(idx);
    centroids = zeros(k, size(X, 2));
    for i = 1:k
        centroids(i, :) = mean(X(idx == i, :));
    end
    
    maxIntraClusterDistance = 0;
    for i = 1:k
        dists = pdist2(X(idx == i, :), centroids(i, :));
        maxIntraClusterDistance = max(maxIntraClusterDistance, max(dists));
    end
    
    minInterClusterDistance = inf;
    for i = 1:k
        for j = 1:k
            if i ~= j
                dist = pdist2(centroids(i, :), centroids(j, :));
                minInterClusterDistance = min(minInterClusterDistance, dist);
            end
        end
    end
    
    dunnIndex = minInterClusterDistance / maxIntraClusterDistance;
end
end
