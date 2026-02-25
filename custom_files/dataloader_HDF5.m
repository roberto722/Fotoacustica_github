function [sinograms, file_names] = dataloader_HDF5(ids, model)

%sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm2000\'; 
sino_folder = 'E:\Scardigno\Fotoacustica-MB\data\Forearm_complex_HDF5_samples\transverse\';

if isempty(ids)
    D_images = dir([sino_folder '/*.hdf5']);
    ids = struct2cell(D_images);
    ids = ids(1, :)';
end

for i = 1:numel(ids)
    sinograms(:, :, 1+3*(i-1)) = check_length_HDF5(h5read(strcat(sino_folder, ids{i}), '/simulations/time_series_data/750'), model);
    sinograms(:, :, 2+3*(i-1)) = check_length_HDF5(h5read(strcat(sino_folder, ids{i}), '/simulations/time_series_data/800'), model);
    sinograms(:, :, 3+3*(i-1)) = check_length_HDF5(h5read(strcat(sino_folder, ids{i}), '/simulations/time_series_data/850'), model);

    file_names{1+3*(i-1)} = strcat(ids{i}(1:end-5), '_750');
    file_names{2+3*(i-1)} = strcat(ids{i}(1:end-5), '_800');
    file_names{3+3*(i-1)} = strcat(ids{i}(1:end-5), '_850');
    i
end


