function [appParams,simParams,varargin] = initiateApplicationParameters(simParams,fileCfg,varargin)
% function [appParams,simParams,varargin]= initiateApplicationParameters(fileCfg,varargin)
%
% Settings of the application
% It takes in input the name of the (possible) file config and the inputs
% of the main function
% It returns the structure "appParams"

% ==============
% Copyright (C) Alessandro Bazzi, University of Bologna, and Alberto Zanella, CNR
% 
% All rights reserved.
% 
% Permission to use, copy, modify, and distribute this software for any 
% purpose without fee is hereby granted, provided that this entire notice 
% is included in all copies of any software which is or includes a copy or 
% modification of this software and in all copies of the supporting 
% documentation for such software.
% 
% THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED 
% WARRANTY. IN PARTICULAR, NEITHER OF THE AUTHORS MAKES ANY REPRESENTATION 
% OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY OF THIS SOFTWARE 
% OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
% 
% Project: LTEV2Vsim
% ==============

fprintf('Application settings\n');

% [averageTbeacon]
% Beacon period in seconds.
[appParams,varargin] = addNewParam([],'averageTbeacon',0.1,'Beacon period (s)','double',fileCfg,varargin{1});
if appParams.averageTbeacon<=0
    error('Error: "appParams.averageTbeacon" cannot be <= 0');
end

% [variabilityTbeacon]
% Interval of variability of Tbeacon from vehicle to vehicle
% Each (11p) vehicle will have a periodicity uniformly randomly chosen
% between "averageTbeacon-variabilityTbeacon/2" and "averageTbeacon+variabilityTbeacon/2"
% Note: it applies only to 11p nodes, in order to reproduce possible small variations in the
% speed of vehicles that cause small variation in periodicity
% In LTE this cannot apply, as in LTE the beacon interval is rigid and
% small variability to speed does not make the periodicity to vary
[appParams,varargin]= addNewParam(appParams,'variabilityTbeacon',0,'Variability of beacon period per vehicle (s) (only 11p)','double',fileCfg,varargin{1});
if appParams.variabilityTbeacon<0 || appParams.variabilityTbeacon>=appParams.averageTbeacon
    error('Error: "appParams.variabilityTbeacon" cannot be < 0 or >= "appParams.averageTbeacon"');
end


% The beacon periodicity fB is derived - never used
%appParams.fB = 1/appParams.averageTbeacon;

if simParams.typeOfScenario==2 % traffic trace
    % if default value of time resolution is selected, update the value to the beacon period
    if simParams.positionTimeResolution==-1
        simParams.positionTimeResolution = appParams.averageTbeacon;
    end
end

% [beaconSizeBytes]
% Beacon size (Bytes)
[appParams,varargin]= addNewParam(appParams,'beaconSizeBytes',190,'Beacon size (Bytes)','integer',fileCfg,varargin{1});
if appParams.beaconSizeBytes<=0 || appParams.beaconSizeBytes>10000
    error('Error in the setting of "appParams.beaconSizeBytes".');
end

if simParams.technology ~= 2 % not only 11p
    % [resourcesV2V]
    % Resource allocated to V2V (%)
    [appParams,varargin]= addNewParam(appParams,'resourcesV2V',100,'Resource allocated to V2V (%)','integer',fileCfg,varargin{1});
    if appParams.resourcesV2V<=0 || appParams.resourcesV2V>100
        error('Error in the setting of "appParams.resourcesV2V". Not within 1-100%.');
    end
end
if simParams.technology == 2 % only 11p . variable size is not supported otherwise
    % [variableBeaconSize]
    % Enable to use variable beacon size
    [appParams,varargin]= addNewParam(appParams,'variableBeaconSize',false,'Varibale beacon size','bool',fileCfg,varargin{1});
    if appParams.variableBeaconSize~=false && appParams.variableBeaconSize~=true
        error('Error: "appParams.variableBeaconSize" must be equal to false or true');
    end
    
    if appParams.variableBeaconSize
        % [beaconSizeSmallBytes]
        % Beacon size small (Bytes)
        [appParams,varargin] = addNewParam(appParams,'beaconSizeSmallBytes',190,'Beacon size small (Bytes)','integer',fileCfg,varargin{1});
        if appParams.beaconSizeSmallBytes<=0 || appParams.beaconSizeSmallBytes>10000 || appParams.beaconSizeSmallBytes>appParams.beaconSizeBytes
            error('Error in the setting of "appParams.beaconSizeSmallBytes".');
        end
        
        % [NbeaconsSmall]
        % Number of small beacons between two large beacons
        [appParams,varargin]= addNewParam(appParams,'NbeaconsSmall',4,'Number of small beacons between two large beacons','integer',fileCfg,varargin{1});
        if appParams.NbeaconsSmall<=0
            error('Error in the setting of "appParams.beaconSizeSmallBytes".');
        end
    end
end

% [cbrSensingInterval]
% Duration of the interval for the CBR calculation [s]
[simParams,varargin] = addNewParam(simParams,'cbrSensingInterval',1,'Average duration of the interval for the CBR calculation (s)','double',fileCfg,varargin{1});
if simParams.cbrSensingInterval<=0
    error('Error: "outParams.cbrSensingInterval" cannot be <= 0');
end

fprintf('\n');
%
%%%%%%%%%
