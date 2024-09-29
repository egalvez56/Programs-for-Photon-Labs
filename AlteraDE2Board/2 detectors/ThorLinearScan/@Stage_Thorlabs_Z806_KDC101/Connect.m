% File: Connect.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Description: Connects to the latest seens stage, evtl you can even pass
% things like serial numbers one day

function Connect(ts, varargin)

if ~ts.isConnected
    serialnumber = ts.serialnumber;

    for iargin = 1:2:(nargin - 1)
        switch varargin{iargin}
            case 'serialnumber'
                serialnumber = varargin{iargin + 1};
            otherwise
                error('Invalid argument passed to function');
        end
    end

    % if serial number is kept empty lets try to find it automatically
    if isempty(serialnumber)
        serialNumberPull = ts.List_Devices();
        if (length(serialNumberPull) == 1)
            serialnumber = serialNumberPull{1};
        elseif (length(serialNumberPull) > 1)
            serialnumber = serialNumberPull{1};
            warning('Multiple devices found, choosing the first one');
        else
            error('Could not find device automatically');
        end
    end

    ts.deviceNET = ...
        Thorlabs.MotionControl.KCube.DCServoCLI.KCubeDCServo.CreateKCubeDCServo(serialnumber);

    %ts.deviceNET.ClearDeviceExceptions(); % Clear device exceptions via .NET interface
    ts.deviceNET.Connect(serialnumber); % Connect to device via .NET interface,
    pause(0.5)

    % check if connection was successfully established
    if ~ts.deviceNET.IsConnected
        error('Could not connect to stage');
    else
        ts.isConnected = 1;
    end
    ts.deviceNET.StartPolling(250);

    % Device info and configuration
    ts.serialnumber = serialnumber;
    ts.deviceInfoNET = ts.deviceNET.GetDeviceInfo();
    ts.deviceNET.LoadMotorConfiguration(serialnumber);

    % Enable device
    ts.deviceNET.EnableDevice();
    pause(0.5)
else
    warning('Device is already connected');
end
end