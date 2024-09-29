function varargout = PiezoScan_2Detectors_Altera(varargin)
% PIEZOSCAN_2DETECTORS_ALTERA MATLAB code for PiezoScan_2Detectors_Altera.fig
%      PIEZOSCAN_2DETECTORS_ALTERA, by itself, creates a new PIEZOSCAN_2DETECTORS_ALTERA or raises the existing
%      singleton*.
%
%      H = PIEZOSCAN_2DETECTORS_ALTERA returns the handle to a new PIEZOSCAN_2DETECTORS_ALTERA or the handle to
%      the existing singleton*.
%
%      PIEZOSCAN_2DETECTORS_ALTERA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIEZOSCAN_2DETECTORS_ALTERA.M with the given input arguments.
%
%      PIEZOSCAN_2DETECTORS_ALTERA('Property','Value',...) creates a new PIEZOSCAN_2DETECTORS_ALTERA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PiezoScan_2Detectors_Altera_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PiezoScan_2Detectors_Altera_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PiezoScan_2Detectors_Altera

% Last Modified by GUIDE v2.5 25-May-2018 15:25:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PiezoScan_2Detectors_Altera_OpeningFcn, ...
                   'gui_OutputFcn',  @PiezoScan_2Detectors_Altera_OutputFcn, ...
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


% --- Executes just before PiezoScan_2Detectors_Altera is made visible.
function PiezoScan_2Detectors_Altera_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PiezoScan_2Detectors_Altera (see VARARGIN)

% Choose default command line output for PiezoScan_2Detectors_Altera
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PiezoScan_2Detectors_Altera wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clc;
% Setting initial value for Start voltage (1st left) box
set(handles.Vi_edit8,'Value', 1);
set(handles.Vi_edit8,'string',num2str(get(handles.Vi_edit8,'Value')));
set(handles.Vi_edit8,'Fontsize',20,'FontName','Times New Roman')

% Setting initial value for End voltage (2nd left) box
set(handles.Vf_edit9,'Value', 8);
set(handles.Vf_edit9,'string',num2str(get(handles.Vf_edit9,'Value')));
set(handles.Vf_edit9,'Fontsize',20,'FontName','Times New Roman')

% Setting initial values for the Increment (3rd left) box
set(handles.Inc_edit10,'Value', 0.05);
set(handles.Inc_edit10,'string',num2str(get(handles.Inc_edit10,'Value')));
set(handles.Inc_edit10,'Fontsize',20,'FontName','Times New Roman')

