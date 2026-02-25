function [output_img] = read_img_synthetic(img, model)
    img_gray = 0.2989 * img(:,:,1);
    if(size(img,3)>1)
        img_gray = img_gray + 0.5870 * img(:,:,2) + 0.1140 * img(:,:,3);
    end
    img_gray = imresize(img_gray, model.Discretization.sizeOfPixelGrid, 'bicubic');
    output_img = mat2gray(img_gray);
end

