% The function calculates the cell speed of neutrophils between two time points
% and the cosine theta and appends to a matrix
% The function decides the minimum distance of a cell from the wound perimeter


% Last Update:  01 Jul 2019


%% Beginning of file

function [u_all, costh_all] = velocity_xy_costh(time_int, time_id, ...
    dist_min, dist_max, xx, yy, num_cells, wound_x, wound_y)

% Loop over all cells
for cell_id = 1:num_cells
    
    % Calculate the distance from the wound points
    for kk = 1:length(wound_x)
        d1_wound(kk) = sqrt((xx(time_id,cell_id) - wound_x(kk))^2 ...
            + (yy(time_id,cell_id) - wound_y(kk))^2);
        d2_wound(kk) = sqrt((xx(time_id+1,cell_id) - wound_x(kk))^2 ...
            + (yy(time_id+1,cell_id) - wound_y(kk))^2);
    end
    
    % Find the minimum distance and use this distance
    [~, d_wound_min_id2] = min(d2_wound);
    d1_wound = d1_wound(d_wound_min_id2);
    d2_wound = d2_wound(d_wound_min_id2);
    
    % If the cell lies in the distance between the inner and maximum one, 
    % then process it
    if ((d1_wound >= dist_min) && (d1_wound <= dist_max)) || ...
            (((d2_wound >= dist_min) && (d2_wound <= dist_max)))
        
        % Find the distance travelled
        d = sqrt((xx(time_id+1,cell_id) - xx(time_id,cell_id))^2 + ...
            (yy(time_id+1,cell_id) - yy(time_id,cell_id))^2);
        
        % Calculate the speed in um/min using the time interval
        u = d * 60 / time_int;
        
        % Calculate the angle theta
        theta = atan2d((xx(time_id+1,cell_id)-xx(time_id,cell_id)) * ...
            (wound_y(d_wound_min_id2)-yy(time_id,cell_id)) - ...
            (yy(time_id+1,cell_id)-yy(time_id,cell_id)) * ...
            (wound_x(d_wound_min_id2)-xx(time_id,cell_id)), ...
            (xx(time_id+1,cell_id)-xx(time_id,cell_id)) * ...
            (wound_x(d_wound_min_id2)-xx(time_id,cell_id)) + ...
            (yy(time_id+1,cell_id)-yy(time_id,cell_id)) * ...
            (wound_y(d_wound_min_id2)-yy(time_id,cell_id)));
        
        % Calculate the cosine theta
        costh = cosd(theta);

        % Append the speed, distance travelled and cosine theta
        u_all(cell_id) = u;
        costh_all(cell_id) = costh;
        
    else
        % If outside the distance-to-wound limits, append NaNs
        u_all(cell_id) = NaN;
        costh_all(cell_id) = NaN;
    end
end


