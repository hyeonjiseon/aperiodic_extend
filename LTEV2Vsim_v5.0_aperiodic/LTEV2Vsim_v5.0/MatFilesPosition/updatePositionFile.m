function [XvehicleReal,YvehicleReal,IDvehicle,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,IDvehicleExit] = updatePositionFile(time,dataTrace,oldIDvehicle)
% Update position of vehicles from file

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

fileIndex = find(dataTrace(:,1)==time);
IDvehicle = dataTrace(fileIndex,2);
XvehicleReal = dataTrace(fileIndex,3);
YvehicleReal = dataTrace(fileIndex,4);

% Sort IDvehicle, XvehicleReal and YvehicleReal by IDvehicle
[IDvehicle,indexOrder] = sort(IDvehicle);
XvehicleReal = XvehicleReal(indexOrder);
YvehicleReal = YvehicleReal(indexOrder);

[~,indexNewVehicles] = setdiff(IDvehicle,oldIDvehicle,'stable');

% Find IDs of vehicles that are exiting the scenario
IDvehicleExit = setdiff(oldIDvehicle,IDvehicle);

% Find indices of vehicles in IDvehicle that are both in IDvehicle and OldIDvehicle
indexOldVehicles = find(ismember(IDvehicle,oldIDvehicle));

% Find indices of vehicles in OldIDvehicle that are both in IDvehicle and OldIDvehicle
indexOldVehiclesToOld = find(ismember(oldIDvehicle,IDvehicle));

end