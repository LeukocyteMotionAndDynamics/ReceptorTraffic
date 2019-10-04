% Function that receives the experiment index and returns all parameters
% that are needed to segment the wound cells-clusters
% Wound points (wound_x, wound_y) are given in pixels

% Last Update:  11 Jul 2019


%% Beginning of function

function [name, wound_x, wound_y, iterations, bias] = wound_data(experiment)

if experiment == 1
    name = 'wound 1 fr1';
    wound_x = [235;167;226;289];
    wound_y = [288;463;420;368];
    iterations = 250;
    bias = -0.3;
elseif experiment == 2
    name = 'wound 2 fr6';
    wound_x = [466;464;504;411];
    wound_y = [562;653;684;618];
    iterations = 450;
    bias = -0.5;
elseif experiment == 3
    name = 'wound 3 fr1';
    wound_x = [155;202;107;102];
    wound_y = [654;425;416;371];
    iterations = 250;
    bias = -0.25;
end


