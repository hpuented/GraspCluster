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
%avg_features(:,4) = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % Taxonomy groups: Power and Precision Grasps
avg_features(:,4) = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % Taxonomy groups: Thumb used

%% Fuzzy c-means
%options = fcmOptions(NumClusters=[1 2 3], Verbose=false);
options = fcmOptions(NumClusters=2);
[centers, U, objFun, info] = fcm(avg_features,options);
%info.OptimalNumClusters;

%% Plot the clustered data using the optimal clustering results. 
% First classify each data point into the cluster with the largest membership value.
maxU = max(U);
index1 = find(U(1,:) == maxU);
index2 = find(U(2,:) == maxU);
%index3 = find(U(3,:) == maxU);

%% Plot the clustered data and cluster centers.
figure
hold on
scatter3(avg_features(index1,1),avg_features(index1,2),avg_features(index1,3), 36, 'filled')
scatter3(avg_features(index2,1),avg_features(index2,2),avg_features(index2,3), 36, 'filled')
% scatter3(avg_features(index3,1),avg_features(index3,2),avg_features(index3,3), 36, 'filled')
plot3(centers(:,1),centers(:,2),centers(:,3),'kx', 'LineWidth', 1.5)
xlabel('EEG amplitude');
ylabel('Covariance');
zlabel('Phase');
title('Fuzzy c-means Clustering in 3D');
view([-11 63])
hold off
grid on