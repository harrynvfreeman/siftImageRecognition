function [siftDetails, nextImage, nextScale] = processOctave(I,sigma)
fprintf('       Applying Gaussian Filters \n');
[gaussian, scales] = multgaussianfilter(I, sigma);
fprintf('       Calculating difference of gaussians \n');
[dog, dogScales] = diffOfGaussians(gaussian, scales);
fprintf('       Finding extremas \n');
[extremas, ~] = findExtremas(dog, dogScales);
fprintf('       Localizing extremas \n');
[updatedExtremas, dx, dy] = localize(dog, dogScales, extremas);
fprintf('       Eliminating Edge Responses \n');
eerExtremas = elimEdgeResponse(updatedExtremas, dog, dx, dy);

fprintf('       Calculating Histograms \n');
[histograms, keypointCount, ms, thetas] = findOrientation(eerExtremas, gaussian(1:end-1, :, :));
fprintf('       Extracting Keypoints \n');
keypoints = fitPeaks(eerExtremas, histograms, keypointCount);
fprintf('       Calculating Descriptors \n');
[descriptors, ~] = findDescriptors(keypoints, ms, thetas);

nextImage = squeeze(gaussian(end-2, :, :));
nextScale = scales(end-2);

siftDetails = repmat(struct('keypoint',0,'descriptor',0), size(keypoints, 1), 1);

for i=1:size(keypoints, 1)
   siftDetails(i).keypoint = keypoints(i);
   siftDetails(i).descriptor = squeeze(descriptors(i, :));
end

end

