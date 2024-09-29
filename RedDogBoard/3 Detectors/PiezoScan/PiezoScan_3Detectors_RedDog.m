%% Data aquisition from Altera DE2 board through Serial port
% Tomography
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%
%                                                                         %
% This program is written by Bhzad Khajavi in July 2017. Modified by      %
% Kiko in 2021. The goal is to take data from CD48 board.                 %
% This program was written based on a similar                             %
% program written for the Altera DE2 board.                               %
% Kiko Galvez modified it in June-July 2021.                              %
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
prompt = {'Enter the COM# of the Counter:','Start Voltage','End Voltage','V Increment','time interval','Excel file name'};
dlg_title = 'Quantum lab Inputs for Triple Coinc. Voltage Scan';
defaultans = {'COM19','1','4','0.02','1','LabSPint'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1}; % COM port
% Reading parameters for Voltage scan
StartVoltage = str2double(userinput{2});
EndVoltage = str2double(userinput{3});
DeltaV=EndVoltage-StartVoltage;
Increment = str2double(userinput{4});
numofsteps = round(DeltaV/Increment,0); %defines the number of measurements
timeinterval = str2double(userinput{5}); % time interval for each measurement in seconds
CD48serial = serial(counterportnum,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
fopen(CD48serial);  % open the Counter serial port before the inner loop begins.
numofstates=1; % In principle set up for taking several measurements per point
numofmeasurements = numofsteps+1;
loop = numofmeasurements;
deltat=20e-9; % coincidence time to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0; % initializing counters
clockt=fix(clock); % saving the initial date/time into a matrix
%
%% Setting up output to Excel file
%
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
% Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'V','A','B','C','AB','AC','ABC','Accidentals'};
xlsfilename = [userinput{6},'Vscan'];
xlswrite(xlsfilename,Header1,Sheet1,xlrange1)
% xlswrite('CoincidenceABC.xlsx',Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
% Start the excel file to write the "Total Results" sheet
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'V','A','B','C','AB','AC','ABC','Accidentals'};
xl2range1='A1';
% xlswrite(xlsfilename,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%
%% The outer Loop (repeats number of states per voltage, set to 1 for now 7/21)
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
    % xlswrite('CoincidenceABC.xlsx',stateheader,Sheet2,xl2range2);
    %% Figure adjustments
    screensize = get( groot, 'Screensize' ); %getting screen size
    position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
    f1=figure('Name','Triple Coincidence ABC Voltage Scan','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
    %_____________________________________
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
    set(get(ax1,'title'),'background','y')
    % ax1.XLim = [0 numofmeasurements+1];
    ax1.XLim = [StartVoltage EndVoltage];
    ax1.YLim = [0 inf];
    % ax1.XLabel.String  = 'time (sec)';ax1.XLabel.FontWeight = 'bold';
    ax1.XLabel.FontSize = 14;ax1.XLabel.FontName = 'TimesNewRoman';
    set(ax1,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax1.YLabel.String  = 'Singles A';ax1.YLabel.FontWeight = 'bold';
    ax1.YLabel.FontSize = 20;ax1.YLabel.FontName = 'TimesNewRoman';
    grid(ax1,'on');
    hold(ax1,'on')
    %____________________________________
    % singles B axes
    ax2 = axes('position',[0.40 0.57 0.25 0.3]); % Axes 2 position in the figure
    set(get(ax2,'title'),'background','y')
    ax2.XLim=[StartVoltage EndVoltage];
    ax2.YLim = [0 inf];
    % ax2.XLabel.String  = 'time (sec)';ax2.XLabel.FontWeight = 'bold';
    ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
    set(ax2,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
    ax2.YLabel.FontSize = 20;ax2.YLabel.FontName = 'TimesNewRoman';
    grid(ax2,'on')
    hold(ax2,'on')
    %____________________________________
    % singles C axes
    ax4=axes('position',[0.72 0.57 0.25 0.3]); % Axes 4 position in the figure
    set(get(ax4,'title'),'background','y')
    ax4.XLim=[StartVoltage EndVoltage];
    ax4.YLim = [0 inf];
    % ax4.XLabel.String  = 'time (sec)';ax4.XLabel.FontWeight = 'bold';
    ax4.XLabel.FontSize = 146;ax4.XLabel.FontName = 'TimesNewRoman';
    set(ax4,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax4.YLabel.String  = 'singles C';ax4.YLabel.FontWeight = 'bold';
    ax4.YLabel.FontSize = 20;ax4.YLabel.FontName = 'TimesNewRoman';
    grid(ax4,'on')
    hold(ax4,'on')
    %____________________________________
    % Coinc.AB axes
    ax3=axes('position',[0.08 0.175 0.25 0.3]); % Axes 3 position in the figure
    set(get(ax3,'title'),'background','y')
    ax3.XLim=[StartVoltage EndVoltage];
    ax3.YLim = [0 inf];
    ax3.XLabel.String  = 'Voltage (V)';ax3.XLabel.FontWeight = 'bold';
    ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman';
    set(ax3,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax3.YLabel.String  = 'Coincidences AB';ax3.YLabel.FontWeight = 'bold';
    ax3.YLabel.FontSize = 20;ax3.YLabel.FontName = 'TimesNewRoman';
    grid(ax3,'on')
    hold(ax3,'on')
    %_____________________________
    % Coinc.AC axes
    ax5=axes('position',[0.4 0.17 0.25 0.3]); % Axes 5 position in the figure
    set(get(ax5,'title'),'background','y')
    ax5.XLim=[StartVoltage EndVoltage];
    ax5.YLim = [0 inf];
    ax5.XLabel.String  = 'Voltage (V)';ax5.XLabel.FontWeight = 'bold';
    ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
    set(ax5,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax5.YLabel.String  = 'Coincidences AC';ax5.YLabel.FontWeight = 'bold';
    ax5.YLabel.FontSize = 20;ax5.YLabel.FontName = 'TimesNewRoman';
    grid(ax5,'on')
    hold(ax5,'on')
    %____________________________________
    % Coinc.ABC axes
    ax6=axes('position',[0.72 0.17 0.25 0.3]); % Axes 6 position in the figure
    set(get(ax6,'title'),'background','y')
    ax6.XLim=[StartVoltage EndVoltage];
    ax6.YLim = [0 inf];
    ax6.XLabel.String  = 'Voltage (V)';ax6.XLabel.FontWeight = 'bold';
    ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
    set(ax6,'XTick',StartVoltage:DeltaV/10:EndVoltage)
    ax6.YLabel.String  = 'Coincidences ABC';ax6.YLabel.FontWeight = 'bold';
    ax6.YLabel.FontSize = 20;ax6.YLabel.FontName = 'TimesNewRoman';
    grid(ax6,'on')
    hold(ax6,'on')
    %______________________________________________________________
    %% Setting up the Coincidence board
    %
    %fprintf(CD48serial,'%s','v'); %reset to firmware
    pause(0.1)
    fprintf(CD48serial,'%s','T');
    fprintf(CD48serial,'%s','S01000'); % counter 1 A
    fprintf(CD48serial,'%s','S10100'); % counter 2 B
    fprintf(CD48serial,'%s','S20001'); % counter 3 D
    fprintf(CD48serial,'%s','S30010'); % counter 4 C
    fprintf(CD48serial,'%s','S41100'); % counter 5 AB
    fprintf(CD48serial,'%s','S51001'); % counter 6 AC
    fprintf(CD48serial,'%s','S61110'); % counter 7 ABC 
    fprintf(CD48serial,'%s','S71010'); % counter 8 AD
    fprintf(CD48serial,'%s','L050'); % pulse threshold
    fprintf(CD48serial,'%s','z'); %50 ohm impedance
    %timeintervals = '2'; % time interval for each measurement in seconds
    timeinms=num2str(floor(timeinterval*1000)); % time interval in ms
    disp(timeinterval);
    disp(timeinms);
    onesec=num2str(1000);%%% 1 s increments
%    onetenthsec=num2str(100);%%% 0.1s increments
     timetobox = strcat('r','0',onesec); %%%
     timeinds=timeinterval*10;
%     timetobox = strcat('r','00',onetenthsec); %%%
%     if timeinterval < 1
%         timetobox = strcat('r','00',timeinms); % set up repeat command (counter accumulation time) to time interval
%     elseif timeinterval < 10
%         timetobox = strcat('r','0',timeinms); % set up repeat command (counter accumulation time) to time interval
%     else
%         timetobox = strcat('r',timeinms); % set up repeat command (counter accumulation time) to time interval
%     end
    disp(timetobox);
    fprintf(CD48serial,'%s','R'); % Repeat off
    pause(0.1)
    fprintf(CD48serial,'%s',timetobox); % program the repeat time in mseconds
    pause(0.1)
    fprintf(CD48serial,'%s','R'); % Repeat on
    %fprintf(CD48serial,'%s','r02000'); % program the repeat time to be 0.1 seconds
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

    %% Loop to take data
    %
    while ~isequal(count,loop+1) % outer loop measurements per voltage step
 %       numofcounts = zeros(9,1);
        flushinput(CD48serial)
        pause(0.01)
        %    Setting Piezo Voltage
        % Reading Piezo_slider
        VtoCD48 = StartVoltage + (count-1)*Increment;
        VtoCD48num = floor(VtoCD48*(255/4));
        % Seding Voltage to CD48
        VtoCD48s = num2str(VtoCD48num);
        pause(0.01)
        if VtoCD48num < 100 && VtoCD48num > 10
            VtoCD48s = strcat('0',num2str(VtoCD48num))
        end
        if VtoCD48num < 10
            VtoCD48s = strcat('00',num2str(VtoCD48num))
        end
        fprintf(CD48serial,'%s',strcat('V',VtoCD48s))
        flushinput(CD48serial)
        pause(timeinterval)
        numofcounts(:,1)=fscanf(CD48serial,'%d\n');
        for jj=1:(timeinterval-1) %%%
                pause(timeinterval); %%%
                 numofcounts(:,1)=numofcounts(:,1)+fscanf(CD48serial,'%d\n'); %%%
        end %%%
        flushinput(CD48serial)
        numofcountsA = numofcounts(1,1); % A detector
        numofcountsB = numofcounts(2,1); % B detector
        numofcountsC = numofcounts(4,1);% C detector
        numofcountsD = numofcounts(3,1); % AD detector
        numofcountsAB = numofcounts(5,1); %AB coincidences
        numofcountsAC = numofcounts(8,1);% AC Coincidence
        numofcountsAD = numofcounts(6,1); % AD
        numofcountsABC=numofcounts(7,1); % ABC Coincidence
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
        accidentalsAC=numofcountsA*numofcountsC*deltat/timeinterval;
        accidentalsACstr=num2str(round(accidentalsAC))  ;  %     numofcountsA=numofcounts(1,1);
        accidentalsABC=numofcountsA*numofcountsB*numofcountsC*deltat^2/timeinterval^2;
        accidentalsABCstr=num2str(round(accidentalsABC));    %     numofcountsA=numofcounts(1,1);
        %     else
        %         numofcountsA = 0;
        %         numofcountsB = 0;
        %         numofcountsC = 0;% C detector
        %         numofcountsBprime = 0;
        %         numofcountsAB = 0;
        %         numofcountsAC = 0;% AC Coincidence
        %         numofcountsABC = 0;% ABC Coincidence
        %         numofcountsAprimeBprime = 0;
        %    end
        %% Plotting the data points on different subplots
        %     time(count) = count*timeinterval; % x-axis (time) in seconds
        voltage(count) = VtoCD48; % x-axis (time) in seconds
        % plotting A
        plot(ax1,voltage(count),numofcountsA,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting B
        plot(ax2,voltage(count),numofcountsB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting C
        plot(ax4,voltage(count),numofcountsC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        
        % plotting AB
        plot(ax3,voltage(count),numofcountsAB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AC
        plot(ax5,voltage(count),numofcountsAC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting ABC
        plot(ax6,voltage(count),numofcountsABC,'. b','MarkerSize',20)
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
        
        descr = ['Triple Coincidence ABC Voltage Scan:',num2str(VtoCD48)];
        title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman','color','b','background','w')
        %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        axcredit=axes('position',[0.5 0.01 0.1 0.05],'visible','off');
        axcredit.Title.Visible = 'on';
        set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
        descr2 = strcat('Accidentals: AB = ',accidentalsABstr,', AC = ',accidentalsACstr,', ABC = ',accidentalsABCstr);
        title(axcredit,descr2,'FontWeight','bold','FontSize',20,'FontName','TimesNew Roman','color','b','background','w')
        drawnow
        %----------------------------------------------------------------------
        %% Storing Data in the resultsmatrix and finally in xlsx file
        resultsmatrix(count,1)=numofcountsA;
        resultsmatrix(count,2)=numofcountsB;
        resultsmatrix(count,3)=numofcountsC;
        resultsmatrix(count,4)=numofcountsD;
        resultsmatrix(count,5)=numofcountsAB;
        resultsmatrix(count,6)=numofcountsAC;
        resultsmatrix(count,8)=numofcountsAD;
        resultsmatrix(count,7)=numofcountsABC;
        %________________________________________________________________________
        % writing results gradually into the "Gradual Results' sheet in excel
        % file
        warning('off','MATLAB:xlswrite:AddSheet');
        % to suppress the warning when the sheet name is not in excel file.
        countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
        xlrange2=strcat('A',countt);
        accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
        %         xlswrite(xlsfilename,[str2double(VtoCD48),resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsindividual],Sheet1,xlrange2);
        xlswrite(xlsfilename,[VtoCD48,resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsindividual],Sheet1,xlrange2);
        count = count +1;
    end
    flushinput(CD48serial)
    pause(0.1);
    fprintf(CD48serial,'%s','V00'); % set voltage back to zero
    pause(1);
    fclose(CD48serial);  % close the serial port after the inner loop ends.
    clear CD48serial;
    % Writing the average of the measurement results for the state into "Total
    % Results" sheet
    % countt=num2str((stateindexi-1)*2+3);
    % xl2range2=strcat('A',countt);
    accidentalstotal = sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
    % xlswrite(xlsfilename,[str2double(VtoArduinos),sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotal],Sheet2,xl2range2)
    pause(statepause);
    count=1;
end
clear scounter;
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
%xlswrite(xlsfilename,timeheader,Sheet2,xlrangetimeheader)
%xlswrite(xlsfilename,clockt,Sheet2,xlrangetime)
% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')

