function [dUpdate,S,distanceRealOld] = updateDistance(distanceReal,distanceRealOld,indexOldVehicles,indexOldVehiclesToOld,Shadowing_dB,stdDevShadowLOS_dB)
% This function calculates the difference of the distance between two
% vehicles w.r.t. the previous instant and it updates the
% shadowing matrix removing vehicles out of the scenario and ordering
% indices

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

Nvehicles = length(distanceReal(:,1));
dUpdate = zeros(Nvehicles,Nvehicles);
S = randn(Nvehicles,Nvehicles)*stdDevShadowLOS_dB;

% Update distance matrix
dUpdate(indexOldVehicles,indexOldVehicles) = abs(distanceReal(indexOldVehicles,indexOldVehicles)-distanceRealOld(indexOldVehiclesToOld,indexOldVehiclesToOld));

% Update shadowing matrix 
S(indexOldVehicles,indexOldVehicles) = Shadowing_dB(indexOldVehiclesToOld,indexOldVehiclesToOld);

% Update distanceRealOld for next snapshot
distanceRealOld = distanceReal;

end

