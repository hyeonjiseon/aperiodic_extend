function [simParams,varargin] = initiateMainSimulationParameters(fileCfg,varargin)
% function simParams = initiateMainSimulationParameters(fileCfg,varargin)
%
% Main settings of the simulation
% It takes in input the name of the (possible) file config and the inputs
% of the main function
% It returns the structure "simParams"

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

fprintf('Simulation settings\n');

% [seed]
% Seed for the random numbers generation
% If seed = 0, the seed is randomly selected (the selected value is saved
% in the main output file)
[simParams,varargin] = addNewParam([],'seed',0,'Seed for random numbers','integer',fileCfg,varargin{1});
if simParams.seed == 0
    simParams.seed = randi(2^32-1,1);
    fprintf('Seed used in the simulation: %d\n',simParams.seed);
end
rng(simParams.seed);

% [simulationTime]
% Duration of the simulation in seconds
[simParams,varargin] = addNewParam(simParams,'simulationTime',10,'Simulation duration (s)','double',fileCfg,varargin{1});
if simParams.simulationTime<=0
    error('Error: "simParams.simulationTime" cannot be <= 0');
end

% [Technology]
% Choose if simulate LTE-V2V or 802.11p
% String: "LTEV2V" or "80211p"
[simParams,varargin] = addNewParam(simParams,'Technology','LTEV2V','Choose if simulate "LTEV2V" or "80211p"','string',fileCfg,varargin{1});
% Check that the string is correct
if strcmpi(simParams.Technology,'LTEV2V')
    simParams.technology = 1; % LTE
elseif strcmpi(simParams.Technology,'80211p')
    simParams.technology = 2; % 11p
elseif strcmpi(simParams.Technology,'COEX-NO-INTERF')
    simParams.technology = 3; % LTE+11p, not interfering to each other
else
    error('"simParams.Technology" must be "LTEV2V" or "80211p" or "COEX-NO-INTERF"');
end

% [numVehiclesLTE]
% [numVehicles11p]
% To be used in the case of coexistence to set the proportion between 11p
% and LTE
if simParams.technology>2 % if coexistence
    [simParams,varargin] = addNewParam(simParams,'numVehiclesLTE',1,'How many consecutive vehicles use LTE-V2X','integer',fileCfg,varargin{1});
    if simParams.numVehiclesLTE<=0
        error('Error: "simParams.numVehiclesLTE" must be an integer greater than 0');
    end
    [simParams,varargin] = addNewParam(simParams,'numVehicles11p',1,'How many consecutive vehicles use IEEE 802.11p','integer',fileCfg,varargin{1});
    if simParams.numVehicles11p<=0
        error('Error: "simParams.numVehicles11p" must be an integer greater than 0');
    end
end

%% [typeOfScenario]
% Select if want to use Trace File: true or false
[simParams,varargin] = addNewParam(simParams,'TypeOfScenario','PPP','Type of scenario ("PPP"=random 1-D, "Traces"=traffic trace, "ETSI-Highway"=ETSI highway high speed','string',fileCfg,varargin{1});
% Check that the string is correct
if strcmpi(simParams.TypeOfScenario,'PPP')
    simParams.typeOfScenario = 1; % Random speed and direction on multiple parallel roads, all configurable
elseif strcmpi(simParams.TypeOfScenario,'Traces')
    simParams.typeOfScenario = 2; % Traffic traces
elseif strcmpi(simParams.TypeOfScenario,'ETSI-Highway')
    simParams.typeOfScenario = 3; % ETSI Highway high speed scenario
else
    error('"simParams.TypeOfScenario" must be "PPP" or "Traces" or "ETSI-Highway"');
end

