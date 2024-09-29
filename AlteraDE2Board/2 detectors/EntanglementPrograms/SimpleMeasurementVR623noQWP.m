clc; close all; clearvars;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% States to measure
States = {'HH'};
States = {'HH','HV','VV','VH','DD','DA','AA','AD'};%,'RL','RR','LR','LL'};

%%% Integration time per point in seconds (in 0.1 s steps)
TimeInterval = 1;

%%% COM ports for serial communication
Counter    = 'COM18'; % Coincidences counter
Tissue  = 'COM11'; % Quarter waveplate on the tissue side (Alice)
nTissueQWP = 'COM19'; % Quarter waveplate on the non-tissue side (Bob)
nTissueHWP = 'COM10'; % Half waveplate on the non-tissue side (Bob)

%%% Offset angles for each side
OffsetAngle_Tissue = 0;
OffsetAngle_NonTissue = 0;

%%% Filename with no extension
filename = 'Test01_SimpleMeasurement';

%%% Folder where to save data and figures
%%% Use "OUTfolder = '';" to save in the same folder this script is
%%% When using a specific folder, don't forget to finish on '\'
OUTfolder ='';% '\\fresnel\EGalvezLab\PHAS2\2023\MuellerMatricesFilms\20230609\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UserInput = { Counter, Tissue, nTissueQWP, nTissueHWP, TimeInterval, OffsetAngle_Tissue, OffsetAngle_NonTissue };
[ Data, fig ] = TakeData( States, UserInput );

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
function [ Data, figh ] = TakeData( States, UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nstates = length(States);

%%% Measurement parameters
TimeInterval = UserInput{5}; % integration time for each measurement in seconds
TimeInterval = round( 10*TimeInterval ) / 10 % In multiples of 0.1 s
deltat = 40e-9; % Coincidence window to calculate accidental coincidences
OffsetAngleTissue = UserInput{6};
OffsetAngleNonTissue = UserInput{7};

%%% Create figure and axes
[ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, Header, figh ] = FigureSetup( States, TimeInterval );

%%% Create variables for communication with serial ports
[ scounter, TissueQ, TissueH, NTissueQ, NTissueH ] = OpenCOMports( UserInput );

%%% Prellocate memory
Data = struct( 'State','', 'NcountsA',0, 'NcountsB',0, 'NcountsAB',0, 'AcctalsAB',0 );
Data = repmat( Data, [ Nstates, 1 ] );

%%% Add  button to stop measurement
StopButton = uicontrol( figh, 'Style','togglebutton', 'String','Stop', 'Value',0, ...
    'Units','normalized', 'Position',[0.85 0.9 0.1 0.05], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',16 );

%%% Loop
for n = 1:Nstates
    nState = States{n};

    %%% Rotate the waveplates depending on the state to be measured
    SetWavePlates( nState, OffsetAngleTissue, OffsetAngleNonTissue, TissueQ, TissueH, NTissueQ, NTissueH )

    %%% Measure
    nData = OnePoint( scounter, TimeInterval );

    NcountsA = nData(1,1);
    NcountsB = nData(1,2);
    NcountsAB = nData(1,5);
    AcctalsAB = NcountsA * NcountsB * deltat / TimeInterval;

    %%% Store information
    Data(n) = struct( 'State',nState, 'NcountsA',NcountsA, 'NcountsB',NcountsB, 'NcountsAB',NcountsAB, 'AcctalsAB',AcctalsAB );

    %%% Plot
    x = 1:n;

    y = cat(1,Data(1:n).NcountsA);
    set( Agraph,'XData',x, 'YData', y )
    TitleA.String = num2str(y(n));

    y = cat(1,Data(1:n).NcountsB);
    set( Bgraph,'XData',x, 'YData', y )
    TitleB.String = num2str(y(n));

    y = cat(1,Data(1:n).NcountsAB);
    set( ABgraph,'XData',x, 'YData', y )
    TitleAB.String = num2str(y(n));

    set( Header, 'String',['A measurement (t = ' num2str(TimeInterval) 's ): ' num2str(n) '/' num2str(Nstates) ] )
    pause(0.01)

    %%% Stop Measurement
    if StopButton.Value == 1
        assignin('base','Data',Data)
        return;
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Agraph, TitleA, Bgraph, TitleB, ABgraph, TitleAB, Header, figh ] = FigureSetup( States, TimeInterval )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nstates = length( States );
BGcolor = [1 170 170]/255;

figh = figure( 'color',BGcolor, 'Units','normalized', 'Position',[0 0 1 1] );
fs1 = 15; fs2 = 24;

Header = sgtitle( gcf, ['A measurement (t = ' num2str(TimeInterval) 's): ' num2str(0) '/' num2str(Nstates) ], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','k');

x = 1:Nstates;
y = zeros(Nstates,1) * NaN;

axes('Units','normalized', 'Position',[0.045, 0.2, 0.275, 0.4] ); 
Agraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.045 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles A', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleA = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.22 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.38, 0.2, 0.275, 0.4] );
Bgraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.38 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles B', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleB = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.555 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.715, 0.2, 0.275, 0.4] );
ABgraph = scatter(x,y,80,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'YLim', [0 Inf] );
set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.715 0.61 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Coincidences AB', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleAB = uicontrol( figh, 'Style','text', 'Units','normalized', 'Position',[0.89 0.61 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ scounter, TissueQ, TissueH, NTissueQ, NTissueH ] = OpenCOMports( UserInput )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Counter
scounter = serialport(UserInput{1},19200,'DataBits',8,'StopBits',1,'Parity','none');

%%% COM# for the Tissue side motors, which have the same COM port
TissueQ = serialport(UserInput{2},9600); % Quarter-wave plate
configureTerminator(TissueQ,'CR')

TissueH = TissueQ;
% configureTerminator(Tissueh,'CR') % Already done for Tissueq

%%% Non-tissue side QWP
% NTissueQ = serialport( UserInput{3},9600);
% configureTerminator(NTissueQ,'CR')

%%% Non-tissue HWP
NTissueH = serialport(UserInput{4},9600);
configureTerminator(NTissueH,'CR')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetWavePlates( nState, OffsetAngleTissue, OffsetAngleNonTissue, TissueQ, TissueH, NTissueQ, NTissueH )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Known rotations of [ QWP, HWP ] in degrees
%%% Motors have 9 steps per one degree
Known.H = [   0,   0.0 ] * 9;
Known.V = [  90,  45.0 ] * 9;
Known.D = [  45,  22.5 ] * 9;
Known.A = [ -45, -22.5 ] * 9;
Known.R = [  90,  22.5 ] * 9;
Known.L = [  90, -22.5 ] * 9;

%%% Offsets in motor steps
Toffset = OffsetAngleTissue * 9;
nToffset = OffsetAngleNonTissue * 9;

%%% Tissue side
TissueCorrected = Known.( nState(1) ) + Toffset;
%writeline( TissueQ, [ '1ma' num2str( TissueCorrected(1) )] );
writeline( TissueH, [ 'ma' num2str( TissueCorrected(2) )] );

%%% Non-Tissue side
NonTissueCorrected = Known.( nState(2) ) + nToffset;
%writeline( NTissueQ, [ 'ma' num2str( NonTissueCorrected(1) )] );
writeline( NTissueH, [ 'ma' num2str( NonTissueCorrected(2) )] );

%%% Give time to the motors to move
pause(1)

%%% Make sure all motors finished moving
tic
statusmotor = 'TTNN';
while ~strcmp( statusmotor, 'TTTT' )
    if toc > 5, break; end % In case
    pause(0.1)

    %     statusmotor(1) = CheckMotor(TissueQ); % The instruction does not work
    %     statusmotor(2) = CheckMotor(TissueH); % with this motor
%    statusmotor(3) = CheckMotor(NTissueQ);
    statusmotor(4) = CheckMotor(NTissueH);
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