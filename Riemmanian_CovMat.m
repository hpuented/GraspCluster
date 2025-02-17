load all_data.mat
load EEG_channels.mat
load datGraspCateg_sub10.mat

%% Observation: MRCP signal (grand average) and logarithmic mapping of the covariance matrices for each grasp
data_obs = all_data.Observation;
patients = fieldnames(data_obs);

avg_obs = cell(33,1);
clog_obs = cell(33,1);

for grasp = 1:33
    % Step 1. Grand average for each grasp condition
    avg_obs_i = (data_obs.(patients{1}){grasp,1} + data_obs.(patients{2}){grasp,1} + data_obs.(patients{3}){grasp,1} + ...
        data_obs.(patients{4}){grasp,1} + data_obs.(patients{5}){grasp,1} + data_obs.(patients{6}){grasp,1} + ...
        data_obs.(patients{7}){grasp,1} + data_obs.(patients{8}){grasp,1} +data_obs.(patients{9}){grasp,1} + ...
        data_obs.(patients{10}){grasp,1})/10;

    time = {1,1:8};
    trials = {1,1:8};
    
    for j = 1:8
        time{1,j} = 50:400;  % Time of interest 0.5 to 4 seconds of execution
        trials{1,j} = squeeze(avg_obs_i(:,j,50:400));
    end
    
    % Create Fieldtrip structure 
    eeg_ft = struct();
    eeg_ft.label = EEG_channels';
    eeg_ft.time = time; %1x8 repetitions, each repetition 400 timepoints
    eeg_ft.trial = trials;
    
    cfg = [];
    cfg.covariance = 'yes';
    avg_obs{grasp,1} = ft_timelockanalysis(cfg, eeg_ft); % Timelocked average across repetitions

    % Step 2. Riemannian Geometry
    % Define the Riemannian manifold
    manifold = sympositivedefinitefactory(size(avg_obs{grasp,1}.cov, 1));
    
    % Perform logarithmic mapping to the tangent space
    clog_obs{grasp,1} = manifold.log(avg_obs{grasp,1}.cov, eye(size(avg_obs{grasp,1}.cov, 1)));
end

%% Execution: MRCP signal (grand average) and logarithmic mapping of the covariance matrices for each grasp
data_ex = all_data.Execution;

avg_ex = cell(33,1);
clog_ex = cell(33,1);

for grasp = 1:33
    % Step 1. Grand average for each grasp condition
    avg_ex_i = (data_ex.(patients{1}){grasp,1} + data_ex.(patients{2}){grasp,1} + data_ex.(patients{3}){grasp,1} + ...
        data_ex.(patients{4}){grasp,1} + data_ex.(patients{5}){grasp,1} + data_ex.(patients{6}){grasp,1} + ...
        data_ex.(patients{7}){grasp,1} + data_ex.(patients{8}){grasp,1} + data_ex.(patients{9}){grasp,1} + ...
        data_ex.(patients{10}){grasp,1})/10;

    time = {1,1:8};
    trials = {1,1:8};
    
    for j = 1:8
        time{1,j} = 50:400;  % Time of interest 0.5 to 4 seconds of execution
        trials{1,j} = squeeze(avg_ex_i(:,j,50:400));
    end
    
    % Create Fieldtrip structure 
    eeg_ft = struct();
    eeg_ft.label = EEG_channels';
    eeg_ft.time = time; %1x8 repetitions, each repetition 400 timepoints
    eeg_ft.trial = trials;
    
    cfg = [];
    cfg.covariance = 'yes';
    avg_ex{grasp,1} = ft_timelockanalysis(cfg, eeg_ft); % Timelocked average across repetitions

    % Step 2. Riemannian Geometry
    % Define the Riemannian manifold
    manifold = sympositivedefinitefactory(size(avg_ex{grasp,1}.cov, 1));
    
    % Perform logarithmic mapping to the tangent space
    clog_ex{grasp,1} = manifold.log(avg_ex{grasp,1}.cov, eye(size(avg_ex{grasp,1}.cov, 1)));
end

%% Compute the distance between the covariance matrices
log_distance = cell(33,1);

% Option 1: It gives 1 value and warning error...
% for grasp = 1:33
%     log_distance{grasp,1} = manifold.dist(clog_obs{grasp,1}, clog_ex{grasp,1});
% end

% Option 2:
for grasp = 1:33
    log_distance{grasp,1} = clog_obs{grasp,1} - clog_ex{grasp,1};
end

%% Plots (33 grasps)
for i = 1:33
    % Plotting the covariance matrices
    figure;
    subplot(1,3,1);
    imagesc(avg_obs{i,1}.cov);
    title('Observation Covariance Matrix');
    axis square;
    
    subplot(1,3,2);
    imagesc(avg_ex{i,1}.cov);
    title('Execution Covariance Matrix');
    axis square;
    
    sgtitle('Comparison of Covariance Matrices');
    colormap('jet');
    
    % Plotting the Log-Euclidean distance
    subplot(1,3,3);
    surf(log_distance{i,1}); % bar, imagesc or surf for a more detailed representation
    title('Log-Euclidean Distance');
    xlabel('Channel');
    ylabel('Channel')
    zlabel('Distance');
    axis square;
    colormap('jet');
end

%% Plots (for one grasp type)
% Plotting the covariance matrices
figure;
subplot(1,2,1);
imagesc(avg_obs{1,1}.cov, [-1,15]);
title('Observation Covariance Matrix');
axis square;
colorbar;
%zlim([-0.5, 15]);

subplot(1,2,2);
imagesc(avg_ex{1,1}.cov, [-1,15]);
title('Execution Covariance Matrix');
axis square;
colorbar;

sgtitle('Comparison of Covariance Matrices');
colormap('jet');

% Plotting the Log-Euclidean distance
figure;
surf(log_distance{1,1}+10*ones(64));
%zlim([5, 55]);
hold on
imagesc(log_distance{1,1}); % bar, imagesc or surf for a more detailed representation
title('Log-Euclidean Distance');
xlabel('Channel');
ylabel('Channel')
zlabel('Distance');
axis square;
colormap('parula');
colorbar; % zlim([5, 55])
