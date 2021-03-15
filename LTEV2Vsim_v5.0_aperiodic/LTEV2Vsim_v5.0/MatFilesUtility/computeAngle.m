function angle = computeAngle(XvehicleReal,YvehicleReal,Xold,Yold,angleOld)
% Function to compute the angle of the vehicles trajectory.
% The angle is determined as the angle between the vector 
% [oldPosition newPosition] and the x-axis.

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

xDiff = XvehicleReal-Xold;
yDiff = YvehicleReal-Yold;

% Slope of line connecting old and new coordinates
m = yDiff./xDiff;

% Identify quarters
quarter1 = (xDiff>0).*(yDiff>0);
quarter2 = (xDiff<0).*(yDiff>0);
quarter3 = (xDiff<0).*(yDiff<0);
quarter4 = (xDiff>0).*(yDiff<0);
% Special cases 
zeroRad = (xDiff>0).*(yDiff==0);
halfPiRad =  (xDiff==0).*(yDiff>0);
piRad = (xDiff<0).*(yDiff==0);
threeHalfPiRad =  (xDiff==0).*(yDiff<0);
stillVehicles = (xDiff==0).*(yDiff==0);

m(isnan(m)) = 1;

% Calculate angle
angle = atan(m).*(quarter1) + (atan(m)+pi).*(quarter2) + (atan(m)+pi).*(quarter3) +...
    atan(m).*(quarter4)+ zeroRad*0 + halfPiRad*pi/2 + piRad*pi + threeHalfPiRad*3/2*pi+...
    stillVehicles.*angleOld(:,1);


end

