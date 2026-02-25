path_to_rec_toolbox = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);

%% Define model
device_probe_id = 'TEST_Device_Curved'; % see Probe.m for all available probes
dataset_name = 'VOC2012'; % [VOC2012, ...]
max_imgs = 250;
use_eir = false;
use_indiv_eir = false;
use_sir = false;
use_single_speed_of_sound = true;
num_cropped_samples_at_sinogram_start = 110;
filt_cutoff_min = 1e5;
filt_cutoff_max = 12e6;
field_of_view = [-0.02 0.02 -0.02 0.02];          % [x_fov_min x_fov_max z_fov_min z_fov_max]
number_of_grid_points_fov = [256 256];            % [grid_points_x_dimension grid_points_z_dimension]
speed_of_sound_tissue = 1465;
model_normalization_factor = [];                  % if empty, the model is normalized so that its largest singular values is 1.
broken_transducers = [];
%%%%%%%% REGULARIZATION Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NN_REC_WITHOUT_REG        -> Non-negative reconstruction without regularization
% L2_TIKHONOV_AND_LAPLACIAN -> Non-negative reconstruction with L2 and L2 Laplace regularization
% L1_SHEARLET               -> Shearlet non-negative limited view reconstruction
% TV_NN_REG                 -> TV non-negative limited view reconstruction
% L1_EYE_REG                -> Non-negative reconstruction with L1 eye reg. matrix
regularization = 'L1_SHEARLET';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda_shearlet = 1e-2; %1e-4                     % Strength of Shearlet L1 regularization, only used if regularization = 'L1_SHEARLET' 
lambda_tikhonov = 5e-3;                           % Strength of Tikhonov regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
lambda_TV = 1e-3;
lambda_L1_eye_reg = 1e-3;
lambda_laplacian = 0;                             % Strength of L2 Laplacian regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
num_iterations_mb = 50;

model = define_model_for_reconstruction(field_of_view, number_of_grid_points_fov, device_probe_id, use_eir, use_indiv_eir, use_sir, use_single_speed_of_sound, speed_of_sound_tissue, num_cropped_samples_at_sinogram_start, filt_cutoff_min, filt_cutoff_max, model_normalization_factor);

%% Execute reconstruction
%% Create test image (initial pressure distribution)
test_img = 0.01*ones(model.Discretization.sizeOfPixelGrid);
test_img(model.Discretization.region.zPositionsFov<0.015) = 0.1;
r = sqrt(model.Discretization.region.xPositionsFov.^2+model.Discretization.region.zPositionsFov.^2);
test_img(r<0.001) = 1;
test_img(10:20,23:30) = 1;

% Comment-in next line to simulate a frame consisting of 28 wavelengths
%test_img = repmat(test_img,1,1,28);

%% Simulate recorded pressure signals for the defined test image with the forward model
tic;
test_sig = model.Funcs.applyForward(test_img);
t_single_forward = toc;
test_sig = test_sig + 0.01 * randn(size(test_sig));
test_sig = reshape(test_sig,model.Probe.detector.numOfTransducers, size(test_img,3)); 

%% Obtain backprojection-like reconstruction with the transpose model
tic;
transp_img = model.Funcs.applyTranspose(test_sig);
t_single_transpose = toc;
transp_img = reshape(transp_img, [], model.Discretization.sizeOfPixelGrid(1), model.Discretization.sizeOfPixelGrid(2), []);
% % Preprocess the signals
% data_precrop = crop_first_n_signals(test_sig,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
% data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
% data_filt = filter_butter_zero_phase(data_precrop_windowed, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
% data_filt = interpolate_signals_of_broken_transducers(data_filt, broken_transducers);

% Reconstruction and save results
save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs';
file_name = 'example_reconstruction';

% Perform model-based reconstruction
rec_img_nn = reconstruct_model_based(model, test_sig, regularization, lambda_shearlet, lambda_tikhonov, lambda_laplacian, lambda_TV, lambda_L1_eye_reg, num_iterations_mb);
figure; imagesc(rec_img_nnReg_TV)

% Save results
niftiwrite(rec_img_nn, fullfile(save_dir, [file_name '.nii']));


