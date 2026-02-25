function [sinograms] = sinoloader(dataset_type, id_imgs)

if strcmp(dataset_type, 'PRIN_DATI')
    %img_folder = 'E:\Scardigno\Fotoacustica\dataset\PRIN_DATI\Diffusors\lead'; % Path to 'JPEGImages' folder of VOC2012 dataset.
    img_folder = 'E:\Scardigno\Fotoacustica\dataset\PRIN_DATI\Diffusors\lead';
    D_images = dir([img_folder '/*.mat']);
    
    for i = 1 : numel(id_imgs)
        sino_raw = load(fullfile(D_images(i).folder, id_imgs(i))); 
        sino = sino_raw.RcvData{1, 1};
        sinograms(:, :, i) = double(sino(:, :, 90));
    end

else
    disp(['Unknown dataset: ' dataset_type]);
end

end

