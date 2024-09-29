%
% MotorScan 
% Based on a program by Valeria Rodriguez-Fajardo
% Modified by Kiko Galvez 6/21/23
%

clc; close all; clearvars;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prompt = {'Enter the COM# of the Counter:','Enter the COM# of Stage:',...
    'Start Position','End Position','Increment','time interval',...
    'Excel file name','Info on scan:'};
dlg_title = 'Quantum lab Inputs for Scan';
defaultans = {'COM25','COM21','-400','400','100','1','Mot',' '};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
Counter = userinput{1};
MotorCom = userinput{2}; % COM# for the Arduino 
Mstart = str2double(userinput{3});
Mend = str2double(userinput{4});
Minc = str2double(userinput{5});
Mrange=Mend-Mstart;
numofsteps = round((Mend - Mstart)/Minc,0); %defines the number of measurements
TimeInterval = str2double(userinput{6}); % time interval for each measurement in seconds
filename = userinput{7};
info = userinput{8};
dateexp = date; % date
NumofMeasurements = numofsteps+1; % # of measurements  
OUTfolder = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UserInput = { Counter, MotorCom, Mstart, Mend, Minc, TimeInterval, NumofMeasurements, filename, info};
[ Data, fig ] = TakeData( UserInput );

%%% Save data and counts figure
DataTable = struct2table(Data);
writetable( DataTable, [ OUTfolder filename '.txt' ] );
writetable( DataTable, [ OUTfolder filename '.xlsx' ] );
print(fig,[ OUTfolder filename '_CountsFig.png' ], '-dpng' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     Functions definition below                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Data, figh ] = TakeData( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nstates = length(States);
Nstates = UserInput{7};
%%% Measurement parameters
TimeInterval = UserInput{6}; % integration time for each measurement in seconds
TimeInterval = round( 10*TimeInterval ) / 10; % In multiples of 0.1 s
deltat = 32e-9; % Coincidence window to calculate accidental coincidences

%%% Create figure and axes
[ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, Header, figh, TitleAcc ] = FigureSetup( UserInput );

%%% Create variables for communication with serial ports
[ scounter, sPacific ] = OpenCOMports( UserInput );

%%% Prellocate memory
Data = struct( 'Mcurr',0, 'NcountsA',0, 'NcountsB',0, 'NcountsAB',0, 'AcctalsAB',0 );
Data = repmat( Data, [ Nstates, 1 ] );

%%% Add  button to stop measurement
StopButton = uicontrol( figh, 'Style','togglebutton', 'String','Stop', 'Value',0, ...
    'Units','normalized', 'Position',[0.85 0.9 0.1 0.05], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',16 );
    Mstart = UserInput{3};
    Mend = UserInput{4};
    Minc = UserInput{5};
    Mstarts = num2str(Mstart);
    Mends = num2str(Mend);

%%% Loop
for n = 1:Nstates+1
%     nState = States{n};
    Mcurr = Mstart + (n-1)*Minc;

    %%% Rotate the waveplates depending on the state to be measured
%    SetWavePlates( nState, OffsetAngleTissue, OffsetAngleNonTissue, TissueQ, TissueH, NTissueQ, NTissueH )
    MoveMotor( sPacific, Mcurr );
    %%% Measure
    nData = OnePoint( scounter, TimeInterval );

    NcountsA = nData(1,1);
    NcountsB = nData(1,2);
    NcountsAB = nData(1,5);
    AcctalsAB = NcountsA * NcountsB * deltat / TimeInterval;

    %%% Store information
    Data(n) = struct( 'Mcurr',Mcurr, 'NcountsA',NcountsA, 'NcountsB',NcountsB, 'NcountsAB',NcountsAB, 'AcctalsAB',AcctalsAB );

    %%% Plot
   % x = 1:n;
    x = cat(1,Data(1:n).Mcurr);
    y = cat(1,Data(1:n).NcountsA);
    set( Agraph,'XData',x, 'YData', y )
    TitleA.String = num2str(y(n));

    y = cat(1,Data(1:n).NcountsB);
    set( Bgraph,'XData',x, 'YData', y )
    TitleB.String = num2str(y(n));

    y = cat(1,Data(1:n).NcountsAB);
    set( ABgraph,'XData',x, 'YData', y )
    TitleAB.String = num2str(y(n));

    TitleAcc.String = num2str(AcctalsAB);
    Mcurrs = num2str(Mcurr);

    set( Header, 'String',['A measurement (t = ' num2str(TimeInterval) 's ): ' Mcurrs '/' Mstarts ' - ' Mends ] )
    pause(0.01)

    %%% Stop Measurement
    if StopButton.Value == 1
        assignin('base','Data',Data)
        return;
    end
end
MoveMotor( sPacific, 0 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, Header, figh, TitleAcc ] = FigureSetup( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mstart = UserInput{3};
Mend = UserInput{4};
Mstarts = num2str(Mstart);
Mends = num2str(Mend);
Nstates = UserInput{7};
BGcolor = [1 170 170]/255;
TimeInterval = UserInput{6};
filename = UserInput{8};
info = UserInput{9};
figh = figure( 'color',BGcolor, 'Units','normalized', 'Position',[0 0 1 1] );
fs1 = 15; fs2 = 24;
Header = sgtitle( gcf, ['A measurement (t = ' num2str(TimeInterval) 's): ' Mstarts '/' Mstarts ' - ' Mends ], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','k');

x = 1:Nstates;
y = zeros(Nstates,1) * NaN;

axes('Units','normalized', 'Position',[0.045, 0.2, 0.275, 0.4] ); 
Agraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [Mstart, Mend]);%, 'XTick',1:Nstates+1 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.045 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles A', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleA = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.22 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.38, 0.2, 0.275, 0.4] );
Bgraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [Mstart, Mend]);%, 'XTick',1:Nstates+1 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.38 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles B', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleB = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.555 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.715, 0.2, 0.275, 0.4] );
ABgraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [Mstart, Mend]);%, 'XTick',1:Nstates+1 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.715 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Coincidences AB', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleAB = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.89 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

% Print Accidentals title

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.715 0.1 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Accidentals', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

TitleAcc = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.89 0.1 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );



