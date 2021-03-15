function printDebugBackoff11p(Time,StringOfEvent,idEvent,stationManagement)
% Print of: Time, event description, then per each station:
% ID, technology, state, current SINR (if LTE, first neighbor), useful power (if LTE, first neighbor),
% interfering power (if LTE, first neighbor), interfering power from
% the other technology (if LTE, first neighbor)

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

return;

fid = fopen('Filebackoff11p.xls','r');
if fid==-1
    fid = fopen('Filebackoff11p.xls','w');
    fprintf(fid,'Time\tEvent\tVehicle\tBackoffCounter\n');
end
fclose(fid);

fid = fopen('Filebackoff11p.xls','a');
fprintf(fid,'%3.6f\t%s\t%d\t%d\n',Time,StringOfEvent,idEvent,stationManagement.nSlotBackoff11p(idEvent));
fclose(fid);

