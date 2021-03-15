function [simValues,simParams] = interpolateTrace(dataOrig,simParams,Tbeacon)
% This function interpolates the input traffic trace with the desired output 
% time interval 
% Inputs: the original file 'dataOrig' and the desired interval 'simValues.timeResolution'
% Outputs: the interpolated file
% The input file should be in the form of rows with four columns indicating
% 1) the time instant, 2) the vehicle ID, 3) its x-position, 4) its
% y-position
% The position of each vehicle is expected to be updated every time
% interval; such time interval must be constant and is derived by the function 
% internally 
% The output file has the same format
% If a vehicle is present only in one instant in the input file, that
% vehicle is neglected in the output
% The time interval set for the output should be an integer fraction of 
% the input interal, and is adjusted otherwise; if it is not smaller than the 
% interval of the input time, then the input file is returned directly

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

if simParams.positionTimeResolution<Tbeacon
    fprintf('The selected time resolution is smaller than the beacon period.\n');
    simParams.positionTimeResolution = Tbeacon;
    fprintf('For this reason, positionTimeResolution is set to %fs\n',simParams.positionTimeResolution);
end

% The input time interval is derived from the input file
deltaTorig = max(dataOrig(2:end,1)-dataOrig(1:end-1,1));

% If resolution in data file is better than needed, just return
if simParams.positionTimeResolution > deltaTorig
    simValues.timeResolution = simParams.positionTimeResolution;
    simValues.dataTrace = dataOrig;
    return;
end

% The time interval set for the output should be an integer fraction of 
% the input interval, and is adjusted otherwise using the ceil function
interpFactor = round(deltaTorig/simParams.positionTimeResolution);
if simParams.positionTimeResolution*interpFactor < deltaTorig-1e-9 || simParams.positionTimeResolution*interpFactor > deltaTorig+1e-9
    error('Error in interpolateTrace. Attempt to interpolate not with an integer number: deltaTorig=%.2f, positionTimeResolution=%.2f',deltaTorig,simParams.positionTimeResolution);
end    
simValues.timeResolution = deltaTorig/interpFactor;
simParams.positionTimeResolution = simValues.timeResolution;

% If the output time interval is not smaller than the interval of the input 
% time, then the input file is returned directly
if interpFactor==1
    simValues.dataTrace = dataOrig;
    return;
end

fprintf('Interpolating Trace File\n');

tic

% Vectors are set to speed up processing
t = dataOrig(:,1);
id = dataOrig(:,2);
xV = dataOrig(:,3);
yV = dataOrig(:,4);

% For speed reasons, the output matrix is initialized larger than needed
% It will be later reduced to what strictly required 
n = length(id);
dataAll = zeros(interpFactor * n,4);

% Cycle among the vehicles in the trace
startIndex = 1;
for idToCheck = min(dataOrig(:,2)):max(dataOrig(:,2))
  
    % IDs of vehicles that are not present or only compare in one instant
    % are skipped
    if  nnz(dataOrig(:,2)==idToCheck)>1
        % Vectors that focus on a specific vehicle
        tCheck = t(id==idToCheck);
        xCheck = xV(id==idToCheck);
        yCheck = yV(id==idToCheck);
        
        % Vectors related to those instants when the vehicle does not move 
        movingV = (xCheck(2:end)-xCheck(1:end-1))~=0 | (yCheck(2:end)-yCheck(1:end-1))~=0;
        indexes = find(movingV==0);
        
        % This if considers the case when a vehicle never moves
        if nnz(movingV)>0
            % Interpolation, excluding those instants when the vehicle does not move 
            tparz=tCheck(1):tCheck(nnz(movingV)+1);
            xparz=[xCheck(movingV~=0); xCheck(end)];
            yparz=[yCheck(movingV~=0); yCheck(end)];
            tq = tparz(1):simValues.timeResolution:tparz(end);
            xq = interp1(tparz,xparz,tq,'spline');
            yq = interp1(tparz,yparz,tq,'spline');
        else
            % Initializations of xq and yq if the vehicle never moves
            xq = xCheck(end);
            yq = yCheck(end);
        end
            
        % Re-addition of the instants when the vehicle does not move , with
        % the output time interval
        for i=1:length(indexes)
            xq = [xq(1:(indexes(i)-1)*interpFactor) xq((indexes(i)-1)*interpFactor+1)*ones(1,interpFactor) xq((indexes(i)-1)*interpFactor+1:end)];
            yq = [yq(1:(indexes(i)-1)*interpFactor) yq((indexes(i)-1)*interpFactor+1)*ones(1,interpFactor) yq((indexes(i)-1)*interpFactor+1:end)];
        end
        tq = tCheck(1):simValues.timeResolution:tCheck(end);       
        
        % Concatenation to the previous vehicles
        endIndex = startIndex + length(tq) - 1;        
        dataAll(startIndex:endIndex,1) = tq;
        dataAll(startIndex:endIndex,2) = idToCheck;
        dataAll(startIndex:endIndex,3) = xq;
        dataAll(startIndex:endIndex,4) = yq;
        startIndex = endIndex+1;
    end
end
% Removal of null lines in dataAll (dataAll was initialized to larger than
% needed for speed purposes)
delIndex = (dataAll(:,2)==0);
dataAll(delIndex,:) = [];
% Sort of the output file along the time (it was sorted along the vehicle ID)
simValues.dataTrace = sortrows(dataAll,1);

toc

end