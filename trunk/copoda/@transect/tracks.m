% tracks Plot the track of a transect object
%
% [p] = tracks(T,[OPTS])
% 
% Plot the track of a transect object, ie the location
% of all profiles on a map.
%
% Inputs:
%	T: a transect object
%	OPTS:
%		1: color with station dates
%		2: color with station seasons
%		3: color with station numbers
%		4: color with station index (1:Ns)
%		5: color with station mixed layer depth
%		6: color with station pycnocline depth
%
% Outputs:
%	p : Handle of points (scatter group)
% 
% Eg:
% Change the look and size of markers:
% 	p = tracks(T,6);
%	set(p,'marker','.','sizedata',40)
% or:
%	set(findall(gcf,'tag','station_location'),'marker','.','sizedata',40)
%
% Created: 2010-05-10.
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
function varargout = tracks(T,varargin)

%- Default parameters:
typ = 1; % Map type
marker = '+';

%- User defined parameters
if nargin > 1
	typ = varargin{1};
end

%- Lood transect profiles coordinates
[x,y,t] = coord(T);

if min(t) == max(t)
	warning('Stations are on the same day, move to Station numbers for color axis');
	t   = extract(T,'STATION_NUMBER');
	typ = 3;
end

%- Determine plot properties according to the requested type of map
switch typ
	case 1
		cmap = jet(length(t));
		cx   = [min(t) max(t)];
		cl   = cx;
		ctit = 'Station date';
	case 2
		cmap = cseason(12);
		cx   = [0 12];
		cl   = cx;
		ctit = 'Station season';		
	case 3
		ids  = extract(T,'STATION_NUMBER');
		cmap = jet(length(ids));
		cx   = [min(ids) max(ids)];
		cl   = cx;
		t = ids;
		ctit = 'Station number';		
	case 4
		[ns nl] = size(T);
		t = 1:ns;
		cmap = jet(ns);
		cx = [1 ns];
		cl = cx;
		ctit = 'Station index';			
	case 5
		t = T.data.MLD.cont;
		cmap = jet(length(t));
		cx   = [min(t) max(t)];
		cl   = cx;
		ctit = 'Mixed layer depth (m)';		
	case 6
		t = T.data.THD.cont;
		cmap = jet(length(t));
		cx   = [min(t) max(t)];
		cl   = cx;
		ctit = 'Pycnocline depth (m)';	
	otherwise	
		error('Unknow track type !')
end%switch typ
	
%%%%%%%%%%%%%%%%%%%%%%%%
%- Do the plot !
hold on
optimap(T);
colormap(cmap);

%- Render profiles locations
if length(x) == 1
	p = m_plot(x,y,'k');
else
	switch typ
		case {1,3,4,5,6}
			if length(x) > 1
				p = m_scatter(x,y,10,t,'marker','+');
			else
				p = m_plot(x,y,'k+');
			end% if 
		case 2
			p = m_scatter(x,y,10,str2num(datestr(t,'mm')),'marker','+');
	end%switch
end% if
set(p,'marker',marker);
set(p,'tag','station_location');

%- Handle colorscale and colorbar
if diff(cx)~=0
	caxis(cx);
	cl = colorbar;
	ctitle(cl,ctit);
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
	end
	set(cl,'fontsize',8);

else
	cl = [];
end% if 

%- Title
tt = title(stamp(T,5),'interpreter','none'); set(tt,'fontweight','bold')
copoda_figtoolbar(T);
set(gcf,'tag','track_map');

%- Output
switch nargout
	case 1
		varargout(1) = {p};
	case 2
		varargout(1) = {p};
		varargout(2) = {cl};
end% switch 


end %functiontracks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













