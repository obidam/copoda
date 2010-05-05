% get_ds H1LINE
%
% [] = get_ds()
% 
% HELPTEXT
%
%
% Created: 2009-07-29.
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

function varargout = get_ds(T)

y = T.geo.LATITUDE';
x = T.geo.LONGITUDE';
np = length(x);
if length(y) ~= np
	error('Latitude and longitude should be of same dimensions within transect geo properties');
end
for ipt = 1 : np - 1
	d(ipt) = m_lldist(x(ipt:ipt+1),y(ipt:ipt+1));
end
DL = [d(1)/2 (d(1:end-1)+d(2:end))/2 d(end)/2]';

for ipt = 1 : np
	z = abs(T.geo.DEPH(ipt,:));
	dz = diff(z);
	DZ(ipt,:) = [dz(1)/2 (dz(1:end-1)+dz(2:end))/2 dz(end)/2]';
	DS(ipt,:) = DZ(ipt,:).*DL(ipt);
end

switch nargout
	case 1
		varargout(1) = {DS};
	case 2
		varargout(1) = {DS};
		varargout(2) = {DZ};		
	case 3
		varargout(1) = {DS};
		varargout(2) = {DZ};
		varargout(3) = {DL};	
end

end %function