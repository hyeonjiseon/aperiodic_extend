function [simValues,outputValues,timeManagement,stationManagement,sinrManagement] = endOfTransmission11p(idEvent,indexEvent,positionManagement,phyParams,outParams,simParams,simValues,outputValues,timeManagement,stationManagement,sinrManagement,appParams)
% A transmission ends in IEEE 802.11p

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

% The transmitting vehicle is first updated
[timeManagement,stationManagement,sinrManagement] = updateVehicleEndingTx11p(idEvent,indexEvent,timeManagement,stationManagement,sinrManagement,phyParams);

% The average SINR of all vehicles is then updated
sinrManagement = updateSINR11p(timeManagement,sinrManagement,stationManagement,phyParams);

% DEBUG TX
printDebugTx(timeManagement.timeNow,false,idEvent,stationManagement,positionManagement,sinrManagement,outParams,phyParams);            

% Update KPIs
[simValues,outputValues] = updateKPI11p(idEvent,indexEvent,timeManagement,stationManagement,positionManagement,sinrManagement,simParams,phyParams,outParams,simValues,outputValues);

% The nodes that may stop receiving must be checked
[timeManagement,stationManagement,sinrManagement] = checkVehiclesStopReceiving11p(timeManagement,stationManagement,sinrManagement,simParams,phyParams);

% The present overall/useful power received and the instant of calculation are updated
% The power received must be calculated after
% 'checkVehiclesStopReceiving11p', to have the correct idFromWhichtransmitting
[sinrManagement] = updateLastPower11p(timeManagement,stationManagement,sinrManagement,phyParams,simValues);
