function varargout = mainGUI(varargin)
% MAINGUI MATLAB code for mainGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGUI

% Last Modified by GUIDE v2.5 23-May-2019 18:42:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGUI (see VARARGIN)

% Choose default command line output for mainGUI
handles.output = hObject;
handles.index = 0;
handles.slices = 0;
handles.segment = 0;
handles.slices = 0;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbuttonDiastole.
function pushbuttonDiastole_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiastole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


%  reading the systolic phase
name1 = slices(1).name;
path1 = FileList(1).folder;
fullfilenames1 = fullfile(path1, name1);
systole = niftiread(fullfilenames1);

cine1 = zeros(size(systole));
sz = size(cine1);

for j = 1:sz(3)
    cine1(:,:,j) = uint8(systole(:,:,j));
end

handles.cine1 = cine1;
%  Segmentation of the Systolic phase
LVlocal1 = cineLVLocalize(cine1);
cine1Smoothed = adaptiveSmoothing(cine1);
kInfo1 = getKClusters(cine1Smoothed,22);
combinedClusters1 = kMeansClusterCombine(kInfo1);
cine1LVseg = finalClusterCombine(combinedClusters1,LVlocal1);
handles.systoleSeg = cine1LVseg;


%  reading Diastolic phase
name2 = slices(2).name;
path2 = FileList(2).folder;
fullfilenames2 = fullfile(path2, name2);
diastole = niftiread(fullfilenames2);

cine2 = zeros(size(diastole));
sz = size(cine2);

for j = 1:sz(3)
    cine2(:,:,j) = uint8(diastole(:,:,j));
end

handles.cine2 = cine2;

%  Segmentation of the Diastolic phase
LVlocal2 = cineLVLocalize(cine2);
cine1Smoothed = adaptiveSmoothing(cine2);
kInfo2 = getKClusters(cine1Smoothed,22);
combinedClusters2 = kMeansClusterCombine(kInfo2);
cine2LVseg = finalClusterCombine(combinedClusters2,LVlocal2);
handles.diastoleSeg = cine2LVseg;

DV = cardiacStatistics(cine1LVseg);
DV = DV/1000;


SV = cardiacStatistics(cine2LVseg);
SV = SV/1000;

EF = ((DV - SV) / DV) * 100;

slcThickness = num2str(5);
slcGap = num2str(5);
Dv = num2str(DV);
Sv = num2str(SV);
Ef = num2str(EF);


information = sprintf('     Cardiac Info... \n\nSlice Thickness: \n%s\n\nSlice Gap:\n%s\n\nEnd-Systolic Volume: \n%smL \n\nEnd-Diastolic Volume: \n%smL\n\nEjection Fraction: \n%s%\n\n',...
    slcThickness, slcGap, Sv, Dv, Ef);
set(handles.metricsBox, 'String', information);


axes(handles.display)
imshow(cine2(:,:,5),[]);
axis off
hold on

temp = zeros(sz(1),sz(2),3);
overlay = imagesc(temp);
temp(:,:,1) = cine2LVseg(:,:,5);
set(overlay,'AlphaData',cine2LVseg(:,:,5) * 0.7,'CData',temp);
colormap('gray')

guidata(hObject, handles);





% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.index;
slices = handles.slices;
segment = handles.segment;

if(index == 1)
    return;
end

index = index - 1;
handles.index = index;

sz = size(slices);

axes(handles.display)
im1 = imshow(slices(:,:,index),[]);
axis off
hold on

temp = zeros(sz(1),sz(2),3);
overlay = imagesc(temp);
set(im1,'CData',slices(:,:,index));
temp(:,:,1) = segment(:,:,index);
set(overlay,'AlphaData',segment(:,:,index) * 0.7,'CData',temp);
colormap('gray')
guidata(hObject, handles);



% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.index;
slices = handles.slices;
segment = handles.segment;

sz = size(slices);

if(index == sz(3))
    return;
end

index = index + 1;
handles.index = index;

axes(handles.display)
im1 = imshow(slices(:,:,index),[]);
axis off
hold on

temp = zeros(sz(1),sz(2),3);
overlay = imagesc(temp);
set(im1,'CData',slices(:,:,index));
temp(:,:,1) = segment(:,:,index);
set(overlay,'AlphaData',segment(:,:,index) * 0.7,'CData',temp);
colormap('gray')
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSystolePhase.
function pushbuttonSystolePhase_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSystolePhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.index = 0;
set(gcbo,'userdata',1);

cine1 = handles.cine1;
handles.slices = cine1;
systoleSeg = handles.systoleSeg;
handles.segment = systoleSeg;
guidata(hObject, handles);

% displaying segmented parts
axes(handles.systolewindow);
im2 = imshow(cine1(:,:,1),[]);
hold on
axis off
sz = size(cine1);
tmp_ov = zeros(sz(1),sz(2),3);
ov = imagesc(tmp_ov);
"set(gcbo,'userdata',1)";
set(handles.exit,'userdata',0);
 while ~get(handles.exit,'userdata')
    for j = 1:sz(3)
        set(im2,'CData',cine1(:,:,j));
        tmp_ov(:,:,1) = systoleSeg(:,:,j);
        set(ov,'AlphaData',systoleSeg(:,:,j) * 0.7,'CData',tmp_ov);
        colormap('gray')        
        drawnow;
        pause(1/sz(3));
    end
 end
 



% --- Executes on button press in pushbuttonDiastolePhase.
function pushbuttonDiastolePhase_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiastolePhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.index = 0;
set(gcbo,'userdata',1);

cine2 = handles.cine2;
handles.slices = cine2;
diastoleSeg = handles.diastoleSeg;
handles.segment  = diastoleSeg;
sz = size(cine2);
guidata(hObject, handles);

% displaying segmented parts
axes(handles.diastolewindow);
im2 = imshow(cine2(:,:,1),[]);
hold on
axis off
tmp_ov = zeros(sz(1),sz(2),3);
ov = imagesc(tmp_ov);
"set(gcbo,'userdata',1)";
set(handles.exit,'userdata',0);
 while ~get(handles.exit,'userdata')
    for j = 1:sz(3)
        set(im2,'CData',cine2(:,:,j));
        tmp_ov(:,:,1) = diastoleSeg(:,:,j);
        set(ov,'AlphaData',diastoleSeg(:,:,j) * 0.7,'CData',tmp_ov);
        colormap('gray')        
        drawnow;
        pause(1/sz(3));
    end
 end



% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcbo,'userdata',1);
clear all force;
clc;
delete(mainGUI);

% --- Executes when display is resized.
function display_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
