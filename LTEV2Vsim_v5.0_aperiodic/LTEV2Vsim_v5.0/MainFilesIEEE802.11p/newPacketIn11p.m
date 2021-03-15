function [timeManagement,stationManagement,outputValues] = newPacketIn11p(timeEvent,idEvent,indexEvent,outParams,simParams,positionManagement,phyParams,timeManagement,stationManagement,sinrManagement,outputValues,appParams)
% A new packet is generated in IEEE 802.11p

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

% The queue is updated
% If one packet is already enqueued, the old packet is removed, the
% number of errors is updated, and the number of packets discarded
% is increased by one
stationManagement.nPackets(idEvent) = stationManagement.nPackets(idEvent)+1;

% Part dealing with the channel busy ratio
%if ~isempty(stationManagement.channelSensedBusyMatrix11p)
if outParams.printCBR
    [timeManagement,stationManagement] = cbrUpdate11p(timeManagement,idEvent,stationManagement,simParams,outParams);
end
%

% Part dealing with new packets introduced in a non-empty queue
if stationManagement.nPackets(idEvent)>1
    % Count as a blocked transmission (previous packet is discarded)
    % Condsider only 11p
    if ~simParams.neighborsSelection
        allNeighbors = (stationManagement.activeIDs11p~=idEvent);
    else
        indexEvent11p = (stationManagement.activeIDs11p == stationManagement.activeIDs(indexEvent));
        allNeighbors = ismember(stationManagement.activeIDs11p,stationManagement.neighborsID11p(indexEvent11p,:));
    end
    distance11pFromTx = positionManagement.distanceReal(stationManagement.vehicleState(stationManagement.activeIDs)~=100,indexEvent);
    % remove self (or non "selected", if "neighborsSelection" is active)
    distance11pFromTx = distance11pFromTx(allNeighbors);
    % count 
    for iPhyRaw = 1:length(phyParams.Raw)
        outputValues.Nblocked11p(iPhyRaw) = outputValues.Nblocked11p(iPhyRaw) + nnz(distance11pFromTx<phyParams.Raw(iPhyRaw));
        outputValues.NblockedTOT(iPhyRaw) = outputValues.NblockedTOT(iPhyRaw) + nnz(distance11pFromTx<phyParams.Raw(iPhyRaw));
    end
    if outParams.printPacketReceptionRatio
        if simParams.technology==1 % only LTE
            error('Not expected to arrive here...');
            %outputValues.distanceDetailsCounterLTE(iRaw,4) = outputValues.distanceDetailsCounterLTE(iRaw,4) + nnz(positionManagement.distanceReal(:,indexEvent)<iRaw);
        else
            if simParams.technology == 2 && appParams.variableBeaconSize % if ONLY 11p
                % If variable beacon size is selected, find if small or large packet is
                % currently transmitted (1 stays for large, 0 for small)
                error('This feature has not been tested in this version of the simulator.');
                %stationManagement.ifBeaconLarge = (mod(stationManagement.variableBeaconSizePeriodicity(indexEvent)+floor(timeManagement.timeNow/appParams.Tbeacon),appParams.NbeaconsSmall+1))==0;
            else
                % Always large
                stationManagement.ifBeaconLarge = 1;
            end
            
            if stationManagement.ifBeaconLarge
                for iRaw = 1:floor(phyParams.RawMax11p/outParams.prrResolution)
                    outputValues.distanceDetailsCounter11p(iRaw,4) = outputValues.distanceDetailsCounter11p(iRaw,4) + nnz(distance11pFromTx<(iRaw*outParams.prrResolution));
                end
            else
                for iRaw = 1:floor(phyParams.RawMax11p/outParams.prrResolution)
                    outputValues.distanceDetailsCounter11p(iRaw,8) = outputValues.distanceDetailsCounter11p(iRaw,8) + nnz(distance11pFromTx<(iRaw*outParams.prrResolution));
                end
            end
        end
    end
    stationManagement.nPackets(idEvent) = stationManagement.nPackets(idEvent)-1;
    %fprintf('CAM message discarded\n');
end

% If the node was in IDLE (State==1)
% NOTE: if the channel is sensed busy, the station is in State 9, so there
% is no need to freeze here
if stationManagement.vehicleState(idEvent)==1 % idle
    
    % % DEBUG EVENTS
    % printDebugEvents(timeEvent,'backoff starts',idEvent);

    % Start the backoff (State==2)
    stationManagement.vehicleState(idEvent)=2; % backoff
    % A new random backoff is set and the instant of its conclusion
    % is derived
    [stationManagement.nSlotBackoff11p(idEvent), timeManagement.timeNextTxRx11p(idEvent)] = startNewBackoff11p(timeManagement.timeNow,phyParams.CW,phyParams.tAifs,phyParams.tSlot);    
end
