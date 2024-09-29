%% Paused3Detectors_CD48
% Data aquisition program with Red5 Dog CD48 board
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
% This program used the output of 3 detectors and takes data points step  %
% by step, where in between steps the user can make changes to the        %
% apparatus. For example, it can be used for th Hanbuty-Brown-Twiss test. %
% The output is put in an Excel file.                                     %
%                                                                         %
%*************************************************************************%
%
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none.
% The COM port is determined by the Device Manager in Windows.
%% Setup
prompt = {'Enter # of paused steps:','time interval','Counter COM port #: ','Excel file name'};
dlg_title = 'Paused Scan Inputs';
defaultans = {'3','1','COM19','Paused3'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
numofstates = str2double(userinput{1}); % # of states to do the tomography for
numofmeasurements = 1; % # of measurements per each state
comportnum = userinput{3}; % COM port
CD48serial = serial(comportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
timeinterval = str2double(userinput{2}); % time interval for each measurement in seconds
% end of input dialo
timeaxislimit = numofstates*numofmeasurements;
loop = numofmeasurements;
deltat=20e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; pstep=zeros(loop);statepause=2;
clockt=fix(clock); % saving the initial date/time into a matrix
% Excel file definitions
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'A','B','C','AB','AC,','ABC','Accidenals'};
xlsfilename = [userinput{4},'CoincidenceABC'];
xlswrite(xlsfilename,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
% Start the excel file to write the "Total Results" sheet
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'A','B','C','AB','AC','ABC','Accidentals'};
xl2range1='A1';
xlswrite(xlsfilename,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','CoincidenceABC','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
%_____________________________________
% Axes Properties
% axes('position',[left bottom width height])

% Axis for Header
axheader=axes('position',[0.45 0.88 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
% Singles A axes
ax1 = axes('position',[0.08 0.57 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'background','y')
ax1.XLim = [0 timeaxislimit+1];
ax1.YLim = [0 inf];
% ax1.XLabel.String  = 'time (sec)';ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 14;ax1.XLabel.FontName = 'TimesNewRoman';
% set(ax1,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax1,'XTick',1:1:timeaxislimit)

ax1.YLabel.String  = 'Singles A';ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 20;ax1.YLabel.FontName = 'TimesNewRoman';
grid(ax1,'on');
hold(ax1,'on')
%____________________________________
% singles B axes
ax2 = axes('position',[0.40 0.57 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'background','y')
ax2.XLim=[0 timeaxislimit+1];
ax2.YLim = [0 inf];
% ax2.XLabel.String  = 'time (sec)';ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
% set(ax2,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax2,'XTick',1:1:timeaxislimit)
ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 20;ax2.YLabel.FontName = 'TimesNewRoman';
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
% Singles C axes
ax4=axes('position',[0.72 0.57 0.25 0.3]); % Axies 3 position in the figure
set(get(ax4,'title'),'background','y')
ax4.XLim=[0 timeaxislimit+1];
ax4.YLim = [0 inf];
% ax4.XLabel.String  = 'time (sec)';ax4.XLabel.FontWeight = 'bold';
ax4.XLabel.FontSize = 14;ax4.XLabel.FontName = 'TimesNewRoman';
% set(ax4,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax4,'XTick',1:1:timeaxislimit)

ax4.YLabel.String  = 'Singles C';ax4.YLabel.FontWeight = 'bold';
ax4.YLabel.FontSize = 20;ax4.YLabel.FontName = 'TimesNewRoman';
grid(ax4,'on')
hold(ax4,'on')
%____________________________________
% Coincidences AB axes
ax3=axes('position',[0.08 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
ax3.XLim=[0 timeaxislimit+1];
ax3.YLim = [0 inf];
ax3.XLabel.String  = 'Step';ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman';
% set(ax3,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax3,'XTick',1:1:timeaxislimit)

ax3.YLabel.String  = 'Coincidences AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 20;ax3.YLabel.FontName = 'TimesNewRoman';
grid(ax3,'on')
hold(ax3,'on')
%_____________________________
% CoincidencesAC axes
ax5=axes('position',[0.4 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax5,'title'),'background','y')
ax5.XLim=[0 timeaxislimit+1];
ax5.YLim = [0 inf];
ax5.XLabel.String  = 'Step';ax5.XLabel.FontWeight = 'bold';
ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
% set(ax5,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax5,'XTick',1:1:timeaxislimit)

ax5.YLabel.String  = 'Coincidences AC';ax5.YLabel.FontWeight = 'bold';
ax5.YLabel.FontSize = 20;ax5.YLabel.FontName = 'TimesNewRoman';
grid(ax5,'on')
hold(ax5,'on')
%____________________________________
% CoincidencesABC axes
ax6=axes('position',[0.72 0.17 0.25 0.3]); % Axies 3 position in the figure
set(get(ax6,'title'),'background','y')
ax6.XLim=[0 timeaxislimit+1];
ax6.YLim = [0 inf];
ax6.XLabel.String  = 'Step';ax6.XLabel.FontWeight = 'bold';
ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
% set(ax6,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax6,'XTick',1:1:timeaxislimit)

ax6.YLabel.String  = 'Coincidences ABC';ax6.YLabel.FontWeight = 'bold';
ax6.YLabel.FontSize = 20;ax6.YLabel.FontName = 'TimesNewRoman';
grid(ax6,'on')
hold(ax6,'on')
%______________________________________________________________
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
%
%% The Loop
%
for stateindexi=1:numofstates
    % header for each state measurement results in excel file "Gradual Results"
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    stateindexit=num2str(stateindexi);
    stateheader={'state #',stateindexit};
    xlswrite(xlsfilename,stateheader,Sheet1,xlrange2);
    % header for each state measurement results in excel file "Total Results"
    countt=num2str((stateindexi-1)*2+2);
    xl2range2=strcat('A',countt);
    xlswrite(xlsfilename,stateheader,Sheet2,xl2range2);
    while ~isequal(count,loop+1) % This is for measurements per step
%        numofcounts = zeros(9,1);
        flushinput(CD48serial)
        pause(timeinterval)
        numofcounts(:,1)=fscanf(CD48serial,'%d\n');
        flushinput(CD48serial)
        numofcountsA = numofcounts(1,1); %A detector
        numofcountsB = numofcounts(2,1); % B detector
        numofcountsC = numofcounts(3,1);% C detector
        numofcountsD = numofcounts(4,1); % D detector-not used
        numofcountsAB = numofcounts(5,1); %AB coincidences
        numofcountsAC = numofcounts(6,1);% AC coincidence
        numofcountsAD = numofcounts(8,1); % AD coincidence
        numofcountsABC=numofcounts(7,1); % ABC triple coincidence
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
        accidentalsAC=numofcountsA*numofcountsC*deltat/timeinterval;
        accidentalsACstr=num2str(round(accidentalsAC))  ;  %     numofcountsA=numofcounts(1,1);
        accidentalsABC=numofcountsA*numofcountsB*numofcountsC*deltat^2/timeinterval^2;
        accidentalsABCstr=num2str(round(accidentalsABC));    %     numofcountsA=numofcounts(1,1);
        %
        %% Plotting the data points on different subplots
        pstep(count) = (stateindexi-1)*numofmeasurements+count; % x-axis (time) in seconds
        % plotting A
        plot(ax1,pstep(count),numofcountsA,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting B
        plot(ax2,pstep(count),numofcountsB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting C
        plot(ax4,pstep(count),numofcountsC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------      
        % plotting AB
        plot(ax3,pstep(count),numofcountsAB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AC
        plot(ax5,pstep(count),numofcountsAC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting ABC
        plot(ax6,pstep(count),numofcountsABC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % Drawing Y-data of the three plots (A, B, AB) at the same time
        descriptionA = num2str(numofcountsA);
        title(ax1,descriptionA,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');        
        descriptionB = num2str(numofcountsB);
        title(ax2,descriptionB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');        
        descriptionC = num2str(numofcountsC);
        title(ax4,descriptionC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        descriptionAB = num2str(numofcountsAB);
        title(ax3,descriptionAB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        descriptionAC = num2str(numofcountsAC);
        title(ax5,descriptionAC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        descriptionABC = num2str(numofcountsABC);
        title(ax6,descriptionABC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        descr = ['Paused Scan: Step # ',num2str(stateindexi),'/',num2str(numofstates),', Time per step = ',num2str(timeinterval),' s'];
        title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        axcredit=axes('position',[0.5 0.01 0.1 0.05],'visible','off');
        axcredit.Title.Visible = 'on';
        set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
        descr2 = strcat('Accidentals: AB = ',accidentalsABstr,', AC = ',accidentalsACstr,', ABC = ',accidentalsABCstr);
        title(axcredit,descr2,'FontWeight','bold','FontSize',20,'FontName','TimesNew Roman')
        drawnow
        %----------------------------------------------------------------------       
        %% Storing Data in the resultsmatrix and finally in xlsx file       
        resultsmatrix(count,1)=numofcountsA;
        resultsmatrix(count,2)=numofcountsB;
        resultsmatrix(count,3)=numofcountsC;
        resultsmatrix(count,4)=numofcountsD;
        resultsmatrix(count,5)=numofcountsAB;
        resultsmatrix(count,6)=numofcountsAC;
        resultsmatrix(count,7)=numofcountsABC;
        resultsmatrix(count,8)=numofcountsAD;
        %________________________________________________________________________
        % writing results gradually into the "Gradual Results' sheet in excel
        % file
        warning('off','MATLAB:xlswrite:AddSheet');
        % to suppress the warning when the sheet name is not in excel file.
        countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
        xlrange2=strcat('A',countt);
        accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
        xlswrite(xlsfilename,[resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsindividual],Sheet1,xlrange2);
        count = count +1;
        
    end
    % Writing the average of the measurement results for the state into "Total
    % Results" sheet
    countt=num2str((stateindexi-1)*2+3);
    xl2range2=strcat('A',countt);
    accidentalstotal=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
    xlswrite(xlsfilename,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotal],Sheet2,xl2range2)
    % pause(statepause);
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
    %______________________________________________
    
end
fclose(CD48serial);  % close the serial port after the inner loop ends.
clear s;
%% writing date and time of the results into the excle files

timeheader={'year','month','day','hour','minute','seconds'};

% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,clockt,Sheet1,xlrange2)

% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
xlswrite(xlsfilename,timeheader,Sheet2,xlrangetimeheader)
xlswrite(xlsfilename,clockt,Sheet2,xlrangetime)

% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')

