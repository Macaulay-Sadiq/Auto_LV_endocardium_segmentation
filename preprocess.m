function img = preprocess(img)

BWnobord = imclearborder(img,4);
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
img = imerode(BWfinal,seD);
img = im2bw(img,1);
end