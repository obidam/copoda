%DEF Plot all transects on 1 map with 1 color per cruise
%
% [] = tracks_pl0(D,[pl_type,show_legend])
% 
% Inputs:
%	D: The database object
%	pl_type: can be:
%		1: Centered on stations +/-  2 deg in longitude, +/- 2 deg in latitude (default)
%		2: Centered on stations +/- 10 deg in longitude, +/- 5 deg in latitude
%		3: Global Map
%	show_legend: can be:
%		1: Show a legend over the map  (default)
%		2: Hide the legend
%		3: Hide the legend and print on prompt the legend to paste in LaTeX
%
% Created: 2009-08-03.
% Rev. by Guillaume Maze on 2011-06-01: DEPRECATED METHOD !
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


function varargout = tracks_pl0(D,varargin)

% DEPRECATED
return


%%%%%%%%%%%%%% Options:
show_leg = 0;
if nargin == 2
	show_leg = varargin{1};
end

%%%%%%%%%%%%%% 
hold on
optimap(D);

%%%%%%%%%%%%%% Plot stations
nt   = length(D);
cmap = hsv(nt);
if 0	
	for it = 1 : nt
		T = D.transect{it};
		x = T.geo.LONGITUDE;
		y = T.geo.LATITUDE;
		p(it) = m_plot(x,y,'+'); 
		set(p(it),'color',cmap(it,:),'tag','station_location');
		leg(it).val = stamp(T,1);
	end
else
	colormap(cmap);
	for it = 1 : nt
		T = D.transect{it};
		x = T.geo.LONGITUDE;
		y = T.geo.LATITUDE;
		a = m_scatter(x,y,10,it*ones(1,length(x)),'marker','+');
		set(a,'tag','station_location');
		leg(it).val = stamp(T,1);
		p(it) = a;
	end
	caxis([1 nt]);
end

%%%%%%%%%%%%%% Text:
switch show_leg
	case 1
		ll = legend(p,leg.val,'location','northoutside');
		set(ll,'interpreter','none','fontweight','normal')
	case 2 % No legend
	otherwise
end

%tt = xlabel(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
tt = xlabel(sprintf('%s, %s\n%s (%s)',D.name,datestr(D.modified,'yyyy/mmm/dd'),D.source,D.creator));
set(tt,'fontweight','bold','fontsize',14);

%%%%%%%%%%%%%% Outputs:
switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end






end %function