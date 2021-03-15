function printDebugTx(Time,isThisTX,staID,stationManagement,positionManagement,sinrManagement,outParams,phyParams)
% Print of: Time, event description, then per each station:
% ID, technology, state, current SINR (if LTE, first neighbor), useful power (if LTE, first neighbor),
% interfering power (if LTE, first neighbor), interfering power from
% the other technology (if LTE, first neighbor)

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

%if Time<57
   return;
%end

alsoRx = true;

filename = sprintf('%s/_DebugTx_%d.xls',outParams.outputFolder,outParams.simID);
fid = fopen(filename,'r');
if fid==-1
    fid = fopen(filename,'w');
    fprintf(fid,'Time\tVehicle 11p TX\t');
    if alsoRx
        fprintf(fid,'Vehicle 11p RX OK\tVehicle 11p RX ERR\t');
    end
    fprintf(fid,'Vehicle LTE TX\t');
    if alsoRx
        fprintf(fid,'Vehicle LTE RX OK\tVehicle LTE RX ERR\t');
    end
    fprintf(fid,'X of Vehicle 11p TX\t');
    if alsoRx
        fprintf(fid,'X of Vehicle 11p RX OK\tX of Vehicle 11p RX ERR\t');
    end
    fprintf(fid,'X of Vehicle LTE TX');
    if alsoRx
        fprintf(fid,'\tX of Vehicle LTE RX OK\tX of Vehicle LTE RX ERR');
    end
    fprintf(fid,'\n');
end
fclose(fid);

fid = fopen(filename,'a');
if staID==-1
    if isfield(stationManagement,'transmittingIDsLTE') && ~isempty(stationManagement.transmittingIDsLTE)
        nTx = length(stationManagement.transmittingIDsLTE);
        for index=1:nTx
            if isThisTX
                fprintf(fid,'%3.6f\t\t\t\t%d\t\t\t',Time,stationManagement.transmittingIDsLTE(index));
                fprintf(fid,'\t\t\t%d\t\t\n',positionManagement.XvehicleReal(stationManagement.transmittingIDsLTE(index)));
            end
            if alsoRx && ~isThisTX
                % Find indexes of receiving vehicles in neighborsID
                indexNeighborsRX = find(stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(index),:));
                for j = 1:length(indexNeighborsRX)
                    % If received beacon SINR is lower than the threshold
                    if sinrManagement.neighborsSINRaverageLTE(index,indexNeighborsRX(j)) < phyParams.sinrThresholdLTE
                        fprintf(fid,'%3.6f\t\t\t\t\t\t%d\t',Time,stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(index),j));
                        fprintf(fid,'\t\t\t\t\t%d\n',positionManagement.XvehicleReal(stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(index),j)));
                    else
                        fprintf(fid,'%3.6f\t\t\t\t\t%d\t\t',Time,stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(index),j));
                        fprintf(fid,'\t\t\t\t%d\t\n',positionManagement.XvehicleReal(stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(index),j)));
                    end
                end
            end
        end
    end
else
    if isThisTX
        fprintf(fid,'%3.6f\t%d\t\t\t\t\t\t',Time,staID);
        fprintf(fid,'%d\t\t\t\t\t\n',positionManagement.XvehicleReal(staID));
    end
    if alsoRx && ~isThisTX
        indexOfstaID = find(stationManagement.activeIDs11p==staID,1);
        rxOk = (stationManagement.vehicleState(stationManagement.activeIDs11p)==9) .* (sinrManagement.idFromWhichRx11p(stationManagement.activeIDs11p)==staID)...
                .* (sinrManagement.sinrAverage11p(stationManagement.activeIDs11p) >= phyParams.sinrThreshold11p);
        awarenessID11p = stationManagement.awarenessID11p(indexOfstaID,:)';
        neighborsRaw = ismember(stationManagement.activeIDs11p,awarenessID11p);
        neighbors = (stationManagement.activeIDs11p(neighborsRaw))';
        for iN=neighbors
            indexOfNeighbor=(stationManagement.activeIDs11p==iN);
            if rxOk(indexOfNeighbor)
                fprintf(fid,'%3.6f\t\t%d\t\t\t\t\t',Time,iN);
                fprintf(fid,'\t%d\t\t\t\t\n',positionManagement.XvehicleReal(iN));
            else
                fprintf(fid,'%3.6f\t\t\t%d\t\t\t\t',Time,iN);
                fprintf(fid,'\t\t%d\t\t\t\n',positionManagement.XvehicleReal(iN));
            end
        end
    end
end
fclose(fid);
