function [sinograms, file_names] = dataloader_HDF5(ids, model)

%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm2000\';
sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex_HDF5_samples\transverse\';

if isempty(ids)
    D_images = dir(fullfile(sino_folder, '*.hdf5'));
    ids = {D_images.name}';
end

wavelengths = {'750', '800', '850'};
num_sinograms = numel(ids) * numel(wavelengths);
file_names = cell(1, num_sinograms);
sinograms = [];
out_idx = 1;

for i = 1:numel(ids)
    for w = 1:numel(wavelengths)
        wavelength = wavelengths{w};
        path_hdf5 = fullfile(sino_folder, ids{i});
        raw_signal = h5read(path_hdf5, ['/simulations/time_series_data/' wavelength]);
        checked_signal = check_length_HDF5(raw_signal, model);

        if isempty(sinograms)
            sinograms = zeros(size(checked_signal, 1), size(checked_signal, 2), num_sinograms, 'like', checked_signal);
        end

        sinograms(:, :, out_idx) = checked_signal;
        [basename, ~, ~] = fileparts(ids{i});
        file_names{out_idx} = strcat(basename, '_', wavelength);
        out_idx = out_idx + 1;
    end
    i
end
