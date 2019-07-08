% Mean context neighborhood
function u = meanCN(img)

if ismatrix(img)
    u = sum(img(:)) ./ numel(img);
else
    u = sum(sum(img,1),2) / numel(img(:,:,1));
end