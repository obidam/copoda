% tracks Plot the track of a transect object
%
% [] = tracks(T,[OPTS])
% 
% Plot the track of a transect object
%
% Inputs:
%	T: a transect object
%	OPTS:
%		1: color with station dates
%		2: color with station seasons
%		3: color with station numbers
%
% Outputs:
%
%
% Created: 2010-05-10.
% http://code.google.com/p/copoda
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
function varargout = tracks(T,varargin)

x = extract(T,'LONGITUDE');
y = extract(T,'LATITUDE');
t = extract(T,'STATION_DATE');

typ = 1;
if nargin > 1
	typ = varargin{1};
end

if min(t) == max(t)
	warning('Stations are on the same day, move to Station numbers tracks plot');
	t = extract(T,'STATION_NUMBER');
	typ = 3;
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
		ids  = extract(T,'STATION_NUMBER');
		cmap = jet(length(ids));
		cx   = [min(ids) max(ids)];
		cl   = cx;
	otherwise	
		error('Unknow track type !')
end
	
%%%%%%%%%%%%%%%%%%%%%%%%
optimap(T);hold on
colormap(cmap);

if 0
	for ip = 1 : length(t)
		p(ip) = m_plot(x(ip),y(ip),'+','tag','station_location');
		switch typ
			case {1,3}
				set(p(ip),'color',cmap(ip,:));
			case 2
				im = str2num(datestr(t(ip),'mm')); 
				set(p(ip),'color',cmap(im,:));
		end
	end
	caxis(cx);
	cl = colorbar;
	set(cl,'ylim',cx);

	switch typ
		case 1
			yt = linspace(min(t),max(t),12);
			set(cl,'ytick',yt);
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
	
else
	switch typ
		case {1,3}
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
end

tt = title(stamp(T,6)); set(tt,'fontweight','bold')
copoda_figtoolbar(T);

if nargout == 1
	varargout(1) = {p};
end

end %functiontracks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













