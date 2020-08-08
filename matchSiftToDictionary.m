function [output, octaveCount] = matchSiftToDictionary(siftDetails, IOrig, dictionary)

matchIndex = 1;
labelsFound = zeros(dictionary.numLabels, 1);
connectedImages = cell(dictionary.numLabels, 1);

octaveCount = zeros(length(siftDetails), 1);
for i=1:length(siftDetails)
   siftOctaveDetails = siftDetails{i};
   
   for j=1:length(siftOctaveDetails)
      match = keypointMatch(dictionary.dictionary, siftOctaveDetails(j).descriptor);
      if match.found==1
         octaveCount(i) = octaveCount(i) + 1;
         matchedKeyPoints(matchIndex).minIndex = match.minIndex;
         matchedKeyPoints(matchIndex).secondMinIndex = match.secondMinIndex;
         matchedKeyPoints(matchIndex).siftDetail = siftOctaveDetails(j);
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

if matchIndex == 1
   output = -1;
   return
end
for i=1:length(matchedKeyPoints)
    label = dictionary.dictionary(matchedKeyPoints(i).minIndex).label;
    connectedImage = connectedImages{label};
    
    dictionaryKeypoint = dictionary.dictionary(matchedKeyPoints(i).minIndex).keypoint;
    dictionaryInterpValue = dictionary.dictionary(matchedKeyPoints(i).minIndex).interpValue;
    dictionaryProcessedImage = dictionary.dictionary(matchedKeyPoints(i).minIndex).processedImage;
    dictionaryOriginalImage = dictionary.dictionary(matchedKeyPoints(i).minIndex).originalImage;
   
    [dictionaryY, dictionaryX] = getAdjustedPoints(dictionaryKeypoint, dictionaryInterpValue, dictionaryProcessedImage, dictionaryOriginalImage);
    
    siftKeypoint = matchedKeyPoints(i).siftDetail.keypoint;
    siftInterpValue = matchedKeyPoints(i).siftDetail.interpValue;
    siftProcessedImage = matchedKeyPoints(i).siftDetail.processedImage;
    siftOriginalImage = matchedKeyPoints(i).siftDetail.originalImage;
    
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

