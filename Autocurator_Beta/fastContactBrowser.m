function varargout = fastContactBrowser(varargin)
% FASTCONTACTBROWSER MATLAB code for fastContactBrowser.fig
%      FASTCONTACTBROWSER, by itself, creates a new FASTCONTACTBROWSER or raises the existing
%      singleton*.
%
%      H = FASTCONTACTBROWSER returns the handle to a new FASTCONTACTBROWSER or the handle to
%      the existing singleton*.
%
%      FASTCONTACTBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FASTCONTACTBROWSER.M with the given input arguments.
%
%      FASTCONTACTBROWSER('Property','Value',...) creates a new FASTCONTACTBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fastContactBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fastContactBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fastContactBrowser

% Last Modified by GUIDE v2.5 25-Jul-2018 13:24:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fastContactBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @fastContactBrowser_OutputFcn, ...
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


% --- Executes just before fastContactBrowser is made visible.
function fastContactBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fastContactBrowser (see VARARGIN)

% Choose default command line output for fastContactBrowser
handles.output = hObject;

% Remove axes labels from images because they're not needed
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
set(handles.axes2,'YTick',[]);
set(handles.axes2,'XTick',[]);
set(handles.axes3,'YTick',[]);
set(handles.axes3,'XTick',[]);
set(handles.axes4,'YTick',[]);
set(handles.axes4,'XTick',[]);
set(handles.axes5,'YTick',[]);
set(handles.axes5,'XTick',[]);
set(handles.axes6,'YTick',[]);
set(handles.axes6,'XTick',[]);
set(handles.axes7,'YTick',[]);
set(handles.axes7,'XTick',[]);
set(handles.axes8,'YTick',[]);
set(handles.axes8,'XTick',[]);

% Show images (EXAMPLE)
% -3
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411-3));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes2);
% -2
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411-2));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes3);
% -1
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411-1));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes4);
% 0
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes5);
% +1
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411+1));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes6);
% +2
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411+2));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes7);
% +3
example = mmread('Z:\Data\Video\PHILLIP\AH0706\171031\AH0706x171031-4.mp4',(1411+3));
example = example.frames.cdata(258:318,239:299,1);
imshow(example, 'Parent', handles.axes8);

%Defaults 
autoSkip == false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fastContactBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fastContactBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tArray, tPath] = uigetfile(pwd, 'Select trial array');
[cArray, cPath] = uigetfile(pwd, 'Select contact array'); 


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveLoc = uigetdir(pwd, 'Choose location to save');


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSkip = true;

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if autoSkip == true;
    %Stuff
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
