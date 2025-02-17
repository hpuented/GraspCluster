function [ariValues, nmiValues, purityValues] = kmeans_ExternalValidation(data, k)

% Extract features and labels
features = data(:, 1:3); 
labels = data(:, 4);

% Split data into 70% training and 30% testing
cv = cvpartition(labels, 'HoldOut', 0.3);

idxTrain = training(cv); % Logical index for training set
idxTest = test(cv);      % Logical index for testing set

% Training data
X_train = features(idxTrain, :);
%y_train = labels(idxTrain);

% Testing data
X_test = features(idxTest, :);
y_test = labels(idxTest);

% Perform k-means clustering
[~, centroids] = kmeans(X_train, k);

% Predict clusters for test data
idx_test = kmeans(X_test, k, 'Start', centroids, 'Replicates', 1); 

% Adjust cluster indices for evaluation metrics
idx_test = bestMap(y_test, idx_test);

ariValues = adjustedrand(y_test, idx_test);
nmiValues = normalizedmutualinfo(y_test, idx_test);
purityValues = purity(y_test, idx_test);

%% FUNCTIONS
% Adjusted Rand Index
function ariValue = adjustedrand(labels_true, labels_pred)
    % labels_true: true labels
    % labels_pred: predicted labels
    
    contingency_matrix = contingency(labels_true, labels_pred);
    
    % Compute the Adjusted Rand Index
    a = sum(sum(contingency_matrix, 2).^2);
    b = sum(sum(contingency_matrix, 1).^2);
    c = sum(sum(contingency_matrix.^2)) - a - b;
    
    expected_index = (a * b + b * c + c * a) / (a + b)^2;
    index = sum(sum(contingency_matrix.^2)) - expected_index;
    
    max_index = (a + b + c)^2 / (4 * (a + b + c));
    min_index = 0.5 * ((a + c) * (a + b) + (b + c) * (a + b)) / (a + b + c);
    
    ariValue = (index - expected_index) / (max_index - expected_index);
    
    % Ensure that the ARI is within the valid range [-1, 1]
    ariValue = max(min(ariValue, 1), -1);
end

function cont_matrix = contingency(labels_true, labels_pred)
    % Create a contingency matrix
    num_true = max(labels_true);
    num_pred = max(labels_pred);
    
    cont_matrix = zeros(num_true, num_pred);
    
    for i = 1:num_true
        for j = 1:num_pred
            cont_matrix(i, j) = sum(labels_true == i & labels_pred == j);
        end
    end
end


% Normalized Mutual Information
function nmiValue = normalizedmutualinfo(labels_true, labels_pred)
    % labels_true: true labels
    % labels_pred: predicted labels
    
    cont_matrix = contingency(labels_true, labels_pred);
    
    % Compute entropy of true and predicted labels
    H_true = entropy(labels_true);
    H_pred = entropy(labels_pred);
    
    % Compute mutual information
    mutual_info = 0;
    for i = 1:size(cont_matrix, 1)
        for j = 1:size(cont_matrix, 2)
            if cont_matrix(i, j) > 0
                p_ij = cont_matrix(i, j) / sum(cont_matrix(:));
                p_i = sum(cont_matrix(i, :)) / sum(cont_matrix(:));
                p_j = sum(cont_matrix(:, j)) / sum(cont_matrix(:));
                
                mutual_info = mutual_info + p_ij * log2(p_ij / (p_i * p_j));
            end
        end
    end
    
    % Compute normalized mutual information
    nmiValue = mutual_info / sqrt(H_true * H_pred);
end

function H = entropy(labels)
    % Compute the entropy of a set of labels
    
    p = histcounts(labels, 'Normalization', 'probability');
    H = -sum(p .* log2(p + eps));
end


% Purity
function purityValue = purity(labels_true, labels_pred)
    n = length(labels_true);
    k = length(unique(labels_pred));
    
    M = zeros(k, max(labels_true));
    for i = 1:k
        indices = find(labels_pred == i);
        cluster_labels = labels_true(indices);
        M(i, :) = hist(cluster_labels, 1:max(labels_true));
    end
    
    purityValue = sum(max(M, [], 2)) / n;
end

% Helper function for best mapping of cluster indices

function new_labels = bestMap(labels1, labels2)
    % labels1: true labels
    % labels2: predicted labels
    
    num_samples = length(labels1);
    num_clusters = max(max(labels1), max(labels2));
    
    G = zeros(num_clusters, num_clusters);
    
    for i = 1:num_clusters
        for j = 1:num_clusters
            G(i, j) = sum(labels1 == i & labels2 == j);
        end
    end
    
    % Applying the Hungarian algorithm for assignment
    assignment = munkres(-G);
    
    % Map the labels
    new_labels = zeros(size(labels2));
    for i = 1:num_samples
        new_labels(labels2 == assignment(labels1(i))) = labels1(i);
    end
end
end
