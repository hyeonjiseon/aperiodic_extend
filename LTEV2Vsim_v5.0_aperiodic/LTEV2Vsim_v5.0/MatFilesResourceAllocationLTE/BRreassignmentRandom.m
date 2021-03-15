function [BRid, Nreassign] = BRreassignmentRandom(IDvehicle,BRid,Nbeacons,simParams,appParams)
% Benchmark Algorithm 101 (RANDOM ALLOCATION)

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

Nvehicles = length(IDvehicle(:,1));   % Number of vehicles      

% Assign a random beacon resource to vehicles
BRid(IDvehicle) = randi(Nbeacons,Nvehicles,1);

Nreassign = Nvehicles;

end