function [sinograms, file_names] = reconstruct_from_Y_shaped(params, model)
    % Load  sinograms data
    [sinograms, file_names] = dataloader_Y_shaped(params.ForearmComplex_ids, model, params.data_folder);
    % params.HDF5_ids = {};
    % [sinograms, file_names] = dataloader_HDF5_subsampler(params.HDF5_ids, model);

    %save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\Forearm_complex\transverse'; 
    %save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\Forearm_complex\longitudinal'; 
    % save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\Phantom_complex\Phantom_pencil_lead\transverse\test'; 
    % save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\sim_31_25_mat'; 
    % save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\phantom_Y-shaped';
    if isfield(params, 'output_folder') && strlength(string(params.output_folder)) > 0
        save_dir = char(params.output_folder);
    else
        save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\Phantom_Y-shaped_new_morphology';
    end

    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
        disp(['La cartella è stata creata: ', save_dir]);
    end

     % Perform model-based reconstruction
    batch_size = 8;
    for b = 1 : batch_size : size(sinograms, 3)+1
        sinogram_raw = sinograms(:, :, b : (batch_size+b)-1);

        data_precrop = crop_first_n_signals(sinogram_raw,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
        %data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
        data_filt = filter_butter_zero_phase(data_precrop, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
        data_filt = interpolate_signals_of_broken_transducers(data_filt, params.broken_transducers);

        % rec_img_no_reg = reconstruct_model_based(model, sinograms, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        rec_img_L1_shearlet = reconstruct_model_based(model, data_filt, 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_L2 = reconstruct_model_based(model, sinograms, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_TV = reconstruct_model_based(model, sinograms, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_L1_eye = reconstruct_model_based(model, sinograms, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        b
        % Reconstruct with back projection
        K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
        if params.device_probe_id == "TEST_Device_Curved"
            ProbeType = "curved";
        else
            ProbeType = "linear";
        end
        %rec_imgs_bp = reconstruct_bp(model, K, sinograms(:, :, b : (batch_size+b)-1), ProbeType);

        % Save results
        for s = 1 : batch_size
            disp(s)
            filename = file_names{(s + b) - 1};
            % Backprojection
            if exist('rec_imgs_bp','var') == 1
                BP_folder = fullfile(save_dir, "BP");
                check_folder(BP_folder);
                niftiwrite(rec_imgs_bp(:, :, s), fullfile(BP_folder, [filename '_rec_bp.nii']));
            end

            % L1-Shearlet
            if exist('rec_img_L1_shearlet','var') == 1
                % param_shearlet = num2str(params.lambda_shearlet, '%e');
                % param_shearlet = param_shearlet(end-3:end);
                L1_folder = fullfile(save_dir, "L1_Shearlet");
                check_folder(L1_folder);
                niftiwrite(rec_img_L1_shearlet(:, :, s), fullfile(L1_folder, [filename '_rec_L1_shearlet.nii']));
            end

             % TV
            if exist('rec_img_TV','var') == 1
                % param_TV = num2str(params.lambda_TV, '%e');
                % param_TV = param_TV(end-3:end);
                niftiwrite(rec_img_TV(:, :, s), fullfile(save_dir, [filename '_rec_TV.nii']));
            end
        end
        

    end

end
