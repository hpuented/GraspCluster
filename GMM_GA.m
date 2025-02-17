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

%%
%avg_features(:,4) = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % Taxonomy groups: Power and Precision Grasps
avg_features(:,4) = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % Taxonomy groups: Thumb used

%% Gaussian Mixture Model (GMM) clustering
% Step 1: Load your data
data = avg_features;

% Step 2: Specify the number of clusters
k = 2;

% Step 3: Fit GMM to the data
options = statset('MaxIter', 1000); % You can adjust MaxIter based on your data
gmm = fitgmdist(data, k, 'Options', options, 'SharedCovariance', true);

% Step 4: Get the cluster assignments for each data point
idx = cluster(gmm, data);

%% Step 5: Plot the results (optional)
figure;
scatter3(data(:,1), data(:,2), data(:,3), 50, idx, 'filled');
xlabel('EEG amplitude');
ylabel('Covariance');
zlabel('Phase');
title('GMM Clustering in 3D');
