function kInfo = getKClusters(img,k)

sz = size(img);
kMask = zeros(size(img));
kGroups = zeros(sz(3),k);
for i = 1:sz(3)
    [kMask(:,:,i),kGroups(i,:)] = kmeans2(img(:,:,i),k);
end

kInfo.mask = kMask;
kInfo.grps = kGroups;