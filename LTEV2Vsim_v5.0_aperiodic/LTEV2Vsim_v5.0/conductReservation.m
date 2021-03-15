function [stationManagement] = conductReservation(M_matrix,simParams,stationManagement,timeManagement,IDvehicle,Nbeacons,NbeaconsT,NbeaconsF)%안보임
%Alg 2, Line 3
stationManagement.conductReserveMatrix(:,:,IDvehicle) = zeros(Nbeacons,10);
%Alg 2, Line 1-2
if stationManagement.numPacketInit(IDvehicle)<5
    RRP1 = M_matrix(stationManagement.usedNumRow(IDvehicle),stationManagement.numPacketInit(IDvehicle)*1);
    RRP2 = 0;
elseif stationManagement.numPacketInit(IDvehicle)>=5
    idx1 = find(timeManagement.packetInterval(IDvehicle,1) == M_matrix(:,1);
    idx2 = intersect(find(timeManagement.packetInterval(IDvehicle,2)==M_matrix(:,2)),idx1);
    idx3 = intersect(find(timeManagement.packetInterval(IDvehicle,3)==M_matrix(:,3)),idx2);
    idx4 = intersect(find(timeManagement.packetInterval(IDvehicle,4)==M_matrix(:,4)),idx3);
    idx = intersect(find(timeManagement.packetInterval(IDvehicle,5)==M_matrix(:,5)),idx4);
    if length(idx) == 1
        RRP1 = M_matrix(idx,6);
        RRP2 = 0;
    elseif length(idx) > 1
        probSet = M_matrix(idx,7);
        [~,maxIndex] = maxk(probSet,2);
        RRP1 = M_matrix(-1*min(idx)+maxIndex(1),6);
        RRP2 = M_matrix(-1*min(idx)+maxIndex(2),6);
    else
        RRP1 = 0;
        RRP2 = 0;
    end
end
%Alg 2, Line 5-7
if stationManagement.resReselectionCounterLTE(IDvehicle) > 1 && RRP1>0
    stationMAnagement.conductReserveMatrix(stationManagement.BRid(IDvehicle),RRP1,IDvehicle) = 1;
    if RRP2 > 0
        stationManagement.conductReserveMatrix(statioinManagement.BRid(IDvehicle),RRP2,IDvehicle)=1;
    end
    %Alg 2, Line 8-11
elseif stationManagement.resReselectionCounterLTE(IDvehicle == 1 && RRP1 > 0
    sensingMatrixScheduled = sum(stationManagement.sensingMatrixLTE(:,:,IDvehicle),1)/length(stationManagement.sensingMatrixLTE(:,1,1));
    if simParams.subframeT1Mode4 > 1 || simParams.subframeT2Mode4 <100
        if NbeaconsT ~=100
            error('This part is written for NbeaconsT=100. NEeds revision.');
        end
        %Since the currentT can be at any point of beacon resource matrix,
        %the calculations depend on where T1 and T2 are placed IF Both T1
        %and T2 are within this beacon period
        if (currentT*simParams.subframeT2Mode4+1)<=NbeaconsT
            sensingMatrixScheduled([1:((currentT+simParams.subframeT1Mode4-1)*NbeaconsF),((currentT*simParams.subframeT2Mode4)*NbeaconsF+1)]);%안보임
            %IF Both are beyond this beacon period
        elseif (currentT+simParams.subframeT1Mode4-1)>NbeaconsT
            sensingMatrixScheduled([1:((currentT+simParams.subframeT1Mode4-1-NbeaconsT)*NbeaconsF),((currentT+simPArams.subframeT2Mode4-NbeaconsT)*NbeaconsF)]);%안보임
        end
        
        sensingMatrixPerm = sensingMatrixScheduled(rpMatrix);
        updateReservaeMatrixScheduledSumPerm = updateReserveMatrixScheduledSum(rpMatrix);
        
        powerThreshold = simParams.powerThresholdMode4;
        while powerThreshold < 100
            usableBRs = ((sensingMatrixPerm*0.015)<powerThreshold) | ((sensingMatrixPerm < inf) & (updateReserveMatrixScheduledSumPerm < 1));
            if sum(usableBRs) < MBest
                powerThreshold = powerThreshold * 2;
            else
                break;
            end
        end
        idx = find(usableBRs == 1);
        bestBR = rpMatrix(idx);
        BRindex = randi(length(bestBR));
        newBR = bestBR(BRindex);
        stationManagement.reserveNewBRid(IDvehicle) = newBR;
        
        stationManagement.conductReserveMatrix(stationManagement.reserveNewBRid(IDvehicle),RRP1,IDvehicle) = 1;
        if RRP2>0
            stationManagement.conductReserveMatrix(stationManagement.reserveNewBRid(IDvehicle),RRP2,IDvehicle) = 1;
        end
    end
end
