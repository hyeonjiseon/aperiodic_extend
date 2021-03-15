function  simValues = counterMap(iPhyRaw,simValues,IDvehicle,indexVehicleTX,IDvehicleTX,awarenessID,errorMatrix)
% Function to update matrices needed for PRRmap creation in urban scenarios

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

for i = 1:Ntx
    awarenessIndex = find(awarenessID(indexVehicleTX(i),:)>0);
    for j = 1:length(awarenessIndex)
        % ID and index of receiving vehicle
        IDvehicleRX = awarenessID(indexVehicleTX(i),awarenessIndex(j));
        indexVehicleRX = find(IDvehicle==IDvehicleRX);
        % Count correctly received beacons
        if isempty(find(errorMatrix(:,1)==IDvehicleTX(i) & errorMatrix(:,2)==IDvehicleRX, 1))
            simValues.correctlyReceivedMapLTE(simValues.YmapFloor(indexVehicleRX),simValues.XmapFloor(indexVehicleRX),iPhyRaw) = ...
                simValues.correctlyReceivedMapLTE(simValues.YmapFloor(indexVehicleRX),simValues.XmapFloor(indexVehicleRX),iPhyRaw) + 1;
        end
    end
    % Count neighbors of IDVehicleTX(i)
    NneighborsRaw = length(awarenessIndex);
    simValues.neighborsMapLTE(simValues.YmapFloor(indexVehicleTX(i)),simValues.XmapFloor(indexVehicleTX(i)),iPhyRaw) = ...
        simValues.neighborsMapLTE(simValues.YmapFloor(indexVehicleTX(i)),simValues.XmapFloor(indexVehicleTX(i)),iPhyRaw) + NneighborsRaw;
end

end