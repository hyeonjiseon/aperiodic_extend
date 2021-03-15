function [timeManagement,stationManagement,sinrManagement] = cbrUpdateLTE(timeManagement,inTheLastSubframe,stationManagement,sinrManagement,appParams,simParams,phyParams,outParams)

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

% ETSI TS 103 574 V1.1.1 (2018-11)
% 5.2 Calculation of CBR [...]
% For PSSCH, CBR is the fraction of "sub-channels" whose S-RSSI exceeds a threshold -94 dBm.
% Note: sensingMatrix is per-RB
% The threshold needs to be converted from sub-channel to RB
threshCBR = 10^((-94-30)/10); % fixed in this version
threshCBR_PerRB = threshCBR/phyParams.sizeSubchannel;

sensingMatrix = stationManagement.sensingMatrixLTE;
nBeaconPeriodsCBR = min(ceil(simParams.cbrSensingInterval/appParams.averageTbeacon),length(sensingMatrix(:,1,1)));

vehiclesToConsider = stationManagement.activeIDsLTE(logical(inTheLastSubframe(stationManagement.activeIDsLTE)));

if ~isempty(vehiclesToConsider) && timeManagement.elapsedTime_subframes > nBeaconPeriodsCBR * appParams.NbeaconsT
    if outParams.printCBR
        cbrToPrint = zeros(1,length(vehiclesToConsider));
        index = 1;
    end
    for iV = vehiclesToConsider'
        % sensingMatrix(-,-,-)>T returns a matrix (recall: comparisons
        % are considering the power per resource block)
        % then reshape converts into a vector and sum sums up
        sinrManagement.cbrLTE(iV) = sum(reshape(sensingMatrix(1:nBeaconPeriodsCBR,:,iV) > threshCBR_PerRB, [], 1)) / (nBeaconPeriodsCBR * appParams.NbeaconsT * appParams.NbeaconsF);
        if outParams.printCBR
            cbrToPrint(index) = sinrManagement.cbrLTE(iV);            
            index = index + 1;
        end
    end
    if outParams.printCBR
        printCBRToFile(cbrToPrint,outParams,false);
    end
end
