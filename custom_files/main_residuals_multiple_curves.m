% TO DO: Inserire plot che mostra sensori rispetto a FOV

clc; clear
path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);

%% Define model
params.device_probe_id = 'PoliTo_probe'; %'PoliTo_probe_curved_fake'; % see Probe.m for all available probes
params.max_imgs = 1;
VOC_id_imgs = {"2009_004734.jpg"}%, "2007_002216.jpg", "2007_000123.jpg", "2007_001761.jpg"}; %
%params.VOC_id_imgs = 4;
params.use_eir = true;
params.use_indiv_eir = false;
params.use_sir = false;
params.use_single_speed_of_sound = true;
params.num_cropped_samples_at_sinogram_start = 0;
params.filt_cutoff_min = 0;
params.filt_cutoff_max = 0;
if strcmp(params.device_probe_id, 'PoliTo_probe')
    params.field_of_view = [-0.01905 0.01905 -0.0192 0.0192];
else
    params.field_of_view = [-0.02 0.02 -0.02 0.02]; % [x_fov_min x_fov_max z_fov_min z_fov_max]
end
params.number_of_grid_points_fov = [256 256];            % [grid_points_x_dimension grid_points_z_dimension]
params.speed_of_sound_tissue = 1524;
params.model_normalization_factor = [];                  % if empty, the model is normalized so that its largest singular values is 1.
params.broken_transducers = [];
%%%%%%%% REGULARIZATION Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NN_REC_WITHOUT_REG        -> Non-negative reconstruction without regularization
% L2_TIKHONOV_AND_LAPLACIAN -> Non-negative reconstruction with L2 and L2 Laplace regularization
% L1_SHEARLET               -> Shearlet non-negative limited view reconstruction
% TV_NN_REG                 -> TV non-negative limited view reconstruction
% L1_EYE_REG                -> Non-negative reconstruction with L1 eye reg. matrix
params.regularization = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.lambda_shearlet = 1e-4; %1e-2 su set_parameters_for_data_generation.m di deepMB  % Strength of Shearlet L1 regularization, only used if regularization = 'L1_SHEARLET' 
params.lambda_tikhonov = 1e-4;                           % Strength of Tikhonov regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.lambda_TV = 1e-3;
params.lambda_L1_eye_reg = 1e-4;
params.lambda_laplacian = 0;                             % Strength of L2 Laplacian regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.num_iterations_mb = 200;
params_concave = load_params_concave(params);


model_linear = define_model_for_reconstruction(params.field_of_view, params.number_of_grid_points_fov, params.device_probe_id, params.use_eir, params.use_indiv_eir, params.use_sir, params.use_single_speed_of_sound, params.speed_of_sound_tissue, params.num_cropped_samples_at_sinogram_start, params.filt_cutoff_min, params.filt_cutoff_max, params.model_normalization_factor);
model_concave = define_model_for_reconstruction(params_concave.field_of_view, params_concave.number_of_grid_points_fov, 'PoliTo_probe_curved_fake', params_concave.use_eir, params_concave.use_indiv_eir, params_concave.use_sir, params_concave.use_single_speed_of_sound, params_concave.speed_of_sound_tissue, params_concave.num_cropped_samples_at_sinogram_start, params_concave.filt_cutoff_min, params_concave.filt_cutoff_max, params_concave.model_normalization_factor);

%% Execute reconstruction and calculate residuals
reg_methods = ["TV_NN_REG"] %, "TV_NN_REG"];
%lambdas = ["1e-8", "1e-7", "1e-6", "1e-5", "1e-4", "2e-4", "3e-4", "5e-4", "8e-4", "1e-3", "1.4e-3", "1.8e-3", "2e-3", "3e-3", "5e-3", "8e-3", "1e-2", "1.4e-2", "1.8e-2", "1e-1"];
lambdas = ["1e-4"];
results = struct();
metrics = struct();
for a = 1:numel(reg_methods)
    results.(reg_methods(a)) = cell(1, numel(VOC_id_imgs));
    for b = 1:numel(VOC_id_imgs)
        results.(reg_methods(a)){b} = table('Size', [size(lambdas, 2), 3], 'VariableTypes', ["string", "double", "double"], ...
                                      'VariableNames', ["Lambda", "lCurveErrImg_" + VOC_id_imgs{b}, "lCurveErrReg_" + VOC_id_imgs{b}]);

        metrics.(reg_methods(a)){b} = table('Size', [size(lambdas, 2), 3], 'VariableTypes', ["string", "double", "double"], ...
                                      'VariableNames', ["Lambda", "SSIM" + VOC_id_imgs{b}, "MAE" + VOC_id_imgs{b}]);
    end
end

for i = 1:numel(lambdas)
    for id = 1:numel(VOC_id_imgs)
        params.VOC_id_imgs = VOC_id_imgs(id);
        params_concave.VOC_id_imgs = VOC_id_imgs(id);

        params.lambda_shearlet = str2double(lambdas(i));
        params.lambda_TV = str2double(lambdas(i));

        if any(strcmp(lambdas(i) , ["1"]))
            enable_metrics = true;
        else
            enable_metrics = false;
        end

        % Reconstruction
        [recs, references, lCurveErrImg, lCurveErrReg] = reconstruct_from_VOC_residuals('VOC2012', model_linear, params, reg_methods, true);
        if enable_metrics
            recs_concave = reconstruct_from_VOC_residuals('VOC2012', model_concave, params_concave, reg_methods, true);
        end

        %% Compute residuals
        % Calculate the norm 2 squared
        % squared_norm_of_reference = zeros(1, size(references, 3));
        % for img = 1:size(references, 3)
        %     squared_norm_of_reference(img) = norm(references(:, :, img), 2)^2;
        % end

        recs_names = fieldnames(recs);
        for j = 1:size(recs_names, 1)
            recs_name = recs_names{j};
            % recs_values = getfield(recs, recs_name);
            %
            % for img_rec = 1:size(recs_values, 3)
            %     norm_of_solution = norm(recs_values(:, :, img_rec), 2)^2;
            %     norm_of_estimation_minus_reference(img_rec) = norm(recs_values(:, :, img_rec) - references(:, :, img_rec), 2);
            %
            %     % Calculate the data residual norm
            %     data_residual_norm(img_rec) = (norm_of_estimation_minus_reference(img_rec)^2) / squared_norm_of_reference(img_rec);
            % end
            % results.(recs_name)(i, :) = {lambdas(i), mean(norm_of_solution), mean(data_residual_norm)};
            % lCurveErrImg.(recs_name)
            if enable_metrics
                SSIM_ = ssim(recs.(recs_name), recs_concave.(recs_name));
                MAE_ = calMAE(recs.(recs_name), recs_concave.(recs_name));
            else
                SSIM_ = NaN;
                MAE_ = NaN;
            end
            if recs_name ~= "BACKPROJECTION"
                results.(recs_name){id}(i, :) = {lambdas(i), lCurveErrImg.(recs_name), lCurveErrReg.(recs_name)};
            end
            metrics.(recs_name){id}(i, :) = {lambdas(i), SSIM_, MAE_};
            save residuals.mat results metrics
        end
    end    
end


