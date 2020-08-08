function keypoints = fitPeaks(eerExtremas, histograms, keypointTempCount)

keypointsTemp = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0,'orientation',0), keypointTempCount, 1);
keypointsTempIndex = 1;

numBins = size(histograms, 2);
binSize = 360/numBins;

for i=1:size(eerExtremas, 1)
   maxVal = max(histograms(i, :));
   
   compVal = 0.8*maxVal;
   for j=1:numBins
       if histograms(i, j) >= compVal
           lowBin = mod(j-2, numBins) + 1;
           highBin = mod(j, numBins) + 1;
           
           xMid = (j-0.5)*binSize;
           xLow = xMid - binSize;
           xHigh = xMid + binSize;
           xAxis = [xLow, xMid, xHigh];
           
           yLow = histograms(i, lowBin);
           yMid = histograms(i, j);
           yHigh = histograms(i, highBin);
           yAxis = [yLow, yMid, yHigh];
           
           p = polyfit(xAxis, yAxis, 2);
           
           if (p(1) < 0)
               orientation = -p(2)/(2*p(1));
               keypointsTemp(keypointsTempIndex).x = eerExtremas(i).x;
               keypointsTemp(keypointsTempIndex).y = eerExtremas(i).y;
               keypointsTemp(keypointsTempIndex).sigma = eerExtremas(i).sigma;
               keypointsTemp(keypointsTempIndex).sigmaIndex = eerExtremas(i).sigmaIndex;
               keypointsTemp(keypointsTempIndex).orientation = orientation;
               keypointsTempIndex = keypointsTempIndex + 1;
           end
       end
   end
end

keypoints = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0,'orientation',0), keypointsTempIndex - 1, 1);

for i=1:keypointsTempIndex-1
   keypoints(i) =  keypointsTemp(i);
end


end

