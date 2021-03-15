function sinrManagement = updateSINRLTE(timeNow,stationManagement,sinrManagement,Pnoise,simParams,appParams)
% Calculates the average SINR to each receiving neighbor

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

transmittingIDsLTE = stationManagement.transmittingIDsLTE;

% Given:
% sinrManagement.neighPowerUsefulLastLTE
% sinrManagement.neighPowerInterfLastLTE
% sinrManagement.neighborsSINRaverageLTE
% sinrManagement.instantThisPstartedLTE
% sinrManagement.instantTheSINRaverageStartedLTE

% % This part was without interference from IEEE 802.11p
% Without 11p interference
% sinrLast = sinrManagement.neighPowerUsefulLastLTE ./ ( Pnoise + sinrManagement.neighPowerInterfLastLTE);
% 
% neighborsSINRaverageLTE = (sinrManagement.neighborsSINRaverageLTE .* (sinrManagement.instantThisPstartedLTE-sinrManagement.instantTheSINRaverageStartedLTE) + ... 
%     sinrLast .* (timeNow-sinrManagement.instantThisPstartedLTE)) ./ (timeNow-sinrManagement.instantTheSINRaverageStartedLTE);
% %

% % This is the new version to include interference form IEEE 802.11p nodes
% TODO: is it possible to optimize?
if ~isempty(transmittingIDsLTE)
    sinrLast = zeros(length(transmittingIDsLTE),length(sinrManagement.neighPowerUsefulLastLTE(1,:)));
    sinrSciLast = zeros(length(transmittingIDsLTE),length(sinrManagement.neighPowerUsefulLastLTE(1,:)));
    for iLTEtx = 1:length(transmittingIDsLTE)
        for iInterf = 1:length(stationManagement.neighborsIDLTE(1,:))     

            if stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(iLTEtx),iInterf)>0
                % Data
                sinrLast(iLTEtx,iInterf) = sinrManagement.neighPowerUsefulLastLTE(iLTEtx,iInterf) ./ ( Pnoise + sinrManagement.neighPowerInterfLastLTE(iLTEtx,iInterf) );
                % SCI - 11p interference must be scaled down
                sinrSciLast(iLTEtx,iInterf) = sinrManagement.neighPowerUsefulLastLTE(iLTEtx,iInterf) ./ ( Pnoise + sinrManagement.neighPowerInterfLastLTE(iLTEtx,iInterf));
            end
        end
    end

    sinrManagement.neighborsSINRaverageLTE = (sinrManagement.neighborsSINRaverageLTE .* (sinrManagement.instantThisPstartedLTE-sinrManagement.instantTheSINRaverageStartedLTE) + ... 
        sinrLast .* (timeNow-sinrManagement.instantThisPstartedLTE)) ./ (timeNow-sinrManagement.instantTheSINRaverageStartedLTE);    

    sinrManagement.neighborsSINRsciAverageLTE = (sinrManagement.neighborsSINRsciAverageLTE .* (sinrManagement.instantThisPstartedLTE-sinrManagement.instantTheSINRaverageStartedLTE) + ... 
        sinrSciLast .* (timeNow-sinrManagement.instantThisPstartedLTE)) ./ (timeNow-sinrManagement.instantTheSINRaverageStartedLTE);        
else
    sinrManagement.neighborsSINRaverageLTE = [];
    sinrManagement.neighborsSINRsciAverageLTE = [];
end

sinrManagement.instantThisPstartedLTE = timeNow;
