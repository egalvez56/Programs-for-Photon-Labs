%% Data Acquisition from Altera DE2 board through Serial port
% Free-running with 3 detectors
% Original Version Behzad Khajavi and Baibhav Sharma 5/2018
% Revision Kiko Galvez 3/2022
% Latest revision 3/16/22 KG
% Revised for long and short times down to 0.1 s 4/3/22 KG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% The goal is to take data from Altera DE2 board through a serial port.   %
% ALTERA sends out 8 numbers that are 32-bit numbers. They correspond to 8%
% counters which are A, B, A' and B' singles as well as AB, A'B, AB' and  %
% A'B' coincidences respectively.                                         %
%_________________________________________________________________________%
%                                                                         %
%*************************************************************************%
%_________________________________________________________________________%
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Kiko Galvez for 3 detectors 4/3/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2/23 SAME AS FreeRunning3DetectorsAlteraShortLongTimes - just a shorter
% name
clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none.
% The COM port is determined by the Device Manager in Windows.
prompt = {'Enter the COM# of the Counter:','number of intervals','time per interval',...
    'Name of file = ','Coincidence Time (ns)'};
dlg_title = 'Free Running Scan';
defaultans = {'COM19','200','1','Three','40'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1};
numofmeasurements= str2double(userinput{2}); % time interval for each measurement in seconds
timeinterval = str2double(userinput{3}); % time interval for each measurement in seconds
%nams = userinput{3};
nams = userinput{4};
datanam = strcat(nams,'.xlsx');  %'TM11805Normal3632'; % data name
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
Tcoincstr=userinput{5};
Tcoinc = str2double(Tcoincstr);


%% Loop

