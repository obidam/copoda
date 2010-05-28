% tracks Draw a map of all transect's tracks within a database
%
% [hl] = tracks(D,[TYPE],[SUBTYPE])
% 
% According to max/min of latitude/longitude of all transects within the
% database object D, this function draw a map with all profils locations.
% Options:
%	 TYPE: 
%		1: 
%		2:
%		3:
%		4:
%
% Output parameter hl is a table of handles from objects in the figure.
%
%
% Created: 2009-07-28.
% Rev. by Guillaume Maze on 2009-08-03: Moved to plot modules in private folder
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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

switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end






end %function