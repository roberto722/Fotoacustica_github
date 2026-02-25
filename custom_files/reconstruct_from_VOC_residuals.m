function [recs, imgs, lCurveErrImgs, lCurveErrRegs] = reconstruct_from_VOC_residuals(dataset_name, model, params, reg_methods, save)
    
    if nargin < 5
        save = false;
    end
    
    % Load  sinograms data
    if strcmp(dataset_name, "PRIN_DATI")
        sinograms_raw = sinoloader(dataset_name, params.SINO_id_imgs);
        disp("Sinogrammi di PRIN_DATI caricati con successo!")
        save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\PoliTo_probe_PRIN_DATI';
        imgs = "";
    elseif strcmp(dataset_name, "VOC2012")
        [sinograms_raw, imgs, img_names] = dataloader(dataset_name, model, params.VOC_id_imgs);
        save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\L_CURVE_TEST_Device_Linear_MULTI-CURVE_HF';
    elseif strcmp(dataset_name, "PRIN_TRUE_L-CURVE")
        [sinograms_raw, imgs, img_names] = dataloader(dataset_name, model, params.PRIN_imgs_id);
        save_dir = 'E:\Scardigno\Fotoacustica-MB\outputs\PRIN_TRUE_L-CURVE';
    end
    
    if ~exist(save_dir, 'dir')
       mkdir(save_dir)
    end
    
    if exist('img_names', 'var')
        writecell(img_names', fullfile(save_dir, 'img_names.xls'), 'WriteMode', 'overwritesheet', 'Sheet', 1)
    end

    % PRE-PROCESSING
    data_precrop = crop_first_n_signals(sinograms_raw,  model.DataPreprocessing.numCroppedSamplesAtSinogramStart);
    data_precrop_windowed = apply_butterworth_window_to_sinogram(data_precrop, 2, 300, size(data_precrop,1)-200);
    data_filt = filter_butter_zero_phase(data_precrop_windowed, model.Probe.DAC.frequency, [model.DataPreprocessing.filtCutoffMin, model.DataPreprocessing.filtCutoffMax],true);
    %data_filt = interpolate_signals_of_broken_transducers(data_filt, params.broken_transducers);
        
    % Perform model-based reconstruction

    if any(strcmp(reg_methods, 'NN_REC_WITHOUT_REG'))
        [rec_img_no_reg, lCurveErrImg_no_reg, lCurveErrReg_no_reg] = reconstruct_model_based_residuals(model, data_filt, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    end
    if any(strcmp(reg_methods, 'L1_SHEARLET'))
        [rec_img_L1_shearlet, lCurveErrImg_L1_shearlet, lCurveErrReg_L1_shearlet] = reconstruct_model_based_residuals(model, data_filt, 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    end
    if any(strcmp(reg_methods, 'L2_TIKHONOV_AND_LAPLACIAN'))
        [rec_img_L2, lCurveErrImg_L2, lCurveErrReg_L2] = reconstruct_model_based_residuals(model, data_filt, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    end
    if any(strcmp(reg_methods, 'TV_NN_REG'))
        [rec_img_TV, lCurveErrImg_TV, lCurveErrReg_TV] = reconstruct_model_based_residuals(model, data_filt, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    end
    if any(strcmp(reg_methods, 'L1_EYE_REG'))
        [rec_img_L1_eye, lCurveErrImg_L1_eye, lCurveErrReg_L1_eye] = reconstruct_model_based_residuals(model, data_filt, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    end
    if any(strcmp(reg_methods, 'BACKPROJECTION'))
        % Reconstruct with back projection
        K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
        if params.device_probe_id == "TEST_Device_Curved"
            ProbeType = "curved";
        else
            ProbeType = "linear";
        end
        rec_imgs_bp = reconstruct_bp(model, K, data_filt, ProbeType);
    end

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
    
    % Save results
    if save
        if isfield(params, 'VOC_id_imgs')
            id = char(params.VOC_id_imgs{1});
            dataset_name = [dataset_name '_' id(1:end-4)];

            % Initial images
            % niftiwrite(imgs, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_initial_img.nii']));

        elseif isfield(params, 'SINO_id_imgs')
            id = char(params.SINO_id_imgs);
            dataset_name = [dataset_name '_' id];
        end
        
        
        if exist('rec_imgs_bp','var')
            niftiwrite(rec_imgs_bp, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_imgs_bp.nii']));
            recs.bp = rec_imgs_bp;
        end
        if exist('rec_img_no_reg','var')
            rec_img_no_reg_blur = imgaussfilt(rec_img_no_reg, 1);
            niftiwrite(cat(3, rec_img_no_reg, rec_img_no_reg_blur), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_no_reg.nii']));
            recs.no_reg = rec_img_no_reg;
        end
        if exist('rec_img_L1_shearlet','var')
            param_shearlet = num2str(params.lambda_shearlet, '%e');
            param_shearlet = [param_shearlet(1:3), param_shearlet(end-3:end)];
            rec_img_L1_shearlet_blur = imgaussfilt(rec_img_L1_shearlet, 1);
            niftiwrite(cat(3, rec_img_L1_shearlet, rec_img_L1_shearlet_blur), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L1_shearlet_' param_shearlet '.nii']));
        end
        if exist('rec_img_L2','var')
            param_L2 = num2str(params.lambda_tikhonov, '%e');
            param_L2 = [param_L2(1:3), param_L2(end-3:end)];
            niftiwrite(rec_img_L2, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L2_' param_L2 '.nii']));
        end
        if exist('rec_img_TV','var')
            param_TV = num2str(params.lambda_TV, '%e');
            param_TV = [param_TV(1:3), param_TV(end-3:end)];
            rec_img_TV_blur = imgaussfilt(rec_img_TV, 0.5);
            rec_img_TV_blur_2 = imgaussfilt(rec_img_TV, 1);
            niftiwrite(cat(3, rec_img_TV, rec_img_TV_blur, rec_img_TV_blur_2), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_TV_' param_TV '.nii']));
            recs.TV = rec_img_TV;
        end
        if exist('rec_img_L1_eye','var')
            param_EYE = num2str(params.lambda_L1_eye_reg, '%e');
            param_EYE = [param_EYE(1:3), param_EYE(end-3:end)];
            niftiwrite(rec_img_L1_eye, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L1_eye_' param_EYE '.nii']));
        end
    end

    % Set results in a struct
    recs = struct();
    lCurveErrImgs = struct();
    lCurveErrRegs = struct();
    if exist('rec_imgs_bp','var')
        recs.BACKPROJECTION = rec_imgs_bp;
    end
    if exist('rec_img_no_reg','var')
        recs.NN_REC_WITHOUT_REG = rec_img_no_reg;
        lCurveErrImgs.NN_REC_WITHOUT_REG = lCurveErrImg_no_reg;
        lCurveErrRegs.NN_REC_WITHOUT_REG = lCurveErrReg_no_reg;
    end
    if exist('rec_img_L1_shearlet','var')
        recs.L1_SHEARLET = rec_img_L1_shearlet;
        lCurveErrImgs.L1_SHEARLET = lCurveErrImg_L1_shearlet;
        lCurveErrRegs.L1_SHEARLET = lCurveErrReg_L1_shearlet;
    end
    if exist('rec_img_L2','var')
        recs.L2_TIKHONOV_AND_LAPLACIAN = rec_img_L2;
        lCurveErrImgs.L2_TIKHONOV_AND_LAPLACIAN = lCurveErrImg_L2;
        lCurveErrRegs.L2_TIKHONOV_AND_LAPLACIAN = lCurveErrReg_L2;
    end
    if exist('rec_img_TV','var')
        recs.TV_NN_REG = rec_img_TV;
        lCurveErrImgs.TV_NN_REG = lCurveErrImg_TV;
        lCurveErrRegs.TV_NN_REG = lCurveErrReg_TV;
    end
    if exist('rec_img_L1_eye','var')
        recs.L1_EYE_REG = rec_img_L1_eye;
        lCurveErrImgs.L1_EYE_REG = lCurveErrImg_L1_eye;
        lCurveErrRegs.L1_EYE_REG = lCurveErrReg_L1_eye;
    end

    disp("Images from VOC dataset successfully reconstructed and saved.")
end

