function  printHiddenNodeProb(outputValues,outParams)
% Print to file the hidden node probability
% [distance(m) - Nevents - hidden node probability]

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

filename = sprintf('%s/hiddenNodeProb_%.0f_%.0f.xls',outParams.outputFolder,outParams.simID,outParams.Pth_dBm);
fileID = fopen(filename,'at');

for i = 1:length(outputValues.hiddenNodeSumProb)
    fprintf(fileID,'%.0f\t%.0f\t%.6f\n',i,outputValues.hiddenNodeProbEvents(i),outputValues.hiddenNodeSumProb(i)/outputValues.hiddenNodeProbEvents(i));
end

fclose(fileID);

end