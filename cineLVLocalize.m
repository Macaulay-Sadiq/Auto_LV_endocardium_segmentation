function LVlocal = cineLVLocalize(img)

k = 4;
totImgMask = kmeans2(sum(img,3),k);
totImgMask = preprocess(totImgMask);

stdImg = std(img,[],3);

% The blood pool is the brightest and will be a part of the highest
% k-group
[B,L] = bwboundaries(totImgMask);

% The group with the most difference in the standard deviation across time
% (since the LV is contracting) will be where the position of the LV is.
% This is only true in the short axis orientation I think, but it's the
% most common orientation so it's okay
L2 = (totImgMask) .* stdImg;
Lstd = zeros(length(B),1);

for i = 1:length(B)
    blob = L == i;
    Lstd(i) = sum(sum(blob .* L2));
end

% The LV position that will hopefully be the same across all time steps
[~,ind] = max(Lstd);
LVpos = (L==ind);

sz = size(img);
LVlocal = zeros(size(img));

% se = strel('disk',2);
for i = 1:sz(3)
    % LVposDo more kmeans to split the intensities.
    tmpK = kmeans2(img(:,:,i),k);
    tmpK = preprocess(tmpK);
    [~,L] = bwboundaries(tmpK);
    tmp = L(LVpos);
    tmp(tmp==0) = [];
    bdr = L == mode(tmp);
    
    % Erode to ensure you remain inside the LV cavity.
    %     [B,L] = bwboundaries(imerode(bdr,se));
    [B,L] = bwboundaries(bdr);
    if ~isempty(B)
        dt = delaunayTriangulation(B{1}(:,1),B{1}(:,2));
        % Get the convex hull because the LV is always a circle in the
        % short-axis orientation
        ch = convexHull(dt);
        LVlocal(:,:,i) = roipoly(LVlocal(:,:,1), ...
            round(dt.Points(ch,2)),round(dt.Points(ch,1)));
%     else
%         LVlocal(:,:,i) = L;
    end
end


end