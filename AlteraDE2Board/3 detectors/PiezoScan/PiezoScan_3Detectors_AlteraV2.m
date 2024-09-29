

%% Data aquisition from Altera DE2 board through Serial port
% Tomography 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This program is written by Bebeh and Kiko on July 2017.                 %
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
% Revision to add long and short times Kiko Galvez 4/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none. 
% The COM port is determined by the Device Manager in Windows. 

% Input dialog
prompt = {'Enter the COM# of the Counter:','Enter the COM# of Arduino:',...
    'Start Voltage','End Voltage','V Increment','time interval','File name'};
dlg_title = 'Quantum lab Inputs for Triple Coinc. Arduino Scan';
defaultans = {'COM19','COM20','1','6','0.05','1','Test3d'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1}; % # of states to do the tomography for
Arduinoportnum = userinput{2}; % COM# for the Arduino 
% Properties for Arduino and Piezo Voltage
StartVoltage = str2double(userinput{3});
EndVoltage = str2double(userinput{4});
VoltageInterval=EndVoltage-StartVoltage;
Increment = str2double(userinput{5});
numofsteps = round(VoltageInterval/Increment,0); %defines the number of measurements
timeinterval = str2double(userinput{6}); % time interval for each measurement in seconds

if ~strcmp(counterportnum,'COM0')
%     scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
end
sArduino = serial(Arduinoportnum,'BaudRate',115200);

%% Loop (properties)

