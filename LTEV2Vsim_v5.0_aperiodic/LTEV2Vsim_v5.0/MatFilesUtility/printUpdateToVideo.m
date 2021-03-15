function reverseStr = printUpdateToVideo(elapsedTime,simTime,reverseStr)
% Function to print time to video and estimate end of simulation

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

elapsedSeconds = toc;
remainingSeconds = elapsedSeconds * (simTime-elapsedTime)/elapsedTime;
remainingDays = floor(remainingSeconds/(60*60*24));
remainingSeconds = remainingSeconds - (remainingDays*60*60*24);
remainingHours = floor(remainingSeconds/(60*60));
remainingSeconds = remainingSeconds - (remainingHours*60*60);
remainingMinutes = floor(remainingSeconds/(60));
remainingSeconds = remainingSeconds - (remainingMinutes*60);
msg = sprintf('%.1f / %.1fs, end estimated in',elapsedTime,simTime);
if remainingDays>0
    sTemp = sprintf(' %d days, %d hours',remainingDays,remainingHours);
    msg = strcat(msg,sTemp);
elseif remainingHours>0
    sTemp = sprintf(' %d hours, %d minutes',remainingHours,remainingMinutes);
    msg = strcat(msg,sTemp);
elseif remainingMinutes>0
    sTemp = sprintf(' %d minutes, %d seconds',remainingMinutes,ceil(remainingSeconds));
    msg = strcat(msg,sTemp);
else
    sTemp = sprintf(' %d seconds',ceil(remainingSeconds));
    msg = strcat(msg,sTemp);
end
fprintf([reverseStr, msg]);
reverseStr = repmat(sprintf('\b'), 1, length(msg));


