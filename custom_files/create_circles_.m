function circlePixels_res = create_circles_(img_size, center_pos, radius, view)

if nargin < 1
    img_size = [256 256];
elseif nargin < 2
    center_pos = [img_size(1)/2 img_size(2)/2];
elseif nargin < 3
    radius = 10;
elseif nargin < 4
    view = false;
end

imageSizeX = img_size(1);
imageSizeY = img_size(2);
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

for i = 1 : size(center_pos)
    centerX = center_pos(i, 1); 
    centerY = center_pos(i, 2); 

    circlePixels(i, :, :) = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2;
end

circlePixels_res = imgaussfilt(squeeze(sum(circlePixels, 1)) * 255, 2);

    if view
        image(circlePixels_res) ;
        %colormap([0 0 0; 1 1 1]);
        axis equal
        xlim([0 imageSizeX])
        ylim([0 imageSizeY])
        %imwrite(circlePixels*255, "circle.jpg")
    end
end

