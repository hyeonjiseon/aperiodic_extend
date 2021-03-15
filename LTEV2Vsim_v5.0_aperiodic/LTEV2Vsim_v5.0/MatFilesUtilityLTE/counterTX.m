function matrix = counterTX(IDvehicleTX,indexVehicleTX,awarenessID,errorMatrix)
% Count correctly transmitted beacons among neighbors within Raw
% Matrix = [#Correctly transmitted beacons, #Errors, #Neighbors]

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

Ntx = length(indexVehicleTX);
matrix = zeros(Ntx,3);
for i = 1:Ntx

    % #Neighbors of TX vehicle IDvehicleTX(i)
    Nneighbors = nnz(awarenessID(indexVehicleTX(i),:));
    matrix(i,3) = Nneighbors;

    % #Neighbors that do not have correctly received the beacon
    Nerrors = nnz(errorMatrix(:,1)==IDvehicleTX(i));
    matrix(i,2) = Nerrors;

    % #Neighbors that have correctly received the beacon transmitted by IDvehicleTX(i)
    matrix(i,1) = Nneighbors - Nerrors;

end

