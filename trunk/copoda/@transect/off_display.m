% display Deprecated
%
% [] = display()
% 
% HELPTEXT
%
%
% Created: 2009-07-22.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function varargout = display(T)

disp('#################################################################################################')
disp('============================== TRANSECT OBJECT CONTENT DESCRIPTION ==============================');
disp('#################################################################################################')
disp('1) ================================== GENERAL INFORMATIONS ======================================');
disp_prop('Source',T.source);
disp_prop('Creator',T.creator);
disp_prop('File',T.file);
disp_prop('Created',datestr(T.created));
disp_prop('Modified',datestr(T.modified));
disp('2) =================================== CRUISE INFORMATIONS ======================================');
disp_cruise(T.cruise_info);
disp('3) ==================================== AXES INFORMATIONS =======================================');
disp_geo(T.geo);
disp('4) ==================================== DATA INFORMATIONS =======================================');
disp_data(T.data);
disp('#################################################################################################')

end %function


%%%%%%%%%%%%%%%%%%%% 
function varargout = disp_data(A)

	f = fieldnames(A);
	for iv = 1 : size(f,1)
		v = getfield(A,cell2mat(f(iv)));
		if isa(v,'odata')
			if ~isempty(v.name) | ~isempty(v.long_name)
				v
			end
		end
	end


end


%%%%%%%%%%%%%%%%%%%% 
function varargout = disp_geo(A)
	
	blk = ' ';
	if ~isempty(A.LATITUDE)
		disp_prop('Latitude range',sprintf('From %2.1fN to %2.1fN',...
											min(A.LATITUDE),max(A.LATITUDE)));
	end 
	if ~isempty(A.LONGITUDE)
		disp_prop('Longitude range',sprintf('From %2.1fE to %2.1fE',...
											min(A.LONGITUDE),max(A.LONGITUDE)));
	end	
	if ~isempty(A.DEPH)
		disp_prop('Depth range',sprintf('From %2.1fm to %2.1fm',...
											max(max(A.DEPH)),min(min(A.DEPH))));
	end
	if ~isempty(A.STATION_DATE)
		disp_prop('Date range',sprintf('From %s to %s (%3.0f days)',...
					datestr(min(A.STATION_DATE),'mmm. dd yyyy'),...
					datestr(max(A.STATION_DATE),'mmm. dd yyyy'),...
					max(A.STATION_DATE)-min(A.STATION_DATE)))
	end
	
end

%%%%%%%%%%%%%%%%%%%% This one should be a copy of @cruise_info/display.m
function varargout = disp_cruise(C)

blk = ' ';
	if ~isempty(C.NAME),   disp_prop('Name',C.NAME);end
	if ~isempty(C.PI_NAME) 
		if ~isempty(C.PI_ORGANISM)
			disp_prop('PI',sprintf('%s (%s)',C.PI_NAME,C.PI_ORGANISM));
		else
			disp_prop('PI',C.PI_NAME);
		end
	end
	if ~isempty(C.SHIP_NAME)
		if ~isempty(C.SHIP_WMO_ID)
			disp_prop('Ship',sprintf('%s (%s)',C.SHIP_NAME,C.SHIP_WMO_ID));
		else
			disp_prop('Ship',C.SHIP_NAME);
		end
	end
	if ~isempty(C.DATE)
		disp_prop('Date',sprintf('From %s to %s (%3.0f days)',...
					datestr(min(C.DATE),'mmm. dd yyyy'),...
					datestr(max(C.DATE),'mmm. dd yyyy'),diff(C.DATE)));
	end
	if ~isempty(C.N_STATION)
		disp_prop('Number of station(s)',num2str(C.N_STATION))
	end
end

%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end

















