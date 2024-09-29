

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
% bytes of 7-bit figures per number. Transmitting through the serial port %
% each number becomes 5 8-bit bytes + a termination byte. Eventually      %
% reading the data with MatLab using 19200 baudrate we receive            %
% 8 (# of countes)*5(bytes per number)+1= 41 numbers in the array.        %
% In order to calculate the actual number for a counter, say A, we mu     %
% multiply the corresponding figures by 2^0, 2^7, 2^14, 2^21 and 2^28.    %
% We save the numbers and plot them.                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Kiko to add number of intervals to the dialog box. Fixed a 
% bug to do with the file name.. 4/24/21
% Modified to do the measurements fo any 4 angles KG 4/24
clc;
clear;
close all;
format compact


%% Loop
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prompt = {'Enter the COM# of the Counter:','time interval','Name of file = '};
prompt = {'Enter the COM# of the Counter:','Enter the COM# of Alice',...
    'Enter the COM# of Bob','time per measurement','Polarizer Angle A (degrees):',...
    'Polarizer Angle A-prime (degrees):','Polarizer Angle B (degrees):',...
    'Polarizer Angle B-prime (degrees):','Name of file = '};
dlg_title = 'Bell test general parameters';
%defaultans = {'COM6','1','Bell'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
defaultans = {'COM25','COM22','COM29','8','0','45','180','225','Bell3824ah'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
counterportnum = userinput{1};
scounter = serial(counterportnum,'BaudRate',19200,'DataBits',8,'StopBits',1,'Parity','none');
AliceHWP = userinput{2};
BobHWP = userinput{3};
Alice = serialport(AliceHWP,9600);
configureTerminator(Alice,'CR')
Bob = serialport(BobHWP,9600);
configureTerminator(Bob,'CR')
%timeinterval = str2double(userinput{2}); % time interval for each measurement in seconds
numofstates=16;% str2double(userinput{2}); % time interval for each measurement in seconds
timeinterval = str2double(userinput{4}); % time interval for each measurement in seconds
%
%A
%
AngleA=str2num(userinput{5});
HWPNodsA=AngleA*9/2;
HWPNodsAort=(AngleA+90)*9/2;
rotA=strcat(['ma',num2str(HWPNodsA)]);
rotAort=strcat(['ma',num2str(HWPNodsAort)]);
% 
%A prime
%
AngleAp=str2num(userinput{6});
HWPNodsAp=AngleAp*9/2;
HWPNodsAport=(AngleAp+90)*9/2;
rotAp=strcat(['ma',num2str(HWPNodsAp)]);
rotAport=strcat(['ma',num2str(HWPNodsAport)]);
%
%B
%
AngleB=str2num(userinput{7});
HWPNodsB=AngleB*9/2;
HWPNodsBort=(AngleB+90)*9/2;
rotB=strcat(['ma',num2str(HWPNodsB)]);
rotBort=strcat(['ma',num2str(HWPNodsBort)]);
%
%B prime
%
AngleBp=str2num(userinput{8});
HWPNodsBp=AngleBp*9/2;
HWPNodsBport=(AngleBp+90)*9/2;
rotBp=strcat(['ma',num2str(HWPNodsBp)]);
rotBport=strcat(['ma',num2str(HWPNodsBport)]);
nams = userinput{9};
datanam = strcat(nams,'.xlsx');  %'TM11805Normal3632'; % data name
dateexp = date; % date
%numofstates = 4; % # of states for the manual scan
numofmeasurements = numofstates; % # of measurements per each state
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = numofmeasurements;
timeaxislimit = numofstates;%*numofmeasurements*timeinterval;
deltat = 30e-9;% 40e-9; % pulse width to calculate accidental coincidences
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
Header1={'HWP-A','HWP-B','A','B','AB','Accidentals'};
%xlswrite('Bell.xlsx',Header1,Sheet1,xlrange1)
xlswrite(datanam,Header1,Sheet1,xlrange1)
% End of writing the header for the "Gradual Results" sheet in excel file.
%-------------------------------------
% Start the excel file to write the "Total Results" sheet

warning('off','MATLAB:xlswrite:AddSheet');
% to suppress the warning when the sheet name is not in excel file.
% Header2={'A','B','AB','Accidentals'};
% xl2range1='A1';
%xlswrite('Bell.xlsx',Header2,Sheet2,xl2range1)
% xlswrite(datanam,Header2,Sheet2,xl2range1)
% End of writing the header for the "Gradual Results" sheet in excel file.


%% Figure adjustments
screensize = get( groot, 'Screensize' ); %getting screen size
position=[1 screensize(1,4)/2-100 screensize(1,3) screensize(1,4)/2];
f1=figure('Name','Bell Test Data','numbertitle','off','Position',screensize,'color',[0.7 0.7 0.7]);
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
ax1 = axes('position',[0.08 0.2 0.25 0.3]); % Axies 1 position in the figure
set(get(ax1,'title'),'color','w','background','b')
ax1.XLim = [0 numofstates];
% ax1.XLabel.String  = 'time (sec)';
% ax1.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax1.XLabel.FontWeight = 'bold';
ax1.XLabel.FontSize = 12; ax1.XLabel.FontName = 'TimesNewRoman';
%set(ax1,'XTickL',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17],{'HH','HV','VV','VH','RH','RV','DV','DH','DR','DD','RD','HD','VD','VL','HL','RL','DA'})
set(ax1,'XTick',1:1:numofstates)
set(ax1,'XTicklabel',{'ab','a`b','a+b','a`+b',...
    'ab`','a`b`','a+b`','a`+b`',...
    'ab+','a`b+','a+b+','a`+b+',...
    'ab`+','a`b`+','a+b`+','a`+b`+'});
ax1.YLabel.String  = 'singles A';
ax1.YLabel.FontWeight = 'bold';
ax1.YLabel.FontSize = 25;ax1.YLabel.FontName = 'TimesNewRoman';
ax1.YLim = [0 inf];
grid(ax1,'on');
hold(ax1,'on')
%____________________________________

ax2 = axes('position',[0.40 0.2 0.25 0.3]); % Axies 2 position in the figure
set(get(ax2,'title'),'color','w','background','b')
ax2.XLim=[0 numofstates];
% ax2.XLabel.String  = 'time (sec)';
% ax2.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax2.XLabel.FontWeight = 'bold';
ax2.XLabel.FontSize = 12;ax2.XLabel.FontName = 'TimesNewRoman';
set(ax2,'XTick',1:1:numofstates)
%set(ax2,'XTicklabel',{'11','21','31','41','12','22','32','42','31','32','33','34','41','42','43','44','ex'})
%set(ax2,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','ex'})
set(ax2,'XTicklabel',{'ab','a`b','a+b','a`+b','ab`','a`b`','a+b`','a`+b`','ab+','a`b+','a+b+','a`+b+','ab`+','a`b`+','a+b`+','a`+b`+'});
ax2.YLabel.String  = 'singles B';ax2.YLabel.FontWeight = 'bold';
ax2.YLabel.FontSize = 25;ax2.YLabel.FontName = 'TimesNewRoman';
ax2.YLim = [0 inf];
grid(ax2,'on')
hold(ax2,'on')
%____________________________________

ax3=axes('position',[0.72 0.2 0.25 0.3]); % Axies 3 position in the figure
set(get(ax3,'title'),'color','w','background','b')
ax3.XLim=[0 numofstates];
% ax3.XLabel.String  = 'time (sec)';
% ax3.XLabel.String  ='HH HV VV VH RH RV DV DH DR DD RD HD VD VL HL RL DA';
ax3.XLabel.FontWeight = 'bold';
ax3.XLabel.FontSize = 12;ax3.XLabel.FontName = 'TimesNewRoman';
set(ax3,'XTick',1:1:numofstates)
%set(ax3,'XTicklabel',{'11','21','31','41','12','22','32','42','31','32','33','34','41','42','43','44','ex'})
%set(ax3,'XTicklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','ex'})
set(ax3,'XTicklabel',{'ab','a`b','a+b','a`+b','ab`','a`b`','a+b`','a`+b`','ab+','a`b+','a+b+','a`+b+','ab`+','a`b`+','a+b`+','a`+b`+'});
ax3.YLabel.String  = 'Coinc. AB';ax3.YLabel.FontWeight = 'bold';
ax3.YLabel.FontSize = 25;ax3.YLabel.FontName = 'TimesNewRoman';
ax3.YLim=[0 inf];
grid(ax3,'on')
hold(ax3,'on')
%
% Alice and Bob waveplate settings
% AHWP(1)='ma0  ';AHWP(2)='ma203';AHWP(3)='ma405';AHWP(4)='ma608';
% AHWP(5)='ma0  ';AHWP(6)='ma203';AHWP(7)='ma405';AHWP(8)='ma608';
% AHWP(9)='ma0  ';AHWP(10)='ma203';AHWP(11)='ma405';AHWP(12)='ma608';
% AHWP(13)='ma0  ';AHWP(14)='ma203';AHWP(15)='ma405';AHWP(16)='ma608';
% BHWP(1)='ma101';BHWP(2)='ma101';BHWP(3)='ma101';BHWP(4)='ma101';
% BHWP(5)='ma304';BHWP(6)='ma304';BHWP(7)='ma304';BHWP(8)='ma304';
% BHWP(9)='ma506';BHWP(10)='ma506';BHWP(11)='ma506';BHWP(12)='ma506';
% BHWP(13)='ma709';BHWP(14)='ma709';BHWP(15)='ma709';BHWP(16)='ma709';
% prompt = {'Set the wave plates and then click OK'};
% dlg_title = 'Wave plate Orientation';
% userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30]);
fopen(scounter);  % open the serial port before the inner loop begins.
stateindexi=1;% :numofstates
%-----------------------------------------------------------
% header for each state measurement results in excel file "Gradual Results"
countt=num2str((stateindexi-1)*(numofmeasurements+1)+2);% to go two lines further (count+1)in excel (because of the header)
xlrange2=strcat('A',countt);
stateindexit=num2str(stateindexi);
stateheader={'state #',stateindexit};
%xlswrite('Bell.xlsx',stateheader,Sheet1,xlrange2);
%xlswrite(datanam,stateheader,Sheet1,xlrange2);
% header for each state measurement results in excel file "Total Results"
countt=num2str((stateindexi-1)*2+2);
%xl2range2=strcat('A',countt);
%xlswrite('Bell.xlsx',stateheader,Sheet2,xl2range2);
%xlswrite(datanam,stateheader,Sheet2,xl2range2);

