load all_data.mat
load EEG_channels.mat
load datGraspCateg_sub10.mat

%% Step 1. Grand average for each grasp condition
% Observation
data_obs = all_data.Observation;
patients = fieldnames(data_obs);

avg_obs = cell(33,1);

for grasp = 1:33
    avg_obs{grasp,1} = (data_obs.(patients{1}){grasp,1} + data_obs.(patients{2}){grasp,1} + data_obs.(patients{3}){grasp,1} + ...
        data_obs.(patients{4}){grasp,1} + data_obs.(patients{5}){grasp,1} + data_obs.(patients{6}){grasp,1} + ...
        data_obs.(patients{7}){grasp,1} + data_obs.(patients{8}){grasp,1} +data_obs.(patients{9}){grasp,1} + ...
        data_obs.(patients{10}){grasp,1})/10;
end

% Execution
data_ex = all_data.Execution;

avg_ex = cell(33,1);

for grasp = 1:33
    avg_ex{grasp,1} = (data_ex.(patients{1}){grasp,1} + data_ex.(patients{2}){grasp,1} + data_ex.(patients{3}){grasp,1} + ...
        data_ex.(patients{4}){grasp,1} + data_ex.(patients{5}){grasp,1} + data_ex.(patients{6}){grasp,1} + ...
        data_ex.(patients{7}){grasp,1} + data_ex.(patients{8}){grasp,1} + data_ex.(patients{9}){grasp,1} + ...
        data_ex.(patients{10}){grasp,1})/10;
end

%% Step 2. Create structure and plot MRCPs
% Select the channel of interest
% In literature: FCz (n=46), C3 (n=13), Cz (n=14), C4 (n=15)
% AF3 (n=34), Ps (n=58)

for grasp_cond = 3 %1:33
    time = {1,8};
    trials_obs = {1,8};
    trials_ex = {1,8};
    
    for j = 1:8
        time{1,j} = 1:400;
        trials_obs{1,j} = squeeze(avg_obs{grasp_cond,1}(:,j,:));
        trials_ex{1,j} = squeeze(avg_ex{grasp_cond,1}(:,j,:));
    end
    
    % Create Fieldtrip structure 
    eeg_obs = struct();
    eeg_obs.label = EEG_channels';
    eeg_obs.time = time; %1x8 repetitions, each repetition 400 timepoints
    eeg_obs.trial = trials_obs;

    eeg_ex = struct();
    eeg_ex.label = EEG_channels';
    eeg_ex.time = time;
    eeg_ex.trial = trials_ex;

    % Stdshade: Mean and std of the 8 repetitions
    obs_repetitions = zeros(8,400);
    ex_repetitions = zeros(8,400);
    channel = 58; % CHANNEL NUMBER (Parameter to be changed)
    
    for i = 1:8 % Repetitions
        obs_repetitions(i,:) = eeg_obs.trial{1,i}(channel,:);
        ex_repetitions(i,:) = eeg_ex.trial{1,i}(channel,:);
    end
    
%     % Plot 1: MRCPs
%     figure()
%     t = tiledlayout(1,2);
%     
%     for k = 1:2 % Subplots: observation and execution
%         nexttile
%     
%         if k == 1
%             stdshade(obs_repetitions, 0.1)
%             hold on
%             title('Observation')
%         else
%             stdshade(ex_repetitions, 0.1)
%             hold on
%             title('Execution')
%         end
%         
%         xticks(0:50:400)
%         xticklabels(0:0.5:4)
%         xlabel('Time (s)','FontSize',12);
%         ylim([-12 12]);
%         yticks(-12:1:12)
%         yticklabels(-12:1:12)
%         ylabel('Amplitude (\muV)','FontSize',12);
%         
%     end
%     title(t, strcat('Channel:', 32, EEG_channels{1,channel}, 32, '| Grasp condition:', 32, datGraspCateg{1,grasp_cond}),'FontSize',14)
%     pic_name = strcat('graspcondition', num2str(grasp_cond),'.png');
%     %saveas(gcf, fullfile('C:\Users\helen\Documentos\UT\2A\4.Results\MRCPs\Grand_average\Cz', pic_name))
% 
    %---------------------------------------------------------------------------------------------------------------------------
    % Plot 2: Grand average of all trials of the movement-related cortical potentials (MRCPs) with respect to the movement onset
    concatenated_signal = [obs_repetitions, ex_repetitions];
    %concatenated_signal = concatenated_signal(:,200:700); % tROI: [-2, 3] seconds
    concatenated_signal = mean(concatenated_signal);
    %concatenated_signal = smoothdata(concatenated_signal, 'gaussian', 10);
    
    % Create an x-axis vector for the concatenated signal
    x = 1:length(concatenated_signal);
    
    figure()
    plot(x, concatenated_signal,'Color','b','LineWidth',1.5); % Plot the first signal
    hold on;
    plot(x(400+1:end), concatenated_signal(400+1:end),'Color','r','LineWidth',1.5); % Plot the second signal starting where the first one ends
    hold off;
    
    xline(450+1,'LineWidth',1.5);
    
    xlabel('Time (s)','FontSize',12);
    %xlim([1 501]);
    xticks(1:50:800)
    xticklabels(-4:0.5:4)
    ylim([-4.5 7.5]);
    ylabel('Amplitude (\muV)');
    legend('Observation','Execution','Location','southeast');
    title(strcat('Channel:', 32, EEG_channels{1,channel}, 32, '| Grasp condition:', 32, datGraspCateg{1,grasp_cond}),'FontSize',14)
    pic_name = strcat('graspcondition', num2str(grasp_cond),'.png');
    
    % SAVING - Comment in case it was already saved
    %saveas(gcf, fullfile('C:\Users\helen\Documentos\UT\2A\4.Results\1. AnalysisPhase\MRCPs', pic_name))
end

%% Plot of 4 figures (4 channels of interest) for the 3 taxonomies
taxonomy1 = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % 1=Power, 2=Precission, 3=Intermediate
taxonomy2 = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % 1=Abducted, 2=Adducted

for grasp_cond = 1:33
    time = {1,8};
    trials_ex = {1,8};
    
    for j = 1:8
        time{1,j} = 1:400;
        trials_ex{1,j} = squeeze(avg_ex{grasp_cond,1}(:,j,:));
    end
    
    % Create Fieldtrip structure 
    eeg_ex = struct();
    eeg_ex.label = EEG_channels';
    eeg_ex.time = time;
    eeg_ex.trial = trials_ex;

    % Stdshade: Mean and std of the 8 repetitions
    ex_repetitions = zeros(8,400);
    channel = 46; % CHANNEL NUMBER (Parameter to be changed)
    
    for i = 1:8 % Repetitions
        ex_repetitions(i,:) = eeg_ex.trial{1,i}(channel,:);
    end
end

%  FCz (n=46), C1 (n=48), Cz (n=14), C2 (n=49)
channels = [46, 48, 14, 49];

%% Plot of 4 figures (4 channels of interest) for the 3 taxonomies
taxonomy1 = [1 1 1 1 2 2 1 2 3 2 1 1 1 1 3 3 1 2 2 1 3 2 2 2 1 2 3 1 2 3 1 2 1]'; % 1=Power, 2=Precission, 3=Intermediate
taxonomy2 = [2 1 1 2 1 1 2 1 2 1 2 1 1 2 1 2 1 1 1 1 2 1 1 1 1 2 2 1 1 1 1 1 1]'; % 1=Abducted, 2=Adducted





