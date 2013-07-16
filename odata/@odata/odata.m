% odata Constructor for odata class
%
% The class odata links data values to meta informations about it.
% The main difference from a netcdf object is that it doesn't
% contain informations about axis and values are loaded in Matlab memory.
%
% OD = ODATA; will create the default odata object
%
% OD = ODATA('property',value,...); will create an odata object with 
% 	specific properties
%	
% List of properties:
%	name (string)		: short name of the variable
%	unit (string)		: short string for unit (see also shorten_unit)
%	long_name (string)	: Full name of the variable
%	long_unit (string)	: Full unit
%	cont (double)		: variable content
% 
% The following properties are not fully supported:
%	prec (double)		: precision of the variable
%	prec_conv (string)	: convention of the precision
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
% Available elementary math functions:
%
% Trigonometric.
% 	sin         - Sine.
% 	sind        - Sine of argument in degrees.
% 	sinh        - Hyperbolic sine.
% 	asin        - Inverse sine.
% 	asind       - Inverse sine, result in degrees.
% 	asinh       - Inverse hyperbolic sine.
% 	cos         - Cosine.
% 	cosd        - Cosine of argument in degrees.
% 	cosh        - Hyperbolic cosine.
% 	acos        - Inverse cosine.
% 	acosd       - Inverse cosine, result in degrees.
% 	acosh       - Inverse hyperbolic cosine.
% 	tan         - Tangent.
% 	tand        - Tangent of argument in degrees.
% 	tanh        - Hyperbolic tangent.
% 	atan        - Inverse tangent.
% 	atand       - Inverse tangent, result in degrees.
% 	atanh       - Inverse hyperbolic tangent.
% 	sec         - Secant.
% 	secd        - Secant of argument in degrees.
% 	sech        - Hyperbolic secant.
% 	asec        - Inverse secant.
% 	asecd       - Inverse secant, result in degrees.
% 	asech       - Inverse hyperbolic secant.
% 	csc         - Cosecant.
% 	cscd        - Cosecant of argument in degrees.
% 	csch        - Hyperbolic cosecant.
% 	acsc        - Inverse cosecant.
% 	acscd       - Inverse cosecant, result in degrees.
% 	acsch       - Inverse hyperbolic cosecant.
% 	cot         - Cotangent.
% 	cotd        - Cotangent of argument in degrees.
% 	coth        - Hyperbolic cotangent.
% 	acot        - Inverse cotangent.
% 	acotd       - Inverse cotangent, result in degrees.
% 	acoth       - Inverse hyperbolic cotangent.
%
% Exponential.
% 	exp         - Exponential.
% 	expm1       - Compute exp(x)-1 accurately.
% 	log         - Natural logarithm.
% 	log1p       - Compute log(1+x) accurately.
% 	log10       - Common (base 10) logarithm.
% 	log2        - Base 2 logarithm and dissect floating point number.
% 	pow2        - Base 2 power and scale floating point number.
% 	reallog     - Natural logarithm of real number.
% 	realsqrt    - Square root of number greater than or equal to zero.
% 	sqrt        - Square root.
% 	nthroot     - Real n-th root of real numbers.
% 	nextpow2    - Next higher power of 2.
%
% Complex.
% 	abs         - Absolute value.
% 	angle       - Phase angle.
% 	complex     - Construct complex data from real and imaginary parts.
% 	conj        - Complex conjugate.
% 	imag        - Complex imaginary part.
% 	real        - Complex real part.
% 	isreal      - True for real array.
%
% Rounding and remainder.
% 	fix         - Round towards zero.
% 	floor       - Round towards minus infinity.
% 	ceil        - Round towards plus infinity.
% 	round       - Round towards nearest integer.

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
	
	% String properties:
	O.name = '';
	O.unit = '';
	O.long_name = '';
	O.long_unit = '';
	
	% Numerical properties:
	O.cont = NaN;
	
	% Not supported:
	O.prec = NaN;
	O.prec_conv = '';
	O.dims = {};
	
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
	else, OK = false;
	end
end

