% File: Disconnect.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Description: Disconnects the stage

function Disconnect(ts)

if ts.isConnected

    ts.deviceNET.Disconnect

    if ts.deviceNET.IsConnected
        error('Could not disconnect device');
    else
        ts.isConnected = 0;
    end

else
    warning('Cannot disconnect because device was never connected');
end

end