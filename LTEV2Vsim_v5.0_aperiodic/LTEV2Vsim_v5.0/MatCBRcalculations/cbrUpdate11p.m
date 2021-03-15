function [timeManagement,stationManagement,CBRvalue] = cbrUpdate11p(timeManagement,idEvent,stationManagement,simParams,outParams)

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

CBRvalue = 0;

if timeManagement.cbr11p_timeStartMeasInterval(idEvent) <= 0
    timeManagement.cbr11p_timeStartMeasInterval(idEvent) = timeManagement.timeNow;
    if timeManagement.cbr11p_timeStartBusy(idEvent)~=-1
        timeManagement.cbr11p_timeStartBusy(idEvent) = timeManagement.timeNow;
    end
    return
end

% Update last CBR
if timeManagement.cbr11p_timeStartBusy(idEvent)~=-1
    stationManagement.channelSensedBusyMatrix11p(1,idEvent) = stationManagement.channelSensedBusyMatrix11p(1,idEvent) + (timeManagement.timeNow-timeManagement.cbr11p_timeStartBusy(idEvent));
    timeManagement.cbr11p_timeStartBusy(idEvent) = timeManagement.timeNow;
end               

% Calculate the new CBR
stationManagement.channelSensedBusyMatrix11p(1,idEvent) = stationManagement.channelSensedBusyMatrix11p(1,idEvent)/(timeManagement.timeNow-timeManagement.cbr11p_timeStartMeasInterval(idEvent));
timeManagement.cbr11p_timeStartMeasInterval(idEvent) = timeManagement.timeNow;
% Average out 
CBRvalue = sum(stationManagement.channelSensedBusyMatrix11p(:,idEvent))/(nnz(stationManagement.channelSensedBusyMatrix11p(:,idEvent)));
%print - only if print is active - only 11p
if outParams.printCBR && timeManagement.timeNow>simParams.cbrSensingInterval && stationManagement.vehicleState(idEvent)~=100    
    printCBRToFile(CBRvalue,outParams,false);
end

% Shift of the matrix
stationManagement.channelSensedBusyMatrix11p(:,idEvent) = circshift(stationManagement.channelSensedBusyMatrix11p(:,idEvent),1);
stationManagement.channelSensedBusyMatrix11p(1,idEvent) = 0;