if simParams.typeOfScenario==2 % Traffic traces
    % [fileObstaclesMap]
    % Select if want to use Obstacles Map File: true or false
    [simParams,varargin] = addNewParam(simParams,'fileObstaclesMap',false,'If using a obstacles map file','bool',fileCfg,varargin{1});
    if simParams.fileObstaclesMap~=false && simParams.fileObstaclesMap~=true
        error('Error: "simParams.fileObstaclesMap" must be equal to false or true');
    end
    
    % [filenameTrace]
    % If the trace file is used, this selects the file
    [simParams,varargin] = addNewParam(simParams,'filenameTrace','null.txt','File trace name','string',fileCfg,varargin{1});
    % Check that the file exists. If the file does not exist, the
    % simulation is aborted.
    fid = fopen(simParams.filenameTrace);
    if fid==-1
        fprintf('File trace "%s" not found. Simulation Aborted.',simParams.filenameTrace);
    else
        fclose(fid);
    end
    
    % [XminTrace]
    % Minimum X coordinate to keep in the traffic trace (m)
    [simParams,varargin] = addNewParam(simParams,'XminTrace',-1,'Minimum X coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
    if simParams.XminTrace~=-1 && simParams.XminTrace<0
        error('Error: the value set for "simParams.XminTrace" is not valid');
    end
    
    % [XmaxTrace]
    % Maximum X coordinate to keep in the traffic trace (m)
    [simParams,varargin] = addNewParam(simParams,'XmaxTrace',-1,'Maximum X coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
    if simParams.XmaxTrace~=-1 && simParams.XmaxTrace<0 && simParams.XmaxTrace<simParams.XminTrace
        error('Error: the value set for "simParams.XmaxTrace" is not valid');
    end
    
    % [YminTrace]
    % Minimum Y coordinate to keep in the traffic trace (m)
    [simParams,varargin] = addNewParam(simParams,'YminTrace',-1,'Minimum Y coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
    if simParams.YminTrace~=-1 && simParams.YminTrace<0
        error('Error: the value set for "simParams.YminTrace" is not valid');
    end
    
    % [YmaxTrace]
    % Maximum Y coordinate to keep in the traffic trace (m)
    [simParams,varargin] = addNewParam(simParams,'YmaxTrace',-1,'Maximum Y coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
    if simParams.YmaxTrace~=-1 && simParams.YmaxTrace<0 && simParams.XmaxTrace<simParams.YminTrace
        error('Error: the value set for "simParams.YmaxTrace" is not valid');
    end
    
    % [positionTimeResolution]
    % Time resolution for the positioning update of the vehicles in the trace file (s)
    [simParams,varargin] = addNewParam(simParams,'positionTimeResolution',-1,'Time resolution for the positioning update of the vehicles in the trace file (s)','double',fileCfg,varargin{1});
    if simParams.positionTimeResolution<=0 && simParams.positionTimeResolution~=-1
        error('Error: "simParams.positionTimeResolution" cannot be <= 0 or different from -1');
    end
    
    % Depending on the setting of "simParams.fileObstaclesMap", other parameters must
    % be set
    if simParams.fileObstaclesMap
        % [filenameObstaclesMap]
        % If the obstacles map file is used, this selects the file
        [simParams,varargin] = addNewParam(simParams,'filenameObstaclesMap','null.txt','File obstacles map name','string',fileCfg,varargin{1});
        % Check that the file exists. If the file does not exist, the
        % simulation is aborted.
        fid = fopen(simParams.filenameObstaclesMap);
        if fid==-1
            fprintf('File obstacles map "%s" not found. Simulation Aborted.',simParams.filenameObstaclesMap);
        else
            fclose(fid);
        end
    end
else
    simParams.fileObstaclesMap = false;
    
    if simParams.typeOfScenario==1 % Legacy PPP
        % [roadLength]
        % Length of the road to be simulated (m)
        [simParams,varargin] = addNewParam(simParams,'roadLength',4000,'Road Length (m)','double',fileCfg,varargin{1});
        if simParams.roadLength<=0
            error('Error: "simParams.roadLength" cannot be <= 0');
        end

        % [roadWidth]
        % Width of each lane (m)
        [simParams,varargin] = addNewParam(simParams,'roadWidth',3.5,'Road Width (m)','double',fileCfg,varargin{1});
        if simParams.roadWidth<0
            error('Error: "simParams.roadWidth" cannot be < 0');
        end
        
        % [vMean]
        % Mean speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vMean',114.23,'Mean speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vMean<0
            error('Error: "simParams.vMean" cannot be < 0');
        end

        % [vStDev]
        % Standard deviation of speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vStDev',12.65,'Standard deviation of speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vStDev<0
            error('Error: "simParams.vStDev" cannot be < 0');
        end
        
        % [rho]
        % Density of vehicles (vehicles/km)
        [simParams,varargin] = addNewParam(simParams,'rho',100,'Density of vehicles (vehicles/km)','double',fileCfg,varargin{1});
        if simParams.rho<=0
            error('Error: "simParams.rho" cannot be <= 0');
        end
    elseif simParams.typeOfScenario==3 % ETSI Highway high speed
        % [roadLength]
        % Length of the road to be simulated (m)
        [simParams,varargin] = addNewParam(simParams,'roadLength',2000,'Road Length (m)','double',fileCfg,varargin{1});
        if simParams.roadLength<=0
            error('Error: "simParams.roadLength" cannot be <= 0');
        end

        % [roadWidth]
        % Width of each lane (m)
        [simParams,varargin] = addNewParam(simParams,'roadWidth',4,'Road Width (m)','double',fileCfg,varargin{1});
        if simParams.roadWidth<0
            error('Error: "simParams.roadWidth" cannot be < 0');
        end
        
        % [vMean]
        % Mean speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vMean',240,'Mean speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vMean<0
            error('Error: "simParams.vMean" cannot be < 0');
        end

        % [vStDev]
        % Standard deviation of speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vStDev',0,'Standard deviation of speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vStDev<0
            error('Error: "simParams.vStDev" cannot be < 0');
        end
        
        % [rho]
        % Density of vehicles (vehicles/km)
        [simParams,varargin] = addNewParam(simParams,'rho',35,'Density of vehicles (vehicles/km)','double',fileCfg,varargin{1});
        if simParams.rho<=0
            error('Error: "simParams.rho" cannot be <= 0');
        end
    end
    % [NLanes]
    % Number of lanes per direction
    [simParams,varargin] = addNewParam(simParams,'NLanes',3,'Number of lanes per direction','integer',fileCfg,varargin{1});
    if simParams.NLanes<=0
        error('Error: "simParams.NLanes" cannot be <= 0');
    end
    
end


% [neighborsSelection]
% Choose whether to use significant neighbors selection
[simParams,varargin] = addNewParam(simParams,'neighborsSelection',false,'If using significant neighbors selection','bool',fileCfg,varargin{1});
if simParams.neighborsSelection~=false && simParams.neighborsSelection~=true
    error('Error: "simParams.neighborsSelection" must be equal to false or true');
end

if simParams.neighborsSelection
    error('This version of the simulator has not been tested with "neighborsSelection"');
    % [Mvicinity]
    % Margin for trajectory vicinity (m)
    %[simParams,varargin] = addNewParam(simParams,'Mvicinity',10,'Margin for trajectory vicinity (m)','integer',fileCfg,varargin{1});
    %if simParams.Mvicinity < 0
    %    error('Error: "simParams.Mvicinity" cannot be negative.');
    %end
end

fprintf('\n');

end
