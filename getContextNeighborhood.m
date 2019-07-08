% Gets the context neighboorhood (basically a the pixels surrounding the
% loc
%
% img is the 2D image
% loc is the location of the center
% R is the size of the window

function out = getContextNeighborhood(img,loc,R)

out = img(loc(1)-R:loc(1)+R, loc(2)-R:loc(2)+R,:);