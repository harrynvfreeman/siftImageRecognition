function [updatedExtremas, dx, dy] = localize(dog, scales, extremas)

thresh = 0.03;
maxCount = 5;

dx = calcDx(dog);
dy = calcDy(dog);
ds = calcDs(dog, scales);

dxx = calcDx(dx);
dxy = calcDy(dx);
dxs = calcDs(dx, scales);

dyx = calcDx(dy);
dyy = calcDy(dy);
dys = calcDs(dy, scales);

dsx = calcDx(ds);
dsy = calcDy(ds);
dss = calcDs(ds, scales);

updatedExtremasTemp = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0), size(extremas, 1), 1);
updatedIndex = 1;

%Confirm the h and deriv method!!!
%Do we cycle again when derivative greater than 0.5 or stop and reassign?
%do we use sigma for derivative or just 1?
for i=1:size(extremas)
   sigma = extremas(i).sigma;
   sigmaIndex = extremas(i).sigmaIndex;
   y = extremas(i).y;
   x = extremas(i).x;
   
   cycle = 1;
   count = 0;
   finalize = 0;
   while cycle == 1
        H = [dxx(sigmaIndex, y, x) dxy(sigmaIndex, y, x) dxs(sigmaIndex, y, x); ...
            dyx(sigmaIndex, y, x) dyy(sigmaIndex, y, x) dys(sigmaIndex, y, x); ...
            dsx(sigmaIndex, y, x) dsy(sigmaIndex, y, x) dss(sigmaIndex, y, x);];
        deriv = [dx(sigmaIndex, y, x) dy(sigmaIndex, y, x) ds(sigmaIndex, y, x)]';
        %xhat = -inv(H)*deriv;
        xhat = -H\deriv;
        
        sigmaDelta = xhat(3);
        sigmaUpdated = sigma + sigmaDelta;
        sigmaIndexUpdated = findSigmaIndex(sigmaUpdated, scales);
        yDelta = xhat(2);
        yUpdated = y + yDelta;
        xDelta = xhat(1);
        xUpdated = x + xDelta;
        
        if (xUpdated < 0.5 || xUpdated > size(dog, 3) + 0.4 || yUpdated < 0.5 ...
                || yUpdated > size(dog, 2) + 0.4 || ... 
                sigmaUpdated < scales(1) || sigmaUpdated > scales(end)...
                || (isnan(sum(xhat))))
            cycle = 0;
        elseif (abs(xDelta) > 0.5 || abs(yDelta) > 0.5 || sigmaIndexUpdated ~= sigmaIndex)
            if count < maxCount
                x = round(xUpdated);
                y = round(yUpdated);
                sigmaIndex = sigmaIndexUpdated;
                sigma = scales(sigmaIndex);
            else
               x = round(xUpdated);

               y = round(yUpdated);
               sigmaIndex = sigmaIndexUpdated;
               sigma = scales(sigmaIndex);
               
               xhat(1) = xUpdated - x;
               xhat(2) = yUpdated - y;
               xhat(3) = sigmaUpdated - scales(sigmaIndex);
               
               finalize = 1; 
            end
        else
            finalize = 1;
        end
        
        if finalize == 1
            D = dog(sigmaIndex, y, x) + 0.5*deriv'*xhat;
            if abs(D) >= thresh
                updatedExtremasTemp(updatedIndex).x = xUpdated;
                updatedExtremasTemp(updatedIndex).y = yUpdated;
                updatedExtremasTemp(updatedIndex).sigma = sigmaUpdated;
                updatedExtremasTemp(updatedIndex).sigmaIndex = sigmaIndexUpdated;
                updatedIndex = updatedIndex + 1;    
            end
            cycle = 0;
        end
        
        count = count + 1;
   end
end

updatedExtremas = repmat(struct('x',0,'y',0,'sigma',0,'sigmaIndex',0), updatedIndex - 1, 1);
for i = 1:updatedIndex - 1
   updatedExtremas(i) = updatedExtremasTemp(i); 
end

end

function dx = calcDx(D)
    dx = zeros(size(D));
    for s=1:size(D,1)
        for i=1:size(D,2)
           %dx(s,i,1) = D(s, i, 2)/2;
           dx(s,i,1) = D(s, i, 2) - D(s, i, 1);
           for j=2:size(D,3)-1
               dx(s, i, j) = (D(s, i, j+1) - D(s, i, j-1))/2;
           end
           %dx(s,i,size(D,3)) = -D(s,i,size(D,3)-1)/2;
           dx(s,i,size(D,3)) = D(s, i, size(D,3)) - D(s,i,size(D,3)-1);
        end
    end
end

function dy = calcDy(D)
    dy = zeros(size(D));
    for s=1:size(D,1)
        for j=1:size(D,3)
           %dy(s,1,j) = D(s, 2, j)/2;
           dy(s,1,j) = D(s, 2, j) - D(s, 1, j);
           for i=2:size(D,2)-1
               dy(s, i, j) = (D(s, i+1, j) - D(s, i-1, j))/2;
           end
           %dy(s,size(D,2),j) = -D(s,size(D,2)-1,j)/2;
           dy(s,size(D,2),j) = D(s,size(D,2),j) - D(s,size(D,2)-1,j);
        end
    end
end

function ds = calcDs(D, scales)
    ds = zeros(size(D));
    for i=1:size(D,2)
        for j=1:size(D,3)
           ds(1,i,j) = (D(2, i, j) - D(1, i, j))/(scales(2) - scales(1));
           for s=2:size(D,1)-1
               ds(s, i, j) = (D(s+1, i, j) - D(s-1, i, j))/(scales(s+1) - scales(s-1));
           end
           ds(size(D,1),i,j) = (D(size(D,1),i,j) - D(size(D,1)-1,i,j))/...
               (scales(size(D,1)) - scales(size(D,1) -1));
        end
    end
end
