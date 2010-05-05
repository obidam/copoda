% test_test H1LINE
%
% [] = test_test()
% 
% HELPTEXT
%
%
% Created: 2009-07-31.
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

function varargout = test_test(varargin)

res   = true;
fixed = false;
test_name = sprintf('Always %i',res);
test_desc = {'Debug purposes, allow to determined test results'};
switch nargin
	case 0
		varargout(1) = {0};
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end


msg(1).test_name   = test_name;
msg(1).test_result = '?';

if res
	if fixe
		if fixed
			disp_res(test_name,'OK and fixed',verbose);
		else
			disp_res(test_name,'OK and not fixed',verbose);
		end
	else
		disp_res(test_name,'OK',verbose);
	end
else
	if fixe
		if fixed
			disp_res(test_name,'echec but fixed !',verbose);
		else
			disp_res(test_name,'echec and cannot be fixed !',verbose);
		end
	else
		disp_res(test_name,'echec',verbose);
	end
end


if fixed, res=true; end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end


end %function