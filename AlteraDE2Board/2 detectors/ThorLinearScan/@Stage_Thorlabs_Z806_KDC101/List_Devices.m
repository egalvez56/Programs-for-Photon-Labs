% File: List_Devices.m @ Thorlabs_Stage_LTS300
% Author: Urs Hofmann, 03.02.2021
% Mail: hofmannu@ethz.ch
% Modified: Valeria Rodriguez-Fajardo, 01.02.2022

% Description: Lists all devices with the corresponding device numbers

function serialNumbers = List_Devices( ts )
% thorlabsstage.loaddlls; % Load DLLs
Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();  % Build device list
serialNumbersNet = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList( str2double(ts.SERIAL_START) ); % Get device list
serialNumbers = cell(ToArray(serialNumbersNet)); % Convert serial numbers to cell array

  corrSerialCount = 0; % counter for number of correct serial numbers
  for iSerial = 1:length(serialNumbers)
  	currSerial = serialNumbers{iSerial};
  	if strcmp(currSerial(1:2), ts.SERIAL_START)
  		corrSerialCount = corrSerialCount + 1;
  		corrSerials{corrSerialCount} = currSerial;
  	end
  end

if isempty( serialNumbers )
    warning('Could not find any device with an appropriate serial number.');
end

end