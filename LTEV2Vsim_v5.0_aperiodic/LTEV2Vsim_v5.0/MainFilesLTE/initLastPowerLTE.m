function [sinrManagement] = initLastPowerLTE(timeManagement,stationManagement,sinrManagement,simParams,appParams,phyParams)

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

% If there is at least one LTE station transmitting, I have to initialize
% SINR values
if ~isempty(stationManagement.transmittingIDsLTE)     
    RXpower_MHz_ofLTE = sinrManagement.P_RX_MHz(stationManagement.indexInActiveIDs_ofLTEnodes,stationManagement.indexInActiveIDs_ofLTEnodes);

    % Number of vehicles transmitting in the current subframe
    Ntx = length(stationManagement.transmittingIDsLTE);

    % Initialization of SINRmanagement
    sinrManagement.neighPowerUsefulLastLTE = zeros(Ntx,length(stationManagement.activeIDsLTE)-1);
    sinrManagement.neighPowerInterfLastLTE = zeros(Ntx,length(stationManagement.activeIDsLTE)-1);
    sinrManagement.neighborsSINRaverageLTE = zeros(Ntx,length(stationManagement.activeIDsLTE)-1);
    sinrManagement.neighborsSINRsciAverageLTE = zeros(Ntx,length(stationManagement.activeIDsLTE)-1);
    sinrManagement.instantThisPstartedLTE = timeManagement.timeNow;
    sinrManagement.instantTheSINRaverageStartedLTE = timeManagement.timeNow;

    % Find not assigned BRid
    indexNOT = (stationManagement.BRid<=0);

    % Calculate BRidT = vector of BRid in the time domain
    BRidT = ceil(stationManagement.BRid/appParams.NbeaconsF);
    BRidT(indexNOT) = -1;

    % Calculate BRidF = vector of BRid in the frequency domain
    BRidF = mod(stationManagement.BRid-1,appParams.NbeaconsF)+1;
    BRidF(indexNOT) = -1;

    for i_tx = 1:Ntx

        % Find BRT and BRF in use by tx vehicle i
        BRTtx = BRidT(stationManagement.transmittingIDsLTE(i_tx));
        BRFtx = BRidF(stationManagement.transmittingIDsLTE(i_tx));

        % Find neighbors of vehicle i
        indexNeighborOfVehicleTX = find(stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(i_tx),:));

        for j_neigh = indexNeighborOfVehicleTX

            % ID rx vehicle
            IDrx = stationManagement.neighborsIDLTE(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(i_tx),j_neigh);

            % Find BRT in use by rx vehicle j
            BRTrx = BRidT(IDrx);

            % Useful received power by vehicle j
            C = RXpower_MHz_ofLTE(stationManagement.activeIDsLTE==IDrx,stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(i_tx));

            % Initialize interfering power sums vector
            Isums = zeros(appParams.NbeaconsF,1);

            % Interference computation
            % Find other vehicles transmitting in the same subframe of
            % tx vehicle i
            if Ntx > 1 % otherwise there is only one transmitter - no interference
                for k = 1:length(stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE)
                    % If interferer is different from tx vehicle i and
                    % different from receiving vehicle j
                    if k~=i_tx && stationManagement.transmittingIDsLTE(k)~=IDrx
                        % Find which BRF is used by the interferer k
                        BRFInt = BRidF(stationManagement.transmittingIDsLTE(k));
                        % Find power from interfering vehicle k received
                        % by receiving vehicle j         
                        I = RXpower_MHz_ofLTE(stationManagement.activeIDsLTE==IDrx,stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(k));
                        % Sum interference in that BRF
                        Isums(BRFInt,1) = Isums(BRFInt,1) + I;% THIS LINE
                    end
                end
            end

            % Find total interference using IBE
            Itot = phyParams.IBEmatrix(BRFtx,:)*Isums;

            % Check if the receiver j is transmitting on the same BRT
            % of transmitter i
            if BRTtx==BRTrx
                % Self-interference
                selfI = phyParams.Ksi*phyParams.P_ERP_MHz_LTE(stationManagement.transmittingIDsLTE(i_tx)); % does not include Gr
            else
                % No self-interference
                selfI = 0;
            end

            % SINR computation
            %SINR(i,j) = C / (PnRB + selfI + Itot);
            sinrManagement.neighPowerUsefulLastLTE(i_tx,j_neigh) = C * phyParams.BwMHz_lteBR;
            sinrManagement.neighPowerInterfLastLTE(i_tx,j_neigh) = (selfI + Itot) * phyParams.BwMHz_lteBR;
        end
    end
end