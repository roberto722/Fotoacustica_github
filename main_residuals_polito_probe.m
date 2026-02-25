% TO DO: Inserire plot che mostra sensori rispetto a FOV

clear

params = build_params();
run([params.path_to_rec_toolbox filesep 'startup_reconstruction.m']);

model = define_model_for_reconstruction( ...
    params.field_of_view, ...
    params.number_of_grid_points_fov, ...
    params.device_probe_id, ...
    params.use_eir, ...
    params.use_indiv_eir, ...
    params.use_sir, ...
    params.use_single_speed_of_sound, ...
    params.speed_of_sound_tissue, ...
    params.num_cropped_samples_at_sinogram_start, ...
    params.filt_cutoff_min, ...
    params.filt_cutoff_max, ...
    params.model_normalization_factor);

reg_methods = ["L1_SHEARLET"];
lambdas = ["1e-8", "1e-7", "1e-6", "1e-5", "1e-4", "1e-3", "1e-2", "1e-1", "1"];

results = run_lambda_sweep(params, model, reg_methods, lambdas, 'PRIN_TRUE_L-CURVE');
save_residuals(results, params.voc_ids);

function params = build_params()
    params = struct();
    params.path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
    params.device_probe_id = 'PoliTo_probe';
    params.max_imgs = 1;

    params.voc_ids = ["lead_diffusors_GT"];
    params = normalize_generation_params_names(params);

    params.use_eir = true;
    params.use_indiv_eir = false;
    params.use_sir = false;
    params.use_single_speed_of_sound = true;
    params.num_cropped_samples_at_sinogram_start = 0;
    params.filt_cutoff_min = 3e6;
    params.filt_cutoff_max = 14e6;
    params.field_of_view = [-0.01905 0.01905 0 0.038];
    params.number_of_grid_points_fov = [256 256];
    params.speed_of_sound_tissue = 1540;
    params.model_normalization_factor = [];
    params.broken_transducers = [];
    params.regularization = '';
    params.lambda_shearlet = 1e-4;
    params.lambda_tikhonov = 1e-4;
    params.lambda_TV = 1e-3;
    params.lambda_L1_eye_reg = 1e-4;
    params.lambda_laplacian = 0;
    params.num_iterations_mb = 200;
end

function results = run_lambda_sweep(params, model, reg_methods, lambdas, dataset_name)
    results = initialize_results(reg_methods, params.voc_ids, lambdas);

    for i = 1:numel(lambdas)
        for id = 1:numel(params.voc_ids)
            params.lambda_shearlet = str2double(lambdas(i));
            params.lambda_TV = str2double(lambdas(i));

            [recs, ~, lCurveErrImg, lCurveErrReg] = reconstruct_from_VOC_residuals( ...
                dataset_name, model, params, reg_methods, true);

            recs_names = fieldnames(recs);
            for j = 1:size(recs_names, 1)
                recs_name = recs_names{j};
                if recs_name ~= "BACKPROJECTION"
                    results.(recs_name){id}(i, :) = {lambdas(i), lCurveErrImg.(recs_name), lCurveErrReg.(recs_name)};
                end
            end
        end
    end
end

function results = initialize_results(reg_methods, image_ids, lambdas)
    results = struct();
    for a = 1:numel(reg_methods)
        results.(reg_methods(a)) = cell(1, numel(image_ids));
        for b = 1:numel(image_ids)
            results.(reg_methods(a)){b} = table('Size', [size(lambdas, 2), 3], ...
                'VariableTypes', ["string", "double", "double"], ...
                'VariableNames', ["Lambda", "lCurveErrImg_" + string(image_ids(b)), "lCurveErrReg_" + string(image_ids(b))]);
        end
    end
end

function save_residuals(results, image_ids)
    for id = 1:numel(image_ids)
        save(sprintf("residuals_%s.mat", string(image_ids(id))), 'results');
    end
end
