% test_STATION_NUMBER H1LINE
%
% [] = test_STATION_NUMBER()
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

function varargout = test_STATION_NUMBER(varargin)
		
test_name = 'STATION_NUMBER order';
test_desc = {'Check if STATION_NUMBER is sorted (excluded from the default list, Jul.30/2009)'};
res   = false;
fixed = false;	
switch nargin
	case 0
		varargout(1) = {2}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	


stnumb = T.geo.STATION_NUMBER;
if ~issorted(stnumb)
	msg(1).test_name   = test_name;
	msg(1).test_result = 'STATION_NUMBER is not always increasing';
	if fixe
		try 
			[a, ii] = sort(stnumb);
			T = reorder(T,ii);
			clear a ii
			disp_res(test_name,'echec but fixed !',verbose);
			fixed = true;
		catch
			disp_res(test_name,'Couldn''t fix this, sorry ... ',verbose);
		end
	else	
		disp_res(test_name,'echec (try FIX=1)',verbose);
	end
else
	disp_res(test_name,'OK',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	res = true;
end

if fixed, res=true;end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end

end %function