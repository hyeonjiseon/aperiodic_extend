function [phyParams,simValues,outputValues,sinrManagement,stationManagement,timeManagement] = ...
            mainLTEsubframeEnds(appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement)
% an LTE subframe ends
        
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
     
% local variables for simpler reading
awarenessID_LTE = stationManagement.awarenessIDLTE;
neighborsID_LTE = stationManagement.neighborsIDLTE;

% Compute elapsed time [the unit of measure is the subframe time i.e. phyParams.Tsf]
%elapsedTime_subframes = floor((timeManagement.timeNow-1e-9)/phyParams.Tsf)+1;

if ~isempty(stationManagement.transmittingIDsLTE)     
    
    % Find ID and index of vehicles that are currently transmitting in LTE
    activeIDsTXLTE = stationManagement.transmittingIDsLTE;
    indexInActiveIDsOnlyLTE = stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE;

    %% Start computing KPIs only after the first BR assignment (after the first cycle)

    % Compute SINR of received beacons
    sinrManagement = updateSINRLTE(timeManagement.timeNow,stationManagement,sinrManagement,phyParams.Pnoise_MHz*phyParams.BwMHz_lteBR,simParams,appParams);

    % Code for possible DEBUG
    % figure(100)
    % plot(elapsedTime_subframes*ones(1,length(neighborsSINRaverageLTE(:,:))),10*log10(neighborsSINRaverageLTE(:,:)),'*');
    % hold on

    % DEBUG TX
    printDebugTx(timeManagement.timeNow,false,-1,stationManagement,positionManagement,sinrManagement,outParams,phyParams);

    % Code for possible DEBUG
    % figure(200)
    % plot(elapsedTime_subframes*ones(1,length(errorMatrixRawMax(:,4))),errorMatrixRawMax(:,4),'*');
    % hold on

    % Code for possible DEBUG
    % figure(300)
    % plot(elapsedTime_subframes*ones(1,length(errorMatrix(1,:))),10*log10(errorMatrix(1,:)),'*');
    % hold on

    % Check the correctness of SCI messages
    if simParams.BRAlgorithm==18
        % correctSCImatrix is nTXLTE x nNeighblors
        stationManagement.correctSCImatrixLTE = (sinrManagement.neighborsSINRsciAverageLTE > phyParams.minSCIsinr);
    end

    %% KPIs Computation (Snapshot)
    [stationManagement,outputValues,simValues] = updateKPILTE(activeIDsTXLTE,indexInActiveIDsOnlyLTE,awarenessID_LTE,neighborsID_LTE,timeManagement,stationManagement,positionManagement,sinrManagement,outputValues,outParams,simParams,appParams,phyParams,simValues);

end 

Nreassign = 0;
if simParams.BRAlgorithm==18
    % BRs reassignment (3GPP MODE 4)
    [timeManagement,stationManagement,sinrManagement,Nreassign] = ...
        BRreassignment3GPPmode4(timeManagement,stationManagement,sinrManagement,simParams,phyParams,appParams,outParams);
        % Code for possible DEBUG
        % figure(400)
        % plot(timeManagement.timeNow*ones(1,length(stationManagement.BRid)),stationManagement.BRid,'*');
        % hold on
        % figure(500)
        % plot(stationManagement.activeIDsLTE,stationManagement.BRid,'*');
        % hold on

