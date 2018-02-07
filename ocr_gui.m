function varargout = ocr_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ocr_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ocr_gui_OutputFcn, ...
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


function ocr_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;


guidata(hObject, handles);


function varargout = ocr_gui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


function pb_load_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.bmp';'*.gif';'*.tif'}, 'Pick an Image File');
img=imread([pathname,filename]);
set(handles.text1,'String',[filename]);
set(handles.text1,'FontSize',14);
axes(handles.img_display);
imagesc(img);
address = cat(2,pathname,filename);
imagen=imread(address);
% Show image
imshow(imagen);

if size(imagen,3)==3 %RGB image
    imagen=rgb2gray(imagen);
end

threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);

imagen = bwareaopen(imagen,30);

word=[ ];
text=[ ];
re=imagen;

load templates
global templates

num_letras=size(templates,2);
while 1
   
    [fl re]=lines(re);
    imgn=fl;
    %-----------------------------------------------------------------
    % Label and count connected components
    [L Ne] = bwlabel(imgn);
    for n=1:Ne
        [r,c] = find(L==n);
        % Extract letter
        n1=imgn(min(r):max(r),min(c):max(c));
        % Resize letter (same size of template)
        img_r=imresize(n1,[42 24]);
        %-------------------------------------------------------------------
        % Call fcn to convert image to text
        letter=read_letter(img_r,num_letras);
        % Letter concatenation
        word=[word letter];
    end
    text = char(text, word);
    % Clear 'word' variable
    word=[ ];
    %*When the sentences finish, breaks the loop
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end
end
set(handles.img_display,'Visible','off');
set(handles.text2,'String',[text]);
set(handles.text2,'FontSize',24);
guidata(hObject, handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)

printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)

selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

function popupmenu1_Callback(hObject, eventdata, handles)

function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end
