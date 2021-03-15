function [phyParams] = deriveRanges(phyParams,simParams)
% Derive maximum awareness range and other ranges according to the selected algorithm

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
   
if simParams.technology ~= 1 % not only LTE 
    phyParams.RawMaxLOS11p = ((phyParams.P_ERP_MHz_11p*phyParams.Gr)/(phyParams.sinrThreshold11p*phyParams.L0_far*phyParams.Pnoise_MHz))^(1/phyParams.b_far);
    phyParams.RawMaxNLOS11p = ((phyParams.P_ERP_MHz_11p*phyParams.Gr)/(phyParams.sinrThreshold11p*phyParams.L0_NLOS*phyParams.Pnoise_MHz))^(1/phyParams.b_NLOS);
    % Compute maximum range with 2 times standard deviation of shadowing in LOS (m)
    phyParams.RawMax11p =  phyParams.RawMaxLOS11p * 10^((2*phyParams.stdDevShadowLOS_dB)/(10*phyParams.b_far));

    if phyParams.Raw(end) > phyParams.RawMax11p
        error('Max Raw > RawMax11p not yet considered');
    %    fprintf('The awareness range exceeds the maximum possible one of 11p: ');
    %    phyParams.Raw = phyParams.RawMax11p;
    %    fprintf('set to %.0f m\n\n', phyParams.Raw);
    end
end

if simParams.technology ~= 2 % not only 11p
    phyParams.RawMaxLOSLTE = ((phyParams.P_ERP_MHz_LTE*phyParams.Gr)/(phyParams.sinrThresholdLTE*phyParams.L0_far*phyParams.Pnoise_MHz))^(1/phyParams.b_far);
    phyParams.RawMaxNLOSLTE = ((phyParams.P_ERP_MHz_LTE*phyParams.Gr)/(phyParams.sinrThresholdLTE*phyParams.L0_NLOS*phyParams.Pnoise_MHz))^(1/phyParams.b_NLOS);
    % Compute maximum range with 2 times standard deviation of shadowing in LOS (m)
    phyParams.RawMaxLTE =  phyParams.RawMaxLOSLTE * 10^((2*phyParams.stdDevShadowLOS_dB)/(10*phyParams.b_far));

    if phyParams.Raw(end) > phyParams.RawMaxLTE
        error('Max Raw > RawMaxLTE not yet considered');
    %    fprintf('The awareness range LTE exceeds the maximum possible one of LTE: ');
    %    phyParams.Raw = phyParams.RawMaxLTE;
    %    fprintf('set to %.0f m\n\n', phyParams.Raw);
    end
    
    % R reuse for some allocation algorithms
    if simParams.BRAlgorithm==2
        % Compute minimum reuse distance (m)
        Rreuse1 = phyParams.Raw(end) + phyParams.Raw(end)/(((1/phyParams.sinrThresholdLTE)-(phyParams.Pnoise_MHz/phyParams.P_ERP_MHz_LTE)*(phyParams.L0_far*phyParams.Raw^phyParams.b_far)/phyParams.Gr)^(1/phyParams.b_far));
        RreuseMin = max([Rreuse1 2*phyParams.Raw(end)]);
        
        % Reuse distance (m)
        phyParams.Rreuse = RreuseMin + simParams.Mreuse;        
    end
    
end

end
