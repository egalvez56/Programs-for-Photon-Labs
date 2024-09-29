% File Load_DLLs.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 09.05.2022

% Description: Loads all required DLLs

function Load_DLLs(ts)

if ~exist(ts.DEVICEMANAGERCLASSNAME, 'class')
    try   % Load in DLLs if not already loaded
        fprintf('[ThorlabsZStage] Loading general DLLs...\n');
        NET.addAssembly([ts.MOTORPATHDEFAULT, ts.DEVICEMANAGERDLL]);
        NET.addAssembly([ts.MOTORPATHDEFAULT, ts.GENERICMOTORDLL]);
    catch % DLLs did not load
        error('Unable to load .NET assemblies')
    end
else
    fprintf('[ThorlabsZStage] General DLLs already loaded, using existing ones.\n');
end

if ~exist(ts.STEPPERMOTORCLASSNAME, 'class')
    try   % Load in DLLs if not already loaded
        fprintf('[ThorlabsZStage] Loading DLLs for specific motor...\n');
        NET.addAssembly([ts.MOTORPATHDEFAULT, ts.STEPPERMOTORDLL]);
    catch % DLLs did not load
        error('Unable to load .NET assemblies')
    end
else
    fprintf('[ThorlabsZStage] Motor specific DLLs already loaded, using existing ones.\n');
end

end