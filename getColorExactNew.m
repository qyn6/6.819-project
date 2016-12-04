function out = getColorExactNew(ntsc_image)
%find pixel positions where scribbles are
colored_pixels = find(ntsc_image(:,:,2));

out = 1;

[n,m,x]= size(ntsc_image);