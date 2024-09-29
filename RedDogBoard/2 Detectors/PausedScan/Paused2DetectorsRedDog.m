

%% Paused2DetectorCD48. Data aquisition program with Red Dog CD48 board
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This program was originally written by Behzad Khajavi for the Altera DE2%
% board on July 2017. This work was done at Colgate University.           %
% Modified by Kiko Galvez to read Red Dog board CD48 in 2021.             %
%
% This program used the output of 2 detectors and takes data points step  %
% by step, where in between steps the user can make changes to the        %
% apparatus. For example, it can be used for a Bell test. %
% The output is put in an Excel file.                                     %
%                                                                         %
%*************************************************************************%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;
format compact
%% Dialog window
% 
%prompt = {'Enter the COM# of the Counter:','time interval','Name of file = '};
prompt = {'Enter # of paused steps:','time interval in s','Counter COM port #: ','Excel file name'};
dlg_title = 'Paused Scan Inputs';
defaultans = {'3','1','COM20','Paused2'};
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
comportnum = userinput{3};
CD48serial = serial(comportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
timeinterval = str2double(userinput{2}); % time interval for each measurement in seconds
nams = userinput{4}; % file name
datanam = nams;  %'TM11805Normal3632'; % data name
dateexp = date; % date
numofstates = str2double(userinput{1}); % # of states/steps in the data
numofmeasurements = 1; % # of measurements per each stat.e Not used here
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = numofmeasurements;
timeaxislimit = numofstates*numofmeasurements*timeinterval;
deltat = 20e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; pstep=zeros(loop);statepause=0;
%% Setting up an Excel output file
%
clockt = fix(clock); % saving the initial date/time into a matrix
% myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds
% cleandatadimension=41*(timeinterval*10);
% myData=zeros(myDatadimension,1);
% resultsmatrix=zeros(numofmeasurements,8);
% erasingmatrix(1:(numofmeasurements+1)*numofstates+3,1:8)="";% matrix defined to erasethe excel sheet
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
% Start the excel file to write the gradual results
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'A','B','AB','Accidenals'};
xlswrite(datanam,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%-------------------------------------
% Start the excel file to write the "Total Results" sheet
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'A','B','AB','Accidentals'};
xl2range1='A1';
xlswrite(datanam,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%% Figure adjustments
%
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Paused Scan 2 Detectors','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
% hold on
%_____________________________________
% Axes Properties
% axes('position',[left bottom width height])
% Axis for Header
axheader=axes('position',[0.45 0.75 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
ax1 = axes('position',[0.08 0.25 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'background','y')
%ax1.XLim = [0 numofstates*timeinterval+1];
ax1.XLim = [0 numofstates+1];
ax1.XLabel.String  = 'Step';
% ax1.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 20; ax1.XLabel.FontName = 'TimesNewRoman';
% set(ax1,'XTickL',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17],{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
%set(ax1,'XTick',1:1*timeinterval:numofstates*timeinterval)
set(ax1,'XTick',1:numofstates)
%set(ax1,'XTicklabel',{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'});
ax1.YLabel.String  = 'Singles A';
ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 20;ax1.YLabel.FontName = 'TimesNewRoman';
ax1.YLim = [0 inf];
grid(ax1,'on');
hold(ax1,'on')
%____________________________________

ax2 = axes('position',[0.40 0.25 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'background','y')
ax2.XLim=[0 numofstates+1];
ax2.XLabel.String  = 'Step';
% ax2.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 20;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',1:numofstates)
%set(ax2,'XTicklabel',{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 20;ax2.YLabel.FontName = 'TimesNewRoman';
ax2.YLim = [0 inf];
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
ax3=axes('position',[0.72 0.25 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
ax3.XLim=[0 numofstates+1];
ax3.XLabel.String  = 'Step';
% ax3.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 20;ax3.XLabel.FontName = 'TimesNewRoman';
set(ax3,'XTick',1:numofstates)
%set(ax3,'XTicklabel',{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
ax3.YLabel.String  = 'Coincidences AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 20;ax3.YLabel.FontName = 'TimesNewRoman';
ax3.YLim=[0 inf];
grid(ax3,'on')
hold(ax3,'on')
%___
%****************************************************************************
%% Programming the Coincidence Detector Board
%
fopen(CD48serial);  % open the serial port
%fprintf(CD48serial,'%s','v'); %reset to firmware
pause(0.1)
fprintf(CD48serial,'%s','T');
fprintf(CD48serial,'%s','S01000'); % counter 0
fprintf(CD48serial,'%s','S10100'); % counter 1
fprintf(CD48serial,'%s','S20010'); % counter 2
fprintf(CD48serial,'%s','S30001'); % counter 3
fprintf(CD48serial,'%s','S41100'); % counter 4
fprintf(CD48serial,'%s','S51010'); % counter 5
fprintf(CD48serial,'%s','S61110'); % counter 6 - modified for ABC coincidence
fprintf(CD48serial,'%s','S71001'); % counter 7
fprintf(CD48serial,'%s','L050'); % pulse threshold
fprintf(CD48serial,'%s','z'); %50 ohm impedance
%timeintervals = '2'; % time interval for each measurement in seconds
timeinms=num2str(floor(timeinterval*1000)); % time interval in ms
disp(timeinterval);
disp(timeinms);
if timeinterval < 1
    timetobox = strcat('r','00',timeinms); % set up repeat command (counter accumulation time) to time interval
elseif timeinterval < 10
    timetobox = strcat('r','0',timeinms); % set up repeat command (counter accumulation time) to time interval
else
    timetobox = strcat('r',timeinms); % set up repeat command (counter accumulation time) to time interval
end
disp(timetobox);
fprintf(CD48serial,'%s','R'); % Repeat off
pause(0.1)
fprintf(CD48serial,'%s',timetobox); % program the repeat time in seconds
pause(0.1)
fprintf(CD48serial,'%s','R'); % Repeat on
%fprintf(CD48serial,'%s','r02000'); % program the repeat time in seconds
pause(0.1)
flushinput(CD48serial)
fprintf(CD48serial,'%s','P');
pause(0.1);
Bytes = CD48serial.BytesAvailable;
Report = char(fread(CD48serial,Bytes)');
disp(Report);
if strcmp(strcat(Report(1,86:88)),'off') % turns repeat on if off
    fprintf(CD48serial,'%s','R');
    disp('Repeat was off I turned it on')
    fprintf(CD48serial,'%s','P');
    pause(0.1)
    Bytes = CD48serial.BytesAvailable;
    Report = char(fread(CD48serial,Bytes)');
    disp(Report);
end
flushinput(CD48serial) % to fix bug with 1st data point
fprintf(CD48serial,'%s','c');
pause(timeinterval)
flushinput(CD48serial)
%% The Loop
%
for stateindexi=1:numofstates
    % header for each state measurement results in excel file "Gradual Results"
%     prompt = {'Make a change and click OK to continue'};
%     dlg_title = 'Pause to change';
%     descripion = strcat('State # ',' ',num2str(stateindexi+1),':');
%     defaultans = {[descripion,' Do not enter anything here.']};
%     if stateindexi==numofstates
%         defaultans = {'Last Data point'};
%     end
%     answer = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
%     pause(1);
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    stateindexit=num2str(stateindexi);
    stateheader={'state #',stateindexit};
    xlswrite(datanam,stateheader,Sheet1,xlrange2);
    % header for each state measurement results in excel file "Total Results"
    countt=num2str((stateindexi-1)*2+2);
    xl2range2=strcat('A',countt);
    xlswrite(datanam,stateheader,Sheet2,xl2range2);
    flushinput(CD48serial)
%     datacounts = zeros(9,1);
    pause(1);
    datacounts(:,1)=fscanf(CD48serial,'%d\n');
    flushinput(CD48serial)
    numofcountsA = datacounts(1,1);
    numofcountsB = datacounts(2,1);
    numofcountsAB = datacounts(5,1);
    accidentals=numofcountsA*numofcountsB*deltat/timeinterval;
    accidentalsstr=num2str(round(accidentals));    
    %% Plotting the data points on different subplots
%     pstep(count) = (stateindexi-1)*numofmeasurements*timeinterval+count*timeinterval; % x-axis (time) in seconds
        pstep(count) = (stateindexi-1)*numofmeasurements+count; % x-axis (time) in seconds
    % plotting A
    plot(ax1,pstep(count),numofcountsA,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B
    plot(ax2,pstep(count),numofcountsB,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AB
    plot(ax3,pstep(count),numofcountsAB,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % Drawing Y-data of the three plots (A, B, AB) at the same time
    descriptionA = num2str(numofcountsA);
    title(ax1,descriptionA,'FontWeight','bold','FontSize',40,'FontName','Times New Roman','color','b','background','w');
    
    descriptionB = num2str(numofcountsB);
    title(ax2,descriptionB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman','color','b','background','w');
    
    descriptionAB = num2str(numofcountsAB);
    title(ax3,descriptionAB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman','color','b','background','w');
    
    descr = ['Paused Scan: ','Step # ',num2str(stateindexi),'/',num2str(numofstates),', Time per step = ',num2str(timeinterval),' s'];
    title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w')
    %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
    axcredit=axes('position',[0.75 0.03 0.1 0.05],'visible','off');
    axcredit.Title.Visible = 'on';
    set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
    descr2 = strcat('Calculated accidentals =  ',accidentalsstr);
    title(axcredit,descr2,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
    drawnow  
    %----------------------------------------------------------------------  
    %% Storing Data in the resultsmatrix and finally in xlsx file
%    
    resultsmatrix(count,1)=numofcountsA;
    resultsmatrix(count,2)=numofcountsB;
    resultsmatrix(count,3)=numofcountsAB;
    %     resultsmatrix(count,4)=numofcounts(1,4);
    %     resultsmatrix(count,5)=numofcounts(1,5);
    %     resultsmatrix(count,6)=numofcounts(1,6);
    %     resultsmatrix(count,7)=numofcounts(1,7);
    %     resultsmatrix(count,8)=numofcounts(1,8);
    %________________________________________________________________________
    % writing results gradually into the "Gradual Results' sheet in excel
    % file
    warning('off','MATLAB:xlswrite:AddSheet');
    % to suppress the warning when the sheet name is not in excel file.
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
    xlswrite(datanam,[resultsmatrix(count,1:3),accidentalsindividual],Sheet1,xlrange2);
    count = count +1;
    countt=num2str((stateindexi-1)*2+3);
    xl2range2=strcat('A',countt);
    accidentalstotal=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
    xlswrite(datanam,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),accidentalstotal],Sheet2,xl2range2)
    pause(statepause);
    count=1;
        % Prompt User to have a Pause between the states
    prompt = {'Make a change and click OK to continue'};
    dlg_title = 'Pause to change';
    descripion = strcat('State # ',' ',num2str(stateindexi+1),':');
    defaultans = {[descripion,' Do not enter anything here.']};
    if stateindexi==numofstates
        defaultans = {'Done Taking data'};
    end
    answer = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
    pause(1);
end
fclose(CD48serial);  % close the serial port after the inner loop ends.
pause(2)
clear s;
%% writing date and time of the results into the excle files
%
timeheader={'year','month','day','hour','minute','seconds'};
% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite(datanam,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(datanam,clockt,Sheet1,xlrange2)
% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
xlswrite(datanam,timeheader,Sheet2,xlrangetimeheader)
xlswrite(datanam,clockt,Sheet2,xlrangetime)
% save to "resultsmatrix.txt" file
%save('Tomographyresults.txt','resultsmatrix','-ascii')

