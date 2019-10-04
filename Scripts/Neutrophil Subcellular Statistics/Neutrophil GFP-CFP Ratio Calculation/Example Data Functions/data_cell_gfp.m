% Function that receives the experiment index and returns all parameters
% that are needed to segment neutrophils and calculate the ratio 
% GFP/CFP intensity.
% Cell centroid coordinates (wound_x_cfp, wound_y_cfp) are given in pixels

% Last Update:  09 Aug 2019


%% Beginning of function

function [name, wound_x_gfp, wound_y_gfp, iterations, bias] = ...
    data_cell_gfp(experiment)

if experiment == 1
    name = 'cell data fr1 GFP';
    wound_x_gfp = [458;413];
    wound_y_gfp = [712;910];
    iterations = 700;
    bias = -0.36;
end


