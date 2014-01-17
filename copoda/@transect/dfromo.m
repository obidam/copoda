% dfromo Compute station distance (km) from an origin
%
% d = dfromo(T,O) Compute the distance d (km) of each stations 
% in transect object T from a point O defined by its coordinates
% as latitude/longitude. d is not sorted.
% Example:
%	d = dfromo(T,[317.5 59.8]); % Compute distance to Greenland Tip
%
% [d ik] = dfromo(T,O) When two outputs are required, d is sorted 
% and ik contained indices to possibly reorder T (see squeeze method).
% Example:
%	[d ik] = dfromo(T,[317.5 59.8]); % Compute distance to Greenland Tip
%	T = squeeze(T,ik); % Reorder stations in T so that d increases.
%
% Created: 2009-08-04.
% http://copoda.googlecode.com
% Copyright 2009, COPODA

% Tags for documentation:
%TAGS user-level,distance,axis,origin,sort

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

function varargout = dfromo(varargin)

error(nargchk(2,2,nargin,'struct'));
if ~isa(varargin{1},'transect')
	error('1st argument must be a transect object');
elseif ischar(varargin{2})
	error('2nd argument must be 1x2 double table');
elseif length(varargin{2}) > 2
	error('2nd argument must be 1x2 double table');
else
	T = varargin{1};
	O = varargin{2};
end% if 

x = T.geo.LONGITUDE;
y = T.geo.LATITUDE;

if length(x) ~= length(y)
	error('Latitude and Longitude must be of similar dimensions')
end% if 

for is = 1 : length(x)
	D(is) = lldist([O(2) y(is)],[O(1) x(is)])/1e3;
end% for is

[Dsort ik] = sort(D);

switch nargout
	case 1
		varargout(1) = {D};
	case 2
		varargout(1) = {Dsort};
		varargout(2) = {ik};
end% switch

end% function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute distance in meters between two points.
% We use a local routine because the function m_lldist
% returns meter or km depending on the version of the
% m_map package !
% So I don't want to check which version is it
function dist = lldist(lat,lon)
	
	if length(lat) == 1 & length(lon)>1
		lat = lat*ones(1,length(lon));
	elseif length(lon) == 1 & length(lat)>1
		lon = lon*ones(1,length(lat));
	end
	pi180=pi/180;
	earth_radius=6378.137e3;

	long1=lon(1:end-1)*pi180;
	long2=lon(2:end)*pi180;
	lat1=lat(1:end-1)*pi180;
	lat2=lat(2:end)*pi180;

	dlon = long2 - long1; 
	dlat = lat2 - lat1; 
	a = (sin(dlat/2)).^2 + cos(lat1) .* cos(lat2) .* (sin(dlon/2)).^2;
	c = 2 * atan2( sqrt(a), sqrt(1-a) );
	dist = earth_radius * c;

	dist = dist(:)';

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
