clear all
close all

I_rgb_nyu = imread('includes/rcnn-depth/demo-data/images.png');
I_dep_nyu = imread('includes/rcnn-depth/demo-data/depth.png');
I_dep_raw_nyu = imread('includes/rcnn-depth/demo-data/rawdepth.png');

I_rgb_ezy = imread('ezylabel/images/img_005.png');
I_dep_raw_ezy = imread('ezylabel/depth/img_005.png');

C = [1, 0, 0; 0, 1, 0; 0, 0, 1];
I_dep_ezy = fill_depth_cross_bf(I_rgb_ezy, im2double(I_dep_raw_ezy));

hha_nyu = saveHHA([], C, [], I_dep_nyu, I_dep_raw_nyu);
%imwrite(hha_nyu, 'hha_nyu.png');
hha_ezy = saveHHA([], C, [], I_dep_ezy, I_dep_raw_ezy);
%imwrite(hha_ezy, 'hha_ezy.png');

h1_nyu = reshape(hha_nyu(:,:,1), 1 , []);
h2_nyu = reshape(hha_nyu(:,:,2), 1 , []);
a_nyu = reshape(hha_nyu(:,:,3), 1 , []);

h1_ezy = reshape(hha_ezy(:,:,1), 1 , []);
h2_ezy = reshape(hha_ezy(:,:,2), 1 , []);
a_ezy = reshape(hha_ezy(:,:,3), 1 , []);

h1_nyu = double(h1_nyu);
h2_nyu = double(h2_nyu);
a_nyu = double(a_nyu);
h1_ezy = double(h1_ezy);
h2_ezy = double(h2_ezy);
a_ezy = double(a_ezy);

disp('NYU');
disp(['h1 ', num2str(min(h1_nyu)), ' ',  num2str(max(h1_nyu))]);
disp(['h2 ', num2str(min(h2_nyu)), ' ',  num2str(max(h2_nyu))]);
disp(['a  ', num2str(min(a_nyu)), ' ',  num2str(max(a_nyu))]);

disp('EZY');
disp(['h1 ', num2str(min(h1_ezy)), ' ',  num2str(max(h1_ezy))]);
disp(['h2 ', num2str(min(h2_ezy)), ' ',  num2str(max(h2_ezy))]);
disp(['a  ', num2str(min(a_ezy)), ' ',  num2str(max(a_ezy))]);

disp('NYU');
[counts,els] = hist(h1_nyu, unique(h1_nyu));
disp('h1');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);
[counts,els] = hist(h2_nyu, unique(h2_nyu));
disp('h2');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);
[counts,els] = hist(a_nyu, unique(a_nyu));
disp('a');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);

disp('EZY');
[counts,els] = hist(h1_ezy, unique(h1_ezy));
disp('h1');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);
[counts,els] = hist(h2_ezy, unique(h2_ezy));
disp('h2');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);
[counts,els] = hist(a_ezy, unique(a_ezy));
disp('a');
disp(['element: ', num2str(els)]);
disp(['counts: ', num2str(counts)]);

%histogram(h1_nyu, 20);
%axis([0 5 0 255]);

%figure;
%histogram(h1_ezy, 20);
%axis([0 5 0 255]);

%min_h1_nyu = min(h1_nyu);
%max_h1_nyu = max(h1_nyu);
%min_h2_nyu = min(h2_nyu);
%max_h2_nyu = max(h2_nyu);
%min_a_nyu = min(a_nyu);
%max_a_nyu = max(a_nyu);

%min_h1_nyu = min(h1_ezy);
%max_h1_nyu = max(h1_ezy);
%min_h2_nyu = min(h2_ezy);
%max_h2_nyu = max(h2_ezy);
%min_a_nyu = min(a_ezy);
%max_a_nyu = max(a_ezy);