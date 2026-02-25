function [sinograms, imgs, img_names] = dataloader(dataset_type, model, id_imgs, max_imgs)

if nargin < 2
    model = 0;
elseif nargin < 3
    id_imgs = ["2009_004734.jpg"];
    max_imgs = inf;
end

if strcmp(dataset_type, 'VOC2012')
    image_folder = 'E:\Scardigno\Fotoacustica-MB\data\JPEGImages'; % Path to 'JPEGImages' folder of VOC2012 dataset.
    D_images = dir([image_folder '/*.jpg']);

    if isempty(id_imgs)
        id_imgs = {D_images.name};
        id_imgs = id_imgs(1:max_imgs);
    end
    
    if isa(id_imgs, 'cell')
        for i = 1 : numel(id_imgs)
            img_name = id_imgs{i};
            img = double(imread(fullfile(D_images(i).folder, img_name))); 
            imgs(:, :, i) = read_img_synthetic(img, model);
        end
        img_names = id_imgs;
    elseif isa(id_imgs, 'double')
        for i = 1:id_imgs
            img_name = D_images(i).name;
            img = double(imread(fullfile(D_images(i).folder, img_name))); 
            imgs(:, :, i) = read_img_synthetic(img, model);
        end
        img_names = {D_images(1:id_imgs).name};
        fprintf("Successfully loaded %i images", id_imgs)
    end
    % img = double(imread(fullfile(D_images(1).folder, id_img))); 
    % img_gray = 0.2989 * img(:,:,1);
    % if(size(img,3)>1)
    %     img_gray = img_gray + 0.5870 * img(:,:,2) + 0.1140 * img(:,:,3);
    % end
    % img_gray = imresize(img_gray, model.Discretization.sizeOfPixelGrid, 'bicubic');
    % imgs(:, :) = mat2gray(img_gray);

    % Apply forward model and save the resulting sinogram
    sinograms = model.Funcs.applyForward(imgs);
    sinograms = reshape(sinograms, [], model.Probe.detector.numOfTransducers, size(imgs,3));

elseif strcmp(dataset_type, 'PRIN_TRUE_L-CURVE')
    image_folder = 'E:\Scardigno\Fotoacustica-MB\dataset'; 
    D_images = dir([image_folder '/*.png']);
    for i = 1 : numel(id_imgs)
        img_name = id_imgs{i};
        img = double(imread(fullfile(D_images(i).folder, [img_name '.png'])));
        imgs(:, :, i) = read_img_synthetic(img, model);
    end
    img_names = {D_images(1:numel(id_imgs)).name};

    sinograms = model.Funcs.applyForward(imgs);
    sinograms = reshape(sinograms, [], model.Probe.detector.numOfTransducers, size(imgs,3));
else
    disp(['Unknown dataset: ' dataset_type]);
end

end

