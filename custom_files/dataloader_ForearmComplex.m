function [sinograms, file_names] = dataloader_ForearmComplex(ids, model)

%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\transverse\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\longitudinal\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Phantom_complex\Phantom_pencil_lead\transverse\';
%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\sim_31_25_mat\';
sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\prove_x_BA\lead step12mm width25mm\mat files\';

if isempty(ids)
    D_images = dir([sino_folder '/*.mat']);
    ids = struct2cell(D_images);
    ids = ids(1, :)';
end

for i = 1:numel(ids)
    file_ = load(strcat(sino_folder, ids{i}));
    sinograms(:, :, 1+3*(i-1)) = check_length_ForearmComplex(file_.RF_sottocampionato_31p25MHz_750, model); 
    sinograms(:, :, 2+3*(i-1)) = check_length_ForearmComplex(file_.RF_sottocampionato_31p25MHz_800, model); 
    sinograms(:, :, 3+3*(i-1)) = check_length_ForearmComplex(file_.RF_sottocampionato_31p25MHz_850, model);

    file_names{1+3*(i-1)} = strcat(ids{i}(1:end-4), '_750');
    file_names{2+3*(i-1)} = strcat(ids{i}(1:end-4), '_800');
    file_names{3+3*(i-1)} = strcat(ids{i}(1:end-4), '_850');
    i
end

