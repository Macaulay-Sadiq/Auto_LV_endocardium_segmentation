function contextDiscont = getContextDiscont(img,R)
sz = size(img);
contextDiscont = zeros(size(img));

for row = R+1 : sz(1)-R
    for col = R+1 : sz(2)-R
        contextNeighbor = getContextNeighborhood(img,[row col],R);
        contextDiscont(row,col,:) = stdCN(contextNeighbor);
    end
end
    
% Normalize contextDiscontinuities
mn = min(min(contextDiscont(R+1:sz(1)-R,R+1:sz(2)-R,:),[],1),[],2);
mx = max(max(contextDiscont(R+1:sz(1)-R,R+1:sz(2)-R,:),[],1),[],2);

contextDiscont = ( contextDiscont - repmat(mn,sz(1:2)) ) ./ ...
    ( repmat(mx,sz(1:2)) - repmat(mn,sz(1:2)) );