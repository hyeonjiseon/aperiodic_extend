close all
clear
clc

% Flag to print the output in a jpeg file
printJpgOn = true;

% Simulated time in each simulation
simTime = 5;

% Main output file 
mainFileName = sprintf('Output_SpeedTest/MainOut.xls');
% The file contains 26 columns
% Simulated duration is the 5th column, simulation duration is the 6th
% column
fid = fopen(mainFileName,'r');
if fid==-1
    error('File not found');
else
    fclose(fid);
    C = textread(mainFileName, '%s','delimiter', '\t');
    simDuration = zeros(floor(length(C)/41)-1,1);
    for i=1:(floor(length(C)/41)-1)
        if str2double(C(i*41+5))~=simTime
            error('simTime not correct');
        end
        simDuration(i) = str2double(C(i*41+6));
    end
end

% Duration per second
simPerSec = [simDuration(1:3:end)/simTime simDuration(3:3:end)/simTime simDuration(2:3:end)/simTime];

% Output bar figure
figure1 = figure(1);
axes1 = axes('Parent',figure1);
bar(simPerSec)
grid on
% Set the remaining axes properties
set(axes1,'XTick',[1 2 3 4 5 6 7 8 9 10],'XTickLabel',...
    {'50','100','150','200','250','300','350','400','450','500'});%,...
%    'YScale','log');
xlabel('Simulated vehicles');
ylabel('Simulation duration per each simulated second [s]');
legend('Only LTE','Only 11p','Coexistence 50%-50%','Location','NorthWest');

% Print to jpeg file
if printJpgOn
    strOutFile = sprintf('Fig_speed_test.jpg');
    print(strOutFile, '-djpeg')
end

