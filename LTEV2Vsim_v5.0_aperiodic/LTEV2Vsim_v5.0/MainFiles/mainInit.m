function [appParams,simParams,phyParams,outParams,simValues,outputValues,...
    sinrManagement,timeManagement,positionManagement,stationManagement] = mainInit(appParams,simParams,phyParams,outParams,simValues,outputValues,positionManagement)
% Initialization function

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

%% Init of active vehicles and states
% Move IDvehicle from simValues to station Management
% TODO simValues to be removed in future versions
stationManagement.activeIDs = simValues.IDvehicle;

% State of each node
% Discriminates LTE nodes from 11p nodes
if simParams.technology==1
    
    % All vehicles in LTE are currently in the same state
    % 100 = LTE TX/RX
    stationManagement.vehicleState = 100 * ones(simValues.maxID,1);
 
elseif simParams.technology==2
   
    % The possible states in 11p are four:
    % 1 = IDLE :    the node has no packet and senses the medium as free
    % 2 = BACKOFF : the node has a packet to transmit and senses the medium as
    %               free; it is thus performing the backoff
    % 3 = TX :      the node is transmitting
    % 9 = RX :      the node is sensing the medium as busy and possibly receiving
    %               a packet (the sender it firstly sensed is saved in
    %               idFromWhichRx)
    stationManagement.vehicleState = ones(simValues.maxID,1);

else % coexistence
    
    % Init all as LTE
    stationManagement.vehicleState = 100 * ones(simValues.maxID,1);
    %Then use simParams.numVehiclesLTE and simParams.numVehicles11p to
    %initialize
    for i11p = 1:simParams.numVehicles11p
        stationManagement.vehicleState(simParams.numVehiclesLTE+i11p:simParams.numVehiclesLTE+simParams.numVehicles11p:end) = 1;
    end
        
%     % POSSIBLE OPTION FOR DEBUG PURPOSES
%     % First half 11p, Second half LTE
%     stationManagement.vehicleState = 100*ones(simValues.maxID,1);
%     stationManagement.vehicleState(1:1:end/2) = 1;

end

%% Initialization of the vectors of active vehicles in each technology, 
% which is helpful to work with smaller vectors and matrixes
stationManagement.activeIDsLTE = stationManagement.activeIDs.*(stationManagement.vehicleState(stationManagement.activeIDs)==100);
stationManagement.activeIDsLTE = stationManagement.activeIDsLTE(stationManagement.activeIDsLTE>0);
stationManagement.activeIDs11p = stationManagement.activeIDs.*(stationManagement.vehicleState(stationManagement.activeIDs)~=100);
stationManagement.activeIDs11p = stationManagement.activeIDs11p(stationManagement.activeIDs11p>0);
stationManagement.indexInActiveIDs_ofLTEnodes = zeros(length(stationManagement.activeIDsLTE),1);
for i=1:length(stationManagement.activeIDsLTE)
    stationManagement.indexInActiveIDs_ofLTEnodes(i) = find(stationManagement.activeIDs==stationManagement.activeIDsLTE(i));
end
stationManagement.indexInActiveIDs_of11pnodes = zeros(length(stationManagement.activeIDs11p),1);
for i=1:length(stationManagement.activeIDs11p)
    stationManagement.indexInActiveIDs_of11pnodes(i) = find(stationManagement.activeIDs==stationManagement.activeIDs11p(i));
end

%% Number of vehicles at the current time
outputValues.Nvehicles = length(simValues.IDvehicle);
outputValues.NvehiclesTOT = outputValues.NvehiclesTOT + outputValues.Nvehicles;
outputValues.NvehiclesLTE = outputValues.NvehiclesLTE + length(stationManagement.activeIDsLTE);
outputValues.Nvehicles11p = outputValues.Nvehicles11p + length(stationManagement.activeIDs11p);

%% Initialization of packets management 
% Number of packets in the queue of each node
stationManagement.nPackets = zeros(simValues.maxID,1);

% Packet generation
timeManagement.timeNextPacket = Inf * ones(simValues.maxID,1);
timeManagement.timeNextPacket(simValues.IDvehicle) = appParams.averageTbeacon * rand(length(simValues.IDvehicle),1);
timeManagement.timeLastPacket = -1 * ones(simValues.maxID,1); % needed for the calculation of the CBR
timeManagement.beaconPeriod = appParams.averageTbeacon - appParams.variabilityTbeacon/2 + appParams.variabilityTbeacon*rand(simValues.maxID,1);
timeManagement.beaconPeriod(stationManagement.activeIDsLTE) = appParams.averageTbeacon;

