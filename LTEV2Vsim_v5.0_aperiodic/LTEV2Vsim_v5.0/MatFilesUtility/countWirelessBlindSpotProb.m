function wirelessBlindSpotCounter = countWirelessBlindSpotProb(updateTimeMatrix,wirelessBlindSpotCounter,elapsedTime)
% Function to store delay events for wireless blind spot computation

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

% Build timeDiff matrix
timeDiffMatrix = updateTimeMatrix;
timeDiffMatrix(timeDiffMatrix>0) = elapsedTime-timeDiffMatrix(timeDiffMatrix>0);

% For every time interval (multiples of Tbeacon)
for i = 1:length(wirelessBlindSpotCounter)
    % Count number of delay events larger or equal than time interval
    wirelessBlindSpotCounter(i,2) = wirelessBlindSpotCounter(i,2) + sum(timeDiffMatrix(:)>=wirelessBlindSpotCounter(i,1));
    % Count number of delay events shorter than time interval
    wirelessBlindSpotCounter(i,3) = wirelessBlindSpotCounter(i,3) + sum(timeDiffMatrix(:)>0 & timeDiffMatrix(:)<wirelessBlindSpotCounter(i,1));
end
