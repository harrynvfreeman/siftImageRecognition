function [dog, dogScales] = diffOfGaussians(gaussians, scales)

dog = zeros(size(gaussians,1)-1, size(gaussians, 2), size(gaussians, 3));
dogScales = zeros(size(scales,1)-1, 1);

for i=2:size(gaussians,1)
   dog(i-1, :, :) = squeeze(gaussians(i, :, :) - gaussians(i-1, :, :));
   dogScales(i-1) = scales(i-1);
end

end