%% Initialize propagation
% Tx power vectors
if isfield(phyParams,'P_ERP_MHz_LTE')
    phyParams.P_ERP_MHz_LTE = phyParams.P_ERP_MHz_LTE*ones(simValues.maxID,1);
else
    phyParams.P_ERP_MHz_LTE = -ones(simValues.maxID,1);
end
if isfield(phyParams,'P_ERP_MHz_11p')
    phyParams.P_ERP_MHz_11p = phyParams.P_ERP_MHz_11p*ones(simValues.maxID,1);
else
    phyParams.P_ERP_MHz_11p = -ones(simValues.maxID,1);
end

% Vehicles in a technology have the power to -1000 in the other; this is helpful for
% verification purposes
phyParams.P_ERP_MHz_LTE(stationManagement.vehicleState~=100) = -1000;
phyParams.P_ERP_MHz_11p(stationManagement.vehicleState==100) = -1000;

% Shadowing matrix
sinrManagement.Shadowing_dB = randn(length(simValues.IDvehicle),length(simValues.IDvehicle))*phyParams.stdDevShadowLOS_dB;
sinrManagement.Shadowing_dB = triu(sinrManagement.Shadowing_dB,1)+triu(sinrManagement.Shadowing_dB)';

%% Management of coordinates and distances
% Init knowledge at eNodeB of nodes positions
if simParams.technology~=2 % not only 11p
    % Number of groups for position update
 	positionManagement.NgroupPosUpdate = round(simParams.Tupdate/appParams.averageTbeacon);
    % Assign update period to all vehicles (introduce a position update delay)
    positionManagement.posUpdateAllVehicles = randi(positionManagement.NgroupPosUpdate,simValues.maxID,1);
else
    positionManagement.NgroupPosUpdate = -1;
end

% Copy real coordinates into estimated coordinates at eNodeB (no positioning error)
simValues.XvehicleEstimated = positionManagement.XvehicleReal;
simValues.YvehicleEstimated = positionManagement.YvehicleReal;

% Call function to compute distances
% computeDistance(i,j): computeDistance from vehicle with index i to vehicle with index j
% positionManagement.distance matrix has dimensions equal to simValues.IDvehicle x simValues.IDvehicle in order to
% speed up the computation (only vehicles present at the considered instant)
% positionManagement.distance(i,j): positionManagement.distance from vehicle with index i to vehicle with index j
[positionManagement,stationManagement] = computeDistance (simParams,simValues,stationManagement,positionManagement,phyParams);

% Save positionManagement.distance matrix
positionManagement.XvehicleRealOld = positionManagement.XvehicleReal;
positionManagement.YvehicleRealOld =  positionManagement.YvehicleReal;
positionManagement.distanceRealOld = positionManagement.distanceReal;
positionManagement.angleOld = zeros(length(positionManagement.XvehicleRealOld),1);

% The variable 'timeManagement.timeNextPosUpdate' is used for updating the positions
timeManagement.timeNextPosUpdate = simParams.positionTimeResolution;
positionManagement.NposUpdates = 1;

% Number of neighbors
[outputValues,~] = updateAverageNeighbors(simParams,stationManagement,outputValues,phyParams);

% Floor coordinates for PRRmap creation (if enabled)
if simParams.typeOfScenario==2 && outParams.printPRRmap % Only traffic traces
    simValues.XmapFloor = floor(simValues.Xmap);
    simValues.YmapFloor = floor(simValues.Ymap);
end

