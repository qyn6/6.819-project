
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

% pixels that are scribbled on
colored_pixels = ntsc_image(:,:,2);
colored_pixels(colored_pixels~=0) = 1;

out = 1;

[m,n]= size(ntsc_image(:,:,1));
columns = zeros(m*n*9, 1); %8 neighbors + thing itself
rows = zeros(m*n*9, 1);
count_index = 0;
current_index = 0;
pixel_vals = zeros(m*n*9, 1);
temp_vals = [];

for j=1:n
    for i=1:m
        current_pixel_num = (j-1) *m + i;
        if (~colored_pixels(i,j))
            %find neighbors
            for x=i-1:i+1
                for y=j-1:j+1
                    if ~(x<1 || x>m || y>n || y<1 || (x==i && y==j))
                        current_index = current_index + 1;
                        rows(current_index) = current_pixel_num;
                        columns(current_index) = m*(y-1) + x;
                        temp_vals = [temp_vals ntsc_image(x, y, 1)];
                    end
                end
            end
            current_pixel_intensity = ntsc_image(i,j,1);
            temp_vals =[temp_vals current_pixel_intensity];
            num_neighbors = size(temp_vals);
            variance = var(temp_vals);
            sigma = variance^(.5);   
  
            temp_vals = exp(-(temp_vals - current_pixel_intensity).^2/(2*variance));
            %normalize
            temp_vals(1:num_neighbors) = temp_vals(1:num_neighbors)/sum(temp_vals(1:num_neighbors));
            pixel_vals(current_index-num_neighbors+1:current_index) = -temp_vals(1:num_neighbors); 
            
            %A = D-W, W = pixel_vals, D = Identity matrix    
        end

        current_index = current_index + 1;
        rows(current_index) = current_pixel_num;
        columns(current_index) = m * (j - 1) + i;
        pixel_vals(current_index) = 1;
    end
end

A = sparse(rows(1:current_index), columns(1:current_index), pixel_vals(1:current_index), m*n, m*n);
b = zeros(size(A,1), 1);
colored_pixel_indices = find(colored_pixels);
result_image = ntsc_image(:,:,1);

for i=2:3
    channel = ntsc_image(:,:,i);
    b(colored_pixel_indices) = channel(colored_pixel_indices);
    x = A\b;
    result_image(:,:,i) = reshape(x,m,n,1);
end
result_image = ntsc2rgb(result_image);
figure;
imshow(result_image);