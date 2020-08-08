function eerExtremas = elimEdgeResponse(updatedExtremas, dog, dx, dy)

r = 10;

eerExtremasTemp = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0), size(updatedExtremas, 1), 1);
eerIndex = 1;

%do I need to worry about edge cases here?
for i = 1:size(updatedExtremas)
    x = updatedExtremas(i).x;
    y = updatedExtremas(i).y;
    sigmaIndex = updatedExtremas(i).sigmaIndex;
    
    xLow = floor(x);
    xHigh = ceil(x);
    
    yLow = floor(y);
    yHigh = ceil(y);
    
    if (xHigh == xLow || yHigh == yLow)
       disp('Error, equal condition');
       eerExtremas = -1;
       return
    end
    
   	D = squeeze(dog(sigmaIndex, :, :));
    Dx = squeeze(dx(sigmaIndex, :, :));
    Dy = squeeze(dy(sigmaIndex, :, :));
    
    
    dxxLow = (Dx(yLow, xHigh) - Dx(yLow, xLow)) / (xHigh - xLow);
    dxxHigh = (Dx(yHigh, xHigh) - Dx(yHigh, xLow)) / (xHigh - xLow);
    dxx = dxxHigh*(1 + x - xHigh) + dxxLow*(1 + xLow - x);
    
    dyyLow = (Dy(yHigh, xLow) - Dy(yLow, xLow)) / (yHigh - yLow);
    dyyHigh = (Dy(yHigh, xHigh) - Dy(yLow, xHigh)) / (yHigh - yLow);
    dyy = dyyHigh*(1 + y - yHigh) + dyyLow*(1 + yLow - y);
    
    dxy = (D(yHigh, xHigh) + D(yLow, xLow) - D(yHigh, xLow) - D(yLow, xHigh))/4;
    
    tr = dxx  + dyy;
    det = dxx*dyy - dxy*dxy;
    
    if det > 0 && tr*tr/det <= (r+1)*(r+1)/r
        eerExtremasTemp(eerIndex) = updatedExtremas(i);
        eerIndex = eerIndex + 1;
    end
end

eerExtremas = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0), eerIndex - 1, 1);
for i=1:eerIndex-1
   eerExtremas(i) = eerExtremasTemp(i);
end
end

