function printPRRmapToFile(simValues,simParams,outParams,positionManagement)
% Print PRRmap to image file

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

% Find size of PRRmap
[Nrows, Ncolumns] = size(positionManagement.GridMap);

% Convert limits to map coordinates (if needed)
if simParams.XminTrace <= positionManagement.XminMap
    XminTraceMap = 1;
else
    [XminTraceMap,~] = convertToGrid(simParams.XminTrace,0,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap);
end

if simParams.YminTrace <= positionManagement.YminMap
    YminTraceMap = Nrows;
else 
    [~,YminTraceMap] = convertToGrid(0,simParams.YminTrace,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap);
end

if simParams.XmaxTrace < 0 || simParams.XmaxTrace >= positionManagement.XmaxMap
    XmaxTraceMap = Ncolumns;
else
    [XmaxTraceMap,~] = convertToGrid(simParams.XmaxTrace,0,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap);
end

if simParams.YmaxTrace < 0 || simParams.YmaxTrace >= positionManagement.YmaxMap
    YmaxTraceMap = 1;
else
    [~,YmaxTraceMap] = convertToGrid(0,simParams.YmaxTrace,positionManagement.XminMap,positionManagement.YmaxMap,positionManagement.StepMap);
end

% Cut the map files
positionManagement.GridMap = positionManagement.GridMap(floor(YmaxTraceMap):ceil(YminTraceMap),floor(XminTraceMap):ceil(XmaxTraceMap));
simValues.neighborsMap11p = simValues.neighborsMap11p(floor(YmaxTraceMap):ceil(YminTraceMap),floor(XminTraceMap):ceil(XmaxTraceMap));
simValues.correctlyReceivedMap11p = simValues.correctlyReceivedMap11p(floor(YmaxTraceMap):ceil(YminTraceMap),floor(XminTraceMap):ceil(XmaxTraceMap));
simValues.neighborsMapLTE = simValues.neighborsMapLTE(floor(YmaxTraceMap):ceil(YminTraceMap),floor(XminTraceMap):ceil(XmaxTraceMap));
simValues.correctlyReceivedMapLTE = simValues.correctlyReceivedMapLTE(floor(YmaxTraceMap):ceil(YminTraceMap),floor(XminTraceMap):ceil(XmaxTraceMap));

% Set -1 as #neighbors where there are no neighbors
noneighbors11p = (simValues.neighborsMap11p==0);
simValues.neighborsMap11p(noneighbors11p)=-1;
noneighborsLTE = (simValues.neighborsMapLTE==0);
simValues.neighborsMapLTE(noneighborsLTE)=-1;

% [Linear scale version]
% Create PRRMap matrix
% Set 1 as #correctly received beacons where there are no neighbors 
%simValues.correctlyReceivedMap(A)=1;
%PRRmap = (simValues.correctlyReceivedMap./simValues.neighborsMap).*positionManagement.GridMap-1.*(1-positionManagement.GridMap);

% [Non-linear scale]
% Create PRRMap matrix
PRRvalues11p = (simValues.correctlyReceivedMap11p./simValues.neighborsMap11p);
PRRmap11p = real(((1-sqrt(1-PRRvalues11p.^2))).*(1-noneighbors11p)-1.*noneighbors11p);
PRRvaluesLTE = (simValues.correctlyReceivedMapLTE./simValues.neighborsMapLTE);
PRRmapLTE = real(((1-sqrt(1-PRRvaluesLTE.^2))).*(1-noneighborsLTE)-1.*noneighborsLTE);

if simParams.technology ~= 2 % not only 11p
    % Print PRRMap to file
    filename = sprintf('%s/PRRmap_%.0f_%s.png',outParams.outputFolder,outParams.simID,'LTE');
    createMap(positionManagement.GridMap,PRRmapLTE,filename);
end
if simParams.technology ~= 1 % not only LTE
    % Print PRRMap to file
    filename = sprintf('%s/PRRmap_%.0f_%s.png',outParams.outputFolder,outParams.simID,'11p');
    createMap(positionManagement.GridMap,PRRmap11p,filename);
end    

end
