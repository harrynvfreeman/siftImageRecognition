function [output, octaveCount] = matchImageToDictionary(imagePath, resizeFactor, numOctaves, dictionary)

[I, IOrig, sigma, interpValue] = prepareImage(imagePath, resizeFactor);
siftDetails = multOctave(I, IOrig, sigma, numOctaves, interpValue);

[output, octaveCount] = matchSiftToDictionary2(siftDetails, IOrig, dictionary);