numofstates=1; % # of states to do the tomography for
% numofmeasurements=10; % # of measurements per each state 
numofmeasurements = numofsteps;
% timeinterval=1; % time interval for each measurement in seconds
loop = numofmeasurements; 
deltat=40e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0;
clockt=fix(clock); % saving the initial date/time into a matrix
myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
cleandatadimension=41*(timeinterval*10);
myData=zeros(myDatadimension,1);
resultsmatrix=zeros(numofmeasurements,8);
% erasingmatrix(1:(numofmeasurements+1)*numofstates+3,1:8)="";% matrix defined to erase the excel sheet
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
% Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'V','A','B','C','AB','AC,','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xlsfilename = userinput{7};
xlswrite(xlsfilename,Header1,Sheet1,xlrange1)
% xlswrite('CoincidenceABC.xlsx',Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.

% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'V','A','B','C','AB','AC','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xl2range1='A1';
% xlswrite(xlsfilename,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.

%% The outer Loop (repeats number of states times)

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
% xlswrite('CoincidenceABC.xlsx',stateheader,Sheet2,xl2range2);

%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Triple CoincidencePiezo Scan','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
 %_____________________________________
    % Accidental windows
    axAB=axes('position',[0.13 0.03 0.1 0.05],'visible','off');
    axAB.Title.Visible = 'on';
    set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
    axAC=axes('position',[0.45 0.03 0.1 0.05],'visible','off');
    axAC.Title.Visible = 'on';
    set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
    axABC=axes('position',[0.77 0.03 0.1 0.05],'visible','off');
    axABC.Title.Visible = 'on';
    set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue%_____________________________________
% Axes Properties
% axes('position',[left bottom width height])

% Axis for Header
axheader=axes('position',[0.45 0.88 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
% singles A axes
ax1 = axes('position',[0.08 0.57 0.25 0.3]); % Axes 1 position in the figure
set(get(ax1,'title'),'color','w','background','b')
ax1.XLim = [StartVoltage EndVoltage];
ax1.YLim = [0 inf];
% ax1.XLabel.String  = 'time (sec)';ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 14;ax1.XLabel.FontName = 'TimesNewRoman';
set(ax1,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax1.YLabel.String  = 'Singles A';ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 25;ax1.YLabel.FontName = 'TimesNewRoman';
grid(ax1,'on');
hold(ax1,'on')
%____________________________________
% singles B axes
ax2 = axes('position',[0.40 0.57 0.25 0.3]); % Axes 2 position in the figure
set(get(ax2,'title'),'color','w','background','b')
ax2.XLim=[StartVoltage EndVoltage];
ax2.YLim = [0 inf];
% ax2.XLabel.String  = 'time (sec)';ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 25;ax2.YLabel.FontName = 'TimesNewRoman';
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
% singles C axes
ax4=axes('position',[0.72 0.57 0.25 0.3]); % Axes 4 position in the figure
set(get(ax4,'title'),'color','w','background','b')
ax4.XLim=[StartVoltage EndVoltage];
ax4.YLim = [0 inf];
% ax4.XLabel.String  = 'time (sec)';ax4.XLabel.FontWeight = 'bold';
ax4.XLabel.FontSize = 14;ax4.XLabel.FontName = 'TimesNewRoman';
set(ax4,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax4.YLabel.String  = 'Singles C';ax4.YLabel.FontWeight = 'bold';
ax4.YLabel.FontSize = 25;ax4.YLabel.FontName = 'TimesNewRoman';
grid(ax4,'on')
hold(ax4,'on')
%____________________________________
% Coinc.AB axes
ax3=axes('position',[0.08 0.18 0.25 0.3]); % Axes 3 position in the figure
set(get(ax3,'title'),'color','w','background','b')
ax3.XLim=[StartVoltage EndVoltage];
ax3.YLim = [0 inf];
ax3.XLabel.String  = 'time (sec)';ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman';
set(ax3,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax3.YLabel.String  = 'Doubles AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 25;ax3.YLabel.FontName = 'TimesNewRoman';
grid(ax3,'on')
hold(ax3,'on')
%_____________________________
% Coinc.AC axes
ax5=axes('position',[0.4 0.18 0.25 0.3]); % Axes 5 position in the figure
set(get(ax5,'title'),'color','w','background','b')
ax5.XLim=[StartVoltage EndVoltage];
ax5.YLim = [0 inf];
ax5.XLabel.String  = 'time (sec)';ax5.XLabel.FontWeight = 'bold';
ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
set(ax5,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax5.YLabel.String  = 'Doubles AC';ax5.YLabel.FontWeight = 'bold';
ax5.YLabel.FontSize = 25;ax5.YLabel.FontName = 'TimesNewRoman';
grid(ax5,'on')
hold(ax5,'on')
%____________________________________
% Coinc.ABC axes
ax6=axes('position',[0.72 0.18 0.25 0.3]); % Axes 6 position in the figure
set(get(ax6,'title'),'color','w','background','b')
ax6.XLim=[StartVoltage EndVoltage];
ax6.YLim = [0 inf];
ax6.XLabel.String  = 'time (sec)';ax6.XLabel.FontWeight = 'bold';
ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
set(ax6,'XTick',StartVoltage:VoltageInterval/10:EndVoltage)
ax6.YLabel.String  = 'Triples ABC';ax6.YLabel.FontWeight = 'bold';
ax6.YLabel.FontSize = 25;ax6.YLabel.FontName = 'TimesNewRoman';
grid(ax6,'on')
hold(ax6,'on')
%______________________________________________________________
%% The inner Loop (repeats numebr of measurements times)
if ~strcmp(counterportnum,'COM0')
    fopen(scounter);  % open the serial port before the inner loop begins.
end
fopen(sArduino);  % open the Arduino serial port before the inner loop begins.
%****************************************************************************

while ~isequal(count,loop+2)
    
%    Setting Piezo Voltage
% Seding Voltage to Arduino
    Vcurrent=StartVoltage + (count-1)*Increment;
    VtoArduinos = num2str(Vcurrent);
    fprintf(sArduino,VtoArduinos);
    pause(0.01)
            numofcounts=zeros(1,8);
        if timeinterval > 10
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
            pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
            times10loop=floor(timeinterval/10);
            for il=1:times10loop
                if il == times10loop
                    time10=10+rem(timeinterval,10);
                else
                    time10=10;
                end
                myDatadimension=41*(time10*10)+40; % timeinterval*10=timeinterval in seconds
                cleandatadimension=41*(time10*10);
                myData=zeros(1,myDatadimension);
                for i=1:time10
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
                %            numofcounts=zeros(1,8);
                CD=cleandata; % just to use a shorthand notation CD
                kmax=time10*10; % loop repetition number for each counter
                L=0;j=0;
                for i=1:8
                    j=0;
                    for k=1:kmax
                        numofcounts(1,i)=numofcounts(1,i)+CD(1,1+j+L)+2^7*CD(1,2+j+L)+2^14*CD(1,3+j+L)+2^21*CD(1,4+j+L)+2^28*CD(1,5+j+L);
                        j=j+41; % the corresponding figure after a tenth of a second
                    end
                    L=L+5; % next counter partition starts at the next 5th byte
                end
            end
        elseif timeinterval<1
            %%%%%%%%%%%%%%%%   Short times
            myDatadimension=41*10+40; % timeinterval*10=timeinterval in seconds
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
 %           pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
           cleandatadimension=41*10;
            myData=zeros(1,myDatadimension);
            %        for i=1:timeinterval
            myData1 = fread(scounter,512,'uint8'); % reading # of bytes
            myData(1,1:512) = myData1';
            %            myData(1,(i-1)*512+1:i*512) = myData1';
            %        end
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
            %        numofcounts=zeros(1,8);
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
        else
            %%%%%%%%%%%%%%%%%%   Regular times
            myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds
            cleandatadimension=41*(timeinterval*10);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
            pause(0.01);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
             %            myData=zeros(myDatadimension,1);
            myData=zeros(1,myDatadimension);
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
        end
        %%%%%%%%%%%%%%%%%%%%% end of taking data  
    numofcountsA = numofcounts(1,1);
    numofcountsB = numofcounts(1,2);
    numofcountsC = numofcounts(1,3);% C detector
    numofcountsBprime = numofcounts(1,4);
    numofcountsAB = numofcounts(1,5);
    numofcountsAC = numofcounts(1,6);% AC Coincidence
    numofcountsABC = numofcounts(1,7);% ABC Coincidence
    numofcountsAprimeBprime=numofcounts(1,8);
    %% Plotting the data points on different subplots  
    time(count) =Vcurrent; % x-axis (time) in seconds   
    % plotting A    
      plot(ax1,time(count),numofcountsA,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B
      plot(ax2,time(count),numofcountsB,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting C    
      plot(ax4,time(count),numofcountsC,'. b','MarkerSize',20)
    %----------------------------------------------------------------------

    % plotting AB
      plot(ax3,time(count),numofcountsAB,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AC
      plot(ax5,time(count),numofcountsAC,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting ABC
      plot(ax6,time(count),numofcountsABC,'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % Drawing Y-data of the three plots (A, B, AB) at the same time
    descriptionA = num2str(numofcountsA);    
    title(ax1,descriptionA,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');
    
    descriptionB = num2str(numofcountsB);
    title(ax2,descriptionB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');
    
    descriptionC = num2str(numofcountsC);    
    title(ax4,descriptionC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');

    descriptionAB = num2str(numofcountsAB);
    title(ax3,descriptionAB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');
    
    descriptionAC = num2str(numofcountsAC);
    title(ax5,descriptionAC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');

    descriptionABC = num2str(numofcountsABC);
    title(ax6,descriptionABC,'FontWeight','bold','FontSize',30,'FontName','Times New Roman');

    descr = ['Current Voltage: ',num2str(Vcurrent),' [',num2str(StartVoltage),',',num2str(EndVoltage),']'];
    title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
%     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsAC=numofcountsA*numofcountsC*deltat/timeinterval;
        accidentalsABC=(numofcountsC*numofcountsAB+numofcountsB*numofcountsAC)*deltat/timeinterval; %From Pearson and Jackson AJP 2010
        descraccAB = ['Acc AB=',num2str(accidentalsAB)];
        title(axAB,descraccAB,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')
        descraccAC = ['Acc AC=',num2str(accidentalsAC)];
        title(axAC,descraccAC,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')
        descraccABC = ['Acc ABC=',num2str(accidentalsABC)];
        title(axABC,descraccABC,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')

    %----------------------------------------------------------------------
    
    
    %% Storing Data in the resultsmatrix and finally in xlsx file
    
    resultsmatrix(count,1)=numofcountsA;
    resultsmatrix(count,2)=numofcountsB;
    resultsmatrix(count,3)=numofcountsC;
    resultsmatrix(count,4)=numofcountsBprime;
    resultsmatrix(count,5)=numofcountsAB;
    resultsmatrix(count,6)=numofcountsAC;
    resultsmatrix(count,7)=numofcountsABC;
    resultsmatrix(count,8)=numofcountsAprimeBprime;
%________________________________________________________________________    
    % writing results gradually into the "Gradual Results' sheet in excel
    % file
    warning('off','MATLAB:xlswrite:AddSheet');
    % to suppress the warning when the sheet name is not in excel file.
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
    xlswrite(xlsfilename,[Vcurrent,resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsAB,accidentalsAC,accidentalsABC],Sheet1,xlrange2);
    count = count +1;
    drawnow

end
    fclose(scounter);  % close the serial port after the inner loop ends.
fclose(sArduino);

% Writing the average of the measurement results for the state into "Total
% Results" sheet
% countt=num2str((stateindexi-1)*2+3);
% xl2range2=strcat('A',countt);
%accidentalstotal = sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
%xlswrite(xlsfilename,[Vcurrent,sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotal],Sheet2,xl2range2)
pause(statepause);
count=1;

end
clear scounter;
clear sArduino
%% writing date and time of the results into the excle files

timeheader={'year','month','day','hour','minute','seconds'};

% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,clockt,Sheet1,xlrange2)
parameterheader={'Start Voltage','End Voltage','Increment','Time Interval (s)'};
countt=num2str(numofstates*(numofmeasurements)+7);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,parameterheader,Sheet1,xlrange2)
parameters=[StartVoltage,EndVoltage,Increment,timeinterval];
countt=num2str(numofstates*(numofmeasurements)+8);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,parameters,Sheet1,xlrange2)
% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
%xlswrite(xlsfilename,timeheader,Sheet2,xlrangetimeheader)
%xlswrite(xlsfilename,clockt,Sheet2,xlrangetime)

% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')

