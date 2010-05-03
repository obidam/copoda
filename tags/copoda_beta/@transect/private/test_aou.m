% test_aou H1LINE
%
% [] = test_aou()
% 
% HELPTEXT
%
%
% Created: 2009-08-04.
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

function varargout = test_aou(varargin)

test_name = 'Apparent Oxygen Utilization';
test_desc = {'Check if variable AOU exists and try to compute it otherwise'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {6}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

if isdata(T,'AOU')
	disp_res(test_name,'AOU already exists, not overwritten',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true; 
	res   = true;
	
%%%%%%%%%%%%%%%%%%%%%%%%%	
elseif isdata(T,'OXYL') & isdata(T,'OXSL') & fixe
	% Compute AOU
	if strcmp(T.data.OXYL.unit,T.data.OXSL.unit)
		AOU = T.data.OXSL.cont - T.data.OXYL.cont;
	else
		try % to convert units
			if isdata(T,'SIG0')
				OXYL = convert_unit(T.data.OXYL.cont,'OXY',T.data.OXYL.unit,T.data.OXSL.unit,T.data.SIG0.cont);
			else
				OXYL = convert_unit(T.data.OXYL.cont,'OXY',T.data.OXYL.unit,T.data.OXSL.unit);
			end
			AOU = T.data.OXSL.cont - OXYL;
			OD = odata('name','AOU=OXSL-OXY',...
						'long_name',sprintf('Apparent Oxygen Utilization, added by %s',getenv('USER')),...
						'unit',T.data.OXSL.unit,'long_unit',T.data.OXSL.long_unit,...
						'cont',AOU);
			T = addodata(T,'AOU',OD);
			disp_res(test_name,'OK, AOU created from OXYL and OXSL',verbose);
			msg(1).test_name   = test_name;
			msg(1).test_result = 'OK';
			fixed = true;
			res   = true;
		catch
			disp_res(test_name,'Cannot compute AOU',verbose);
			msg(1).test_name   = test_name;
			msg(1).test_result = 'OK';
			res = true;
		end
	end
	
elseif isdata(T,'OXYK') & isdata(T,'OXSL') & fixe
	% Compute AOU
	if strcmp(T.data.OXYK.unit,T.data.OXSL.unit)
		AOU = T.data.OXSL.cont - T.data.OXYK.cont;
	else
		try % to convert units
			if isdata(T,'SIG0')
				OXYK = convert_unit(T.data.OXYK.cont,'OXY',T.data.OXYK.unit,T.data.OXSL.unit,T.data.SIG0.cont);
			else
				OXYK = convert_unit(T.data.OXYK.cont,'OXY',T.data.OXYK.unit,T.data.OXSL.unit);
			end
			AOU = T.data.OXSL.cont - OXYK;
			OD = odata('name','AOU=OXSL-OXY',...
						'long_name',sprintf('Apparent Oxygen Utilization, added by %s',getenv('USER')),...
						'unit',T.data.OXSL.unit,'long_unit',T.data.OXSL.long_unit,...
						'cont',AOU);
			T = addodata(T,'AOU',OD);
			
			disp_res(test_name,'OK, AOU created from OXYK and OXSL',verbose);
			msg(1).test_name   = test_name;
			msg(1).test_result = 'OK';
			fixed = true;
			res   = true;
		catch
			disp_res(test_name,'Cannot compute AOU',verbose);
			msg(1).test_name   = test_name;
			msg(1).test_result = 'OK';
			res = true;
		end
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%%	
elseif isdata(T,'OXYL') & isdata(T,'TEMP') & isdata(T,'PSAL') & fixe
	% Compute AOU:
%	AOU = sw_satO2(T.data.PSAL.cont,T.data.TEMP.cont) - T.data.OXYL.cont;	
	AOU = oxysol(T.data.TEMP.cont,T.data.PSAL.cont,'ml/l') - T.data.OXYL.cont;
	
	
	OD = odata('name','AOU=OXSL-OXYL',...
				'long_name',sprintf('Apparent Oxygen Utilization, added by %s, computed using oxysol.m',getenv('USER')),...
				'unit','ml/l','long_unit','millitres/litre',...
				'cont',AOU);
	T = addodata(T,'AOU',OD);
	disp_res(test_name,'OK, AOU created',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true;
	res   = true;
else
	disp_res(test_name,'Missing fields to compute AOU',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	res = true;
end

if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end


end %function