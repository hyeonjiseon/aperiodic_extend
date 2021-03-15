function printDelay(simParams,outputValues,outParams)
% Print to file the delay occurrences
% [delay (s) - number of events - CDF]

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

% Update delay
if outParams.printUpdateDelay
    if simParams.technology ~= 2 % not only 11p
        % outputValues.updateDelayCounterLTE needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.updateDelayCounterLTE(1,:)):-1:2
            outputValues.updateDelayCounterLTE(:,iPhyRaw) = outputValues.updateDelayCounterLTE(:,iPhyRaw)-outputValues.updateDelayCounterLTE(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/update_delay_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'LTE');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.updateDelayCounterLTE,1);
        for i = 1:length(outputValues.updateDelayCounterLTE(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.updateDelayCounterLTE(i,iPhyRaw),sum(outputValues.updateDelayCounterLTE(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.updateDelayCounterLTE(i,:)),sum(sum(outputValues.updateDelayCounterLTE(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);
    end
    if simParams.technology ~= 1 % not only LTE
        % outputValues.updateDelayCounter11p needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.updateDelayCounter11p(1,:)):-1:2
            outputValues.updateDelayCounter11p(:,iPhyRaw) = outputValues.updateDelayCounter11p(:,iPhyRaw)-outputValues.updateDelayCounter11p(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/update_delay_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'11p');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.updateDelayCounter11p,1);
        for i = 1:length(outputValues.updateDelayCounter11p(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.updateDelayCounter11p(i,iPhyRaw),sum(outputValues.updateDelayCounter11p(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.updateDelayCounter11p(i,:)),sum(sum(outputValues.updateDelayCounter11p(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);
    end
    
    % Wireless blind spot probability
    if outParams.printWirelessBlindSpotProb
        % Print to file the wireless blind spot probability
        % [Time interval - # delay events larger or equal than time interval - #
        % delay events shorter than time interval - wireless blind spot probability]
        filename = sprintf('%s/wireless_blind_spot_%.0f.xls',outParams.outputFolder,outParams.simID);
        fileID = fopen(filename,'at');
        for i = 1:length(outputValues.wirelessBlindSpotCounter)
            fprintf(fileID,'%.3f\t%d\t%d\t%.6f\n',outputValues.wirelessBlindSpotCounter(i,1),outputValues.wirelessBlindSpotCounter(i,2),outputValues.wirelessBlindSpotCounter(i,3),...
                outputValues.wirelessBlindSpotCounter(i,2)/(outputValues.wirelessBlindSpotCounter(i,2)+outputValues.wirelessBlindSpotCounter(i,3)));
        end
        fclose(fileID);  
    end
end

% Data Age
if outParams.printDataAge
    if simParams.technology ~= 2 % not only 11p
        % outputValues.dataAgeCounterLTE needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.dataAgeCounterLTE(1,:)):-1:2
            outputValues.dataAgeCounterLTE(:,iPhyRaw) = outputValues.dataAgeCounterLTE(:,iPhyRaw)-outputValues.dataAgeCounterLTE(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/data_age_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'LTE');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.dataAgeCounterLTE,1);
        for i = 1:length(outputValues.dataAgeCounterLTE(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.dataAgeCounterLTE(i,iPhyRaw),sum(outputValues.dataAgeCounterLTE(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.dataAgeCounterLTE(i,:)),sum(sum(outputValues.dataAgeCounterLTE(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);
    end
    
    if simParams.technology ~= 1 % not only LTE
        % outputValues.dataAgeCounter11p needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.dataAgeCounter11p(1,:)):-1:2
            outputValues.dataAgeCounter11p(:,iPhyRaw) = outputValues.dataAgeCounter11p(:,iPhyRaw)-outputValues.dataAgeCounter11p(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/data_age_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'11p');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.dataAgeCounter11p,1);
        for i = 1:length(outputValues.dataAgeCounter11p(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.dataAgeCounter11p(i,iPhyRaw),sum(outputValues.dataAgeCounter11p(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.dataAgeCounter11p(i,:)),sum(sum(outputValues.dataAgeCounter11p(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);
    end
end

% Packet delay
if outParams.printPacketDelay
    if simParams.technology ~= 2 % not only 11p
        % outputValues.packetDelayCounterLTE needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.packetDelayCounterLTE(1,:)):-1:2
            outputValues.packetDelayCounterLTE(:,iPhyRaw) = outputValues.packetDelayCounterLTE(:,iPhyRaw)-outputValues.packetDelayCounterLTE(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/packet_delay_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'LTE');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.packetDelayCounterLTE,1);
        for i = 1:length(outputValues.packetDelayCounterLTE(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.packetDelayCounterLTE(i,iPhyRaw),sum(outputValues.packetDelayCounterLTE(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.packetDelayCounterLTE(i,:)),sum(sum(outputValues.packetDelayCounterLTE(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);    
    end
    if simParams.technology ~= 1 % not only LTE
        % outputValues.packetDelayCounter11p needs elaboration
        % Now contains values up to each awareness range value; must
        % instead include teh values in each group
        for iPhyRaw=length(outputValues.packetDelayCounter11p(1,:)):-1:2
            outputValues.packetDelayCounter11p(:,iPhyRaw) = outputValues.packetDelayCounter11p(:,iPhyRaw)-outputValues.packetDelayCounter11p(:,iPhyRaw-1);
        end
        % Now the values can be print
        filename = sprintf('%s/packet_delay_%.0f_%s.xls',outParams.outputFolder,outParams.simID,'11p');
        fileID = fopen(filename,'at');
        NeventsTOT = sum(outputValues.packetDelayCounter11p,1);
        for i = 1:length(outputValues.packetDelayCounter11p(:,1))
            fprintf(fileID,'%.3f\t',i*outParams.delayResolution);
            for iPhyRaw=1:length(NeventsTOT)   
                fprintf(fileID,'%d\t%.6f',outputValues.packetDelayCounter11p(i,iPhyRaw),sum(outputValues.packetDelayCounter11p(1:i,iPhyRaw))/NeventsTOT(iPhyRaw));
                if length(NeventsTOT)>1
                    fprintf(fileID,'\t');
                else
                    fprintf(fileID,'\n');
                end
            end
            if length(NeventsTOT)>1
                fprintf(fileID,'%d\t%.6f\n',sum(outputValues.packetDelayCounter11p(i,:)),sum(sum(outputValues.packetDelayCounter11p(1:i,:),1))/sum(NeventsTOT(:)));
            end
        end
        fclose(fileID);    
    end
end

end

