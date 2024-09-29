
% Paused2DetectorsAltera
%% Data aquisition from Altera DE2 board through Serial port
% Bell test (mod KG 4/20)

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
% bytes of 7-bit figures per number. Transmitting through the serial port
% %
% each number becomes 5 8-bit bytes + a termination byte. Eventually      %
% reading the data with MatLab using 19200 baudrate we receive            %
% 8 (# of countes)*5(bytes per number)+1= 41 numbers in the array.        %
% In order to calculate the actual number for a counter, say A, we mu     %
% multiply the corresponding figures by 2^0, 2^7, 2^14, 2^21 and 2^28.    %
% We save the numbers and plot them.                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Kiko to add number of intervals to the dialog box. Fixed a 
% bug to do with the file name.. 4/24/21, Modified to include short and 
% long times KG 5/22
% modified by adding buffer-clearing lines 5/12/22
clc;
clear;
close all;
format compact


%% Loop
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prompt = {'Enter the COM# of the Counter:','time interval','Name of file = '};
prompt = {'Enter the COM# of the Counter:','number of intervals','time per interval','Name of file = '};
dlg_title = 'Two Detectors';
%defaultans = {'COM6','1','Bell'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
defaultans = {'COM19','50','1','FreeRun2'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1};
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
%timeinterval = str2double(userinput{2}); % time interval for each measurement in seconds
numofstates= str2double(userinput{2}); % number of measurements
timeinterval = str2double(userinput{3}); % time interval for each measurement in seconds
%nams = userinput{3};
nams = userinput{4};
datanam = strcat(nams,'.xlsx');  %'TM11805Normal3632'; % data name
dateexp = date; % date
%numofstates = 4; % # of states for the manual scan 
numofmeasurements = numofstates; % # of measurements  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = numofmeasurements; 
timeaxislimit = numofstates*numofmeasurements*timeinterval;
deltat = 40e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=0;
clockt = fix(clock); % saving the initial date/time into a matrix
myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
cleandatadimension=41*(timeinterval*10);
myData=zeros(myDatadimension,1);
resultsmatrix=zeros(numofmeasurements,8);
% erasingmatrix(1:(numofmeasurements+1)*numofstates+3,1:8)="";% matrix defined to erase the excel sheet
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Average results',num2str(clockt(1,4:6)));
% Start the excel file to write the gradual results
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'A','B','AB','Accidentals'}; 
%xlswrite('Bell.xlsx',Header1,Sheet1,xlrange1)
xlswrite(datanam,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%-------------------------------------
% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header2={'A','B','AB','Accidentals'}; 
xl2range1='A1';
%xlswrite('Bell.xlsx',Header2,Sheet2,xl2range1)
xlswrite(datanam,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.


%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Free Running','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
% hold on
%_____________________________________
% Axes Properties
% axes('position',[left bottom width height])

% Axis for Header
axheader=axes('position',[0.45 0.7 0.1 0.05],'visible','off');
axheader.Title.Visible = 'on';
set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
%_____________________________________
% Axes for plots
ax1 = axes('position',[0.08 0.25 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'color','w','background','b')% figure header text:white, background:blue
ax1.XLim = [0 numofmeasurements]; %numofstates*timeinterval+1];
% ax1.XLabel.String  = 'time (sec)';
% ax1.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax1.XLabel.String  = 'Step';
ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 12; ax1.XLabel.FontName = 'TimesNewRoman';
% set(ax1,'XTickL',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17],{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
set(ax1,'XTick',0:numofmeasurements/10:numofmeasurements);%0:1*timeinterval:numofstates*timeinterval)
%set(ax1,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','ex'});
ax1.YLabel.String  = 'singles A';
ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 25;ax1.YLabel.FontName = 'TimesNewRoman';
ax1.YLim = [0 inf];
grid(ax1,'on');
hold(ax1,'on')
%____________________________________

ax2 = axes('position',[0.40 0.25 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'color','w','background','b')% figure header text:white, background:blue
ax2.XLim=[0 numofmeasurements];%numofstates*timeinterval+1];
% ax2.XLabel.String  = 'time (sec)';
% ax2.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax2.XLabel.String  = 'Step';
ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 12;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',0:numofmeasurements/10:numofmeasurements);%0:1*timeinterval:numofstates*timeinterval)
%set(ax2,'XTicklabel',{'11','21','31','41','12','22','32','42','31','32','33','34','41','42','43','44','ex'})
%set(ax2,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','ex'})
ax2.YLabel.String  = 'singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 25;ax2.YLabel.FontName = 'TimesNewRoman';
ax2.YLim = [0 inf];
grid(ax2,'on')
hold(ax2,'on')
%____________________________________

ax3=axes('position',[0.72 0.25 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'color','w','background','b')% figure header text:white, background:blue
ax3.XLim=[0 numofmeasurements];% numofstates*timeinterval+1];
% ax3.XLabel.String  = 'time (sec)';
% ax3.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax3.XLabel.String  = 'Step';
ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 12;ax3.XLabel.FontName = 'TimesNewRoman';
set(ax3,'XTick',0:numofmeasurements/10:numofmeasurements);%1:1*timeinterval:numofstates*timeinterval)
%set(ax3,'XTicklabel',{'11','21','31','41','12','22','32','42','31','32','33','34','41','42','43','44','ex'})
%set(ax3,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','ex'})
ax3.YLabel.String  = 'Coinc. AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 25;ax3.YLabel.FontName = 'TimesNewRoman';
ax3.YLim=[0 inf];
grid(ax3,'on')
hold(ax3,'on')
%______________________________________________________________

%for stateindexi=1:numofstates
stateindexi=1;
% prompt = {'Set the wave plates and then click OK'};
% dlg_title = 'Wave plate Orientation';
% userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30]);

%-----------------------------------------------------------   
% header for each state measurement results in excel file "Gradual Results"
countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
xlrange2=strcat('A',countt);
stateindexit=num2str(stateindexi);
stateheader={'state #',stateindexit};
%xlswrite('Bell.xlsx',stateheader,Sheet1,xlrange2);
xlswrite(datanam,stateheader,Sheet1,xlrange2);
% header for each state measurement results in excel file "Total Results"
countt=num2str((stateindexi-1)*2+2);
xl2range2=strcat('A',countt);
%xlswrite('Bell.xlsx',stateheader,Sheet2,xl2range2);
xlswrite(datanam,stateheader,Sheet2,xl2range2);

% %______________________________________________________________
%% The Loop
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none. 
% The COM port is determined by the Device Manager in Windows.
 
fopen(scounter);  % open the serial port before the inner loop begins.
%****************************************************************************

while ~isequal(count,loop+1)
        numofcounts=zeros(1,8);
    % Serial data accessing
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
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
%             pause(1);
            flushinput(scounter);
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes            
            flushinput(scounter);
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
            myData0 = fread(scounter,512,'uint8'); % reading # of bytes
%            pause(1);
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
    
%     % Serial data accessing 
%     
%     for i=1:timeinterval
%          myData1 = fread(scounter,512,'uint8'); % reading # of bytes
%          myData(1,(i-1)*512+1:i*512) = myData1';
%     end 
%     
%     % finding terminationbyte if the 41th element of myData is not 255
%     tbi=0;
%     if myData(1,41)~=255
%         for i=1:40
%            if myData(1,i)==255
%                terminationbyteindex=i;
%            end
%         end 
%         tbi=terminationbyteindex;
%     end 
%     % saving myData portion into cleandata so the array starts with A
%     % that is right after the first termination byte (255)
%     
%     cleandata=myData(1,tbi+1:tbi+cleandatadimension);
%     numofcounts=zeros(1,8);
%     CD=cleandata; % just to use a shorthand notation CD
%     kmax=timeinterval*10; % loop repetation numner for each counter
%     L=0;j=0;
%     for i=1:8
%         j=0;
%         for k=1:kmax         
%             numofcounts(1,i)=numofcounts(1,i)+CD(1,1+j+L)+2^7*CD(1,2+j+L)+2^14*CD(1,3+j+L)+2^21*CD(1,4+j+L)+2^28*CD(1,5+j+L);
%             j=j+41; % the corresponding figure after a tenth of a second
%         end
%         L=L+5; % next counter partition starts at the next 5th byte
%     end 
    numofcountsA=numofcounts(1,1);
    n1(stateindexi)=numofcountsA;
    numofcountsB=numofcounts(1,2);
    n2(stateindexi)=numofcountsB;
    numofcountsAprime=numofcounts(1,3);
    numofcountsBprime=numofcounts(1,4);
    numofcountsAB=numofcounts(1,5);
    n(stateindexi)=numofcountsAB;
    numofcountsAprimeB=numofcounts(1,6);
    numofcountsABprime=numofcounts(1,7);
    numofcountsAprimeBprime=numofcounts(1,8);
    accidentals=numofcountsA*numofcountsB*deltat/timeinterval;
    accidentalsstr=num2str(round(accidentals));    
    
    %% Plotting the data points on different subplots  
    time(count) =count; % x-axis (time) in seconds   
    % plotting A    
      plot(ax1,time(count),numofcounts(1,1),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B
      plot(ax2,time(count),numofcounts(1,2),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AB
      plot(ax3,time(count),numofcounts(1,5),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % Drawing Y-data of the three plots (A, B, AB) at the same time
    descriptionA = num2str(numofcounts(1,1));    
    title(ax1,descriptionA,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');
    
    descriptionB = num2str(numofcounts(1,2));
    title(ax2,descriptionB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');
    
    descriptionAB = num2str(numofcounts(1,5));
    title(ax3,descriptionAB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');
    
    descr = ['Free-running scan: ',' measurement #',num2str(count),'/',num2str(numofmeasurements)];
    title(axheader,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
%     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
    axcredit=axes('position',[0.5 0.03 0.1 0.05],'visible','off');
    axcredit.Title.Visible = 'on';
    set(get(gca,'title'),'color','b','background','w')% figure header text:white, background:blue
    descr2 = strcat('Calculated accidentals =  ',accidentalsstr);
    title(axcredit,descr2,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')
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
%    xlswrite('Bell.xlsx',[resultsmatrix(count,1:2),resultsmatrix(count,5),accidentalsindividual],Sheet1,xlrange2);
    xlswrite(datanam,[resultsmatrix(count,1:2),resultsmatrix(count,5),accidentalsindividual],Sheet1,xlrange2);
    count = count +1;

end

fclose(scounter);  % close the serial port after the inner loop ends.
pause(2)
%     if stateindexi~=numofstates
%         close all
%     end 

% Writing the average of the measurement results for the state into "Total
% Results" sheet
countt=num2str((stateindexi-1)*2+3);
xl2range2=strcat('A',countt);
accidentalstotal=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
%xlswrite('Bell.xlsx',[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,5)),accidentalstotal],Sheet2,xl2range2)
xlswrite(datanam,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,5)),accidentalstotal],Sheet2,xl2range2)
pause(statepause);
count=1;

%end
clear s;
%% writing date and time of the results into the excle files

timeheader={'year','month','day','hour','minute','seconds'};

% "Gradual Results" sheet
countt=num2str(numofstates*(numofmeasurements+1)+2);
xlrange2=strcat('A',countt);
%xlswrite('Bell.xlsx',timeheader,Sheet1,xlrange2)
xlswrite(datanam,timeheader,Sheet1,xlrange2)
countt=num2str(numofstates*(numofmeasurements+1)+3);
xlrange2=strcat('A',countt);
%xlswrite('Bell.xlsx',clockt,Sheet1,xlrange2)
xlswrite(datanam,clockt,Sheet1,xlrange2)

% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
xlrangetime=strcat('A',num2str(numofstates*2+3));
% xlswrite('Bell.xlsx',timeheader,Sheet2,xlrangetimeheader)
% xlswrite('Bell.xlsx',clockt,Sheet2,xlrangetime)
xlswrite(datanam,timeheader,Sheet2,xlrangetimeheader)
xlswrite(datanam,clockt,Sheet2,xlrangetime)

% save to "resultsmatrix.txt" file
%save('Bell.txt','resultsmatrix','-ascii')


