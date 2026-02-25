function file = check_length_HDF5_subsampler(file, model)
    if size(file, 1) < 4106
        while size(file, 1) < 4106
            file(end+1, :) = file(end, :);
        end
    elseif size(file, 1) > 4106
        file = file(1:4106, :);
    elseif size(file, 1) ~= model.Probe.DAC.numRecordedSamplesPerTransducer
        disp("WARNING: Sinogram does not fit with Probe settings!")
    end
    
end

