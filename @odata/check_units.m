% check_units TRUE if units are similar, FALSE otherwise
%
% RES = check_units(od1,od2)
% 
% Check from od1,od2 unit or long_unit properties if they are
% of the units
%
%
% Created: 2009-08-26.
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

function RES = check_units(od1,od2)

% We don't bother the user by too much checking, so the default result will be TRUE:
default = true;

% Read units:
u1  = lower(od1.unit);
u2  = lower(od2.unit);
lu1 = lower(od1.long_unit);
lu2 = lower(od2.long_unit);

% If both short units are defined, is it a match ?
if ~strcmp(u1,'') & ~strcmp(u2,'')
	if length(u1) ~= length(u2) % If string length different, cannot be similar !
		RES = false;
	elseif ~strcmp(u1,u2)
		RES = false;
	else
		RES = default;
	end%if

% 1 of the short unit was not defined, try to compair long_units, if they are defined:
elseif ~strcmp(lu1,'') & ~strcmp(lu2,'')
	if length(lu1) ~= length(lu2) % If string length different, cannot be similar !
		RES = false;
	elseif ~strcmp(lu1,lu2)
		RES = false;
	else
		RES = default;
	end
	
% Not enough informations about units (short or long) so let's the default output prevails:
else
	RES = default;
end

end %function