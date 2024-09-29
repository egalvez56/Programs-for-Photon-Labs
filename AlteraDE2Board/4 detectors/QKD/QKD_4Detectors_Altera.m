

%% Data Acquisition from Altera DE2 board through Serial port
% Tomography 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This program is written by Behzad and Baibhav on May 2018.                 %
% The goal is to take data from Altera DE2 board through a serial port.   %
% ALTERA sends out 8 numbers that are 32-bit numbers. They correspond to 8%
% counters which are A, B, A' and B' singles as well as AB, A'B, AB' and  %
% A'B' coincidences respectively.                                         %
%_________________________________________________________________________%
%                                                                         %
%*************************************************************************%
%_________________________________________________________________________%
%                                                                         %
% Each 32-bit number is divided into 7-bit partitions which makes it 5    %
% bytes of 7-bit figures per number. Transmitting through the serial port %
% each number becomes 5 8-bit bytes + a termination byte. Eventually      %
% reading the data with MatLab using 19200 baudrate we receive            %
% 8 (# of countes)*5(bytes per number)+1= 41 numbers in the array.        %
% In order to calculate the actual number for a counter, say A, we mu     %
% multiply the corresponding figures by 2^0, 2^7, 2^14, 2^21 and 2^28.    %
% We save the numbers and plot them.                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none. 
% The COM port is determined by the Device Manager in Windows. 


prompt = 'Counter COM port #: ';
dlg_title = 'Counter COM port';
default = {'COM0'};
counterportnum = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],default);
scounter = serial(counterportnum{1},'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
 

%% Loop

numofstates = 1; % # of states to do the tomography for
numofmeasurements = 10; % # of measurements per each state 
timeinterval = 1; % time interval for each measurement in seconds
loop = numofmeasurements; 
deltat = 40e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0;
clockt=fix(clock); % saving the initial date/time into a matrix
myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
cleandatadimension=41*(timeinterval*10);
myData=zeros(myDatadimension,1);
resultsmatrix=zeros(numofmeasurements,8);
% erasingmatrix(1:(numofmeasurements+1)*numofstates+3,1:8)="";% matrix defined to erase the excel sheet
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
% xlswrite('resultsmatrix.xlsx',erasingmatrix,Sheet1,'A1')%erasing sheet 1
% xlswrite('resultsmatrix.xlsx',erasingmatrix,Sheet2,'A1')%erasing sheet 2
% Start the excel file to write the gradual results
xlrange1='A1';

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
%Header1={'A','B','AB','Accidenals'}; 
Header1={'Ad','Bd','A','B','AdBd','AdB','AB','ABd','Accidentals'}; 
xlswrite('Tomographyresults.xlsx',Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.

% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'Ad','Bd','A','B','AdBd','AdB','AB','ABd','Accidentals'}; 
xl2range1='A1';
xlswrite('Tomographyresults.xlsx',Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.

for stateindexi=1:numofstates
% header for each state measurement results in excel file "Gradual Results"
countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
xlrange2=strcat('A',countt);
stateindexit=num2str(stateindexi);
stateheader={'state #',stateindexit};
xlswrite('Tomographyresults.xlsx',stateheader,Sheet1,xlrange2);
% header for each state measurement results in excel file "Total Results"
countt=num2str((stateindexi-1)*2+2);
xl2range2=strcat('A',countt);
xlswrite('Tomographyresults.xlsx',stateheader,Sheet2,xl2range2);

%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','QKD Data Acquisition','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
%_____________________________________
% Axes Properties
% axes('position',[left bottom width height])

% Axis for Header
axheader=axes('position',[0.45 0.85 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
plotwidth = 0.20;
plotheight = 0.25;
ax1 = axes('position',[0.03 0.12 plotwidth plotheight]); % Axies 1 position in the figure
set(get(ax1,'title'),'background','y')
ax1.XLim = [0 numofmeasurements+1];
ax1.YLim = [0 inf];
ax1.XLabel.String  = 'Bob(d)';ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 20;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax1,'XTick',0:loop/10:loop*timeinterval+1)
ax1.YLabel.String  = '';ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 7;ax1.YLabel.FontName = 'TimesNewRoman';
grid(ax1,'on');
hold(ax1,'on')
%____________________________________

ax2 = axes('position',[0.28 0.12 plotwidth plotheight]); % Axies 2 position in the figure
set(get(ax2,'title'),'background','y')
ax2.XLim = [0 numofmeasurements+1];
ax2.YLim = [0 inf];
ax2.XLabel.String  = 'Bob';ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 20;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',0:loop/10:loop*timeinterval+1)
ax2.YLabel.String  = '';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 7;ax2.YLabel.FontName = 'TimesNewRoman';
grid(ax2,'on');
hold(ax2,'on')
%__________________________________________________________________
ax3 = axes('position',[0.53 0.12 plotwidth plotheight]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
ax3.XLim=[0 numofmeasurements+1];
ax3.YLim = [0 inf];
ax3.XLabel.String  = 'Alice';ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 20;ax3.XLabel.FontName = 'TimesNewRoman'; %time font
set(ax3,'XTick',0:loop/10:loop*timeinterval+1)
ax3.YLabel.String  = '';ax3.YLabel.FontWeight = 'bold';% single font
ax3.YLabel.FontSize = 7;ax3.YLabel.FontName = 'TimesNewRoman';
grid(ax3,'on');
hold(ax3,'on')
%____________________________________

ax4 = axes('position',[0.79 0.12 plotwidth plotheight]); % Bob (d) position in the figure
set(get(ax4,'title'),'background','y')
ax4.XLim=[0 numofmeasurements+1];
ax4.YLim = [0 inf];
ax4.XLabel.String  = 'Alice (d)';ax4.XLabel.FontWeight = 'bold';
ax4.XLabel.FontSize = 20;ax4.XLabel.FontName = 'TimesNewRoman';
set(ax4,'XTick',0:loop/10:loop*timeinterval+1)
ax4.YLabel.String  = '';ax4.YLabel.FontWeight = 'bold';
ax4.YLabel.FontSize = 7;ax4.YLabel.FontName = 'TimesNewRoman';
grid(ax4,'on');
hold(ax4,'on')

%___________________________________________________________________
ax5=axes('position',[0.03 0.55 plotwidth plotheight]); % Axies 5 position in the figure
set(get(ax5,'title'),'background','y')
ax5.XLim=[0 numofmeasurements+1];
ax5.YLim = [0 inf];
ax5.XLabel.String  = 'A''B''';ax5.XLabel.FontWeight = 'bold';
ax5.XLabel.FontSize = 20;ax5.XLabel.FontName = 'TimesNewRoman';
set(ax5,'XTick',0:loop/10:loop*timeinterval+1)
ax5.YLabel.String  = '';ax5.YLabel.FontWeight = 'bold';
ax5.YLabel.FontSize = 7;ax5.YLabel.FontName = 'TimesNewRoman';
grid(ax5,'on');
hold(ax5,'on')
%______________________________________________________________
ax6=axes('position',[0.28 0.55 plotwidth plotheight]); % Axies 6 position in the figure
set(get(ax6,'title'),'background','y')
ax6.XLim=[0 numofmeasurements+1];
ax6.YLim = [0 inf];
ax6.XLabel.String  = 'AB';ax6.XLabel.FontWeight = 'bold';
ax6.XLabel.FontSize = 20;ax6.XLabel.FontName = 'TimesNewRoman';
set(ax6,'XTick',0:loop/10:loop*timeinterval+1)
ax6.YLabel.String  = '';ax6.YLabel.FontWeight = 'bold';
ax6.YLabel.FontSize = 7;ax6.YLabel.FontName = 'TimesNewRoman';
grid(ax6,'on');
hold(ax6,'on')

%_________________________________________________________________
ax7=axes('position',[0.53 0.55 plotwidth plotheight]); % Axies 7 position in the figure
set(get(ax7,'title'),'background','y')
ax7.XLim=[0 numofmeasurements+1];
ax7.YLim = [0 inf];
ax7.XLabel.String  = 'AB''';ax7.XLabel.FontWeight = 'bold';
ax7.XLabel.FontSize = 20;ax7.XLabel.FontName = 'TimesNewRoman';
set(ax7,'XTick',0:loop/10:loop*timeinterval+1)
ax7.YLabel.String  = '';ax7.YLabel.FontWeight = 'bold';
ax7.YLabel.FontSize = 7;ax7.YLabel.FontName = 'TimesNewRoman';
grid(ax7,'on');
hold(ax7,'on')

%____________________________________________________________________
ax8=axes('position',[0.79 0.55 plotwidth plotheight]); % Axies 8 position in the figure
set(get(ax8,'title'),'background','y')
ax8.XLim=[0 numofmeasurements+1];
ax8.YLim = [0 inf];
ax8.XLabel.String  = 'A''B';ax8.XLabel.FontWeight = 'bold';
ax8.XLabel.FontSize = 20;ax8.XLabel.FontName = 'TimesNewRoman';
set(ax8,'XTick',0:loop/10:loop*timeinterval+1)
ax8.YLabel.String  = '';ax8.YLabel.FontWeight = 'bold';
ax8.YLabel.FontSize = 7;ax8.YLabel.FontName = 'TimesNewRoman';
grid(ax8,'on');
hold(ax8,'on')
%____________________________________________________________________

%% The Loop
fopen(scounter);  % open the serial port before the inner loop begins.
%****************************************************************************

while ~isequal(count,loop+1)
    
    % Serial data accessing 
    for i=1:timeinterval
         myData1 = fread(scounter,512,'uint8'); % reading # of bytes
         myData(1,(i-1)*512+1:i*512) = myData1';
    end 
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
    % saving myData portion into cleandata so the array starts with A
    % that is right after the first termination byte (255)
    
    cleandata=myData(1,tbi+1:tbi+cleandatadimension);
    numofcounts=zeros(1,8);
    CD=cleandata; % just to use a shorthand notation CD
    kmax=timeinterval*10; % loop repetation numner for each counter
    L=0;j=0;
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
    numofcountsAprime=numofcounts(1,3);
    numofcountsBprime=numofcounts(1,4);
    numofcountsAB=numofcounts(1,5);
    numofcountsAprimeA=numofcounts(1,6);
    numofcountsBBprime=numofcounts(1,7);
    numofcountsAprimeBprime=numofcounts(1,8);
    
    %% Plotting the data points on different subplots 
    % Drawing Y-data of the 8 plots (A, A', B, B', AA', BB', A'B', AB) at the same time
    time(count) = count*timeinterval; % x-axis (time) in seconds   
    % plotting B(d)    
      plot(ax1,time(count),numofcounts(1,2),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting A
      plot(ax3,time(count),numofcounts(1,3),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B    
      plot(ax2,time(count),numofcounts(1,4),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting Ad    
      plot(ax4,time(count),numofcounts(1,1),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AdBd
      plot(ax5,time(count),numofcounts(1,5),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AA' (AAd)
      plot(ax7,time(count),numofcounts(1,6),'. b','Markersize',20)
    %----------------------------------------------------------------------
    % plotting BB'
      plot(ax8,time(count),numofcounts(1,7),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AB
      plot(ax6,time(count),numofcounts(1,8),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % Showing the numbers (counts) in the title of the axes 1-8
    descriptionBd = num2str(numofcounts(1,2)); 
    fontsize = 35;
    title(ax1,descriptionBd,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descriptionB = num2str(numofcounts(1,4));
    title(ax2,descriptionB,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descriptionA = num2str(numofcounts(1,3));
    title(ax3,descriptionA,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descriptionAd = num2str(numofcounts(1,1));
    title(ax4,descriptionAd,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
   
    descriptionAB = num2str(numofcounts(1,5));
    title(ax5,descriptionAB,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descriptionAAprime = num2str(numofcounts(1,6));
    title(ax7,descriptionAAprime,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
   
    descriptionBBprime = num2str(numofcounts(1,7));
    title(ax8,descriptionBBprime,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descriptionAprimeBprime = num2str(numofcounts(1,8));
    title(ax6,descriptionAprimeBprime,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');
    
    descr = ['QKD Data Acquisition: ','State # ',num2str(stateindexi),'/',num2str(numofstates),', measurement #',num2str(count),'/',num2str(numofmeasurements)];
    title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
%     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
    drawnow

    %----------------------------------------------------------------------
    
    
    %% Storing Data in the resultsmatrix and finally in xlsx file
    
    resultsmatrix(count,1)=numofcounts(1,1);
    resultsmatrix(count,2)=numofcounts(1,2);
    resultsmatrix(count,3)=numofcounts(1,3);
    resultsmatrix(count,4)=numofcounts(1,4);
    resultsmatrix(count,5)=numofcounts(1,5);
    resultsmatrix(count,6)=numofcounts(1,6);
    resultsmatrix(count,7)=numofcounts(1,7);
    resultsmatrix(count,8)=numofcounts(1,8);
%________________________________________________________________________    
    % writing results gradually into the "Gradual Results' sheet in excel
    % file
    warning('off','MATLAB:xlswrite:AddSheet');
    % to suppress the warning when the sheet name is not in excel file.
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
   % xlswrite('Tomographyresults.xlsx',[resultsmatrix(count,1:2),resultsmatrix(count,5),accidentalsindividual],Sheet1,xlrange2);
    xlswrite('Tomographyresults.xlsx',[resultsmatrix(count,1:8),accidentalsindividual],Sheet1,xlrange2);
    count = count +1;

end

fclose(scounter);  % close the serial port after the inner loop ends.

    if stateindexi~=numofstates
        close all
    end 

% Writing the average of the measurement results for the state into "Total
% Results" sheet
countt=num2str((stateindexi-1)*2+3);
xl2range2=strcat('A',countt);
accidentalstotal=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
xlswrite('Tomographyresults.xlsx',[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,5)),accidentalstotal],Sheet2,xl2range2)
pause(statepause);
count=1;

end
fclose(scounter);
delete(scounter);
clear s;

%% writing date and time of the results into the excle files

timeheader={'year','month','day','hour','minute','seconds'};

% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite('Tomographyresults.xlsx',timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite('Tomographyresults.xlsx',clockt,Sheet1,xlrange2)

% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
xlswrite('Tomographyresults.xlsx',timeheader,Sheet2,xlrangetimeheader)
xlswrite('Tomographyresults.xlsx',clockt,Sheet2,xlrangetime)

% save to "resultsmatrix.txt" file
save('Tomographyresults.txt','resultsmatrix','-ascii')

