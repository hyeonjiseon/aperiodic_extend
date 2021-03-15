function [Xvehicle,Yvehicle,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,IDvehicleExit] = updatePosition(Xvehicle,Yvehicle,IDvehicle,v,direction,updateInterval,Xmax)
% Update vehicles position (when not using File Trace)
% (if a vehicle moves outside the scenario, enters by the other side)

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

Xvehicle = (~direction).*mod(Xvehicle + v*updateInterval,Xmax) + direction.*mod(Xvehicle - v*updateInterval,Xmax);

% Return indices
indexNewVehicles = [];
indexOldVehicles = IDvehicle;
indexOldVehiclesToOld = IDvehicle;
IDvehicleExit = [];

end