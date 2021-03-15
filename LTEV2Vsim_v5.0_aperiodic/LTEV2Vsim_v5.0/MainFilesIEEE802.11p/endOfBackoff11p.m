function [timeManagement,stationManagement,sinrManagement] = endOfBackoff11p(idEvent,indexEvent,simParams,simValues,phyParams,timeManagement,stationManagement,sinrManagement,appParams)
% A backoff ends and the corresponding transmission starts

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

% A transmission starts:
% - The backoff counter is reset
% - The end of the transmission is set
stationManagement.vehicleState(idEvent) = 3; % tx
stationManagement.nSlotBackoff11p(idEvent) = -1;

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
    % If the vehicle transmits a large packet
    timeManagement.timeNextTxRx11p(idEvent) = timeManagement.timeNow + phyParams.tPck11p;
else
    % if only 11p and variable beacons
    % If the vehicle transmits a small packet
    timeManagement.timeNextTxRx11p(idEvent) = timeManagement.timeNow + phyParams.tPck11pSmall;
end

% The average SINR is updated
sinrManagement = updateSINR11p(timeManagement,sinrManagement,stationManagement,phyParams);

% Check the nodes that start receiving
[timeManagement,stationManagement,sinrManagement] = checkVehiclesStartReceiving11p(idEvent,indexEvent,timeManagement,stationManagement,sinrManagement,simParams,phyParams);

% The present overall/useful power received and the instant of calculation are updated
% The power received must be calculated after
% 'checkVehiclesStartReceiving11p', to have the correct idFromWhichtransmitting
[sinrManagement] = updateLastPower11p(timeManagement,stationManagement,sinrManagement,phyParams,simValues);

