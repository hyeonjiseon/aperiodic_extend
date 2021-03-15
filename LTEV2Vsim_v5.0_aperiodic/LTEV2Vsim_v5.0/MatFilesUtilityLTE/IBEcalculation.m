function IBEmatrix = IBEcalculation(phyParams,appParams)
% This function computes the In-Band Emission Matrix, following 
% the model reported in 3GPP TS 36.101 V15.0.0

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

%%
% Uncomment the following two lines to remove IBE
%IBEmatrix = eye(appParams.NbeaconsF,appParams.NbeaconsF);
%return
%%

%% START PLOT1 AND PLOT2
%activePlots = false;
%% STOP PLOT1 AND PLOT2

%% Inizialization of variables from phyParams and appParams
%
% N_RB_tot is the total bandwidth in terms of RBs
N_RB_tot = phyParams.RBsSubframe/2;

% N_RB_beacon is the bandwidth of a beacon in terms of RBs
N_RB_beacon = appParams.RBsBeacon/2;

% Number of beacons in a subframe
nBeaconPerSubframe = appParams.NbeaconsF;

% Number of RBs of the channel(s) (might be more than one) that allocate
% one beacon
nRBofSubchAllocatingOneBeacon = phyParams.RBsBeaconSubchannel;

% Number of subchannles, adopted MCS, adjacent/non-adjacent
% allocation
nSubchannels = phyParams.NsubchannelsFrequency;
MCS = phyParams.MCS_LTE;
ifAdjacent = phyParams.ifAdjacent;
%% 

%%
% Setting of the parameters
% Parameters W,X,Y,Z
W = 3;
X = 6;
Y = 3;
Z = 3;
% EVM
if MCS >= 0 && MCS <= 10
    % BPSK-QPSK
    EVM = 0.175;
elseif MCS <= 20
    % 16-QAM
    EVM = 0.125;
else
    error('MCS in IBEcalculation() not valid. MCS must be in 0-20');
end

% If nBeaconPerSubframe is 1, there cannot be IBE and the IBEmatrix is set to 1
% If nBeaconPerSubframe is 0, it means that more than one subbrframe
% is needed to allocate a beacon; also in such case, IBEmatrix must be set to 1
if nBeaconPerSubframe==1 || nBeaconPerSubframe==0
    IBEmatrix = 1;
    return
end
%%

%%
% Initialization
IBEmatrix = ones(nBeaconPerSubframe,nBeaconPerSubframe);
startRB = -1*ones(1,nBeaconPerSubframe);
stopRB = -1*ones(1,nBeaconPerSubframe);

rbPerGap = (nRBofSubchAllocatingOneBeacon-N_RB_beacon)*ones(1,nBeaconPerSubframe-1);
%%

% Setting the start and end of each beacon resource
%%%% START PLOT1
% if activePlots
%     figure(101);
%     plot([1 N_RB_tot],[1 1],'--r');
%     hold on
% end
%%%% END PLOT1
startRB(1) = nSubchannels*2*(1-(ifAdjacent))+2*(ifAdjacent)+1;
stopRB(1) = nSubchannels*2*(1-(ifAdjacent))+2*(ifAdjacent)+N_RB_beacon;
%%%% START PLOT1
% if activePlots
%     plot(startRB(1):stopRB(1),ones(1,N_RB_beacon),'ok');
% end
%%%% STOP PLOT1
for i=2:nBeaconPerSubframe
    startRB(i) = stopRB(i-1)+rbPerGap(i-1)+1;
    stopRB(i) = startRB(i)+N_RB_beacon-1;
    %%%% START PLOT1
%     if activePlots
%         plot(stopRB(i-1)+1:startRB(i)-1,zeros(1,rbPerGap(i-1)),'pb');
%         plot(startRB(i):stopRB(i),ones(1,N_RB_beacon),'ob');
%     end
    %%%% STOP PLOT1
end
%%

