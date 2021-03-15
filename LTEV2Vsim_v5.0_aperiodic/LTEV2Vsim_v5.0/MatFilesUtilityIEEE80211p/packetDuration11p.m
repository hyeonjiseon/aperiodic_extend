function tPack = packetDuration11p(Nbyte,Mode,NbitsHz,BwMHz,pWithLTEPHY)
% IEEE 802.11p: find packet transmission duration

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

Nol = 22; % overhead at MAC in bits
%Noh = 60; % overhead above MAC in bytes
tOs = 8e-6; % OFDM symbol duration
tPreamble = 40e-6; % overhead at PHY in us

% If using 802.11p standard PHY
% From version 5.0.11, the Modes are numbered from 0 to 7
if ~pWithLTEPHY
    % ns = bits per OFDM symbol
    if Mode==0
        ns = 24; % Mode 0
    elseif Mode==1
        ns = 36; % Mode 1
    elseif Mode==2
        ns = 48; % Mode 2
    elseif Mode==3
        ns = 72; % Mode 3
    elseif Mode==4
        ns = 96; % Mode 4
    elseif Mode==5
        ns = 144; % Mode 5
    elseif Mode==6
        ns = 192; % Mode 6
    elseif Mode==7
        ns = 216; % Mode 7
    else
        error('Error');
    end
    
    % Compute packet transmission duration (standard)
    tPack = tPreamble + ceil((Nbyte*8 + Nol)/ns)*tOs;
else
    % If using 802.11p with LTE PHY
    
    % Compute throughput (bits/s)
    thr = NbitsHz*BwMHz*1e6;
    
    % Compute packet transmission duration (11p with LTE PHY)
    tPack = tPreamble + ceil((Nbyte*8 + Nol)/(thr*tOs))*tOs;
end

end