% Computation of the channel gain
% 'dUpdate': vector used for the calculation of correlated shadowing
dUpdate = zeros(outputValues.Nvehicles,outputValues.Nvehicles);
% TODO in future versions the two function should be integrated into a
% single function
[CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChannelGain(sinrManagement,positionManagement,phyParams,simParams,dUpdate);
% if ~phyParams.winnerModel   
%     [CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChGain(positionManagement.distanceReal,phyParams.L0,phyParams.beta,positionManagement.XvehicleReal,positionManagement.YvehicleReal,phyParams.Abuild,phyParams.Awall,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap,positionManagement.GridMap,simParams.fileObstaclesMap,sinrManagement.Shadowing_dB,dUpdate,phyParams.stdDevShadowLOS_dB,phyParams.stdDevShadowNLOS_dB);
% else
%     [CHgain,sinrManagement.Shadowing_dB,simValues.Xmap,simValues.Ymap] = computeChGainWinner(positionManagement.distanceReal,positionManagement.XvehicleReal,positionManagement.YvehicleReal,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap,positionManagement.GridMap,simParams.fileObstaclesMap,sinrManagement.Shadowing_dB,dUpdate,phyParams.stdDevShadowLOS_dB,phyParams.stdDevShadowNLOS_dB);
% end

% Compute RXpower
% NOTE: sinrManagement.P_RX_MHz( RECEIVER, TRANSMITTER) 
sinrManagement.P_RX_MHz =  ( (phyParams.P_ERP_MHz_LTE(stationManagement.activeIDs).*(stationManagement.vehicleState(stationManagement.activeIDs)==100))' + ...
    (phyParams.P_ERP_MHz_11p(stationManagement.activeIDs).*(stationManagement.vehicleState(stationManagement.activeIDs)~=100))' )...
    * phyParams.Gr .* min(1,CHgain);

%% Initialization of time variables
% Stores the instant of the next event among all possible events;
% initially set to the first packet generation
timeManagement.timeNextEvent = Inf * ones(simValues.maxID,1);
timeManagement.timeNextEvent(simValues.IDvehicle) = timeManagement.timeNextPacket(simValues.IDvehicle);

%% Initialization of variables related to transmission in IEEE 802.11p
% 'timeNextTxRx11p' stores the instant of the next backoff or
% transmission end, if the station is 11p - not used in LTE and therefore
% init to inf in all cases
timeManagement.timeNextTxRx11p = Inf * ones(simValues.maxID,1);
%
if simParams.technology~=1 % if not only LTE
    % When a node senses the medium as busy and goes to State RX, the
    % transmitting node is saved in 'idFromWhichRx'
    % Note that once a node starts receiving a signal, it will not be able to
    % synchronize to a different signal, thus there is no reason to change this
    % value before exiting from State RX
    % 'idFromWhichRx' is set to the id of the node if the node is not receiving
    % (a number must be set in order to avoid exceptions running the code that follow)
    sinrManagement.idFromWhichRx11p = (1:simValues.maxID)';

    % Possible events: A) New packet, B) Backoff ends, C) Transmission end;
    % A - 'timeNextPacket' stores the instant of the next message generation; the
    % first instant is randomly chosen within 0-Tbeacon
    %timeManagement.timeNextGeneration11p = timeManagement.timeNextPacket;
    timeManagement.cbr11p_timeStartBusy = -1 * ones(simValues.maxID,1); % needed for the calculation of the CBR
    timeManagement.cbr11p_timeStartMeasInterval = -1 * ones(simValues.maxID,1); % needed for the calculation of the CBR

    % Total power being received from nodes in State 3
    sinrManagement.rxPowerInterfLast11p = zeros(simValues.maxID,1);
    sinrManagement.rxPowerUsefulLast11p = zeros(simValues.maxID,1);
 
    % Instant when the power store in 'PrTot' was calculated; it will remain
    % constant until a new calculation will be performed
    %sinrManagement.instantThisPrStarted11p = Inf;
    sinrManagement.instantThisSINRstarted11p = ones(simValues.maxID,1)*Inf;

    % Average SINR - This parameter is irrelevant if the node is not in State 9
    sinrManagement.sinrAverage11p = zeros(simValues.maxID,1);

    % Instant when the average SINR of a node in State 9 was initiated - This
    % parameter is irrelevant if the node is not in State 9
    sinrManagement.instantThisSINRavStarted11p = Inf * ones(simValues.maxID,1);

    % Number of slots for the backoff - Set to '-1' when not initiated
    stationManagement.nSlotBackoff11p = -1 * ones(simValues.maxID,1);
    
    % Prepare matrix for update delay computation (if enabled)
    if outParams.printUpdateDelay
        % Reset update time of vehicles that are outside the scenario
        allIDOut = setdiff(1:simValues.maxID,simValues.IDvehicle);
        simValues.updateTimeMatrix11p(allIDOut,:) = -1;
        simValues.updateTimeMatrix11p(:,allIDOut) = -1;
    end

    % Prepare matrix for data age computation (if enabled)
    if outParams.printDataAge
        % Reset update time of vehicles that are outside the scenario
        allIDOut = setdiff(1:simValues.maxID,simValues.IDvehicle);
        simValues.dataAgeTimestampMatrix11p(allIDOut,:) = -1;
        simValues.dataAgeTimestampMatrix11p(:,allIDOut) = -1;
    end
    
    % Initialization of a matrix containing the duration the channel has
    % been sensed as busy, if used
    % Note: 11p CBR is calculated over a fixed number of beacon periods; 
    % this implies that if they are not all the same among vehciles, then 
    % the duration of the sensing interval is not the same
    if outParams.printCBR
        stationManagement.channelSensedBusyMatrix11p = zeros(ceil(simParams.cbrSensingInterval/appParams.averageTbeacon),simValues.maxID);
    else
        % set to empty if not used
        stationManagement.channelSensedBusyMatrix11p = [];
    end

    % Conversion of sensing power threshold when hidden node probability is active
    if outParams.printHiddenNodeProb
        %% TODO - needs update
        error('Not updated in v5');
        %if outParams.Pth_dBm==1000
        %    outParams.Pth_dBm = 10*log10(phyParams.gammaMin*phyParams.PnBW*(appParams.RBsBeacon/2))+30;
        %end
        %outParams.Pth = 10^((outParams.Pth_dBm-30)/10);
    end

    % Initialize vector containing variable beacon periodicity
    if simParams.technology==2 && appParams.variableBeaconSize
        % Generate a random integer for each vehicle indicating the period of
        % transmission (1 corresponds to the transmission of a big beacon)
        stationManagement.variableBeaconSizePeriodicity = randi(appParams.NbeaconsSmall+1,simValues.maxID,1);
    else
        stationManagement.variableBeaconSizePeriodicity = 0;
    end

