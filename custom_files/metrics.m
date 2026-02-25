clear
folder = "E:\Scardigno\Fotoacustica-MB\outputs\for_abstract\imgs_MB";

listing_res = struct2table(dir(folder + "\**\*Curved*.png"));



for i = 1:size(listing_res, 1)
    name_img = listing_res.name{i};
    
    name_gt = strrep(name_img, "Curved", "Linear");
    %name_gt = strrep(name_img, "concave", "linear");
    initial_img = strcat(folder, filesep, name_gt);
    img_gt = double(imread(initial_img));
    img_gt = img_gt(:, :, 1)/255;

    img_to_evaluate = double(imread(strcat(listing_res.folder{1}, filesep, name_img)))/255;
    img_to_evaluate = imresize(img_to_evaluate(:, :, 1), [256 256]);

     % SSIM
    SSIM{i, 1} = ssim(img_to_evaluate, img_gt);
    SSIM{i, 2} = name_gt;
    SSIM{i, 3} = name_img;
    
    MAE{i, 1} = sum(sum(abs(img_gt - img_to_evaluate)))/(length(img_gt)*length(img_gt));
    MAE{i, 2} = name_gt;
    MAE{i, 3} = name_img;

    % PSNR
    % PSNR{i, 1} = psnr(img_to_evaluate, img_gt);
    % PSNR{i, 2} = name_img;
    % 
    % RMSE
    RMSE{i, 1} = rmse(double(img_to_evaluate), double(img_gt), "all");
    RMSE{i, 2} = name_gt;
    RMSE{i, 3} = name_img;
end