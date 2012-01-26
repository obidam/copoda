% tracks Draw a map of all transect's tracks within a database
%
% [hl] = tracks(D,[TYPE,SUBTYPE,OPTIONS])
% 
% This function draws a map with all profiles locations.
%
% Options:
% - TYPE: 1: Colorize according to profiles' years:
%		SUBTYPE = 1 (default) per year
%		SUBTYPE = 2 per decade
%		SUBTYPE = 3 per 5 years 
%
% - TYPE: 2: On a single figure, one subplot per transect of the database.
%
% - TYPE: 3: (fastest method) No color, only black crosses for each profiles.
%
% - TYPE: 4: (default) Colorize profiles' location with various fields:
%		SUBTYPE = 1 (default) Station dates
%		SUBTYPE = 2 Station dates by months
%		SUBTYPE = 3 Station number
%		SUBTYPE = 4 Station mixed layer depth
%		SUBTYPE = 5 Station main thermocline depth
%		SUBTYPE = 6 Station main thermocline depth quality flag
%
% - OPTIONS is the marker type, it can be anyone from the plot function.
%
% Output parameter hl is a table of handles from objects plotted on the figure.
%
% Rq:
%	All plotted object (markers) are tagged with: 'station_location'
%
% Eg:
%	tracks(D);
%	tracks(D,4,1); % Similar to previous call
%	tracks(D,4,4,'s'); 
%
% Created: 2009-07-28.
% Rev. by Guillaume Maze on 2011-06-01: Added help
% Rev. by Guillaume Maze on 2009-08-03: Moved to plot modules in private folder
% http://copoda.googlecode.com
% Copyright 2010, COPODA

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


function varargout = tracks(D,varargin)

pl_type  = 4;
if nargin >= 2
	pl_type = varargin{1};
end

switch pl_type
	case 0,
		if nargin >= 2
			[p tt]=tracks_pl0(D,varargin{2:end});
		else
			[p tt]=tracks_pl0(D);
		end
	case 1,[p tt]=tracks_pl1(D);
	case 2,[p tt]=tracks_pl2(D);
	case 3, p = tracks_pl3(D);
	case 4, p = tracks_pl4(D,varargin{2:end});
end
copoda_figtoolbar(D);
set(gcf,'tag','track_map');


switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end






end %function