end % end of not only LTE

%% Initialization of variables related to transmission in IEEE 802.11p
% Initialize the beacon resource used by each vehicle
stationManagement.BRid = -2*ones(simValues.maxID,1);
stationManagement.BRid(simValues.IDvehicle) = -1;
%
% Initialize next LTE event to inf
timeManagement.timeNextLTE = inf;
%
if simParams.technology ~= 2 % not only 11p

    % Initialization of resouce allocation algorithms in LTE-V2X
   if simParams.BRAlgorithm==2 || simParams.BRAlgorithm==7 || simParams.BRAlgorithm==10
        % Number of groups for scheduled resource reassignment (BRAlgorithm=2, 7 or 10)
        stationManagement.NScheduledReassignLTE = round(simParams.Treassign/appParams.averageTbeacon);

        % Assign update period to vehicles (BRAlgorithm=2, 7 or 10)
        stationManagement.scheduledReassignLTE = randi(stationManagement.NScheduledReassignLTE,simValues.maxID,1);
    end

    if simParams.BRAlgorithm==18
        % Find min and max values for random counter (BRAlgorithm=18)
        [simParams.minRandValueMode4,simParams.maxRandValueMode4] = findRandValueMode4(appParams.averageTbeacon,simParams);

        % Initialize reselection counter (BRAlgorithm=18)
        stationManagement.resReselectionCounterLTE = Inf*ones(simValues.maxID,1);
        stationManagement.resReselectionCounterLTE(stationManagement.activeIDs) = (simParams.minRandValueMode4-1) + randi((simParams.maxRandValueMode4-simParams.minRandValueMode4)+1,1,length(simValues.IDvehicle));
        % COMMENTED: Set value 0 to vehicles that are blocked
        % stationManagement.resReselectionCounterLTE(stationManagement.BRid==-1)=0;

        % Initialization of sensing matrix (BRAlgorithm=18)
        stationManagement.sensingMatrixLTE = zeros(ceil(simParams.TsensingPeriod/appParams.averageTbeacon),appParams.Nbeacons,simValues.maxID);
        stationManagement.knownUsedMatrixLTE = zeros(appParams.Nbeacons,simValues.maxID);

        % First random allocation 
        [stationManagement.BRid,~] = BRreassignmentRandom(simValues.IDvehicle,stationManagement.BRid,appParams.Nbeacons,simParams,appParams);
        
        % vector correctSCImatrixLTE created
        stationManagement.correctSCImatrixLTE = [];
        % vector sensedPowerByLteNo11p created (might remain void)
        sinrManagement.sensedPowerByLteNo11p = [];
    end

    % Initialization of lambda: SINR threshold for BRAlgorithm 9
    if simParams.BRAlgorithm==9
        stationManagement.lambdaLTE = phyParams.sinrThresholdLTE;
    end

    % Conversion of sensing power threshold when hidden node probability is active
    if outParams.printHiddenNodeProb
        %% TODO - needs update
        error('Not updated in v5');
        %if outParams.Pth_dBm==1000
        %    outParams.Pth_dBm = 10*log10(phyParams.gammaMin*phyParams.PnRB*(appParams.RBsBeacon/2))+30;
        %end
        %outParams.Pth = 10^((outParams.Pth_dBm-30)/10);
        %outParams.PthRB = outParams.Pth/(appParams.RBsBeacon/2);
    end
    
    % The next instant in LTE will be the beginning
    % of the first subframe in 0
    timeManagement.timeNextLTE = 0;
    timeManagement.subframeLTEstarts = true;

    % The channel busy ratio of LTE is initialized if used
    if outParams.printCBR
        sinrManagement.cbrLTE = zeros(simValues.maxID,1);
    else 
    % set to empty if not used
        sinrManagement.cbrLTE = [];
    end
end % end of if simParams.technology ~= 2 % not only 11p

% BRid set to -1 for non-LTE
stationManagement.BRid(stationManagement.vehicleState~=100)=-3;
