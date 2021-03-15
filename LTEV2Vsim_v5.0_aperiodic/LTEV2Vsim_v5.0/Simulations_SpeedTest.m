close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

%%% HELP FOR THE SIMULATOR
% LTEV2Vsim('help');

%%% CONFIGURATION FILE
% Highway scenario (PPP)
configFile = 'HighwayPPP.cfg';

%%% SIMULATION DURATION
T = 5; % s
% The assumption is that the simulation duration is proportional to the
% simulated time, which is reasonable for a fixed number of vehicles

% Road length
roadlength_m = 1000; %m

% Output folder
outputFolder = 'Output_SpeedTest';

% Varying the number of vehicles
for nVehicles = 50:50:300 

    % The density is derived
    density_vkm = nVehicles / (roadlength_m/1000); % veh/km

    % The LTE-V2V case 
    LTEV2Vsim(configFile,'outputFolder',outputFolder,'simulationTime',T,...
        'BRAlgorithm',18,'probResKeep',0,...
        'rho',density_vkm,'roadLength',roadlength_m);

    % The IEEE 802.11p case 
    LTEV2Vsim(configFile,'outputFolder',outputFolder,'simulationTime',T,...
        'Technology','80211p',...
        'rho',density_vkm,'roadLength',roadlength_m);

end