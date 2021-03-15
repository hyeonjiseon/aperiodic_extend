function [updateTimeMatrix,updateDelayCounter] = countUpdateDelay(iPhyRaw,IDvehicleTX,indexVehicleTX,BRid,NbeaconsF,awarenessID,errorMatrix,elapsedTime,updateTimeMatrix,updateDelayCounter,delayResolution,enableUpdateDelayHD)
% Function to compute the update delay between received beacons
% Returns the updated updateTimeMatrix, updateDelayMatrix and updateDelayCounter

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

% Update updateTimeMatrix -> matrix containing the timestamp of the last received beacon
% Row index -> transmitting vehicle's ID
% Column index -> receiving vehicle's ID
Ntx = length(IDvehicleTX);
all = 1:length(BRid);
delayMax = length(updateDelayCounter(:,1))*delayResolution;

% Find not assigned BRid
indexNOT = BRid<=0;

% Calculate BRidT = vector of BRid in the time domain
BRidT = ceil(BRid/NbeaconsF);
BRidT(indexNOT) = -1;

for i = 1:Ntx
    % Vehicles inside the awareness range of vehicle IDvehicleTX(i)
    IDIn = awarenessID(indexVehicleTX(i),awarenessID(indexVehicleTX(i),:)>0);
    % ID of vehicles that are outside the awareness range of vehicle i
    IDOut = setdiff(all,IDIn);
    updateTimeMatrix(IDvehicleTX(i),IDOut,iPhyRaw)=-1;
    for j = 1:length(IDIn)
        % If boolean 'enableUpdateDelayHD' is false, if the vehicle is not
        % blocked and if there is no error in reception, update the matrix
        % with the timestamp of the received beacons
        % If boolean 'enableUpdateDelayHD' is true, compute only the update
        % delay caused by concurrent transmissions on the same subframe
        if ((BRid(IDIn(j))>0 && isempty(find(errorMatrix(:,1)==IDvehicleTX(i) & errorMatrix(:,2)==IDIn(j), 1))) && ~enableUpdateDelayHD)...
                || ((~(BRid(IDIn(j))>0 && BRidT(IDvehicleTX(i))==BRidT(IDIn(j)))) && enableUpdateDelayHD)
            % Store previous timestamp
            previousTimeStamp = updateTimeMatrix(IDvehicleTX(i),IDIn(j),iPhyRaw);
            % Compute current timestamp
            currentTimeStamp = elapsedTime;
            % If there was a previous timestamp
            if previousTimeStamp>0
                % Compute update delay, considering the subframe used for transmission (s)
                updateDelay = currentTimeStamp-previousTimeStamp;
                % Check if the update delay is larger than the maximum delay value stored in the array
                if updateDelay<0
                    error('Update delay < 0');
                elseif updateDelay>=delayMax
                    % Increment last counter
                    updateDelayCounter(end,iPhyRaw) = updateDelayCounter(end,iPhyRaw) + 1;
                else
                    % Increment counter corresponding to the current delay
                    updateDelayCounter(ceil(updateDelay/delayResolution),iPhyRaw) = ...
                        updateDelayCounter(ceil(updateDelay/delayResolution),iPhyRaw) + 1;
                end
            end
            % Update updateTimeMatrix with the current timestamp
            updateTimeMatrix(IDvehicleTX(i),IDIn(j),iPhyRaw) = currentTimeStamp;
        end
    end
end

end
