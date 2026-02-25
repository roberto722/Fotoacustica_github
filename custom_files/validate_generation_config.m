function validate_generation_config(config)
%VALIDATE_GENERATION_CONFIG Valida campi minimi della configurazione pipeline.

    if ~isstruct(config)
        error('config deve essere una struct.');
    end

    required_top_level = {'profile', 'source', 'params', 'rec_toolbox_path'};
    for i = 1:numel(required_top_level)
        field_name = required_top_level{i};
        if ~isfield(config, field_name)
            error('Campo config.%s mancante.', field_name);
        end
    end

    if ~isfield(config.source, 'type') || strlength(string(config.source.type)) == 0
        error('Campo config.source.type mancante o vuoto.');
    end

    if ~ischar(config.rec_toolbox_path) && ~(isstring(config.rec_toolbox_path) && isscalar(config.rec_toolbox_path))
        error('config.rec_toolbox_path deve essere char o string scalar.');
    end

    if strlength(string(config.rec_toolbox_path)) == 0
        error(['config.rec_toolbox_path non impostato. ' ...
               'Crea custom_files/local_paths.m a partire da custom_files/local_paths.example.m, ' ...
               'oppure passa overrides.rec_toolbox_path.']);
    end

    params = normalize_generation_params_names(config.params);
    source_type = lower(string(config.source.type));
    switch source_type
        case "voc"
            if ~isfield(config.source, 'dataset_name') || strlength(string(config.source.dataset_name)) == 0
                error('Per profilo VOC serve config.source.dataset_name.');
            end
            validate_ids_field(params, 'voc_ids', 'VOC/SINOGRAMMI');

        case "polito"
            if ~isfield(params, 'folder') || strlength(string(params.folder)) == 0
                error(['Per profilo PoliTo serve config.params.folder. ' ...
                       'Imposta paths.polito_data_folder in local_paths.m o overrides.params.folder.']);
            end
            if ~isfield(params, 'mat_filenames') || isempty(params.mat_filenames)
                error('Per profilo PoliTo serve config.params.mat_filenames non vuoto.');
            end

        case "hdf5"
            validate_ids_field(params, 'hdf5_ids', 'HDF5');

        case "forearm_complex"
            validate_ids_field(params, 'forearm_complex_ids', 'forearm_complex');

        case "y_shaped"
            validate_ids_field(params, 'forearm_complex_ids', 'y_shaped');

        otherwise
            error('Tipo sorgente non supportato: %s', config.source.type);
    end
end

function validate_ids_field(params, field_name, profile_name)
    if ~isfield(params, field_name)
        error(['Per profilo %s serve config.params.%s (anche vuoto). ' ...
               'Puoi usare anche l''alias legacy dove previsto.'], profile_name, field_name);
    end

    value = params.(field_name);
    valid_type = iscell(value) || isstring(value) || isnumeric(value);
    if ~valid_type
        error('config.params.%s deve essere cell/string/numerico.', field_name);
    end
end
