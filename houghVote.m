function filteredVotes = houghVote(matchedKeyPoints, dictionary)
%binning scale, yTranslation, xTranlation when wrap around might
%be something to consider here

%should I replace with hash function as paper describes?


maxImageSize = 3000;
locationCoeff = 0.25;
maxScale = 10;
scaleFactor = 2;
numScaleBins = ceil(maxScale / scaleFactor);
orientationBinSize = 30;
numOrientationBins = 360/orientationBinSize;
orientationBinOffset = orientationBinSize / 2;

votes = cell(0);

voteCellCount = 0;

for i=1:length(matchedKeyPoints)
    label = dictionary.dictionary(matchedKeyPoints(i).minIndex).label;
    dictionaryOriginalImage = dictionary.dictionary(matchedKeyPoints(i).minIndex).originalImage;
    
    if label > length(votes) || isempty(votes{label})
        numRowLocationBins = ceil(2*maxImageSize/(locationCoeff*size(dictionaryOriginalImage, 1)));
        numColLocationBins = ceil(2*maxImageSize/(locationCoeff*size(dictionaryOriginalImage, 2)));
        votes{label} = repmat(struct('vote',0), [numRowLocationBins, numColLocationBins, numScaleBins, numOrientationBins]); 
        voteCellCount = voteCellCount + 1;
        
        created = 1;
    else
        created = 0; 
    end
    
    voteValues = votes{label};
    [numRowLocationBins, numColLocationBins, ~, ~] = size(voteValues);
    
    dictionaryKeypoint = dictionary.dictionary(matchedKeyPoints(i).minIndex).keypoint;
    dictionaryInterpValue = dictionary.dictionary(matchedKeyPoints(i).minIndex).interpValue;
    dictionaryProcessedImage = dictionary.dictionary(matchedKeyPoints(i).minIndex).processedImage;
    
    siftKeypoint = matchedKeyPoints(i).siftDetail.keypoint;
    siftInterpValue = matchedKeyPoints(i).siftDetail.interpValue;
    siftProcessedImage = matchedKeyPoints(i).siftDetail.processedImage;
    siftOriginalImage = matchedKeyPoints(i).siftDetail.originalImage;
    
    rotation = siftKeypoint.orientation - dictionaryKeypoint.orientation;
    rotation = mod(rotation, 360);
    
    scaleChange = siftKeypoint.sigma / dictionaryKeypoint.sigma;
    
    [dictionaryY, dictionaryX] = getAdjustedPoints(dictionaryKeypoint, dictionaryInterpValue, dictionaryProcessedImage, dictionaryOriginalImage);
    [siftY, siftX] = getAdjustedPoints(siftKeypoint, siftInterpValue, siftProcessedImage, siftOriginalImage);

    yTranslation = siftY - dictionaryY;
    xTranslation = siftX - dictionaryX;
    
    rotationBin0 = floor(rotation / orientationBinSize) + 1;
    if (rotationBin0 - 1)*orientationBinSize + orientationBinOffset >= rotation
        rotationBin1 = mod(rotationBin0, numOrientationBins) + 1;
    else
        rotationBin1 = rotationBin0;
        rotationBin0 = mod(rotationBin1 - 2, numOrientationBins) + 1;
    end
    
    scaleBin0 = floor(scaleChange) + 1;
    if scaleBin0*scaleFactor - scaleChange < scaleChange - (scaleBin0 - 1)*scaleFactor
        scaleBin1 = mod(scaleBin0, numScaleBins) + 1;
    else
        scaleBin1 = scaleBin0;
        scaleBin0 = mod(scaleBin1 - 2, numScaleBins) + 1;
    end
    
    yBin0 = floor(yTranslation / (locationCoeff*size(dictionaryOriginalImage, 1)));
    yOffset = locationCoeff*size(dictionaryOriginalImage, 1) / 2;
    if yBin0*locationCoeff*size(dictionaryOriginalImage, 1) + yOffset <= yTranslation
        yBin1 = yBin0 + 1;
    else
        yBin1 = yBin0;
        yBin0 = yBin1 - 1;
    end
    
    yBin0 = mod(yBin0, numRowLocationBins) + 1;
    yBin1 = mod(yBin1, numRowLocationBins) + 1;
    
    xBin0 = floor(xTranslation / (locationCoeff*size(dictionaryOriginalImage, 2)));
    xOffset = locationCoeff*size(dictionaryOriginalImage, 2) / 2;
    if xBin0*locationCoeff*size(dictionaryOriginalImage, 2) + xOffset <= xTranslation
        xBin1 = xBin0 + 1;
    else
        xBin1 = xBin0;
        xBin0 = xBin1 - 1;
    end
    
    xBin0 = mod(xBin0, numColLocationBins) + 1;
    xBin1 = mod(xBin1, numColLocationBins) + 1;
    
    voteValues(yBin0, xBin0, scaleBin0, rotationBin0).vote = ...
        voteValues(yBin0, xBin0, scaleBin0, rotationBin0).vote + 1;
    voteValues(yBin0, xBin0, scaleBin0, rotationBin1).vote = ...
        voteValues(yBin0, xBin0, scaleBin0, rotationBin1).vote + 1;
    voteValues(yBin0, xBin0, scaleBin1, rotationBin0).vote = ...
        voteValues(yBin0, xBin0, scaleBin1, rotationBin0).vote + 1;
    voteValues(yBin0, xBin0, scaleBin1, rotationBin1).vote = ...
        voteValues(yBin0, xBin0, scaleBin1, rotationBin1).vote + 1;
    voteValues(yBin0, xBin1, scaleBin0, rotationBin0).vote = ...
        voteValues(yBin0, xBin1, scaleBin0, rotationBin0).vote + 1;
    voteValues(yBin0, xBin1, scaleBin0, rotationBin1).vote = ...
        voteValues(yBin0, xBin1, scaleBin0, rotationBin1).vote + 1;
    voteValues(yBin0, xBin1, scaleBin1, rotationBin0).vote = ...
        voteValues(yBin0, xBin1, scaleBin1, rotationBin0).vote + 1;
    voteValues(yBin0, xBin1, scaleBin1, rotationBin1).vote = ...
        voteValues(yBin0, xBin1, scaleBin1, rotationBin1).vote + 1;
    voteValues(yBin1, xBin0, scaleBin0, rotationBin0).vote = ...
        voteValues(yBin1, xBin0, scaleBin0, rotationBin0).vote + 1;
    voteValues(yBin1, xBin0, scaleBin0, rotationBin1).vote = ...
        voteValues(yBin1, xBin0, scaleBin0, rotationBin1).vote + 1;
    voteValues(yBin1, xBin0, scaleBin1, rotationBin0).vote = ...
        voteValues(yBin1, xBin0, scaleBin1, rotationBin0).vote + 1;
    voteValues(yBin1, xBin0, scaleBin1, rotationBin1).vote = ...
        voteValues(yBin1, xBin0, scaleBin1, rotationBin1).vote + 1;
    voteValues(yBin1, xBin1, scaleBin0, rotationBin0).vote = ...
        voteValues(yBin1, xBin1, scaleBin0, rotationBin0).vote + 1;
    voteValues(yBin1, xBin1, scaleBin0, rotationBin1).vote = ...
        voteValues(yBin1, xBin1, scaleBin0, rotationBin1).vote + 1;
    voteValues(yBin1, xBin1, scaleBin1, rotationBin0).vote = ...
        voteValues(yBin1, xBin1, scaleBin1, rotationBin0).vote + 1;
    voteValues(yBin1, xBin1, scaleBin1, rotationBin1).vote = ...
        voteValues(yBin1, xBin1, scaleBin1, rotationBin1).vote + 1;
    
    
    if created == 1
        voteValues(yBin0, xBin0, scaleBin0, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin0, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin1, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin1, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin0, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin0, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin1, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin1, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin0, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin0, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin1, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin1, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin0, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin0, rotationBin1).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin1, rotationBin0).keypoints(1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin1, rotationBin1).keypoints(1) = matchedKeyPoints(i);
    else
        voteValues(yBin0, xBin0, scaleBin0, rotationBin0).keypoints...
            (length(voteValues(yBin0, xBin0, scaleBin0, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin0, rotationBin1).keypoints...
            (length(voteValues(yBin0, xBin0, scaleBin0, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin1, rotationBin0).keypoints...
            (length(voteValues(yBin0, xBin0, scaleBin1, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin0, scaleBin1, rotationBin1).keypoints...
            (length(voteValues(yBin0, xBin0, scaleBin1, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);    
        voteValues(yBin0, xBin1, scaleBin0, rotationBin0).keypoints...
            (length(voteValues(yBin0, xBin1, scaleBin0, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin0, rotationBin1).keypoints...
            (length(voteValues(yBin0, xBin1, scaleBin0, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin1, rotationBin0).keypoints...
            (length(voteValues(yBin0, xBin1, scaleBin1, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin0, xBin1, scaleBin1, rotationBin1).keypoints...
            (length(voteValues(yBin0, xBin1, scaleBin1, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin0, rotationBin0).keypoints...
            (length(voteValues(yBin1, xBin0, scaleBin0, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin0, rotationBin1).keypoints...
            (length(voteValues(yBin1, xBin0, scaleBin0, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin1, rotationBin0).keypoints...
            (length(voteValues(yBin1, xBin0, scaleBin1, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin0, scaleBin1, rotationBin1).keypoints...
            (length(voteValues(yBin1, xBin0, scaleBin1, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);    
        voteValues(yBin1, xBin1, scaleBin0, rotationBin0).keypoints...
            (length(voteValues(yBin1, xBin1, scaleBin0, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin0, rotationBin1).keypoints...
            (length(voteValues(yBin1, xBin1, scaleBin0, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin1, rotationBin0).keypoints...
            (length(voteValues(yBin1, xBin1, scaleBin1, rotationBin0).keypoints) + 1) = matchedKeyPoints(i);
        voteValues(yBin1, xBin1, scaleBin1, rotationBin1).keypoints...
            (length(voteValues(yBin1, xBin1, scaleBin1, rotationBin1).keypoints) + 1) = matchedKeyPoints(i);
    end
    
    votes{label} = voteValues;
    
end

filteredVotes = cell(voteCellCount);
voteIndex = 1;
for i=1:length(votes)
   if isempty(votes{i}) == 0
      filteredVotes{voteIndex} = votes{i};
      voteIndex = voteIndex + 1;
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