% %______________________________________________________________
%% The Loop
% defining object s for serial instrument. BaudRate=19200 bps, DataBits=8
% StopBits=1, Parity=none.
% The COM port is determined by the Device Manager in Windows.

%****************************************************************************
% ,{'ab','a`b','a+b','a`+b',...
%     'ab`','a`b`','a+b`','a`+b`',...
%     'ab+','a`b+','a+b+','a`+b+',...
%     'ab`+','a`b`+','a+b`+','a`+b`+'});
for count=1:loop
    if count==1 %ab
%        writeline(Alice,'ma0'); % Setting Alice HWP
        writeline(Alice,rotA); % Setting Alice HWP
        % Alicenod=0;
        Alicenod=HWPNodsA;
        % writeline(Bob,'ma101'); % Setting BOB HWP
        writeline(Bob,rotB); % Setting BOB HWP
        % Bobnod=101;
        Bobnod=HWPNodsB;
    elseif count==2 % a`b
%        writeline(Alice,'ma203'); % Setting Alice HWP
        % writeline(Alice,'ma203'); % Setting Alice HWP
        % Alicenod=203;
        writeline(Alice,rotAp); % Setting Alice HWP
        Alicenod=HWPNodsAp;
    elseif count==3 % a+b
        % writeline(Alice,'ma405'); % Setting Alice HWP
        % Alicenod=405;
        writeline(Alice,rotAort); % Setting Alice HWP
        Alicenod=HWPNodsAort;
    elseif count==4 % a'+b
        % writeline(Alice,'ma608'); % Setting Alice HWP
        % Alicenod=608;
        writeline(Alice,rotAport); % Setting Alice HWP
        Alicenod=HWPNodsAport;
    elseif count==5 % ab'
        writeline(Alice,rotA); % Setting Alice HWP
        % Alicenod=0;
        Alicenod=HWPNodsA;
        % writeline(Bob,'ma304'); % Setting BOB HWP
        % Bobnod=304;
        writeline(Bob,rotBp); % Setting BOB HWP
        Bobnod=HWPNodsBp;
    elseif count==6 %a'b'
        % writeline(Alice,'ma203'); % Setting Alice HWP
        % Alicenod=203;
        writeline(Alice,rotAp); % Setting Alice HWP
        Alicenod=HWPNodsAp;
    elseif count==7 % a+b'
        % writeline(Alice,'ma405'); % Setting Alice HWP
        % Alicenod=405;
        writeline(Alice,rotAort); % Setting Alice HWP
        Alicenod=HWPNodsAort;
    elseif count==8 % a'+b'
        % writeline(Alice,'ma608'); % Setting Alice HWP
        % Alicenod=608;
        writeline(Alice,rotAport); % Setting Alice HWP
        Alicenod=HWPNodsAport;
    elseif count==9 % ab+
        % writeline(Alice,'ma0'); % Setting Alice HWP
        % Alicenod=0;
        writeline(Alice,rotA); % Setting Alice HWP
        Alicenod=HWPNodsA;
        % writeline(Bob,'ma506'); % Setting BOB HWP
        % Bobnod=506;
        writeline(Bob,rotBort); % Setting BOB HWP
        Bobnod=HWPNodsBort;
    elseif count==10 % a'b+
        % writeline(Alice,'ma203'); % Setting Alice HWP
        % Alicenod=203;
        writeline(Alice,rotAp); % Setting Alice HWP
        Alicenod=HWPNodsAp;
    elseif count==11 % a+b+
        % writeline(Alice,'ma405'); % Setting Alice HWP
        % Alicenod=405;
        writeline(Alice,rotAort); % Setting Alice HWP
        Alicenod=HWPNodsAort;
    elseif count==12 % a'+b+
        % writeline(Alice,'ma608'); % Setting Alice HWP
        % Alicenod=608;
        writeline(Alice,rotAport); % Setting Alice HWP
        Alicenod=HWPNodsAport;
    elseif count==13 % ab'+
        % writeline(Alice,'ma0'); % Setting Alice HWP
        % Alicenod=0;
        writeline(Alice,rotA); % Setting Alice HWP
        Alicenod=HWPNodsA;
        % writeline(Bob,'ma709'); % Setting BOB HWP
        % Bobnod=709;
        writeline(Bob,rotBport); % Setting BOB HWP
        Bobnod=HWPNodsBort;
    elseif count==14 % a'b'+
        % writeline(Alice,'ma203'); % Setting Alice HWP
        % Alicenod=203;
        writeline(Alice,rotAp); % Setting Alice HWP
        Alicenod=HWPNodsAp;
    elseif count==15 % a+b'+
        % writeline(Alice,'ma405'); % Setting Alice HWP
        % Alicenod=405;
        writeline(Alice,rotAort); % Setting Alice HWP
        Alicenod=HWPNodsAort;
    elseif count==16 % a'+b'+
        % writeline(Alice,'ma608'); % Setting Alice HWP
        % Alicenod=608;
        writeline(Alice,rotAport); % Setting Alice HWP
        Alicenod=HWPNodsAport;
    end
    Alicenods(count)=Alicenod;
    Bobnods(count)=Bobnod;
    pause(1);
    numofcounts=zeros(1,8);
    % Serial data accessing
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
    numofcountsA=numofcounts(1,1);
    n1(count)=numofcountsA;
    numofcountsB=numofcounts(1,2);
    n2(count)=numofcountsB;
    %     numofcountsAprime=numofcounts(1,3);
    %     numofcountsBprime=numofcounts(1,4);
    numofcountsAB=numofcounts(1,5);
    n(count)=numofcountsAB;
    %     numofcountsAprimeB=numofcounts(1,6);
    %     numofcountsABprime=numofcounts(1,7);
    %     numofcountsAprimeBprime=numofcounts(1,8);
    accidentalsAB=numofcountsA*numofcountsB*deltat/timeinterval;
    accidentalsABstr=num2str(round(accidentalsAB));    %     numofcountsA=numofcounts(1,1);
    nacc(count)=accidentalsAB;
    nmacc(count)=n(count)-nacc(count);
    %% Plotting the data points on different subplots
    %time(count) = (stateindexi-1)*numofmeasurements*timeinterval+count*timeinterval; % x-axis (time) in seconds
    % plotting A
    plot(ax1,count,numofcounts(1,1),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting B
    plot(ax2,count,numofcounts(1,2),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % plotting AB
    plot(ax3,count,numofcounts(1,5),'. b','MarkerSize',20)
    %----------------------------------------------------------------------
    % Drawing Y-data of the three plots (A, B, AB) at the same time
    descriptionA = num2str(numofcounts(1,1));
    title(ax1,descriptionA,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');

    descriptionB = num2str(numofcounts(1,2));
    title(ax2,descriptionB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');

    descriptionAB = num2str(numofcounts(1,5));
    title(ax3,descriptionAB,'FontWeight','bold','FontSize',40,'FontName','Times New Roman');

    descr = ['Bell measurement: ','State # ',num2str(count),'/',num2str(numofmeasurements)];
    title(axheader,descr,'FontWeight','bold','FontSize',40,'FontName','Times New Roman')
    %     text(axheader,0,0,descr,'FontWeight','bold','FontSize',30,'FontName','Times New Roman')
            axcredit=axes('position',[0.5 0.03 0.1 0.05],'visible','off');
        axcredit.Title.Visible = 'on';
        set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
        descr2 = strcat('Calculated accidentals =  ',accidentalsABstr,'   ');
        title(axcredit,descr2,'FontWeight','bold','FontSize',30,'FontName','TimesNew Roman')

    drawnow

    %----------------------------------------------------------------------


    %% Storing Data in the resultsmatrix and finally in xlsx file

    resultsmatrix(count,1)=numofcounts(1,1);
    resultsmatrix(count,2)=numofcounts(1,2);
    resultsmatrix(count,3)=numofcounts(1,5);
    %     resultsmatrix(count,4)=numofcounts(1,4);
    %     resultsmatrix(count,5)=numofcounts(1,5);
    %     resultsmatrix(count,6)=numofcounts(1,6);
    %     resultsmatrix(count,7)=numofcounts(1,7);
    %     resultsmatrix(count,8)=numofcounts(1,8);
    %________________________________________________________________________
    % writing results gradually into the "Gradual Results' sheet in excel
    % file
    warning('off','MATLAB:xlswrite:AddSheet');
    % to suppress the warning when the sheet name is not in excel file.
    countt=num2str((stateindexi-1)*(numofmeasurements+1)+count+2);% to go two lines further (count+1)in excel (because of the header)
    xlrange2=strcat('A',countt);
    accidentalsindividual=resultsmatrix(count,1)*resultsmatrix(count,2)*deltat/timeinterval;
    %    xlswrite('Bell.xlsx',[resultsmatrix(count,1:2),resultsmatrix(count,5),accidentalsindividual],Sheet1,xlrange2);
    xlswrite(datanam,[Alicenods(count),Bobnods(count),resultsmatrix(count,1:3),accidentalsindividual],Sheet1,xlrange2);
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
%xlswrite(datanam,[sum(resultsmatrix(1:numofmeasurements,1)),sum(resultsmatrix(1:numofmeasurements,2)),sum(resultsmatrix(1:numofmeasurements,5)),accidentalstotal],Sheet2,xl2range2)
pause(statepause);
count=1;


%clear s;
%% writing date and time of the results into the excle files

timeheader={'year','month','day','hour','minute','seconds'};

% "Gradual Results" sheet
countt=num2str(numofmeasurements+3);
xlrange2=strcat('A',countt);
%xlswrite('Bell.xlsx',timeheader,Sheet1,xlrange2)
xlswrite(datanam,timeheader,Sheet1,xlrange2)
countt=num2str(numofmeasurements+4);
xlrange2=strcat('A',countt);
%xlswrite('Bell.xlsx',clockt,Sheet1,xlrange2)
xlswrite(datanam,clockt,Sheet1,xlrange2)
% "Total Results" sheet
xlrangetimeheader=strcat('A',num2str(numofmeasurements+5));
timestr={'timeinterval='};
xlswrite(datanam,timestr,Sheet1,xlrangetimeheader)
xlrangetime=strcat('B',num2str(numofmeasurements+5));
xlswrite(datanam,num2str(timeinterval),Sheet1,xlrangetime)

% "Total Results" sheet
% xlrangetimeheader=strcat('A',num2str(numofstates*2+2));
% xlrangetime=strcat('A',num2str(numofstates*2+3));
% % xlswrite('Bell.xlsx',timeheader,Sheet2,xlrangetimeheader)
% % xlswrite('Bell.xlsx',clockt,Sheet2,xlrangetime)
% xlswrite(datanam,timeheader,Sheet2,xlrangetimeheader)
% xlswrite(datanam,clockt,Sheet2,xlrangetime)

% save to "resultsmatrix.txt" file
%
%% Calculating Bell
%
Eab=(nmacc(1)+nmacc(11)-nmacc(3)-nmacc(9))/(nmacc(1)+nmacc(11)+nmacc(3)+nmacc(9))
Eabp=(nmacc(5)+nmacc(15)-nmacc(7)-nmacc(13))/(nmacc(5)+nmacc(15)+nmacc(7)+nmacc(13))
Eapb=(nmacc(2)+nmacc(12)-nmacc(4)-nmacc(10))/(nmacc(2)+nmacc(12)+nmacc(4)+nmacc(10))
Eapbp=(nmacc(6)+nmacc(16)-nmacc(8)-nmacc(14))/(nmacc(6)+nmacc(16)+nmacc(8)+nmacc(14))
SBell=Eab-Eabp+Eapb+Eapbp
Eabna=(n(1)+n(11)-n(3)-n(9))/(n(1)+n(11)+n(3)+n(9))
Eabpna=(n(5)+n(15)-n(7)-n(13))/(n(5)+n(15)+n(7)+n(13))
Eapbna=(n(2)+n(12)-n(4)-n(10))/(n(2)+n(12)+n(4)+n(10))
Eapbpna=(n(6)+n(16)-n(8)-n(14))/(n(6)+n(16)+n(8)+n(14))
SBellna=Eabna-Eabpna+Eapbna+Eapbpna
dsdn(1)=(2*(n(4)+n(10))/(n(2)+n(12)+n(4)+n(10))^2)^2*n(2);
dsdn(4)=dsdn(1)^2*n(12);
dsdn(2)=(-2*(n(2)+n(12))/(n(2)+n(12)+n(4)+n(10))^2)^2*n(10);
dsdn(3)=dsdn(2)^2*n(4);
dsdn(5)=(2*(n(8)+n(14))/(n(6)+n(16)+n(8)+n(14))^2)^2*n(6);
dsdn(8)=dsdn(5)^2*n(16);
dsdn(6)=(-2*(n(6)+n(16))/(n(6)+n(16)+n(8)+n(14))^2)^2*n(14);
dsdn(7)=dsdn(6)^2*n(8);
dsdn(9)=(2*(n(3)+n(9))/(n(3)+n(9)+n(1)+n(11))^2)^2*n(1);
dsdn(12)=dsdn(9)^2*n(11);
dsdn(10)=(-2*(n(1)+n(11))/(n(3)+n(9)+n(1)+n(11))^2)^2*n(9);
dsdn(11)=dsdn(10)^2*n(3);
dsdn(13)=(2*(n(7)+n(13))/(n(5)+n(15)+n(7)+n(13))^2)^2*n(5);
dsdn(16)=dsdn(13)^2*n(15);
dsdn(14)=(-2*(n(5)+n(15))/(n(5)+n(15)+n(7)+n(13))^2)^2*n(13);
dsdn(15)=dsdn(14)^2*n(7);
dsdnn=0;
for in=1:16
dsdnn=dsdnn+dsdn(in);
end
ds=sqrt(dsdnn)
xlrangeSheader=strcat('A',num2str(numofmeasurements+6));
Sstr={'S='};
dSstr={'+/-'};
xlswrite(datanam,Sstr,Sheet1,xlrangeSheader)
xlrangeS=strcat('B',num2str(numofmeasurements+6));
xlswrite(datanam,num2str(SBell),Sheet1,xlrangeS)
xlrangepm=strcat('C',num2str(numofmeasurements+6));
xlswrite(datanam,dSstr,Sheet1,xlrangepm)
xlrangeds=strcat('D',num2str(numofmeasurements+6));
xlswrite(datanam,num2str(ds),Sheet1,xlrangeds)
            axresult=axes('position',[0.45 0.6 0.1 0.05],'visible','off');
        axresult.Title.Visible = 'on';
        set(get(gca,'title'),'color','w','background','b')% figure header text:white, background:blue
        descr2 = strcat('S =  ',num2str(SBell),' +/- ',num2str(ds));
        title(axresult,descr2,'FontWeight','bold','FontSize',40,'FontName','TimesNew Roman')
        drawnow