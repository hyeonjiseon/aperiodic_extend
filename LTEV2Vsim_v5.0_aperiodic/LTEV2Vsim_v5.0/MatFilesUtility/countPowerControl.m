function powerControlCounter = countPowerControl(IDvehicleTX,P_ERP_MHz_dBm,powerControlCounter,powerResolution)
% Function to compute the power control allocation at each transmission
% Returns the updated powerControlCounter

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

% Number of vehicles transmitting at the current time
Ntx = length(IDvehicleTX);

% Convert power to powerControlCounter vector
P_ERP_MHz_dBm = round(P_ERP_MHz_dBm/powerResolution)+101;
maxPtx = length(powerControlCounter);

for i = 1:Ntx
    if P_ERP_MHz_dBm(IDvehicleTX(i))>=maxPtx
        powerControlCounter(end) = powerControlCounter(end) + 1;
    elseif P_ERP_MHz_dBm(IDvehicleTX(i))<=1
        powerControlCounter(1) = powerControlCounter(1) + 1;
    else
        powerControlCounter(P_ERP_MHz_dBm(IDvehicleTX(i))) = powerControlCounter(P_ERP_MHz_dBm(IDvehicleTX(i))) + 1;
    end  
end

end
