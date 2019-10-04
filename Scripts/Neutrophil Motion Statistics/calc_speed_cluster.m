% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel  
% file that is generated from Imaris(R) and calculate the speed of neutrophils
% in cluster

% Last Update:  27 Jun 2019


%% Beginning of file

% Define the number of experiments (*)
num_exp = 5;

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, pixel size, experiment start and wound perimeter (*)
    [name, pixel, exp_start, wound_x, wound_y] = data_tracking(exp_id);
    
    % Define minimum and maximum distance from wound centre to calculate speed
    dist_min = 0; dist_max = 100;
    
    % Define the time interval in seconds
    time_int = 30;
    
    % Define the time that tracking starts in minutes
    time_start = 60;
    
    % Define the time that tracking ends in minutes
    time_total = 120;
    
    % Define the time bin size in minutes
    bin_size = 60;
    
    % Define the time bins in minutes
    time = [time_start:bin_size:time_total];
    
    % Define the time bins in frames
    time_bins = (time*60/time_int);
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Define the time bins to plot in minutes
    time_plot = time(2:end) - bin_size/2;
    
    % Choose whether to save data for experiments; 0 not save, 1 save
    save_exp_all = 1;
    
    
    %% Load the excel file with the 'neutrophil position' spreadsheet
    
    % Choose the directory of data (*)
    dir_data = ['Data'];
    
    % Choose the file
    filename = [name '.xls'];
    
    % Read the file with the worksheet 'Position'
    file = fullfile(dir_data, filename);
    [xx, yy, ~, ~, ~, first_frame] = read_xls_file_time(file, 'Position');
    
    % Append NaNs if tracking does not start from beginning of imaging
    if first_frame > 1
        xx = [nan((first_frame-1),size(xx,2)); xx];
        yy = [nan((first_frame-1),size(yy,2)); yy];
    end
    
    % Append NaNs if experiment does not start from 0 minutes
    if exp_start > 0
        xx = [nan((exp_start*60/time_int),size(xx,2)); xx];
        yy = [nan((exp_start*60/time_int),size(xx,2)); yy];
    end
    
    % Delete positions for time-points not interested
    xx(1:fram_track_start,:) = NaN; yy(1:fram_track_start,:) = NaN;
    xx(fram_track_end+2:end,:) = []; yy(fram_track_end+2:end,:) = [];
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Delete positions of neutrophils outside the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        out = find(~inpolygon(xx(:,hh),yy(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx(out,hh) = NaN; yy(out,hh) = NaN;
    end
    
    % Delete positions for time-points not interested
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = [];
    xx = xx(:,~all(isnan(xx))); yy = yy(:,~all(isnan(yy)));
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Calculate the neutrophil speed
    
    % Initialise variable for all distances
    u_all = nan(fram_track_end-fram_track_start+1, num_cells);
    
    % Loop over all time-points
    for time_id = fram_track_start:fram_track_end-1
        % Calculate the speed
        u_temp = velocity_xy(time_int, time_id, dist_min, dist_max, xx, yy, ...
            num_cells, wound_x, wound_y);
        % Find the number of speeds
        u_time_length = length(u_temp);
        % Append the speed to initialised variable
        u_all(time_id, 1:u_time_length) = u_temp;
    end
    
    
    %% Bin speed with time (cell-based)
    
    % Initialise speed variable 
    speed_cell = cell(1, length(time_bins)-1);
    
    % Loop over all time bins
    for kk = 1:length(time_bins)-1
        % Choose the speeds for each bin
        if size(u_all,1) < time_bins(end)
            time_bins(end) = size(u_all,1);
        end
        speed_temp = u_all(time_bins(kk)+1:time_bins(kk+1),:);
        speed_temp = speed_temp(:);
        % Append speeds to cell matrix
        speed_cell{kk} = speed_temp;
    end
    
    
    %% Find the mean exepriment speed
    speed_exp = nanmean(u_all(:));
    
    
    %% Append to matrix of all data
    if save_exp_all == 1
        if exp_id == 1
            u_exp = speed_exp;
       else
            u_exp = [u_exp; speed_exp];
        end
    end
    
end


%% Save data (*)
if save_exp_all == 1
    save('speed_cluster', 'u_exp', 'time_plot');
end
    

