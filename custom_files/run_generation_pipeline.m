function run_generation_pipeline(config)
%RUN_GENERATION_PIPELINE Esegue la pipeline di ricostruzione in base al profilo.

    config.params = normalize_generation_params_names(config.params);
    validate_generation_config(config);
    setup_reconstruction_environment(config);
    params = config.params;
    model = build_reconstruction_model(params);

    switch lower(string(config.source.type))
        case "voc"
            reconstruct_from_VOC(config.source.dataset_name, model, params);

        case "hdf5"
            reconstruct_from_HDF5(params, model);

        case "polito"
            for i = 1:numel(params.mat_filenames)
                params.mat_filename = params.mat_filenames{i}; %#ok<AGROW>
                reconstruct_from_POLITO(params, model);
            end

        case "forearm_complex"
            reconstruct_from_matlabForearmComplex(params, model);

        case "y_shaped"
            reconstruct_from_Y_shaped(params, model);

        otherwise
            error('Tipo sorgente non supportato: %s', config.source.type);
    end
end
