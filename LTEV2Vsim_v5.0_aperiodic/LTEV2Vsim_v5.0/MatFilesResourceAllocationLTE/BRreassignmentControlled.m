function [BRid, Nreassign] = BRreassignmentControlled(IDvehicle,scheduledID,distance,BRid,Nbeacons,Rreuse)
% [CONTROLLED CASE with Rreuse and scheduled vehicles]
% Reassign BRs first to blocked vehicles, then to scheduledID vehicles

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

% NOTE: this algorithm is not optimized with IBE
% (it could be improved with the same approach as BR Algorithm 7)

% Find blocked vehicles
blockedID = find(BRid==-1);
blockedIndex = find(BRid(IDvehicle)==-1);
Nb = length(blockedIndex);

% Assign resources to blocked vehicles
if Nb~=0
    p1 = randperm(Nb);                 % Generate random permutation vector
    % Assign BRs to blocked vehicles
    for i = 1:Nb
        z = p1(i);
        ID = IDvehicle(blockedIndex(z,1));
        p2 = randperm(Nbeacons);       % Generate random permutation vector
        for j = 1:Nbeacons             % Check all possible BRs
            BR = p2(j);
            found = 0;  % Becomes 1 if there is a vehicle using that BR within reuse distance
            intIndex = find(BRid(IDvehicle)==BR);
            for k = 1:length(intIndex)
                if distance(blockedIndex(z,1),intIndex(k))<Rreuse
                    found = 1;
                    break
                end
            end
            if found
                BRid(ID) = -1;  % BR not available (blocked)
            else
                BRid(ID) = BR;  % Assign BR
                break
            end
        end
    end
end

% Number of scheduled vehicles
Nscheduled = length(scheduledID);

% Update vector of resources
BRid(scheduledID)=-1;

% Assign resources to scheduled vehicles
p1 = randperm(Nscheduled);             % Generate random permutation vector
% Assign BRs to scheduled vehicles
for i = 1:Nscheduled
    z = p1(i);
    ID = scheduledID(z,1);
    p2 = randperm(Nbeacons);       % Generate random permutation vector
    for j = 1:Nbeacons             % Check all possible BRs
        BR = p2(j);
        found = 0;  % Becomes 1 if there is a vehicle using that BR within reuse distance
        intIndex = find(BRid(IDvehicle)==BR);
        for k = 1:length(intIndex)
            if distance(IDvehicle==ID,intIndex(k))<Rreuse
                found = 1;
                break
            end
        end
        if found
            BRid(ID) = -1;  % BR not available (blocked)
        else
            BRid(ID) = BR;  % Assign BR
            break
        end
    end
end

% Number of resource reassignments
Nreassign = length(unique(vertcat(scheduledID,blockedID)));

end