close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

%LTEV2Vsim('help');

%% LTE Autonomous (3GPP Mode 4) - on a subframe basis
% Autonomous allocation algorithm defined in 3GPP standard
%density = [200, 400, 600, 800];
density = 200;
for i = 1:length(density)
    LTEV2Vsim('BenchmarkPoisson.cfg','simulationTime',40,'roadLength', 3000, 'rho', density(i),...
        'BRAlgorithm',18,'probResKeep',0);
end
%'MCS_LTE', 7, 'printCBR', true