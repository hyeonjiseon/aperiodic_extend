function [Xvehicle, Yvehicle] = addPosError(XvehicleReal,YvehicleReal,sigma)
% Add positioning error based on the Gaussian model

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

Nvehicles = length(XvehicleReal(:,1));
error = sigma.*randn(Nvehicles,1);               % Generate error samples
angle = 2*pi.*rand(Nvehicles,1);                 % Generate random angles

Xvehicle = (XvehicleReal + error.*cos(angle));
Yvehicle = (YvehicleReal + error.*sin(angle));

end