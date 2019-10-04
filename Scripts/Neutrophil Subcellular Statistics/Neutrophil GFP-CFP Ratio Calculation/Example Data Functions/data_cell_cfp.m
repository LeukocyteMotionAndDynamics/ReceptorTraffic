% Function that receives the experiment index and returns all parameters
% that are needed to segment neutrophils and calculate the ratio 
% GFP/CFP intensity.
% Cell centroid coordinates (wound_x_cfp, wound_y_cfp) are given in pixels

% Last Update:  09 Aug 2019


%% Beginning of function

function [name, wound_x_cfp, wound_y_cfp, iterations, bias] = ...
    data_cell_cfp(experiment)

if experiment == 1
    name = 'cell data fr1 CFP';
    wound_x_cfp = [461;413];
    wound_y_cfp = [749;910];
    iterations = 250;
    bias = -0.35;
end


