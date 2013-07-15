% coord Load latitude/longitude/time of profiles
%
% [X,Y,T] = coord(T)
% 
% Load latitude/longitude/time of profiles
%
% Rev. by Guillaume Maze on 2012-06-04: Added time output
% Created: 2011-10-21.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = coord(T,varargin)

if nargin > 1
	error('Sorry, not implemented yet !')
end% if 

switch nargout
	case 1
		X = T.geo.LONGITUDE;
		varargout(1) = {X};
	case 2
		X = T.geo.LONGITUDE;
		Y = T.geo.LATITUDE;
		if length(X) ~= length(Y)
			throw(MException('COPODA:transect:coord','Latitude and longitude are not of similar length !'));
		end% if			
		varargout(1) = {X};
		varargout(2) = {Y};
	case 3
		X = T.geo.LONGITUDE;
		Y = T.geo.LATITUDE;
		t = T.geo.STATION_DATE;
		if length(X) ~= length(Y)
			throw(MException('COPODA:transect:coord','Latitude and longitude are not of similar length !'));
		end% if
		if length(X) ~= length(t)
			throw(MException('COPODA:transect:coord','Time and longitude are not of similar length !'));
		end% if			
		varargout(1) = {X};
		varargout(2) = {Y};
		varargout(3) = {t};
	otherwise
		throw(MException('COPODA:transect:coord','Invalid number of output'));
end% switch 

end %functioncoord
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
