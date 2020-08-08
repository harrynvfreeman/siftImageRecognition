function [histograms, keypointCount, ms, thetas] = findOrientation(extremas, gaussians)
    scaleCoeff = 1.5;
    kernelSize = 16;
    binSize = 10;
    numBins = 360/binSize;
    
    dx = calcDx(gaussians);
    dy = calcDy(gaussians);

    ms = sqrt(dx.^2 + dy.^2);
    thetas = atan2(dy, dx);
    
    thetas = thetas*180/pi;
    thetas = mod(thetas, 360);
    histograms = zeros(size(extremas,1), numBins);
    
    keypointCount = 0;
    for i=1:size(extremas)
        x = extremas(i).x;
        y = extremas(i).y;
        sigma = extremas(i).sigma;
        sigmaIndex = extremas(i).sigmaIndex;
        
        m = squeeze(ms(sigmaIndex,:,:));
        theta = squeeze(thetas(sigmaIndex,:,:));
        
        xMin = max(1, floor(x) - kernelSize + 1);
        xMax = min(size(gaussians, 3), ceil(x) + kernelSize - 1);
        
        yMin = max(1, floor(y) - kernelSize + 1);
        yMax = min(size(gaussians, 2), ceil(y) + kernelSize - 1);
        
        gaussianSigma = scaleCoeff*sigma;
        for row=yMin:yMax
           for col=xMin:xMax
              gaussianWeight = (1/(2*pi*gaussianSigma^2))...
                  *exp(-((y-row)^2 + (x-col)^2)/(2*gaussianSigma^2)); 
              
              bin = floor(theta(row,col) / binSize) + 1;
              histograms(i, bin) = histograms(i, bin) + m(row,col)*gaussianWeight;
           end
        end
        
        maxVal = max(histograms(i, :));
        compVal = 0.8*maxVal;
        %compVal = maxVal;
        for j=1:numBins
           if histograms(i, j) >= compVal
              keypointCount = keypointCount + 1; 
           end
        end
    end
end

function dx = calcDx(D)
    dx = zeros(size(D));
    for s=1:size(D,1)
        for i=1:size(D,2)
           %dx(s,i,1) = D(s, i, 2)/2;
           %dx(s,i,1) = D(s, i, 2) - D(s, i, 1);
           dx(s,i,1) = D(s, i, 2);
           for j=2:size(D,3)-1
               %removed divide by two
               dx(s, i, j) = (D(s, i, j+1) - D(s, i, j-1));
           end
           %dx(s,i,size(D,3)) = -D(s,i,size(D,3)-1)/2;
           %dx(s,i,size(D,3)) = D(s, i, size(D,3)) - D(s,i,size(D,3)-1);
           dx(s,i,size(D,3)) =  - D(s,i,size(D,3)-1);
        end
    end
end

function dy = calcDy(D)
    dy = zeros(size(D));
    for s=1:size(D,1)
        for j=1:size(D,3)
           %dy(s,1,j) = D(s, 2, j)/2;
           %dy(s,1,j) = D(s, 2, j) - D(s, 1, j);
           dy(s,1,j) = D(s, 2, j);
           for i=2:size(D,2)-1
               %removed divide by two
               dy(s, i, j) = (D(s, i+1, j) - D(s, i-1, j));
           end
           %dy(s,size(D,2),j) = -D(s,size(D,2)-1,j)/2;
           %dy(s,size(D,2),j) = D(s,size(D,2),j) - D(s,size(D,2)-1,j);
           dy(s,size(D,2),j) = - D(s,size(D,2)-1,j);
        end
    end
end

