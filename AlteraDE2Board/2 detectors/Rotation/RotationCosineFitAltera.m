%% RotationCosineFitAltera
%
% Program to test polarization correlations of a prepared Bell state
% The program scans the angle of a waveplate that projects the 
% state of the light onto a linear state of varying orientation.
% The program ends by making a fit to the data to extract the phase of the
% cosine function. It also fits the visibility.
%
% The input/graphics aere based on a program written by Bhzad Khajavi in 
% July 2017. Modified by Kiko in 2021.                               %
% Kiko Galvez modified it in June-July 2021,
% Modified to scan rotation mount KG 4/22.                              %
% Modified to rotate a waveplate and fit N(1+V cos q).  KG 5/29/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none.
% The COM port is determined by the Device Manager in Windows.
%
%% Input dialog and setting up parameters
%
prompt = {'Enter the COM# of the Counter:','Enter the COM# of the Rotator:','Start Motor Angle (nods)','End Motor Angle (nods)','Motor Increment (nods)','time interval','Excel file name'};
dlg_title = 'Quantum lab Inputs for Triple Coinc. Voltage Scan';
defaultans = {'COM21','COM12','-600','600','10','2','Sinecurve'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1}; % COM port
PacificPortNum = userinput{2}; % COM# for the Pacific Motor Rotator 
% Reading parameters for Voltage scan
StartAngle = str2double(userinput{3});
EndAngle = str2double(userinput{4});
DeltaA=EndAngle-StartAngle;
Increment = str2double(userinput{5});
numofsteps = round(DeltaA/Increment,0); %defines the number of measurements
timeinterval = str2double(userinput{6}); % time interval for each measurement in seconds
%CD48serial = serial(counterportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
% fopen(CD48serial);  % open the Counter serial port before the inner loop begins.
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
fopen(scounter);  % open the Counter serial port before the inner loop begins.
numofstates=1; % In principle set up for taking several measurements per point
numofmeasurements = numofsteps+1;
loop = numofmeasurements;
deltat=20e-9; % coincidence time to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0; % initializing counters
clockt=fix(clock); % saving the initial date/time into a matrix
%sPacific = serial(PacificPortNum,'BaudRate',9600);
sPacific = serialport(PacificPortNum,9600);
configureTerminator(sPacific,'CR')
%
%% Setting up output to Excel file
%
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
% Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'M','A','B','AB','Accidentals'};
xlsfilename = [userinput{7},'Mscan'];
xlswrite(xlsfilename,Header1,Sheet1,xlrange1)
% xlswrite('CoincidenceABC.xlsx',Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
% Start the excel file to write the "Total Results" sheet
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
% End of writing the header for the  excel file.
%
%% The outer Loop (repeats number of states per voltage, set to 1 for now 7/21)
%
for stateindexi=1:numofstates
    % header for each state measurement results in excel file "Gradual Results"
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
%     xlrange2=strcat('A',countt);
    stateindexit=num2str(stateindexi);
%     stateheader={'state #',stateindexit};
%     xlswrite(xlsfilename,stateheader,Sheet1,xlrange2);
    % header for each state measurement results in excel file "Total Results"
    countt=num2str((stateindexi-1)*2+2);
%     xl2range2=strcat('A',countt);
    % xlswrite('CoincidenceABC.xlsx',stateheader,Sheet2,xl2range2);
    %% Figure adjustments
    %
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Rotation Scan Data Recording','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
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
    ax1.XLim = [StartAngle EndAngle];
ax1.XLabel.String  = 'Motor Position (nods)';
ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 20; ax1.XLabel.FontName = 'TimesNewRoman';
set(ax1,'XTick',StartAngle:DeltaA/10:EndAngle)
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
    ax2.XLim = [StartAngle EndAngle];
ax2.XLabel.String  = 'Motor Position (nods)';
ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 20;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',StartAngle:DeltaA/10:EndAngle);
ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 20;ax2.YLabel.FontName = 'TimesNewRoman';
ax2.YLim = [0 inf];
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
ax3=axes('position',[0.72 0.25 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'background','y')
    ax3.XLim = [StartAngle EndAngle];
ax3.XLabel.String  = 'Motor Position (nods)';
ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 20;ax3.XLabel.FontName = 'TimesNewRoman';
set(ax3,'XTick',StartAngle:DeltaA/10:EndAngle)
%set(ax3,'XTicklabel',{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
ax3.YLabel.String  = 'Coincidences AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 20;ax3.YLabel.FontName = 'TimesNewRoman';
ax3.YLim=[0 inf];
grid(ax3,'on')
hold(ax3,'on')
    %______________________________________________________________
    %% Setting up the Coincidence board
    %
%fprintf(CD48serial,'%s','v'); %reset to firmware
% pause(0.1)
% fprintf(CD48serial,'%s','T');
% fprintf(CD48serial,'%s','S01000'); % counter 0
% fprintf(CD48serial,'%s','S10100'); % counter 1
% fprintf(CD48serial,'%s','S20010'); % counter 2
% fprintf(CD48serial,'%s','S30001'); % counter 3
% fprintf(CD48serial,'%s','S41100'); % counter 4
% fprintf(CD48serial,'%s','S51010'); % counter 5
% fprintf(CD48serial,'%s','S61110'); % counter 6 - modified for ABC coincidence
% fprintf(CD48serial,'%s','S71001'); % counter 7
% fprintf(CD48serial,'%s','L050'); % pulse threshold
% fprintf(CD48serial,'%s','z'); %50 ohm impedance
% %timeintervals = '2'; % time interval for each measurement in seconds
% timeinms=num2str(floor(timeinterval*1000)); % time interval in ms
% disp(timeinterval);
% disp(timeinms);
% if timeinterval < 1
%     timetobox = strcat('r','00',timeinms); % set up repeat command (counter accumulation time) to time interval
% elseif timeinterval < 10
%     timetobox = strcat('r','0',timeinms); % set up repeat command (counter accumulation time) to time interval
% else
%     timetobox = strcat('r',timeinms); % set up repeat command (counter accumulation time) to time interval
% end
% disp(timetobox);
% fprintf(CD48serial,'%s','R'); % Repeat off
% pause(0.1)
% fprintf(CD48serial,'%s',timetobox); % program the repeat time in seconds
% pause(0.1)
% fprintf(CD48serial,'%s','R'); % Repeat on
% %fprintf(CD48serial,'%s','r02000'); % program the repeat time in seconds
% pause(0.1)
% flushinput(CD48serial)
% fprintf(CD48serial,'%s','P');
% pause(0.1);
% Bytes = CD48serial.BytesAvailable;
% Report = char(fread(CD48serial,Bytes)');
% disp(Report);
% if strcmp(strcat(Report(1,86:88)),'off') % turns repeat on if off
%     fprintf(CD48serial,'%s','R');
%     disp('Repeat was off I turned it on')
%     fprintf(CD48serial,'%s','P');
%     pause(0.1)
%     Bytes = CD48serial.BytesAvailable;
%     Report = char(fread(CD48serial,Bytes)');
%     disp(Report);
% end
% flushinput(CD48serial) % to fix bug with 1st data point
% fprintf(CD48serial,'%s','c');
% pause(timeinterval)
% flushinput(CD48serial)
    %% Loop to take data
    %
    while ~isequal(count,loop+1) % outer loop measurements per voltage step
        numofcounts = zeros(9,1);
%        flushinput(CD48serial)
        pause(0.01)
        %    Setting Piezo Voltage
        VtoCD48 = StartAngle + (count-1)*Increment;
        StepToPacific = strcat('ma',num2str(VtoCD48));
%    fprintf(sPacific,StepToPacific);
        writeline(sPacific,StepToPacific);
        pause(1)
%         % Reading Piezo_slider
%         VtoCD48num = floor(VtoCD48*(255/4));
%         % Seding Voltage to CD48
%         VtoCD48s = num2str(VtoCD48num);
%         pause(0.01)
%         if VtoCD48num < 100 && VtoCD48num > 10
%             VtoCD48s = strcat('0',num2str(VtoCD48num))
%         end
%         if VtoCD48num < 10
%             VtoCD48s = strcat('00',num2str(VtoCD48num))
%         end
%         fprintf(CD48serial,'%s',strcat('V',VtoCD48s))
%         flushinput(CD48serial)
%         pause(timeinterval)
%         numofcounts(:,1)=fscanf(CD48serial,'%d\n');
%         flushinput(CD48serial)
         numofcounts=zeros(1,8);
       %%%%%%%%%%%%%%%%%% Long times
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
            cleandatadimension=41*10;
%             myData0 = fread(scounter,512,'uint8'); % reading # of bytes
%   %          pause(1);
%             myData0 = fread(scounter,512,'uint8'); % reading # of bytes
%             pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
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
            numofcounts=zeros(1,8);
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
            pause(1);
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
        %%%%%%%%%%%%%%%%%%%%% end of taking data    numofcountsA=numofcounts(1,1);
        numofcountsA = numofcounts(1,1); %A detector
        numofcountsB = numofcounts(1,2); % B detector
        numofcountsAB = numofcounts(1,5); %AB coincidences
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
        %% Plotting the data points on different subplots
        %     time(count) = count*timeinterval; % x-axis (time) in seconds
        voltage(count) = VtoCD48; % x-axis (time) in seconds
        % plotting A
        plot(ax1,voltage(count),numofcountsA,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting B
        plot(ax2,voltage(count),numofcountsB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AB
        plot(ax3,voltage(count),numofcountsAB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % Drawing Y-data of the three plots (A, B, AB) at the same time
        descriptionA = num2str(numofcountsA);
        title(ax1,descriptionA,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionB = num2str(numofcountsB);
        title(ax2,descriptionB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionAB = num2str(numofcountsAB);
        title(ax3,descriptionAB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
                
        descr = [' Motor Scan - Current Value:',num2str(VtoCD48),' Time per step = ',num2str(timeinterval),' s'];
        title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w')
        %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
    axcredit=axes('position',[0.5 0.03 0.1 0.05],'visible','off');
    axcredit.Title.Visible = 'on';
    set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
    descr2 = strcat('Calculated accidentals =  ',accidentalsABstr);
    title(axcredit,descr2,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
        drawnow
        %----------------------------------------------------------------------
        %% Storing Data in the resultsmatrix and finally in xlsx file
        resultsmatrix(count,1)=numofcountsA;
        resultsmatrix(count,2)=numofcountsB;
        resultsmatrix(count,3)=numofcountsAB;
        resultsmatrix(count,4)=accidentalsAB;
        %________________________________________________________________________
        % writing results gradually into the "Gradual Results' sheet in excel
        % file
        warning('off','MATLAB:xlswrite:AddSheet');
        % to suppress the warning when the sheet name is not in excel file.
        countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
         xlrange2=strcat('A',countt);
        accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
        %         xlswrite(xlsfilename,[str2double(VtoCD48),resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsindividual],Sheet1,xlrange2);
        xlswrite(xlsfilename,[VtoCD48,resultsmatrix(count,1:4)],Sheet1,xlrange2);
        count = count +1;
    end
%     flushinput(CD48serial)
%     pause(0.1);
%     fprintf(CD48serial,'%s','V00'); % set voltage back to zero
%     pause(1);
    fclose(scounter);  % close the serial port after the inner loop ends.
    clear scounter;
    % Writing the average of the measurement results for the state into "Total
    % Results" sheet
    % countt=num2str((stateindexi-1)*2+3);
    % xl2range2=strcat('A',countt);
    accidentalstotal = sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
    % xlswrite(xlsfilename,[str2double(VtoArduinos),sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotal],Sheet2,xl2range2)
    pause(statepause);
    count=1;
end
%% writing date and time of the results into the excle file
timeheader={'year','month','day','hour','minute','seconds'};
% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,clockt,Sheet1,xlrange2)
% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str((numofstates*(numofmeasurements+1)+4)));
timestr={'timeinterval='};
xlswrite(xlsfilename,timestr,Sheet1,xlrangetimeheader)
xlrangetime=strcat('B',num2str((numofstates*(numofmeasurements+1)+4)));
xlswrite(xlsfilename,num2str(timeinterval),Sheet1,xlrangetime)
% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')
%
%% Fit
%
disp('Fitting the data')
prompt = ' Enter estimated half maximum: ';
cest(1)=input(prompt);
prompt = ' Enter estimate of visibility: ';
cest(2)=input(prompt);
prompt = ' Enter estimate of phase at x=0 in degrees: ';
cest(4)=input(prompt)*pi/180;
prompt = ' For a period enter x1: ';
x1val=input(prompt);
prompt = ' For a period enter x2: ';
x2val=input(prompt);
cest(3)=2*pi/(x2val-x1val);
prompt = ' Enter low x value of data: ';
xlo = input(prompt);
prompt = ' Enter high x value of data:';
xhi = input(prompt);
countfitlo=floor((xlo-StartAngle)/Increment+1);
countfithi=floor((xhi-StartAngle)/Increment);
xinfit=voltage(countfitlo:countfithi)';
yinfit=resultsmatrix(countfitlo:countfithi,3);
accidentals=resultsmatrix(countfitlo:countfithi,4);
yinfit=yinfit-accidentals;
uncy=sqrt(yinfit);
cfit=lsqcurvefit(@Sinefit,cest,xinfit,yinfit);
yfit=Sinefit(cfit,xinfit);
figure(2);
errorbar(xinfit,yinfit,uncy,'bo','Markersize',3);
hold on
plot(xinfit,yfit,'r-');
cmin=num2str(cfit(4)*180*4.5/pi);
title([' Sine fit phase at 0: ',cmin,' nods']);
hold off
% cmin0=round(cfit(2),0);
% cmin0st=num2str(cmin0);
% setq=strcat('ma',cmin0st);
% writeline(sPacific,setq);
disp('Fitting parameters:');
disp(' ');
disp(' y=c(1)*(1+c(2)*sin(x*c(3)+c(4))) ');
disp(' parameter         value ')
Clab=['c(1) N_0        ';
      'c(2) Visibility ';
      'c(3) Dispersion ';
      'c(4) Zero phase '];
ct = cfit';
Cs=num2str(ct);
Ctab=[Clab,Cs];
disp(Ctab)
phase0=strcat('phase at x=0 : ',num2str(cfit(4)*180/pi*4.5),' nods');
disp(phase0);
clear scounter;
%
%% Function to fit a quadratic minimum
%
%% quadraticmin
%
% cosine function
%
function [ y ]=Sinefit (c,x)
y=c(1)*(1+c(2)*cos(x*c(3)+c(4)));
end