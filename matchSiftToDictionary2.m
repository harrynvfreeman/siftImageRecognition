function [output, octaveCount] = matchSiftToDictionary2(siftDetails, IOrig, dictionary)
voteThresh = 3;

matchIndex = 1;
labelsFound = zeros(dictionary.numLabels, 1);
connectedImages = cell(dictionary.numLabels, 1);

octaveCount = zeros(length(siftDetails), 1);

matchedKeypoints = matchKeypoints(siftDetails, dictionary);
votes = houghVote(matchedKeypoints, dictionary);

for i=1:length(votes)
  voteValues = votes{i};
  [numRowLocationBins, numColLocationBins, numScaleBins, numOrientationBins] = size(voteValues);
  
  for row = 1:numRowLocationBins
      for col = 1:numColLocationBins
         for scale = 1: numScaleBins
            for orientation = 1: numOrientationBins
                if voteValues(row, col, scale, orientation).vote >= voteThresh
                    for k = 1:length(voteValues(row, col, scale, orientation).keypoints)
                        match = voteValues(row, col, scale, orientation).keypoints(k);
                        newMatchedKeyPoints(matchIndex) = match;
                        
                        labelsFound(dictionary.dictionary(match.minIndex).label) = 1;
                        originalImage = dictionary.dictionary(match.minIndex).originalImage;
         
                        numRows = max(size(IOrig, 1), size(originalImage, 1));
                        numCols = size(IOrig, 2) + size(originalImage, 2);
         
                        connectedImage = zeros(numRows, numCols);
         
                        connectedImage(1:size(IOrig, 1), 1:size(IOrig, 2)) = IOrig;
                        connectedImage(1:size(originalImage, 1), size(IOrig, 2)+1:end) = originalImage;
         
                        connectedImages{dictionary.dictionary(match.minIndex).label} = connectedImage;
                        
                        matchIndex = matchIndex + 1;
                    end
                end
            end
         end
      end
  end
end

if matchIndex == 1
   output = -1;
   return
end

for i=1:length(newMatchedKeyPoints)
    label = dictionary.dictionary(newMatchedKeyPoints(i).minIndex).label;
    connectedImage = connectedImages{label};
    
    dictionaryKeypoint = dictionary.dictionary(newMatchedKeyPoints(i).minIndex).keypoint;
    dictionaryInterpValue = dictionary.dictionary(newMatchedKeyPoints(i).minIndex).interpValue;
    dictionaryProcessedImage = dictionary.dictionary(newMatchedKeyPoints(i).minIndex).processedImage;
    dictionaryOriginalImage = dictionary.dictionary(newMatchedKeyPoints(i).minIndex).originalImage;
   
    [dictionaryY, dictionaryX] = getAdjustedPoints(dictionaryKeypoint, dictionaryInterpValue, dictionaryProcessedImage, dictionaryOriginalImage);
    
    siftKeypoint = newMatchedKeyPoints(i).siftDetail.keypoint;
    siftInterpValue = newMatchedKeyPoints(i).siftDetail.interpValue;
    siftProcessedImage = newMatchedKeyPoints(i).siftDetail.processedImage;
    siftOriginalImage = newMatchedKeyPoints(i).siftDetail.originalImage;
    
    [siftY, siftX] = getAdjustedPoints(siftKeypoint, siftInterpValue, siftProcessedImage, siftOriginalImage);
    
    y1 = siftY;
    x1 = siftX;
    y2 = dictionaryY;
    x2 = size(siftOriginalImage, 2) + dictionaryX;
    connectedImage = insertShape(connectedImage,'Line',[x1 y1 x2 y2],'LineWidth',1,'Color','blue');
    connectedImages{label} = connectedImage;
end

output = cell(sum(labelsFound), 1);
outputIndex = 1;
for i=1:length(labelsFound)
    if labelsFound(i) == 1
       output{outputIndex} = connectedImages{i};
       outputIndex = outputIndex + 1;
    end
end

end


function [y, x] = getAdjustedPoints(keypoint, interpValue, processedImage, originalImage)
    yDist = keypoint.y - (size(processedImage, 1) + 1)/2;
    xDist = keypoint.x - (size(processedImage, 2) + 1)/2;
    
    yDist = yDist /interpValue;
    xDist = xDist / interpValue;
    
    y = round(yDist + (size(originalImage, 1) + 1)/2);
    x = round(xDist + (size(originalImage, 2) + 1)/2);
end

