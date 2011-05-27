% tracks_pl3 Plot all stations positions using m_scatter
%
% [] = tracks_pl4()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-05-27.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = tracks_pl4(D,varargin)

x = extract(D,'LONGITUDE');
y = extract(D,'LATITUDE');
t = extract(D,'STATION_DATE');

% Make the copoda toolbar faster:
station_locations.LON = x;station_locations.LAT = y;
setappdata(gcf,'station_locations',station_locations);

% Options:
typ = 1;
if nargin > 1
	typ = varargin{1};
end

if length(unique(t)) == 1
	typ = 3;
	warning('All stations on the same date, move to station number as x-axis');
end

switch typ
	case 1
		cmap = jet(length(t));
		cx   = [min(t) max(t)];
		cl   = cx;
	case 2
		cmap = cseason(12);
		cx   = [0 12];
		cl   = cx;
	case 3
		t = extract(D,'STATION_NUMBER');
		cmap = jet(length(t));		
		cx   = [min(t) max(t)];
		cl   = cx;
	case 4
		t = extract(D,'THD');
		cmap = jet(length(t));		
		cx   = [min(t) max(t)];
		cl   = cx;
end

%%%%%%%%%%%%%%%%%%%%%%%%
optimap(D);hold on
colormap(cmap);

switch typ
	case {1,3,4}
		p = m_scatter(x,y,10,t,'marker','+');
	case 2
		p = m_scatter(x,y,10,str2num(datestr(t,'mm')),'marker','+');
end
set(p,'tag','station_location');
caxis(cx);
cl = colorbar;
set(cl,'ylim',cx);
switch typ
	case 1
		yt = linspace(min(t),max(t),12);
		set(cl,'ytick',	 yt	);
		if diff(yt(1:2))<1 % Less than a day
			set(cl,'yticklabel',datestr(yt,'yy/mm/dd HH:MM'));
		else
			set(cl,'yticklabel',datestr(yt,'yyyy/mm/dd'));
		end
	case 2
		yt = [12 1:12];
		set(cl,'ytick',	 0:12	);
		set(cl,'yticklabel',datestr(datenum(1900,yt,15,0,0,0),'mmm'));
	case 3
		
end
set(cl,'fontsize',8);

tt = xlabel(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
set(tt,'fontweight','bold','fontsize',14)

if nargout == 1
	varargout(1) = {p};
end

end %functiontracks_pl4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
