function [RBsBeacon,gammaMin_dB,NbitsHz] = findRBsBeaconSINRmin(MCS,BeaconSizeBits)
% This function calculates RBs per beacon and minimum required SINR

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

% Call function to find ITBS value from MCS
ITBS = findITBS(MCS);

% Call function to find the modulation format (number of bits per symbol)
Nbps = findModulation(MCS);

% Call function to find the number of RBs per beacon
[RBsBeacon,Nbits] = findRBsBeaconNbits(ITBS,BeaconSizeBits);

% Compute the effective code rate
CR = Nbits/((RBsBeacon/2)*9*12*Nbps);

% Compute spectral efficiency (bits/s·Hz)
NbitsHz = (12*14*Nbps*CR)/(1e-3*180e3);

% Compute the minimum required SINR
% (alfa is taken from 3GPP)
alfa = 0.4;
gammaMin_dB = 10*log10(2^(NbitsHz/alfa)-1);

end