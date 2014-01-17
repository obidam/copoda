% map Draw a map of all transect's tracks within a database
%
% [hl] = map(D,[TYPE,SUBTYPE,OPTIONS])
% 
% This function draws a map with all profiles locations.
%
% Options:
% - TYPE = <any field name from geo and data properties of transect>
%		SUBTYPE is any level for profiles data.
%		Eg:
%			map(D,'TEMP'); % color markers with temperature at 1st level
%			map(D,'PSAL',10); % color markers with salinity at 10th level
%
% - TYPE = 1: Colorize according to profiles' years:
%		SUBTYPE = 1 (default) per year
%		SUBTYPE = 2 per decade
%		SUBTYPE = 3 per 5 years 
%		Eg:
%			map(D,1,3); % color markers for every 5 years period of the database
%
% - TYPE: 2: On a single figure, one subplot per transect of the database.
%		Eg:
%			map(D,2);
%
% - TYPE: 3: (fastest method) No color, only black crosses for each profiles.
%		Eg:
%			map(D,1,2);
%
% - TYPE: 4: (default) Colorize profiles' location with various fields:
%		SUBTYPE = 1 (default) Station dates
%		SUBTYPE = 2 Station dates by months
%		SUBTYPE = 3 Station number
%		SUBTYPE = 4 Station mixed layer depth
%		SUBTYPE = 5 Station main thermocline depth
%		SUBTYPE = 6 Station main thermocline depth quality flag
%		Eg:
%			map(D,4,4); % Color markers with profile mixed layer depth
%
% - OPTIONS is the marker type, it can be anyone from the plot function.
%
% Output parameter hl is a table of handles from objects plotted on the figure.
%
% Rq:
%	All plotted object (markers) are tagged with: 'station_location'
%
%
% Created: 2012-01-29.
% http://code.google.com/p/copoda
% Copyright 2012, COPODA

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
function varargout = map(D,varargin)

[p tt] = tracks(D,varargin{1:end});

switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end


end %functionmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
