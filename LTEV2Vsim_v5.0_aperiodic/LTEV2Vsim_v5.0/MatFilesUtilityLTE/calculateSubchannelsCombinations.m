function completeSizeSubchannel = calculateSubchannelsCombinations(supportedSizeSubchannel,RBsFrequencyV2V,ifAdjacent)
% Function to calculate all combinations of subchannels

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

% Pre-allocate vector (better code performance)
% First column: RBs per subchannels or multiple
% Second column: subchannel size
% Third column: number of subchannels
completeSizeSubchannel = zeros(length(supportedSizeSubchannel)*(supportedSizeSubchannel(end)/supportedSizeSubchannel(1)),3);

% Complete vector of subchannel sizes with multiples up to the number of RBs per Tslot
k = 1;
for i = 1:length(supportedSizeSubchannel)
    n = 1;
    multiple = 0;
    while multiple<RBsFrequencyV2V
        multiple = supportedSizeSubchannel(i)*n;
        while ~isValidForFFT(multiple - 2 * ifAdjacent)
            multiple = multiple-1;
        end
        if ifAdjacent
            % If adjacent configuration is selected, SCI is included in the beacon size
            limit = RBsFrequencyV2V;
        else
            % If non-adjacent configuration is selected, SCI is always allocated in a separate pool
            limit = RBsFrequencyV2V - 2*n;
        end
        if multiple<=limit
            completeSizeSubchannel(k,1) = multiple;
            completeSizeSubchannel(k,2) = supportedSizeSubchannel(i);
            completeSizeSubchannel(k,3) = n;
            k = k+1;
        else
            break
        end
        n = n+1;
    end
end

% Delete zero values
delIndex = completeSizeSubchannel(:,1)==0;
completeSizeSubchannel(delIndex,:) = [];

end