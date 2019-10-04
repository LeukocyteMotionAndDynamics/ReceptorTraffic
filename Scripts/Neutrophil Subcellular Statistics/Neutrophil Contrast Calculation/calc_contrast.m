% Script to segment neutrophils and calculate their contrast
% It calculates the contrast at cells close to wound and it 
% normalises the values with the contras values of cells at CHT

% Last Update:  24 Jun 2019


%% Beginning of script

% Define the number of experiments (*)
num_exp = 5;

% Set whether to draw the contour
draw_contour = 0;

% Initialise the contrast variables
contrast_wound = []; contrast_cht = []; contrast_cht_norm = []; 
contrast_wound_norm = [];

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Initialise the structure array with the final cell data to store
    neutro_texture_wound = struct();
    
    % Get the filename, neutrophil centre coordinates, iterations and bias for 
    % active contours (*)
    [name, neutro_x, neutro_y, iter, bias] = wound_data(exp_id);
    file = ['Data\' name '.tif'];
    
    % Read first image
    im = imread(file);
    % Double-precision transformation
    im = im2double(im);
    
    % Intialise the final binary image
    bw_final = zeros(size(im));
    
    % Find the number of neutrophils/clusters
    num_cells = length(neutro_x);
    
    % Loop over all neutrophils to get the contrast
    for qq = 1:num_cells
        
        % Create the binary mask for each cell by extending by X pixels in x and 
        % y for the selected centroid
        mask = zeros(size(im));
        mask(neutro_y(qq)-5:neutro_y(qq)+5, neutro_x(qq)-5:neutro_x(qq)+5) = 1;
        
        % Apply active contour technique based on the initial area defined above
        bw = activecontour(im, mask, iter, 'Chan-Vese', 'SmoothFactor', 0.5, ...
            'ContractionBias', bias);
        
        % Eliminate very small segmented areas
        bw = bwareaopen(bw, 50);
        
        % Multiply the individual cell binary mask with the original image to 
        % get only grey-image of the cell
        cell_image = immultiply(im, bw);
        cell_image(bw==0) = NaN;
        
        % Calculate the Gray Co-Occurence Matrix and from that calculate the
        % parameters that describe the cell
        glcm = graycomatrix(cell_image, 'Offset', [5 0]);
        text = graycoprops(glcm, {'contrast'});
        
        % Append parameters into matrix
        neutro_texture_wound(qq).Contrast = text.Contrast;
        
        % Append binary image so to get teh final contours
        bw_final = bw_final + bw;
        
        % Get contrast and normalise contrast with mean intensity of structure
        contrast_wound_temp = [neutro_texture_wound.Contrast]';
        
    end
    
    % Show the image and plot boundaries
    if draw_contour == 1
        f = figure('visible', 'on'); imshow(im);
        hold on
        plot(neutro_x, neutro_y, 'b*');
        for kk = 1:num_cells
            [bound_cell, ~] = bwboundaries(bw_final, 'noholes');
            boundary = bound_cell{kk,1};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1);
        end
        
        % Save the image with the contour (*)
        im_cont = getframe(f); 
        im_cont = im_cont.cdata;
        set(gca,'position',[0 0 1 1],'units','normalized')
        imwrite(im_cont, ['Data\' name ' wound contour.tif']);
    end
    
    % Initialise the structure array with the final cell data to store
    neutro_texture_cht = struct();

    % Get the filename, neutrophil centre coordinates, iterations and bias for 
    % active contours (*)
    [name, neutro_x, neutro_y, iter, bias] = cht_data(exp_id);
    
    % Intialise the final binary image
    bw_final = zeros(size(im));
    
    % Find the number of neutrophils/clusters
    num_cells = length(neutro_x);
    
    % Loop over all neutrophils to get the contrast
    for qq = 1:num_cells
        
        % Create the binary mask for each cell by extending by X pixels in x and 
        % y for the selected centroid
        mask = zeros(size(im));
        mask(neutro_y(qq)-5:neutro_y(qq)+5, neutro_x(qq)-5:neutro_x(qq)+5) = 1;
        
        % Apply active contour technique based on the initial area defined above
        bw = activecontour(im, mask, iter, 'Chan-Vese', 'SmoothFactor', 0.5, ...
            'ContractionBias', bias);
        
        % Eliminate very small segmented areas
        bw = bwareaopen(bw, 50);
        
        % Multiply the individual cell binary mask with the original image to 
        % get only grey-image of the cell
        cell_image = immultiply(im, bw);
        cell_image(bw==0) = NaN;
        
        % Calculate the Gray Co-Occurence Matrix and from that calculate the
        % parameters that describe the cell
        glcm = graycomatrix(cell_image, 'Offset', [5 0]);
        text = graycoprops(glcm, {'contrast'});
        
        % Append parameters into matrix
        neutro_texture_cht(qq).Contrast = text.Contrast;
        
        % Append binary image so to get the final contours
        bw_final = bw_final + bw;
        
        % Get contrast and normalise contrast with mean intensity of structure
        contrast_cht_temp = [neutro_texture_cht.Contrast]';
        
    end
    
    % Find the mean contrast value for the CHT neutrophils
    contrast_cht_mean = nanmean(contrast_cht_temp);
    
    % Normalise the contrast of CHT neutrophils
    contrast_cht_norm_temp = contrast_cht_temp / contrast_cht_mean;
    
    % Show the image and plot boundaries
    if draw_contour == 1
        f = figure('visible', 'on'); imshow(im);
        hold on
        plot(neutro_x, neutro_y, 'b*');
        for kk = 1:num_cells
            [bound_cell, ~] = bwboundaries(bw_final, 'noholes');
            boundary = bound_cell{kk,1};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1);
        end
        
        % Save the image with the contour (*)
        im_cont = getframe(f); 
        im_cont = im_cont.cdata;
        set(gca,'position',[0 0 1 1],'units','normalized')
        imwrite(im_cont, ['Data\' name ' cht contour.tif']);
    end
    
    % Find the relative contrast of wound vs cht
    contrast_wound_norm_temp = contrast_wound_temp / contrast_cht_mean;
    
    % Append all cell contrast values from all experiments
    contrast_wound = [contrast_wound; contrast_wound_temp];
    contrast_cht = [contrast_cht; contrast_cht_temp];
    contrast_cht_norm = [contrast_cht_norm; contrast_cht_norm_temp];
    contrast_wound_norm = [contrast_wound_norm; contrast_wound_norm_temp];
    
end


