% Script to segment GFP neutrophils and apply segmentation to mCherry channel
% to assess chemokine consumption from co-localisation of GFP and mCherry
% signal

% Last Update:  25 Jun 2019


%% Define the number of experiments (*)
num_exp = 3;

% Define whether to draw the contour
draw_contour = 1;

% Define whether to save data
save_data = 1;

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, transplant perimeter, neutrophil centre coordinates, 
    % number of iterations and bias for active contours (*)
    [name, transpl_x, transpl_y, neutro_x, neutro_y, iter, bias] = ...
        cell_data(exp_id);
    
    % Choose the directory of data (*)
    dir_data = ['Data'];
    
    
    %% GFP image processing
    
    % Read first image
    im_gfp = imread([dir_data '\' name ' GFP.tif']);
    % Double-precision transformation
    im_gfp = im2double(im_gfp);
    
    % Intialise the final binary image
    bw_final = zeros(size(im_gfp));
    
    % Find the number of neutrophils-clusters
    num_cells = length(neutro_x);
    
    % Initialise the neutrophil intensity variable
    cell_intens = nan(num_cells,1);
    
    % Read mCherry image
    im_mcherry = imread([dir_data '\' name ' mCherry.tif']);
    % Double-precision transformation
    im_mcherry = im2double(im_mcherry);
    
    % Loop over all neutrophils to get the intensity
    for qq = 1:num_cells
        
        % Create the binary mask for each cell by extending by X pixels in x and 
        % y for the selected centroid
        mask = zeros(size(im_gfp));
        mask(neutro_y(qq)-5:neutro_y(qq)+5, neutro_x(qq)-5:neutro_x(qq)+5) = 1;
        
        % Apply active contour technique based on the initial area defined above
        bw = activecontour(im_gfp, mask, iter, 'Chan-Vese', 'SmoothFactor', ...
            0.5, 'ContractionBias', bias);
        
        % Eliminate very small segmented areas
        bw = bwareaopen(bw, 50);
        
        % Multiply the individual cell binary mask with the original image to 
        % get only grey-image of the cell
        cell_image = immultiply(im_gfp, bw);
        cell_image(bw==0) = NaN;
        
        % Get the neutrophil intensities at mCherry
        im_mcherry_cell = immultiply(im_mcherry, cell_image);
        
        % Find the neutrophil mean intensity
        cell_intens(qq) = nanmean(im_mcherry_cell(:));
        
        % Get the binary image
        bw_final = bw_final + bw;
        
    end
    
    % Show the image and plot boundaries
    if draw_contour == 1
        f = figure('visible', 'on'); imshow(im_gfp);
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
        imwrite(im_cont, ['Data\' name ' GFP contour.tif']);
    end

    
    %% mCherry image processing, segment mCherry image based on GFP image

    % Choose the area of image that includes the transplant
    im_trans = im_mcherry(transpl_y:transpl_y+150, transpl_x:transpl_x+150);

    % Find the mean intensity of the transplant area
    im_trans_mean = nanmean(im_trans(:));
        
    % Find the normalised mean cell intensity
    cell_intens_norm = cell_intens / im_trans_mean;
    
    % Show the image and plot boundaries
    if draw_contour == 1
        f = figure('visible', 'on'); imshow(im_mcherry);
        hold on
        plot(neutro_x, neutro_y, 'b*');
        for kk = 1:num_cells
            [bound_cell, ~] = bwboundaries(bw_final, 'noholes');
            boundary = bound_cell{kk,1};
            plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1);
            rectangle('Position', [transpl_x transpl_y 150 150], 'EdgeColor', 'y');
        end
        % Save the image with the contour (*)
        im_cont = getframe(f); 
        im_cont = im_cont.cdata;
        set(gca,'position',[0 0 1 1],'units','normalized')
        imwrite(im_cont, ['Data\' name ' mCherry contour.tif']);
    end
    
    
    %% Append data to a single matrix
    if save_data == 1
        if exp_id == 1
            cell_intens_norm_all = cell_intens_norm;
        else
            cell_intens_norm_all = [cell_intens_norm_all; cell_intens_norm];
        end
    end
    
end


%% Save variables (*)
if save_data == 1
    save('cell_intens.mat', 'cell_intens_norm_all');
end
    

