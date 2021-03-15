function ITBS = findITBS(MCS)
% This function finds the corresponding Transport Block Size Index (ITBS)
% from 3GPP LTE Tables

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

if MCS<=10 
    ITBS = MCS;
elseif MCS>10 && MCS<=20
    ITBS = MCS-1;
elseif MCS>20 && MCS<=28
    ITBS = MCS-2; 
else 
    error('Invalid MCS');
end

end

    
    
   


