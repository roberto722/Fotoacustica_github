function [sinograms, file_names] = dataloader_ForearmComplex(ids, model, data_folder)

if nargin < 3 || strlength(string(data_folder)) == 0
    %sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\transverse\';
    %sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex\longitudinal\';
    %sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Phantom_complex\Phantom_pencil_lead\transverse\';
    %sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\sim_31_25_mat\';
    sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\prove_x_BA\lead step12mm width25mm\mat files\';
else
    sino_folder = char(data_folder);
end

if isempty(ids)
    D_images = dir(fullfile(sino_folder, '*.mat'));
    ids = {D_images.name}';
end

wavelengths = {'750', '800', '850'};
field_names = { ...
    'RF_sottocampionato_31p25MHz_750', ...
    'RF_sottocampionato_31p25MHz_800', ...
    'RF_sottocampionato_31p25MHz_850' ...
};

num_sinograms = numel(ids) * numel(wavelengths);
file_names = cell(1, num_sinograms);
sinograms = [];
out_idx = 1;

for i = 1:numel(ids)
    file_ = load(fullfile(sino_folder, ids{i}));

    for w = 1:numel(wavelengths)
        checked_signal = check_length_ForearmComplex(file_.(field_names{w}), model);

        if isempty(sinograms)
            sinograms = zeros(size(checked_signal, 1), size(checked_signal, 2), num_sinograms, 'like', checked_signal);
        end

        sinograms(:, :, out_idx) = checked_signal;
        [basename, ~, ~] = fileparts(ids{i});
        file_names{out_idx} = strcat(basename, '_', wavelengths{w});
        out_idx = out_idx + 1;
    end
    i
end
