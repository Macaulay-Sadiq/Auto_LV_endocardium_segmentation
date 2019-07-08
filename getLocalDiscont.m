function localDiscont = getLocalDiscont(img)
sz = size(img);
Edirs = [1 0 -1 0; 0 1 0 -1; 1 1 -1 -1; 1 -1 -1 1];
localDiscont = zeros(size(img));

for row = 2:sz(1)-1
    for col = 2:sz(2)-1
        for e = 1:4
            localDiscont(row,col,:) = localDiscont(row,col,:) + ...
            abs(img(row+Edirs(e,1),col+Edirs(e,2),:) - ...
            img(row+Edirs(e,3),col+Edirs(e,4),:) );
        end
    end
end

localDiscont = localDiscont/4;