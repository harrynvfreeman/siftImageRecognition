function [descriptors, histograms] = findDescriptors(keypoints, ms, thetas)
    sigmaCoeff = 0.5;
    kernelSize = 16;
    subRegionSize = 4;
    %kernelSize = 8;
    %subRegionSize = 4;
    numSubRegions = kernelSize / subRegionSize;
    offset = (subRegionSize + 1)/2 - 1;
    binSize = 45;
    numBins = 360/binSize;
    binOffset = binSize / 2;
    normThresh = 0.2;
    
    histograms = zeros(size(keypoints,1), numSubRegions, numSubRegions, numBins);
    
    descriptorLength = numSubRegions*numSubRegions*numBins;
    descriptors = zeros(size(keypoints,1), descriptorLength);

    for i=1:size(keypoints)
        x = keypoints(i).x;
        y = keypoints(i).y;
        sigmaIndex = keypoints(i).sigmaIndex; 
        orientation = keypoints(i).orientation;
        
        m = squeeze(ms(sigmaIndex,:,:));
        theta = squeeze(thetas(sigmaIndex,:,:));
        %rotate
        theta = mod(theta - orientation, 360);
        theta = imrotate(theta, orientation);
        
        centreY = (1+size(m,1))/2;
        centreX = (1+size(m,2))/2;
        %right direction?
        R = [cosd(orientation) -sind(orientation); sind(orientation) cosd(orientation)];
        rotate = R*[y-centreY, x-centreX]';

        m = imrotate(m, orientation);
        centreYRotate = (1+size(m,1))/2;
        centreXRotate = (1+size(m,2))/2;
       
        rotatedY = rotate(1) + centreYRotate;
        rotatedX = rotate(2) + centreXRotate;

        xMin = max(1, floor(rotatedX) - kernelSize/2 + 1);
        xMax = min(size(m, 2), ceil(rotatedX) + kernelSize/2 - 1);
        
        yMin = max(1, floor(rotatedY) - kernelSize/2 + 1);
        yMax = min(size(m, 1), ceil(rotatedY) + kernelSize/2 - 1);
        
        gaussianSigma = sigmaCoeff*kernelSize;
        %Do we use wrap around?
        for row=yMin:yMax
           ySub0 = floor(mod((row - yMin + 1) - 1 - offset, kernelSize) / subRegionSize) + 1;
           ySub1 = mod(ySub0, numSubRegions) + 1;
           yCentre0 = offset + subRegionSize*(ySub0-1) + 1;
           yScale0 = 1 - mod((row - yMin + 1) - yCentre0, kernelSize) / subRegionSize;
           yScale1 = 1 - yScale0;
           
           for col=xMin:xMax 
               xSub0 = floor(mod((col - xMin + 1) - 1 - offset, kernelSize) / subRegionSize) + 1;
               xSub1 = mod(xSub0, numSubRegions) + 1;
               xCentre0 = offset + subRegionSize*(xSub0-1) + 1;
               xScale0 = 1 - mod((col - xMin + 1) - xCentre0, kernelSize) / subRegionSize;
               xScale1 = 1 - xScale0;              
              
              gaussianWeight = (1/(2*pi*gaussianSigma^2))...
                  *exp(-((rotatedY-row)^2 + (rotatedX-col)^2)/(2*gaussianSigma^2));
              
              bin0 = floor(theta(row,col) / binSize) + 1;

              binCentre0 = (bin0-1)*binSize + binOffset;
              if theta(row,col) < binCentre0
                  bin0 = mod(bin0-2, numBins) + 1;
                  binCentre0 = (bin0-1)*binSize + binOffset;
              end
              bin1 = mod(bin0, numBins) + 1;
              
              bin0Scale = 1 - mod(theta(row,col) - binCentre0, 360) / binSize;
              bin1Scale = 1 - bin0Scale;
              
              histograms(i, ySub0, xSub0, bin0) = ...
                  histograms(i, ySub0, xSub0, bin0) + ...
                  m(row,col)*gaussianWeight*yScale0*xScale0*bin0Scale;
              histograms(i, ySub0, xSub0, bin1) = ...
                  histograms(i, ySub0, xSub0, bin1) + ...
                  m(row,col)*gaussianWeight*yScale0*xScale0*bin1Scale;
              histograms(i, ySub0, xSub1, bin0) = ...
                  histograms(i, ySub0, xSub1, bin0) + ...
                  m(row,col)*gaussianWeight*yScale0*xScale1*bin0Scale;
              histograms(i, ySub0, xSub1, bin1) = ...
                  histograms(i, ySub0, xSub1, bin1) + ...
                  m(row,col)*gaussianWeight*yScale0*xScale1*bin1Scale;
              histograms(i, ySub1, xSub0, bin0) = ...
                  histograms(i, ySub1, xSub0, bin0) + ...
                  m(row,col)*gaussianWeight*yScale1*xScale0*bin0Scale;
              histograms(i, ySub1, xSub0, bin1) = ...
                  histograms(i, ySub1, xSub0, bin1) + ...
                  m(row,col)*gaussianWeight*yScale1*xScale0*bin1Scale;
              histograms(i, ySub1, xSub1, bin0) = ...
                  histograms(i, ySub1, xSub1, bin0) + ...
                  m(row,col)*gaussianWeight*yScale1*xScale1*bin0Scale;
              histograms(i, ySub1, xSub1, bin1) = ...
                  histograms(i, ySub1, xSub1, bin1) + ...
                  m(row,col)*gaussianWeight*yScale1*xScale1*bin1Scale;
           end
        end
        descriptor = reshape(histograms(i, :, :, :), [descriptorLength, 1]);
        descriptor = descriptor ./ norm(descriptor);
        descriptor(descriptor > normThresh) = normThresh;
        descriptor = descriptor ./ norm(descriptor);
        descriptors(i, :) = descriptor;
    end
end

