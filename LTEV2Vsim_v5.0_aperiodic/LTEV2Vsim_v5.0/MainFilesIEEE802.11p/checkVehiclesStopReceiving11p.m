function [timeManagement,stationManagement,sinrManagement] = checkVehiclesStopReceiving11p(timeManagement,stationManagement,sinrManagement,simParams,phyParams)
% The nodes that may stop receiving must be checked

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

% Variable used for easier reading
activeIDs = stationManagement.activeIDs;

% Firstly, those nodes that were receiving from this node should change the
% receiving node to own, and then possibly stop receiving
% They are those that:
% 1) are currently receiving
% 2) do not have the 'idFromWhichRx' currently transmitting
ifReceivingFromThis = logical( (stationManagement.vehicleState(activeIDs)==9) .* ...
    (stationManagement.vehicleState(sinrManagement.idFromWhichRx11p(activeIDs))~=3) );

sinrManagement.idFromWhichRx11p(activeIDs(ifReceivingFromThis)) = activeIDs(ifReceivingFromThis);
% Then, those that also sense the medium as idle will exit from state 9
% 3) sense a total power below the threshold

rxPowerTotNow = (sinrManagement.P_RX_MHz*phyParams.BwMHz) * (stationManagement.vehicleState(activeIDs)==3);
ifStopReceiving = ifReceivingFromThis .* (rxPowerTotNow < phyParams.PrxSensNotSynch);
% Focusing on those that stop receiving
% The 'idFromWhichRx' is reset to the own id
% State is set to either 0 or 1 depending on whether the queue
% is empty or not
% If the queue is not empty, the backoff is started; if
% 'nSlotBackoff' contains a '-1', it means that a new backoff
% should be started; otherwise, it was freezed and should be
% resumed
stationManagement.vehicleState(activeIDs((logical(ifStopReceiving .* (stationManagement.nPackets(activeIDs)==0))))) = 1;
stationManagement.vehicleState(activeIDs((logical(ifStopReceiving .* (stationManagement.nPackets(activeIDs)>0))))) = 2;
idVehicleVector=activeIDs(logical(ifStopReceiving .* (stationManagement.nPackets(activeIDs)>0)));
for iVehicle = idVehicleVector'
    if stationManagement.nSlotBackoff11p(iVehicle)==-1
        [stationManagement.nSlotBackoff11p(iVehicle), timeManagement.timeNextTxRx11p(iVehicle)] = startNewBackoff11p(timeManagement.timeNow,phyParams.CW,phyParams.tAifs,phyParams.tSlot);
        % DEBUG BACKOFF
        %printDebugBackoff11p(timeManagement.timeNow,'11p backoff start',iVehicle,stationManagement)
    else
        timeManagement.timeNextTxRx11p(iVehicle) = resumeBackoff11p(timeManagement.timeNow,stationManagement.nSlotBackoff11p(iVehicle),phyParams.tAifs,phyParams.tSlot);
        % DEBUG BACKOFF
        %printDebugBackoff11p(timeManagement.timeNow,'11p backoff resume',iVehicle,stationManagement)
    end
end
% The channel busy ratio should be updated 
if ~isempty(stationManagement.channelSensedBusyMatrix11p)
    stationManagement.channelSensedBusyMatrix11p(1,activeIDs(logical(ifStopReceiving))) = stationManagement.channelSensedBusyMatrix11p(1,activeIDs(logical(ifStopReceiving))) + (timeManagement.timeNow-timeManagement.cbr11p_timeStartBusy(activeIDs(logical(ifStopReceiving)))');
    timeManagement.cbr11p_timeStartBusy(activeIDs(logical(ifStopReceiving))) = -1;
end



