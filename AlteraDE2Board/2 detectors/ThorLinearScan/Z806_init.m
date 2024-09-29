function T = Z806_init( velocity )

%%% Basic initialization
T = Stage_Thorlabs_Z806_KDC101(); % Class definition
T.Load_DLLs(); % Load necessary dlls as defined in Stage_Thorlabs_Z806_KDC101
T.List_Devices(); % Find compatible devices
T.Connect(); % Open a connection to the device
T.Home(); % Go to position zero.

%%% Set stage speed
if velocity > 2.3 || velocity < 0.1
    error('error:Z806_init','Input velocity out of allowed range ( 0.1 to 2.3 mm/s).')
end
T.vel = velocity; % ( mm / s )

%%% Set stage acceleration
T.acc = 1; % ( mm / s^2 )