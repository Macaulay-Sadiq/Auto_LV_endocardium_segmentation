function out = convexImgBdr(img)
out = zeros(size(img));
for i = 1:size(img,3)
    [B,~] = bwboundaries(img(:,:,i));
    dt = delaunayTriangulation(B{1}(:,1),B{1}(:,2));
    % Get the convex hull because the LV is always a circle in the
    % short-axis orientation
    ch = convexHull(dt);
    out(:,:,i) = roipoly(img(:,:,1), ...
        round(dt.Points(ch,2)),round(dt.Points(ch,1)));
end

end
