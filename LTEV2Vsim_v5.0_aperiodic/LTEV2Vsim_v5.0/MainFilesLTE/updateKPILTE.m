function [stationManagement,outputValues,simValues] = updateKPILTE(activeIDsTXLTE,indexInActiveIDsOnlyLTE,awarenessID_LTE,neighborsID_LTE,timeManagement,stationManagement,positionManagement,sinrManagement,outputValues,outParams,simParams,appParams,phyParams,simValues)

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

% Error detection (up to RawMax)
errorMatrixRawMax = findErrors(activeIDsTXLTE,indexInActiveIDsOnlyLTE,neighborsID_LTE,sinrManagement,stationManagement,positionManagement,phyParams);

% Error detection (within each value of Raw)
for iPhyRaw=1:length(phyParams.Raw)
    
    errorMatrix = errorMatrixRawMax(errorMatrixRawMax(:,4)<phyParams.Raw(iPhyRaw),:);

    % Call function to create awarenessMatrix
    % [#Correctly transmitted beacons, #Errors, #Neighbors]
    awarenessMatrix = counterTX(activeIDsTXLTE,indexInActiveIDsOnlyLTE,awarenessID_LTE(:,:,iPhyRaw),errorMatrix);

    % Number of errors
    Nerrors = length(errorMatrix(:,1));
    outputValues.NerrorsLTE(iPhyRaw) = outputValues.NerrorsLTE(iPhyRaw) + Nerrors;
    outputValues.NerrorsTOT(iPhyRaw) = outputValues.NerrorsTOT(iPhyRaw) + Nerrors;

    % Number of transmitted beacons
    NtxBeacons = sum(awarenessMatrix(:,3));
    outputValues.NtxBeaconsLTE(iPhyRaw) = outputValues.NtxBeaconsLTE(iPhyRaw) + NtxBeacons;
    outputValues.NtxBeaconsTOT(iPhyRaw) = outputValues.NtxBeaconsTOT(iPhyRaw) + NtxBeacons;

    % Number of correctly transmitted beacons
    NcorrectlyTxBeacons = sum(awarenessMatrix(:,1));
    outputValues.NcorrectlyTxBeaconsLTE(iPhyRaw) = outputValues.NcorrectlyTxBeaconsLTE(iPhyRaw) + NcorrectlyTxBeacons;
    outputValues.NcorrectlyTxBeaconsTOT(iPhyRaw) = outputValues.NcorrectlyTxBeaconsTOT(iPhyRaw) + NcorrectlyTxBeacons;

    % Compute update delay (if enabled)
    if outParams.printUpdateDelay
        [simValues.updateTimeMatrixLTE,outputValues.updateDelayCounterLTE] = countUpdateDelay(iPhyRaw,activeIDsTXLTE,indexInActiveIDsOnlyLTE,stationManagement.BRid,appParams.NbeaconsF,awarenessID_LTE(:,:,iPhyRaw),errorMatrix,timeManagement.timeNow,simValues.updateTimeMatrixLTE,outputValues.updateDelayCounterLTE,outParams.delayResolution,outParams.enableUpdateDelayHD);
    end

    % Compute data age (if enabled)
    if outParams.printDataAge
        [simValues.dataAgeTimestampMatrixLTE,outputValues.dataAgeCounterLTE] = countDataAge(iPhyRaw,timeManagement,activeIDsTXLTE,indexInActiveIDsOnlyLTE,stationManagement.BRid,appParams.NbeaconsF,awarenessID_LTE(:,:,iPhyRaw),errorMatrix,timeManagement.timeNow,simValues.dataAgeTimestampMatrixLTE,outputValues.dataAgeCounterLTE,outParams.delayResolution);
    end

    % Compute packet delay (if enabled)
    if outParams.printPacketDelay
        outputValues.packetDelayCounterLTE = countPacketDelay(iPhyRaw,activeIDsTXLTE,timeManagement.timeNow,timeManagement.timeLastPacket,awarenessMatrix(:,1),outputValues.packetDelayCounterLTE,outParams.delayResolution);
    end

    % Compute power control allocation (if enabled)
    if outParams.printPowerControl
        error('Output not updated in v5');
        %   % Convert linear PtxERP values to Ptx in dBm
        %	Ptx_dBm = 10*log10((phyParams.PtxERP_RB*appParams.RBsBeacon)/(2*phyParams.Gt))+30;
        %	outputValues.powerControlCounter = countPowerControl(IDvehicleTX,Ptx_dBm,outputValues.powerControlCounter,outParams.powerResolution);
    end

    % Update matrices needed for PRRmap creation in urban scenarios (if enabled)
    if simParams.typeOfScenario==2 && outParams.printPRRmap
        simValues = counterMap(iPhyRaw,simValues,stationManagement.activeIDsLTE,indexInActiveIDsOnlyLTE,activeIDsTXLTE,awarenessID_LTE(:,:,iPhyRaw),errorMatrix);
    end

end

% Count distance details for distances up to the maximum awareness range (if enabled)
if outParams.printPacketReceptionRatio
    outputValues.distanceDetailsCounterLTE = countDistanceDetails(indexInActiveIDsOnlyLTE,neighborsID_LTE,stationManagement.neighborsDistanceLTE,errorMatrixRawMax,outputValues.distanceDetailsCounterLTE,outParams);
end