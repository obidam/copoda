% oaxis Constructor for oaxis class
%
% The class oaxis serves as axis definitions to odata objects
%
% O = oaxis(no arguments) creates a default oaxis object
% 
% [] = oaxis(T) display properties of a oaxis object T
%
% O = oaxis('property',value,...) creates a oaxis object
%	
% List of properties:
%	name (string)		: short name of the axis
%	unit (string)		: short string for unit (see also shorten_unit)
%	cont (double)		: axis content
%	prec (double)		: precision of the axis
%	prec_conv (string)	: convention of the precision
%	long_name (string)	: Full name of the axis
%	long_unit (string)	: Full unit
%	axis (string) 		: X,Y,Z,T for netcdf transcription
%
% Example:
%	to do !
%
% Created: 2009-11-05.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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



function C = oaxis(varargin)

switch nargin
	case 0 
		% Create default object
		C = init_fields;
		C = class(C,'oaxis');

	case 1
		% If a single argument of class test, return it
		if (isa(varargin{1},'oaxis'))
			C = varargin{1};
		else
			error('Input argument is not an oaxis object');
		end

	otherwise	
		% Create default object
		C = init_fields;
		C = class(C,'oaxis');
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
					error('Invalid propertie name for oaxis structure');
				end
			end
		end

end %switch

end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function O = init_fields(varargin)
	
	O.name = '';
	O.unit = '';
	O.cont = NaN;
	O.prec = NaN;
	O.prec_conv = '';
	O.long_name = '';
	O.long_unit = '';
	O.axis = '';
	
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OK = check_prop(P)
	if 		strcmp(P,'name'), OK = true;
	elseif	strcmp(P,'unit'), OK = true;
	elseif	strcmp(P,'cont'), OK = true;
	elseif	strcmp(P,'prec'), OK = true;
	elseif	strcmp(P,'prec_conv'), OK = true;
	elseif	strcmp(P,'long_name'), OK = true;
	elseif	strcmp(P,'long_unit'), OK = true;
	elseif	strcmp(P,'axis'), OK = true;
	else, OK = false;
	end
end

