function file = check_length_HDF5(file, model)
    if size(file, 1) < model.Probe.DAC.numRecordedSamplesPerTransducer %&& size(file, 1) > (model.Probe.DAC.numRecordedSamplesPerTransducer - 3)
        while size(file, 1) < model.Probe.DAC.numRecordedSamplesPerTransducer
            file(end+1, :) = file(end, :);
        end
    elseif size(file, 1) > model.Probe.DAC.numRecordedSamplesPerTransducer && size(file, 1) < (model.Probe.DAC.numRecordedSamplesPerTransducer + 10)
        file = file(1:model.Probe.DAC.numRecordedSamplesPerTransducer, :);
    elseif size(file, 1) ~= model.Probe.DAC.numRecordedSamplesPerTransducer
        disp("WARNING: Sinogram does not fit with Probe settings!")
    end
    
end

