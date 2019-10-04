% Function that receives the experiment index and returns all parameters
% for that condition
% Pixel size (pixel) is given in um/pixel, experiment starting time 
% (exp_start) is given in minutes

% Last Update:  17 May 2019


%% Beginning of function

function [name, pixel, exp_start] = data_cluster(experiment)

if experiment == 1
    name = 'sampleclustersize';
    pixel = 0.5725026;
    exp_start = 15;
elseif experiment == 2
    name = 'file 2';
    pixel = 0.5725026;
    exp_start = 15;
elseif experiment == 3
    name = 'file 3';
    pixel = 0.5725026;
    exp_start = 15;
elseif experiment == 4
    name = 'file 4';
    pixel = 0.5725026;
    exp_start = 15;
elseif experiment == 5
    name = 'file 5';
    pixel = 0.5725026;
    exp_start = 15;
end

