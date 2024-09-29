% File: Wait_Move.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Derscription: Waits for stafe to finish moving

function Wait_Move(ts)
    while ts.deviceNET.IsDeviceBusy
        pause(0.5)
    end
end