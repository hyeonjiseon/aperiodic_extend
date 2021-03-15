function [timeManagement,stationManagement,sinrManagement] = updateVehicleEndingTx11p(idEvent,indexEvent,timeManagement,stationManagement,sinrManagement,phyParams)
% A transmission is concluded in IEEE 802.11p

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

% If the vehicle is exiting the scenario, indexEvent is set to -1
% thus shouldn't call this function
if indexEvent<=0
    error('Call to updateVehicleEndingTx11p with indexEvent<=0');
end

% The number of packets in the queue is reduced
stationManagement.nPackets(idEvent) = stationManagement.nPackets(idEvent)-1;
% The medium is sensed to check if it is free
% (note: 'vState(idEvent)' is set to 9 in order not to contribute
% to the sensed power)
stationManagement.vehicleState(idEvent)=9; % rx
if ((stationManagement.vehicleState(stationManagement.activeIDs)==3) * sinrManagement.P_RX_MHz(indexEvent,:)) > (phyParams.PrxSensNotSynch/phyParams.BwMHz)
    % If it is busy, State 9 with error is entered
    stationManagement.vehicleState(idEvent)=9; % rx
    sinrManagement.idFromWhichRx11p(idEvent) = idEvent;
    sinrManagement.sinrAverage11p(idEvent) = 0;
    sinrManagement.instantThisSINRavStarted11p(idEvent) = timeManagement.timeNow;
    timeManagement.timeNextTxRx11p(idEvent) = Inf;
else
    % If it is free, then: the idle state is entered if the queue is empty
    % otherwise a new backoff is started
    if stationManagement.nPackets(idEvent)==0
        % If no other packets are in the queue, the node goes
        % in idle state
        stationManagement.vehicleState(idEvent)=1; % idle
        timeManagement.timeNextTxRx11p(idEvent) = Inf;
    elseif stationManagement.nPackets(idEvent)>=1
        % If there are other packets in the queue, a new
        % backoff is initialized and started
        stationManagement.vehicleState(idEvent)=2; % backoff
        [stationManagement.nSlotBackoff11p(idEvent), timeManagement.timeNextTxRx11p(idEvent)] = startNewBackoff11p(timeManagement.timeNow,phyParams.CW,phyParams.tAifs,phyParams.tSlot);
    else
        error('Error: nPackets<0');
    end
    % In both cases, the channel busy ratio is updated 
    if ~isempty(stationManagement.channelSensedBusyMatrix11p)
        stationManagement.channelSensedBusyMatrix11p(1,idEvent) = stationManagement.channelSensedBusyMatrix11p(1,idEvent) + (timeManagement.timeNow-timeManagement.cbr11p_timeStartBusy(idEvent));
        timeManagement.cbr11p_timeStartBusy(idEvent) = -1;
    end
end

