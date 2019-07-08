%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Automated LV segmentation based on Lynch & Whelan 2004
% -This script is meant to serve as a base for endocardial segmentation of
% short-axis cardiac images to allow calculation of ejection fraction.
% There are two main steps to the segmentation: (1) Smoothing and (2)
% Clustering the pixel intensities.
%
% Written by: Adrian Lam
% ayplam@gmail.com
%
%



%% Read in dicom images
close all;
clear all;
clc;


% dcmdir = ('dcms/*.dcm');
% files = dir('dcms/*.dcm');
[filename, filePath] = uigetfile('*.nii.gz', 'Data-set Directory');
% files(1:2) = [];
% fullfilenames = cellfun(@(x)fullfile(dcmdir,x),{files.name},'uniformoutput',0);
fullfilenames = fullfile(filePath, filename);
tmp = niftiread(fullfilenames);
cine = zeros(size(tmp));

% fullfilenames = fullfile(files(1).folder, files(1).name);
% tmp = dicomread(fullfilenames);
% tmp = dicomread(fullfilenames{1});
% cine = zeros([size(tmp) length(files)])

%%
for i = 1:size(cine,3)
    cine(:,:,i) = uint8(tmp(:,:,i));
end
sz = size(cine);

% Images to display as an example
% d = round(linspace(1,10,3));

% Automatically identify the location of the LV
LVlocal = cineLVLocalize(cine);

%%
% opengl software
f1 = figure(1);
for i = 1:size(cine,3)
    subplot(2,5,i)
    imagesc(cine(:,:,i));
    axis image
    axis off
    hold on
    temp = zeros(sz(1),sz(2),3);
    temp(:,:,1) = LVlocal(:,:,i);
    overlay = imagesc(temp);
    set(overlay,'AlphaData',LVlocal(:,:,i) * 0.7);
end
colormap('gray')
set(gcf,'Position', [560 609 954 339]);

hb = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off', ...
    'Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.975,'\bf Cardiac Segmentation with K-means', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment', 'top', ...
    'FontSize',13);

%% Step 1

% Perform smoothing on the cine images for improved image clustering
cineSmoothed = adaptiveSmoothing(cine);

% Step 2
% Use a k-means to start clustering like-segments together
kInfo = getKClusters(cineSmoothed,22);

% opengl software
f2 = figure(2);
for i = 1:size(cine,3)
    subplot(4,10,i)
    imagesc(cineSmoothed(:,:,i));
    subplot(4,10,i+10)
    imagesc(kInfo.mask(:,:,i));
end

colormap('jet')
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off', ...
    'Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.975,'Smoothed Images', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment', 'top', ...
    'FontSize',12);
text(0.5, 0.525,'KMeansClustered Images', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment', 'top', ...
    'FontSize',12);


%% Step 2b


% Combine all related clusters
combinedClusters = kMeansClusterCombine(kInfo);

% Finalize the cluster combining by extracting which cluster is actually 
% the LV and doing some convex rounding
LVseg = finalClusterCombine(combinedClusters,LVlocal);

% opengl software
f3 = figure(3);
im = imagesc(cine(:,:,1));

hold on
axis image

tmp_ov = zeros(sz(1),sz(2),3);
ov = imagesc(tmp_ov);

%%
% Review all segmented images

for i = 1:sz(3)    
    set(im,'CData',cine(:,:,i));
    tmp_ov(:,:,1) = LVseg(:,:,i);
    set(ov,'AlphaData',LVseg(:,:,i) * 0.7,'CData',tmp_ov);    
    colormap('gray')
    %title(['Segmented Short-Axis Image: #',num2str(i)])
    drawnow;
end
