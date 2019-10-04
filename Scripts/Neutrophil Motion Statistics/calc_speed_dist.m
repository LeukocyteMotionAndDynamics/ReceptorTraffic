% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel 
% file that is generated from Imaris(R) and calculate their speed with distance 
% from wound

% Last Update:  21 Jun 2019


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
    dist_bins = (30:30:300)'; dist_bin_lim = [0; dist_bins];
    
    % Define the distance bins
    dist_min = 0; dist_max = 300;
    
    % Define the time interval in seconds
    time_int = 30;
    
    % Define the time that tracking starts in minutes
    time_start = 15;
    
    % Define the time that tracking ends in minutes
    time_total = 120;
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Choose whether to save data for experiments; 0 not save, 1 save
    save_exp_all = 1;
    
    
    %% Load the excel file with the 'neutrophil position' spreadsheet
    
    % Choose the directory of data (*)
    dir_data = 'Data';
    
    % Choose the file
    filename = [name '.xls'];
    
    % Read the file with the worksheet 'Position'
    file = fullfile(dir_data, filename);
    [xx, yy, first_frame] = read_xls_file(file, 'Position');
    
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
    xx(1:fram_track_start-1,:) = NaN; yy(1:fram_track_start-1,:) = NaN;
    xx(fram_track_end+1:end,:) = []; yy(fram_track_end+1:end,:) = [];
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
        
    %% Delete positions of neutrophils after the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each cell appears inside the wound
        in = find(inpolygon(xx(:,hh),yy(:,hh),wound_x,wound_y) == 1,1,'first');
        % Empty the previous positions
        xx(in:end,hh) = NaN; yy(in:end,hh) = NaN;
    end
    
    % Delete positions for time-points not interested
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = [];
    xx = xx(:,~all(isnan(xx))); yy = yy(:,~all(isnan(yy)));
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Eliminate tracks that go away from the wound
    
    % Initialise parameters
    d_first = nan(length(wound_x),1); d_last = nan(length(wound_x),1);
    
    % Loop over all cells
    for kk = 1:num_cells
        % Find the first and last neutrophil position
        first_pos = find(isnan(xx(:,kk)) == 0, 1, 'first');
        last_pos = find(isnan(xx(:,kk)) == 0, 1, 'last');
        % Find distance from wound of first and last position
        for ll = 1:length(wound_x)
            d_first(ll) = sqrt((xx(first_pos,kk) - wound_x(ll))^2 ...
                + (yy(first_pos,kk) - wound_y(ll))^2);
            d_last(ll) = sqrt((xx(last_pos,kk) - wound_x(ll))^2 ...
                + (yy(last_pos,kk) - wound_y(ll))^2);
        end
        % If distance of last position is longer than that of first position, it
        % means that the neutrophil is going away from wound, so exclude it
        if min(d_first) < min(d_last)
            xx(:,kk) = nan; yy(:,kk) = nan;
        end
    end
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Calculate the neutrophil distance and speed
    
    % Initialise variable for all distances
    d_all = nan(fram_track_end, num_cells);
    u_all = nan(fram_track_end, num_cells);
    
    % Loop over all time-points
    for time_id = fram_track_start:fram_track_end-1
        % Calculate the speed and distance
        [u_temp, d_temp] = velocity_xy(time_int, time_id, dist_min, ...
            dist_max, xx, yy, num_cells, wound_x, wound_y);
        % Find the number of distances and speeds
        d_temp_length = length(d_temp);
        u_time_length = length(u_temp);
        % Append the distance and speed to initialised variables
        d_all(time_id, 1:d_temp_length) = d_temp;
        u_all(time_id, 1:u_time_length) = u_temp;
    end
    
    
    %% Append to matrix of all data
    if save_exp_all == 1
        if exp_id == 1
            d_cell = d_all;
            u_cell = u_all;
        else
            d_cell = [d_cell; d_all];
            u_cell = [u_cell; u_all];
        end
    end
    
end


%% Save data (*)
if save_exp_all == 1
    save('speed_dist', 'd_cell', 'u_cell', 'dist_bins');
end
    
        

