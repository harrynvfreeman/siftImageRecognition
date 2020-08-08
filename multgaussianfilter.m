function [output, scales] = multgaussianfilter(I, sigma)
    s = 3;

    k = 2^(1/s);
    n = s+3;
    
    numRows = size(I,1);
    numCols = size(I,2);
    
    output = zeros(n, numRows, numCols);
    output(1,:,:) = I;
    
    scales = zeros(n,1);
    scales(1) = sigma;
    
    for i=2:n
       sigma = sigma*k;
       output(i,:,:) = imgaussfilt(I, sigma);
       scales(i) = sigma;
    end

end

