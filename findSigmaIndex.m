function sigmaIndex = findSigmaIndex(sigma, scales)
    for i=1:size(scales) - 1
       startVal = scales(i);
       if startVal == sigma
           sigmaIndex = i;
           return
       end
       endVal = scales(i+1);
       
       if startVal < sigma && endVal > sigma
           if sigma - startVal <= endVal - sigma
              sigmaIndex = i;
              return
           else
              sigmaIndex = i + 1;
              return
           end
       end
    end
    
    if sigma == scales(end)
       sigmaIndex = size(scales, 1);
    else
       sigmaIndex = -1000; 
    end
end