function [Shadowing_dB] = computeShadowing(Shadowing_dB,LOS,dUpdate,stdDevShadowLOS_dB,stdDevShadowNLOS_dB,D_corr)
% Function that computes correlated shadowing samples w.r.t. the previous
% time instant

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

Nv = length(dUpdate(:,1));                           % Number of vehicles

% Generation of new samples of shadowing
newShadowing_dB = randn(Nv,Nv).*(LOS*stdDevShadowLOS_dB + (~LOS)*(stdDevShadowNLOS_dB));

% Calculation of correlated shadowing matrix
A = exp(-dUpdate/D_corr).*Shadowing_dB + sqrt( 1-exp(-2*dUpdate/D_corr) ).*newShadowing_dB;
Shadowing_dB = triu(A,1)+triu(A)';

end

