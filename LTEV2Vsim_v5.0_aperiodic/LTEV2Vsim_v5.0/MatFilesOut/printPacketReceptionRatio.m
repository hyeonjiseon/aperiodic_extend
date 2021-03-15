function printPacketReceptionRatio(tag,distanceDetailsCounter,outParams,appParams,simParams)
% Print to file Rx details vs. distance up to Raw Max

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

% #Neighbors within i meters
distanceDetailsCounter(:,5) = distanceDetailsCounter(:,2) + distanceDetailsCounter(:,3) + distanceDetailsCounter(:,4);

% If variable beacon size is selected (currently only for 11p)
if simParams.technology==2 && appParams.variableBeaconSize
    distanceDetailsCounter(:,9) = distanceDetailsCounter(:,6) + distanceDetailsCounter(:,7) + distanceDetailsCounter(:,8);
end

for j=length(distanceDetailsCounter(:,1)):-1:2
    distanceDetailsCounter(j,2:end) = distanceDetailsCounter(j,2:end) - distanceDetailsCounter(j-1,2:end);
end

filename = sprintf('%s/packet_reception_ratio_%.0f_%s.xls',outParams.outputFolder,outParams.simID,tag);
fileID = fopen(filename,'at');

if simParams.technology==2 && appParams.variableBeaconSize
    % If variable beacon size is selected (currently only for 11p)
        for i = 1:length(distanceDetailsCounter(:,1))
            fprintf(fileID,'%d\t%d\t%d\t%d\t%d\t%f\t%d\t%d\t%d\t%d\t%f\n',...
                distanceDetailsCounter(i,1),distanceDetailsCounter(i,2),distanceDetailsCounter(i,3),distanceDetailsCounter(i,4),distanceDetailsCounter(i,5),distanceDetailsCounter(i,2)/distanceDetailsCounter(i,5),...
                distanceDetailsCounter(i,6),distanceDetailsCounter(i,7),distanceDetailsCounter(i,8),distanceDetailsCounter(i,9),distanceDetailsCounter(i,6)/distanceDetailsCounter(i,9));
        end
else
    % If constant beacon size is selected
    for i = 1:length(distanceDetailsCounter(:,1))
        fprintf(fileID,'%d\t%d\t%d\t%d\t%d\t%f\n',...
            distanceDetailsCounter(i,1),distanceDetailsCounter(i,2),distanceDetailsCounter(i,3),distanceDetailsCounter(i,4),distanceDetailsCounter(i,5),distanceDetailsCounter(i,2)/distanceDetailsCounter(i,5));
    end
end

fclose(fileID);

end
