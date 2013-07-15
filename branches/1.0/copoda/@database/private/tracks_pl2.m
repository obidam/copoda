% tracks_pl2 Plot on 1 figure, 1 transect per subplots
%
% [p,tt] = tracks_pl2(D)
% 
% Created: 2009-08-20.
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


function varargout = tracks_pl2(D)

nt = length(D);
%y = extract(D,'LATITUDE');
%x = extract(D,'LONGITUDE');
[x y] = coord(D); % More efficient than extract

% Make the copoda toolbar faster:
station_locations.LON = x;station_locations.LAT = y;
setappdata(gcf,'station_locations',station_locations);


%dx = 5; dy = 2;
%DOMAIN = [max([min(x)-dx 0]) min([360 max(x)+dx]) max([min(y)-dy -90]) min([max(y)+dy 90])];
%m_proj('equid','long',DOMAIN(1:2),'lat',DOMAIN(3:4));

if nt == 1, iw=1;jw=1; end
if nt <=3,  iw=nt;jw=1;end
if nt > 3
	iw=3; 
	jw=fix(nt/iw);
	if jw > 4
		jw = 4;
	end
end

figure;figure_land;

ipl = 0;
for isec = 1 : nt
	ipl=ipl+1;
	subplot(iw,jw,ipl);hold on;
	optimap(D,'topo',false);
%	m_elev('contour',[-3:-1]*1e3,'edgecolor',[1 1 1]*.5)
%	m_coast('patch',[1 1 1]*.5);
%	m_grid('xtick',[0:10:360],'ytick',[0:5:90],'fontsize',6);
	iprof=0;
	t = D.transect{isec}.cruise_info.DATE(1);
	x = D.transect{isec}.geo.LONGITUDE;
	y = D.transect{isec}.geo.LATITUDE;
	for ip = 1 : length(x)
		iprof = iprof + 1;
		p(iprof).handle = m_plot(x(ip),y(ip),'+','tag','station_location');
		p(iprof).time   = t;
	end
	str = stamp(D.transect{isec},5); str = strrep(str,' ',''); 
	if str(1)=='|',str=str(2:end);end
	if str(end)=='|',str=str(1:end-1);end
	str = strrep(str,'||','|');
	title(str,'fontweight','bold','fontsize',8,'interpreter','none');
	if ipl >= iw*jw
		tt = suptitle(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
		set(tt,'fontweight','bold','fontsize',14)
		if isec < nt
			ipl=0;figure;figure_land;
		end		
	end
end%for isec
%tt = suptitle(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
%set(tt,'fontweight','bold','fontsize',14)


switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {tt};
end



end %function