function [ucm2, tree, b_feats] = save_ucm_tree_features(dir, filename)
% function [ucm2, tree, b_feats] = save_ucm_tree_features(dir, filename)
% Input: 
%   dir is the directory
%   filename is the name of the file

    disp(['processing image ', filename]);
    
    image_dir = 'rgb';
    depth_dir = 'depth';
    hierarchies_dir = 'hierarchies';
    hha_dir = 'hha';
    ucms_dir = 'ucms';
    
    %% Check if hierarchies already computed
    features_rgb = [dir, '/', hierarchies_dir, '/', filename, '.mat'];
    features_rgbhha = [dir, '/', hierarchies_dir, '/', filename, '_hha.mat'];
    if exist(features_rgb, 'file') == 2 & exist(features_rgbhha, 'file') == 2
        disp(['Features already computed for ', dir, ' ', filename]);
        return;
    end
    

    %% Load the rgb and depth image
    im_rgb = imread([dir, '/', image_dir, '/', filename, '.png']);
    im_dep = imread([dir, '/', depth_dir, '/', filename, '.png']);

    %% In paint depth image
    im_dep_filename = [dir, '/', depth_dir, '/', filename, '_ip.png'];
    if exist(im_dep_filename, 'file') == 2
        disp(['Loading existing file ', im_dep_filename]);
        im_dep_filled = imread(im_dep_filename);
    else
        disp('In painting depth image...');
        im_dep_filled = fill_depth_cross_bf(im_rgb, im2double(im_dep));
        im_dep_filled = im2uint16(im_dep_filled);
        imwrite(im_dep_filled, im_dep_filename);
    end

    %% Get HHA image
    hha_filename = [dir, '/', hha_dir, '/', filename, '.png'];
    if exist(hha_filename, 'file') == 2
        disp(['Loading existing file ', hha_filename]);
        hha = imread(hha_filename);
    else
        disp('Computing HHA features...');
        C = [1, 0, 0; 0, 1, 0; 0, 0, 1];
        hha = saveHHA([], C, [], im_dep_filled, im_dep);
        imwrite(hha, hha_filename);
    end
    
%     %% Compute UCMs
%     
%     % RGB only
%     ucm_filename = [dir, '/', ucms_dir, '/', filename, '.mat'];
%     if exist(ucm_filename, 'file') == 2
%         disp(['Loading existing file ', ucm_filename]);
%         load(ucm_filename, 'ucm2');
%     else
%         disp('Computing UCM for RGB...');
%         disp(['Size of image ', num2str(size(im_rgb,3))]);
%         [ucm2, ~, ~, ~, ~] = im2ucm(im_rgb);
%         save(ucm_filename, 'ucm2');
%         ucm_image_filename = [dir, '/', ucms_dir, '/', filename, '.png'];
%         imwrite(ucm2, ucm_image_filename);
%     end
% 
%     % Compute features and tree
%     hierarchy_filename = [dir, '/', hierarchies_dir, '/', filename, '.mat'];
%     if exist(hierarchy_filename, 'file') == 2
%         disp(['Loading existing file ', hierarchy_filename]);
%         load(hierarchy_filename, 'tree', 'b_feats');
%     else
%         disp('Computing features and tree hierarchy...');
%         [tree, b_feats] = ucm2tree(ucm2);
%         save(hierarchy_filename, 'tree', 'b_feats');
%     end
    
    %% RGB + HHA
    im = cat(3, im_rgb, hha);

    % Compute ucm for rgb + hha
    ucm_filename = [dir, '/', ucms_dir, '/', filename, '_hha.mat'];
    if exist(ucm_filename, 'file') == 2
        disp(['Loading existing file ', ucm_filename]);
        load(ucm_filename, 'ucm2');
    else
        disp('Computing UCM for RGB + HHA...');
        disp(['Size of image ', num2str(size(im,3))]);
        [ucm2, ~, ~, ~, ~] = im2ucm(im);
        save(ucm_filename, 'ucm2');
        ucm_image_filename = [dir, '/', ucms_dir, '/', filename, '_hha.png'];
        imwrite(ucm2, ucm_image_filename);
    end

    % Compute features and tree
    hierarchy_filename = [dir, '/', hierarchies_dir, '/', filename, '_hha.mat'];
    if exist(hierarchy_filename, 'file') == 2
        disp(['Loading existing file ', hierarchy_filename]);
        %load(hierarchy_filename, 'tree', 'b_feats');
    else
        disp('Computing features and tree hierarchy...');
        [tree, b_feats] = ucm2tree(ucm2);
        save(hierarchy_filename, 'tree', 'b_feats');
    end
end