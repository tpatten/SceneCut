%clear all
%close all

file = 'img_005';
root_dir = 'ezylabel';
    
disp(['processing image ', file]);

% Load the rgb and depth image
im_rgb = imread([root_dir, '/images/', file, '.png']);
im_dep = imread([root_dir, '/depth/', file, '.png']);

%function [pc, N, yDir, h, pcRot, NRot] = processDepthImage(z, missingMask, C)

% In paint depth image
im_dep_filename = [root_dir, '/depth/', file, '_ip.png'];
if exist(im_dep_filename, 'file') == 2
    disp(['Loading existing file ', im_dep_filename]);
    im_dep_filled = imread(im_dep_filename);
else
    disp('In painting depth image...');
    im_dep_filled = fill_depth_cross_bf(im_rgb, im2double(im_dep));
    im_dep_filled = im2uint16(im_dep_filled);
    imwrite(im_dep_filled, im_dep_filename);
end

% Get HHA image
hha_filename = [root_dir, '/hha/', file, '.png'];
if exist(hha_filename, 'file') == 2
    disp(['Loading existing file ', hha_filename]);
    hha = imread(hha_filename);
else
    disp('Computing HHA features...');
    C = [1, 0, 0; 0, 1, 0; 0, 0, 1];
    hha = saveHHA([], C, [], im_dep_filled, im_dep);
    imwrite(hha, hha_filename);
end
im = cat(3, im_rgb, hha);

% Compute ucm
ucm_filename = [root_dir, '/ucms/', file, '_hha.mat'];
if exist(ucm_filename, 'file') == 2
    disp(['Loading existing file ', ucm_filename]);
    load(ucm_filename, 'ucm2');
else
    disp('Computing UCM...');
    [ucm2, ucms, ~, O, E] = im2ucm(im);
    save(ucm_filename, 'ucm2');
end

% Compute features and tree
hierarchy_filename = [root_dir, '/hierarchies/', file, '_hha.mat'];
if exist(hierarchy_filename, 'file') == 2
    disp(['Loading existing file ', hierarchy_filename]);
    load(hierarchy_filename, 'tree', 'b_feats');
else
    disp('Computing features and tree hierarchy...');
    [tree, b_feats] = ucm2tree(ucm2);
    save(hierarchy_filename, 'tree', 'b_feats');
end