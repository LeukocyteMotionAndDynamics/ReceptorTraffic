% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel  
% file that is generated from Imaris(R) and calculate their speed with cosine 
% theta

% Last Update:  01 Jul 2019


%% Beginning of file

% Define the number of experiments (*)
num_exp = 5;

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, pixel size, experiment start and wound perimeter (*)
    [name, pixel, exp_start, wound_x, wound_y] = data_tracking(exp_id);
    
    % Define the inner distance and maximum distance from the wound to calculate 
    % the speed
    dist_min = 0; dist_max = 50;
    
    % Define the cosine theta bins 
    costh_bins = (-0.9:0.2:0.9)'; costh_bin_lim = (-1:0.2:1)';
    
    % Define the time interval in sec
    time_int = 30;
    
    % Define the time that tracking starts in minutes
    time_start = 15;
    
    % Define the time duration of tracking in minutes
    time_total = 120;
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Choose whether to save data for experiments; 0 not save, 1 save
    save_exp_all = 1;
    
    
    %% Load the excel file with the 'neutrophil position' spreadsheet
    
    % Choose the directory of files (*)
    dir_data = 'Data';
    
    % Choose the laser wound file
    filename = [name '.xls'];
    
    % Read the file with the worksheet 'Position'
    file = fullfile(dir_data, filename);
    [xx, yy, first_frame] = read_xls_file_time(file, 'Position');
    
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
    xx(fram_track_end+2:end,:) = []; yy(fram_track_end+2:end,:) = [];
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Delete positions after cells reach the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each cell (xx,yy) is inside the perimeter of 
        % the wound area
        in = find(inpolygon(xx(:,hh),yy(:,hh),wound_x,wound_y) == 1, ...
            1, 'first');
        % Empty the rest of positions
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
    
    
    %% Calculate the neutrophil speed vs cosine theta
    
    % Initialise variable for all speeds
    u_time = nan(fram_track_end+1, num_cells);
    costh_time = nan(fram_track_end+1, num_cells);
    
    % Loop over all neutrophils
    for time_id = fram_track_start:fram_track_end-1
        
        % Calculate the speeds and cosine theta values
        [u_time_temp, costh_time_temp] = velocity_xy_costh(time_int, ...
            time_id, dist_min, dist_max, xx, yy, num_cells, wound_x, wound_y);
        
        % Find the number of speeds and cosines
        u_time_length = length(u_time_temp);
        costh_time_length = length(costh_time_temp);
        
        % Append the speed and cosine theta to initialised variable
        u_time(time_id, 1:u_time_length) = u_time_temp;
        costh_time(time_id, 1:costh_time_length) = costh_time_temp;
        
    end
    
    % Append NaNs if experiment is shorter than the time of tracking
    if size(u_time,1) < fram_track_end
        num_col_add = fram_track_end - size(u_time,1);
        u_time = [u_time; nan(num_col_add, num_cells)];
        costh_time = [costh_time; nan(num_col_add, num_cells)];
    end
    
    
    %% Append to matrix of all data
    if save_exp_all == 1
        if exp_id == 1
            u_costh_cell = u_time;
            costh_cell = costh_time;
        else
            u_costh_cell = [u_costh_cell; u_time];
            costh_cell = [costh_cell; costh_time];
        end
    end
    
end


%% Save data (*)
if save_exp_all == 1
    save('speed_costh.mat', 'u_costh_cell', 'costh_cell', 'costh_bins', ...
        'costh_bin_lim');
end


