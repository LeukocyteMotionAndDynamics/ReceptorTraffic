% Script to segment multiple neutrophils and calculate the contrast of the 
% inner surface and the distance from the wound

% Last Update:  10 Aug 2019


%% Beginning of image processing

% Experiment index (change number to run exp 1,2,3 without clearing variables)
exp_id = 1;

% Message in command window of which image is processed
disp(['Processing experiment ' num2str(exp_id)]);

% Define the number of frames to track (*)
num_images_track = 60;

% Define the pixel size in um/pixel and time interval in seconds (*)
pixel = 0.3841170; time_interval = 30;

% Select the file, the wound perimeter, and the x-coordinate of CHT boundary (*)
if exp_id == 1
    name = 'Images\file 1';
    file = 'Images\file 1.tif';
    cht_boundary = 470;
    wound_x = [644;617;594;570;548;522;512;504;509;518;518;527;540;552;564;...
        573;585;602;615;633;645;659]*pixel;
    wound_y = [609;606;591;588;591;596;609;632;653;672;699;713;728;752;771;...
        798;813;831;844;862;880;889]*pixel;
elseif exp_id == 2
    name = 'Images\file 2';
    file = 'Images\file 2.tif';
    cht_boundary = 260;
    wound_x = [78;96;114;132;160;176;193;205;209;203;192;188;188;190;188;...
        186;181]*pixel;
    wound_y = [741;740;742;751;754;762;775;795;812;832;847;859;876;891;909;...
        927;945]*pixel;
elseif exp_id == 3
    name = 'Images\file 3';
    file = 'Images\file 3.tif';
    cht_boundary = 220;
    wound_x = [114;125;138;148;159;166;173;176;184;177;164;149;139;135;127;...
        115]*pixel;
    wound_y = [490;502;512;525;544;564;591;616;635;645;657;662;673;689;703;...
        714]*pixel;
end

% Get the file information
info = imfinfo(file);

% Select whether to calculate, draw or save data
draw_contour = 1; save_contour = 1; save_data = 1;

% Initialise variables
centroids = []; distance = []; contrast = [];


%% Loop over all frames
for kk = 1:num_images_track
    
    % Message in command window of which image is processed
    disp(['Processing image ', num2str(kk), '/', num2str(num_images_track)]);
    
    % Read file and create variable for initial image for future use
    im = imread(file, kk, 'Info', info); im_init = im;
    
    % Transform image into double-precision
    im = im2double(im);
    
    % Define a contrast adjustment factor, empirically found (*)
    adj_factor = (kk / 200)/2;
    
    % Simple manually selected threshold, empirically found (*)
    if exp_id == 1 && kk < 50
        thresh = 0.06;
    elseif exp_id == 1 && kk >= 50
        thresh = 0.04;
    elseif exp_id == 2 && kk > 50
        thresh = 0.02;
    elseif exp_id == 2 && kk <= 50
        thresh = 0.07;
    elseif exp_id == 3 && kk < 20
        thresh = 0.05;
    elseif exp_id == 3 && kk >= 20
        thresh = 0.03;
    elseif exp_id == 4
        thresh = 0.07;
    end
    
    % Threshold-based segmentation by adjusting the threshold using the contrast
    % adjustment factor, empirically found (*)
    if exp_id == 1 || exp_id == 2 || exp_id == 4
        bw = imbinarize(im, thresh+(adj_factor/3));
    elseif exp_id == 3
        bw = imbinarize(im, thresh+(adj_factor/5));
    end
    
    % Discard cells at CHT and before CHT, keep only neutrophils at fin (*)
    for yy = 1:size(im,1)
        for xx = 1:size(im,2)
            if exp_id == 1
                if xx < cht_boundary
                    bw(yy,xx) = 0;
                end
            elseif exp_id == 2 || exp_id == 3
                if xx > cht_boundary
                    bw(yy,xx) = 0;
                end
            end
        end
    end
    
    % Eliminate any small particle that resulted from segmentation
    bw = bwareaopen(bw, 200);    
    
    % Multiply the individual neutrophil binary mask with the original image to 
    % get only grey-image of the neutrophil
    im1 = immultiply(im, bw);
    
    % Find the boundaries of the neutrophils
    [bound_cell, ~] = bwboundaries(bw, 'noholes');    
    
    % Find the number of neutrophils
    num_cells = length(bound_cell);
    
    % Loop over all neutrophils
    for uu = 1:num_cells
        
        % Mask neutrophils
        boundary = bound_cell{uu};
        mask = poly2mask(boundary(:,2),boundary(:,1),size(im,1),size(im,2));
        cell = immultiply(im, mask);
        
        % Replace image background with NaNs, so it does not contribute to the 
        % calculation of contrast
        im(im == 0) = NaN; im_mean = nanmean(im(:)); cell(cell == 0) = NaN;
        
        % Calculate contrast
        glcm = graycomatrix(cell, 'Offset', [5 0]);
        texture = graycoprops(glcm, {'Contrast'});
        
        % Append contrast values in a matrix
        contrast_temp = struct2cell(texture);
        contrast = cell2mat(contrast_temp);
        
        % Find the centre of the neutrophil
        centre = mean(boundary) * pixel;
        
        % Calculate the distance between the centre and the wound centre
        dist_temp = pdist2([wound_y, wound_x], centre, 'Euclidean');
        distance = [distance; min(dist_temp)];
        
    end
    
    % Draw frame with neutrophil boundary
    if draw_contour == 1
        map = makeColorMap([0 0 0], [0 0.5 0], [0 1 0], 255);
        f = figure('visible', 'off'); imshow(im_init, map); hold on;
        for jj = 1:length(bound_cell)
            boundary = bound_cell{jj};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1.2);
        end
    end
    
    % Append currect frame
    if save_contour == 1
        im_save = getframe(f); im_save = im_save.cdata;
        imwrite(im_save, [name ' contour.tif'], 'writemode', 'append');
    end
end

% Normalise the neutrophil intensities using the maximum neutrophil intensity
max_contrast = max(contrast(:));
contrast_norm = contrast / max_contrast;


%% Append the distance and contrast to a common matrix
if save_data == 1
    if exp_id == 1
        distance_all = distance;
        contrast_all = contrast_norm;
    else
        distance_all = [distance_all; distance];
        contrast_all = [contrast_all; contrast_norm];
    end
end

% Save distance and contrast for plotting (*)
save('contrast_dist_norm.mat', 'distance_all', 'contrast_all');


