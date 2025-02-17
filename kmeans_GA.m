addpath C:\Users\helen\Documentos\UT\2A\3.Code\Scripts\data
load all_data.mat
load EEG_channels.mat
load datGraspCateg_sub10.mat

data = all_data.Execution;
patients = fieldnames(data);

addpath C:\Users\helen\Documentos\UT\2A\3.Code\FieldTrip
ft_defaults

%% Step 1. Create 1 grand average for each grasp condition 
avg_grasp = cell(33,1);

for grasp = 1:33
    avg_grasp{grasp,1} = (data.(patients{1}){grasp,1} + data.(patients{2}){grasp,1} + data.(patients{3}){grasp,1} + ...
        data.(patients{4}){grasp,1} + data.(patients{5}){grasp,1} + data.(patients{6}){grasp,1} + ...
        data.(patients{7}){grasp,1} + data.(patients{8}){grasp,1} + data.(patients{9}){grasp,1} + ...
        data.(patients{10}){grasp,1})/10;
end

%% Step 2. Create Fieldtrip structure
%  FCz (n=46), C1 (n=48), Cz (n=14), C2 (n=49)
channel = 49;
toi = 50:400;

avg_features = mean_features(avg_grasp, toi, EEG_channels, channel);

%% Cloud of points
figure
plot3(avg_features(:,1),avg_features(:,2),avg_features(:,3),'.','markersize',20,'color','blue');
xlabel('EEG amplitude');
ylabel('Covariance');
zlabel('Phase');
grid on

%% K-means algorithm
avg_features(:,4) = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % Taxonomy groups: Power and Precision Grasps
%avg_features(:,4) = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % Taxonomy groups: Thumb used

%% Evaluate the optimal number of clusters using the silhouette criterion
evaluation = evalclusters(avg_features,"kmeans","silhouette","KList",1:6);
plot(evaluation)

%% Based on: Power, Intermediate, and Precision Grasps
avg_features(:,4) = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % Taxonomy groups: Power and Precision Grasps

K = 3; % Kmeans algorithm based on the three groups (taxonomy literature)

% Perform K-means clustering
rng(1); % Set random seed for reproducibility
[idx, centers] = kmeans(avg_features, K); % idx contains cluster assignments for each grasp condition, and centers contains the cluster centroids

figure;
scatter3(avg_features(:, 1), avg_features(:, 2), avg_features(:, 3), 36, idx, 'filled');
hold on;
scatter3(centers(:, 1), centers(:, 2), centers(:, 3), 'kx', 'LineWidth', 1.5);
hold off;
%legend('Cluster 1','Cluster 2','Cluster 3','Cluster Centroid')
xlabel('EEG amplitude');
ylabel('Covariance');
zlabel('Phase');
title('K-means Clustering in 3D');

%% K-means algorithm based on: Thumb position
avg_features(:,4) = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % Taxonomy groups: Thumb used

K = 2;

% Perform K-means clustering
rng(1); % Set random seed for reproducibility
[idx, centers] = kmeans(avg_features, K); % idx contains cluster assignments for each grasp condition, and centers contains the cluster centroids

figure;
scatter3(avg_features(:, 1), avg_features(:, 2), avg_features(:, 3), 36, idx, 'filled');
hold on;
scatter3(centers(:, 1), centers(:, 2), centers(:, 3), 'kx', 'LineWidth', 1.5);
hold off;
%legend('Cluster 1','Cluster 2','Cluster 3','Cluster Centroid')
xlabel('EEG amplitude');
ylabel('Covariance');
zlabel('Phase');
title('K-means Clustering in 3D');
