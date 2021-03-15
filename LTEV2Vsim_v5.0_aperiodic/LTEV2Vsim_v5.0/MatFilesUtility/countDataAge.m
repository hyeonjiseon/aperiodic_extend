function [dataAgeTimestampMatrix,dataAgeCounter] = countDataAge(iPhyRaw,timeManagement,IDvehicleTX,indexVehicleTX,BRid,NbeaconsF,awarenessID,errorMatrix,elapsedTime,dataAgeTimestampMatrix,dataAgeCounter,delayResolution)
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
delayMax = length(dataAgeCounter(:,1))*delayResolution;

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
    dataAgeTimestampMatrix(IDvehicleTX(i),IDOut,iPhyRaw)=-1;
    for j = 1:length(IDIn)
        % If the vehicle is not blocked and if there is no error in reception, update the matrix
        % with the timestamp of the received beacons
        if BRid(IDIn(j))>0 && isempty(find(errorMatrix(:,1)==IDvehicleTX(i) & errorMatrix(:,2)==IDIn(j), 1))
            % Store previous timestamp
            previousTimeStamp = dataAgeTimestampMatrix(IDvehicleTX(i),IDIn(j),iPhyRaw);
            % Compute current timestamp
            currentTimeStamp = elapsedTime;
            % If there was a previous timestamp
            if previousTimeStamp>0
                % Compute update delay, considering the subframe used for transmission (s)
                dataAge = currentTimeStamp-previousTimeStamp;
                % Check if the update delay is larger than the maximum delay value stored in the array
                if dataAge<0
                    error('Update delay < 0');
                elseif dataAge>=delayMax
                    % Increment last counter
                    dataAgeCounter(end,iPhyRaw) = dataAgeCounter(end,iPhyRaw) + 1;
                else
                    % Increment counter corresponding to the current delay
                    dataAgeCounter(ceil(dataAge/delayResolution),iPhyRaw) = ...
                        dataAgeCounter(ceil(dataAge/delayResolution),iPhyRaw) + 1;
                end
            end
            % Update updateTimeMatrix with the current timestamp
            dataAgeTimestampMatrix(IDvehicleTX(i),IDIn(j),iPhyRaw) = timeManagement.timeLastPacket(IDvehicleTX(i));
        end
    end
end

end
