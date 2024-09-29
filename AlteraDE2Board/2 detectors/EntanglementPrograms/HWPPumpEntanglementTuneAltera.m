%%  HWPPumpEntanglementTune
%          
% Program to prepare the Bell state HH+VV. The first step is to equalize
% the counts for HH and VV by adjusting the HWP for the pump. This program
% makes a scan of the pump HWP in a motorized rotating mount (Pacific
% Laser), while taking data for both HH and VV, which are moved through
% waveplates projecting the polarization for both photons. The program
% takes the difference of HH and VV and fits a curve and finds the zero
% crossing. Sunsequently sets the half wave plate to the appropriate angle.
%
% The inpur/graphics were based on a program written by Bhzad Khajavi in
% July 2017. Modified by Kiko in 2021.                                %
% Kiko Galvez modified it in June-July 2021,
% Modified to scan rotation mount KG 4/22.  
% Modified to locate the appropriate value of the 405-nm pump HWP
% to get the best entangled state KG 5/22
%                                                                         %
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
prompt = {'Enter the COM# of the Counter:','Enter the COM# of Pump HWP:',...
    'Enter the COM# of Left HWP:','Enter the COM# of Right HWP:',...
    'Start Angle (nods)','End Angle (nods)','Angle Increment (nods)',...
    'time interval','Excel file name'};
dlg_title = 'Quantum lab Inputs for Triple Coinc. Voltage Scan';
defaultans = {'COM26','COM25','COM15','COM12','0','400','50','1',...
    'Entanglestatefit'};
