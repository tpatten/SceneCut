clear all;
close all;

% To store status

% Define root directory
root_dir = '/home/tpatten/Data/EasyLabel/OCID-dataset/YCB10/';
% Subdirectories level 1
sub_dirs_1 = ["floor", "table"];
% Subdirectories level 2
sub_dirs_2 = ["bottom", "top"];
% Subdirectories level 3
sub_dirs_3 = ["cuboid", "curved", "mixed"];
% Save directory
save_dir = '/home/tpatten/Data/EasyLabel/OCID-dataset/scenecut_ycb10';
hha = true;
if (hha)
    save_dir = [save_dir, '_rgbhha/'];
else
    save_dir = [save_dir, '_rgb/'];
end
% Color map
color_map = color_map(10000);

%sub_dirs_1 = ["floor"];
%sub_dirs_2 = ["bottom"];

% For each sub directory level 1
for i=1:length(sub_dirs_1)
    % For each sub directory level 2
    for j=1:length(sub_dirs_2)
        % For each sub directory level 3
        for jj=1:length(sub_dirs_3)
            % Path
            d = strcat(root_dir, sub_dirs_1(i), "/", sub_dirs_2(j), "/", sub_dirs_3(jj));
            % Get all subdirectories (equivalent to the sequences)
            dirs = dir(d{1});
            dir_flags = [dirs.isdir];
            subs = dirs(dir_flags);
            % Remove '.' and '..'
            subs(1:2) = [];
            % For all subdirectories
            for k=1:length(subs)
            %for k=1:1
                dir_process = [d{1}, '/', subs(k).name];
                % Create the directories to store results
                %mkdir(dir_process, 'hha');
                %mkdir(dir_process, 'ucms');
                %mkdir(dir_process, 'hierarchies');
                % Get all files (look in the rgb directory)
                filenames = dir([dir_process, '/rgb',]);
                filenames(1:2) = [];
                for f=1:length(filenames)
                %for f=1:1
                    % Get the filename without the extension
                    [~, fname, ~] = fileparts(filenames(f).name);
                    %disp(['DIR ', dir_process, ' FILE ', fname]);
                    % Set the file names to save results
                    save_png_filename = [save_dir, fname, '.png'];
                    save_mat_filename = [save_dir, fname, '.mat'];
                    % Check if results already exist
                    image_exists = exist(save_png_filename, 'file') == 2;
                    mat_exists = exist(save_mat_filename, 'file') == 2;
                    successful_hierarchy = true;
                    if image_exists & mat_exists
                        disp(['Segmentation already computed for ', fname]);
                        successful_hierarchy = false;
                    else
                        % Load the image
                        im = imread([dir_process, '/rgb/', fname, '.png']);
                        % Load the point cloud
                        load([dir_process, '/pcd/', fname, '.mat']);
                        % Load the hierarchy tree and features
                        if hha
                            disp('Loading rgb + hha');
                            hha_filename = [dir_process, '/hierarchies/', fname, '_hha.mat'];
                            if exist(hha_filename, 'file') == 2
                                load(hha_filename);
                            else
                                warning(['HHA does not exist for ', file]);
                                successful_hierarchy = false;
                            end
                        else
                            disp('Loading rgb');
                            load([dir_process, '/hierarchies/', fname, '.mat']);
                        end
                         % If successfully loaded data
                        if successful_hierarchy
                            % Convert rgb to hsv
                            im_hsv = rgb2hsv(im);
                            im_hsv = reshape(im_hsv, [size(im,1)*size(im,2) 3]);
                            % Reshape the point cloud
                            pc = reshape(pc, [size(pc,1)*size(pc,2) 3]);
                            % Set nans to 0s
                            pc(isnan(pc)) = 0;
                        end
                    end
                    % If successfully loaded data
                    if successful_hierarchy
                        % Load or perform segmentation
                        if mat_exists
                            disp(['.mat already computed for ', fname]);
                            load(save_mat_filename, 'seg');
                        else
                            disp('Calling SceneCut...');
                            try
                                [seg] = scenecut_segmentation(im_hsv, pc, tree, b_feats);
                            catch
                                warning(['Error processing file ', fname]);
                                disp(['DIR ', dir_process, ' FILE ', fname]);
                                successful_hierarchy = false;
                            end
                        end

                        % If image is already saved then just save the .mat file
                        if successful_hierarchy & image_exists & ~mat_exists
                            disp(['Only need to save .mat ', save_mat_filename]);
                            save(save_mat_filename, 'seg');
                        elseif successful_hierarchy & ~image_exists
                            % Relabel ids from 1 onwards
                            seg_copy = seg;
                            unique_ids = sort(unique(seg));
                            curr_label = 1;
                            for s=1:length(unique_ids)
                                idx = seg_copy == unique_ids(s);
                                seg_copy(idx) = curr_label;
                                curr_label = curr_label + 1;
                            end
                            disp(['Saving result to', save_png_filename]);
                            imwrite(uint16(seg_copy), save_png_filename);
                            seg_color = imoverlay(im, seg, 'colormap', color_map, ...
                                                  'facealpha', 0.7, ...
                                                  'zerocolor', [0 0 0], ...
                                                  'zeroalpha' ,0.4, ...
                                                  'edgewidth', 2, ...
                                                  'edgealpha', 0.7);
                            imwrite(seg_color, [save_dir, 'images/orig_', fname, '.png']);
                            seg_color = imoverlay(im, seg, 'colormap', color_map, ...
                                                  'facealpha', -1);
                            imwrite(seg_color, [save_dir, 'images/icra_', fname, '.png']);
                            if ~mat_exists
                                save(save_mat_filename, 'seg');
                            end
                        end
                    end
                    clear im im_hsv pc seg tree b_feats seg seg_copy seg_color ...
                          unique_ids successful_hierarchy image_exists mat_exists ...
                          save_png_filename save_mat_filename;
                end
            end
        end
    end
end
