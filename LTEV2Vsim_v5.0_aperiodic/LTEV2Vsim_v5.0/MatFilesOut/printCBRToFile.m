function printCBRToFile(CBRvalues,outParams,finalPrint)
% Print number of neighbors per vehicle at each snapshot for traffic trace
% analysis (CDF plot)

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

persistent cbrOutValuesVector;
if isempty(cbrOutValuesVector)
    cbrOutValuesVector = zeros(1,10000);
end
persistent cbrOutValuesCounter;
if isempty(cbrOutValuesCounter)
    cbrOutValuesCounter = 0;
end

for k = 1:length(CBRvalues)
    cbrOutValuesCounter = cbrOutValuesCounter + 1;
    cbrOutValuesVector(cbrOutValuesCounter) = CBRvalues(k);
    
    if cbrOutValuesCounter == 10000
        filename9 = sprintf('%s/CBRstatistic_%.0f.xls',outParams.outputFolder,outParams.simID);
        fileID = fopen(filename9,'at');
        for i=1:cbrOutValuesCounter
            fprintf(fileID,'%d\n',cbrOutValuesVector(i));
        end
        fclose(fileID);
        cbrOutValuesVector = zeros(1,10000);
        cbrOutValuesCounter = 0;
    end
end

if finalPrint
    filename9 = sprintf('%s/CBRstatistic_%.0f.xls',outParams.outputFolder,outParams.simID);
    fileID = fopen(filename9,'at');
    for i=1:cbrOutValuesCounter
        fprintf(fileID,'%d\n',cbrOutValuesVector(i));
    end
    fclose(fileID);
    values = load(filename9);
    [F,X] = ecdf(values);
    fileID = fopen(filename9,'w');
    for i=1:length(F)
        fprintf(fileID,'%f\t%f\n',X(i),F(i));
    end
    fclose(fileID);
end