% Print date 

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.05 0.05 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Date/Time:', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

DateTime = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.2 0.05 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String',string(datetime), 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

% Print filename

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.05 0.8 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','File Name: ', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.2 0.8 0.4 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String', filename, 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

% Print info

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.05 0.75 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Info: ', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.2 0.75 0.6 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String', info, 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ scounter, sPacific ] = OpenCOMports( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Counter
scounter = serialport(UserInput{1},19200,'DataBits',8,'StopBits',1,'Parity','none');

%%% COM# for the Tissue side motors, which have the same COM port
sPacific = serialport(UserInput{2},9600); % Pacific Motor
configureTerminator(sPacific,'CR')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MoveMotor( sPacific, Mcurr )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

writeline( sPacific, [ 'ma' num2str( Mcurr )] );

%%% Give time to the motors to move
pause(1)

%%% Make sure all motors finished moving
tic
statusmotor = 'N';
while ~strcmp( statusmotor, 'T' )
    if toc > 5, break; end % In case
    pause(0.1)

    statusmotor = CheckMotor(sPacific);
end
end % ends function SetWavePlates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Ask motor for its status
function StatusMotor = CheckMotor(COMport)
writeline(COMport,'TP');
checkmotor = char( readline(COMport) );
StatusMotor = checkmotor(5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NCounts = OnePoint( scounter, timeinterval )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Size of vector to read from counter
DataDimension = ( 10 * timeinterval ) * 41;

%%% Get raw data
flush(scounter)
RawData = read(scounter,DataDimension+40,'uint8');

%%% Find termination byte if the 41th element of myData is not 255
if RawData(1,41) == 255
    tbi = 0; % = termination byte index
else
    tbi = find( RawData == 255, 1, 'first' );
end

%%% Actual Data
myData = RawData( tbi+(1:DataDimension) );
myData = reshape( myData, [ 41, 10*timeinterval ] ); % Shape data so every column corresponds to 0.1 s

%%% Counts computation
myData = sum( myData(1:40,:), 2 ); % Adds up all 0.1 s counts to get total
myData = reshape( myData, [5, 8] );

Scale = repmat( 2.^[ 0 7 14 21 28 ]', [1, 8] );
NCounts = sum( myData .* Scale, 1 );
end