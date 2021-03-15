function printPowerControl(outputValues,outParams)
% Print to file the power control allocation occurencies
% [Tx power (dBm) - number of events - CDF]

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

filename = sprintf('%s/power_control_%.0f.xls',outParams.outputFolder,outParams.simID);
fileID = fopen(filename,'at');

NeventsTOT = sum(outputValues.powerControlCounter);

for i = 1:length(outputValues.powerControlCounter)
    fprintf(fileID,'%.2f\t%d\t%.6f\n',i*outParams.powerResolution-101,outputValues.powerControlCounter(i),sum(outputValues.powerControlCounter(1:i))/NeventsTOT);
end

fclose(fileID);

end