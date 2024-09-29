%
% Valeria Continuous Counting
% Free running program
% Written by Valeria Rodriguez-Fajardo 6/10/23
% Modified Kiko Galvez 6/21/23
% Colgate University
% 
clc; close all; clearvars;

COMs = serialportlist;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BGcolor = [1 170 170]/255;

fig = figure( 'color',BGcolor, 'Units','normalized', 'Position',[0 0 1 1] );
fs1 = 15; fs2 = 24;

Header = sgtitle( gcf, 'Continous Counting', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',26, 'Color','w');

x = 1;
y = NaN;

axes('Units','normalized', 'Position',[0.08, 0.57, 0.24, 0.29] ); 
Agraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.07 0.865 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles A', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2)
TitleA = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.18 0.865 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.4, 0.57, 0.24, 0.29] );
Bgraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.39 0.865 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles B', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleB = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.5 0.865 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.72, 0.57, 0.24, 0.29] );
Cgraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.72 0.865 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Singles C', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleC = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.82 0.865 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );


axes('Units','normalized', 'Position',[0.08, 0.17, 0.24, 0.29] );
ABgraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.07 0.47 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Coinc AB', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleAB = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.17 0.47 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.4, 0.17, 0.24, 0.29] );
ACgraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.4 0.47 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Coinc AC', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleAC = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.5 0.47 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

axes('Units','normalized', 'Position',[0.72, 0.17, 0.24, 0.29] );
ABCgraph = scatter(x,y,20,'filled');
set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf], 'FontSize',fs1 );
% set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.72 0.47 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Coinc ABC', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )
TitleABC = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.82 0.47 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );


uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.07 0.07 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Accidentals:', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

TitleAccAB = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.18 0.07 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

TitleAccAC = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.5 0.07 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

TitleAccABC = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.82 0.07 0.1 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String','1', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );


uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.08 0.02 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','left', ...
    'String','Info', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 )

DateTime = uicontrol( fig, 'Style','text', 'Units','normalized', 'Position',[0.15 0.02 0.2 0.05], ...
    'ForegroundColor','k', 'BackgroundColor',BGcolor, 'HorizontalAlignment','right', ...
    'String',string(datetime), 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2 );

% axs1 = axes('Units','normalized', 'OuterPosition',[0.0025, 0.2, 0.34, 0.4] );
% Agraph = scatter(x,y,80,'filled');
% set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf] );
% % set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
% ylabel('Singles A', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )
% set( get(gca,'title'), 'color','w', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )
% 
% axs2 = axes('Units','normalized', 'OuterPosition',[0.3425, 0.2, 0.34, 0.4] );
% Bgraph = scatter(x,y,80,'filled');
% set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf] );
% % set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
% ylabel('Singles B', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )
% set(get(gca,'title'),'color','w', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )
% 
% axs3 = axes('Units','normalized', 'OuterPosition',[0.6850, 0.2, 0.34, 0.4] );
% ABgraph = scatter(x,y,80,'filled');
% set( gca, 'XGrid','on', 'YGrid','on', 'LineWidth',2, 'XLim', [0 Inf], 'YLim', [0 Inf] );
% % set( gca, 'XLim', [0, Nstates+1], 'XTick',1:Nstates, 'XTickLabel',States, 'FontSize',fs1, 'XTickLabelRotation',0 )
% ylabel('AB', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )
% set(get(gca,'title'),'color','w', 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs2, 'Color','w' )

%%% Create COM port Menu for selection
fs = 12;
uicontrol( fig, 'Style','text', 'String','Select COM port','Units','normalized', 'Position',[0.01 0.93 0.2 0.05], ...
    'BackgroundColor', BGcolor, 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs, 'HorizontalAlignment','left' )
PortMenu = uicontrol( fig, 'Style','popupmenu', 'String',COMs, 'FontSize',fs, ...
    'Units','normalized', 'Position',[0.01 0.91 0.1 0.05] );

%%% Write integration time
uicontrol( fig, 'Style','text', 'String','Type integration time (s)','Units','normalized', 'Position',[0.2 0.93 0.2 0.05], ...
    'BackgroundColor', BGcolor, 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs, 'HorizontalAlignment','left' )
TimeEdit = uicontrol( fig, 'Style','edit', 'String','1', 'FontSize',fs, ...
    'Units','normalized', 'Position',[0.2 0.93 0.1 0.025] );

