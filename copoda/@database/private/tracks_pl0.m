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




function varargout = tracks_pl0(D,varargin)

%%%%%%%%%%%%%% Options:
pl_type  = 1;
if nargin >= 2
	pl_type  = varargin{1};
end
show_leg = 1;
if nargin >= 3
	show_leg = varargin{2};
end

%%%%%%%%%%%%%% Cruise info:
[y,x]=extract(D,'LATITUDE',{'LONGITUDE'});
nt = length(D.transect);

figure;hold on

%%%%%%%%%%%%%% Manage projection
switch pl_type
	case 1
		dx = 2;
		dy = 2;
		DOMAIN = [max([min(x)-dx 0]) min([360 max(x)+dx]) max([min(y)-dy -90]) min([max(y)+dy 90])];
		if DOMAIN(2) == 360
			DOMAIN(2) = 359.5;
		end
		m_proj('equid','lon',DOMAIN(1:2),'lat',DOMAIN(3:4));
	case 2
		dx = 10;
		dy = 5;
		DOMAIN = [max([min(x)-dx 0]) min([360 max(x)+dx]) max([min(y)-dy -90]) min([max(y)+dy 90])];
		if DOMAIN(2) == 360
			DOMAIN(2) = 359.5;
		end
		m_proj('equid','lon',DOMAIN(1:2),'lat',DOMAIN(3:4));
	case 3
		m_proj('equid','lon',[0 359.5],'lat',[-90 90]);
end

%%%%%%%%%%%%%% Plot stations
cmap = hsv(nt);
for it = 1 : nt
	T = D.transect{it};
	x = T.geo.LONGITUDE;
	y = T.geo.LATITUDE;
	p(it) = m_plot(x,y,'+'); 
	set(p(it),'color',cmap(it,:));
	leg(it).val = stamp(T,1);
end

%%%%%%%%%%%%%% Topo, Coast and grid:
m_coast('patch',[1 1 1]*.6);
switch pl_type
	case {1,2}
		m_grid('xtick',[0:5:360],'ytick',[-90:5:90]);
	case 3
		m_grid('xtick',[0:20:360],'ytick',[-90:10:90]);
end
m_elev('contour',[-4:-1]*1e3,'edgecolor',[1 1 1]*.5);

%%%%%%%%%%%%%% Text:
switch show_leg
	case 1
		ll = legend(p,leg.val,'location','northoutside');
		set(ll,'interpreter','none','fontweight','normal')
	case 2 % No legend
	otherwise
end

tt = xlabel(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
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