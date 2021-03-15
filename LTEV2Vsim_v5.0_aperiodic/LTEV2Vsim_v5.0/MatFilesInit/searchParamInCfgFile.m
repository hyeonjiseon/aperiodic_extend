function value = searchParamInCfgFile(filename,paramname,paramType)
% Function used to search for a given parameter in the config file

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

value = -1;

fid = fopen(filename);
if fid==-1
    return    
end
[C]=textscan(fid,'%s %s','CommentStyle','%');
fclose(fid);

params = C{1};
values = C{2};
for i=1:length(params)
    parameter = char(params(i));
    if parameter(1)=='[' && parameter(end)==']' && strcmpi(parameter(2:end-1),paramname)

        if strcmpi(paramType,'integer') || strcmpi(paramType,'double')
            value = str2double(values(i));
        elseif strcmpi(paramType,'string')
            value = values{i};
        elseif strcmpi(paramType,'bool')
            if strcmpi(values(i),'true')
                value = true;
            elseif strcmpi(values(i),'false')
                value = false;
            else
                error('Error: parameter %s must be a boolean.',params(i));
            end
        elseif strcmpi(paramType,'integerOrArrayString')
            %if ischar(values(i))
                value = str2num(values{i});
            %else
            %    value = str2double(values(i));
            %end                
        else
            error('Error in searchParamInCfgFile: paramType can be only integer, double, string, or bool.');
        end
               
        return
    end
end
