function [rec_img] = reconstruct_model_based(model, sinogram, regularization, lambda_shearlet, lambda_tikhonov, lambda_laplacian, lambda_TV, lambda_L1_eye_reg, num_iterations_mb)

% Shearlet non-negative limited view reconstruction
if strcmp(regularization, 'L1_SHEARLET')
    rec_img = rec_nn_with_Shearlet_reg(model, sinogram, num_iterations_mb, lambda_shearlet);

% Non-negative reconstruction with L1 eye reg. matrix
elseif strcmp(regularization, 'L1_EYE_REG')
    rec_img = rec_nn_with_L1_eye_reg(model, sinogram, num_iterations_mb, lambda_L1_eye_reg);

% Non-negative reconstruction without regularization
elseif strcmp(regularization, 'NN_REC_WITHOUT_REG')
    rec_img = rec_nn_with_L2_reg(model, sinogram, num_iterations_mb, 0, [], [], 0, [], []);

% Non-negative reconstruction with L2 and L2 Laplace regularization
elseif strcmp(regularization, 'L2_TIKHONOV_AND_LAPLACIAN')
    RegL2 = @(x) x;
    RegL2T = @(x) x;
    RegL2_lap = @(x) laplacian_per_wavelength(reshape(x, model.Discretization.sizeOfPixelGrid(2), model.Discretization.sizeOfPixelGrid(1), []));
    RegL2T_lap = @(x) laplacian_per_wavelength(reshape(x, model.Discretization.sizeOfPixelGrid(2), model.Discretization.sizeOfPixelGrid(1), []));

    rec_img = rec_nn_with_L2_reg(model, sinogram, num_iterations_mb, lambda_tikhonov, RegL2, RegL2T, lambda_laplacian, RegL2_lap, RegL2T_lap);

% TV non-negative limited view reconstruction
elseif strcmp(regularization, 'TV_NN_REG')
    rec_img = rec_nn_with_TV_reg(model, sinogram, num_iterations_mb, lambda_TV);

else
    disp(['Unknown regularization: ' regularization]);
end

%rec_img = fliplr(rec_img); %RS
end