elseif mod(timeManagement.elapsedTime_subframes,appParams.NbeaconsT)==0
    % All other algorithms except standard Mode 4
    % TODO not checked in version 5.X
    
    %% Radio Resources Reassignment
    if simParams.BRAlgorithm==2 || simParams.BRAlgorithm==7 || simParams.BRAlgorithm==10
        
        if timeManagement.elapsedTime_subframes > 0
            % Current scheduled reassign period
            reassignPeriod = mod(round(timeManagement.elapsedTime_subframes/(appParams.NbeaconsT))-1,stationManagement.NScheduledReassignLTE)+1;

            % Find IDs of vehicles whose resource will be reassigned
            scheduledID = stationManagement.activeIDsLTE(stationManagement.scheduledReassignLTE(stationManagement.activeIDsLTE)==reassignPeriod);
        else
            % For the first allocation, all vehicles in the scenario
            % need to be scheduled
            scheduledID = stationManagement.activeIDsLTE;
        end
    end

    if simParams.BRAlgorithm==2

        % BRs reassignment (CONTROLLED with REUSE DISTANCE and scheduled vehicles)
        % Call function for BRs reassignment
        % Returns updated stationManagement.BRid vector and number of successful reassignments
        [stationManagement.BRid,Nreassign] = BRreassignmentControlled(stationManagement.activeIDsLTE,scheduledID,positionManagement.distanceEstimated,stationManagement.BRid,appParams.Nbeacons,phyParams.Rreuse);

    elseif simParams.BRAlgorithm==7

        % BRs reassignment (CONTROLLED with MAXIMUM REUSE DISTANCE)
        [stationManagement.BRid,Nreassign] = BRreassignmentControlledMaxReuse(stationManagement.activeIDsLTE,stationManagement.BRid,scheduledID,stationManagement.allNeighborsID,appParams.NbeaconsT,appParams.NbeaconsF);

    elseif simParams.BRAlgorithm==9

        if mod(timeManagement.elapsedTime_subframes-appParams.NbeaconsT,simParams.Treassign)==0
            % BRs reassignment (CONTROLLED with POWER CONTROL)
            [stationManagement.BRid,phyParams.P_ERP_MHz_LTE,stationManagement.lambdaLTE,Nreassign] = BRreassignmentControlledPC(stationManagement.activeIDsLTE,stationManagement.BRid,phyParams.P_ERP_MHz_LTE,sinrManagement.CHgain,awarenessID_LTE,appParams.Nbeacons,stationManagement.lambdaLTE,phyParams.sinrThresholdLTE,phyParams.Pnoise_MHz,simParams.blockTarget,phyParams.maxERP_MHz);
        else
            Nreassign = 0;
        end

    elseif simParams.BRAlgorithm==10

        % BRs reassignment (CONTROLLED with MINIMUM POWER REUSE)
        [stationManagement.BRid,Nreassign] = BRreassignmentControlledMinPowerReuse(stationManagement.activeIDsLTE,stationManagement.BRid,scheduledID,sinrManagement.RXpower,sinrManagement.Shadowing_dB,simParams.knownShadowing,appParams.NbeaconsT,appParams.NbeaconsF);

    elseif simParams.BRAlgorithm==101  || (simParams.BRAlgorithm==9 && timeManagement.elapsedTime_subframes == 0) || (simParams.BRAlgorithm==10 && timeManagement.elapsedTime_subframes == 0)

        % Call Benchmark Algorithm 101 (RANDOM ALLOCATION)
        [stationManagement.BRid,Nreassign] = BRreassignmentRandom(stationManagement.activeIDsLTE,stationManagement.BRid,appParams.Nbeacons,simParams,appParams);

    elseif simParams.BRAlgorithm==102

        % Call Benchmark Algorithm 102 (ORDERED ALLOCATION)
        [stationManagement.BRid,Nreassign] = BRreassignmentOrdered(positionManagement.XvehicleReal,stationManagement.activeIDsLTE,stationManagement.BRid,appParams.NbeaconsT,appParams.NbeaconsF);

    end

end

if ~isempty(sinrManagement.sensedPowerByLteNo11p)
    sinrManagement.sensedPowerByLteNo11p = [];
end

% Incremental sum of successfully reassigned and unlocked vehicles
outputValues.NreassignLTE = outputValues.NreassignLTE + Nreassign;

% Update KPIs for blocked vehicles
blockedIndex = find(stationManagement.BRid(stationManagement.transmittingIDsLTE)==-1);
Nblocked = length(blockedIndex);
for iBlocked = 1:Nblocked
    for iPhyRaw=1:length(phyParams.Raw)
        % Count as a blocked transmission (previous packet is discarded)
        outputValues.NblockedLTE(iPhyRaw) = outputValues.NblockedLTE(iPhyRaw) + nnz(positionManagement.distanceReal(blockedIndex,:)<phyParams.Raw(iPhyRaw));
        outputValues.NblockedTOT(iPhyRaw) = outputValues.NblockedTOT(iPhyRaw) + nnz(positionManagement.distanceReal(blockedIndex,:)<phyParams.Raw(iPhyRaw));
    end
    if outParams.printPacketReceptionRatio
        for iRaw = 1:1:floor(phyParams.RawMaxLTE/outParams.prrResolution)
            distance = iRaw * outParams.prrResolution;
            outputValues.distanceDetailsCounterLTE(iRaw,4) = outputValues.distanceDetailsCounterLTE(iRaw,4) + nnz(positionManagement.distanceReal(blockedIndex,:)<distance);
        end
    end
end
