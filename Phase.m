% PHASE COMPUTATION
load all_data.mat
load EEG_channels.mat
load datGraspCateg_sub10.mat

addpath C:\Users\helen\Documentos\UT\2A\3.Code\FieldTrip
ft_defaults

addpath C:\Users\helen\Documentos\UT\2A\3.Code\CircStat

data = all_data.Execution; % Stage: Fixation, Observation or Execution
patients = fieldnames(data);

%% Step 0. Create 1 grand average for each grasp condition 
avg_grasp = cell(33,1);

for grasp = 1:33
    avg_grasp{grasp,1} = (data.(patients{1}){grasp,1} + data.(patients{2}){grasp,1} + data.(patients{3}){grasp,1} + ...
        data.(patients{4}){grasp,1} + data.(patients{5}){grasp,1} + data.(patients{6}){grasp,1} + ...
        data.(patients{7}){grasp,1} + data.(patients{8}){grasp,1} + data.(patients{9}){grasp,1} + ...
        data.(patients{10}){grasp,1})/10;
end

%% Step 1. Build matrix of phases per each grasp condition
phases_mat = cell(33,1);
inst_ampl = cell(33,1);

for grasp_cond = 1:33
    time = {1,8};
    trials = {1,8};
    
    for j = 1:8
        time{1,j} = 1:400;
        trials{1,j} = squeeze(avg_grasp{grasp_cond,1}(:,j,:));
    end
    
    % Create Fieldtrip structure 
    eeg_ft = struct();
    eeg_ft.label = EEG_channels';
    eeg_ft.time = time; %1x8 repetitions, each repetition 400 timepoints
    eeg_ft.trial = trials;
    
    cfg = [];
    eeg_avg = ft_timelockanalysis(cfg, eeg_ft); % Timelocked average across repetitions

    % Phase computation
    hilbert_i = hilbert(eeg_avg.avg); % Hilbert trasnform per grasp condition
    inst_ampl{grasp_cond, 1} = abs(hilbert_i);
    phzr = atan2(imag(hilbert_i), real(hilbert_i));
    phzr(phzr < 0) = phzr(phzr < 0) + 2 * pi;
    phases_mat{grasp_cond, 1} = phzr;
end

%% PLOTS
%% Figure 1. Scatter and histograms for phases at moment "0.5" for MRCP
% To plot these Figures go to CircStat folder
TOI = 50:400; % Time of interest (the MRCP starts 0.5 seconds after the execution)

for i = 1:33
    PhaseFrontal{i,1} = phases_mat{i,1}([1:11,37:40,42:46],TOI); 
    PhaseCentral{i,1} = phases_mat{i,1}([13:15,18:21,47:50,52:54],TOI);
    PhaseTemporal{i,1} = phases_mat{i,1}([12,16,17,22,51,55],TOI);
    PhaseParietal{i,1} = phases_mat{i,1}([23:28,32,56:64],TOI);
    PhaseOccipital{i,1} = phases_mat{i,1}([29:31],TOI);

    figure;
    subplot(2,5,1)
    circ_plot(PhaseFrontal{i,1},'pretty','bo',true,'linewidth',2,'color','r'), hold on,
    title_handle = title(''); % Create an empty title
    title_position = get(title_handle, 'Position'); % Get the default position
    title_position(2) = 1.35; % Set the desired height
    set(title_handle, 'String', 'Frontal', 'Position', title_position);
    subplot(2,5,6)
    polarhistogram(PhaseFrontal{i,1},'linewidth',1.5,'FaceColor','r'), hold on,

    subplot(2,5,2)
    circ_plot(PhaseCentral{i,1},'pretty','bo',true,'linewidth',2,'color','r'), hold on,
    title_handle = title('');
    title_position = get(title_handle, 'Position');
    title_position(2) = 1.35;
    set(title_handle, 'String', 'Central', 'Position', title_position);
    subplot(2,5,7)
    polarhistogram(PhaseCentral{i,1},'linewidth',1.5,'FaceColor','r'), hold on,

    subplot(2,5,3)
    circ_plot(PhaseTemporal{i,1},'pretty','bo',true,'linewidth',2,'color','r'), hold on, 
    title_handle = title('');
    title_position = get(title_handle, 'Position');
    title_position(2) = 1.35;
    set(title_handle, 'String', 'Temporal', 'Position', title_position);
    subplot(2,5,8)
    polarhistogram(PhaseTemporal{i,1},'linewidth',1.5,'FaceColor','r'), hold on,

    subplot(2,5,4)
    circ_plot(PhaseParietal{i,1},'pretty','bo',true,'linewidth',2,'color','r'), hold on,     
    title_handle = title('');
    title_position = get(title_handle, 'Position');
    title_position(2) = 1.35;
    set(title_handle, 'String', 'Parietal', 'Position', title_position);
    subplot(2,5,9)
    polarhistogram(PhaseParietal{i,1},'linewidth',1.5,'FaceColor','r'), hold on,

    subplot(2,5,5)
    circ_plot(PhaseOccipital{i,1},'pretty','bo',true,'linewidth',2,'color','r'), hold on,
    title_handle = title('');
    title_position = get(title_handle, 'Position');
    title_position(2) = 1.35;
    set(title_handle, 'String', 'Occipital', 'Position', title_position);
    subplot(2,5,10)
    polarhistogram(PhaseOccipital{i,1},'linewidth',1.5,'FaceColor','r'), hold off,

    sgtitle(strcat('Grasp condition:', 32, datGraspCateg{1,i})) % The unicode value of ' ' is 32
end
