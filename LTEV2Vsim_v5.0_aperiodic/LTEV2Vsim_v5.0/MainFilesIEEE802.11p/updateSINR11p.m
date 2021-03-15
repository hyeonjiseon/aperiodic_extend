function sinrManagement = updateSINR11p(timeManagement,sinrManagement,stationManagement,phyParams)
% The average SINR is updated

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

% The average SINR is updatedUpdate as the weighted average
% between (i) the SINR calculated from 'instantThisSINRavStarted'
% and 'instantThisPrStarted', presently saved in 'sinrAverage'
% and (ii) the SINR calculated since the last Pr calculation,
% i.e., from 'instantThisPrStarted', to now
% The useful power is calculated as the power received from the
% node stored in 'idFromWhichRx'
% The interfering power is calculated as the overall power
% received from the nodes with State==3 minus the useful power

for idVehicle = stationManagement.activeIDs(stationManagement.vehicleState(stationManagement.activeIDs)==9)'
    if sinrManagement.idFromWhichRx11p(idVehicle)==idVehicle
        sinrManagement.sinrAverage11p(idVehicle) = 0;
    else        
        sinrLast = sinrManagement.rxPowerUsefulLast11p(idVehicle) / ...
            (phyParams.Pnoise_MHz * phyParams.BwMHz + ...
            sinrManagement.rxPowerInterfLast11p(idVehicle));
        if sinrLast<0
            error('sinrLast of vehicle=%d (state=%d), receiving from=%d (state=%d) < 0',idVehicle,stationManagement.vehicleState(idVehicle),...
                sinrManagement.idFromWhichRx11p(idVehicle),stationManagement.vehicleState(sinrManagement.idFromWhichRx11p(idVehicle)));
        end
        sinrManagement.sinrAverage11p(idVehicle) = ...
            (sinrManagement.sinrAverage11p(idVehicle) .* (sinrManagement.instantThisSINRstarted11p(idVehicle)-sinrManagement.instantThisSINRavStarted11p(idVehicle)) + ...
               sinrLast .* (timeManagement.timeNow-sinrManagement.instantThisSINRstarted11p(idVehicle))) ...
            ./ (timeManagement.timeNow-sinrManagement.instantThisSINRavStarted11p(idVehicle));
        sinrManagement.instantThisSINRstarted11p(idVehicle) = timeManagement.timeNow;
    end
end            