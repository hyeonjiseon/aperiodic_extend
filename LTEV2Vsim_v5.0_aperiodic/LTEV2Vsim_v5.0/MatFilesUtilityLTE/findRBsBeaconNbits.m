function  [RBsBeacon,Nbits] = findRBsBeaconNbits(ITBS,BeaconSizeBits)
% This function looks at Table 7-1-7-2-1-1 of 3GPP TS 36.213 V14.0.0 and,
% based on ITBS (which is calculated before) and B (beacon size), finds the
% corresponding number of RBs in each slot of an LTE subframe that is
% needed to carry one beacon

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

X = load('TBL717211.txt');

RBsBeacon = 0;

for i = 2 : 111
    if X(ITBS+1,i) > BeaconSizeBits
        Nbits = X(ITBS+1,i);
        RBsBeacon = 2*(i-1);
        break;
    end
end

if RBsBeacon == 0
    error('Beacon size is too large for the selected MCS');
end

end