numofstates = 1; % # of states to do the tomography for
%numofmeasurements = 10; % # of measurements per each state
%timeinterval = 1; % time interval for each measurement in seconds
loop = numofmeasurements;
deltat = Tcoinc*1e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0;
clockt=fix(clock); % saving the initial date/time into a matrix
resultsmatrix=zeros(numofmeasurements,8);
% erasingmatrix(1:(numofmeasurements+1)*numofstates+3,1:8)="";% matrix defined to erase the excel sheet
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Sum of all points',num2str(clockt(1,4:6)));
% xlswrite('resultsmatrix.xlsx',erasingmatrix,Sheet1,'A1')%erasing sheet 1
% xlswrite('resultsmatrix.xlsx',erasingmatrix,Sheet2,'A1')%erasing sheet 2
% Start the excel file to write the gradual results
xlrange1='A1';

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
%Header1={'A','B','AB','Accidenals'};
%Header1={'A','B','A`','B`','AB','AA`','BB`','A`B`','Acc-AB','Acc-AA`','Acc-BB`','Acc-A`B`'};
Header1={'A','B','C','AB','AC,','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xlswrite(nams,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.

% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'A','B','C','AB','AC,','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xl2range1='A1';
xlswrite(nams,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.
    %% Figure adjustments
    screensize = get( groot, 'Screensize' ); %getting screen size
    position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
    f1=figure('Name','Free Running Scan','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
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
    set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue

for stateindexi=1:numofstates
    % header for each state measurement results in excel file "Gradual Results"
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    stateindexit=num2str(stateindexi);
    stateheader={'state #',stateindexit};
    xlswrite(nams,stateheader,Sheet1,xlrange2);
    % header for each state measurement results in excel file "Total Results"
    countt=num2str((stateindexi-1)*2+2);
    xl2range2=strcat('A',countt);
    xlswrite(nams,stateheader,Sheet2,xl2range2);

    %_____________________________________
    % Axes Properties
    % axes('position',[left bottom width height])

    % Axis for Header
    axheader=axes('position',[0.45 0.88 0.1 0.05],'visible','off');
    axheader.Title.Visible = 'on';
    set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
    %_____________________________________
    % Coincidence Time window
    axCoinc=axes('position',[0.8 0.88 0.1 0.05],'visible','off');
    axCoinc.Title.Visible = 'on';
    descrCoinc = ['Coinc. Time = ',Tcoincstr,' ns'];
    title(axCoinc,descrCoinc,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')
    set(get(gca,'title'),'color','w','background','b')
%     %_____________________________________
%     % Accidental windows
%     axAB=axes('position',[0.08 0.03 0.1 0.05],'visible','off');
%     axAB.Title.Visible = 'on';
%     set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%     axBAp=axes('position',[0.33 0.03 0.1 0.05],'visible','off');
%     axBAp.Title.Visible = 'on';
%     set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%     axABp=axes('position',[0.58 0.03 0.1 0.05],'visible','off');
%     axABp.Title.Visible = 'on';
%     set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%     axApBp=axes('position',[0.83 0.03 0.1 0.05],'visible','off');
%     axApBp.Title.Visible = 'on';
%     set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
    %_____________________________________
    % Axes for plots
    %
    % A
    plotwidth = 0.20;
    plotheight = 0.25;
    ax1 = axes('position',[0.08 0.57 plotwidth plotheight]); % Axies 1 position in the figure
    set(get(ax1,'title'),'color','w','background','b')
    ax1.XLim = [0 numofmeasurements];
    ax1.YLim = [0 inf];
    ax1.XLabel.String  = 'Step';ax1.XLabel.FontWeight = 'bold';
    ax1.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
    set(ax1,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax1.YLabel.String  = 'Singles A';ax1.YLabel.FontWeight = 'bold';
    ax1.YLabel.FontSize = 25;ax1.YLabel.FontName = 'TimesNewRoman';
    grid(ax1,'on');
    hold(ax1,'on')
    %____________________________________
    % B
    ax2 = axes('position',[0.40 0.57 plotwidth plotheight]); % Axies 2 position in the figure
    set(get(ax2,'title'),'color','w','background','b')
    ax2.XLim = [0 numofmeasurements];
    ax2.YLim = [0 inf];
    ax2.XLabel.String  = 'Step';ax2.XLabel.FontWeight = 'bold';
    ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
    set(ax2,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax2.YLabel.String  = 'Singles B';ax2.YLabel.FontWeight = 'bold';
    ax2.YLabel.FontSize = 25;ax2.YLabel.FontName = 'TimesNewRoman';
    grid(ax2,'on');
    hold(ax2,'on')
    %__________________________________________________________________
    % C
    ax3 = axes('position',[0.72 0.57 plotwidth plotheight]); % Axies 3 position in the figure
    set(get(ax3,'title'),'color','w','background','b')
    ax3.XLim=[0 numofmeasurements];
    ax3.YLim = [0 inf];
    ax3.XLabel.String  = 'Step';ax3.XLabel.FontWeight = 'bold';
    ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman'; %time font
    set(ax3,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax3.YLabel.String  = 'Singles C';ax3.YLabel.FontWeight = 'bold';% single font
    ax3.YLabel.FontSize = 25;ax3.YLabel.FontName = 'TimesNewRoman';
    grid(ax3,'on');
    hold(ax3,'on')
    %____________________________________
% Coinc.AB axes

    ax4 = axes('position',[0.08 0.18 plotwidth plotheight]); % Bob (d) position in the figure
    set(get(ax4,'title'),'color','w','background','b')
    ax4.XLim=[0 numofmeasurements];
    ax4.YLim = [0 inf];
    ax4.XLabel.String  = 'Step';ax4.XLabel.FontWeight = 'bold';
    ax4.XLabel.FontSize = 14;ax4.XLabel.FontName = 'TimesNewRoman';
    set(ax4,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax4.YLabel.String  = 'Doubles AB';ax4.YLabel.FontWeight = 'bold';
    ax4.YLabel.FontSize = 25;ax4.YLabel.FontName = 'TimesNewRoman';
    grid(ax4,'on');
    hold(ax4,'on')

    %___________________________________________________________________
    % AC
    ax5=axes('position',[0.4 0.18 plotwidth plotheight]); % Axies 5 position in the figure
    set(get(ax5,'title'),'color','w','background','b')
    ax5.XLim=[0 numofmeasurements];
    ax5.YLim = [0 inf];
    ax5.XLabel.String  = 'Step';ax5.XLabel.FontWeight = 'bold';
    ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
    set(ax5,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax5.YLabel.String  = 'Doubles AC';ax5.YLabel.FontWeight = 'bold';
    ax5.YLabel.FontSize = 25;ax5.YLabel.FontName = 'TimesNewRoman';
    grid(ax5,'on');
    hold(ax5,'on')
    %______________________________________________________________
    % ABC
    ax6=axes('position',[0.72 0.18 plotwidth plotheight]); % Axies 6 position in the figure
    set(get(ax6,'title'),'color','w','background','b')
    ax6.XLim=[0 numofmeasurements];
    ax6.YLim = [0 inf];
    ax6.XLabel.String  = 'Step';ax6.XLabel.FontWeight = 'bold';
    ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
    set(ax6,'XTick',0:numofmeasurements/10:numofmeasurements)
    ax6.YLabel.String  = 'Triples ABC';ax6.YLabel.FontWeight = 'bold';
    ax6.YLabel.FontSize = 25;ax6.YLabel.FontName = 'TimesNewRoman';
    grid(ax6,'on');
    hold(ax6,'on')

    %% The Loop
    fopen(scounter);  % open the serial port before the inner loop begins.
    %****************************************************************************
%    slowoption = true;
    while ~isequal(count,loop+1)
        numofcounts=zeros(1,8);
        % Serial data accessing
 %       if slowoption
 %%%%%%%%%%%%%%%%%% Long times
        if timeinterval > 10
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
        numofcountsA=numofcounts(1,1);
        numofcountsB=numofcounts(1,2);
        numofcountsC=numofcounts(1,3);
        numofcountsBprime=numofcounts(1,4);
        numofcountsAB=numofcounts(1,5);
%         numofcountsAprimeA=numofcounts(1,6);
%         numofcountsBBprime=numofcounts(1,7);
        numofcountsAC=numofcounts(1,6);
        numofcountsABC=numofcounts(1,7);
        %numofcountsAprimeBprime=numofcounts(1,8);

        %% Plotting the data points on different subplots
        % Drawing Y-data of the 8 plots (A, A', B, B', AA', BB', A'B', AB) at the same time
        time(count) = count; % x-axis (time) in seconds
        % plotting A
        plot(ax1,time(count),numofcountsA,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting C
        plot(ax3,time(count),numofcountsC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting B
        plot(ax2,time(count),numofcountsB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AB
        plot(ax4,time(count),numofcountsAB,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting AC
        plot(ax5,time(count),numofcountsAC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % plotting ABC
        plot(ax6,time(count),numofcountsABC,'. b','MarkerSize',20)
        %----------------------------------------------------------------------
        % Showing the numbers (counts) in the title of the axes 1-8
        descriptionA = num2str(numofcountsA);
        fontsize = 30;
        title(ax1,descriptionA,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');

        descriptionB = num2str(numofcountsB);
        title(ax2,descriptionB,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');

        descriptionC = num2str(numofcountsC);
        title(ax3,descriptionC,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');

        descriptionAB = num2str(numofcountsAB);
        title(ax4,descriptionAB,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');

        descriptionAC = num2str(numofcountsAC);
        title(ax5,descriptionAC,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');

        descriptionABC = num2str(numofcountsABC);
        title(ax6,descriptionABC,'FontWeight','bold','FontSize',fontsize,'FontName','Times New Roman');


        %    descr = ['QKD Data Acquisition: ','State # ',num2str(stateindexi),'/',num2str(numofstates),', measurement #',num2str(count),'/',num2str(numofmeasurements)];
        descr = ['Measurement: ',num2str(count),'/',num2str(numofmeasurements)];
        title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
        % Accidentals
        %
        accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
        accidentalsAC=numofcountsA*numofcountsC*deltat/timeinterval;
        accidentalsABC=(numofcountsC*numofcountsAB+numofcountsB*numofcountsAC)*deltat/timeinterval; %From Pearson and Jackson AJP 2010
        descraccAB = ['Acc AB=',num2str(accidentalsAB)];
        title(axAB,descraccAB,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')
        descraccAC = ['Acc AC=',num2str(accidentalsAC)];
        title(axAC,descraccAC,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')
        descraccABC = ['Acc ABC=',num2str(accidentalsABC)];
        title(axABC,descraccABC,'FontWeight','bold','FontSize',15,'FontName','TimesNew Roman')

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
        % xlswrite(nams',[resultsmatrix(count,1:2),resultsmatrix(count,5),accidentalsAB],Sheet1,xlrange2);
    xlswrite(nams,[resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsAB,accidentalsAC,accidentalsABC],Sheet1,xlrange2);
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
    nams=nams;
accidentalstotalAB=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
accidentalstotalAC=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,3))*deltat/(numofmeasurements*timeinterval);
accidentalstotalABC=(sum(resultsmatrix(1:numofmeasurements,2))*sum(resultsmatrix(1:numofmeasurements,5))+...
    sum(resultsmatrix(1:numofmeasurements,3))*sum(resultsmatrix(1:numofmeasurements,6)))*deltat/(numofmeasurements*timeinterval);
xlswrite(nams,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),...
    sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotalAB,...
    accidentalstotalAC,accidentalstotalABC],Sheet2,xl2range2)
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
xlswrite(nams,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
xlswrite(nams,clockt,Sheet1,xlrange2)

% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
xlswrite(nams,timeheader,Sheet2,xlrangetimeheader)
xlswrite(nams,clockt,Sheet2,xlrangetime)

parameterheader={'Time Interval (s)'};
countt=num2str(numofstates*(numofmeasurements)+7);
xlrange2=strcat('A',countt);
xlswrite(nams,parameterheader,Sheet1,xlrange2)
parameters=timeinterval;
countt=num2str(numofstates*(numofmeasurements)+8);
xlrange2=strcat('A',countt);
xlswrite(nams,parameters,Sheet1,xlrange2)
% save to "resultsmatrix.txt" file
%save('Tomographyresults.txt','resultsmatrix','-ascii')

