function [I, IOrig, sigma, interpValue] = prepareImage(path, resizeFactor)
%start sigma value    
sigma = 1.6;

IOrig = imread(path);
IOrig = im2double(IOrig);
if size(IOrig, 3) == 3
    IOrig = rgb2gray(IOrig);
end

if resizeFactor ~= 1
  IOrig = imresize(IOrig, resizeFactor);  
end
%paper assumes each image has sigma=0.5 to start
%double size so that sigma = 1
I = imresize(IOrig, 2, 'bilinear');
interpValue = 2;
 
I = imgaussfilt(I, sigma);
end

