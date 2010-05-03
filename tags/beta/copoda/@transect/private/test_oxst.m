% test_oxst H1LINE
%
% [] = test_oxst()
% 
% HELPTEXT
%
%
% Created: 2009-08-05.
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

function varargout = test_oxst(varargin)

test_name = 'Oxygen Saturation';
test_desc = {'Check if variable OXST exists and try to compute it otherwise'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {8}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

if isdata(T,'OXST')
	disp_res(test_name,'OXST already exists, not overwritten',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true; 
	res   = true;
	
elseif isdata(T,'OXYL')	& isdata(T,'OXSL') & fixe 
	% Compute O2 saturation:
	OXST = 100*(T.data.OXYL.cont./T.data.OXSL.cont);

	OD = odata('name','OXST',...
				'long_name',sprintf('Oxygen Saturation, added by %s',getenv('USER')),...
				'unit','%','long_unit','%',...
				'cont',OXST);				
	T = addodata(T,'OXST',OD);
	disp_res(test_name,'OK, OXST created',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true;
	res   = true;
else
	disp_res(test_name,'Missing fields to compute OXST',verbose);
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