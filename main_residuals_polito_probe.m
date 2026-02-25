% TO DO: Inserire plot che mostra sensori rispetto a FOV

clear
path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);

%% Define model
params.device_probe_id = 'PoliTo_probe'; %'PoliTo_probe'; % see Probe.m for all available probes
params.max_imgs = 1;
params.PRIN_imgs_id = ["lead_diffusors_GT"]; %PAtestKMM2
params.use_eir = true;
params.use_indiv_eir = false;
params.use_sir = false;
params.use_single_speed_of_sound = true;
params.num_cropped_samples_at_sinogram_start = 0;
params.filt_cutoff_min = 3e6;
params.filt_cutoff_max = 14e6;
params.field_of_view = [-0.01905 0.01905 0 0.038]; %[-0.013 0.013 0 0.026]; %[-0.01905 0.01905 -0.0192 0.0192]; % [x_fov_min x_fov_max z_fov_min z_fov_max]
params.number_of_grid_points_fov = [256 256]; %[87 87];  % [grid_points_x_dimension grid_points_z_dimension] (DOVREBBE ESSERE Z:90)
params.speed_of_sound_tissue = 1540;
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

model = define_model_for_reconstruction(params.field_of_view, params.number_of_grid_points_fov, params.device_probe_id, params.use_eir, params.use_indiv_eir, params.use_sir, params.use_single_speed_of_sound, params.speed_of_sound_tissue, params.num_cropped_samples_at_sinogram_start, params.filt_cutoff_min, params.filt_cutoff_max, params.model_normalization_factor);

%% Execute reconstruction and calculate residuals
reg_methods = ["L1_SHEARLET"];
lambdas = ["1e-8", "1e-7", "1e-6", "1e-5", "1e-4", "1e-3", "1e-2", "1e-1", "1"];


results = struct();
for a = 1:numel(reg_methods)
    results.(reg_methods(a)) = cell(1, numel(params.PRIN_imgs_id));
    for b = 1:numel(params.PRIN_imgs_id)
        results.(reg_methods(a)){b} = table('Size', [size(lambdas, 2), 3], 'VariableTypes', ["string", "double", "double"], ...
                                      'VariableNames', ["Lambda", "lCurveErrImg_" + params.PRIN_imgs_id{b}, "lCurveErrReg_" + params.PRIN_imgs_id{b}]);
    end
end

for i = 1:numel(lambdas)
    for id = 1:numel(params.PRIN_imgs_id)
        params.lambda_shearlet = str2double(lambdas(i));
        params.lambda_TV = str2double(lambdas(i));
    
        % Reconstruction
        [recs, ~, lCurveErrImg, lCurveErrReg] = reconstruct_from_VOC_residuals('PRIN_TRUE_L-CURVE', model, params, reg_methods, true);
    
        %% Compute residuals
        recs_names = fieldnames(recs);
        for j = 1:size(recs_names, 1)
            recs_name = recs_names{j};
            if recs_name ~= "BACKPROJECTION"
                results.(recs_name){id}(i, :) = {lambdas(i), lCurveErrImg.(recs_name), lCurveErrReg.(recs_name)};
            end
        end
        save(sprintf("residuals_%s.mat", params.PRIN_imgs_id(id)), 'results')
    end
end


