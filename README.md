# ReceptorTraffic

% File to explain how to use the MATLAB(R) software as described in:
% Coombs et al., 2019, Nature Communications (Accepted in Principle)

% Each parameter is calculated using a different script. For example, the script 
% calc_speed_costh calculates the speed vs cosine theta.

% Each script runs the data from all experiments for each condition at once. The 
% first input variable needed is the number of experiments. This number is 
% associated with the number of Microsoft(R) Excel files (generated by Imaris(R) 
% software in our case). If a different format of Microsoft(R) Excel file is 
% given, then the user should modify the functions 'read_xls_file.m' and 
% 'read_xls_file_vector.m'.

% Each script reads a data function (e.g. cell_data.m) which includes the 
% properties of the experiments of each condition, e.g. a) the name of the excel 
% files, b) the pixel size, c) the time post-wounding that imaging started, 
% d) the wound perimeter. These data functions should be in the same folder as 
% the scripts.

% To run a script, click 'Run', assuming Microsoft(R) Excel files and data 
% functions have been generated. To run a different condition, the user should 
% change the number of experiments, the data function name, the source data 
% folder and the output file name. In all scripts, these are denoted with a (*).

% For each script, an example data function is provided. Additionally, an 
% example of source data is provided for calculation of kinetics and cluster 
% size.
