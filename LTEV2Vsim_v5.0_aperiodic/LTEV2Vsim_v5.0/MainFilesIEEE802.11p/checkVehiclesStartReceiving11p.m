function [timeManagement,stationManagement,sinrManagement] = checkVehiclesStartReceiving11p(idEvent,indexEventInActiveIDs,timeManagement,stationManagement,sinrManagement,simParams,phyParams)
% The nodes that start receiving are identified
        
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

% They are those that:
% A.  are in idle or in backoff (do not transmit and are not
% already receiving)
% B. do not end the backoff in the next time slot (a 1e-10
% margin is added due to problems with the representation of
% floating point numbers)
% C+D. receive this signal with sufficient quality (= (C) are able to
% decode the preamble, since SINR>SINR_min) OR (D) do not receive the
% signal with sufficient quality, but perceive the channel as
% busy
rxPowerTotNow_MHz = sinrManagement.P_RX_MHz * (stationManagement.vehicleState(activeIDs)==3);
A = ( (stationManagement.vehicleState(activeIDs)==1) + (stationManagement.vehicleState(activeIDs)==2) );
B = (timeManagement.timeNextTxRx11p(activeIDs) >= (timeManagement.timeNow+phyParams.tSlot-1e-10));
if indexEventInActiveIDs>0
    % Normal case
    % The SINR corresponding to PER = 0 is used
    C = sinrManagement.P_RX_MHz(:,indexEventInActiveIDs) ./ (phyParams.Pnoise_MHz + (rxPowerTotNow_MHz-sinrManagement.P_RX_MHz(:,indexEventInActiveIDs))) > phyParams.sinrThreshold11p;
else
    % Only interference, with no real useful signal
    % In this case C is always 'false'
    C = zeros(length(sinrManagement.P_RX_MHz(:,1)),1);
end
D = (rxPowerTotNow_MHz*phyParams.BwMHz) >= phyParams.PrxSensNotSynch;

ifStartReceiving = logical( A .* ...
    B .* ...
    (C+D) );

% Focusing on those that start receiving
% The backoff is freezed if the node was in vState==2
% State is set to 9
% The node from which receiving is set
% SINR is reset and initial instant is set to now
% 'timeNextTxRx' is set to infinity
vehiclesFreezingList=activeIDs(logical(ifStartReceiving.*(stationManagement.vehicleState(activeIDs)==2)));
for idVehicle = vehiclesFreezingList'
    stationManagement.nSlotBackoff11p(idVehicle) = freezeBackoff11p(timeManagement.timeNow,timeManagement.timeNextTxRx11p(idVehicle),phyParams.tSlot,stationManagement.nSlotBackoff11p(idVehicle));
    % DEBUG BACKOFF
    %printDebugBackoff11p(timeManagement.timeNow,'11p backoff freeze',iVehicle,stationManagement)
end
stationManagement.vehicleState(activeIDs(ifStartReceiving)) = 9;
sinrManagement.sinrAverage11p(activeIDs(ifStartReceiving)) = 0;
sinrManagement.instantThisSINRavStarted11p(activeIDs(ifStartReceiving)) = timeManagement.timeNow;
sinrManagement.instantThisSINRstarted11p(activeIDs(ifStartReceiving)) = timeManagement.timeNow;
timeManagement.timeNextTxRx11p(activeIDs(ifStartReceiving)) = Inf;

% The channel busy ratio should be updated 
timeManagement.cbr11p_timeStartBusy(activeIDs(ifStartReceiving)) = timeManagement.timeNow;
if idEvent>0
    timeManagement.cbr11p_timeStartBusy(idEvent) = timeManagement.timeNow;
    sinrManagement.idFromWhichRx11p(activeIDs(ifStartReceiving)) = idEvent;
    %
else
    % if State 9 is due to interference, the idFromWhichRx must be set to
    % 'self'
    sinrManagement.idFromWhichRx11p(activeIDs(ifStartReceiving)) = activeIDs(ifStartReceiving);
end

