function sig = stdCN(img)

if ismatrix(img)
    sig = sum(img(:).^2) ./ numel(img) - ...
        (sum(img(:)) ./ numel(img)).^2;
else
    sig = sum(sum(img.^2,1),2) / numel(img(:,:,1)) - ...
        ( sum(sum(img,1),2) / numel(img(:,:,1))).^2;
end

