clear all
close all
%install

cmap = color_map(10000);

%file = 'img_005';
%hha = true;
%root_dir = 'ezylabel';
%image_dir = 'images';
%pointcloud_dir = 'pointcloud';
%hierarchies_dir = 'hierarchies';

%file = 'result_2018-08-20-09-30-33';
file = 'result_2018-08-21-11-50-58';
hha = false;
%root_dir = '/home/tpatten/Data/EasyLabel/OCID-dataset/ARID20/floor/bottom/seq01';
root_dir = '/home/tpatten/Data/EasyLabel/OCID-dataset/ARID20/table/bottom/seq03';
image_dir = 'rgb';
pointcloud_dir = 'pcd';
hierarchies_dir = 'hierarchies';

%DIR /home/tpatten/Data/EasyLabel/OCID-dataset/ARID20/table/bottom/seq03 FILE result_2018-08-21-11-50-58
%DIR /home/tpatten/Data/EasyLabel/OCID-dataset/ARID20/table/bottom/seq04 FILE result_2018-08-21-12-09-42
    
disp(['processing image ', file]);

% img_000: off-the-shelf
%          features use the resized input
%          point cloud is organised and includes nans
%          -- Does BEST --
% img_001: trying point cloud without nans
%          features use the resized input
%          point cloud is unusable because it has different size to image
%          -- Does not work! --
% img_002: trying features computed without resizing image
%          features use original image size
%          point cloud is organised and includes nans
%          -- Does BEST (is there difference to resized version?) --
% img_003: different caffe model for ucm (COB_PASCALContext_train)
%          features use original image size
%          point cloud is organised and includes nans
%          -- Not so good (over segmented) --
% img_004: different caffe model for ucm (COB_BSDS500)
%          features use original image size
%          point cloud is organised and includes nans
%          -- Not so good (over segmented) --
% img_005: off-the-shelf but different scene
%          features use the resized input
%          point cloud is organised and includes nans
%          can select hha version !!!

% Load data
im = imread([root_dir, '/', image_dir, '/', file, '.png']);
load([root_dir, '/', pointcloud_dir, '/', file, '.mat']);
if hha
    disp('Loading rgb + hha');
    hha_filename = [root_dir, '/', hierarchies_dir, '/', file, '_hha.mat'];
    if exist(hha_filename, 'file') == 2
        load(hha_filename);
    else
        warning(['HHA does not exist for ', file]);
        load([root_dir, '/', hierarchies_dir, '/', file, '.mat']);
    end
else
    disp('Loading rgb');
    load([root_dir, '/', hierarchies_dir, '/', file, '.mat']);
end

im_hsv = rgb2hsv(im);
im_hsv = reshape(im_hsv, [size(im,1)*size(im,2) 3]);
pc = reshape(pc, [size(pc,1)*size(pc,2) 3]);

% set nans to 0s
pc(isnan(pc)) = 0;

% randomly shuffle point cloud
%pc = pc(randperm(size(pc,1)),:); % gets worse results -> order is important


[seg] = scenecut_segmentation(im_hsv, pc, tree, b_feats);
% relabel ids from 1 onwards
seg_copy = seg;
unique_ids = sort(unique(seg_copy));
curr_label = 1;
for i=1:length(unique_ids)
    idx = seg_copy == unique_ids(i);
    seg_copy(idx) = curr_label;
    curr_label = curr_label + 1;
end
imwrite(uint16(seg_copy), 'result.png');
%rr = imread('result.png');
save('result.mat', 'seg');


% Display segmentation result
color_map = cmap;
seg_color = imoverlay(im, seg, 'colormap',color_map, 'facealpha',0.7,'zerocolor',[0 0 0],'zeroalpha',0.4, 'edgewidth',2, 'edgealpha',0.7);

seg_ids = unique(seg);
for i=1:length(seg_ids)
    l  = seg_ids(i); 
    if l <= 100 
        M = seg == seg_ids(i);
        stats = regionprops(M, 'Centroid');
        centroids = cat(1, stats.Centroid);   
        seg_color = insertText(seg_color, centroids, 'Surface', 'FontSize',12, 'AnchorPoint', 'Center', 'TextColor', 'blue', 'BoxOpacity',0.0);
    end
end

figure(1);imshow(seg_color);
drawnow;