%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1}; % COM port
PumpHWP = userinput{2}; % COM# for the Pacific Motor Rotator
% Reading parameters for Voltage scan
RightHWP = userinput{3};
LeftHWP = userinput{4};
StartAngle = str2double(userinput{5});
EndAngle = str2double(userinput{6});
Increment = str2double(userinput{7});
DeltaA=EndAngle-StartAngle;
numofsteps = round(DeltaA/Increment,0); %defines the number of measurements
timeinterval = str2double(userinput{8}); % time interval for each measurement in seconds
%CD48serial = serial(counterportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
fopen(scounter);  % open the Counter serial port before the inner loop begins.
numofstates=1; % In principle set up for taking several measurements per point
numofmeasurements = numofsteps+1;
loop = numofmeasurements;
deltat=20e-9; % coincidence time to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0; % initializing counters
clockt=fix(clock); % saving the initial date/time into a matrix
%sPacific = serial(PacificPortNum,'BaudRate',9600);
Pump = serialport(PumpHWP,9600);
% configureTerminator(sPacific,'CR')
configureTerminator(Pump,'CR')
Left = serialport(LeftHWP,9600);
configureTerminator(Left,'CR')
Right = serialport(RightHWP,9600);
pause(1);
configureTerminator(Right,'CR')
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
%
countt=num2str(2*numofmeasurements+3);% to go two lines further (count+1)in excel (because of the header)
stateindexi=1;
stateindexit=num2str(stateindexi);
%
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
ax1.XLabel.String  = 'HWP Angle (nods)';
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
ax2.XLabel.String  = 'HWP Angle (nods)';
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
ax3.XLabel.String  = 'HWP Angle (nods)';
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
myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
cleandatadimension=41*(timeinterval*10);
myData=zeros(myDatadimension,1);
flushinput(scounter)
%% Loop to take data
%
CountsHHVV=zeros(numofsteps,2);
while ~isequal(count,loop+1) % outer loop measurements per voltage step
    numofcounts = zeros(9,1);
    flushinput(scounter)
    pause(1)
    %    Setting Piezo Voltage
    CurrAngle = StartAngle + (count-1)*Increment;
    PumpAngle = strcat('MA',num2str(CurrAngle));
    %           fprintf(sPacific,StepToPacific);
    writeline(Pump,PumpAngle);
    pause(2);
    for iset=1:2
            pause(1)
        if(iset==1)
%             writeline(Right,'MA-50'); % Correcting for backlash
%             writeline(Left,'MA-50');
            writeline(Right,'MA0'); % Setting HH
            pause(1)
            writeline(Left,'MA0');
            pause(1)
        else
            writeline(Right,'MA405'); % Setting VV
            pause(1)
            writeline(Left,'MA405');
        end
            pause(1)
        numofcounts=zeros(1,8);
    % Serial data accessing
        if timeinterval > 10
            times10loop=floor(timeinterval/10);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
            pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
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
             myData0 = fread(scounter,512,'uint8'); % reading # of bytes
%            pause(1);
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
%            myData=zeros(myDatadimension,1);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
            pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
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
        numofcountsA = numofcounts(1,1); %A detector
        numofcountsB = numofcounts(1,2); % B detector
        %            dataHHVV=(cos(2/9*(CurrAngle+50)*pi()/180))^2*(-1)^(iset-1)+iset-1;% fake data
        %            numofcountsAB = (400+50*(2-iset))*dataHHVV+rand*40;%(numofcounts(5,1); %AB coincidences
        numofcountsAB = numofcounts(1,5); %AB coincidences
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
        %% Plotting the data points on different subplots
        %     time(count) = count*timeinterval; % x-axis (time) in seconds
        Anglenods(count) = CurrAngle; % current angle
        % plotting A
        if(iset==1)
            datacolor='. b';
        else
            datacolor='. r';
        end
        plot(ax1,Anglenods(count),numofcountsA,datacolor,'MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting B
        plot(ax2,Anglenods(count),numofcountsB,datacolor,'MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AB
        plot(ax3,Anglenods(count),numofcountsAB,datacolor,'MarkerSize',20)
        %----------------------------------------------------------------------
        % Drawing Y-data of the three plots (A, B, AB) at the same time
        descriptionA = num2str(numofcountsA);
        %            title(ax1,descriptionA,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionB = num2str(numofcountsB);
        %            title(ax2,descriptionB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descriptionAB = num2str(round(numofcountsAB,0));
        %            title(ax3,descriptionAB,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w');
        
        descr = [' Motor Scan - Current Value:',num2str(CurrAngle),' Time per step = ',num2str(timeinterval),' s'];
        title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w')
        %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        axcredit=axes('position',[0.5 0.03 0.1 0.05],'visible','off');
        axcredit.Title.Visible = 'on';
        set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
        descr2 = strcat('Calculated accidentals =  ',accidentalsABstr);
        title(axcredit,descr2,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
        %
        if(iset==1)
            axcreditHHA=axes('position',[0.15 0.6 0.1 0.05],'visible','off');
            axcreditHHA.Title.Visible = 'on';
            set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
            descrHHA = strcat('  HH =  ',descriptionA,'  ');
            title(axcreditHHA,descrHHA,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
            %
            axcreditHHB=axes('position',[0.47 0.6 0.1 0.05],'visible','off');
            axcreditHHB.Title.Visible = 'on';
            set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
            descrHHB = strcat('  HH =  ',descriptionB,'  ');
            title(axcreditHHB,descrHHB,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
            %
            axcreditHHAB=axes('position',[0.79 0.6 0.1 0.05],'visible','off');
            axcreditHHAB.Title.Visible = 'on';
            set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
            descrHHAB = strcat('  HH =  ',descriptionAB,'  ');
            title(axcreditHHAB,descrHHAB,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
        else
            axcreditVVA=axes('position',[0.15 0.52 0.1 0.05],'visible','off');
            axcreditVVA.Title.Visible = 'on';
            set(get(gca,'title'),'color','r','background','w')% figure header text:white, background:blue
            descrVVA = strcat('  VV = ',descriptionA,'  ');
            title(axcreditVVA,descrVVA,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
            %
            axcreditVVB=axes('position',[0.47 0.52 0.1 0.05],'visible','off');
            axcreditVVB.Title.Visible = 'on';
            set(get(gca,'title'),'color','r','background','w')% figure header text:white, background:blue
            descrVVB = strcat('  VV = ',descriptionB,'  ');
            title(axcreditVVB,descrVVB,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
            %
            axcreditVVAB=axes('position',[0.79 0.52 0.1 0.05],'visible','off');
            axcreditVVAB.Title.Visible = 'on';
            set(get(gca,'title'),'color','r','background','w')% figure header text:white, background:blue
            descrVVAB = strcat('  VV = ',descriptionAB,'  ');
            title(axcreditVVAB,descrVVAB,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
        end
        drawnow
        %----------------------------------------------------------------------
        %% Storing Data in the resultsmatrix and finally in xlsx file
        resultsmatrix(count,1)=numofcountsA;
        resultsmatrix(count,2)=numofcountsB;
        resultsmatrix(count,3)=numofcountsAB;
        resultsmatrix(count,4)=accidentalsAB;
        CountsHHVV(count,iset)=numofcountsAB;
        %________________________________________________________________________
        % writing results gradually into the "Gradual Results' sheet in excel
        % file
        warning('off','MATLAB:xlswrite:AddSheet');
        % to suppress the warning when the sheet name is not in excel file.
        countt=num2str(numofmeasurements+3);% to go two lines further (count+1)in excel (because of the header)
        xlrange2=strcat('A',countt);
        accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
        %         xlswrite(xlsfilename,[str2double(VtoCD48),resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsindividual],Sheet1,xlrange2);
        xlswrite(xlsfilename,[CurrAngle,resultsmatrix(count,1:4)],Sheet1,xlrange2);
    end
    AngleHHVV(count)=CurrAngle;
    DiffHHVV(count)=CountsHHVV(count,1)-CountsHHVV(count,2);
    UncHHVV(count)=sqrt(CountsHHVV(count,1))+sqrt(CountsHHVV(count,2));
    count = count +1;
end
% Resetting the waveplates
            writeline(Right,'MA0'); % Setting HH
            writeline(Left,'MA0');
%     flushinput(CD48serial)
%     pause(0.1);
%     fprintf(CD48serial,'%s','V00'); % set voltage back to zero
%     pause(1);
fclose(scounter);  % close the serial port after the loop ends.
%clear CD48serial;
% Writing the average of the measurement results for the state into "Total
% Results" sheet
% countt=num2str((stateindexi-1)*2+3);
% xl2range2=strcat('A',countt);
accidentalstotal = sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
% xlswrite(xlsfilename,[str2double(VtoArduinos),sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotal],Sheet2,xl2range2)
pause(statepause);
count=1;
%clear scounter;
%% writing date and time of the results into the excle file
timeheader={'year','month','day','hour','minute','seconds'};
% "Gradual Results" sheet
countt=num2str((2*numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,timeheader,Sheet1,xlrange2)
countt=num2str((2*numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,clockt,Sheet1,xlrange2)
% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(((2*numofmeasurements+1)+4)));
xlrangetime=strcat('B',num2str(((2*numofmeasurements+1)+4)));
timestr={'timeinterval='};
xlswrite(xlsfilename,timestr,Sheet1,xlrangetimeheader)
xlswrite(xlsfilename,num2str(timeinterval),Sheet1,xlrangetime)
% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Fitting the function
%fitting parameters initial guess (done iteratively)
c(1)=400; % N_0
c(2)=50; %zero angle
% % once guesses are determined then proceed to fit
cfit = lsqcurvefit(@HHVVfit,c,AngleHHVV,DiffHHVV); % fit
% % Make a table
disp('Fitting parameters:');
disp(' ');
disp(' y = c(1)*cos(4*(x+c(2))/9*pi()/180); ');
disp(' parameter         value ')
Clab=['c(1) Max    ';
    'c(2) Zero   ']
ct = cfit';
Cs=num2str(ct);
Ctab=[Clab,Cs];
disp(Ctab)
% %% Plot the data and fit
yfit=HHVVfit(cfit,AngleHHVV); %Fitting function
%
% Getting a conservative uncertainty
%
chisq=sqrt(sum(((DiffHHVV-yfit)./UncHHVV).^2)/numofsteps); %starting chi square
z=cfit;
chisq1=chisq;
while abs(chisq-chisq1)<1 % loop to increase z(2) until chisquare increases by 1
    z(2)=z(2)*1.01;
    yfit2=z(1)*cos(4*(AngleHHVV+z(2))/9*pi()/180);
    chisq1=sqrt(sum(((DiffHHVV-yfit2)./UncHHVV).^2)/numofsteps);
end
unczero1=abs(z(2)-cfit(2)); % the uncertainty 
z=cfit;
chisq1=chisq;
while abs(chisq-chisq1)<1 % loop to increase z(2) until chisquare increases by 1
    z(2)=z(2)*0.99;
    yfit2=z(1)*cos(4*(AngleHHVV+z(2))/9*pi()/180);
    chisq1=sqrt(sum(((DiffHHVV-yfit2)./UncHHVV).^2)/numofsteps);
end
unczero2=abs(z(2)-cfit(2)); % the uncertainty %% Print the data
unczero=(unczero1+unczero2)/2;
unczerostr=num2str(round(unczero,0))
figure(2);
ymax=round(max(DiffHHVV),-2);
ymin=round(min(DiffHHVV),-2);
errorbar(AngleHHVV,DiffHHVV,UncHHVV,'bo','Markersize',3); % plot data with error bars
xlabel('Angle of Pump HWP (nods)'); %labels
ylabel('Count difference in HH-VV');
axis([StartAngle EndAngle ymin ymax]);
Maxstr=num2str(cfit(1));
zerocrossing=203-round(cfit(2),0)
Zerostr=num2str(203-round(cfit(2),0));
Zerocounts=num2str( cfit(1)*cos(4*(203)/9*pi()/180));
title(['Fitted: Max = ',Maxstr,' Zero = ',Zerostr,' +/- ',unczerostr,' N(',Zerostr,')=',Zerocounts]);
hold on;
plot(AngleHHVV,yfit,'r-');
grid on
hold off
%
% Finish
prompt = ' Do you want to set the waveplate to the zero crossing (y/n)? ';
setzero=input(prompt);
if setzero=='y'
    writeline(Pump,strcat('MA',Zerostr));
else
    writeline(Pump,'gh0');
end
    
clear Pump
clear Left
clear Right
%
%% Function used for fitting
%
function [ y ] = HHVVfit( c,x )
%This function is used to calculate the function that fits the data
%obtained in the single-photon experiment.
% The function is of the form:
% y = c1*(cos(4(x+c2)))
% The parameters are:
% c1 is the Number of counts
% c2 is the zero angle
y = -c(1)*cos(4*(x+c(2))/9*pi()/180);
end

