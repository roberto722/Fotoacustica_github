function reconstruct_from_GRID(model, params, center_pos, radius)
    % Create grid
    grid_img = create_circles_([256 256], center_pos, radius, false);
    grid_img = mat2gray(grid_img);

    % Apply forward model and save the resulting sinogram
    sinogram = model.Funcs.applyForward(grid_img);
    sinogram = reshape(sinogram, [], model.Probe.detector.numOfTransducers, size(grid_img,3));

    save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs';
    
    % Reconstruct with back projection
    % K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
    % if params.device_probe_id == "TEST_Device_Curved"
    %     ProbeType = "curved";
    % else
    %     ProbeType = "linear";
    % end
    % rec_imgs_bp = reconstruct_bp(model, K, sinogram, ProbeType);

    % Perform model-based reconstruction
    % rec_img_no_reg = reconstruct_model_based(model, sinogram, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    %rec_img_L1_shearlet = reconstruct_model_based(model, sinogram, 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    % rec_img_L2 = reconstruct_model_based(model, sinogram, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    rec_img_TV = reconstruct_model_based(model, sinogram, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    % rec_img_L1_eye = reconstruct_model_based(model, sinogram, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    % 
    
    % Plot images
    % f = figure;
    % f.WindowState = 'maximized';
    % subplot(1, 7, 1)
    % imshow(grid_img)
    % title("Initial image")
    % subplot(1, 7, 2)
    % imshow(rec_imgs_bp)
    % title("Rec. with bp")
    % subplot(1, 7, 3)
    % imshow(rec_img_no_reg(:, :, 1))
    % title("NN Rec. without reg.")
    % subplot(1, 7, 4)
    % imshow(rec_img_L1_shearlet(:, :, 1))
    % title("Shearlet NN Rec.")
    % subplot(1, 7, 5)
    % imshow(rec_img_L2(:, :, 1))
    % title("Rec. with L2 reg.")
    % subplot(1, 7, 6)
    % imshow(rec_img_TV(:, :, 1))
    % title("Rec. with TV reg.")
    % subplot(1, 7, 7)
    % imshow(rec_img_L1_eye(:, :, 1))
    % title("NN Rec. with L1 eye reg.")
    % exportgraphics(f,'GRID.png','Resolution',1200)
    
    % Save results
    % niftiwrite(grid_img, fullfile(save_dir, [params.device_probe_id '_NO_EIR_GRID_initial_img.nii']));
    
    % niftiwrite(rec_imgs_bp.*10, fullfile(save_dir, [params.device_probe_id '_EIR_GRID_rec_imgs_bp.nii']));
    
    % niftiwrite(rec_img_no_reg, fullfile(save_dir, [params.device_probe_id '_NO_EIR_GRID_rec_img_no_reg.nii']));
    
    % param_shearlet = num2str(params.lambda_shearlet, '%e');
    % param_shearlet = [param_shearlet(1:3), param_shearlet(end-3:end)];
    % niftiwrite(rec_img_L1_shearlet, fullfile(save_dir, [params.device_probe_id '_GRID_rec_img_L1_shearlet_' param_shearlet '.nii']));

    % param_L2 = num2str(params.lambda_tikhonov, '%e');
    % param_L2 = param_L2(end-3:end);
    % niftiwrite(rec_img_L2, fullfile(save_dir, [params.device_probe_id '_EIR_GRID_rec_img_L2_' param_L2 '.nii']));
    % 
    param_TV = num2str(params.lambda_TV, '%e');
    param_TV = [param_TV(1:3), param_TV(end-3:end)];
    niftiwrite(rec_img_TV, fullfile(save_dir, [params.device_probe_id '_GRID_rec_img_TV_' param_TV '.nii']));
    % 
    % param_EYE = num2str(params.lambda_L1_eye_reg, '%e');
    % param_EYE = param_EYE(end-3:end);
    % niftiwrite(rec_img_L1_eye, fullfile(save_dir, [params.device_probe_id '_EIR_GRID_rec_img_L1_eye_' param_EYE '.nii']));

    disp("GRID image successfully reconstructed.")
end