% Figure adjustments
screensize = get( groot, 'Screensize' ); % getting screen size
set(handles.figure1,'Name','Quantum Eraser','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
pause(1);

% axes('position',[left bottom width height])
% Credit Behzad Khajavi
axcredit=axes('position',[0.87 0.05 0.1 0.05],'visible','off');
axcredit.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
descr2 = 'by: Behzad Khajavi';
title(axcredit,descr2,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')

%-----------------------------


% --- Outputs from this function are returned to the command line.
function varargout = PiezoScan_2Detectors_Altera_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in Clearplotbutton.
function Clearplotbutton_Callback(~, ~, handles)
% hObject    handle to Clearplotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clearing axes (don't want to see the preious data points)
axes(handles.axes1)
cla reset % Do a complete and total reset of the axes.
axes(handles.axes2)
cla reset % Do a complete and total reset of the axes.
axes(handles.axes3)
cla reset % Do a complete and total reset of the axes.
set(handles.accidentalsedit6,'String','')
%%%

% --- Executes on button press in Run.
function Run_Callback(hObject, ~, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;
timeinterval=1; % time interval for each measurement in seconds
% deltat=40e-9; % pulse width to calculate accidental coincidences
myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
cleandatadimension=41*(timeinterval*10);
myData=zeros(myDatadimension,1);
time=0;
format compact
set(hObject,'String','STOP','Foregroundcolor','r','FontWeight','Bold','FontName','Times New Roman')
StartVoltage = str2double(get(handles.Vi_edit8,'String'));
EndVoltage = str2double(get(handles.Vf_edit9,'String'));
Increment = str2double(get(handles.Inc_edit10,'String'));
numsteps = round((EndVoltage - StartVoltage)/Increment,0);

% Saving data preparation
clockt=fix(clock); % saving the initial date/time into a matrix
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
% Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
% Start the excel file to write the gradual results
xl1range1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'V','A','B','AB','Accidenals'}; 
xlswrite('QuantumEraser.xlsx',Header1,Sheet1,xl1range1)
% End of writing the header for the "Gradual Results" sheet in excel file.
% setting axes properties
% Clear Axes 1
axes(handles.axes1)
cla reset % Do a complete and total reset of the axes.
grid(handles.axes1,'on');
hold(handles.axes1,'on');
handles.axes1.XLim = [0 inf];
handles.axes1.YLim = [0 inf];
% Clear Axes 2
axes(handles.axes2)
cla reset % Do a complete and total reset of the axes.
grid(handles.axes2,'on');
hold(handles.axes2,'on');
handles.axes2.XLim = [0 inf];
handles.axes2.YLim = [0 inf];
% Clear Axes 3
axes(handles.axes3)
cla reset % Do a complete and total reset of the axes.
grid(handles.axes3,'on');
hold(handles.axes3,'on');
handles.axes3.XLim = [0 inf];
handles.axes3.YLim = [0 inf];
%%%
% Opening counter port
counterportnum=get(handles.comport,'String');
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
fopen(scounter);  % open the Counter serial port before the inner loop begins.
% opening Arduino port
Arduinoportnum = get(handles.Arduino_edit12,'String');
sArduino = serial(Arduinoportnum,'BaudRate',115200);
fopen(sArduino);  % open the Arduino serial port before the inner loop begins.

%****************************************************************************
%% Loop
for steps = 1 : numsteps
    % Setting the value for current voltage
    set(handles.CurrentV_edit11,'string',num2str(StartVoltage + steps*Increment));
    set(handles.CurrentV_edit11,'Fontsize',20,'FontName','Times New Roman')
%   
    % Seding Voltage to Arduino
    VtoArduino = num2str(StartVoltage + steps*Increment);
    fprintf(sArduino,VtoArduino);    
    
    % Serial data accessing   
    for i=1:timeinterval
         myData1 = fread(scounter,512,'uint8'); % reading # of bytes
         myData(1,(i-1)*512+1:i*512) = myData1';
    end 
%     myData=transpose(myData); % transposing myData matrix
    
    % finding terminationbyte if the 41th element of myData is not 255
    tbi=0;
    if myData(1,41)~=255
        for i=1:40
           if myData(1,i)==255
               terminationbyteindex=i;
           end
        end 
        tbi=terminationbyteindex;
    end 
    cleandata=myData(1,tbi+1:tbi+cleandatadimension);
    numofcounts=zeros(1,8);
    CD=cleandata; % just to use a shorthand notation CD
    kmax=timeinterval*10; % loop repetation numner for each counter
    L=0;
    for i=1:8
        j=0;
        for k=1:kmax   
            numofcounts(1,i)=numofcounts(1,i)+CD(1,1+j+L)+2^7*CD(1,2+j+L)+2^14*CD(1,3+j+L)+2^21*CD(1,4+j+L)+2^28*CD(1,5+j+L);     
            j=j+41; % the corresponding figure after a tenth of a second
        end
        L=L+5; % next counter partition starts at the next 5th byte
    end 
    numofcountsA=numofcounts(1,1);
    numofcountsB=numofcounts(1,2);
    numofcountsAB=numofcounts(1,5);
     %% Calculating and then Showing Accidentals
    deltat=str2double(get(handles.Deltatedit7,'String'));
    acc=numofcountsA*numofcountsB*deltat*0.000000001;
    
%% plotting the data points on different subplots
    time = time + timeinterval; % x-axis (time) in seconds
    % plotting A
    axes(handles.axes1);
    plot(time,numofcountsA,'. b','MarkerSize',20);
    descriptionA = num2str(numofcountsA);
    title(descriptionA,'FontWeight','bold','FontSize',40,'FontName','Times New Roman')
    set(get(gca,'title'),'background','y')
    xlabel({'time (Sec)','',''},'FontWeight','bold','FontSize',16,'FontName','Times New Roman');
    ylabel('Singles A','FontWeight','bold','FontSize',25,'FontName','Times New Roman');
    %%%%%%%%%%%%%%%%%%%%%%
    % plotting B
    axes(handles.axes2);
    plot(time,numofcountsB,'. b','MarkerSize',20);
    descriptionB = num2str(numofcountsB);
    title(descriptionB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman')
    set(get(gca,'title'),'background','y')
    xlabel({'time (Sec)','',''},'FontWeight','bold','FontSize',14,'FontName','Times New Roman');
    ylabel('Singles B','FontWeight','bold','FontSize',25,'FontName','Times New Roman');
    %%%%%%%%%%%%%%%%%%%%%%
    % plotting AB    
    axes(handles.axes3);
    plot(time,numofcountsAB,'. b','MarkerSize',20);
    descriptionAB = num2str(numofcountsAB);
    title(descriptionAB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman')
    set(get(gca,'title'),'background','y')
    set(handles.accidentalsedit6,'String',num2str(acc))%displays accidentals (here to be simultaneously shown)
    drawnow
    xlabel({'time (Sec)','',''},'FontWeight','bold','FontSize',14,'FontName','Times New Roman');
    ylabel('Coinc. AB','FontWeight','bold','FontSize',25,'FontName','Times New Roman');
    %%%%%%%%%%%%
    
    % Storing Data in Excel file
    countt = num2str(steps+1);% to go two lines further (count+1)in excel (because of the header)
    xl1range=strcat('A',countt);
    xlswrite('QuantumEraser.xlsx',[StartVoltage + steps*Increment,numofcountsA,numofcountsB,numofcountsAB,acc],Sheet1,xl1range);
%     end
end
% assignin('base','time1',time)
% time=get(time1,'Value');
fclose(scounter);  % close the serial port after the inner loop ends.
clear scounter;
fclose(sArduino);  % close the serial port after the inner loop ends.
clear sArduino;
set(hObject,'String','RUN','Foregroundcolor',[0 0.5 0],'FontWeight','Bold','FontName','Times New Roman')

function comport_Callback(~, eventdata, handles)
% hObject    handle to comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comport as text
%        str2double(get(hObject,'String')) returns contents of comport as a double


% --- Executes during object creation, after setting all properties.
function comport_CreateFcn(hObject, ~, ~)
% hObject    handle to comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function accidentalsedit6_Callback(hObject, eventdata, handles)
% hObject    handle to accidentalsedit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accidentalsedit6 as text
%        str2double(get(hObject,'String')) returns contents of accidentalsedit6 as a double


% --- Executes during object creation, after setting all properties.
function accidentalsedit6_CreateFcn(hObject, ~, ~)
% hObject    handle to accidentalsedit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Deltatedit7_Callback(hObject, eventdata, handles)
% hObject    handle to Deltatedit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Deltatedit7 as text
%        str2double(get(hObject,'String')) returns contents of Deltatedit7 as a double




% --- Executes during object creation, after setting all properties.
function Deltatedit7_CreateFcn(hObject, ~, ~)
% hObject    handle to Deltatedit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Vi_edit8_Callback(~, eventdata, handles)
% hObject    handle to Vi_edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vi_edit8 as text
%        str2double(get(hObject,'String')) returns contents of Vi_edit8 as a double


% --- Executes during object creation, after setting all properties.
function Vi_edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vi_edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Vf_edit9_Callback(hObject, eventdata, handles)
% hObject    handle to Vf_edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vf_edit9 as text
%        str2double(get(hObject,'String')) returns contents of Vf_edit9 as a double


% --- Executes during object creation, after setting all properties.
function Vf_edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vf_edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Inc_edit10_Callback(hObject, eventdata, handles)
% hObject    handle to Inc_edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Inc_edit10 as text
%        str2double(get(hObject,'String')) returns contents of Inc_edit10 as a double


% --- Executes during object creation, after setting all properties.
function Inc_edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inc_edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CurrentV_edit11_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentV_edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentV_edit11 as text
%        str2double(get(hObject,'String')) returns contents of CurrentV_edit11 as a double


% --- Executes during object creation, after setting all properties.
function CurrentV_edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentV_edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Arduino_edit12_Callback(hObject, eventdata, handles)
% hObject    handle to Arduino_edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Arduino_edit12 as text
%        str2double(get(hObject,'String')) returns contents of Arduino_edit12 as a double


% --- Executes during object creation, after setting all properties.
function Arduino_edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Arduino_edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pause_button3.
function pause_button3_Callback(hObject, eventdata, handles)
% hObject    handle to pause_button3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
