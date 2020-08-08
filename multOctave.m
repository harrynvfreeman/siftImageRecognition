function siftDetails = multOctave(I, IOrig, sigma, numOctaves, interpValue)

%At each new octave does scale reset at 1.6?

siftDetails = cell(numOctaves, 1);
for i=1:numOctaves
    fprintf('   Processing Octave %d \n', i);
    [siftOctaveDetails, nextImage, ~] = processOctave(I,sigma);
    for j=1:size(siftOctaveDetails, 1)
       siftOctaveDetails(j).interpValue = interpValue;
       siftOctaveDetails(j).processedImage = I;
       siftOctaveDetails(j).originalImage = IOrig;
    end
    
    siftDetails{i} = siftOctaveDetails;
    
    I = nextImage(2:2:end, 2:2:end);
    %sigma = nextScale;
    interpValue = interpValue / 2;
end
end

