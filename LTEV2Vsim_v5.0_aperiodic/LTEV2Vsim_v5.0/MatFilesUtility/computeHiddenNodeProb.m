function [hiddenNodeSumProb,hiddenNodeProbEvents] = computeHiddenNodeProb(IDvehicle,distance,RXpower,gammaMin,Pn,Pth,hiddenNodeSumProb,hiddenNodeProbEvents)
% Function to update hidden node probability

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

% Number of vehicles (set A)
Aset = find(IDvehicle);

% Find maximum recording distance (m)
maxDist = length(hiddenNodeSumProb);

% Check transmitters (A)
for A = Aset'
    % ID of the transmitter
    IDtx = IDvehicle(A);
    % Find potential receivers (set B)
    Bset = find((RXpower(A,:)/Pn)>gammaMin);
    % Check potential receivers (B)
    for B = Bset
        % ID of the receiver
        IDrx = IDvehicle(B);
        % Distance between A and B
        distAB = floor(distance(A,B))+1;
        % Limit maximum distance
        if distAB>=maxDist
            distAB = maxDist;
        end
        if IDtx~=IDrx
            % Reset counters for hidden and non-hidden nodes
            hiddenNodes = 0;
            nonHiddenNodes = 0;
            % Find all potential interferers (Cset)
            Cset = find(IDvehicle~=IDtx & IDvehicle~=IDrx);
            for C = Cset'
                % Compute SINR considering interferer C
                SINR = RXpower(A,B)/(Pn+RXpower(C,B));
                % If computed SINR is lower than the minimum threshold
                if SINR<gammaMin
                    % If interfering power from C to A is higher than the
                    % sensing power threshold
                    if RXpower(C,A)>Pth
                        % Increment non hidden counter
                        nonHiddenNodes = nonHiddenNodes+1;
                    else
                        % Increment hidden counter
                        hiddenNodes = hiddenNodes+1;
                    end
                end
            end
            if hiddenNodes~=0 && nonHiddenNodes~=0
                % Update array for hidden node probability computation
                hiddenNodeSumProb(distAB) = hiddenNodeSumProb(distAB) + hiddenNodes/(hiddenNodes+nonHiddenNodes);
            end
            % Increment number of events
            hiddenNodeProbEvents(distAB) = hiddenNodeProbEvents(distAB)+1;
        end
    end
end
end
