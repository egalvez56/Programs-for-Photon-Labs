

%% Data aquisition program with Altera DE2 bboard 
% The current problem is that this board is obsolete in 2021 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This program was originally written by Behzad Khajavi for the Altera DE2
% board on July 2017. This work was done at Colgate University.                 %
% 
%
% This program used the output of 3 detectors and takes data points step
% by step, where in between steps the user can make changes to the
% apparatus. For example, it can be used for th Hanbuty-Brown-Twiss test.
% The output is put in an Excel file.                                     %
%                                                                         %
%*************************************************************************%
%_________________________________________________________________________%
% To read Altera board:                                                   %
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
% Revision to add long and short times. by Kiko Galvez 4/22
% Modified to clear input buffers 5/29/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;
format compact
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none. 
% The COM port is determined by the Device Manager in Windows. 

 

%% Loop

% numofstates = 3; % # of states to do the tomography for
% numofmeasurements = 5; % # of measurements per each state 
% timeinterval = 2; % time interval for each measurement in seconds
% Input dialog
prompt = {'Enter # of states:','Enter # of measurements per state:','time interval','Counter COM port #: ','Excel file name'};
dlg_title = 'Quantum lab Inputs';
defaultans = {'3','1','1','COM7','Paused3'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
numofstates = str2double(userinput{1}); % # of states to do the tomography for
numofmeasurements = str2double(userinput{2}); % # of measurements per each state 
scounter = serial(userinput{4},'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
timeinterval = str2double(userinput{3}); % time interval for each measurement in seconds
% end of input dialo
timeaxislimit = numofstates*numofmeasurements;
loop = numofmeasurements; 
deltat=40e-9; % pulse width to calculate accidental coincidences
count=1; pausetime=0; time=zeros(loop);statepause=2;
clockt=fix(clock); % saving the initial date/time into a matrix
% myDatadimension=41*(timeinterval*10)+40; % timeinterval*10=timeinterval in seconds 
% cleandatadimension=41*(timeinterval*10);
% myData=zeros(myDatadimension,1);
resultsmatrix=zeros(numofmeasurements,8);

% Excel file definitions
Sheet1=strcat('Data points',num2str(clockt(1,4:6)));
Sheet2=strcat('Sum of all Points',num2str(clockt(1,4:6)));
xlrange1='A1';
warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
Header1={'A','B','C','AB','AC,','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xlsfilename = userinput{5};
xlswrite(xlsfilename,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.

% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
%Header2={'A','B','C','AB','AC','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
Header2={'A','B','C','AB','AC,','ABC','Acc-AB','Acc-AC','Acc-ABC'}; 
xl2range1='A1';
xlswrite(xlsfilename,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.

%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','CoincidenceABC','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
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
ax1 = axes('position',[0.08 0.57 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'color','w','background','b')
ax1.XLim = [0 timeaxislimit];
ax1.YLim = [0 inf];
% ax1.XLabel.String  = 'time (sec)';ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 14;ax1.XLabel.FontName = 'TimesNewRoman';
% set(ax1,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax1,'XTick',0:timeaxislimit/10:timeaxislimit)

ax1.YLabel.String  = 'singles A';ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 25;ax1.YLabel.FontName = 'TimesNewRoman';
grid(ax1,'on');
hold(ax1,'on')
%____________________________________
% singles B axes
ax2 = axes('position',[0.40 0.57 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'color','w','background','b')
ax2.XLim=[0 timeaxislimit];
ax2.YLim = [0 inf];
% ax2.XLabel.String  = 'time (sec)';ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 14;ax2.XLabel.FontName = 'TimesNewRoman';
% set(ax2,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax2,'XTick',0:timeaxislimit/10:timeaxislimit)

ax2.YLabel.String  = 'singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 25;ax2.YLabel.FontName = 'TimesNewRoman';
grid(ax2,'on')
hold(ax2,'on')
%____________________________________
% singles C axes
ax4=axes('position',[0.72 0.57 0.25 0.3]); % Axies 3 position in the figure
set(get(ax4,'title'),'color','w','background','b')
ax4.XLim=[0 timeaxislimit];
ax4.YLim = [0 inf];
% ax4.XLabel.String  = 'time (sec)';ax4.XLabel.FontWeight = 'bold';
ax4.XLabel.FontSize = 14;ax4.XLabel.FontName = 'TimesNewRoman';
% set(ax4,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax4,'XTick',0:timeaxislimit/10:timeaxislimit)

ax4.YLabel.String  = 'singles C';ax4.YLabel.FontWeight = 'bold';
ax4.YLabel.FontSize = 25;ax4.YLabel.FontName = 'TimesNewRoman';
grid(ax4,'on')
hold(ax4,'on')
%____________________________________
% Coinc.AB axes
ax3=axes('position',[0.08 0.18 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'color','w','background','b')
ax3.XLim=[0 timeaxislimit];
ax3.YLim = [0 inf];
ax3.XLabel.String  = 'Measurement';ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 14;ax3.XLabel.FontName = 'TimesNewRoman';
% set(ax3,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax3,'XTick',0:timeaxislimit/10:timeaxislimit)

ax3.YLabel.String  = 'Coinc. AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 25;ax3.YLabel.FontName = 'TimesNewRoman';
grid(ax3,'on')
hold(ax3,'on')
%_____________________________
% Coinc.AC axes
ax5=axes('position',[0.4 0.18 0.25 0.3]); % Axies 3 position in the figure
set(get(ax5,'title'),'color','w','background','b')
ax5.XLim=[0 timeaxislimit];
ax5.YLim = [0 inf];
ax5.XLabel.String  = 'Measurement';ax5.XLabel.FontWeight = 'bold';
ax5.XLabel.FontSize = 14;ax5.XLabel.FontName = 'TimesNewRoman';
% set(ax5,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax5,'XTick',0:timeaxislimit/10:timeaxislimit)

ax5.YLabel.String  = 'Coinc. AC';ax5.YLabel.FontWeight = 'bold';
ax5.YLabel.FontSize = 25;ax5.YLabel.FontName = 'TimesNewRoman';
grid(ax5,'on')
hold(ax5,'on')
%____________________________________
% Coinc.ABC axes
ax6=axes('position',[0.72 0.18 0.25 0.3]); % Axies 3 position in the figure
set(get(ax6,'title'),'color','w','background','b')
ax6.XLim=[0 timeaxislimit];
ax6.YLim = [0 inf];
ax6.XLabel.String  = 'Measurement';ax6.XLabel.FontWeight = 'bold';
ax6.XLabel.FontSize = 14;ax6.XLabel.FontName = 'TimesNewRoman';
% set(ax6,'XTick',1:timeinterval:timeaxislimit*timeinterval)
set(ax6,'XTick',0:timeaxislimit/10:timeaxislimit)

ax6.YLabel.String  = 'Coinc. ABC';ax6.YLabel.FontWeight = 'bold';
ax6.YLabel.FontSize = 25;ax6.YLabel.FontName = 'TimesNewRoman';
grid(ax6,'on')
hold(ax6,'on')
%______________________________________________________________

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

% %______________________________________________________________
%% The Loop
fopen(scounter);  % open the serial port before the inner loop begins.
%****************************************************************************

while ~isequal(count,loop+1)
        numofcounts=zeros(1,8);
    
    % Serial data accessing 
    
%     for i=1:timeinterval
%             myData1 = fread(scounter,512,'uint8'); % reading # of bytes
%             myData(1,(i-1)*512+1:i*512) = myData1';
%     end 
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
    numofcountsA=numofcounts(1,1);
    numofcountsB=numofcounts(1,2);
%   numofcountsAprime=numofcounts(1,3);
    numofcountsC = numofcounts(1,3);% C detector
    numofcountsBprime=numofcounts(1,4);
    numofcountsAB=numofcounts(1,5);
%   numofcountsAprimeB=numofcounts(1,6);
%   numofcountsABprime=numofcounts(1,7);
    numofcountsAC = numofcounts(1,6);% AC Coincidence
    numofcountsABC = numofcounts(1,7);% ABC Coincidence
   % numofcountsAprimeBprime=numofcounts(1,8);
    
    %% Plotting the data points on different subplots  
    time(count) = (stateindexi-1)*numofmeasurements+count; % x-axis (time) in seconds   
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

    descr = ['CoincidenceABC:','State # ',num2str(stateindexi),'/',num2str(numofstates),', measurement #',num2str(count),'/',num2str(numofmeasurements)];
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
    xlswrite(xlsfilename,[resultsmatrix(count,1:3),resultsmatrix(count,5:7),accidentalsAB,accidentalsAC,accidentalsABC],Sheet1,xlrange2);
    count = count +1;

end

fclose(scounter);  % close the serial port after the inner loop ends.
% pause(2)
%     if stateindexi~=numofstates
%         close all
%     end 

% Writing the average of the measurement results for the state into "Total
% Results" sheet
countt=num2str((stateindexi-1)*2+3);
xl2range2=strcat('A',countt);
accidentalstotalAB=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,2))*deltat/(numofmeasurements*timeinterval);
accidentalstotalAC=sum(resultsmatrix(1:numofmeasurements,1))*sum(resultsmatrix(1:numofmeasurements,3))*deltat/(numofmeasurements*timeinterval);
accidentalstotalABC=(sum(resultsmatrix(1:numofmeasurements,2))*sum(resultsmatrix(1:numofmeasurements,5))+...
    sum(resultsmatrix(1:numofmeasurements,3))*sum(resultsmatrix(1:numofmeasurements,6)))*deltat/(numofmeasurements*timeinterval);
xlswrite(xlsfilename,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,3)),...
    sum(resultsmatrix(1:numofmeasurements,5)),sum(resultsmatrix(1:numofmeasurements,6)),sum(resultsmatrix(1:numofmeasurements,7)),accidentalstotalAB,...
    accidentalstotalAC,accidentalstotalABC],Sheet2,xl2range2)
% pause(statepause);
count=1;
% Prompt User to have a Pause between the states
prompt = {'click OK to continue'};
dlg_title = 'PAUSE';
descripion = strcat('State # ',' ',num2str(stateindexi+1),'? ');
defaultans = {[descripion,' You are doing a good job']};
if stateindexi==numofstates
    defaultans = {'Operation Completed. All done'};
end
answer = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
%______________________________________________

end
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

parameterheader={'Time Interval (s)'};
countt=num2str(numofstates*(numofmeasurements)+7);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,parameterheader,Sheet1,xlrange2)

parameters=timeinterval;
countt=num2str(numofstates*(numofmeasurements)+8);
xlrange2=strcat('A',countt);
xlswrite(xlsfilename,parameters,Sheet1,xlrange2)
% save to "resultsmatrix.txt" file
save('CoincidenceABC.txt','resultsmatrix','-ascii')

