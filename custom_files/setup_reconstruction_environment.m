function setup_reconstruction_environment(config)
%SETUP_RECONSTRUCTION_ENVIRONMENT Inizializza il toolbox di ricostruzione.

    if ~isfield(config, 'rec_toolbox_path') || isempty(config.rec_toolbox_path)
        error(['config.rec_toolbox_path non impostato. ' ...
               'Configura custom_files/local_paths.m o overrides.rec_toolbox_path.']);
    end

    startup_script = fullfile(config.rec_toolbox_path, 'startup_reconstruction.m');
    if ~isfile(startup_script)
        error('Startup script non trovato: %s', startup_script);
    end

    run(startup_script);
end
