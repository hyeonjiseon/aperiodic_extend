function [positionManagement,stationManagement] = computeDistance (simParams,simValues,stationManagement,positionManagement,phyParams)

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

% Compute distance matrix
positionManagement.distanceReal = sqrt((positionManagement.XvehicleReal - positionManagement.XvehicleReal').^2+(positionManagement.YvehicleReal - positionManagement.YvehicleReal').^2);
if simParams.technology ~= 2 && ... % not only 11p
    (simParams.posError95 || positionManagement.NgroupPosUpdate~=1) %LTE
    positionManagement.distanceEstimated = sqrt((simValues.XvehicleEstimated - simValues.XvehicleEstimated').^2+(simValues.YvehicleEstimated - simValues.YvehicleEstimated').^2);
else
    positionManagement.distanceEstimated = positionManagement.distanceReal;
end

%%
% LTE
%distanceReal_LTE = positionManagement.distanceReal(:,(stationManagement.vehicleState(stationManagement.activeIDs)==100));
if simParams.technology~=2 % Not only 11p
    distanceReal_LTE = positionManagement.distanceReal;
    % Vehciles that are not LTE are set to an infinite distance
    distanceReal_LTE(:,(stationManagement.vehicleState(stationManagement.activeIDs)~=100))=Inf;
    % The diagonal must be set to 0
    distanceReal_LTE(1:1+length(distanceReal_LTE(1,:)):end) = 0;
    % sort
    [neighborsDistanceLTE, neighborsIndexLTE] = sort(distanceReal_LTE,2);
    % remove the first element per each raw, which is self
    neighborsDistanceLTE(:,1) = [];
    neighborsIndexLTE(:,1) = [];    
    neighborsDistanceLTE_ofLTE = neighborsDistanceLTE(stationManagement.vehicleState(stationManagement.activeIDs)==100,:);
    neighborsIndexLTE_ofLTE = neighborsIndexLTE(stationManagement.vehicleState(stationManagement.activeIDs)==100,:);
    
    % Vehicles in order of distance
    %allNeighborsID = IDvehicle(neighborsIndexLTE);

    % Vehicles in the maximum awareness range
    stationManagement.neighborsIDLTE = (neighborsDistanceLTE_ofLTE < phyParams.RawMaxLTE) .*stationManagement.activeIDs(neighborsIndexLTE_ofLTE);

    % Vehicles in awareness range
    stationManagement.awarenessIDLTE = zeros(length(neighborsDistanceLTE_ofLTE(:,1)),length(neighborsDistanceLTE_ofLTE(1,:)),length(phyParams.Raw));
    for iPhyRaw=1:length(phyParams.Raw)
        stationManagement.awarenessIDLTE(:,:,iPhyRaw) = (neighborsDistanceLTE_ofLTE < phyParams.Raw(iPhyRaw)) .* stationManagement.neighborsIDLTE;
    end

    % Keep only the distance of neighbors up to the maximum awareness range
    % and dealing with the technology of interest
    stationManagement.neighborsDistanceLTE = (neighborsDistanceLTE_ofLTE < phyParams.RawMaxLTE) .* neighborsDistanceLTE_ofLTE;

    stationManagement.neighborsIDLTE = stationManagement.neighborsIDLTE(:,1:length(stationManagement.activeIDsLTE)-1);
    stationManagement.awarenessIDLTE = stationManagement.awarenessIDLTE(:,1:length(stationManagement.activeIDsLTE)-1,:);
    stationManagement.neighborsDistanceLTE = stationManagement.neighborsDistanceLTE(:,1:length(stationManagement.activeIDsLTE)-1);
    
    % LTE vehicles interfering 11p
    if simParams.technology > 2
        neighborsDistanceLTE_of11p = neighborsDistanceLTE(stationManagement.vehicleState(stationManagement.activeIDs)~=100,:);
        neighborsIndexLTE_of11p = neighborsIndexLTE(stationManagement.vehicleState(stationManagement.activeIDs)~=100,:);
        stationManagement.LTEinterfereingTo11p_ID = (neighborsDistanceLTE_of11p < phyParams.RawMaxLTE) .*stationManagement.activeIDs(neighborsIndexLTE_of11p);
    end
end
%%

%%
% 11p
if simParams.technology~=1 % Not only LTE
    distanceReal_11p = positionManagement.distanceReal;
    % Vehciles that are not LTE are set to an infinite distance
    distanceReal_11p(:,(stationManagement.vehicleState(stationManagement.activeIDs)==100))=Inf;
    % The diagonal must be set to 0
    distanceReal_11p(1:1+length(distanceReal_11p(1,:)):end) = 0;
    % sort
    [neighborsDistance11p, neighborsIndex11p] = sort(distanceReal_11p,2);
    % remove the first element per each raw, which is self
    neighborsDistance11p(:,1) = [];
    neighborsIndex11p(:,1) = [];    
    neighborsDistance11p_of11p = neighborsDistance11p(stationManagement.vehicleState(stationManagement.activeIDs)~=100,:);
    neighborsIndex11p_of11p = neighborsIndex11p(stationManagement.vehicleState(stationManagement.activeIDs)~=100,:);
    
    % Vehicles in the maximum awareness range
    stationManagement.neighborsID11p = (neighborsDistance11p_of11p < phyParams.RawMax11p) .*stationManagement.activeIDs(neighborsIndex11p_of11p);

    % Vehicles in awareness range
    stationManagement.awarenessID11p = zeros(length(neighborsDistance11p_of11p(:,1)),length(neighborsDistance11p_of11p(1,:)),length(phyParams.Raw));
    for iPhyRaw=1:length(phyParams.Raw)
        stationManagement.awarenessID11p(:,:,iPhyRaw) = (neighborsDistance11p_of11p < phyParams.Raw(iPhyRaw)) .* stationManagement.neighborsID11p;
    end
    

    % Keep only the distance of neighbors up to the maximum awareness range
    % and dealing with the technology of interest
    stationManagement.neighborsDistance11p = (neighborsDistance11p_of11p < phyParams.RawMax11p) .* neighborsDistance11p_of11p;

    % 11p vehicles interfering LTE
    if simParams.technology > 2
        neighborsDistance11p_ofLTE = neighborsDistance11p(stationManagement.vehicleState(stationManagement.activeIDs)==100,:);
        neighborsIndex11p_ofLTE = neighborsIndex11p(stationManagement.vehicleState(stationManagement.activeIDs)==100,:);
        stationManagement.LTEinterfereingTo11p_ID = (neighborsDistance11p_ofLTE < phyParams.RawMaxLTE) .*stationManagement.activeIDs(neighborsIndex11p_ofLTE);
    end
end
%%

end