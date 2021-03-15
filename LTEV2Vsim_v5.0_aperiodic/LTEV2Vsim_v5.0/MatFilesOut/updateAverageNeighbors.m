function [outputValues,NneighboursTot] = updateAverageNeighbors(simParams,stationManagement,outputValues,phyParams)

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

for iPhyRaw = 1:length(phyParams.Raw)
    % LTE
    if simParams.technology ~= 2 % if not only 11p
        NneighborsRawLTE = zeros(length(stationManagement.activeIDsLTE),1);
        for i = 1:length(stationManagement.activeIDsLTE)
            if iPhyRaw==1
                NneighborsRawLTE(i) = nnz(stationManagement.awarenessIDLTE(i,:,iPhyRaw));
            else
                NneighborsRawLTE(i) = nnz(setdiff(stationManagement.awarenessIDLTE(i,:,iPhyRaw),stationManagement.awarenessIDLTE(i,:,iPhyRaw-1)));
            end
        end
        NneighboursLTE = sum(NneighborsRawLTE);
        StDevNeighboursLTE = std(NneighborsRawLTE);
    else
        NneighboursLTE = 0;
        StDevNeighboursLTE = 0;
    end

    % 11p
    if simParams.technology ~= 1 % if not only LTE
        NneighborsRaw11p = zeros(length(stationManagement.activeIDs11p),1);
        for i = 1:length(stationManagement.activeIDs11p)
            if iPhyRaw==1
                NneighborsRaw11p(i) = nnz(stationManagement.awarenessID11p(i,:,iPhyRaw));
            else
                NneighborsRaw11p(i) = nnz(setdiff(stationManagement.awarenessID11p(i,:,iPhyRaw),stationManagement.awarenessID11p(i,:,iPhyRaw-1)));
            end
        end
        Nneighbours11p = sum(NneighborsRaw11p);
        StDevNeighbours11p = std(NneighborsRaw11p);
    else
        Nneighbours11p = 0;
        StDevNeighbours11p = 0;
    end

    NneighboursTot = NneighboursLTE + Nneighbours11p;
    outputValues.NneighborsLTE(iPhyRaw) = outputValues.NneighborsLTE(iPhyRaw) + NneighboursLTE;
    outputValues.Nneighbors11p(iPhyRaw) = outputValues.Nneighbors11p(iPhyRaw) + Nneighbours11p;
    outputValues.NneighborsTOT(iPhyRaw) = outputValues.NneighborsTOT(iPhyRaw) + NneighboursTot;
    outputValues.StDevNeighboursLTE(iPhyRaw) = outputValues.StDevNeighboursLTE(iPhyRaw) + StDevNeighboursLTE;
    outputValues.StDevNeighbours11p(iPhyRaw) = outputValues.StDevNeighbours11p(iPhyRaw) + StDevNeighbours11p;
    outputValues.StDevNeighboursTOT(iPhyRaw) = outputValues.StDevNeighboursTOT(iPhyRaw) + StDevNeighboursLTE + StDevNeighbours11p;
end