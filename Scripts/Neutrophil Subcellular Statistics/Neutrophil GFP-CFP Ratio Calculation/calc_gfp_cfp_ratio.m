% Script to segment neutrophils in CFP using active contour segmentation, 
% apply the segmentation in GFP and measure the ratio of GFP/CFP of 
% memrbane of those neutrophils

% Last Update:  09 Aug 2019


%% Beginning of script

% Define the experiment id
num_exp = 1;

% Set whether to draw the contour
draw_contour = 1;

% Suppress warnings
warning('off','all');

% Initialise the variables
ratio = [];

% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the GFP file name
    name_gfp = data_cell_gfp(exp_id);
    
    % Get the GFP file name
    file_gfp = ['Data\' name_gfp '.tif'];
    
    % Read image
    im_gfp = imread(file_gfp);
    % Double-precision transformation
    im_gfp = im2double(im_gfp);
    
    % Intialise the final binary image
    im_gfp_membr_final = zeros(size(im_gfp));
    
    % Get the CFP filename, neutrophil centre coordinates, iterations and bias 
    % for active contours (*)
    [name_cfp, neutro_x_cfp, neutro_y_cfp, iter, bias] = ...
        data_cell_cfp(exp_id);
    
    % Get the CFP file name
    file_cfp = ['Data\' name_cfp '.tif'];
    
    % Read image
    im_cfp = imread(file_cfp);
    % Double-precision transformation
    im_cfp = im2double(im_cfp);
    
    % Intialise the final binary image
    bw_final_cfp = zeros(size(im_cfp));
    bw_dil_final_cfp = zeros(size(im_cfp));
    im_cfp_membr_final = zeros(size(im_cfp));
    
    % Find the number of neutrophils/clusters
    num_cells_cfp = length(neutro_x_cfp);
    
    % Loop over all neutrophils to segment them
    for qq = 1:num_cells_cfp
        
        % Create the binary mask for each cell by extending by X pixels in x and 
        % y for the selected centroid
        mask_cfp = zeros(size(im_cfp));
        mask_cfp(neutro_y_cfp(qq)-5:neutro_y_cfp(qq)+5, ...
            neutro_x_cfp(qq)-5:neutro_x_cfp(qq)+5) = 1;
        
        % Apply active contour technique based on the initial area defined above
        bw_cfp = activecontour(im_cfp, mask_cfp, iter, 'Chan-Vese', ...
            'SmoothFactor', 0.8, 'ContractionBias', bias);
        
        % Eliminate very small segmented areas
        bw_cfp = bwareaopen(bw_cfp, 50);
        
        % Multiply the individual cell binary mask with the original image to 
        % get only grey-image of the cell
        im_cell_cfp = immultiply(im_cfp, bw_cfp);        
        im_cell_cfp(bw_cfp==0) = NaN;
        
        % Append binary image so to get teh final contours
        bw_final_cfp = bw_final_cfp + bw_cfp;
        
    end
    
    % Show figure with mask and save
    f = figure; imshow(bw_final_cfp);
    im_cont = getframe(f); 
    im_cont = im_cont.cdata;
    set(gca,'position',[0 0 1 1],'units','normalized')
%     imwrite(im_cont, ['Data\' name_cfp ' mask cells.tif']);
        
    
    %% Segment the membrane of the neutrophil
    
    % Loop over all neutrophils
    for kk = 1:num_cells_cfp
        
        % Get the boundaries
        [bound_cell, ~] = bwboundaries(bw_final_cfp, 'noholes');
        boundary = bound_cell{kk,1};
		
        % Make a binary image
        bw_temp_cfp = zeros(size(im_cfp));
        bw_temp_gfp = zeros(size(im_gfp));
		
        % Make the boundary pixels white
        for oo = 1:length(boundary)
            bw_temp_cfp(boundary(oo,1), boundary(oo,2)) = 1;
        end
		
        % Make the structural element
        se_dil = strel('disk', 4);
		
        % Dilate
        bw_temp_dil_cfp = imdilate(bw_temp_cfp, se_dil);
		
        % Subtract the boundary to create black space within the dilated
        % boundary
        bw_dil_temp_cfp = bw_temp_dil_cfp - bw_temp_cfp;
		
        % Find the white pixels
        [a,b] = find(bw_dil_temp_cfp == 1);
		
        % Find which of them are ouside the boundary
        out = find(~inpolygon(a, b, boundary(:,1),boundary(:,2)) == 1);
		
        % Get the coordinates
        xx = a(out); yy = b(out);
		
        % Loop over all coordinates to make them black in the binary image
        for kkk = 1:length(xx)
            bw_dil_temp_cfp(xx(kkk), yy(kkk)) = 0;
        end
        
        % Add the individual membrane mask to the final one and save figure
        bw_dil_final_cfp = bw_dil_final_cfp + bw_dil_temp_cfp;
        
        % Get the GFP membrane pixels
        im_gfp_membr = im_gfp .* bw_dil_temp_cfp;
        im_gfp_membr_final = im_gfp_membr_final + im_gfp_membr;
        
        % Get the CFP membrane pixels
        im_cfp_membr = im_cfp .* bw_dil_temp_cfp;
        im_cfp_membr_final = im_cfp_membr_final + im_cfp_membr;
        
        % Get the list of GFP/CFP ratios
        ratio_temp = im_gfp_membr ./ im_cfp_membr;
        
        % Get the mean ratio of GFP/CFP
        ratio(kk) = nanmean(ratio_temp(:));
        
    end
    
    
    %% Show membrane in CFP neutrophils and save    
    f = figure; imshow(im_cfp_membr_final); 
    im_cont = getframe(f); 
    im_cont = im_cont.cdata;
    set(gca,'position',[0 0 1 1],'units','normalized')
%     imwrite(im_cont, ['Data\' name_cfp ' membrane cells.tif']);
    
    % Show the image and plot boundaries
    if draw_contour == 1
        f = figure('visible', 'on'); imshow(im_cfp);
        hold on
        plot(neutro_x_cfp, neutro_y_cfp, 'y*');
        for kk = 1:num_cells_cfp
            [bound_cell, ~] = bwboundaries(bw_final_cfp, 'noholes');
            boundary = bound_cell{kk,1};
            plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1);
        end
        % Save the image with the contour
        im_cont = getframe(f); 
        im_cont = im_cont.cdata;
        set(gca,'position',[0 0 1 1],'units','normalized')
%         imwrite(im_cont, ['Data\' name_cfp ' contour cells.tif']);
    end
    
    % Invert the ratio variable
    ratio = ratio';
    
end