%%% Create button to start and end acqusition
RunButton = uicontrol( fig, 'Style', 'togglebutton', 'String','Start !', 'Value',0, ...
    'Units','normalized', 'Position',[0.7 0.93 0.1 0.05], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs1 );

%%% Create button to clear the graphs during acquisition
ClearButton = uicontrol( fig, 'Style', 'togglebutton', 'String','Clear graphs', 'Value',0, ...
    'Units','normalized', 'Position',[0.85 0.93 0.1 0.05], ...
    'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs1 );

%%% Accidentals time window
uicontrol( fig, 'Style','text', 'String','Type coincidence window (ns)','Units','normalized', 'Position',[0.5 0.02 0.2 0.05], ...
    'BackgroundColor', BGcolor, 'FontName','TimesNewRoman', 'FontWeight','bold', 'FontSize',fs, 'HorizontalAlignment','left' )
CoincwEdit = uicontrol( fig, 'Style','edit', 'String','32', 'FontSize',fs, ...
    'Units','normalized', 'Position',[0.55 0.02 0.1 0.025] );

%%
%%% Wait to start
while RunButton.Value == 0
    pause(0.1)
end
RunButton.String = 'Stop';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Counter
aux = COMs{ PortMenu.Value };
scounter = serialport(aux,19200,'DataBits',8,'StopBits',1,'Parity','none');

%%% Measurement parameters
aux = TimeEdit.String;
timeinterval = str2double(aux) % integration time for each measurement in seconds
Told = timeinterval;

aux = CoincwEdit.String
coinc = str2double(aux) % coincidence time in nanoseconds
deltat = coinc*1e-9; % Coincidence window to calculate accidental coincidences

%%% Ensure the integration time is an integer multiple of 0.1 s
timeinterval = round( 10*timeinterval ) / 10;

%%% Loop
Data = zeros(2^16,5);
n = 0;
tic
while RunButton.Value == 1
    pause(0.01);
    n = n+1;

    %%% Measure
    nData = OnePoint( scounter, timeinterval );

    Data(n,1) = nData(1,1); % Number of counts A
    Data(n,2) = nData(1,2); % Number of counts B
    Data(n,3) = nData(1,5); % Coincidences AB
    Data(n,4) = Data(n,1) * Data(n,2) * deltat / timeinterval; % Accidentals AB
    Data(n,5) = toc;
% Additions by Kiko 11/7/23
    Data(n,6) = nData(1,3); % Number of counts C
    Data(n,7) = nData(1,6); % Coincidences AC
    Data(n,8) = Data(n,1) * Data(n,6) * deltat / timeinterval; % Accidentals AC
    Data(n,9) = nData(1,7); % Coincidences ABC
    Data(n,10) = (nData(1,3)*nData(1,5)+nData(1,2)*nData(1,6))* deltat / timeinterval; % Accidentals ABC From Pearson and Jackson AJP 2010
    %%% Plot
    x = 1:n;

    y = Data(x,1);
    set( Agraph,'XData',x, 'YData', y )
    TitleA.String = num2str(y(n));

    y = Data(x,2);
    set( Bgraph,'XData',x, 'YData', y )
    TitleB.String = num2str(y(n));

    y = Data(x,6);
    set( Cgraph,'XData',x, 'YData', y )
    TitleC.String = num2str(y(n));

    y = Data(x,3);
    set( ABgraph,'XData',x, 'YData', y )
    TitleAB.String = num2str(y(n));

    y = Data(x,7);
    set( ACgraph,'XData',x, 'YData', y )
    TitleAC.String = num2str(y(n));

    y = Data(x,9);
    set( ABCgraph,'XData',x, 'YData', y )
    TitleABC.String = num2str(y(n));


    TitleAccAB.String = num2str(Data(n,4));
    TitleAccAC.String = num2str(Data(n,8));
    TitleAccABC.String = num2str(Data(n,10));

    if ClearButton.Value == 1
        n = 0;
        Data = zeros(2^16,5);
        ClearButton.Value = 0;
    end

    aux = str2double( TimeEdit.String );
    if Told ~= aux
        Told = aux;
        timeinterval = aux;
    end
end

%%% Remove unnecessary zeros
aux = find( sum( Data, 2 ) ~= 0, 1, 'last' );
Data = Data( 1:aux, : );

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