function config = build_generation_config(profile, overrides)
%BUILD_GENERATION_CONFIG Costruisce una configurazione centralizzata per la generazione immagini.
%
%   config = BUILD_GENERATION_CONFIG(profile)
%   config = BUILD_GENERATION_CONFIG(profile, overrides)
%
% profile supportati:
%   - "voc"
%   - "hdf5"
%   - "polito"
%   - "forearm_complex"
%   - "y_shaped"

    if nargin < 1 || isempty(profile)
        profile = "voc";
    end
    if nargin < 2
        overrides = struct();
    end

    local_paths = load_local_paths();
    config = local_default_config(local_paths);
    config.profile = string(profile);

    switch lower(config.profile)
        case "voc"
            config.source.type = "voc";
            config.source.dataset_name = "VOC2012";
            config.params.device_probe_id = "PoliTo_probe_saturazione_ossigeno";
            config.params.max_imgs = 100;
            config.params.VOC_id_imgs = {};
            config.params.mb_batch = 1;
            config.params.field_of_view = [-0.01905 0.01905 0 0.038];
            config.params.number_of_grid_points_fov = [256 256];
            config.params.speed_of_sound_tissue = 1540;
            config.params.filt_cutoff_max = 12e6;
            config.params.num_iterations_mb = 100;

        case "hdf5"
            config.source.type = "hdf5";
            config.params.device_probe_id = "PoliTo_probe_saturazione_ossigeno_HF";
            config.params.max_imgs = 1;
            config.params.HDF5_ids = {};
            config.params.field_of_view = [-0.01905 0.01905 0 0.02];
            config.params.number_of_grid_points_fov = [640 333];
            config.params.speed_of_sound_tissue = 1500;
            config.params.filt_cutoff_max = 4 * 12e6;
            config.params.num_iterations_mb = 50;

        case "polito"
            config.source.type = "polito";
            config.params.device_probe_id = "PoliTo_probe_phantoms";
            config.params.mat_filenames = {"US_base_long"};
            config.params.field_of_view = [-0.01905 0.01905 0 0.025];
            config.params.number_of_grid_points_fov = [668 429];
            config.params.speed_of_sound_tissue = 1250;
            config.params.filt_cutoff_min = 1;
            config.params.filt_cutoff_max = 12e6;
            config.params.num_iterations_mb = 50;

        case "forearm_complex"
            config.source.type = "forearm_complex";
            config.params.device_probe_id = "PoliTo_probe_oxy_PhantomComplex";
            config.params.max_imgs = 1;
            config.params.ForearmComplex_ids = {};
            config.params.field_of_view = [-0.01905 0.01905 0 0.020];
            config.params.number_of_grid_points_fov = [635 333];
            config.params.speed_of_sound_tissue = 1200;
            config.params.filt_cutoff_min = 1;
            config.params.filt_cutoff_max = 12e6;
            config.params.num_iterations_mb = 50;

        case "y_shaped"
            config.source.type = "y_shaped";
            config.params.device_probe_id = "PoliTo_probe_Y_shaped";
            config.params.max_imgs = 1;
            config.params.ForearmComplex_ids = {};
            config.params.field_of_view = [-0.02 0.02 0 0.0162];
            config.params.number_of_grid_points_fov = [640 267];
            config.params.speed_of_sound_tissue = 1500;
            config.params.filt_cutoff_min = 1;
            config.params.filt_cutoff_max = 6e7;
            config.params.num_iterations_mb = 100;

        otherwise
            error('Profilo non supportato: %s', config.profile);
    end

    config = merge_structs(config, overrides);
end

function config = local_default_config(local_paths)
    config = struct();
    config.profile = "voc";

    if isfield(local_paths, 'rec_toolbox_path')
        config.rec_toolbox_path = local_paths.rec_toolbox_path;
    else
        config.rec_toolbox_path = '';
    end

    config.source = struct();
    config.source.type = "voc";
    config.source.dataset_name = "VOC2012";

    config.params = struct();
    config.params.max_imgs = 1;
    config.params.use_eir = false;
    config.params.use_indiv_eir = false;
    config.params.use_sir = false;
    config.params.use_single_speed_of_sound = true;
    config.params.num_cropped_samples_at_sinogram_start = 0;
    config.params.filt_cutoff_min = 1e5;
    config.params.filt_cutoff_max = 12e6;
    config.params.field_of_view = [-0.01905 0.01905 0 0.038];
    config.params.number_of_grid_points_fov = [256 256];
    config.params.speed_of_sound_tissue = 1540;
    config.params.model_normalization_factor = [];
    config.params.broken_transducers = [];

    if isfield(local_paths, 'polito_data_folder')
        config.params.folder = local_paths.polito_data_folder;
    else
        config.params.folder = '';
    end

    config.params.regularization = '';
    config.params.lambda_shearlet = 1e-5;
    config.params.lambda_tikhonov = 1e-4;
    config.params.lambda_TV = 1e-4;
    config.params.lambda_L1_eye_reg = 1e-4;
    config.params.lambda_laplacian = 0;
    config.params.num_iterations_mb = 50;
end

function result = merge_structs(base, overrides)
    result = base;
    if ~isstruct(overrides)
        error('overrides deve essere una struct.');
    end

    fields = fieldnames(overrides);
    for i = 1:numel(fields)
        key = fields{i};
        val = overrides.(key);

        if isstruct(val) && isfield(result, key) && isstruct(result.(key))
            result.(key) = merge_structs(result.(key), val);
        else
            result.(key) = val;
        end
    end
end
