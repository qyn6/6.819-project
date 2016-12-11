%Input is two RBG images: one in greyscale (grey_img), the other the same greyscale image with color scribbles added.
function result_image = colorizeimg(gray_img,colored_img)

%transform the images from RGB colorspace to YUV colorspace
ntsc_gray = rgb2ntsc(double(gray_img)/255);         
ntsc_colored = rgb2ntsc(double(colored_img)/255);

ntsc_image(:,:,1) = ntsc_gray(:,:,1);
ntsc_image(:,:,2:3) = ntsc_colored(:,:,2:3);

% colored_pixels are pixels that have color scribbles
colored_pixels = ntsc_image(:,:,2);
colored_pixels(colored_pixels~=0) = 1;

%initializing data structure to store relative neighbor intensity data for each pixel 
[m,n]= size(ntsc_image(:,:,1));
columns = zeros(m*n*9, 1); %8 neighbors + thing itself
rows = zeros(m*n*9, 1);
current_index = 0; %the number of the current iteration
pixel_vals = zeros(m*n*9, 1); 

%iterating through all pixels to obtain neighbor data
for j=1:n
    for i=1:m
        temp_vals = [];
        current_pixel_num = (j-1)*m + i;
        if (~colored_pixels(i,j))
           
            for x=i-1:i+1
                for y=j-1:j+1
                    if ~(x<1 || x>m || y>n || y<1 || (x==i && y==j))  %valid neighbors of current pixel
                        current_index = current_index + 1;
                        rows(current_index) = current_pixel_num;
                        columns(current_index) = m*(y-1) + x;
                        temp_vals = [temp_vals ntsc_image(x, y, 1)];
                    end
                end
            end
            current_pixel_intensity = ntsc_image(i,j,1);
            temp_vals =[temp_vals current_pixel_intensity];
            num_neighbors = size(temp_vals,2)-1;
            variance = var(temp_vals);
            if (variance<0.0001) %thresholding
                variance=0.0001;
            end
            
            %weighting function
            temp_vals(1:num_neighbors)=1+(temp_vals(1:num_neighbors)-mean(current_pixel_intensity))*(current_pixel_intensity-mean(current_pixel_intensity))/variance;
            %normalization
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

%creating a sparse matrix of pixels with valid neighbor weights to solve colorization optimization
A = sparse(rows(1:current_index), columns(1:current_index), pixel_vals(1:current_index), current_pixel_num, m*n);
b = zeros(size(A,1), 1);
colored_pixel_indices = find(colored_pixels);
result_image = ntsc_image(:,:,1);

%performing colorization on UV channels of YUV image
for r=2:3
    channel = ntsc_image(:,:,r);
    b(colored_pixel_indices) = channel(colored_pixel_indices);
    res = A\b;
    result_image(:,:,r) = reshape(res,m,n,1);
end

result_image = ntsc2rgb(result_image);
figure;
imshow(result_image);