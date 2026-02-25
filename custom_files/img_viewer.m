img = im2gray(imread("E:\Scardigno\Fotoacustica-MB\outputs\fantocci_PDMS_2025_04_07\PA_emulsione\L1_Shearlet\emulsione_512.png"));
blurred = imgaussfilt(img, 2)';
imshow(blurred);
cmap = colormap('hot');

imwrite(blurred, cmap, "emulsione_512_optimized.png")