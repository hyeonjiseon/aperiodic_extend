function [minRandValue,maxRandValue] = findRandValueMode4(Tbeacon,simParams)
% The min and max values for the random counter are set as in TS 36.321

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

if Tbeacon>=0.1
    minRandValue = 5;
    maxRandValue = 15;
elseif Tbeacon>=0.05
    minRandValue = 10;
    maxRandValue = 30;
else
    minRandValue = 25;
    maxRandValue = 75;
end

if simParams.minRandValueMode4~=-1
    minRandValue = simParams.minRandValueMode4;
end
if simParams.maxRandValueMode4~=-1
    maxRandValue = simParams.maxRandValueMode4;
end
if maxRandValue <= minRandValue 
    error('Error: in 3GPP Mode 4, "maxRandValue" must be larger than "minRandValue"');
end

end