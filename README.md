# 6.819-project

This package provides an image colorization implementation using the exact MATLAB "\" solving operator. 

Usage:
Use your favorite image editing program to "scribble" colors on a black and white image.
The function colorizeimg takes in two images, the original black and white image, and the image with user-defined scribbles. 
It then returns the colored image after running the solver.

Eg.
im1 = imread('example.bmp');
im2 = imread('example_marked.bmp');
colorizeimg(im1, im2)

Some example image pairs are included in this package.
