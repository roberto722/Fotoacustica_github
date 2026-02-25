function reconstruct_from_VOC(dataset_name, model, params)
    % Load  sinograms data
    [sinograms, imgs, imgs_name] = dataloader(dataset_name, model, params.VOC_id_imgs, params.max_imgs, params.data_folder);

    if isfield(params, 'output_folder') && strlength(string(params.output_folder)) > 0
        save_dir = char(params.output_folder);
    else
        %save_dir = 'E:\Scardigno\Fotoacustica-MB\dataset\linear_low_freq';
        save_dir = 'E:\Scardigno\Fotoacustica-MB\dataset\VOC_forearm_2000_test';
    end
    sinogram_dir = save_dir + "/sinograms";
    bp_dir = save_dir + "/BP";
    rec_dir = save_dir + "/recs";
    if ~exist(sinogram_dir, 'dir'); mkdir(sinogram_dir); end
    if ~exist(bp_dir, 'dir'); mkdir(bp_dir); end
    if ~exist(rec_dir, 'dir'); mkdir(rec_dir); end

    N = size(sinograms, 3);
    if ~isfield(params, 'mb_batch') || isempty(params.mb_batch)
        params.mb_batch = 1;          % batch size di default
    end
    B = params.mb_batch;

    % Prepara gli ID (senza estensione) una volta sola
    ids_noext = cellfun(@(s) char(s(1:end-4)), imgs_name, 'UniformOutput', false);

    for startIdx = 1:B:N
        idx = startIdx : min(startIdx + B - 1, N);
        bsz = numel(idx);
        
        % Estrai batch
        sino_b = sinograms(:, :, idx);

         % Reconstruct with back projection
        K = load_or_calculate_kernel_for_backprojection_rec(params.device_probe_id);
        if params.device_probe_id == "TEST_Device_Curved"
            ProbeType = "curved";
        else
            ProbeType = "linear";
        end
        
        tic
        rec_imgs_bp = reconstruct_bp(model, K, sino_b, ProbeType);
        disp("Tempo per backprojection")
        t = toc;
        
        % Perform model-based reconstruction
        % rec_img_no_reg = reconstruct_model_based(model, sino_b, 'NN_REC_WITHOUT_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % tic
        % rec_img_L1_shearlet = reconstruct_model_based(model, sino_b, 'L1_SHEARLET', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % disp("Tempo per L1 Shearlet")
        % toc
        % rec_img_L2 = reconstruct_model_based(model, sino_b, 'L2_TIKHONOV_AND_LAPLACIAN', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_TV = reconstruct_model_based(model, sino_b, 'TV_NN_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
        % rec_img_L1_eye = reconstruct_model_based(model, sino_b, 'L1_EYE_REG', params.lambda_shearlet, params.lambda_tikhonov, params.lambda_laplacian, params.lambda_TV, params.lambda_L1_eye_reg, params.num_iterations_mb);
    
       
        
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
        device_probe_id = char(params.device_probe_id);
        dataset_name_char = char(dataset_name);

        parfor k = 1:bsz
            name_noext = ids_noext{idx(k)};
            sinogram_filename = sprintf('%s_%s_%s_sinogram.nii', device_probe_id, dataset_name_char, name_noext);
            niftiwrite(sino_b(:, :, k), fullfile(char(sinogram_dir), sinogram_filename));

            bp_filename = sprintf('%s_%s_%s_rec_imgs_bp.nii', device_probe_id, dataset_name_char, name_noext);
            niftiwrite(rec_imgs_bp, fullfile(char(bp_dir), bp_filename));
            % param_shearlet = num2str(params.lambda_shearlet, '%e');
            % param_shearlet = param_shearlet(end-3:end);
            % niftiwrite(rec_img_L1_shearlet(:, :, k), fullfile(rec_dir, [params.device_probe_id '_' dataset_name '_' name_noext '_rec_img_L1_shearlet_' param_shearlet '.nii']));
        end
    end
    
    
   

    % for i = 1:size(sinograms, 3)
    %     id = char(params.VOC_id_imgs{i});
    % 
    %      niftiwrite(sinograms(:, :, i), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_' id(1:end-4) '_sinogram.nii']));
    % 
    % 
    %     % niftiwrite(imgs(:, :, 1), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_initial_img.nii']));
    % 
    %     % niftiwrite(rec_imgs_bp, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_imgs_bp.nii']));
    % 
    %     % niftiwrite(rec_img_no_reg, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_no_reg.nii']));
    % 
    %     param_shearlet = num2str(params.lambda_shearlet, '%e');
    %     param_shearlet = param_shearlet(end-3:end);
    %     niftiwrite(rec_img_L1_shearlet(:, :, i), fullfile(save_dir, [params.device_probe_id '_' dataset_name '_' id(1:end-4) '_rec_img_L1_shearlet_' param_shearlet '.nii']));
    % 
    %     % param_L2 = num2str(params.lambda_tikhonov, '%e');
    %     % param_L2 = param_L2(end-3:end);
    %     % niftiwrite(rec_img_L2, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L2_' param_L2 '.nii']));
    %     % 
    %     % param_TV = num2str(params.lambda_TV, '%e');
    %     % param_TV = param_TV(end-3:end);
    %     % niftiwrite(rec_img_TV, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_TV_' param_TV '.nii']));
    %     % 
    %     % param_EYE = num2str(params.lambda_L1_eye_reg, '%e');
    %     % param_EYE = param_EYE(end-3:end);
    %     % niftiwrite(rec_img_L1_eye, fullfile(save_dir, [params.device_probe_id '_' dataset_name '_rec_img_L1_eye_' param_EYE '.nii']));
    % end
    disp("Images from VOC dataset successfully reconstructed.")
end
