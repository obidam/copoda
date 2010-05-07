%DEF Plot all transects on 1 map with color function of time range
%
% [] = tracks_pl1(D)
% 
%
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

function varargout = tracks_pl1(D)

%y=extract(D,'LATITUDE');
%x=extract(D,'LONGITUDE');
%x(x>=-180 & x<0) = 360 + x(x>=-180 & x<0); % Move to longitude from 0 to 360
% dx=5; dy = 2;
% DOMAIN = [max([min(x)-dx 0]) min([360 max(x)+dx]) max([min(y)-dy -90]) min([max(y)+dy 90])];
% if DOMAIN(2) == 360
% 	DOMAIN(2) = 359.5;
% end
% DOMAIN;

%figure;figure_land;
hold on
optimap(D);

% m_proj('equid','lon',DOMAIN(1:2),'lat',DOMAIN(3:4));
% m_elev('contour',[-3:-1]*1e3,'edgecolor',[1 1 1]*.5);
% m_coast('patch',[1 1 1]*.5);
% m_grid('xtick',[0:10:360],'ytick',[-90:10:90]);
iprof=0;
for isec = 1 : length(D)
	t = D.transect{isec}.cruise_info.DATE(1);
	x = D.transect{isec}.geo.LONGITUDE;
	y = D.transect{isec}.geo.LATITUDE;
	for ip = 1 : length(x)
		iprof = iprof + 1;
		p(iprof).handle = m_plot(x(ip),y(ip),'+','tag','station_location');
		p(iprof).time   = t;
	end
end

year = 1980:2010;
dt = datenum(year(end),12,31,0,0,0) - datenum(year(1),1,1,0,0,0);
icmap = 3;
clear cmap
switch icmap
	case 1 % 1 color per year:
		cmap = jet(length(year));
%		cmap = cmap(randperm(length(year)),:);
		figlabel = '1color_per_1y';
	case 2 % 1 color per decade:
		cmap(find(year<1990),1) = 1;
		cmap(find(year<1990),2) = 0;
		cmap(find(year<1990),3) = 0;
		cmap(find(year>=1990&year<2000),1) = 0;
		cmap(find(year>=1990&year<2000),2) = 1;
		cmap(find(year>=1990&year<2000),3) = 0;
		cmap(find(year>=2000&year<2010),1) = 0;
		cmap(find(year>=2000&year<2010),2) = 0;
		cmap(find(year>=2000&year<2010),3) = 1;
		figlabel = '1color_per_10y';
	case 3 % 1 color every 5 years
		cm = hsv(length(year(1):5:year(end)));
%		ii = randperm(7)
		ii = [ 4     6     2     7     3     5     1];
		cm = cm(ii,:);
		for ip = 0 : length(year(1):5:year(end))-1
			y0 = year(1) + ip*5;
			y1 = year(1) + (ip+1)*5;
			cmap(find(year>=y0&year<y1),1) = cm(ip+1,1);
			cmap(find(year>=y0&year<y1),2) = cm(ip+1,2);
			cmap(find(year>=y0&year<y1),3) = cm(ip+1,3);
		end
			figlabel = '1color_per_5y';
end %switch		

found = zeros(1,size(cmap,1));
for iprof = 1 : size(p,2)
	if ~isnan(p(iprof).handle)
		t  = p(iprof).time - datenum(year(1),1,1,0,0,0);
		ic = fix(t*size(cmap,1)/dt)+1;
		if ic<0,ic=1;end
		set(p(iprof).handle,'markersize',4,'color',cmap(ic,:));
		found(1,ic) = 1;
	end
end
%cmap(found==0,:) = 1;
colormap(cmap);
%caxis([1980 2004]+[0 1]); cl=colorbar;
%set(cl,'ytick',[1980:2004]+.5,'yticklabel',[1980:2004]);
caxis([year(1) year(end)]+[0 1]); cl=colorbar;
set(cl,'ytick',year+.5,'yticklabel',year);

tt = xlabel(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
set(tt,'fontweight','bold','fontsize',14)


switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end






end %function