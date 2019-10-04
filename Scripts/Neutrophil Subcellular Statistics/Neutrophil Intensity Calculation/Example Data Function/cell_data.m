% Function that receives the experiment index and returns all parameters
% that are needed to calculate different variables
% Transplant centre (transpl_x, transpl_y) is given in pixels, neutrophil
% coordinates (cell_x, cell_y) are given in pixels

% Last Update:  24 Jun 2019


%% Beginning of function

function [name, transpl_x, transpl_y, cell_x, cell_y, iterations, bias] = ...
    wt_cxcl8_data(experiment)

% Set experiment name
if experiment == 1
    name = 'file 1 fr88';
    transpl_x = 410; transpl_y = 330;
    cell_x = [389;375;546;555;437;384;464;195;160;184;234;125;169;161;99];
    cell_y = [144;267;216;385;479;433;424;474;433;340;351;242;782;696;691];
    iterations = 200;
    bias = -0.1;
elseif experiment == 2
    name = 'file 2 fr77';
    transpl_x = 275; transpl_y = 510;
    cell_x = [436;383;273;378;607;638;620;569;579;689;402;573;660];
    cell_y = [136;280;292;379;379;434;309;203;603;762;696;855;472];
    iterations = 300;
    bias = -0.1;
elseif experiment == 3
    name = 'file 3 fr75';
    transpl_x = 220; transpl_y = 420;
    cell_x = [186;401;202;483;226;186];
    cell_y = [135;240;874;335;637;785];
    iterations = 300;
    bias = -0.3;
end
