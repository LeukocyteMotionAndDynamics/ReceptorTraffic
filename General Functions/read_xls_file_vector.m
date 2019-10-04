% Script to read a vector of data from Microsoft(R) Excel file (previously made 
% by Imaris(R)) and import it as a variable in workspace

% Last Update:  30 Aug 2018


%% Start of file

function [vector1, vector2, n] = read_xls_file_vector(set, sheet)

% Read xls file
file = xlsread(set, sheet);

% Get the Area variable (in um)
vector1 = file(:,1);

% Get the number of entries
n = length(vector1);

% Get the timw vector
vector2 = file(:,4);
