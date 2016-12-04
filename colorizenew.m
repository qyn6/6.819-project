
gray_img ='example.bmp';
colored_img ='example_marked.bmp';
output_img ='example_res.bmp';

ntsc_gray = rgb2ntsc(double(imread(gray_img))/255);
ntsc_colored = rgb2ntsc(double(imread(colored_img))/255);

ntsc_image(:,:,1) = ntsc_gray(:,:,1);
ntsc_image(:,:,2:3) = ntsc_colored(:,:,2:3);

% colorIm=(sum(abs(ntsc_gray-ntsc_colored),3)>0.01);
% colorIm = double(colorIm);
% out = getColorExact(colorIm,ntsc_image);

colored_pixels = ntsc_image(:,:,2);
colored_pixels(colored_pixels~=0) = 1;

out = 1;

[m,n]= size(ntsc_image(:,:,1));

for i=1:m
    for j=1:n
        if (~colored_pixels(i,j))
            for x=i-1:i+1
                for y=j-1:j+1
                    if ~(x<1 || x>m || y>n || y<1 || (x==i && y==j))
                        
                    end
                end
            end
        end
    end
end

figure;
imshow(out);