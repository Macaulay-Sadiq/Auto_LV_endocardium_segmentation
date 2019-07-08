function LVseg = finalClusterCombine(combinedClusters,LVlocal)

LVseg = zeros(size(combinedClusters));
se = ones(3);

for im = 1:size(combinedClusters,3)
    
    % Erode the LVlocal some
    currLVlocal = imerode(LVlocal(:,:,im),se);
    currCluster = combinedClusters(:,:,im);
    bg = mode(currCluster(:));
    
    u = unique(currLVlocal .* combinedClusters(:,:,im));
    u(u==bg) = [];
    
    % Actually need to isolate the boundary now. Not the best way, but it
    % works
    tmp = ismember(combinedClusters(:,:,im),u);
    [B,L] = bwboundaries(tmp);
    tmp = currLVlocal .* L;
    bdr = mode(tmp(tmp~=0));
    
    % Create a convex hull to smooth things
    if ~isempty(B) && ~isnan(bdr)
        dt = delaunayTriangulation(B{bdr}(:,1),B{bdr}(:,2));
        % Get the convex hull because the LV is always a circle in the
        % short-axis orientation
        ch = convexHull(dt);
        LVseg(:,:,im) = roipoly(LVlocal(:,:,1), ...
            round(dt.Points(ch,2)),round(dt.Points(ch,1)));
%     else
%         LVseg(:,:,im) = L;
    end
    
end