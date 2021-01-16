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

function setGlobalVector(val)
global v
v = val;

function r = getGlobalVector
global v
r = v;

function setGlobalQuat(val)
global q
q = val;

function r = getGlobalQuat
global q
r = q;

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

function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.cube,'xlim');
ylim = get(handles.cube,'ylim');
mousepos=get(handles.cube,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    
    m1 = To2DPointsTo3D(xmouse,ymouse);
    
    m0 = getGlobalVector();
    q0 = getGlobalQuat();
    
     %% Quaternion from two vectors
    axis = cross(m0, m1); % Obtain axis
    angle = acosd((m1'*m0)/(norm(m1)*norm(m0))); % Obtain angle
    axis = axis / norm(axis);
    q1 = [cosd(angle/2),sin(angle/2) * axis']';
    %q1 = QuaternionFrom2Vec(m0,m1);
    q1 = q1/norm(q1);
    q1 = MultQuat(q0,q1);
 
    R = MatrixFromQuat(q1);
    
    setGlobalVector(m1);
    setGlobalQuat(q1);
    
    handles.Cube = RedrawCube(R,handles.Cube);
    UpdateAttitudes(R, handles);
    
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

function h = RedrawCube(R,hin)

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


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.q_a.String = 1;
handles.q_b.String = 0;
handles.q_c.String = 0;
handles.q_d.String = 0;
handles.axisX.String = 0;
handles.axisY.String = 0;
handles.axisZ.String = 0;
handles.axAngle.String = 0;
handles.vecX.String = 0;
handles.vecY.String = 0;
handles.vecZ.String = 0;
handles.alpha.String = 0;
handles.beta.String = 0;
handles.gamma.String = 0;



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


% --- Executes on button press in quatButton.
function quatButton_Callback(hObject, eventdata, handles)
% hObject    handle to quatButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q(1) = str2double(get(handles.q_a,'String'));
q(2) = str2double(get(handles.q_b,'String'));
q(3) = str2double(get(handles.q_c,'String'));
q(4) = str2double(get(handles.q_d,'String'));
q = q';
q = q/norm(q);

R = MatrixFromQuat(q);

SetGlobalQuat(UpdateAttitudes(R, handles));

handles.cube = RedrawCube(R, handles.cube);


% --- Executes on button press in eulersButton.
function eulersButton_Callback(hObject, eventdata, handles)
% hObject    handle to eulersButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.axisX,'String');
get(handles.axisY,'String');
get(handles.axisZ,'String');
get(handles.axAngle,'String');

% --- Executes on button press in anglesButton.
function anglesButton_Callback(hObject, eventdata, handles)
% hObject    handle to anglesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.alpha,'String');
get(handles.beta,'String');
get(handles.gamma,'String');


% --- Executes on button press in rotationButton.
function rotationButton_Callback(hObject, eventdata, handles)
% hObject    handle to rotationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.vecX,'String');
get(handles.vecY,'String');
get(handles.vecZ,'String');

function m = To2DPointsTo3D(x,y)
r = 70;

if x*x+y*y < 0.5*r*r
    z = abs(sqrt(r*r-(x*x)-(y*y))); 
else
    z = (r*r)/(2*sqrt(x*x+y*y));
    modulePoint = norm([x;y;z]); 
    x = r*x/modulePoint;
    y = r*y/modulePoint;
    z = r*z/modulePoint;
end
m=[x;y;z];

function q = QuaternionFrom2Vec(u, v)
angle = acos((v'*u)/(det(v)*det(u)));
c = cross(u, v);
m = sin(angle/2)*(c*det(c));
q = [cos(angle/2);m(1);m(2);m(3)];
%t = quat(dot(u, v), w.x, w.y, w.z);
%t.w = length(t) + t.w;
%q = (t0+t1+t2+t3)/sqrt(t0^2+t1^2+t2^2+t3^2);

function R = MatrixFromQuat(q)
%If the quaternion fisrt number is 1 there's no rotation, therefore the R 
%equals to I.
R = [q(1)^2+q(2)^2-q(3)^2-q(4)^2, 2*q(2)*q(3)-2*q(1)*q(4), 2*q(2)*q(4)+2*q(1)*q(3);
    2*q(2)*q(3)+2*q(1)*q(4),    q(1)^2-q(2)^2+q(3)^2-q(4)^2, 2*q(3)*q(4)-2*q(1)*q(2);
    2*q(2)*q(4)-2*q(1)*q(3),    2*q(3)*q(4)+2*q(1)*q(2),    q(1)^2-q(2)^2-q(3)^2+q(4)^2];
%if q(1) == 1
 %   R = eye(3);
%else
    
%R= {1-2*q(3)^2-2*q(4)^2, 2*q(2)*q(3)-2*q(4)*q(1), 2*q(2)*q(4)+2*q(3)*q(1);
 %   2*q(2)*q(3)+2*q(4)*q(1), 1-2*q(2)^2-2*q(4)^2, 2*q(3)*q(4)-2*q(2)*q(1);
  %  2*q(2)*q(4)-2*q(3)*q(1), 2*q(3)*q(4)+2*q(2)*q(1), 1-w*q(2)^2-w*q(3)^2};
%R = R/norm(R);
 
%end

function UpdateAttitudes(q, handles)

% Calculate Rotation Matrix
R = MatrixFromQuat(q);

% Set the Quaternion
set(handles.q_a,'String', num2str(q(1)));
set(handles.q_b,'String', num2str(q(2)));
set(handles.q_c,'String', num2str(q(3)));
set(handles.q_d,'String', num2str(q(4)));

% Set Euler's Axis & Angle
% Calculate the angle and the vector
[angle, v] = rotMat2Eaa(R);
% Calculate the Rotation Vector
u = v * angle;
set(handles.axisX,'String', num2str(v(1)));
set(handles.axisY,'String', num2str(v(2)));
set(handles.axisZ,'String', num2str(v(3)));
set(handles.axAngle,'String', num2str(angle));

% Set Euler Angles
[alpha, beta, gamma] = rotM2eAngles(R);
set(handles.alpha, 'String', num2str(alpha));
set(handles.beta, 'String', num2str(beta));
set(handles.gamma, 'String', num2str(gamma));

% Set Rotation Vector
set(handles.vecX, 'String', num2str(u(1)));
set(handles.vecX, 'String', num2str(u(2)));
set(handles.vecX, 'String', num2str(u(3)));

% Set Rotation Matrix
set(handles.m11, 'String', num2str(R(1,1)));
set(handles.m12, 'String', num2str(R(1,2)));
set(handles.m13, 'String', num2str(R(1,3)));
set(handles.m21, 'String', num2str(R(2,1)));
set(handles.m22, 'String', num2str(R(2,2)));
set(handles.m23, 'String', num2str(R(2,3)));
set(handles.m31, 'String', num2str(R(3,1)));
set(handles.m32, 'String', num2str(R(3,2)));
set(handles.m33, 'String', num2str(R(3,3)));

function qk = MultQuat(q1,q2)
%MULTQUAT Summary of this function goes here
%   Detailed explanation goes here
%   Set Quaternion C = A * B
  qk(1) = q1(1)*q2(1)-([q1(2);q1(3);q1(4)]'*[q2(2);q2(3);q2(4)]);
  qk(2:4) = q1(1)*[q2(2);q2(3);q2(4)]+q2(1)*[q1(2);q1(3);q1(4)]+cross([q1(2);q1(3);q1(4)],[q2(2);q2(3);q2(4)]);
    %qk(1) = q_a(1,1)*q_b(1,1) - q_a(1,2)*q_b(1,2) - q_a(1,3)*q_b(1,3) - q_a(1,4)*q_b(1,4);
    %qk(2) = q_a(1,1)*q_b(1,2) + q_a(1,2)*q_b(1,1) + q_a(1,3)*q_b(1,4) - q_a(1,4)*q_b(1,3);
    %qk(3) = q_a(1,1)*q_b(1,3) - q_a(1,2)*q_b(1,4) + q_a(1,3)*q_b(1,1) + q_a(1,4)*q_b(1,2);
    %qk(4) = q_a(1,1)*q_b(1,4) + q_a(1,2)*q_b(1,3) - q_a(1,3)*q_b(1,2) + q_a(1,4)*q_b(1,1);
