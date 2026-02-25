% TO-DO: Use EIR of linear probe

clc; clear
path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);

addpath(genpath('E:\Scardigno\Fotoacustica-MB\data'))
%load PA_pen_55.mat; name = 'PA_pen_55'; % CAMBIARE PROBE IN HALF

% load long_PA_4.mat; name = 'long_PA_4';
% load long_PA_lead.mat; name = 'long_PA_lead';
%load tras_PA_lead.mat; name = 'tras_PA_lead';

save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs';

%% Define model
params.mat_filenames = {"PA_emulsione"}; %{"PA_nodif_sup_emul_50"; "PA_nodif_deep_50"; "PA_nodif_sup"; "PA_nodif_sup_emul_10";};
params.folder = 'E:\Scardigno\Fotoacustica-MB\data\fantocci_PDMS_2025_04_07'; % 20250324_PDMS_agarosio';
params.device_probe_id = 'PoliTo_probe'; % see Probe.m for all available probes
params.use_eir = true;
params.use_indiv_eir = false;
params.use_sir = false;
params.use_single_speed_of_sound = true;
params.num_cropped_samples_at_sinogram_start = 0;
params.filt_cutoff_min = 1e5;
params.filt_cutoff_max = 4.5e6;
params.field_of_view = [-0.01905 0.01905 0 0.038];          % [x_fov_min x_fov_max z_fov_min z_fov_max]
params.number_of_grid_points_fov = [512 512];            % [grid_points_x_dimension grid_points_z_dimension]
params.speed_of_sound_tissue = 1500; %1200; %1524;
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
params.lambda_shearlet = 1e-5; %1e-2 su set_parameters_for_data_generation.m di deepMB  % Strength of Shearlet L1 regularization, only used if regularization = 'L1_SHEARLET' 
params.lambda_tikhonov = 5e-3;                           % Strength of Tikhonov regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.lambda_TV = 1e-3;
params.lambda_L1_eye_reg = 1e-3;
params.lambda_laplacian = 0;                             % Strength of L2 Laplacian regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.num_iterations_mb = 200;

model = define_model_for_reconstruction(params.field_of_view, params.number_of_grid_points_fov, params.device_probe_id, params.use_eir, params.use_indiv_eir, params.use_sir, params.use_single_speed_of_sound, params.speed_of_sound_tissue, params.num_cropped_samples_at_sinogram_start, params.filt_cutoff_min, params.filt_cutoff_max, params.model_normalization_factor);

%% Sinogram pre-processing

%sinogram_raw = double(RcvData{1}(1:model.Probe.DAC.numRecordedSamplesPerTransducer, :, 1));
for i = 1:numel(params.mat_filenames)
    params.mat_filename = params.mat_filenames{i}
    reconstruct_from_POLITO(params, model);
end
% 
% data_precrop = crop_first_n_signals(sinogram_raw,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
% data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
% data_filt = filter_butter_zero_phase(data_precrop_windowed, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
% data_filt = interpolate_signals_of_broken_transducers(data_filt, params.broken_transducers);
% 
% 
% %% Reconstruction
% % Perform back-projection reconstruction
% K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
% if params.device_probe_id == "TEST_Device_Curved"
%     ProbeType = "curved";
% else
%     ProbeType = "linear";
% end
% rec_imgs_bp = reconstruct_bp(model, K, data_filt, ProbeType);


% Perform model-based reconstruction
% f_tic = tic;
% rec_img_no_reg = reconstruct_model_based(model, data_filt, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
% rec_img_L1_shearlet = reconstruct_model_based(model, data_filt, 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
% rec_img_L2 = reconstruct_model_based(model, data_filt, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
% rec_img_TV = reconstruct_model_based(model, data_filt, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
% rec_img_L1_eye = reconstruct_model_based(model, data_filt, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
% toc(f_tic)


% Save results
%niftiwrite(rec_imgs_bp, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_imgs_bp.nii']));

% niftiwrite(rec_img_no_reg, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_img_no_reg.nii']));
% 
% param_shearlet = num2str(params.lambda_shearlet, '%e');
% param_shearlet = param_shearlet(end-3:end);
% niftiwrite(rec_img_L1_shearlet, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_img_L1_shearlet_' param_shearlet '.nii']));
% 
% param_L2 = num2str(params.lambda_tikhonov, '%e');
% param_L2 = param_L2(end-3:end);
% niftiwrite(rec_img_L2, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_img_L2_' param_L2 '.nii']));
% 
% param_TV = num2str(params.lambda_TV, '%e');
% param_TV = param_TV(end-3:end);
% niftiwrite(rec_img_TV, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_img_TV_' param_TV '.nii']));
% 
% param_EYE = num2str(params.lambda_L1_eye_reg, '%e');
% param_EYE = param_EYE(end-3:end);
% niftiwrite(rec_img_L1_eye, fullfile(save_dir, [params.device_probe_id '_' name '_invitro_rec_img_L1_eye_' param_EYE '.nii']));
% 


% f = figure;
% f.WindowState = 'maximized';
% subplot(1, 5, 1)
% imshow(rec_img_no_reg(:, :, 1))
% title("NN Rec. without reg.")
% subplot(1, 5, 2)
% imshow(rec_img_L1_shearlet(:, :, 1))
% title("Shearlet NN Rec.")
% subplot(1, 5, 3)
% imshow(rec_img_L2(:, :, 1))
% title("Rec. with L2 reg.")
% subplot(1, 5, 4)
% imshow(rec_img_TV(:, :, 1))
% title("Rec. with TV reg.")
% subplot(1, 5, 5)
% imshow(rec_img_L1_eye(:, :, 1))
% title("NN Rec. with L1 eye reg.")
