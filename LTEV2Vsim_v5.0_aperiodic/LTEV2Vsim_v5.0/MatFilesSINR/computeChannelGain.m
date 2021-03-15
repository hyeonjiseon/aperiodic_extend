function [CHgain,Shadowing_dB,X,Y] = computeChannelGain(sinrManagement,positionManagement,phyParams,simParams,dUpdate)
% Compute received power and create RXpower matrix

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

%% Initialization
distance = positionManagement.distanceReal;
Nvehicles = length(distance(:,1));   % Number of vehicles
LOS = ones(Nvehicles,Nvehicles);
if ~phyParams.winnerModel
    A = ones(Nvehicles,Nvehicles);
end

%% Supplementary attenuation in the case of NLOS conditions
% If the MAP is not present, highway scenario is assumed; only LOS
% If the MAP is present, urban scenario is assumed and NLOS is calculated
if (~simParams.fileObstaclesMap)
    D_corr = 25;         % Decorrelation distance for the shadowing calculation
    
    X = 0;
    Y = 0;
else    
    D_corr = 10;           % Decorrelation distance for the shadowing calculation
    
    % Convert coordinates to grid
    [X,Y] = convertToGrid(positionManagement.XvehicleReal,positionManagement.YvehicleReal,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap);
    
    % Compute attenuation due to walls and buildings
    for i = 1:Nvehicles
        if positionManagement.XvehicleReal(i)~=Inf
            for j = i+1:Nvehicles
                if positionManagement.XvehicleReal(j)~=Inf
                    [Nwalls,Nsteps,granularity] = computeGrid(X(i),Y(i),X(j),Y(j),positionManagement.StepMap,positionManagement.GridMap,phyParams.winnerModel);
                    if phyParams.winnerModel
                        LOS(i,j) = 1-(Nwalls>0);
                        LOS(j,i) = LOS(i,j);
                    else
                        % in non-winner, the supplementary attenuation is
                        % calculated
                        A(i,j) = (phyParams.Awall^Nwalls)*(phyParams.Abuild^(Nsteps*granularity));
                        A(j,i) = A(i,j);
                    end
                end
            end
        end
    end
end

%% Path loss calculation
PL = (LOS>0).*((distance<=phyParams.d_threshold).*(phyParams.L0_near * (distance.^phyParams.b_near))+...
    (distance>phyParams.d_threshold).*(phyParams.L0_far * (distance.^phyParams.b_far)))+...
    (LOS==0).*(phyParams.L0_NLOS * (distance.^phyParams.b_NLOS));

%% LOS derivation in case of non-winner model
if ~phyParams.winnerModel
    PL = PL./A;
    % In non-winner model, LOS was set to 1 not to modify the PL
    % Now LOS needs to be correctly set for the shadowing calculation
    % The values of the matrix A are 1 if LOS and higher than 1 if NLOS
    LOS = (A<=1);
end    

%% Computatiomn of the channel gain
% Call function to calculate shadowing
Shadowing_dB = computeShadowing(sinrManagement.Shadowing_dB,LOS,dUpdate,phyParams.stdDevShadowLOS_dB,phyParams.stdDevShadowNLOS_dB,D_corr);
Shadowing = 10.^(Shadowing_dB/10);

% Compute channel gain with shadowing
CHgain = Shadowing./PL;

end