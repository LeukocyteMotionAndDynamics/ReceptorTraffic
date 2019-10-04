% Script to read the area of cluster in the wound from the Microsoft(R) Excel 
% file that is generated from Imaris(R) and calculate the mean cluster size

% Last Update:  30 May 2019


%% Initialise some parameters

% Define the number of experiments (*)
num_exp = 5;

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, pixel size and experiment starting time (*)
    [name, pixel, exp_start] = data_cluster(exp_id);
    
    
    %% Load the excel file with the 'neutrophil position' spreadsheet
    
    % Choose the directory of files (*)
    directory = 'Data\Data Cluster';
    
    % Choose the laser wound file
    filename = [name '.xls'];
    
    % Read the file with the worksheet 'Position'
    file = fullfile(directory, filename);
    [cluster_size, time, n] = read_xls_file_vector(file, 'Area');
    
    % Define the time interval
    time_int = 30;
    
    % Define the time to start
    time_start = 15;
    
    % Define the time duration of tracking in minutes
    time_total = 120;
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Tranform the time vector of time-frames into actual time-vector
    time = time + exp_start * 60 / time_int;
    
    % Empty these cells in 'area' variable
    cluster_size(time >= fram_track_end) = nan;
    cluster_size(time < fram_track_start) = nan;
    
    % Define the threshold for cluster size
    clust_thresh = 60;
    
    % Empty the small clusters
    time(cluster_size < clust_thresh) = [];
    cluster_size(cluster_size < clust_thresh) = [];
    
    % Find the mean experiment cluster size
    cluster_size_mean = nanmean(cluster_size);
    
    
    %% Append data for all experiments for further analysis
    if exp_id == 1
        cluster_size_exp = cluster_size_mean;
    else
        cluster_size_exp = [cluster_size_exp; cluster_size_mean];
    end
        
end


%% Save the list of cluster size (*)
save('cluster_size.mat', 'cluster_size_exp');


