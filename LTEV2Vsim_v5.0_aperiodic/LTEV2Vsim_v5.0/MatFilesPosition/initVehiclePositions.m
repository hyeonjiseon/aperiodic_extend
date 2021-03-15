function [simParams,simValues,positionManagement] = initVehiclePositions(simParams,appParams)
% Function to initialize the positions of vehicles

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

if simParams.typeOfScenario~=2 % Not traffic trace
    
    % Scenario
    positionManagement.Xmin = 0;                           % Min X coordinate
    simValues.Xmax = simParams.roadLength;        % Max X coordinate
    positionManagement.Ymin = 0;                           % Min Y coordinate
    % Max Y coordinate
    simValues.Ymax = 2*simParams.NLanes*simParams.roadWidth;
    
    vMeanMs = simParams.vMean/3.6;                % Mean vehicle speed (m/s)
    vStDevMs = simParams.vStDev/3.6;              % Speed standard deviation (m/s)
    simParams.rhoM = simParams.rho/1e3;           % Average vehicle density (vehicles/m)
    
    Nvehicles = round(simParams.rhoM*simValues.Xmax);   % Number of vehicles
    
    simValues.IDvehicle(:,1) = 1:Nvehicles;             % Vector of IDs
    simValues.maxID = Nvehicles;                        % Maximum vehicle's ID
    
    % Generate X coordinates of vehicles (uniform distribution)
    positionManagement.XvehicleReal = simValues.Xmax.*rand(Nvehicles,1);
    
    % Uniformly positioned
    %positionManagement.XvehicleReal = (1:Nvehicles)*floor(simValues.Xmax/(Nvehicles));
    
    % Generate driving direction
    % 0 -> from left to right
    % 1 -> from right to left
    if simParams.typeOfScenario == 1 % Legacy PPP
        simValues.direction = rand(Nvehicles,1) > 0.5;
        right = find(simValues.direction==0);
        left = find(simValues.direction);

        % Generate Y coordinates of vehicles (distributed among Nlanes)
        positionManagement.YvehicleReal = zeros(Nvehicles,1);
        for i = 1:length(right)
            lane = randi(simParams.NLanes);
            positionManagement.YvehicleReal(right(i)) = lane*simParams.roadWidth;
        end
        for i = 1:length(left)
            lane = randi([simParams.NLanes+1 2*simParams.NLanes]);
            positionManagement.YvehicleReal(left(i)) = lane*simParams.roadWidth;
        end
    elseif simParams.typeOfScenario == 3 % ETSI Highway high speed
        %positionManagement.YvehicleReal = zeros(Nvehicles,1);
        laneSelected = simParams.NLanes + 0.5 + ((-1).^(mod(mod(((1:Nvehicles)-1),(2*simParams.NLanes))+1+1,2))) .* (ceil((mod(((1:Nvehicles)-1),2*simParams.NLanes)+1)/2)-0.5);
        % The lane, selected in order, need to be shuffled       
        laneSelected = laneSelected(randperm(numel(laneSelected)));
        % and then the Y and direction follow from the selected lane
        positionManagement.YvehicleReal = laneSelected'*simParams.roadWidth;
        simValues.direction =  mod(ceil(laneSelected'/simParams.NLanes)-1,2) ;
    end
    
    % Assign speed to vehicles
    % Gaussian with 'vMeanMs' mean and 'vStDevMs' standard deviation
    % the Gaussian is truncated to avoid negative values or still vehicles
    % (not optimized, but used only once during initialization)
    simValues.v = abs(vMeanMs + vStDevMs.*randn(Nvehicles,1));
    for i=1:Nvehicles
        while simValues.v(i)<0 || (vMeanMs>0 && simValues.v(i)==0)
            % if the speed is negative or zero, a new value is randomly selected
            simValues.v(i) = abs(vMeanMs + vStDevMs.*randn(1,1));
        end
    end
    
    % Time resolution of position update corresponds to the beacon period
    simParams.positionTimeResolution = appParams.averageTbeacon;
    
else
    
    % Call function to load the traffic trace up to the selected simulation
    % time and, if selected, take only a portion of the scenario
    [dataLoaded,simParams] = loadTrafficTrace(simParams);
    
    % Call function to interpolate the traffic trace (if needed)
    [simValues,simParams] = interpolateTrace(dataLoaded,simParams,appParams.averageTbeacon);
    
    % Round time column (representation format)
    simValues.dataTrace(:,1) = round(simValues.dataTrace(:,1)*100)/100;
    
    % Find trace details (Xmin,Xmax,Ymin,Ymax,maxID)
    positionManagement.Xmin = min(simValues.dataTrace(:,3));     % Min X coordinate Trace
    simValues.Xmax = max(simValues.dataTrace(:,3));     % Max X coordinate Trace
    positionManagement.Ymin = min(simValues.dataTrace(:,4));     % Min Y coordinate Trace
    simValues.Ymax = max(simValues.dataTrace(:,4));     % Max Y coordinate Trace
    simValues.maxID = max(simValues.dataTrace(:,2));    % Maximum vehicle's ID
    
    % Call function to read vehicle positions from file at time zero
    [positionManagement.XvehicleReal, positionManagement.YvehicleReal, simValues.IDvehicle] = updatePositionFile(0,simValues.dataTrace,0);
    
end

% Throw an error if there are no vehicles in the scenario
if isempty(simValues.IDvehicle)
    error('Error: no vehicles in the simulation.');
end

end
