% Function that receives the experiment index and returns all parameters
% that are needed to segment the wound cells-clusters
% Wound points (wound_x, wound_y) are given in pixels

% Last Update:  11 Jul 2019


%% Beginning of function

function [name, wound_x, wound_y, iterations, bias] = cht_data(experiment)

if experiment == 1
    name = 'cht 1 fr1';
    wound_x = [381;377;389;392;363];
    wound_y = [649;751;908;273;367];
    iterations = 200;
    bias = -0.1;
elseif experiment == 2
    name = 'cht 2 fr6';
    wound_x = [288;315;269;248];
    wound_y = [609;909;408;222];
    iterations = 400;
    bias = -0.35;
elseif experiment == 3
    name = 'cht 3 fr1';
    wound_x = [468;384];
    wound_y = [888;387];
    iterations = 150;
    bias = -0.1;
end


