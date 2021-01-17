function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 15-Jan-2021 17:25:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
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


% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)


set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.cube});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.cube});
axes(handles.cube);

%On start, we reset q0 to 1,0,0,0 in order to do the first push
setGlobalQuat([1 0 0 0]');

handles.Cube=DrawCube();

set(handles.cube,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.cube,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% This functions set and Gets the quaternion and the vector, which are q0
% and m0

% Sets the vector to m0
function setGlobalVector(val)
global v
v = val;
%Gets the m0
function r = getGlobalVector
global v
r = v;

% Sets the quaternion to q0
function setGlobalQuat(val)
global q
q = val;

% Gets the q0
function r = getGlobalQuat
global q
r = q;

% On click, gets the first vector and sets it as global vector (m0)
function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.cube,'xlim');
ylim = get(handles.cube,'ylim');
mousepos=get(handles.cube,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    
    setGlobalVector(To2DPointsTo3D(xmouse, ymouse));
    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
    
end
guidata(hObject,handles)

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.figure1,'WindowButtonMotionFcn','');
guidata(hObject,handles);

% While dragging the mouse, we calculate continuosly the new vector, and we
% Update the Attitudes and so on
function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.cube,'xlim');
ylim = get(handles.cube,'ylim');
mousepos=get(handles.cube,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

% If the mouse is inside the axe boundaries
if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    
    % Sets m1 to the mouse
    m1 = To2DPointsTo3D(xmouse,ymouse);
    
    m0 = getGlobalVector();
    q0 = getGlobalQuat();

    % Calculate the quaternion
    q1 = QuaternionFrom2Vec(m0,m1);
    q1 = q1/norm(q1);
    q1 = MultQuat(q1,q0);  
    % Transform the vector and the quat
    setGlobalVector(m1);
    setGlobalQuat(q1);
    % Redraw Cube
    handles.Cube = RedrawCube(q1,handles.Cube);
    %Publish new attitudes
    UpdateAttitudes(q1, handles);
    
end
guidata(hObject,handles);

function h = DrawCube()

M = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end

function h = RedrawCube(q,hin)

h = hin;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

%% TODO rotate M by using q
%Calculate the Rotation Matrix
R = MatrixFromQuat(q);
M = (R*M0')';

x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end


function axisX_Callback(hObject, eventdata, handles)
% hObject    handle to axisX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axisX as text
%        str2double(get(hObject,'String')) returns contents of axisX as a double


% --- Executes during object creation, after setting all properties.
function axisX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axisX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axisY_Callback(hObject, eventdata, handles)
% hObject    handle to axisY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axisY as text
%        str2double(get(hObject,'String')) returns contents of axisY as a double


% --- Executes during object creation, after setting all properties.
function axisY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axisY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axisZ_Callback(hObject, eventdata, handles)
% hObject    handle to axisZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axisZ as text
%        str2double(get(hObject,'String')) returns contents of axisZ as a double


% --- Executes during object creation, after setting all properties.
function axisZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axisZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axAngle_Callback(hObject, eventdata, handles)
% hObject    handle to axAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axAngle as text
%        str2double(get(hObject,'String')) returns contents of axAngle as a double


% --- Executes during object creation, after setting all properties.
function axAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angleA_Callback(hObject, eventdata, handles)
% hObject    handle to angleA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angleA as text
%        str2double(get(hObject,'String')) returns contents of angleA as a double


% --- Executes during object creation, after setting all properties.
function angleA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angleA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angleB_Callback(hObject, eventdata, handles)
% hObject    handle to angleB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angleB as text
%        str2double(get(hObject,'String')) returns contents of angleB as a double


% --- Executes during object creation, after setting all properties.
function angleB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angleB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angleC_Callback(hObject, eventdata, handles)
% hObject    handle to angleC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angleC as text
%        str2double(get(hObject,'String')) returns contents of angleC as a double


% --- Executes during object creation, after setting all properties.
function angleC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angleC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vecX_Callback(hObject, eventdata, handles)
% hObject    handle to vecX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vecX as text
%        str2double(get(hObject,'String')) returns contents of vecX as a double


% --- Executes during object creation, after setting all properties.
function vecX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vecX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vecY_Callback(hObject, eventdata, handles)
% hObject    handle to vecY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vecY as text
%        str2double(get(hObject,'String')) returns contents of vecY as a double


% --- Executes during object creation, after setting all properties.
function vecY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vecY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vecZ_Callback(hObject, eventdata, handles)
% hObject    handle to vecZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vecZ as text
%        str2double(get(hObject,'String')) returns contents of vecZ as a double


% --- Executes during object creation, after setting all properties.
function vecZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vecZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function beta_Callback(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a double


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gamma_Callback(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma as text
%        str2double(get(hObject,'String')) returns contents of gamma as a double


% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function q_a_Callback(hObject, eventdata, handles)
% hObject    handle to q_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_a as text
%        str2double(get(hObject,'String')) returns contents of q_a as a double


% --- Executes during object creation, after setting all properties.
function q_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_b_Callback(hObject, eventdata, handles)
% hObject    handle to q_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_b as text
%        str2double(get(hObject,'String')) returns contents of q_b as a double


% --- Executes during object creation, after setting all properties.
function q_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_c_Callback(hObject, eventdata, handles)
% hObject    handle to q_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_c as text
%        str2double(get(hObject,'String')) returns contents of q_c as a double


% --- Executes during object creation, after setting all properties.
function q_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_d_Callback(hObject, eventdata, handles)
% hObject    handle to q_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_d as text
%        str2double(get(hObject,'String')) returns contents of q_d as a double


% --- Executes during object creation, after setting all properties.
function q_d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Buttons

% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset q0 and m0
setGlobalQuat([1 0 0 0]');
setGlobalVector([0 0 0]');

q = getGlobalQuat();

% Update new attitudes
UpdateAttitudes(q, handles);
% Save data
setGlobalQuat(q);
% Redraw new Cube
handles.Cube = RedrawCube(q,handles.Cube);

% --- Executes on button press in quatButton.
function quatButton_Callback(hObject, eventdata, handles)
% hObject    handle to quatButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gets new quaternion
q = [str2double(get(handles.q_a,'String'));
str2double(get(handles.q_b,'String'));
str2double(get(handles.q_c,'String'));
str2double(get(handles.q_d,'String'))];
q = q/norm(q);

% Update new attitudes
UpdateAttitudes(q, handles);
% Save data
setGlobalQuat(q);
% Redraw new Cube
handles.Cube = RedrawCube(q,handles.Cube);

% --- Executes on button press in eulersButton.
function eulersButton_Callback(hObject, eventdata, handles)
% hObject    handle to eulersButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
u(1) = str2double(get(handles.axisX,'String'));
u(2) = str2double(get(handles.axisY,'String'));
u(3) = str2double(get(handles.axisZ,'String'));
a = str2double(get(handles.axAngle,'String'));

det_u = sqrt(u(1)^2+u(2)^2+u(3)^2);

%If the angle is 0 or the det of the vector is 0, then the Rotation Matrix
%is I.
if(a == 0 || det_u == 0)
    R = eye(3);
else
    R = Eaa2rotMat(deg2rad(a),u);
end

q = QuatFromMatrix(R);
q = q/norm(q);

% Update new attitudes
UpdateAttitudes(q, handles);
% Save data
setGlobalQuat(q);
% Redraw new Cube
handles.Cube = RedrawCube(q,handles.Cube);


% --- Executes on button press in anglesButton.
function anglesButton_Callback(hObject, eventdata, handles)
% hObject    handle to anglesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
alpha = str2double(get(handles.alpha,'String'));
beta =  str2double(get(handles.beta,'String'));
gamma = str2double(get(handles.gamma,'String'));

% Calculates the Rotation Matrix and the Quaternion
R = eAngles2rotM(alpha,beta,gamma);
q = QuatFromMatrix(R);
q = q/norm(q);
q = q';

% Update new attitudes
UpdateAttitudes(q, handles);
% Save data
setGlobalQuat(q);
% Redraw new Cube
handles.Cube = RedrawCube(q,handles.Cube);

% --- Executes on button press in rotationButton.
function rotationButton_Callback(hObject, eventdata, handles)
% hObject    handle to rotationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vX = str2double(get(handles.vecX,'String'));
vY = str2double(get(handles.vecY,'String'));
vZ = str2double(get(handles.vecZ,'String'));

v = [vX, vY, vZ]';
normV = norm(v);

% If the normal of the Vector is 0, there's no rotation
if(normV == 0)
    R = eye(3);
else
    C = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    R = eye(3) * cosd(normV) + ((1 - cosd(normV)) / normV.^ 2) * (v * v') + (sind(normV) / normV) * C;
end

% Calculates new quaternion
q = QuatFromMatrix(R);
q = q/norm(q);
q = q';

% Update new attitudes
UpdateAttitudes(q, handles);
% Save data
setGlobalQuat(q);
% Redraw new Cube
handles.Cube = RedrawCube(q,handles.Cube);

%%Functions

% Returns a 3D vector from a 2D point
function m = To2DPointsTo3D(x,y)
r = 70;

%Holroyd's arcball method
if x*x+y*y < 0.5*r*r
    z = abs(sqrt(r*r-(x*x)-(y*y))); 
elseif x*x + y*y >= 0.5*r*r
    z1 = r*((r*r)/(sqrt(x^2+y^2)));
    z2 = det((r*r)/(sqrt(x^2+y^2)));
    z = z1/z2;
    modulePoint = norm([x;y;z]); 
    x = r*x/modulePoint;
    y = r*y/modulePoint;
    z = r*z/modulePoint;
end
m=[x;y;z];

% Returns a quaternion from 2 unity vectors
function q = QuaternionFrom2Vec(u, v)
c = cross(u, v);
angle = acosd((v'*u)/(norm(v)*norm(u)));
c = c / norm(c);
q = [cosd(angle/2),sin(angle/2) * c']';

% Returns the Rotation Matrix from a quaternion
function R = MatrixFromQuat(q)
%If the quaternion fisrt number is 1 there's no rotation, therefore the R 
%equals to I.
if q(1) == 1
    R = eye(3);
else
    R = [2*(q(1)^2+q(2)^2)-1,    2*(q(2)*q(3)-q(1)*q(4)),     2*(q(2)*q(4)+q(1)*q(3));
        2*(q(2)*q(3)+q(1)*q(4)),  2*(q(1)^2+q(3)^2)-1,        2*(q(3)*q(4)-q(1)*q(2));
        2*(q(2)*q(4)-q(1)*q(3)),   2*(q(3)*q(4)+q(1)*q(2)),    2*(q(1)^2+q(4)^2)-1];
 
end

% Updates the new data
function UpdateAttitudes(q, handles)

R = MatrixFromQuat(q);
% Set Rotation Matrix
set(handles.m11, 'String', round(R(1,1),3));
set(handles.m12, 'String', round(R(1,2),3));
set(handles.m13, 'String', round(R(1,3),3));
set(handles.m21, 'String', round(R(2,1),3));
set(handles.m22, 'String', round(R(2,2),3));
set(handles.m23, 'String', round(R(2,3),3));
set(handles.m31, 'String', round(R(3,1),3));
set(handles.m32, 'String', round(R(3,2),3));
set(handles.m33, 'String', round(R(3,3),3));

% Set Euler's Axis & Angle
% Calculate the angle and the vector
[angle, v] = rotMat2Eaa(R);
% Set the Rotation Vector and Angle
set(handles.axAngle,'String', round(angle,3));
set(handles.axisX,'String', round(v(1),3));
set(handles.axisY,'String', round(v(2),3));
set(handles.axisZ,'String', round(v(3),3));

% Set Euler Angles
[alpha, beta, gamma] = rotM2eAngles(R);
set(handles.alpha, 'String', round(alpha,3));
set(handles.beta, 'String', round(beta,3));
set(handles.gamma, 'String', round(gamma,3));

% Set the Quaternion
q = QuatFromMatrix(R);
set(handles.q_a,'String', round(q(1),3));
set(handles.q_b,'String', round(q(2),3));
set(handles.q_c,'String', round(q(3),3));
set(handles.q_d,'String', round(q(4),3));

% Set Rotation Vector
u = angle * v;
set(handles.vecX, 'String', round(u(1),3));
set(handles.vecY, 'String', round(u(2),3));
set(handles.vecZ, 'String', round(u(3),3));

% Return a quaternion from the multiplication of 2 quaternions
function qk = MultQuat(q_a,q_b)

  qk(1) = q_a(1)*q_b(1) - ([q_a(2);q_a(3);q_a(4)]'*[q_b(2);q_b(3);q_b(4)]);
  qk(2) = q_a(1)*q_b(2) + q_a(2)*q_b(1) + q_a(3)*q_b(4) - q_a(4)*q_b(3);
  qk(3) = q_a(1)*q_b(3) - q_a(2)*q_b(4) + q_a(3)*q_b(1) + q_a(4)*q_b(2);
  qk(4) = q_a(1)*q_b(4) + q_a(2)*q_b(3) - q_a(3)*q_b(2) + q_a(4)*q_b(1);


% Returns a quaternion from a Rotation Matrix
function q = QuatFromMatrix(m)
q = [1 0 0 0]';
m_d = [m(1,1),m(2,2),m(3,3)];
% If the trace has different results, we use different formulas according
% to the value of the trace
if(trace(m) > 0)
    S = sqrt(trace(m) + 1) *2;
    q(1) = 0.25 * S;
    q(2) = (m(3,2) - m(2,3)) / S;
    q(3) = (m(1,3) - m(3,1)) / S;
    q(4) = (m(2,1) - m(1,2)) / S;
else
    if (m(1,1) == max(m_d))
        S = sqrt(1 + m(1,1) - m(2,2) - m(3,3)) *2;
        q(1) = (m(3,2) - m(2,3)) / S;
        q(2) = 0.25 * S;
        q(3) = (m(1,2) + m(2,1)) / S;
        q(4) = (m(1,3) + m(3,1)) / S;

    elseif (m(2,2) == max(m_d))
        S = sqrt(1 + m(2,2) - m(1,1) - m(3,3)) *2;
        q(1) = (m(1,3) - m(3,1)) / S;
        q(2) = (m(1,2) + m(2,1)) / S;
        q(3) = 0.25 * S;
        q(4) = (m(2,3) + m(3,2)) / S;
    elseif(m(3,3) == max(m_d))
        S = sqrt(1.0 + m(3,3) - m(1,1) - m(2,2)) * 2;
        q(1) = (m(2,1) - m(1,2)) / S;
        q(2) = (m(1,3) + m(3,1)) / S;
        q(3) = (m(2,3) + m(3,2)) / S;
        q(4) = 0.25 * S;
    end
end
