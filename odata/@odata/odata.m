% odata Constructor for odata class
%
% The class odata links data values to meta informations about it.
% The main difference from a netcdf object is that it doesn't
% contain informations about axis.
%
% O = odata(no arguments) creates a default odata object
% 
% [] = odata(T) display properties of a odata object T
%
% O = odata('property',value,...) creates a odata object
%	
% List of properties:
%	name (string)		: short name of the variable
%	unit (string)		: short string for unit (see also shorten_unit)
%	cont (double)		: variable content
%	prec (double)		: precision of the variable
%	prec_conv (string)	: convention of the precision
%	long_name (string)	: Full name of the variable
%	long_unit (string)	: Full unit
%	dims (cell)	: Cell of OAxis name in the base workspace
%
% Example 1:
%	load wind
%	D1 = odata;
%	D1.name = 'U';
%	D1.unit = 'm/s';
%	D1.cont = u;
%	D1.long_name = 'Zonal velocity';
%	D2 = odata('long_name','Meridional velocity','name','V','unit','m/s','cont',v);
%
% Example 2:
%	% Build an ODdata object from a netcdf variable:
%	varn = 'PSAL';
%	nc = netcdf([getenv('HOME') '/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc'],'nowrite');
%	D = odata(...
% 		'long_name',nc{varn}.long_name(:),...
% 		'long_unit',nc{varn}.units(:),...
% 		'unit',shorten_unit(nc{varn}.units(:)),...
% 		'cont',nc{varn}(:,:),...
% 		'prec',nc{sprintf('PROFILE_%s_PREC',varn)}(:),...
% 		'name',varn...
% 		...
% 		);
%
% Example 2:
%	% Build an ODdata object from a netcdf variable:
%	varn = 'PSAL';
%	nc = netcdf([getenv('HOME') '/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc'],'nowrite');
%	D = odata(...
% 		'long_name',nc{varn}.long_name(:),...
% 		'long_unit',nc{varn}.units(:),...
% 		'unit',shorten_unit(nc{varn}.units(:)),...
% 		'cont',nc{varn}(:,:),...
% 		'prec',nc{sprintf('PROFILE_%s_PREC',varn)}(:),...
% 		'name',varn...
% 		...
% 		);

% More informations about interconnections with netcdf classes:
%	help odata/add2cdf
%
% More informations about specific methods:
%	help odata/reorder
%	help odata/cont
%
% More informations about specific Matlab methods:
%	help odata/display
%	help odata/plus
%	help odata/minus
%	help odata/times
%	help odata/rdivide
%	help odata/power
%	help odata/plot
%	help odata/pcolor
%	help odata/dim
%	help odata/size
%
% Created: 2009-07-24.
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

function C = odata(varargin)

switch nargin
	case 0 
		% Create default object
		C = init_fields;
		C = class(C,'odata');

	case 1
		% If a single argument of class test, return it
		if (isa(varargin{1},'odata'))
			C = varargin{1};
		else
			error('Input argument is not an odata object');
		end

	otherwise	
		% Create default object
		C = init_fields;
		C = class(C,'odata');
		% then modify object using specified values:
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else
			for iprop = 1 : 2 : n
				prop_nam = varargin{iprop};
				prop_val = varargin{iprop+1};
				if check_prop(prop_nam)
%					C = setfield(C,prop_nam,prop_val);
					C = subsasgn(C,substruct('.',prop_nam),prop_val); % Much faster
				else
					error('Invalid propertie name for odata structure');
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
	O.dims = {};

	%-- test:	
	%O.nc = struct();

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
	elseif	strcmp(P,'dims'), OK = true;
	elseif	strcmp(P,'nc'), OK = true;
	else, OK = false;
	end
end

