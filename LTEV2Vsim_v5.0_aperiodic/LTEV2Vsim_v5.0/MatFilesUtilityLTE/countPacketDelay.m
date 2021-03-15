function packetDelayCounter = countPacketDelay(iPhyRaw,IDvehicleTX,subframeNow,subframeLastPacket,NcorrectTX,packetDelayCounter,delayResolution)
% Function to compute the packet delay between received beacons
% Returns the updated packetDelayCounter

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

% Number of vehicles transmitting at the current time
Ntx = length(IDvehicleTX);

% Find maximum delay in updateDelayCounter
delayMax = length(packetDelayCounter(:,1))*delayResolution;

for i = 1:Ntx
    % Number of correct receptions
    iNcorrect = NcorrectTX(i);
    % Compute packet delay of the Tx vehicle (module is used to adapt the
    % calculation to the simulator design)
    if subframeLastPacket(IDvehicleTX(i))>0
        packetDelay = subframeNow - subframeLastPacket(IDvehicleTX(i));
        if packetDelay<0
            error('Delay of a packet z 0');
        elseif packetDelay>=delayMax
            % Increment last counter
            packetDelayCounter(end,iPhyRaw) = packetDelayCounter(end,iPhyRaw) + iNcorrect;
        else
            % Increment counter corresponding to the current delay
            packetDelayCounter(ceil(packetDelay/delayResolution),iPhyRaw) = ...
                packetDelayCounter(ceil(packetDelay/delayResolution),iPhyRaw) + iNcorrect;
        end
    end
end

end
