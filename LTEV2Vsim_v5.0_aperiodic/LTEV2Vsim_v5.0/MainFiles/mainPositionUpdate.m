function [appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement] = ...
    mainPositionUpdate(appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement)
% the position of all vehicles is updated
        
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
    % Call function to update vehicles positions
    [positionManagement.XvehicleReal,positionManagement.YvehicleReal,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,stationManagement.activeIDsExit] = updatePosition(positionManagement.XvehicleReal,positionManagement.YvehicleReal,stationManagement.activeIDs,simValues.v,simValues.direction,simParams.positionTimeResolution,simValues.Xmax);
else
    % Store IDs of vehicles at the previous beacon period and update positions
    [positionManagement.XvehicleReal,positionManagement.YvehicleReal,stationManagement.activeIDs,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,stationManagement.activeIDsExit] = updatePositionFile(round(timeManagement.timeNextPosUpdate*100)/100,simValues.dataTrace,stationManagement.activeIDs);
    %% ONLY LTE
    if simParams.technology ~= 2 % not only 11p
        % Update stationManagement.BRid vector (variable number of vehicles in the scenario)
        [stationManagement.BRid] = updateBRidFile(stationManagement.BRid,stationManagement.activeIDs,indexNewVehicles);
    end
end

% Vectors IDvehicleLTE and IDvehicle11p are updated
stationManagement.activeIDsLTE = stationManagement.activeIDs.*(stationManagement.vehicleState(stationManagement.activeIDs)==100);
stationManagement.activeIDsLTE = stationManagement.activeIDsLTE(stationManagement.activeIDsLTE>0);
stationManagement.activeIDs11p = stationManagement.activeIDs.*(stationManagement.vehicleState(stationManagement.activeIDs)~=100);
stationManagement.activeIDs11p = stationManagement.activeIDs11p(stationManagement.activeIDs11p>0);
stationManagement.indexInActiveIDs_ofLTEnodes = zeros(length(stationManagement.activeIDsLTE),1);
for i=1:length(stationManagement.activeIDsLTE)
    stationManagement.indexInActiveIDs_ofLTEnodes(i) = find(stationManagement.activeIDs==stationManagement.activeIDsLTE(i));
end
stationManagement.indexInActiveIDs_of11pnodes = zeros(length(stationManagement.activeIDs11p),1);
for i=1:length(stationManagement.activeIDs11p)
    stationManagement.indexInActiveIDs_of11pnodes(i) = find(stationManagement.activeIDs==stationManagement.activeIDs11p(i));
end

% % For possible DEBUG
% figure(300)
% plot(timeManagement.timeNextPosUpdate*100*ones(1,length(positionManagement.XvehicleReal)),positionManagement.XvehicleReal,'*');
% hold on

% Set value of next position update
timeManagement.timeNextPosUpdate = timeManagement.timeNextPosUpdate + simParams.positionTimeResolution;
positionManagement.NposUpdates = positionManagement.NposUpdates+1;

% Update variables for resource allocation in LTE-V2V
if simParams.technology ~= 2 % not only 11p

    if simParams.BRAlgorithm==18 && timeManagement.timeNow > phyParams.Tsf
        % Update stationManagement.resReselectionCounterLTE for vehicles exiting the scenario
        stationManagement.resReselectionCounterLTE(stationManagement.activeIDsExit) = Inf;
        % Update stationManagement.resReselectionCounterLTE for vehicles entering the scenario
        % a) LTE vehicles that enter or are blocked start with a counter set to 0
        % b) 11p vehicles are set to Inf
        stationManagement.resReselectionCounterLTE(logical((stationManagement.BRid==-1) .* (stationManagement.vehicleState==100))) = 0;
        stationManagement.resReselectionCounterLTE(logical((stationManagement.BRid==-1) .* (stationManagement.vehicleState~=100))) = Inf;
        % Reset stationManagement.errorSCImatrixLTE for new computation of correctly received SCIs
        %stationManagement.correctSCImatrixLTE = zeros(length(stationManagement.activeIDsLTE),length(stationManagement.activeIDsLTE)-1);
    end
    
    % Add LTE positioning delay (if selected)
    [simValues.XvehicleEstimated,simValues.YvehicleEstimated,PosUpdateIndex] = addPosDelay(simValues.XvehicleEstimated,simValues.YvehicleEstimated,positionManagement.XvehicleReal,positionManagement.YvehicleReal,stationManagement.activeIDs,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,positionManagement.posUpdateAllVehicles,simParams.positionTimeResolution);

    % Add LTE positioning error (if selected)
    % (Xvehicle, Yvehicle): fictitious vehicles' position seen by the eNB
    [simValues.XvehicleEstimated(PosUpdateIndex),simValues.YvehicleEstimated(PosUpdateIndex)] = addPosError(positionManagement.XvehicleReal(PosUpdateIndex),positionManagement.YvehicleReal(PosUpdateIndex),simParams.sigmaPosError);
