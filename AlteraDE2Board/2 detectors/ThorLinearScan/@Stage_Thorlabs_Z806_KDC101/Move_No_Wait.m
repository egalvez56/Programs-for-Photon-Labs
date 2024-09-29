% File: Move_No_Wait.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

function Move_No_Wait(ts, pos)

if ((pos > ts.POS_MAX) || (pos > ts.soft_max))
    error('Requested position beyond upper movement limit of stage');
else
    if ((pos < ts.POS_MIN) || (pos < ts.soft_min))
        error('Requested position is beyond lower movement limit of stage');
    else
        try
            workDone = ts.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
            ts.deviceNET.MoveTo(pos, workDone); % Move device to position via .NET interface
        catch % Device faile to move
            error(['Unable to Move device ',ts.serialnumber,' to ',num2str(pos)]);
        end
    end
end

end