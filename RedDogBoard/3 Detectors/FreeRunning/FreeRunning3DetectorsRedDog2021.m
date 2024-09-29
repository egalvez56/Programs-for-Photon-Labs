%% ContinuousCounting2DetetorCD482021
%
% This program was first written by Behzad Khajavi based on a similar
% program written for the Altera DE2 board.
% Kiko Galvez modified it in June-July 2021.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This program was originally written by Behzad Khajavi for the Altera DE2%
% board on July 2017. This work was done at Colgate University.           %
% Modified by Kiko Galvez to read Red Dog board CD48 in 2021.             %
%
% This program uses the output of 2 detectors and takes data points step  %
% by step%                                                                         %
%*************************************************************************%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;
format compact
prompt = {'Counter COM port #: ','Time interval in s','Number of Steps'};
dlg_title = 'Continuous Countint Scan Inputs';
defaultans = {'COM19','1','200'};
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
comportnum = userinput{1};
CD48serial = serial(comportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
timeintervals = userinput{2}; % time interval for each measurement in seconds
timeinterval = str2double(timeintervals); % time interval for each measurement in seconds
numstepsstr=userinput{3};
numofstates=str2double(numstepsstr);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deltat = 20e-9; % pulse width to calculate accidental coincidences
%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Free-running scan','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
%_____________________________________
% Axes Properties
% Axis for Header
axheader=axes('position',[0.45 0.88 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
ax1 = axes('position',[0.08 0.57 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'background','y')
ax1.XLim = [0 inf];
ax1.XLabel.String  = 'Step';
ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 14; ax1.XLabel.FontName = 'TimesNewRoman';
ax1.YLabel.String  = 'Singles A';
ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 20;ax1.YLabel.FontName = 'TimesNewRoman';
ax1.YLim = [0 inf];
grid(ax1,'on');
hold(ax1,'on')
%____________________________________
ax2 = axes('position',[0.40 0.57 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'background','y')
ax2.XLim=[0 inf];
ax2.XLabel.String  = 'Step';
ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 20;ax2.YLabel.FontName = 'TimesNewRoman';
ax2.YLim = [0 inf];
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
ax3=axes('position',[0.72 0.57 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
ax3.XLim=[0 inf];
ax3.XLabel.String  = 'Step';
ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman';
ax3.YLabel.String  = 'Singles C';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 20;ax3.YLabel.FontName = 'TimesNewRoman';
ax3.YLim=[0 inf];
grid(ax3,'on')
hold(ax3,'on')
%___
% Coinc.AB axes
ax4=axes('position',[0.08 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
ax4.XLim=[0 inf];
ax4.YLim = [0 inf];
ax4.XLabel.String  = 'Step';ax4.XLabel.FontWeight = 'bold';
ax4.XLabel.FontSize = 14;ax4.XLabel.FontName = 'TimesNewRoman';
% set(ax3,'XTick',1:timeinterval:timeaxislimit*timeinterval)
%set(ax4,'XTick',1:1:timeaxislimit)
ax4.YLabel.String  = 'Coincidences AB';ax4.YLabel.FontWeight = 'bold';
ax4.YLabel.FontSize = 20;ax4.YLabel.FontName = 'TimesNewRoman';
grid(ax4,'on')
hold(ax4,'on')
%_____________________________
% Coinc.AC axes
ax5=axes('position',[0.4 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax5,'title'),'background','y')
ax5.XLim=[0 inf];
ax5.YLim = [0 inf];
ax5.XLabel.String  = 'Step';ax5.XLabel.FontWeight = 'bold';
ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
% set(ax5,'XTick',1:timeinterval:timeaxislimit*timeinterval)
%set(ax5,'XTick',1:1:timeaxislimit)

ax5.YLabel.String  = 'Coincidences AC';ax5.YLabel.FontWeight = 'bold';
ax5.YLabel.FontSize = 20;ax5.YLabel.FontName = 'TimesNewRoman';
grid(ax5,'on')
hold(ax5,'on')
%____________________________________
% Coinc.ABC axes
ax6=axes('position',[0.72 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax6,'title'),'background','y')
ax6.XLim=[0 inf];
ax6.YLim = [0 inf];
ax6.XLabel.String  = 'Step';ax6.XLabel.FontWeight = 'bold';
ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
% set(ax6,'XTick',1:timeinterval:timeaxislimit*timeinterval)
%set(ax6,'XTick',1:1:timeaxislimit)

ax6.YLabel.String  = 'Coincidences ABC';ax6.YLabel.FontWeight = 'bold';
ax6.YLabel.FontSize = 20;ax6.YLabel.FontName = 'TimesNewRoman';
grid(ax6,'on')
hold(ax6,'on')
%****************************************************************************
%% Programming the Coincidence Detector Board
%
fopen(CD48serial);  % open the serial port
%fprintf(CD48serial,'%s','v'); %reset to firmware
pause(0.1)
fprintf(CD48serial,'%s','T');
fprintf(CD48serial,'%s','S01000'); % counter 1 A
fprintf(CD48serial,'%s','S10100'); % counter 2 B
fprintf(CD48serial,'%s','S20001'); % counter 3 D
fprintf(CD48serial,'%s','S30010'); % counter 4 C
fprintf(CD48serial,'%s','S41100'); % counter 5 AB
fprintf(CD48serial,'%s','S51010'); % counter 6 AC
fprintf(CD48serial,'%s','S61110'); % counter 7 ABC
fprintf(CD48serial,'%s','S71001'); % counter 8 AD
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
for stateindexi=1:numofstates%     dlg_title = 'Pause to Change';
%    datacounts = zeros(9,1);
    pause(timeinterval)
    datacounts(:,1)=fscanf(CD48serial,'%d\n');
    flushinput(CD48serial);
    stateindexs=num2str(stateindexi);
    numofcountsA = datacounts(1,1);
    numofcountsB = datacounts(2,1);
    numofcountsAB = datacounts(5,1);
    numofcountsC = datacounts(4,1);
    numofcountsAC = datacounts(6,1);
    numofcountsABC = datacounts(7,1);
    accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
    accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
    accidentalsAC=numofcountsA*numofcountsC*deltat/timeinterval;
    accidentalsACstr=num2str(round(accidentalsAC))  ;  %     numofcountsA=numofcounts(1,1);
    accidentalsABC=numofcountsA*numofcountsB*numofcountsC*deltat^2/timeinterval^2;
    accidentalsABCstr=num2str(round(accidentalsABC));    %     numofcountsA=numofcounts(1,1);
    %
    %% Plotting the data points on different subplots
    %pstep(count) = (stateindexi-1)*numofmeasurements*timeinterval+count*timeinterval; % x-axis (time) in seconds
    % plotting A
    plot(ax1,stateindexi,numofcountsA,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B
    plot(ax2,stateindexi,numofcountsB,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting C
    plot(ax3,stateindexi,numofcountsC,'. b','MarkerSize',20)
     % plotting AB
        plot(ax4,stateindexi,numofcountsAB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AC
        plot(ax5,stateindexi,numofcountsAC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting ABC
        plot(ax6,stateindexi,numofcountsABC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    % Drawing Y-data of the three plots (A, B, AB) at the same time
    descriptionA = num2str(numofcountsA);
    title(ax1,descriptionA,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
    
    descriptionB = num2str(numofcountsB);
    title(ax2,descriptionB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
    
    descriptionC = num2str(numofcountsC);
    title(ax3,descriptionC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');

        descriptionAB = num2str(numofcountsAB);
        title(ax4,descriptionAB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionAC = num2str(numofcountsAC);
        title(ax5,descriptionAC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionABC = num2str(numofcountsABC);
        title(ax6,descriptionABC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
    
    
    descr = strcat('Free-Running Scan - Step: ', stateindexs,'/',numstepsstr,', Time per step = ',timeintervals,' s');
    title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w')
    set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
    axcredit=axes('position',[0.5 0.01 0.1 0.05],'visible','off');
    axcredit.Title.Visible = 'on';
    set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
    descr2 = strcat('Accidentals: AB = ',accidentalsABstr,', AC = ',accidentalsACstr,', ABC = ',accidentalsABCstr);
    title(axcredit,descr2,'FontWeight','bold','FontSize',20,'FontName','TimesNew Roman')
    drawnow
    %----------------------------------------------------------------------
end
fclose(CD48serial);  % close the serial port after the inner loop ends.
pause(2)
clear s;


