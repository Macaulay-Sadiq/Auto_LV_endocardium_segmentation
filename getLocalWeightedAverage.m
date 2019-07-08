% lwa = getLocalWeightedAverage(img,n,y,R)
function lwa = getLocalWeightedAverage(img,n,y)

sz = size(img);
R = floor(sz(1)/2);
cent = R+1;

numer = zeros(1,1,sz(3));
denom = zeros(1,1,sz(3));
for row = 1:sz(1)
    for col = 1:sz(2)
        
        if (row == cent) && (col==cent)
            continue;
        end
        
        numer = numer + n(row,col,:) .* y(row,col,:) .* ...
            (img(row,col,:) - img(cent,cent,:));
        denom = denom + n(row,col,:) .* y(row,col,:);
        
    end
end

% Sanity checking
if denom == 0
    lwa = 0;
elseif numer == 0
    lwa = 0;
else
    lwa = n(cent,cent,:) .* numer./denom;
end