end

% Call function to compute the distances
[positionManagement,stationManagement] = computeDistance (simParams,simValues,stationManagement,positionManagement,phyParams);

% Call function to update positionManagement.distance matrix where D(i,j) is the
% change in positionManagement.distance of link i to j from time n-1 to time n and used
% for updating Shadowing matrix
[dUpdate,sinrManagement.Shadowing_dB,positionManagement.distanceRealOld] = updateDistance(positionManagement.distanceReal,positionManagement.distanceRealOld,indexOldVehicles,indexOldVehiclesToOld,sinrManagement.Shadowing_dB,phyParams.stdDevShadowLOS_dB);

% Calculation of channel and then received power
% TODO in future version the two functions to compute the channel gain
% should be included in a single one
[CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChannelGain(sinrManagement,positionManagement,phyParams,simParams,dUpdate);
% if ~phyParams.winnerModel   
%     [CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChGain(positionManagement.distanceReal,phyParams.L0,phyParams.beta,positionManagement.XvehicleReal,positionManagement.YvehicleReal,phyParams.Abuild,phyParams.Awall,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap,positionManagement.GridMap,simParams.fileObstaclesMap,sinrManagement.Shadowing_dB,dUpdate,phyParams.stdDevShadowLOS_dB,phyParams.stdDevShadowNLOS_dB);
% else
%     [CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChGainWinner(positionManagement.distanceReal,positionManagement.XvehicleReal,positionManagement.YvehicleReal,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap,positionManagement.GridMap,simParams.fileObstaclesMap,sinrManagement.Shadowing_dB,dUpdate,phyParams.stdDevShadowLOS_dB,phyParams.stdDevShadowNLOS_dB);
% end

% Compute RXpower
% NOTE: sinrManagement.P_RX_MHz( RECEIVER, TRANSMITTER) 
sinrManagement.P_RX_MHz = ( (phyParams.P_ERP_MHz_LTE(stationManagement.activeIDs).*(stationManagement.vehicleState(stationManagement.activeIDs)==100))' + ...
    (phyParams.P_ERP_MHz_11p(stationManagement.activeIDs).*(stationManagement.vehicleState(stationManagement.activeIDs)~=100) )' )...
    * phyParams.Gr .* min(1,CHgain);

% Floor coordinates for PRRmap creation (if enabled)
if simParams.typeOfScenario==2 && outParams.printPRRmap % only traffic trace 
    simValues.XmapFloor = floor(simValues.Xmap);
    simValues.YmapFloor = floor(simValues.Ymap);
end

% Call function to calculate effective neighbors (if enabled)
if simParams.neighborsSelection
    %% TODO - needs update
    error('Significant neighbors not updated in v5');
%     if simParams.technology ~= 2 % not only 11p
%         % LTE
%         [stationManagement.awarenessIDLTE,stationManagement.neighborsIDLTE,positionManagement.XvehicleRealOld,positionManagement.YvehicleRealOld,positionManagement.angleOld] = computeSignificantNeighbors(stationManagement.activeIDs,positionManagement.XvehicleReal,positionManagement.YvehicleReal,positionManagement.XvehicleRealOld,positionManagement.YvehicleRealOld,stationManagement.neighborsIDLTE,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,positionManagement.angleOld,simParams.Mvicinity,phyParams.RawLTE,phyParams.RawMaxLTE,stationManagement.neighborsDistance);
%     end
%     if simParams.technology ~= 1 % not only LTE
%         % 11p
%         [stationManagement.awarenessID11p,stationManagement.neighborsID11p,positionManagement.XvehicleRealOld,positionManagement.YvehicleRealOld,positionManagement.angleOld] = computeSignificantNeighbors(stationManagement.activeIDs,positionManagement.XvehicleReal,positionManagement.YvehicleReal,positionManagement.XvehicleRealOld,positionManagement.YvehicleRealOld,stationManagement.neighborsID11p,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,positionManagement.angleOld,simParams.Mvicinity,phyParams.Raw11p,phyParams.RawMax11p,stationManagement.neighborsDistance);
%     end
end

% Call function to compute hidden or non-hidden nodes (if enabled)
if outParams.printHiddenNodeProb
    %% TODO - needs update
    error('printHiddenNodeProb not updated in v5');
    %[outputValues.hiddenNodeSumProb,outputValues.hiddenNodeProbEvents] = computeHiddenNodeProb(stationManagement.activeIDs,positionManagement.distanceReal,sinrManagement.RXpower,phyParams.gammaMin,phyParams.PnRB,outParams.PthRB,outputValues.hiddenNodeSumProb,outputValues.hiddenNodeProbEvents);
end

% Number of vehicles in the scenario
outputValues.Nvehicles = length(stationManagement.activeIDs);
outputValues.NvehiclesTOT = outputValues.NvehiclesTOT + outputValues.Nvehicles;
outputValues.NvehiclesLTE = outputValues.NvehiclesLTE + length(stationManagement.activeIDsLTE);
outputValues.Nvehicles11p = outputValues.Nvehicles11p + length(stationManagement.activeIDs11p);

% Number of neighbors
[outputValues,NneighborsRaw] = updateAverageNeighbors(simParams,stationManagement,outputValues,phyParams);

% Print number of neighbors per vehicle to file (if enabled)
if outParams.printNeighbors
    printNeighborsToFile(NneighborsRaw,outParams);
end

% Prepare matrix for update delay computation (if enabled)
if outParams.printUpdateDelay
    % Reset update time of vehicles that are outside the scenario
    allIDOut = setdiff(1:simValues.maxID,stationManagement.activeIDs);
    simValues.updateTimeMatrix11p(allIDOut,:) = -1;
    simValues.updateTimeMatrix11p(:,allIDOut) = -1;
    simValues.updateTimeMatrixLTE(allIDOut,:) = -1;
    simValues.updateTimeMatrixLTE(:,allIDOut) = -1;
end

% Prepare matrix for update delay computation (if enabled)
if outParams.printDataAge
    % Reset update time of vehicles that are outside the scenario
    allIDOut = setdiff(1:simValues.maxID,stationManagement.activeIDs);
    simValues.dataAgeTimestampMatrix11p(allIDOut,:) = -1;
    simValues.dataAgeTimestampMatrix11p(:,allIDOut) = -1;
    simValues.dataAgeTimestampMatrixLTE(allIDOut,:) = -1;
    simValues.dataAgeTimestampMatrixLTE(:,allIDOut) = -1;
end

% Compute wireless blind spot probability (if enabled - update delay is required)
if outParams.printUpdateDelay && outParams.printWirelessBlindSpotProb
     error('Not updated in v. 5.X');
%         %% TODO with coexistence
%         if simParams.technology~=1 && simParams.technology~=2
%             error('Not implemented');
%         end
%         if simParams.technology==2 || elapsedTime_subframes>appParams.NbeaconsT
%             if simParams.technology==1
%                 outputValues.wirelessBlindSpotCounter = countWirelessBlindSpotProb(simValues.updateTimeMatrixLTE,outputValues.wirelessBlindSpotCounter,timeManagement.timeNow);
%             else
%                 outputValues.wirelessBlindSpotCounter = countWirelessBlindSpotProb(simValues.updateTimeMatrix11p,outputValues.wirelessBlindSpotCounter,timeManagement.timeNow);
%             end
%         end        
end

% Update of parameters related to transmissions in IEEE 802.11p to cope
% with vehicles exiting the scenario
if simParams.technology ~= 1 % not only LTE
    
    timeManagement.timeNextTxRx11p(stationManagement.activeIDsExit) = Inf;
    sinrManagement.idFromWhichRx11p(stationManagement.activeIDsExit) = stationManagement.activeIDsExit;
    sinrManagement.instantThisSINRavStarted11p(stationManagement.activeIDsExit) = Inf;
    stationManagement.vehicleState(stationManagement.activeIDsExit(stationManagement.vehicleState(stationManagement.activeIDsExit)~=100)) =  1;
    
    % The average SINR of all vehicles is then updated
    sinrManagement = updateSINR11p(timeManagement,sinrManagement,stationManagement,phyParams);

    % The nodes that may stop receiving must be checked
    [timeManagement,stationManagement,sinrManagement] = checkVehiclesStopReceiving11p(timeManagement,stationManagement,sinrManagement,simParams,phyParams);

    % The present overall/useful power received and the instant of calculation are updated
    % The power received must be calculated after
    % 'checkVehiclesStopReceiving11p', to have the correct idFromWhichtransmitting
    [sinrManagement] = updateLastPower11p(timeManagement,stationManagement,sinrManagement,phyParams,simValues);       
end

% Generate time values of new vehicles entering the scenario
timeManagement.timeNextPacket(stationManagement.activeIDs(indexNewVehicles)) = timeManagement.timeNow + appParams.averageTbeacon * rand(1,length(indexNewVehicles));
timeManagement.beaconPeriod(stationManagement.activeIDs(indexNewVehicles)) = appParams.averageTbeacon - appParams.variabilityTbeacon/2 + appParams.variabilityTbeacon*rand(length(indexNewVehicles),1);
timeManagement.beaconPeriod(stationManagement.activeIDsLTE) = appParams.averageTbeacon;
% Reset time next packet and tx-rx for vehicles that exit the scenario
timeManagement.timeNextPacket(stationManagement.activeIDsExit) = Inf;

% Reset time next packet and tx-rx for vehicles that exit the scenario
stationManagement.nPackets(stationManagement.activeIDsExit) = zeros(length(stationManagement.activeIDsExit),1);
stationManagement.vehicleState(stationManagement.activeIDsExit) = zeros(length(stationManagement.activeIDsExit),1);


