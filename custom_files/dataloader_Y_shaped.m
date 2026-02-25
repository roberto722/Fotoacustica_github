function [sinograms, file_names] = dataloader_Y_shaped(ids, model)

%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\transverse\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\longitudinal\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Phantom_complex\Phantom_pencil_lead\transverse\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\sim_31_25_mat\';
%sino_folder = 'F:\Scardigno\Fotoacustica-MB\data\phantom_Y-shaped\mat_files\';
sino_folder = 'F:\Scardigno\Fotoacustica-MB\data\Phantom_Y-shaped_new_morphology\mat_files\';

if isempty(ids)
    D_images = dir([sino_folder '/*.mat']);
    ids = struct2cell(D_images);
    ids = ids(1, :)';
end

for i = 1:numel(ids)
    file_ = load(strcat(sino_folder, ids{i}));
    sinograms(:, :, i) = check_length_ForearmComplex(file_.RF_750, model);

    file_names{i} = strcat(ids{i}(1:end-4), '_750');
    i
end

