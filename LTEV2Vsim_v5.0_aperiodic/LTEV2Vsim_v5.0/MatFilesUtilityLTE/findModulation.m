function Nbps = findModulation(MCS)
% This function takes the modulation and coding scheme (MCS) as 
% the input parameter and based on table 8-6-1-1 of 3GPP TS 36.213 V14.0.0 
% finds the number of bits per symbol

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
   Nbps = 2;
elseif MCS>=11 && MCS<=20
   Nbps = 4;
elseif MCS>=21 && MCS<=28
   Nbps = 6;
else 
    error('Invalid MCS');
end

end
