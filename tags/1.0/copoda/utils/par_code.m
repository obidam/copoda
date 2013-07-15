% par_code Give informations about a parameter from its code
%
% INFO = par_code(CODES)
% 
% CODES is a parameter from LPO multiprofiles files. For several
% parameters, CODES is a cell table.
% Input example:
%	CODES = 'PSAL';
%	CODES = {'CNDC','PRES','PSAL','TEMP'};
% Output INFO is a cell table of informations about parameters
% into structures.
%
% Example:
%	info = par_code({'PRES','PSAL'});
%	info{1}.name
%	info{1}
%	info{2}.name
%	info{2}
%
% Created: 2009-08-03.
% Rev. by Guillaume Maze on 2009-09-23: Return NaN when no match
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

function varargout = par_code(varargin)

if nargin == 0
	PAR = {'CNDC','PRES','PSAL','TEMP','DEPH','ZCOO',...
	'OXYL','OXYK','TPOT','SIGI','SIGO','SI15','SIG1',...
	'SIG2','SIG3','SIG4','SIG5','SIG6','DYNH','BRV2',...
	'SSDG','VORP','NITR','PHOS'};
elseif iscell(varargin{1})
	PAR = varargin{1};
else
	PAR = {varargin{1}};
end
PAR = upper(PAR);

for ip = 1 : length(PAR)
	par = PAR{ip};
	clear parameter
	switch par
		case 'CNDC'
			parameter.name = 'ELECTRICAL CONDUCTIVITY';
			parameter.unit = 'mhos/m';
			parameter.valid_min = -Inf;
			parameter.valid_max =  Inf;
			parameter.fill_value = -9999;
		case 'PRES'
			parameter.name = 'SEA PRESSURE (sea surface = 0)';
			parameter.unit = 'decibars';
			parameter.valid_min = 0;
			parameter.valid_max = 12000;
			parameter.fill_value = -9999;	
		case 'PSAL'
			parameter.name = 'PRACTICAL SALINITY';
			parameter.unit = '----';
			parameter.valid_min = 0;
			parameter.valid_max = 60;
			parameter.fill_value = -9999;	
		case 'TEMP'
			parameter.name = 'SEA TEMPERATURE';
			parameter.unit = 'degreesC';
			parameter.valid_min = -15;
			parameter.valid_max = 40;
			parameter.fill_value = -9999;
		case 'DEPH'
			parameter.name = 'DEPTH BELOW SEA SURFACE';
			parameter.unit = 'meters';
			parameter.valid_min = 0;
			parameter.valid_max = 15000;
			parameter.fill_value = -9999;
		case 'ZCOO'
			parameter.name = 'VERTICAL COORDINATE DEDUCED FROM LOCAL DENSITY, POSITIVE UPWARD';
			parameter.unit = 'meters';
			parameter.valid_min = -15000;
			parameter.valid_max = 0;
			parameter.fill_value = -9999;
		case 'OXYL'
			parameter.name = 'DISSOLVED OXYGENE';
			parameter.unit = 'ml/l';
			parameter.valid_min = 0;
			parameter.valid_max = 15;
			parameter.fill_value = -9999;		
		case 'OXYK'
			parameter.name = 'DISSOLVED OXYGENE';
			parameter.unit = 'mumol/kg';
			parameter.valid_min = 0;
%			parameter.valid_max = 400; % This needs to be consistent with ml/l valid range
			% A better value is given by: convert_unit(40,'OXY','ml/l','mumol/kg',0):
			parameter.valid_max = 650;			
			parameter.fill_value = -9999;
		case 'TPOT'
			parameter.name = 'POTENTIAL TEMPERATURE';
			parameter.unit = 'degrees C';
			parameter.valid_min = -15;
			parameter.valid_max = 40;
			parameter.fill_value = -9999;
		case 'SIGI'
			parameter.name = 'IN SITU DENSITY ANOMALY';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;
		case 'SIG0'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 0';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;
		case 'SIG1'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 1000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;
		case 'SI15'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 1500';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;		
		case 'SIG2'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 2000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;	
		case 'SIG3'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 3000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;	
		case 'SIG4'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 4000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;	
		case 'SIG5'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 5000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;	
		case 'SIG6'
			parameter.name = 'DENSITY ANOMALY REFERENCED to P = 6000';
			parameter.unit = 'kg/m**3';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;		
		case 'DYNH'
			parameter.name = 'DYNAMICAL HEIGHT';
			parameter.unit = 'Dyn. meters';
			parameter.valid_min = -Inf;
			parameter.valid_max =  Inf;
			parameter.fill_value = -9999;
		case 'BRV2'
			parameter.name = 'BRUNT-VAISALA FREQUENCY SQUARED';
			parameter.unit = 's**-2';
			parameter.valid_min = -Inf;
			parameter.valid_max =  Inf;
			parameter.fill_value = -9999;
		case 'SSDG'
			parameter.name = 'SOUND SPEED DEL GROSSO FORMULA';
			parameter.unit = 'm*s-1';
			parameter.valid_min = 1000;
			parameter.valid_max = 2000;
			parameter.fill_value = -9999;
		case 'VORP'
			parameter.name = 'PLANETARY VORTICITY (f/h)';
			parameter.unit = 's**-1';
			parameter.valid_min = -Inf;
			parameter.valid_max =  Inf;
			parameter.fill_value = -9999;		
		case 'NITR'
			parameter.name = 'NITRATE';
			parameter.unit = 'mumol/kg';
			parameter.valid_min = 0;
			parameter.valid_max = 100;
			parameter.fill_value = -9999;	
		case 'PHOS'
			parameter.name = 'PHOSPHATE';
			parameter.unit = 'mumol/kg';
			parameter.valid_min = 0;
			parameter.valid_max = 10;
			parameter.fill_value = -9999;		
			
		% case ''
		% 	parameter.name = '';
		% 	parameter.unit = '';
		% 	parameter.valid_min = ;
		% 	parameter.valid_max = ;
		% 	parameter.fill_value = -9999;
	end %switch

	if exist('parameter')
		CODE(ip) = {parameter};
	end
end %for ip


switch nargout
	case 0
		if nargin ~= 0
			if exist('CODE')
				disp_this(CODE);
			end
		else
			disp('Please, give me an output variable to give you these results');
		end
	case 1
		if ~exist('CODE')
			CODE = NaN;
		end
		varargout(1) = {CODE};
end
	

end %function



function disp_this(CODE)
	
	for ip = 1 : length(CODE)
		CODE{ip}
	end
	
end