%%
% Calculating the IBE
%%%% START PLOT2
% if activePlots
%     int1Plot = -50*ones(1,N_RB_tot);
%     int2Plot = -50*ones(1,N_RB_tot);
% end
%%%% STOP PLOT2
for iBeacon1 = 1:nBeaconPerSubframe
    for iBeacon2 = 1:nBeaconPerSubframe
        % From interferer iBeacon2 to useful iBeacon1
        if iBeacon1~=iBeacon2
            % Setting the bandwidth of the interfering signal
            L_CRB = stopRB(iBeacon2)-startRB(iBeacon2)+1;            
            interference = 0;
            for rbIndex=startRB(iBeacon1):stopRB(iBeacon1) % in the interfered window
                %
                % 1) GENERAL PART
                % Setting the gap Delta_RB betweeen interfering and useful signals
                % if iBeacon2>iBeacon1:     Delta_RB = max(startRB(iBeacon2)-rbIndex
                % else:                     Delta_RB = rbIndex-stopRB(iBeacon2))
                % The same is obtained using a max() function
                Delta_RB = max(startRB(iBeacon2)-rbIndex, rbIndex-stopRB(iBeacon2));
                % Interference calculation
                % P_RB_dBm is fixed to the maximum, -30 dB, as per the
                % NOTE 1 of 3GPP 36.101 (Table 6.5.2A.3.1-1)
                P_RB_dBm = 0;
                interferenceG_dB = max(max( -25-10*log10(N_RB_tot/L_CRB)-X,20*log10(EVM)-3-5*(abs(Delta_RB)-1)/L_CRB-W),(-57/180e3-P_RB_dBm-X)-30);
                interferenceG = 10^( interferenceG_dB/10 );
                %
                % 2) IQ IMAGE
                % Find the image of the rbIndex, looking at nRBperSubframeTot
                rbImage = (N_RB_tot-(rbIndex)+1); 
                if rbImage>=startRB(iBeacon2) && rbImage<=stopRB(iBeacon2)
                    interferenceIQ = 10^( (-25-Y)/10 ); 
                else
                    interferenceIQ = 0;
                end
                %
                % 3) CARRIER LEACKAGE
                interferenceCL = 0;
                if mod(N_RB_tot,2)==1 % ODD (TOT): one RB
                    if rbIndex==ceil(N_RB_tot/2)
                       interferenceCL = 10^( (-25-Z)/10 ); 
                    end  
                else % EVEN (TOT): two RBs
                    if rbIndex==ceil(N_RB_tot/2)-1 || rbIndex==ceil(N_RB_tot/2)
                       interferenceCL = 10^( (-25-Z)/10 ); 
                    end  
                end
                % OPTION1: Maximum between the sum and P_RB_dBm-30
                %interference = interference + max(10^((P_RB_dBm-30)/10),interferenceG+interferenceIQ+interferenceCL);
                % OPTION2: Directly the sum
                interference = interference + interferenceG+interferenceIQ+interferenceCL;
                %%%% START PLOT2
%                 if activePlots
%                     if iBeacon2==1
%                        int1Plot(rbIndex) = 10 * log10(interferenceG+interferenceIQ+interferenceCL);
%                     end
%                     if iBeacon2==2
%                        int2Plot(rbIndex) = 10 * log10(interferenceG+interferenceIQ+interferenceCL);
%                     end
%                 end
                %%%% STOP PLOT2
            end    
            % Average over the allocated bandwidth
            interference = interference/(stopRB(iBeacon1)-startRB(iBeacon1)+1);
            IBEmatrix(iBeacon1,iBeacon2) = interference;
        end
    end
end
%%

%%%% START PLOT2
% if activePlots
%     figure(102);
%     %plot(1:nRBperSubframeToAlloc,int1Plot,'ok');
%     plot(1:length(int1Plot),int1Plot,'ok-');
%     hold on
%     grid on
%     %plot(1:nRBperSubframeToAlloc,int2Plot,'pr');
%     plot(1:length(int2Plot),int2Plot,'pr-');
% end
%%%% STOP PLOT1

end

