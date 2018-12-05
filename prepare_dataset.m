clear all
close all

% Define root directory
root_dir = '/home/tpatten/Data/EasyLabel/OCID-dataset/YCB10/';
% Subdirectories level 1
sub_dirs_1 = ["floor", "table"];
% Subdirectories level 2
sub_dirs_2 = ["bottom", "top"];
% Subdirectories level 3
sub_dirs_3 = ["cuboid", "curved", "mixed"];
%sub_dirs_1 = ["floor"];
%sub_dirs_2 = ["bottom"];

% Directory names
image_dir = 'rgb';
hierarchies_dir = 'hierarchies';
pcd_dir = 'pcd';

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
                mkdir(dir_process, 'hha');
                mkdir(dir_process, 'ucms');
                mkdir(dir_process, 'hierarchies');
                % Get all files (look in the rgb directory)
                filenames = dir([dir_process, '/', image_dir]);
                filenames(1:2) = [];
                for f=1:length(filenames)
                %for f=1:1
                    disp(['DIR ', dir_process, ' FILE ', filenames(f).name]);
                    % Get the filename without the extension
                    [~, fname, ~] = fileparts(filenames(f).name);
                    % If already processed
                    features_rgb = [dir_process, '/', hierarchies_dir, '/', fname, '.mat'];
                    features_rgbhha = [dir_process, '/', hierarchies_dir, '/', fname, '_hha.mat'];
                    if exist(features_rgb, 'file') == 2 & exist(features_rgbhha, 'file') == 2
                        disp(['Features already computed for ', dir_process, ' ', fname]);
                    else
                        % Save the ucm, tree and features
                        save_ucm_tree_features(dir_process, fname);
                    end
                    % Save the point cloud as a .mat
                    pc_filename = [dir_process, '/', pcd_dir, '/', fname, '.mat'];
                    if exist(pc_filename, 'file') == 2
                        disp(['Loading existing file ', pc_filename]);
                    else
                        disp('Storing point cloud as .mat...');
                        pc = pcread([dir_process, '/', pcd_dir, '/', fname, '.pcd']);
                        pc = pc.Location;
                        save(pc_filename, 'pc');
                    end
                end
            end
        end
    end
end
