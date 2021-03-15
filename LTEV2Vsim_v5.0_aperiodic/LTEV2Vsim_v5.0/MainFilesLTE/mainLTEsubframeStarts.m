function [sinrManagement,stationManagement,timeManagement] = ...
            mainLTEsubframeStarts(appParams,phyParams,timeManagement,sinrManagement,stationManagement,simParams,simValues)
% an LTE subframe starts
        
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

% Compute the number of elapsed subframes (i.e., phyParams.Tsf)
timeManagement.elapsedTime_subframes = floor((timeManagement.timeNow+1e-9)/phyParams.Tsf) + 1;

% BR adopted in the time domain (i.e., TTI)
BRidT = ceil((stationManagement.BRid)/appParams.NbeaconsF);
BRidT(stationManagement.BRid<=0)=-1;

% Find IDs of vehicles that are currently transmitting
stationManagement.transmittingIDsLTE = find(BRidT == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1));
if ~isempty(stationManagement.transmittingIDsLTE)     
    % Find index of vehicles that are currently transmitting
    stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE = zeros(length(stationManagement.transmittingIDsLTE),1);
    stationManagement.indexInActiveIDs_OfTxLTE = zeros(length(stationManagement.transmittingIDsLTE),1);
    for ix = 1:length(stationManagement.transmittingIDsLTE)
        %A = find(stationManagement.activeIDsLTE == stationManagement.transmittingIDsLTE(ix));
        %if length(A)~=1
        %    error('X');
        %end
        stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(ix) = find(stationManagement.activeIDsLTE == stationManagement.transmittingIDsLTE(ix));
        stationManagement.indexInActiveIDs_OfTxLTE(ix) = find(stationManagement.activeIDs == stationManagement.transmittingIDsLTE(ix));
    end
end

% Initialization of the received power
[sinrManagement] = initLastPowerLTE(timeManagement,stationManagement,sinrManagement,simParams,appParams,phyParams);
    