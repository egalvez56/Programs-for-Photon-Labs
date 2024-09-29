% File: Home.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Description: Homes the thorlabs stage

function Home(ts)
if ts.deviceNET.Status.Position ~= 0
    ts.deviceNET.Home(100000);
else
    warning('No need to home');
end
end