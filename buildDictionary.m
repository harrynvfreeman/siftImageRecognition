function dictionaryOutput = buildDictionary(numOctaves, resizeFactor)

mydir = uigetdir;
files = dir(fullfile(mydir, '*.jpeg'));
files2 = dir(fullfile(mydir, '*.png'));
files3 = dir(fullfile(mydir, '*.jpg'));
files = [files; files2; files3];
dictionaryIndex = 1;
for k = 1:length(files)
   fprintf('Processing Image %d \n', k);
   baseFileName = files(k).name;
   fullFileName = fullfile(mydir, baseFileName);
   [I, IOrig, sigma, interpValue] = prepareImage(fullFileName, resizeFactor);
   siftDetails = multOctave(I, IOrig, sigma, numOctaves, interpValue);
   
   for i=1:numOctaves
    siftOctaveDetails = siftDetails{i};
   
    for j=1:size(siftOctaveDetails, 1)
        dictionary(dictionaryIndex).descriptor = siftOctaveDetails(j).descriptor; 
        dictionary(dictionaryIndex).keypoint = siftOctaveDetails(j).keypoint;
        dictionary(dictionaryIndex).interpValue = siftOctaveDetails(j).interpValue;
        dictionary(dictionaryIndex).processedImage = siftOctaveDetails(j).processedImage;
        dictionary(dictionaryIndex).originalImage = siftOctaveDetails(j).originalImage;
        
        dictionary(dictionaryIndex).label = k;
        dictionary(dictionaryIndex).fileName = baseFileName;
        dictionaryIndex = dictionaryIndex + 1;
    end
   end
end

dictionaryOutput.dictionary = dictionary;
dictionaryOutput.numLabels = length(files);

end

