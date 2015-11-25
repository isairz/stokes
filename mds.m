function varargout = mds(varargin)
% MDS MATLAB code for mds.fig
%      MDS, by itself, creates a new MDS or raises the existing
%      singleton*.
%
%      H = MDS returns the handle to a new MDS or the handle to
%      the existing singleton*.
%
%      MDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MDS.M with the given input arguments.
%
%      MDS('Property','Value',...) creates a new MDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mds_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mds_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mds

% Last Modified by GUIDE v2.5 28-Oct-2015 14:43:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mds_OpeningFcn, ...
                   'gui_OutputFcn',  @mds_OutputFcn, ...
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


% --- Executes just before mds is made visible.
function mds_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mds (see VARARGIN)

% Choose default command line output for mds
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mds wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Load ERSP
global meanBandERSP;
global TypeName;
meanInfo = load('Data/KBJ_means');
meanBandERSP = meanInfo.meanBandERSP;
TypeName = meanInfo.TypeName;

% Load times
global times;
timeInfo = load(strcat(pwd, '/Data/KBJ_times'));
times = timeInfo.times;

% Load bands
global bands;
bandInfo = load(strcat(pwd, '/Data/KBJ_bands'));
bands = bandInfo.bands;

% init
global oldRegion;
oldRegion = 0;

updatePlot(handles);


% --- Outputs from this function are returned to the command line.
function varargout = mds_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function timeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to timeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function timeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function timeSlider2_Callback(hObject, eventdata, handles)
% hObject    handle to timeSlider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function timeSlider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeSlider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in regionMenu.
function regionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to regionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regionMenu

updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function regionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global regionId;
regionInfo = load(strcat(pwd, '/Data/KBJ_regions'));
[regionId, regions] =  grp2idx(regionInfo.mappingIdx(:, 2));

hObject.String = regions;
%handles.UserData = regionId;

function updatePlot(handles)
global TypeName;
global meanBandERSP;
global bands;
global times;
global regionId;
global oldRegion;
global Z;
region = handles.regionMenu.Value;
t1 = max(round(length(times) * handles.timeSlider.Value), 1);
t2 = max(round(length(times) * handles.timeSlider2.Value), 1);
set(handles.textTime, 'String', strcat(num2str(times(t1)), '~', num2str(times(t2)), ' ms'));

% Multidimensional Scale
timeERSPT = permute(meanBandERSP, [1, 3, 4, 2]);
axesMap = [ handles.axes1, handles.axes2, handles.axes3, handles.axes4, handles.axes5, handles.axes6 ];
if isempty(oldRegion) || oldRegion ~= region,
    time = length(times);
    channel = size(meanBandERSP(regionId == region), 1);
    Z = zeros(length(TypeName), time, channel, length(bands));
    for b = 1:length(bands),
        timeERSP = timeERSPT(:,:,:,b);
        timeERSP = timeERSP(regionId == region, :)';
        D = pdist(timeERSP);
        Y = cmdscale(D);

        for s=1:length(TypeName),
            Z(s, :, :, b) = Y(1+(s-1)*time:s*time, :);
        end
    end
    
    oldRegion = region;
end

for b = 1:length(bands),
    axes(axesMap(b));
    %subplot(3,2,b);
    xs = Z(:, :, 1, b);
    ys = Z(:, :, 2, b);
    %axis([0,1,2,3]);
    hold off;
    
    for s = 1:length(TypeName)
        %scatter(Z(s, t, 1, b), Z(s, t, 1, b), '*');
        plot(Z(s, t1:t2, 1, b), Z(s, t1:t2, 2, b), 'o-');
        hold on;
    end
    axis([min(xs(:)), max(xs(:)), min(ys(:)), max(ys(:))]);
    
    xlabel('Dimension1');
    ylabel('Dimension2');
    title(strcat('\fontsize{16}',bands(b)));
end
legend(TypeName);
