% The function calculates the distance that neutrophils travel between two 
% time intervals
% The function decides the minimum distance of a cell from the wound perimeter

% Last Update:  30 May 2019


%% Beginning of file

function [d_all, d1] = dist_xy(time_id, dist_inn, dist_max, xx, yy, ...
    num_cells, wound_x, wound_y)

% Initialise parameters; num_cell_true for cells with true distance, 
% num_cell_all for all cells, with true or NaN distance
num_cells_true = 0; num_cells_all = 0; d_all = [];

% Loop over all cells
for i = 1:num_cells
    
    % Calculate the distance from the wound points
    for kk = 1:length(wound_x)
        d1(kk) = sqrt((xx(time_id,i) - wound_x(kk))^2 ...
            + (yy(time_id,i) - wound_y(kk))^2);
        d2(kk) = sqrt((xx(time_id+1,i) - wound_x(kk))^2 ...
            + (yy(time_id+1,i) - wound_y(kk))^2);
    end
    
    % Find the minimum distance and use this distance
    [~, min_d2_id] = min(d2);
    d1 = d1(min_d2_id);
    d2 = d2(min_d2_id);
    
    % If the cell lies in the distance between the inner and maximum one, 
    % then process it
    if (((d1 >= dist_inn) && (d1 <= dist_max)) || ...
            (((d2 >= dist_inn) && (d2 <= dist_max))))
        
        % Find the distance travelled
        d = sqrt((xx(time_id+1,i) - xx(time_id,i))^2 + ...
            (yy(time_id+1,i) - yy(time_id,i))^2);
        
        % If a true distance has been calculated, append it; if not, add a NaN
        if ~isnan(d)
            num_cells_true = num_cells_true + 1;
            num_cells_all = num_cells_all + 1;
            d_all(num_cells_all) = d;
        else
            num_cells_all = num_cells_all + 1;
            d_all(num_cells_all) = NaN;
        end
    else
        num_cells_all = num_cells_all + 1;
        d_all(num_cells_all) = NaN;
    end
    
end


