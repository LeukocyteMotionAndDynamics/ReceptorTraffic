% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel
% file that is generated from Imaris(R) and calculate the net reverse traffic

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
    
    % Define the time interval in seconds
    time_int = 30;
    
    % Define the time that tracking starts in minutes
    time_start = 15;
    
    % Define the time that tracking ends in minutes
    time_total = 120;
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Minimum track distance travelled to consider reverse migration
    min_length = 10;
    
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
    % All experiments start from at least 15 minutes post-wound
    if exp_start > 0
        xx = [nan((exp_start*60/time_int),size(xx,2)); xx];
        yy = [nan((exp_start*60/time_int),size(xx,2)); yy];
    end
    
    
    %% Delete positions for time-points not interested
    xx(1:fram_track_start,:) = NaN; yy(1:fram_track_start,:) = NaN;
    xx(fram_track_end+1:end,:) = []; yy(fram_track_end+1:end,:) = [];
    
    
    %% Find the last neutrophil registered
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    
    
    %% Duplicate X,Y,Z to distinguish direct & reverse migrating neutrophils
    xx_dir = xx; yy_dir = yy;
    xx_rev = xx; yy_rev = yy;
    
    
    %% Delete positions before cells reach the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each cell appears inside the wound
        in = find(inpolygon(xx_rev(:,hh),yy_rev(:,hh),wound_x,wound_y) == 1, ...
            1,'first');
        % Empty the previous positions
        if isempty(in)
            xx_rev(:,hh) = NaN; yy_rev(:,hh) = NaN;
        else
            xx_rev(1:in-1,hh) = NaN; yy_rev(1:in-1,hh) = NaN;
        end
    end
    
    
    %% Delete positions of neutrophils inside the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        in = find(inpolygon(xx_rev(:,hh),yy_rev(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx_rev(in,hh) = NaN; yy_rev(in,hh) = NaN;
    end
    
    
    %% Delete positions after cells reach the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each cell (X,Y) is inside the perimeter of 
        % the wound area
        in = find(inpolygon(xx_dir(:,hh),yy_dir(:,hh),wound_x,wound_y) == 1, ...
            1, 'first');
        % Empty the rest of positions
        if ~isempty(in)
            xx_dir(in:end,hh) = NaN; yy_dir(in:end,hh) = NaN;
        else
            xx_dir(:,hh) = NaN; yy_dir(:,hh) = NaN;            
        end
    end
    
    
    %% Delete positions of neutrophils inside the wound

    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        in = find(inpolygon(xx_dir(:,hh),yy_dir(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx_dir(in,hh) = NaN; yy_dir(in,hh) = NaN;
    end
        
    
    %% Find the number of tracks of direct migration pre-wound
    num_cells_track_dir_temp = sum(~isnan(xx_dir));
    num_track_dir = sum(num_cells_track_dir_temp ~=0);
    
    
    %% Find the number of tracks of reverse migration post-wound
    num_track_rev = 0;
    
    % Loop over all neutrophils
    for pp = 1:size(xx_rev,2)
        % Get the points of current neutrophil
        xx_rev_cell1 = xx_rev(:,pp);
        % Check if all positions are NaNs
        idx_temp1 = all(isnan(xx_rev_cell1));
        % If not, find the last non-NaN position
        if idx_temp1 == 0
            idx_temp2 = find(sum(~isnan(xx_rev_cell1),2) > 0, 1 , 'last');
            % If number of positions is same as frame of end of tracking, add a 
            % track; else, add a track if all the rest of positions are NaNs
            if idx_temp2 == fram_track_end
                num_track_rev = num_track_rev + 1;
            else
                xx_rev_cell2 = xx_rev(idx_temp2+1, pp);
                if isnan(xx_rev_cell2)
                    num_track_rev = num_track_rev + 1;
                end
            end
        end
    end
    
    
    %% Find the distance travelled by the direct migrating neutrophils
    
    % Remove neutrophil columns with only NaNs
    xx_dir(:,all(isnan(xx_dir))) = []; yy_dir(:,all(isnan(yy_dir))) = [];
    
    % Initialise distance variable
    dist_temp = nan(size(xx_dir,2),1);
    
    % Find the distance
    for kk = 1:size(xx_dir,2)
        pos1 = find(~isnan(xx_dir(:,kk)), 1, 'first');
        pos2 = find(~isnan(xx_dir(:,kk)), 1, 'last');
        dist_temp(kk) = sqrt((xx_dir(pos2,kk) - xx_dir(pos1,kk))^2 + ...
            (yy_dir(pos2,kk) - yy_dir(pos1,kk))^2);
    end
    
    % Find the tracks with distance travelled higher longer than min length
    track_temp = find(dist_temp > min_length);
    
    % Find the number of true direct migration tracks
    num_track_dir = length(track_temp);
    
    
    %% Find the distance travelled by the reverse migrating neutrophils
    
    % Remove neutrophil columns with only NaNs
    xx_rev(:,all(isnan(xx_rev))) = []; yy_rev(:,all(isnan(yy_rev))) = [];
    
    % Initialise distance variable
    dist_temp = nan(size(xx_rev,2),1);
    
    % Find the distance
    for kk = 1:size(xx_rev,2)
        pos1 = find(~isnan(xx_rev(:,kk)), 1, 'first');
        pos2 = find(~isnan(xx_rev(:,kk)), 1, 'last');
        dist_temp(kk) = sqrt((xx_rev(pos2,kk) - xx_rev(pos1,kk))^2 + ...
            (yy_rev(pos2,kk) - yy_rev(pos1,kk))^2);
    end
    
    % Find the tracks with distance travelled higher longer than min length
    track_temp = find(dist_temp > min_length);
    
    % Find the number of true reverse migration tracks
    num_track_rev = length(track_temp);
    
    
    %% Find the percentage of reverse/direct migrating neutrophils per frame
    num_cells_perc_exp = num_track_rev / num_track_dir;
    
    
    %% Append to matrix of all data
    if save_exp_all == 1
        if exp_id == 1
            traffic = num_cells_perc_exp;
        else
            traffic = [traffic; num_cells_perc_exp];
        end
    end
    
end


%% Save data (*)
if save_exp_all == 1
    save('exp_traffic.mat', 'traffic');
end
    

