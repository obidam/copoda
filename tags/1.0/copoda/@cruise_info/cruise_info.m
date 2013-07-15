% cruise_info Cruise_info class constructor
%
% Cruise_info is a class containing informations about a cruise.
% 
% Syntax: 
%
% C = cruise_info(no arguments) creates a default cruise_info object
% 
% [] = cruise_info(C) display properties of a cruise_info object C
%
% C = cruise_info('property',value,...) creates a cruise_info object
%
% List of properties:
%	NAME (string)		 : Name of the cruise
% 	PI_NAME (string)	 : Name of the principal investigator
%	PI_ORGANISM (string)	 : Organism of the principal investigator
%	SHIP_NAME (string)	 : Name of the ship
%	SHIP_WMO_ID (string)	 : WMO identifier of the ship. More informations at
%				http://www.wmo.int/pages/prog/amp/mmop/wmo-number-rules.html
%	DATE (datenum 2x1)	 : 1st and last day of the cruise (2x1 double table)
%				as returned by datenum
%	N_STATION (double)	 : Number of stations or profiles performed during the cruise/
%
% More informations about specific Matlab methods:
%	help database/display
%
% Created: 2009-07-23.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

function C = cruise_info(varargin)

switch nargin
	case 0 
		% Create default object
		C = init_fields;
		C = class(C,'cruise_info');

	case 1
		% If a single argument of class test, return it
		if (isa(varargin{1},'cruise_info'))
			C = varargin{1};
		else
			error('Input argument is not a cruise_info object');
		end
				
	otherwise	
		% Create default object
		C = init_fields;
		C = class(C,'cruise_info');
		% then modify object using specified values:
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else
			for iprop = 1 : 2 : n
				prop_nam = varargin{iprop};
				prop_val = varargin{iprop+1};
				if check_prop(prop_nam)
					C = setfield(C,prop_nam,prop_val);
				else
					error('Invalid propertie name for cruise_info structure');
				end
			end
		end

end %switch

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = init_fields()
	% Init:
	C.NAME = '';
	C.PI_NAME = '';
	C.PI_ORGANISM   = '';
	C.SHIP_NAME = '';
	C.SHIP_WMO_ID = '';
	C.DATE = [0 0];
	C.N_STATION = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OK = check_prop(P)
	if 		strcmp(P,'NAME'), OK = true;
	elseif	strcmp(P,'PI_NAME'), OK = true;
	elseif	strcmp(P,'PI_ORGANISM'), OK = true;
	elseif	strcmp(P,'SHIP_NAME'), OK = true;
	elseif	strcmp(P,'SHIP_WMO_ID'), OK = true;
	elseif	strcmp(P,'DATE'), OK = true;
	elseif	strcmp(P,'N_STATION'), OK = true;
	else, OK = false;
	end
end  %function

