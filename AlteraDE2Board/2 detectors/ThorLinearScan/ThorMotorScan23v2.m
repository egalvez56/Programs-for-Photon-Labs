%
% ThorScan 
% Based on a program by Valeria Rodriguez-Fajardo
% Program that takes data from 2 photon detectors while scanning a Thorlabs
% servo motor Z725B
% Modified by Kiko Galvez 6/21/23
%

clc; close all; clearvars;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Counter COM','Start Distance (mm)','End Distance (mm)',...
    'Increment (mm)','time interval','Excel file name','Info on scan:'};
dlg_title = 'Quantum lab Inputs for Actuator Scan';
defaultans = {'COM4','0','17','0.1','120','DoubleSlit116b','2BBO, V, slit'};%[1 length(dlg_title)+10],[1 5;1 5;1 5;1 30]
userinput = inputdlg(prompt,dlg_title,[1 length(dlg_title)+30],defaultans);
Counter = userinput{1};
Mstart = str2double(userinput{2});
Mend = str2double(userinput{3});  
Minc = str2double(userinput{4});
Mrange=Mend-Mstart;
numofsteps = round((Mend - Mstart)/Minc,0); %defines the number of measurements
TimeInterval = str2double(userinput{5}); % time interval for each measurement in seconds
filename = userinput{6};
info = userinput{7};
%
dateexp = date; % date
NumofMeasurements = numofsteps+1; % # of measurements  

OUTfolder = '';
MotorCom=' ';
%%% Measurement
UserInput = { Counter, MotorCom, Mstart, Mend, Minc, TimeInterval, NumofMeasurements, filename, info};
[ Data, fig ] = TakeData( UserInput );
%%% Save data and counts figure
DataTable = struct2table(Data);
writetable( DataTable, [ OUTfolder filename '.txt' ] );
writetable( DataTable, [ OUTfolder filename '.xlsx' ] );
print(fig,[ OUTfolder filename '_CountsFig.png' ], '-dpng' )

%%% Calculations


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
[ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, TitleAcc, Header, figh ] = FigureSetup( UserInput );

%%% Initialize Thorlabs
T = Z806_init( 1 ); % T = Z806_init( velocity (mm/s) )

%%% Setup counter
[ scounter ] = OpenCOMports( UserInput );

%%% Prellocate memory
Data = struct( 'Mcurr',0, 'NcountsA',0, 'NcountsB',0, 'NcountsAB',0, 'AcctalsAB',0 );
Data = repmat( Data, [ Nstates, 1 ] );

%%% Add  button to stop measurement
StopButton = uicontrol( figh, 'Style','togglebutton', 'String','Stop', 'Value',0, ...
    'Units','normalized', 'Position',[0.85 0.9 0.1 0.05], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',16 );
%    xcoord = zeros(Nstates);
%%% Loop
for n = 1:Nstates%+5
%     nState = States{n};
%if n <= Nstates
    Mstart = UserInput{3};
    Mend = UserInput{4};
    Minc = UserInput{5};
    Mcurr = Mstart + (n-1)*Minc; 
% else
%    Mcurr = 12-0.4 + (n-Nstates-1)*Minc; 
% end
    % if n == 2
    %     disp('Press return when the motor is done moving')
    %     prompt = ' Press enter: ';
    %     dummy=input(prompt);
    % end
    %%% Move the motor
    T.pos = Mcurr;
    if n == 1
        disp('Press return when the motor is done moving')
        prompt = ' Press enter: ';
        dummy=input(prompt);
    end
    %%% Measure
    nData = OnePoint( scounter, TimeInterval );
%    xcoord(n) = Mcurr;
    NcountsA = nData(1,1);
    NcountsB = nData(1,2);
    NcountsAB = nData(1,5);
    AcctalsAB = NcountsA * NcountsB * deltat / TimeInterval;

    %%% Store information
    Data(n) = struct( 'Mcurr', Mcurr, 'NcountsA',NcountsA, 'NcountsB',NcountsB, 'NcountsAB',NcountsAB, 'AcctalsAB',AcctalsAB );
    %x = 1:n;
    %%% Plot
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


    set( Header, 'String',['A measurement (t = ' num2str(TimeInterval) 's ): ' num2str(n) '/' num2str(Nstates) ] )
    pause(0.01)
   

    %%% Stop Measurement
    if StopButton.Value == 1
        assignin('base','Data',Data)
        return;
    end
end
T.Home; % brings actuator back to 0 pos.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, TitleAcc, Header, figh ] = FigureSetup( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nstates = UserInput{7};
BGcolor = [1 170 170]/255;
TimeInterval = UserInput{6};
figh = figure( 'color',BGcolor, 'Units','normalized', 'Position',[0 0 1 1] );
fs1 = 15; fs2 = 24;

Header = sgtitle( gcf, ['A measurement (t = ' num2str(TimeInterval) 's): ' num2str(0) '/' num2str(Nstates) ], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','k');

x = 1:Nstates;
y = zeros(Nstates,1) * NaN;
Mstart = UserInput{3};
Mend = UserInput{4};
Minc = UserInput{5};
filename = UserInput{8};
info = UserInput{9};
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
function [ scounter ] = OpenCOMports( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Counter
scounter = serialport(UserInput{1},19200,'DataBits',8,'StopBits',1,'Parity','none');

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


