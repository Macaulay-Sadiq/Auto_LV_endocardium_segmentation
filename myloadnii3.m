% clear all;
close all;
% clc;



Folder = uigetdir('Image Folder');
FileList = dir(fullfile(Folder, '*.nii.gz'));

slices = [];

for i = 1 : length(FileList)
    A1 = strfind(FileList(i).name, 'gt');
    if isempty(A1)
        A2 = strfind(FileList(i).name, '4d');
         if isempty(A2)        
             tmp = FileList(i);
             slices = [slices;  tmp];
         end
    end
end


name1 = slices(1).name;
path1 = FileList(1).folder;
fullfilenames1 = fullfile(path1, name1);
systole = niftiread(fullfilenames1);

cine1 = zeros(size(systole));
sz = size(cine1);

for j = 1:sz(3)
    cine1(:,:,j) = uint8(systole(:,:,j));
end


%%
% LVlocal = cineLVLocalize(cine1);
% for i = 1:10
% figure; imshow(LVlocal(:,:,i),[])
% end


figure
cm = brighten(jet(length('gray')),-.5);
colormap(cm)
contourslice(cine1,[],[],[1:10],10);
view(3);
axis tight
axis off
