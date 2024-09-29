% File: Thorlabs_Stage_LTS300.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Description: class used to control new stage

classdef Stage_Thorlabs_Z806_KDC101 < handle

    properties
        pos(1, 1) double; % position of the stage [mm]
        vel(1, 1) double; % velocity of the stage [mm/s]
        acc(1, 1) double; % acceleration of the stage [mm/s2]
        soft_min(1, 1) double = 0;
        soft_max(1, 1) double = 17.7;
    end

    properties(Hidden, Constant)
        % path to DLL files (edit as appropriate)
        MOTORPATHDEFAULT='C:\Program Files\Thorlabs\Kinesis\';
        % DLL files to be loaded
        DEVICEMANAGERDLL =       'Thorlabs.MotionControl.DeviceManagerCLI.dll';
        DEVICEMANAGERCLASSNAME = 'Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI'
        GENERICMOTORDLL =        'Thorlabs.MotionControl.GenericMotorCLI.dll';
        GENERICMOTORCLASSNAME =  'Thorlabs.MotionControl.GenericMotorCLI.GenericMotorCLI';
        STEPPERMOTORDLL =        'Thorlabs.MotionControl.KCube.DCServoCLI.dll';
        STEPPERMOTORCLASSNAME =  'Thorlabs.MotionControl.KCube.DCServoCLI';

        POS_MAX(1, 1) double = 17.7; % describes the hardware limit of the stage [mm]
        POS_MIN(1, 1) double = 0; % describes the hardware limit of the stage
        VEL_MAX(1, 1) double = 2.3;
        VEL_MIN(1, 1) double = 0;
        ACC_MAX(1, 1) double = 2;
        ACC_MIN(1, 1) double = 0;
        TPOLLING(1, 1) = 250; % Default polling time
        TIMEOUTSETTINGS(1, 1) = 7000;
        TIMEOUTMOVE(1, 1) = 100000;
        SERIAL_START = '27'; % start of correct serial number
    end

    properties (SetAccess = private)
        isConnected(1, 1) logical = 0; % status if device is connected or not
        isHomed(1, 1) logical = 0;
        isBusy(1, 1) logical = 0;
        serialnumber = [];
        deviceNET;
        %         deviceNET;
        motorSettingsNET;
        currentDeviceSettingsNET;
        deviceInfoNET;
    end

    methods

        % class destructor
        function delete(ts)
            ts.Disconnect();
        end

        Load_DLLs(ts);
        corrSerials = List_Devices(ts);
        Connect(ts, varargin);
        Home(ts);
        Move_No_Wait(ts, pos);
        Identify();

        function isBusy = get.isBusy(ts)
            isBusy = ts.deviceNET.IsDeviceBusy;
        end


        function isHomed = get.isHomed(ts)
            isHomed = ~ts.deviceNET.NeedsHoming;
        end

        function set.pos(ts, pos)
            ts.Move_No_Wait(pos);
            ts.Wait_Move();
        end

        % read current position from stage and return to user
        function pos = get.pos(ts)
            pos = System.Decimal.ToDouble(ts.deviceNET.Position);
        end

        % read current maximum velocity from stage and return to user
        function vel = get.vel(ts)
            velparams = ts.deviceNET.GetVelocityParams();
            vel = System.Decimal.ToDouble(velparams.MaxVelocity);
        end

        % set maximum velocity of stage
        function set.vel(ts, vel)
            velpars = ts.deviceNET.GetVelocityParams();
            if isnumeric(vel)
                if (vel <= ts.VEL_MAX) && (vel > 0)
                    velpars.MaxVelocity = vel;
                    ts.deviceNET.SetVelocityParams(velpars);
                else
                    error('Velocity outside of allowed range.');
                end
            else
                error('Invalid datatype.');
            end
        end

        % return currently defined acceleration to user
        function acc = get.acc(ts)
            velparams = ts.deviceNET.GetVelocityParams();
            acc = System.Decimal.ToDouble(velparams.Acceleration);
        end

        % Sets acceleration of the stage
        function set.acc(ts, acc)
            velpars = ts.deviceNET.GetVelocityParams();
            if isnumeric(acc)
                if (acc <= ts.ACC_MAX) && (acc > 0)
                    velpars.Acceleration = acc;
                    ts.deviceNET.SetVelocityParams(velpars);
                else
                    error('Acceleration outside of allowed range.');
                end
            else
                error('Invalid datatype.');
            end
        end
    end
end