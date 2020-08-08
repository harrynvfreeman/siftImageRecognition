function [extremas, extremaMatrix] = findExtremas(dog, dogScales)

extremaMatrix = zeros(size(dog, 1) - 2, size(dog, 2), size(dog,3));
%threshold = 0.00001*max(dog(:));
for d=2:size(dog, 1) - 1
    %threshold = 0.00001*max(max(max(dog(d,:,:))));
    threshold = 0;
    for i=2:size(dog,2)-1
       for j=2:size(dog,3)-1
           if abs(dog(d, i, j)) >= threshold
               
           isPosExtrema=1;
           isNegExtrema=1;
           val = dog(d, i, j);
           for dComp=d-1:d+1
              for iComp=i-1:i+1
                 for jComp=j-1:j+1
                     if (dComp ~= d || iComp ~= i || jComp ~= j)
                        valComp = dog(dComp, iComp, jComp);
                        if (val <= valComp)
                           isPosExtrema = 0; 
                        end
                        
                        if (val >= valComp)
                           isNegExtrema = 0; 
                        end
                     end
                 end
              end
           end
           extremaMatrix(d-1, i, j) = isPosExtrema | isNegExtrema;
           
           end
       end
    end
end

extremas = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0), sum(extremaMatrix(:)),1);
index = 1;

for d=1:size(extremaMatrix, 1)
    for i=2:size(extremaMatrix,2)-1
       for j=2:size(extremaMatrix,3)-1
           if extremaMatrix(d, i, j) == 1
               extremas(index).x = j;
               extremas(index).y = i;
               extremas(index).sigma = dogScales(d+1);
               extremas(index).sigmaIndex = d+1;
               index = index + 1;
           end
       end
    end
end

end

