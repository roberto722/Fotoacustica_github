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

    source_type = lower(string(config.source.type));
    switch source_type
        case "voc"
            if ~isfield(config.source, 'dataset_name') || strlength(string(config.source.dataset_name)) == 0
                error('Per profilo VOC serve config.source.dataset_name.');
            end

        case "polito"
            if ~isfield(config.params, 'folder') || strlength(string(config.params.folder)) == 0
                error(['Per profilo PoliTo serve config.params.folder. ' ...
                       'Imposta paths.polito_data_folder in local_paths.m o overrides.params.folder.']);
            end
            if ~isfield(config.params, 'mat_filenames') || isempty(config.params.mat_filenames)
                error('Per profilo PoliTo serve config.params.mat_filenames non vuoto.');
            end

        case "hdf5"
            if ~isfield(config.params, 'HDF5_ids')
                error('Per profilo HDF5 serve config.params.HDF5_ids (anche vuoto).');
            end

        case "forearm_complex"
            if ~isfield(config.params, 'ForearmComplex_ids')
                error('Per profilo forearm_complex serve config.params.ForearmComplex_ids (anche vuoto).');
            end

        case "y_shaped"
            if ~isfield(config.params, 'ForearmComplex_ids')
                error('Per profilo y_shaped serve config.params.ForearmComplex_ids (anche vuoto).');
            end

        otherwise
            error('Tipo sorgente non supportato: %s', config.source.type);
    end
end
