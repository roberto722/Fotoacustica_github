function [params_concave] = load_params_concave(params_linear)
params_concave = params_linear;
%% Concave standard params
params_concave.device_probe_id = 'PoliTo_probe_curved_fake';
params_concave.lambda_shearlet = 1e-4; %1e-2 su set_parameters_for_data_generation.m di deepMB  % Strength of Shearlet L1 regularization, only used if regularization = 'L1_SHEARLET' 
params_concave.lambda_tikhonov = 1e-4;                           % Strength of Tikhonov regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
params_concave.lambda_TV = 1e-3;
params_concave.lambda_L1_eye_reg = 1e-4;
params_concave.lambda_laplacian = 0;                             % Strength of L2 Laplacian regularization, only used if regularization = 'L2_TIKHONOV_AND_LAPLACIAN' 
end

