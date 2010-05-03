% dfromo Compute station distance (km) to an origin
%
% [D] = dfromo(T,O)
% 
% Compute the distance D (km) of each stations in transect object T
% from a point O defined by: latitude/longitude
% Example:
%	d = dfromo(T,[317.5 59.8]); % Compute distance to Greenland
%
% [D K] = dfromo(T,O);
% When two outputs are required, D is sorted and K contained indices
% to sort T.
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

function varargout = dfromo(varargin)

error(nargchk(2,2,nargin,'struct'));
if ~isa(varargin{1},'transect')
	error('1st argument must be transect object');
elseif ischar(varargin{2})
	error('2nd argument must be 1x2 double table');
elseif length(varargin{2}) > 2
	error('2nd argument must be 1x2 double table');
else
	T = varargin{1};
	O = varargin{2};
end

x = T.geo.LONGITUDE;
y = T.geo.LATITUDE;

if length(x) ~= length(y)
	error('Latitude and Longitude must be of same dimensions')
end

for is = 1 : length(x)
	D(is) = m_lldist([O(1) x(is)],[O(2) y(is)])/1e3;
end

[Dsort ik] = sort(D);


switch nargout
	case 1
		varargout(1) = {D};
	case 2
		varargout(1) = {Dsort};
		varargout(2) = {ik};
end %switch

end %function