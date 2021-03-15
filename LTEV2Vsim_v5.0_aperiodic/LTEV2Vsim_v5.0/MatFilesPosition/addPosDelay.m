function [Xvehicle,Yvehicle,PosUpdateIndex] = addPosDelay(Xvehicle,Yvehicle,XvehicleReal,YvehicleReal,IDvehicle,indexNewVehicles,...
    indexOldVehicles,indexOldVehiclesToOld,posUpdateAllVehicles,PosUpdatePeriod)
% Update positions of vehicles in the current positioning update period
% (PosUpdatePeriod)

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

% Initialize temporary Xvehicle and Yvehicle
Nvehicles = length(IDvehicle);
XvehicleTemp = zeros(Nvehicles,1);
YvehicleTemp = zeros(Nvehicles,1);

% Position of new vehicles in the scenario immediately updated
XvehicleTemp(indexNewVehicles) = XvehicleReal(indexNewVehicles);
YvehicleTemp(indexNewVehicles) = YvehicleReal(indexNewVehicles);

% Copy old coordinates to temporary Xvehicle and Yvehicle
XvehicleTemp(indexOldVehicles) = Xvehicle(indexOldVehiclesToOld);
YvehicleTemp(indexOldVehicles) = Yvehicle(indexOldVehiclesToOld);
Xvehicle = XvehicleTemp;
Yvehicle = YvehicleTemp;

% Find index of vehicles in the scenario whose position will be updated
PosUpdateIndex = find(posUpdateAllVehicles(IDvehicle)==PosUpdatePeriod);

% Update positions
Xvehicle(PosUpdateIndex) = XvehicleReal(PosUpdateIndex);
Yvehicle(PosUpdateIndex) = YvehicleReal(PosUpdateIndex);

end

