function [best_sinogram] = dataloader_POLITO(folder, mat_filename, model)

load(folder + "/" + mat_filename, "RcvData");
sinograms = RcvData{1}(1:model.Probe.DAC.numRecordedSamplesPerTransducer, :, :);

max_value = 0;
max_value_temp = 0;
best_sinogram = sinograms(:, :, 1);
for s = 1:size(sinograms, 3)
    max_value_temp = max(sinograms(:, :, s), [], "all");
    if max_value_temp > max_value
        best_sinogram = sinograms(:, :, s);
        max_value = max_value_temp;
    end
end

%best_sinogram = best_sinogram/2;
%best_sinogram(800:4096, :) = zeros(4096+1-800, 128);

% figure
% imshow(best_sinogram(1:1000, :)')
% figure
% imshow(best_sinogram(1:1000, :)', [0 1000])
a = 0;