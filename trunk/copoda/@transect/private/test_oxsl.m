% test_oxsl H1LINE
%
% [] = test_oxsl()
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

function varargout = test_oxsl(varargin)

test_name = 'Oxygen Solubility';
test_desc = {'Check if variable OXSL exists and try to compute it otherwise'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {7}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

if isdata(T,'OXSL')
	disp_res(test_name,'OXSL already exists, not overwritten',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true; 
	res   = true;
	
elseif isdata(T,'TEMP')	& isdata(T,'PSAL') & fixe 
	% Compute saturation:
	OXSL = oxysol(T.data.TEMP.cont,T.data.PSAL.cont);

	OD = odata('name','OXSL(T,S)',...
				'long_name',sprintf('Oxygen Solubility, added by %s',getenv('USER')),...
				'unit','ml/l','long_unit','millitres/litre',...
				'cont',OXSL);
	T = setodata(T,'OXSL',OD,'R');
	
	disp_res(test_name,'OK, OXSL created',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true;
	res   = true;

elseif isdata(T,'TEMP',0)	& isdata(T,'PSAL',0) & fixe 

	OD = odata('name','OXSL(T,S)',...
				'long_name',sprintf('Oxygen Solubility, added by %s',getenv('USER')),...
				'unit','ml/l','long_unit','millitres/litre',...
				'cont',NaN);
	T = setodata(T,'OXSL',OD,'V');
	
	disp_res(test_name,'OK, OXSL created as a virtual variable (TEMP and PSAL not filled yet)',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true;
	res   = true;
	
else
	disp_res(test_name,'Missing fields to compute OXSL',verbose);
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