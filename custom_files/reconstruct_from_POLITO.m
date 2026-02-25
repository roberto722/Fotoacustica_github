function reconstruct_from_POLITO(params, model)
    % Load  sinograms data
    [sinograms] = dataloader_POLITO(params.folder, params.mat_filename, model);
    
    exp_name = params.mat_filename;
    %save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\fantocci_PDMS_2025_04_07\' + exp_name;
    save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\fantocci_PDMS_Y_20250422\' + exp_name;


    sinograms = double(sinograms);

    data_precrop = crop_first_n_signals(sinograms,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
    data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
    data_filt = filter_butter_zero_phase(data_precrop_windowed, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
    data_filt = interpolate_signals_of_broken_transducers(data_filt, params.broken_transducers);


    % Perform model-based reconstruction
    %batch_size = 100;
    %for b = 1 : batch_size : size(sinograms, 3) + 1 
        % rec_img_no_reg = reconstruct_model_based(model, sinograms, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % b : (batch_size+b)-1
        rec_img_L1_shearlet = reconstruct_model_based(model, data_filt(:, :, 1), 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_L2 = reconstruct_model_based(model, sinograms, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_TV = reconstruct_model_based(model, sinograms, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_L1_eye = reconstruct_model_based(model, sinograms, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % Reconstruct with back projection
        K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
        if params.device_probe_id == "TEST_Device_Curved"
            ProbeType = "curved";
        else
            ProbeType = "linear";
        end
        rec_imgs_bp = reconstruct_bp(model, K, sinograms(:, :, 1), ProbeType); %b : (batch_size+b)-1)

        % Save results
        for s = 1 %: batch_size
            % Backprojection
            if exist('rec_imgs_bp','var') == 1
                BP_folder = fullfile(save_dir, "BP");
                check_folder(BP_folder);
                niftiwrite(rec_imgs_bp(:, :, s), fullfile(BP_folder, [int2str(s) '_rec_bp.nii']));
            end

            % L1-Shearlet
            if exist('rec_img_L1_shearlet','var') == 1
                % param_shearlet = num2str(params.lambda_shearlet, '%e');
                % param_shearlet = param_shearlet(end-3:end);
                L1_folder = fullfile(save_dir, "L1_Shearlet");
                check_folder(L1_folder);
                niftiwrite(rec_img_L1_shearlet(:, :, s), fullfile(L1_folder, [int2str(s) '_rec_L1_shearlet.nii']));
            end

             % TV
            if exist('rec_img_TV','var') == 1
                % param_TV = num2str(params.lambda_TV, '%e');
                % param_TV = param_TV(end-3:end);
                niftiwrite(rec_img_TV(:, :, s), fullfile(save_dir, [int2str(s) '_rec_TV.nii']));
            end
        end
        

%    end

   
    
    % Plot images
    % f = figure;
    % f.WindowState = 'maximized';
    % subplot(1, 7, 1)
    % imshow(imgs(:, :, 1))
    % title("Initial image")
    % % subplot(1, 7, 2)
    % % imshow(rec_imgs_bp)
    % % title("Rec. with bp")
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
    % exportgraphics(f,'VOC.png','Resolution',300)
    
   
        
        % niftiwrite(imgs(:, :, 1), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_initial_img.nii']));
        
       
        
        % niftiwrite(rec_img_no_reg, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_no_reg.nii']));
        
        
        % param_L2 = num2str(params.lambda_tikhonov, '%e');
        % param_L2 = param_L2(end-3:end);
        % niftiwrite(rec_img_L2, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L2_' param_L2 '.nii']));
        % 
        % param_TV = num2str(params.lambda_TV, '%e');
        % param_TV = param_TV(end-3:end);
        % niftiwrite(rec_img_TV, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_TV_' param_TV '.nii']));
        % 
        % param_EYE = num2str(params.lambda_L1_eye_reg, '%e');
        % param_EYE = param_EYE(end-3:end);
        % niftiwrite(rec_img_L1_eye, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L1_eye_' param_EYE '.nii']));

