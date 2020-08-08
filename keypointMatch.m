function match = keypointMatch(dictionary, descriptor)
%first we will start with one image (second closest neighbour)
%paper says if multiple training images, second closest neighbour comes
%from object that is not the first

rejectionRatio = 0.8;

minIndex = 0;
minDistance = 1000;
for i=1:size(dictionary, 2)
    dist = calcEuclidian(dictionary(i).descriptor, descriptor);
    if dist<minDistance
        minIndex = i;
        minDistance = dist;
    end
end

secondMinIndex = 0;
secondMinDistance = 1000;
for i=1:size(dictionary, 2)
    dist = calcEuclidian(dictionary(i).descriptor, descriptor);
    if dist<secondMinDistance && dictionary(i).label ~= dictionary(minIndex).label
        secondMinIndex = i;
        secondMinDistance = dist;
    end
end

if minIndex == 0 || secondMinIndex == 0
    disp('Really Weird Error Here')
    return
end

match.minIndex = minIndex;
match.secondMinIndex = secondMinIndex;

if minDistance/secondMinDistance > rejectionRatio
    match.found = -1;
else 
    match.found = 1; 
end

