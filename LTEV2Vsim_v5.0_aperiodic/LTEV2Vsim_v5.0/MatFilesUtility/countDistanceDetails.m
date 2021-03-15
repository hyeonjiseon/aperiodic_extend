function distanceDetailsCounter = countDistanceDetails(indexVehicleTX,neighborsID,neighborsDistance,errorMatrix,distanceDetailsCounter,outParams)
% Count events for distances up to the maximum awareness range (removing border effect)
% [distance, #Correctly received beacons, #Errors, #Blocked neighbors, #Neighbors]
% #Neighbors will be calculated in "printDistanceDetailsCounter.m" (only one call)

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

% Update array with the events vs. distance
for i = 1:1:length(distanceDetailsCounter(:,1))
    
    distance = i * outParams.prrResolution;
    
    % Number of receiving neighbors at i meters
    NrxNeighbors = nnz((neighborsID(indexVehicleTX,:)>0).*(neighborsDistance(indexVehicleTX,:) < distance));
    
    % #Errors within i meters
    Nerrors = nnz(errorMatrix(:,4) < distance);
    distanceDetailsCounter(i,3) = distanceDetailsCounter(i,3) + Nerrors;
    
    % #Correctly received beacons within i meters
    NrxOK = NrxNeighbors - Nerrors;
    distanceDetailsCounter(i,2) = distanceDetailsCounter(i,2) + NrxOK;
    
end

end
