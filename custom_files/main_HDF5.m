% TO DO: Inserire plot che mostra sensori rispetto a FOV

clc; clear
path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);

%% Define model
params.device_probe_id = 'PoliTo_probe_saturazione_ossigeno_HF';  % see Probe.m for all available probes
params.max_imgs = 1;
params.HDF5_ids = {}; %["2009_004734.jpg" "2007_002216.jpg" "2007_000123.jpg" "2007_001761.jpg" "2007_002953.jpg" "2007_003104.jpg" "2007_003367.jpg" "2007_004510.jpg" "2007_005360.jpg"];
params.use_eir = false;
params.use_indiv_eir = false;
params.use_sir = false;
params.use_single_speed_of_sound = true;
params.num_cropped_samples_at_sinogram_start = 0;
params.filt_cutoff_min = 1e5;
params.filt_cutoff_max = 4*12e6;
params.field_of_view = [-0.01905 0.01905 0 0.02]; %0.04927]; % [x_fov_min x_fov_max z_fov_min z_fov_max]
params.number_of_grid_points_fov = [640 333]; %[640 333]            % [grid_points_x_dimension grid_points_z_dimension]
params.speed_of_sound_tissue = 1500;
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
params.lambda_tikhonov = 1e-4;                           % Strength of Tikhonov regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.lambda_TV = 1e-4;
params.lambda_L1_eye_reg = 1e-4;
params.lambda_laplacian = 0;                             % Strength of L2 Laplacian regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params.num_iterations_mb = 50;

model = define_model_for_reconstruction(params.field_of_view, params.number_of_grid_points_fov, params.device_probe_id, params.use_eir, params.use_indiv_eir, params.use_sir, params.use_single_speed_of_sound, params.speed_of_sound_tissue, params.num_cropped_samples_at_sinogram_start, params.filt_cutoff_min, params.filt_cutoff_max, params.model_normalization_factor);

%% Execute reconstruction
%params.HDF5_id = params.HDF5_ids{i};
reconstruct_from_HDF5(params, model)



% Preprocess the signals
% data_precrop = crop_first_n_signals(data_raw,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
% data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
% data_filt = filter_butter_zero_phase(data_precrop_windowed, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
% data_filt = interpolate_signals_of_broken_transducers(data_filt, broken_transducers);



