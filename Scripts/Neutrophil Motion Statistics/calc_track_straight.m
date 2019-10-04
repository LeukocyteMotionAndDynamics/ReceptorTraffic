% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel
% file that is generated from Imaris(R) and calculate the track straightness

% Last Update:  12 Jun 2019


%% Beginning of file

% Define the number of experiments (*)
num_exp = 5;

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, pixel size, experiment start and wound perimeter (*)
    [name, pixel, exp_start, wound_x, wound_y] = data_tracking(exp_id);
    
    % Define the inner distance and distance from the wound to calculate the speed
    dist_min = 0; dist_max = 50;
    
    % Define the time interval in sec
    time_int = 30;
    
    % Define the time that tracking starts in minutes
    time_start = 15;
    
    % Define the time duration of tracking in minutes
    time_total = 120;
    
    % Define the minimum track length in um to consider the track
    d_min = 10;
    
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
    [xx, yy, first_frame] = read_xls_file(file, 'Position');
    
    % Append NaNs if tracking does not start from beginning of imaging
    if first_frame > 1
        xx = [nan((first_frame-1),size(xx,2)); xx];
        yy = [nan((first_frame-1),size(yy,2)); yy];
    end
    
    % Append NaNs if experiment does not start from 0 minutes
    % All experiments start from at least 15 minutes post-wound
    if exp_start > 0
        xx = [nan((exp_start*60/time_int),size(xx,2)); xx];
        yy = [nan((exp_start*60/time_int),size(xx,2)); yy];
    end
    
    % Delete positions for time-points not interested
    xx(1:fram_track_start,:) = NaN; yy(1:fram_track_start,:) = NaN;
    xx(fram_track_end+1:end,:) = []; yy(fram_track_end+1:end,:) = [];
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    % Delete positions for time-points not interested
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = [];
    xx = xx(:,~all(isnan(xx))); yy = yy(:,~all(isnan(yy)));
    
    % Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Calculate the distance travelled
    
    % Initialise variable for all distances
    d_time = nan(fram_track_end-fram_track_start+1, num_cells);
    
    % Loop over all neutrophils
    for time_id = fram_track_start:fram_track_end-1
        
        % Calculate the distance that neutrophils travel in each step
        d_time_temp = dist_xy(time_id, dist_min, dist_max, xx, yy, ...
            num_cells, wound_x, wound_y);
        
        % Find the number of distances
        d_time_length = length(d_time_temp);
        
        % Append the distance to initialised variable
        d_time(time_id, 1:d_time_length) = d_time_temp;
        
    end
    
    % Append NaNs if experiment is shorter than the time of tracking
    if size(d_time,1) < fram_track_end
        num_col_add = fram_track_end - size(d_time,1);
        d_time = [d_time; nan(num_col_add, num_cells)];
    end
    
    
    %% Calculate the total distance travelled by each neutrophil
    
    % Initialise variable
    d_total = nan(size(d_time,2),1);
    
    % Loop over all cells
    for uu = 1:size(d_time,2)
        d_time_temp = d_time(:,uu);
        d_time_temp(isnan(d_time_temp)) = [];
        d_total(uu) = sum(d_time_temp);
        if d_total(uu) < d_min
            d_total(uu) = NaN;
        end
    end
    
    
    %% Calculate the neutrophil displacement
    
    % Initialise variable
    d_net = nan(size(d_time,2),1);
    
    % Find the first and last time-frame id with non-NaN distance
    for uu = 1:size(d_time,2)
        idx_first = find(sum(~isnan(d_time(:,uu)),2) > 0, 1 , 'first');
        idx_last = find(sum(~isnan(d_time(:,uu)),2) > 0, 1 , 'last');
        if ~isempty(idx_first)
            d_net(uu) = sqrt((xx(idx_last,uu) - xx(idx_first,uu))^2 + ...
                (yy(idx_last,uu) - yy(idx_first,uu))^2);
        else
            d_net(uu) = NaN;
        end
    end
    
    
    %% Calculate the track straighness of cells (actually tracks)
    track_straight = d_net ./ d_total;
        
    
    %% Append to matrix of all data
    if save_exp_all == 1
        if exp_id == 1
            track_straight_cell = track_straight;
        else
            track_straight_cell = [track_straight_cell; track_straight];
        end
    end
    
end


%% Save data (*)
if save_exp_all == 1
    save('track_straight.mat', 'track_straight_cell');
end


