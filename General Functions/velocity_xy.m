% The function calculates the cell speed of neutrophils between two time points
% and the distance from wound and appends to a matrix
% The function decides the minimum distance of a cell from the wound perimeter

% Last Update:  17 Apr 2019


%% Beginning of file

function [u_all, d_all] = velocity_xy(time_int, time_id, dist_min, dist_max, ...
    xx, yy, num_cells, wound_x, wound_y)

% Initialise parameters; cell_count for cells, u_all for speeds and d_all for 
% distances
cell_count = 0; u_all = []; d_all = [];

% Loop over all cells
for i = 1:num_cells
    
    % Calculate the distance from the wound points
    for kk = 1:length(wound_x)
        d1(kk) = sqrt((xx(time_id,i) - wound_x(kk))^2 ...
            + (yy(time_id,i) - wound_y(kk))^2);
        d2(kk) = sqrt((xx(time_id+1,i) - wound_x(kk))^2 ...
            + (yy(time_id+1,i) - wound_y(kk))^2);
    end
    
    % Find the minimum distance from wound and use this distance
    [~, min_d2_id] = min(d2);
    d1 = d1(min_d2_id);
    d2 = d2(min_d2_id);
    
    % If the cell lies in the distance between the minimum and maximum one, 
    % then process it
    if (((d1 >= dist_min) && (d1 <= dist_max)) || ...
            (((d2 >= dist_min) && (d2 <= dist_max))))
        % Find the distance travelled
        d = sqrt((xx(time_id+1,i) - xx(time_id,i))^2 + ...
            (yy(time_id+1,i) - yy(time_id,i))^2);
        
        % Calculate the speed in um/min using the time interval
        u = d * 60 / time_int;
        
        % If a true speed has been calculated, append it; if not, add a NaN
        if ~isnan(u)
            cell_count = cell_count + 1;
            u_all(cell_count) = u;
            d_all(cell_count) = d2;
        else
            cell_count = cell_count + 1;
            u_all(cell_count) = NaN;
            d_all(cell_count) = NaN;
        end
    else
        cell_count = cell_count + 1;
        u_all(cell_count) = NaN;
        d_all(cell_count) = NaN;
    end
end


